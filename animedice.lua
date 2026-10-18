-- animedice.lua
-- Perubahan: menambahkan fitur musik playlist, SFX, ping, AFK/reconnect, remote binding lengkap,
-- serta sinkronisasi GUI dengan nama MofenkHub.
-- Diperkuat agar lebih defensif terhadap environment (mis. executor/console) dan tidak memanggil nilai nil.
-- Catatan: script ini dibuat untuk dijalankan sebagai LocalScript di client (mis. StarterPlayerScripts / PlayerGui).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Compatibility helpers (fall back when task/spawn/wait/delay not available)
local safeSpawn
local safeDelay
local safeWait
if type(task) == "table" and type(task.spawn) == "function" then
    safeSpawn = task.spawn
    safeDelay = task.delay
    safeWait = task.wait
else
    safeSpawn = spawn or function(fn) coroutine.wrap(fn)() end
    safeDelay = delay or function(t, fn) spawn(function() wait(t) fn() end) end
    safeWait = wait
end

local localPlayer = Players.LocalPlayer
-- If LocalPlayer not available immediately (shouldn't happen in a proper LocalScript environment), try briefly
if not localPlayer then
    -- Wait a short amount; avoid indefinite yields in hostile/executor environments
    local ok = pcall(function() Players:GetPropertyChangedSignal("LocalPlayer"):Wait() end)
    if ok then
        localPlayer = Players.LocalPlayer
    else
        -- last resort: try a short wait
        safeWait(0.2)
        localPlayer = Players.LocalPlayer
    end
end

-- If still not present, bail out gracefully.
if not localPlayer or not localPlayer:IsA("Player") then
    warn("animedice.lua: LocalPlayer not found. This script must run as a LocalScript in the client (StarterPlayerScripts/PlayerGui). Aborting to avoid runtime errors.")
    return
end

-- Try to find remotes folder defensively; don't yield indefinitely.
local REMOTES_FOLDER = ReplicatedStorage:FindFirstChild("Remotes")

local function safeFindRemote(name)
    if not REMOTES_FOLDER then return nil end
    return REMOTES_FOLDER:FindFirstChild(name)
end

local Remotes = {
    RollRequest = safeFindRemote("RollRequest"),
    RollResult = safeFindRemote("RollResult"),

    RequestInventorySnapshot = safeFindRemote("RequestInventorySnapshot"),
    InventoryUpdated = safeFindRemote("InventoryUpdated"),
    RequestItemsSnapshot = safeFindRemote("RequestItemsSnapshot"),
    ItemsUpdated = safeFindRemote("ItemsUpdated"),

    SellItemRequest = safeFindRemote("SellItemRequest"),
    SellAllRequest = safeFindRemote("SellAllRequest"),
    SellSelectedRequest = safeFindRemote("SellSelectedRequest"),
    BuyDiceRequest = safeFindRemote("BuyDiceRequest"),
    DiceBuyResult = safeFindRemote("DiceBuyResult"),
    EquipItem = safeFindRemote("EquipItem"),
    EquipItemResult = safeFindRemote("EquipItemResult"),

    AutoSellStateChanged = safeFindRemote("AutoSellStateChanged"),
    RequestAutoSellState = safeFindRemote("RequestAutoSellState"),
    SetAutoSellUnderRequest = safeFindRemote("SetAutoSellUnderRequest"),
    ToggleAutoSellRarityRequest = safeFindRemote("ToggleAutoSellRarityRequest"),

    AutoRollState = safeFindRemote("AutoRollState"),
    AutoRollResume = safeFindRemote("AutoRollResume"),
    RequestMultiRollState = safeFindRemote("RequestMultiRollState"),

    SpinTraitRequest = safeFindRemote("SpinTraitRequest"),
    SpinTraitResult = safeFindRemote("SpinTraitResult"),

    DungeonShopAutoBuy = safeFindRemote("DungeonShopAutoBuy"),
    DungeonShopPurchase = safeFindRemote("DungeonShopPurchase"),
    DungeonShopUpdated = safeFindRemote("DungeonShopUpdated"),

    RequestMarketSpawn = safeFindRemote("RequestMarketSpawn"),
    PurchaseAnnounce = safeFindRemote("PurchaseAnnounce"),

    PerfTelemetry = safeFindRemote("PerfTelemetry"),
    PerfTelemetryReport = safeFindRemote("PerfTelemetryReport"),

    AfkRejoinRequest = safeFindRemote("AfkRejoinRequest"),
    RequestHubSpawn = safeFindRemote("RequestHubSpawn"),
    RequestMyBaseSpawn = safeFindRemote("RequestMyBaseSpawn"),
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
        if type(remoteFunc.InvokeServer) == "function" then
            return remoteFunc:InvokeServer(...)
        else
            error("Remote is not invokable: " .. tostring(remoteFunc))
        end
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
        if type(remoteEvent.FireServer) == "function" then
            remoteEvent:FireServer(...)
        else
            error("Remote is not a RemoteEvent: " .. tostring(remoteEvent))
        end
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
    if spinner then
        pcall(function() spinner.Visible = visible end)
    end
end

local function stopCurrentMusic()
    if state.musicInstance then
        pcall(function()
            if type(state.musicInstance.Stop) == "function" then
                state.musicInstance:Stop()
            end
            if type(state.musicInstance.Destroy) == "function" then
                state.musicInstance:Destroy()
            end
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
        if type(sound.Play) == "function" then
            sound:Play()
        end
    end)
    if not ok then
        warn("Failed to play music:", err)
    end

    state.musicInstance = sound
    state.musicPlaying = true

    -- Connect Ended safely
    if type(sound.Ended) == "RBXScriptSignal" or sound.Ended then
        pcall(function()
            sound.Ended:Connect(function()
                local nextIndex = state.currentMusicIndex + 1
                if nextIndex > #MUSIC_LIBRARY then nextIndex = 1 end
                -- Use safeSpawn to avoid deep recursion
                safeSpawn(function()
                    playMusicByIndex(nextIndex)
                end)
            end)
        end)
    end
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
    pcall(function()
        if type(s.Play) == "function" then s:Play() end
    end)
    pcall(function()
        if s.Ended then
            s.Ended:Connect(function()
                pcall(function() if type(s.Destroy) == "function" then s:Destroy() end end)
            end)
        else
            -- Fallback: destroy after a short delay
            safeDelay(8, function()
                pcall(function() if type(s.Destroy) == "function" then s:Destroy() end end)
            end)
        end
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
            pcall(function() child:Destroy() end)
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
            pcall(function() child:Destroy() end)
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
    safeSpawn(function()
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
        safeSpawn(function()
            setSpinnerVisible(true)
            local ok, err = pcall(function()
                if type(Remotes.RequestMarketSpawn.InvokeServer) == "function" then
                    Remotes.RequestMarketSpawn:InvokeServer()
                elseif type(Remotes.RequestMarketSpawn.FireServer) == "function" then
                    Remotes.RequestMarketSpawn:FireServer()
                end
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

    if Remotes.RollRequest and type(Remotes.RollRequest.FireServer) == "function" then
        safeFire(Remotes.RollRequest)
    elseif Remotes.RollRequest and type(Remotes.RollRequest.InvokeServer) == "function" then
        safeSpawn(function()
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
            pcall(function() togg.Active = v end)
        end
        if togg:FindFirstChild("Fill") then
            pcall(function() togg.Fill.Visible = v end)
        end
    end

    local function onClicked()
        local current = not (togg.Active == true)
        setValue(current)
        playSfx(UiSoundConfig.Toggle)

        if remoteSet and type(remoteSet.FireServer) == "function" then
            safeFire(remoteSet, current)
        elseif remoteSet and type(remoteSet.InvokeServer) == "function" then
            safeSpawn(function()
                safeInvoke(remoteSet, current)
            end)
        end
    end

    if remoteRequest then
        safeSpawn(function()
            local res = safeInvoke(remoteRequest)
            if res ~= nil then
                pcall(setValue, res)
            end
        end)
    end

    -- Connect input defensively
    if togg:IsA("GuiButton") and togg.Activated then
        pcall(function() togg.Activated:Connect(onClicked) end)
    else
        pcall(function()
            togg.InputBegan:Connect(function(input)
                if input.UserInputType and (input.UserInputType.Name == "MouseButton1" or input.UserInputType.Name == "Touch") then
                    onClicked()
                end
            end)
        end)
    end
end

local function wireRemotes()
    if Remotes.RollResult and type(Remotes.RollResult.OnClientEvent) == "RBXScriptSignal" or (Remotes.RollResult and Remotes.RollResult.OnClientEvent) then
        pcall(function() Remotes.RollResult.OnClientEvent:Connect(onRollResultReceived) end)
    end

    if Remotes.InventoryUpdated and Remotes.InventoryUpdated.OnClientEvent then
        pcall(function()
            Remotes.InventoryUpdated.OnClientEvent:Connect(function()
                pcall(refreshInventory)
            end)
        end)
    end

    if Remotes.ItemsUpdated and Remotes.ItemsUpdated.OnClientEvent then
        pcall(function()
            Remotes.ItemsUpdated.OnClientEvent:Connect(function()
                pcall(refreshInventory)
            end)
        end)
    end

    if Remotes.AutoRollState and Remotes.AutoRollState.OnClientEvent then
        pcall(function()
            Remotes.AutoRollState.OnClientEvent:Connect(function(v)
                local togg = state.elements[CONFIG.ToggleNames.AutoRoll]
                if togg and togg:IsA("GuiButton") then
                    pcall(function() togg.Active = v end)
                end
            end)
        end)
    end

    if Remotes.AutoSellStateChanged and Remotes.AutoSellStateChanged.OnClientEvent then
        pcall(function()
            Remotes.AutoSellStateChanged.OnClientEvent:Connect(function(v)
                local togg = state.elements[CONFIG.ToggleNames.AutoSell]
                if togg and togg:IsA("GuiButton") then
                    pcall(function() togg.Active = v end)
                end
            end)
        end)
    end

    if Remotes.SpinTraitResult and Remotes.SpinTraitResult.OnClientEvent then
        pcall(function()
            Remotes.SpinTraitResult.OnClientEvent:Connect(function(payload)
                print("SpinTraitResult", payload)
            end)
        end)
    end

    if Remotes.DungeonShopUpdated and Remotes.DungeonShopUpdated.OnClientEvent then
        pcall(function()
            Remotes.DungeonShopUpdated.OnClientEvent:Connect(function()
                print("Dungeon shop updated")
            end)
        end)
    end

    if Remotes.PerfTelemetry and Remotes.PerfTelemetry.OnClientEvent then
        pcall(function()
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
                        pcall(function()
                            pingLabel.Text = string.format("Ping: %dms", math.floor(ms))
                            local c = Color3.new(0, 1, 0)
                            if ms >= 200 then
                                c = Color3.new(1, 0, 0)
                            elseif ms >= 100 then
                                c = Color3.new(1, 0.8, 0)
                            end
                            pingLabel.TextColor3 = c
                        end)
                    end
                end
            end)
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
        if ai then pcall(function() ai.Visible = false end) end
    end
end

-- Connect user input events defensively
pcall(function() UserInputService.InputBegan:Connect(markInput) end)
pcall(function() UserInputService.InputChanged:Connect(markInput) end)
pcall(function() UserInputService.InputEnded:Connect(markInput) end)

-- AFK watcher
safeSpawn(function()
    while true do
        local now = tick()
        if now - state.lastInput >= AFK_THRESHOLD and not state.afk then
            state.afk = true
            local ai = state.elements[CONFIG.AfkIndicatorName]
            if ai then pcall(function() ai.Visible = true end) end

            if Remotes.AfkRejoinRequest and type(Remotes.AfkRejoinRequest.FireServer) == "function" then
                safeFire(Remotes.AfkRejoinRequest)
            elseif Remotes.AfkRejoinRequest and type(Remotes.AfkRejoinRequest.InvokeServer) == "function" then
                safeSpawn(function()
                    safeInvoke(Remotes.AfkRejoinRequest)
                end)
            end
        end
        safeWait(5)
    end
end)

-- Reconnect watcher
safeSpawn(function()
    while true do
        local chr = localPlayer.Character
        if not chr or not chr.Parent then
            safeWait(RECONNECT_WAIT)
            if not localPlayer.Character or not localPlayer.Character.Parent then
                if Remotes.RequestHubSpawn then
                    pcall(function() safeInvoke(Remotes.RequestHubSpawn) end)
                end
            end
        end
        safeWait(2)
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
    if rollBtn and rollBtn:IsA("GuiButton") and rollBtn.Activated then
        pcall(function() rollBtn.Activated:Connect(onRollPressed) end)
    end

    handleToggle(CONFIG.ToggleNames.AutoSell, Remotes.SetAutoSellUnderRequest or Remotes.ToggleAutoSellRarityRequest, Remotes.RequestAutoSellState)
    handleToggle(CONFIG.ToggleNames.AutoRoll, Remotes.AutoRollState or Remotes.AutoRollResume, Remotes.RequestMultiRollState)
    handleToggle(CONFIG.ToggleNames.AutoDungeon, Remotes.DungeonShopAutoBuy, nil)

    local marketBtn = state.gui:FindFirstChild("OpenMarketButton", true)
    if marketBtn and marketBtn:IsA("GuiButton") and marketBtn.Activated then
        pcall(function() marketBtn.Activated:Connect(openMarketPanel) end)
    end

    if state.elements[CONFIG.MusicSelectorName] then
        pcall(function() populateMusicSelector(state.elements[CONFIG.MusicSelectorName]) end)
    end

    pcall(refreshInventory)
    pcall(wireRemotes)

    if #MUSIC_LIBRARY > 0 then
        safeSpawn(function() playMusicByIndex(1) end)
    end
end

local function watchForGui()
    local pg = localPlayer:FindFirstChild("PlayerGui") or localPlayer:WaitForChild("PlayerGui")
    if not pg then return end
    if pg:FindFirstChild(CONFIG.GuiName, true) then
        pcall(setupUI)
        return
    end

    pcall(function()
        pg.DescendantAdded:Connect(function(desc)
            if not desc then return end
            if desc.Name == CONFIG.GuiName or desc.Name == CONFIG.RollButtonName then
                safeWait(0.05)
                pcall(setupUI)
            end
        end)
    end)
end

safeSpawn(function()
    pcall(watchForGui)
end)

-- End of file
