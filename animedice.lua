-- animedice.lua
-- Perubahan: menambahkan fitur musik playlist, SFX, ping, AFK/reconnect, remote binding lengkap,
-- serta sinkronisasi GUI dengan nama MofenkHub.
-- Catatan: script ini dibuat untuk dijalankan sebagai LocalScript di client (mis. StarterPlayerScripts / PlayerGui).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
if not localPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    localPlayer = Players.LocalPlayer
end

local REMOTES_FOLDER = ReplicatedStorage:WaitForChild("Remotes")

local Remotes = {
    RollRequest = REMOTES_FOLDER:FindFirstChild("RollRequest"),
    RollResult = REMOTES_FOLDER:FindFirstChild("RollResult"),

    RequestInventorySnapshot = REMOTES_FOLDER:FindFirstChild("RequestInventorySnapshot"),
    InventoryUpdated = REMOTES_FOLDER:FindFirstChild("InventoryUpdated"),
    RequestItemsSnapshot = REMOTES_FOLDER:FindFirstChild("RequestItemsSnapshot"),
    ItemsUpdated = REMOTES_FOLDER:FindFirstChild("ItemsUpdated"),

    SellItemRequest = REMOTES_FOLDER:FindFirstChild("SellItemRequest"),
    SellAllRequest = REMOTES_FOLDER:FindFirstChild("SellAllRequest"),
    SellSelectedRequest = REMOTES_FOLDER:FindFirstChild("SellSelectedRequest"),
    BuyDiceRequest = REMOTES_FOLDER:FindFirstChild("BuyDiceRequest"),
    DiceBuyResult = REMOTES_FOLDER:FindFirstChild("DiceBuyResult"),
    EquipItem = REMOTES_FOLDER:FindFirstChild("EquipItem"),
    EquipItemResult = REMOTES_FOLDER:FindFirstChild("EquipItemResult"),

    AutoSellStateChanged = REMOTES_FOLDER:FindFirstChild("AutoSellStateChanged"),
    RequestAutoSellState = REMOTES_FOLDER:FindFirstChild("RequestAutoSellState"),
    SetAutoSellUnderRequest = REMOTES_FOLDER:FindFirstChild("SetAutoSellUnderRequest"),
    ToggleAutoSellRarityRequest = REMOTES_FOLDER:FindFirstChild("ToggleAutoSellRarityRequest"),

    AutoRollState = REMOTES_FOLDER:FindFirstChild("AutoRollState"),
    AutoRollResume = REMOTES_FOLDER:FindFirstChild("AutoRollResume"),
    RequestMultiRollState = REMOTES_FOLDER:FindFirstChild("RequestMultiRollState"),

    SpinTraitRequest = REMOTES_FOLDER:FindFirstChild("SpinTraitRequest"),
    SpinTraitResult = REMOTES_FOLDER:FindFirstChild("SpinTraitResult"),

    DungeonShopAutoBuy = REMOTES_FOLDER:FindFirstChild("DungeonShopAutoBuy"),
    DungeonShopPurchase = REMOTES_FOLDER:FindFirstChild("DungeonShopPurchase"),
    DungeonShopUpdated = REMOTES_FOLDER:FindFirstChild("DungeonShopUpdated"),

    RequestMarketSpawn = REMOTES_FOLDER:FindFirstChild("RequestMarketSpawn"),
    PurchaseAnnounce = REMOTES_FOLDER:FindFirstChild("PurchaseAnnounce"),

    PerfTelemetry = REMOTES_FOLDER:FindFirstChild("PerfTelemetry"),
    PerfTelemetryReport = REMOTES_FOLDER:FindFirstChild("PerfTelemetryReport"),

    AfkRejoinRequest = REMOTES_FOLDER:FindFirstChild("AfkRejoinRequest"),
    RequestHubSpawn = REMOTES_FOLDER:FindFirstChild("RequestHubSpawn"),
    RequestMyBaseSpawn = REMOTES_FOLDER:FindFirstChild("RequestMyBaseSpawn"),
}

local UiSoundConfig = {
    RareReveal = "rbxassetid://0",
    SpinTick = "rbxassetid://0",
    Reveal = "rbxassetid://0",
    Pop = "rbxassetid://0",
    Toggle = "rbxassetid://0",
    Error = "rbxassetid://0",
    Click = "rbxassetid://0",
}

local MUSIC_LIBRARY = {
    { title = "NOAH — Walau Habis Terang", asset = "rbxassetid://437537543" },
    { title = "NOAH — Separuh Aku", asset = "rbxassetid://508366813" },
    { title = "Sheila On 7 — Melompat Lebih Tinggi", asset = "rbxassetid://1280474324" },
    { title = "Sheila On 7 — Dan", asset = "rbxassetid://1837802963" },
    { title = "Armada — Asal Kau Bahagia", asset = "rbxassetid://1274144324" },
    { title = "Last Child — Seluruh Nafas Ini", asset = "rbxassetid://297132093" },
}

local CONFIG = {
    GuiName = "MofenkHub",
    RollButtonName = "RollButton",
    InventoryPanelName = "InventoryPanel",
    MarketPanelName = "MarketPanel",
    SpinnerName = "Spinner",
    PingLabelName = "PingLabel",
    AfkIndicatorName = "AfkIndicator",
    MusicSelectorName = "MusicSelector",
    ToggleNames = {
        AutoSell = "ToggleAutoSell",
        AutoRoll = "ToggleAutoRoll",
        AutoDungeon = "ToggleAutoDungeon",
    },
}

local state = {
    rolling = false,
    gui = nil,
    elements = {},
    lastInput = tick(),
    afk = false,
    pingMs = nil,
    musicPlaying = false,
    musicInstance = nil,
    currentMusicIndex = 1,
}

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

local function findGui(name)
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    return pg:FindFirstChild(name, true)
end

local function setButtonEnabled(button, enabled)
    if not button then return end
    if button:IsA("GuiButton") then
        button.Active = enabled
        button.AutoButtonColor = enabled
        local target = enabled and 1 or 0.5
        pcall(function()
            TweenService:Create(button, TweenInfo.new(0.15), {BackgroundTransparency = 1 - target}):Play()
        end)
    end
end

local function setSpinnerVisible(visible)
    local spinner = state.elements[CONFIG.SpinnerName]
    if spinner then spinner.Visible = visible end
end

local function stopCurrentMusic()
    if state.musicInstance then
        pcall(function()
            state.musicInstance:Stop()
            state.musicInstance:Destroy()
        end)
        state.musicInstance = nil
        state.musicPlaying = false
    end
end

local function playMusicByIndex(index)
    if not MUSIC_LIBRARY or #MUSIC_LIBRARY == 0 then return end
    index = ((index - 1) % #MUSIC_LIBRARY) + 1
    state.currentMusicIndex = index
    local track = MUSIC_LIBRARY[index]
    if not track or not track.asset then return end

    stopCurrentMusic()
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg then return end

    local sound = Instance.new("Sound")
    sound.Name = "_AnimeDiceBackgroundMusic"
    sound.SoundId = track.asset
    sound.Looped = false
    sound.Volume = 0.55
    sound.Parent = pg

    local ok, err = pcall(function()
        sound:Play()
    end)
    if not ok then
        warn("Failed to play music:", err)
    end

    state.musicInstance = sound
    state.musicPlaying = true

    sound.Ended:Connect(function()
        local nextIndex = state.currentMusicIndex + 1
        if nextIndex > #MUSIC_LIBRARY then nextIndex = 1 end
        playMusicByIndex(nextIndex)
    end)
end

local function playMusic(asset)
    for i, track in ipairs(MUSIC_LIBRARY) do
        if track.asset == asset then
            playMusicByIndex(i)
            return
        end
    end
    playMusicByIndex(1)
end

local function playSfx(asset)
    if not asset or asset == "" then return end
    local pg = localPlayer:FindFirstChild("PlayerGui")
    if not pg then return end

    local s = Instance.new("Sound")
    s.SoundId = asset
    s.Looped = false
    s.Volume = 0.85
    s.Parent = pg
    pcall(function() s:Play() end)
    s.Ended:Connect(function()
        pcall(function() s:Destroy() end)
    end)
end

local function populateMusicSelector(selector)
    if not selector then return end
    local template = selector:FindFirstChild("MusicTemplate")
    if not template then
        template = Instance.new("TextButton")
        template.Name = "MusicTemplate"
        template.Text = "Track"
        template.Size = UDim2.new(1, 0, 0, 28)
        template.BackgroundTransparency = 0.6
        template.Parent = selector
        template.Visible = false
    end

    for _, child in pairs(selector:GetChildren()) do
        if child.Name:sub(1, 6) == "Track_" then
            child:Destroy()
        end
    end

    for i, track in ipairs(MUSIC_LIBRARY) do
        local clone = template:Clone()
        clone.Name = "Track_" .. i
        clone.Text = track.title
        clone.Visible = true
        clone.Parent = selector

        clone.MouseButton1Click:Connect(function()
            playMusicByIndex(i)
            for _, c in pairs(selector:GetChildren()) do
                if c:IsA("TextButton") then
                    c.BackgroundTransparency = 0.6
                end
            end
            clone.BackgroundTransparency = 0.2
            playSfx(UiSoundConfig.Click)
        end)

        if i == state.currentMusicIndex then
            clone.BackgroundTransparency = 0.2
        end
    end
end

local function updateInventoryUI(snapshot)
    if not snapshot then return end
    local invPanel = state.elements[CONFIG.InventoryPanelName]
    if not invPanel then return end
    local list = invPanel:FindFirstChild("ItemList")
    if not list then return end

    for _, child in pairs(list:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "Template" then
            child:Destroy()
        end
    end

    local template = list:FindFirstChild("Template")
    if not template then return end

    for i, item in ipairs(snapshot or {}) do
        local clone = template:Clone()
        clone.Name = "Item_" .. tostring(i)
        clone.Parent = list
        clone.Visible = true

        local title = clone:FindFirstChild("Title")
        if title then
            title.Text = tostring(item.Name or "Item")
        end

        local qty = clone:FindFirstChild("Qty")
        if qty then
            qty.Text = tostring(item.Quantity or 1)
        end
    end
end

local function refreshInventory()
    if not Remotes.RequestInventorySnapshot then return end
    setSpinnerVisible(true)
    spawn(function()
        local snapshot, err = safeInvoke(Remotes.RequestInventorySnapshot)
        if snapshot then
            pcall(updateInventoryUI, snapshot)
        else
            warn("RequestInventorySnapshot error:", err)
        end
        setSpinnerVisible(false)
    end)
end

local function openMarketPanel()
    if Remotes.RequestMarketSpawn then
        spawn(function()
            setSpinnerVisible(true)
            local ok, err = pcall(function()
                Remotes.RequestMarketSpawn:InvokeServer()
            end)
            if not ok then
                warn("RequestMarketSpawn failed:", err)
            end
            refreshInventory()
            setSpinnerVisible(false)
        end)
    else
        refreshInventory()
    end
end

local function sellItem(itemId)
    if Remotes.SellItemRequest then
        safeFire(Remotes.SellItemRequest, itemId)
    end
end

local function sellAll()
    if Remotes.SellAllRequest then
        safeFire(Remotes.SellAllRequest)
    end
end

local function buyDice(productId)
    if Remotes.BuyDiceRequest then
        safeFire(Remotes.BuyDiceRequest, productId)
    end
end

local function equipItem(itemId)
    if Remotes.EquipItem then
        safeFire(Remotes.EquipItem, itemId)
    end
end

local function onRollPressed()
    if state.rolling then return end
    local rollBtn = state.elements[CONFIG.RollButtonName]
    if not rollBtn then return end

    state.rolling = true
    setButtonEnabled(rollBtn, false)
    setSpinnerVisible(true)
    playSfx(UiSoundConfig.Click)

    if Remotes.RollRequest and Remotes.RollRequest:IsA("RemoteEvent") then
        safeFire(Remotes.RollRequest)
    elseif Remotes.RollRequest and Remotes.RollRequest:IsA("RemoteFunction") then
        spawn(function()
            local res, err = safeInvoke(Remotes.RollRequest)
            if not res then
                warn(err)
            end
        end)
    else
        warn("RollRequest not found")
        state.rolling = false
        setButtonEnabled(rollBtn, true)
        setSpinnerVisible(false)
        return
    end
end

local function onRollResultReceived(data)
    setSpinnerVisible(false)
    state.rolling = false
    local rollBtn = state.elements[CONFIG.RollButtonName]
    setButtonEnabled(rollBtn, true)
    playSfx(UiSoundConfig.Reveal)

    if type(data) == "table" and data.InventorySnapshot then
        pcall(updateInventoryUI, data.InventorySnapshot)
    end
end

local function handleToggle(toggleName, remoteSet, remoteRequest)
    local togg = state.elements[toggleName]
    if not togg then return end

    local function setValue(v)
        if togg:IsA("GuiButton") then
            togg.Active = v
        end
        if togg:FindFirstChild("Fill") then
            togg.Fill.Visible = v
        end
    end

    local function onClicked()
        local current = not (togg.Active == true)
        setValue(current)
        playSfx(UiSoundConfig.Toggle)

        if remoteSet and remoteSet:IsA("RemoteEvent") then
            safeFire(remoteSet, current)
        elseif remoteSet and remoteSet:IsA("RemoteFunction") then
            spawn(function()
                safeInvoke(remoteSet, current)
            end)
        end
    end

    if remoteRequest then
        spawn(function()
            local res = safeInvoke(remoteRequest)
            if res ~= nil then
                pcall(setValue, res)
            end
        end)
    end

    if togg:IsA("GuiButton") then
        togg.Activated:Connect(onClicked)
    else
        togg.InputBegan:Connect(function(input)
            if input.UserInputType.Name == "MouseButton1" or input.UserInputType.Name == "Touch" then
                onClicked()
            end
        end)
    end
end

local function wireRemotes()
    if Remotes.RollResult and Remotes.RollResult:IsA("RemoteEvent") then
        Remotes.RollResult.OnClientEvent:Connect(onRollResultReceived)
    end

    if Remotes.InventoryUpdated and Remotes.InventoryUpdated:IsA("RemoteEvent") then
        Remotes.InventoryUpdated.OnClientEvent:Connect(function()
            pcall(refreshInventory)
        end)
    end

    if Remotes.ItemsUpdated and Remotes.ItemsUpdated:IsA("RemoteEvent") then
        Remotes.ItemsUpdated.OnClientEvent:Connect(function()
            pcall(refreshInventory)
        end)
    end

    if Remotes.AutoRollState and Remotes.AutoRollState:IsA("RemoteEvent") then
        Remotes.AutoRollState.OnClientEvent:Connect(function(v)
            local togg = state.elements[CONFIG.ToggleNames.AutoRoll]
            if togg and togg:IsA("GuiButton") then
                togg.Active = v
            end
        end)
    end

    if Remotes.AutoSellStateChanged and Remotes.AutoSellStateChanged:IsA("RemoteEvent") then
        Remotes.AutoSellStateChanged.OnClientEvent:Connect(function(v)
            local togg = state.elements[CONFIG.ToggleNames.AutoSell]
            if togg and togg:IsA("GuiButton") then
                togg.Active = v
            end
        end)
    end

    if Remotes.SpinTraitResult and Remotes.SpinTraitResult:IsA("RemoteEvent") then
        Remotes.SpinTraitResult.OnClientEvent:Connect(function(payload)
            print("SpinTraitResult", payload)
        end)
    end

    if Remotes.DungeonShopUpdated and Remotes.DungeonShopUpdated:IsA("RemoteEvent") then
        Remotes.DungeonShopUpdated.OnClientEvent:Connect(function()
            print("Dungeon shop updated")
        end)
    end

    if Remotes.PerfTelemetry and Remotes.PerfTelemetry:IsA("RemoteEvent") then
        Remotes.PerfTelemetry.OnClientEvent:Connect(function(data)
            local ms = nil
            if type(data) == "table" then
                ms = data.ping or data.pingMs or data.ms or data.Ping
            elseif type(data) == "number" then
                ms = data
            end

            if ms then
                state.pingMs = ms
                local pingLabel = state.elements[CONFIG.PingLabelName]
                if pingLabel then
                    pingLabel.Text = string.format("Ping: %dms", math.floor(ms))
                    local c = Color3.new(0, 1, 0)
                    if ms >= 200 then
                        c = Color3.new(1, 0, 0)
                    elseif ms >= 100 then
                        c = Color3.new(1, 0.8, 0)
                    end
                    pcall(function()
                        pingLabel.TextColor3 = c
                    end)
                end
            end
        end)
    end
end

local AFK_THRESHOLD = 60 * 5
local RECONNECT_WAIT = 10

local function markInput()
    state.lastInput = tick()
    if state.afk then
        state.afk = false
        local ai = state.elements[CONFIG.AfkIndicatorName]
        if ai then ai.Visible = false end
    end
end

UserInputService.InputBegan:Connect(function() markInput() end)
UserInputService.InputChanged:Connect(function() markInput() end)
UserInputService.InputEnded:Connect(function() markInput() end)

spawn(function()
    while true do
        local now = tick()
        if now - state.lastInput >= AFK_THRESHOLD and not state.afk then
            state.afk = true
            local ai = state.elements[CONFIG.AfkIndicatorName]
            if ai then ai.Visible = true end

            if Remotes.AfkRejoinRequest and Remotes.AfkRejoinRequest:IsA("RemoteEvent") then
                safeFire(Remotes.AfkRejoinRequest)
            elseif Remotes.AfkRejoinRequest and Remotes.AfkRejoinRequest:IsA("RemoteFunction") then
                spawn(function()
                    safeInvoke(Remotes.AfkRejoinRequest)
                end)
            end
        end
        wait(5)
    end
end)

spawn(function()
    while true do
        local chr = localPlayer.Character
        if not chr or not chr.Parent then
            wait(RECONNECT_WAIT)
            if not localPlayer.Character or not localPlayer.Character.Parent then
                if Remotes.RequestHubSpawn then
                    safeInvoke(Remotes.RequestHubSpawn)
                end
            end
        end
        wait(2)
    end
end)

local function cacheGuiElements()
    local gui = findGui(CONFIG.GuiName)
    if not gui then
        warn("GUI not found: " .. tostring(CONFIG.GuiName))
        return false
    end

    state.gui = gui

    local function tryGet(name)
        local obj = gui:FindFirstChild(name, true)
        if obj then
            state.elements[name] = obj
        end
        return obj
    end

    tryGet(CONFIG.RollButtonName)
    tryGet(CONFIG.InventoryPanelName)
    tryGet(CONFIG.MarketPanelName)
    tryGet(CONFIG.SpinnerName)
    tryGet(CONFIG.PingLabelName)
    tryGet(CONFIG.AfkIndicatorName)
    tryGet(CONFIG.MusicSelectorName)

    for _, v in pairs(CONFIG.ToggleNames) do
        tryGet(v)
    end

    return true
end

local function setupUI()
    if not cacheGuiElements() then return end

    local rollBtn = state.elements[CONFIG.RollButtonName]
    if rollBtn and rollBtn:IsA("GuiButton") then
        rollBtn.Activated:Connect(onRollPressed)
    end

    handleToggle(CONFIG.ToggleNames.AutoSell, Remotes.SetAutoSellUnderRequest or Remotes.ToggleAutoSellRarityRequest, Remotes.RequestAutoSellState)
    handleToggle(CONFIG.ToggleNames.AutoRoll, Remotes.AutoRollState or Remotes.AutoRollResume, Remotes.RequestMultiRollState)
    handleToggle(CONFIG.ToggleNames.AutoDungeon, Remotes.DungeonShopAutoBuy, nil)

    local marketBtn = state.gui:FindFirstChild("OpenMarketButton", true)
    if marketBtn and marketBtn:IsA("GuiButton") then
        marketBtn.Activated:Connect(openMarketPanel)
    end

    if state.elements[CONFIG.MusicSelectorName] then
        populateMusicSelector(state.elements[CONFIG.MusicSelectorName])
    end

    refreshInventory()
    wireRemotes()

    if #MUSIC_LIBRARY > 0 then
        playMusicByIndex(1)
    end
end

local function watchForGui()
    local pg = localPlayer:WaitForChild("PlayerGui")
    if pg:FindFirstChild(CONFIG.GuiName, true) then
        setupUI()
        return
    end

    pg.DescendantAdded:Connect(function(desc)
        if desc.Name == CONFIG.GuiName or desc.Name == CONFIG.RollButtonName then
            wait(0.05)
            setupUI()
        end
    end)
end

spawn(function()
    pcall(watchForGui)
end)

-- End of file
