-- animedice.lua
-- Perubahan: menambahkan fitur client-side UI helpers yang terhubung ke RemoteEvents/RemoteFunctions
-- Fitur yang ditambahkan:
--  - Debounce/disable Roll button saat request berjalan
--  - Auto-refresh inventory & market saat membuka panel
--  - Sinkronisasi toggle (AutoSell, AutoRoll, AutoDungeon) dengan server
--  - Listener untuk update Inventory/Items (realtime)
--  - Handler aman untuk RemoteFunction (pcall)
--  - Tempat konfigurasi nama GUI agar mudah disesuaikan
-- Catatan: Script ini adalah LocalScript untuk dijalankan di client (StarterPlayerScripts / PlayerGui).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
if not localPlayer then
    -- Jika dijalankan sebelum LocalPlayer tersedia (mis. command line), tunggu
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    localPlayer = Players.LocalPlayer
end

-- PATHS / NAMES (sesuaikan jika GUI punya nama lain di projectmu)
local REMOTES_FOLDER = ReplicatedStorage:WaitForChild("Remotes")
-- Remotes yang digunakan (boleh ditambah/ubah sesuai repo)
local Remotes = {
    RollRequest = REMOTES_FOLDER:FindFirstChild("RollRequest"),
    RollResult = REMOTES_FOLDER:FindFirstChild("RollResult"),
    RequestInventorySnapshot = REMOTES_FOLDER:FindFirstChild("RequestInventorySnapshot"),
    InventoryUpdated = REMOTES_FOLDER:FindFirstChild("InventoryUpdated"),
    RequestMarketSpawn = REMOTES_FOLDER:FindFirstChild("RequestMarketSpawn"),
    AutoSellState = REMOTES_FOLDER:FindFirstChild("AutoSellStateChanged"),
    RequestAutoSellState = REMOTES_FOLDER:FindFirstChild("RequestAutoSellState"),
    AutoRollState = REMOTES_FOLDER:FindFirstChild("AutoRollState"),
    AutoRollResume = REMOTES_FOLDER:FindFirstChild("AutoRollResume"),
    RequestRollSpeedState = REMOTES_FOLDER:FindFirstChild("RequestRollSpeedState"),
    RequestMultiRollState = REMOTES_FOLDER:FindFirstChild("RequestMultiRollState"),
    InventorySpaceUpdate = REMOTES_FOLDER:FindFirstChild("InventorySpaceUpgradeResult"),
    ItemsUpdated = REMOTES_FOLDER:FindFirstChild("ItemsUpdated"),
}

-- Safety helper: invoke remote function if exists
local function safeInvoke(remoteFunc, ...)
    if not remoteFunc then return nil, "MissingRemote" end
    local ok, result = pcall(function()
        return remoteFunc:InvokeServer(...)
    end)
    if not ok then
        warn("Invoke failed:", result)
        return nil, result
    end
    return result
end

-- Fire RemoteEvent safely
local function safeFire(remoteEvent, ...)
    if not remoteEvent then return false end
    local ok, err = pcall(function()
        remoteEvent:FireServer(...)
    end)
    if not ok then
        warn("FireServer failed:", err)
        return false
    end
    return true
end

-- GUI lookup (modular) - coba cari di PlayerGui
local function findGui(name)
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    return pg:FindFirstChild(name, true) -- search descendants
end

-- CONFIG: sesuaikan nama GUI dan elemen
local CONFIG = {
    GuiName = "AnimeDiceGui", -- ganti sesuai nama GUI di PlayerGui
    RollButtonName = "RollButton",
    InventoryPanelName = "InventoryPanel",
    MarketPanelName = "MarketPanel",
    SpinnerName = "Spinner",
    ToggleNames = {
        AutoSell = "ToggleAutoSell",
        AutoRoll = "ToggleAutoRoll",
        AutoDungeon = "ToggleAutoDungeon",
    },
}

-- State
local state = {
    rolling = false,
    gui = nil,
    elements = {},
}

-- Utility: set enabled/disabled visual pada tombol
local function setButtonEnabled(button, enabled)
    if not button then return end
    -- Jika button punya Active property (ImageButton / TextButton), gunakan
    if button:IsA("GuiButton") then
        button.Active = enabled
        button.AutoButtonColor = enabled
        -- tween opacity for feedback
        local target = enabled and 1 or 0.5
        pcall(function()
            TweenService:Create(button, TweenInfo.new(0.15), {BackgroundTransparency = 1 - target}):Play()
        end)
    end
end

-- Show / hide spinner
local function setSpinnerVisible(visible)
    local spinner = state.elements[CONFIG.SpinnerName]
    if spinner then
        spinner.Visible = visible
    end
end

-- Update inventory UI (simple) - ini placeholder, sesuaikan dengan struktur GUI mu
local function updateInventoryUI(snapshot)
    if not snapshot then return end
    -- jika ada panel list, bersihkan dan tambahkan entries
    local invPanel = state.elements[CONFIG.InventoryPanelName]
    if not invPanel then return end
    local list = invPanel:FindFirstChild("ItemList")
    if not list then return end

    -- clear existing
    for _, child in pairs(list:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "Template" then
            child:Destroy()
        end
    end

    local template = list:FindFirstChild("Template")
    if not template then return end

    for i, item in ipairs(snapshot or {}) do
        local clone = template:Clone()
        clone.Name = "Item_"..tostring(i)
        clone.Parent = list
        clone.Visible = true
        local title = clone:FindFirstChild("Title")
        if title then title.Text = tostring(item.Name or "Item") end
        local qty = clone:FindFirstChild("Qty")
        if qty then qty.Text = tostring(item.Quantity or 1) end
    end
end

-- Refresh inventory snapshot from server
local function refreshInventory()
    if not Remotes.RequestInventorySnapshot then return end
    setSpinnerVisible(true)
    spawn(function()
        local snapshot, err = safeInvoke(Remotes.RequestInventorySnapshot)
        if snapshot then
            pcall(updateInventoryUI, snapshot)
        else
            warn("Failed RequestInventorySnapshot:", err)
        end
        setSpinnerVisible(false)
    end)
end

-- Open market/panel: request server to spawn market and refresh data
local function openMarketPanel()
    if Remotes.RequestMarketSpawn then
        spawn(function()
            setSpinnerVisible(true)
            local ok, err = pcall(function()
                Remotes.RequestMarketSpawn:InvokeServer()
            end)
            if not ok then warn("RequestMarketSpawn failed:", err) end
            refreshInventory()
            setSpinnerVisible(false)
        end)
    else
        -- fall back: just refresh inventory
        refreshInventory()
    end
end

-- Roll button logic with debounce and result handling
local function onRollPressed()
    if state.rolling then return end
    local rollBtn = state.elements[CONFIG.RollButtonName]
    if not rollBtn then return end

    -- disable UI & set state
    state.rolling = true
    setButtonEnabled(rollBtn, false)
    setSpinnerVisible(true)

    -- fire RollRequest (as RemoteEvent); if RemoteFunction use Invoke
    if Remotes.RollRequest and Remotes.RollRequest:IsA("RemoteEvent") then
        safeFire(Remotes.RollRequest)
    elseif Remotes.RollRequest and Remotes.RollRequest:IsA("RemoteFunction") then
        spawn(function()
            local res, err = safeInvoke(Remotes.RollRequest)
            if res == nil then warn("RollRequest invoke error:", err) end
        end)
    else
        warn("RollRequest remote not found")
        state.rolling = false
        setButtonEnabled(rollBtn, true)
        setSpinnerVisible(false)
        return
    end

    -- Wait for RollResult event to re-enable in the listener below
end

-- Listener for RollResult
local function onRollResultReceived(data)
    -- data could be nil or table; play fx / update UI
    setSpinnerVisible(false)
    state.rolling = false
    local rollBtn = state.elements[CONFIG.RollButtonName]
    setButtonEnabled(rollBtn, true)

    -- Example: jika ada field InventorySnapshot di data, refresh
    if type(data) == "table" then
        if data.InventorySnapshot then
            pcall(updateInventoryUI, data.InventorySnapshot)
        end
        -- play reveal sound / visual jika perlu (implement jika ada suara/FX)
    end
end

-- Toggle handlers: sync toggle with server and update local UI
local function handleToggle(toggleName, remoteSet, remoteRequest)
    local togg = state.elements[toggleName]
    if not togg then return end
    local function setValue(v)
        -- togg might be ImageButton with different states; this is placeholder
        if togg:IsA("GuiButton") then
            togg.Active = v
        end
        -- set visual state e.g. change image or fill
        if togg:FindFirstChild("Fill") then
            togg.Fill.Visible = v
        end
    end

    local function onClicked()
        local current = not togg.Active
        setValue(current)
        -- send request to server to change state
        if remoteSet and remoteSet:IsA("RemoteEvent") then
            safeFire(remoteSet, current)
        elseif remoteSet and remoteSet:IsA("RemoteFunction") then
            spawn(function() safeInvoke(remoteSet, current) end)
        end
    end

    -- initial request to fetch state from server if available
    if remoteRequest then
        spawn(function()
            local res, err = safeInvoke(remoteRequest)
            if res ~= nil then
                pcall(setValue, res)
            end
        end)
    end

    -- connect click
    if togg:IsA("GuiButton") then
        togg.Activated:Connect(onClicked)
    else
        -- fallback: catch InputBegan
        if togg:IsA("GuiObject") then
            togg.InputBegan:Connect(function(input)
                if input.UserInputType.Name == "MouseButton1" or input.UserInputType.Name == "Touch" then
                    onClicked()
                end
            end)
        end
    end
end

-- Utility: wire up listeners from Remotes
local function wireRemotes()
    -- RollResult
    if Remotes.RollResult and Remotes.RollResult:IsA("RemoteEvent") then
        Remotes.RollResult.OnClientEvent:Connect(onRollResultReceived)
    end

    -- InventoryUpdated
    if Remotes.InventoryUpdated and Remotes.InventoryUpdated:IsA("RemoteEvent") then
        Remotes.InventoryUpdated.OnClientEvent:Connect(function(data)
            -- data could be delta; easiest is to re-request snapshot
            pcall(refreshInventory)
        end)
    end

    -- ItemsUpdated
    if Remotes.ItemsUpdated and Remotes.ItemsUpdated:IsA("RemoteEvent") then
        Remotes.ItemsUpdated.OnClientEvent:Connect(function()
            pcall(refreshInventory)
        end)
    end

    -- AutoRollState update -> update toggle visual if exists
    if Remotes.AutoRollState and Remotes.AutoRollState:IsA("RemoteEvent") then
        Remotes.AutoRollState.OnClientEvent:Connect(function(stateVal)
            local togg = state.elements[CONFIG.ToggleNames.AutoRoll]
            if togg and togg:IsA("GuiButton") then
                togg.Active = stateVal
            end
        end)
    end

    -- AutoSellStateChanged
    if Remotes.AutoSellState and Remotes.AutoSellState:IsA("RemoteEvent") then
        Remotes.AutoSellState.OnClientEvent:Connect(function(stateVal)
            local togg = state.elements[CONFIG.ToggleNames.AutoSell]
            if togg and togg:IsA("GuiButton") then
                togg.Active = stateVal
            end
        end)
    end

    -- InventorySpaceUpdate (inform user)
    if Remotes.InventorySpaceUpdate and Remotes.InventorySpaceUpdate:IsA("RemoteEvent") then
        Remotes.InventorySpaceUpdate.OnClientEvent:Connect(function(info)
            -- contoh: tampil notifikasi kecil
            print("Inventory space update:", info)
        end)
    end
end

-- Find GUI elements based on CONFIG and cache them
local function cacheGuiElements()
    local gui = findGui(CONFIG.GuiName)
    if not gui then
        warn("GUI not found: "..tostring(CONFIG.GuiName))
        return false
    end
    state.gui = gui
    -- try to find elements
    local function tryGet(name)
        local obj = gui:FindFirstChild(name, true)
        if obj then state.elements[name] = obj end
        return obj
    end

    tryGet(CONFIG.RollButtonName)
    tryGet(CONFIG.InventoryPanelName)
    tryGet(CONFIG.MarketPanelName)
    tryGet(CONFIG.SpinnerName)

    for k,v in pairs(CONFIG.ToggleNames) do
        tryGet(v)
    end

    return true
end

-- Hook up UI after GUI exists
local function setupUI()
    if not cacheGuiElements() then return end

    -- Roll button
    local rollBtn = state.elements[CONFIG.RollButtonName]
    if rollBtn and rollBtn:IsA("GuiButton") then
        rollBtn.Activated:Connect(onRollPressed)
    end

    -- Toggle handlers
    handleToggle(CONFIG.ToggleNames.AutoSell, Remotes.SetAutoSellUnderRequest or Remotes.ToggleAutoSellRarityRequest, Remotes.RequestAutoSellState)
    handleToggle(CONFIG.ToggleNames.AutoRoll, Remotes.AutoRollState or Remotes.AutoRollResume, Remotes.RequestMultiRollState)
    handleToggle(CONFIG.ToggleNames.AutoDungeon, Remotes.RequestDungeonTeleport, nil) -- contoh: customize

    -- Market open button (jika ada)
    local marketBtn = state.gui:FindFirstChild("OpenMarketButton", true)
    if marketBtn and marketBtn:IsA("GuiButton") then
        marketBtn.Activated:Connect(openMarketPanel)
    end

    -- Show initial inventory when opening panel or on load
    refreshInventory()

    -- wire remotes listeners
    wireRemotes()
end

-- Watch for Gui being added to PlayerGui (useful if GUI spawned later)
local function watchForGui()
    local pg = localPlayer:WaitForChild("PlayerGui")
    -- immediate attempt
    if pg:FindFirstChild(CONFIG.GuiName, true) then
        setupUI()
        return
    end

    -- listen for descendants added
    pg.DescendantAdded:Connect(function(desc)
        if desc.Name == CONFIG.GuiName then
            -- small wait for full hierarchy
            wait(0.1)
            setupUI()
        end
    end)
end

-- Start
spawn(function()
    pcall(watchForGui)
end)

-- End of script
