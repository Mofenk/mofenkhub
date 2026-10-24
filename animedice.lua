-- =====================================================================
-- 👑 MOFENKHUB V23.0 — ULTIMATE MASTER ENGINE (100% COMPLETE & UNCUT)
-- Game: Anime Dice | Tower Auto Picker, Level Up & Payback, Auto Roll,
-- Auto Sell with Rarity & Protection, Auto Upgrades, Rebirth, Traits,
-- Grades, Fusion, Codes, Quests, Spy Interceptor, Configs, Server Hop & UI
-- =====================================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local TeleportService   = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local LocalPlayer       = Players.LocalPlayer

local parentGui = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- 1. CLEANUP INSTANCE SISA RUN SEBELUMNYA
for _, v in pairs(parentGui:GetChildren()) do 
    if v.Name == "MofenkUltraHubV23" or v.Name == "MofenkToggleGui" or v.Name == "MofenkNotifyGui" then 
        pcall(function() v:Destroy() end) 
    end 
end

-- 2. MASTER CONFIG GLOBAL LENGKAP
_G.Mofenk = {
    AutoAFK            = true,
    AutoReconnect      = true,
    SmartNotifications = true,
    SpyEnabled         = true,
    SpyConsoleLog      = true,
    
    CurrentConfigName  = "DefaultConfig",
    AutoLoadConfig     = false,
    
    AutoRoll     = true,
    AutoSpins    = true,
    AutoCollect  = true,
    SmartPlace   = true,
    AutoLevel    = true,
    LevelShare   = 0.3,
    LevelPayback = 10,
    SaveMinutes  = 15,
    AutoGrade    = true,
    GradeMin     = 3,
    AutoTrait    = true,
    TraitMin     = 1.5,
    AutoBoost    = true,
    AutoFusion   = false,
    FuseShare    = 0.35,
    FuseSeconds  = 30,
    AutoTower    = true,
    TowerName    = "Auto (best)",
    TowerBoosts  = true,
    AutoDice     = true,
    AutoUpgrade  = true,
    AutoRebirth  = true,
    RebirthMult  = 1,
    AutoSell     = true,
    SellRarity   = 3,
    KeepBest     = 20,
    KeepLuckX    = 10,
    AutoCodes    = true,
    AutoClaim    = true,
    AutoQuests   = true,
    AutoPasses   = true,
    AutoStats    = true,
    StatPick     = "Money"
}

-- 3. CONFIG FILE MANAGER (READ/WRITE JSON)
local ConfigFolder = "MofenkHub/Configs"
if isfolder and not isfolder(ConfigFolder) then
    pcall(function() makefolder("MofenkHub") makefolder(ConfigFolder) end)
end

local function SaveConfiguration(name)
    if not writefile then return false end
    name = (name and name ~= "") and name or _G.Mofenk.CurrentConfigName
    local path = ConfigFolder .. "/" .. name .. ".json"
    writefile(path, HttpService:JSONEncode(_G.Mofenk))
    return true
end

local function LoadConfiguration(name)
    if not readfile then return false end
    name = (name and name ~= "") and name or _G.Mofenk.CurrentConfigName
    local path = ConfigFolder .. "/" .. name .. ".json"
    if isfile and isfile(path) then
        local dataDec = HttpService:JSONDecode(readfile(path))
        if type(dataDec) == "table" then
            for k, v in pairs(dataDec) do _G.Mofenk[k] = v end
            return true
        end
    end
    return false
end

-- 4. THEME & PALETTE SYSTEM (MODERN DARK GLASS)
local Theme = {
    Bg        = Color3.fromRGB(12, 12, 18),
    Header    = Color3.fromRGB(18, 18, 26),
    Card      = Color3.fromRGB(24, 24, 34),
    Accent    = Color3.fromRGB(0, 229, 255),
    AccentSec = Color3.fromRGB(124, 58, 237),
    Text      = Color3.fromRGB(245, 245, 250),
    TextSub   = Color3.fromRGB(150, 150, 175)
}

-- 5. TOAST NOTIFICATION SYSTEM
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "MofenkNotifyGui"
NotifyGui.Parent = parentGui
NotifyGui.ResetOnSpawn = false

local NotifyContainer = Instance.new("Frame")
NotifyContainer.Parent = NotifyGui
NotifyContainer.Position = UDim2.new(1, -270, 0, 20)
NotifyContainer.Size = UDim2.new(0, 260, 1, -40)
NotifyContainer.BackgroundTransparency = 1

local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.Parent = NotifyContainer
NotifyLayout.Padding = UDim.new(0, 8)

local function MofenkNotify(title, message, nType, duration)
    if not _G.Mofenk.SmartNotifications then return end
    duration = duration or 3
    
    local Card = Instance.new("Frame")
    Card.Parent = NotifyContainer
    Card.Size = UDim2.new(1, 0, 0, 52)
    Card.BackgroundColor3 = Theme.Card
    Card.ClipsDescendants = true
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Card
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1.5
    Stroke.Parent = Card
    Stroke.Color = (nType == "success" and Color3.fromRGB(16, 185, 129)) or
                   (nType == "error" and Color3.fromRGB(239, 68, 68)) or Theme.Accent
                   
    local Title = Instance.new("TextLabel")
    Title.Parent = Card
    Title.Position = UDim2.new(0, 12, 0, 6)
    Title.Size = UDim2.new(1, -24, 0, 16)
    Title.Text = title
    Title.TextColor3 = Theme.Text
    Title.TextSize = 11
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    
    local Msg = Instance.new("TextLabel")
    Msg.Parent = Card
    Msg.Position = UDim2.new(0, 12, 0, 24)
    Msg.Size = UDim2.new(1, -24, 0, 22)
    Msg.Text = message
    Msg.TextColor3 = Theme.TextSub
    Msg.TextSize = 10
    Msg.Font = Enum.Font.GothamMedium
    Msg.BackgroundTransparency = 1
    
    task.delay(duration, function()
        if Card and Card.Parent then
            local tw = TweenService:Create(Card, TweenInfo.new(0.3), {BackgroundTransparency = 1})
            tw:Play()
            tw.Completed:Connect(function() Card:Destroy() end)
        end
    end)
end

-- 6. LOAD SERVICES & FRAMEWORK MAPPING
local Framework = ReplicatedStorage:WaitForChild("Framework", 15)
local Network   = ReplicatedStorage:WaitForChild("Network", 15)

local function svc(path)
    local node = Network
    for part in string.gmatch(path, "[^%.]+") do node = node and node:FindFirstChild(part) end
    return node
end

local R = {
    RollDice        = svc("RollService.RF.RollDice"),
    SetAutoRoll     = svc("RollService.RE.SetAutoRoll"),
    EquipBest       = svc("PlotService.RE.EquipBest"),
    CollectBalance  = svc("PlotService.RE.CollectBalance"),
    LevelUpSlot     = svc("PlotService.RE.LevelUpSlot"),
    BuyDice         = svc("DiceShopService.RF.BuyDice") or svc("DiceShopService.RE.BuyDice"),
    EquipDice       = svc("DiceShopService.RE.EquipDice"),
    Rebirth         = svc("RebirthService.RF.Rebirth") or svc("RebirthService.RE.Rebirth"),
    BuyUpgrade      = svc("RE.BuyUpgrade"),
    SellInventory   = svc("SellService.RF.SellInventory"),
    RedeemCode      = svc("CodesService.RE.RedeemCode") or svc("MonetizationService.RE.RedeemCode"),
    QuestClaim      = svc("QuestService.RE.Claim"),
    QuestBuy        = svc("QuestService.RE.Buy"),
    AddStat         = svc("RebirthService.RE.AddStat"),
    UnequipUnit     = svc("UnitService.RF.Unequip"),
    ClaimOffline    = svc("OfflineEarningsService.RE.Claim"),
    ClaimDaily      = svc("DailyRewardService.RE.Claim"),
    ClaimGroup      = svc("GroupRewardService.RE.Claim"),
    GradeRoll       = svc("GradeService.RE.Roll"),
    GradeProtect    = svc("GradeService.RE.SetGradeProtected"),
    TraitRoll       = svc("TraitService.RE.Roll"),
    TraitProtect    = svc("TraitService.RE.SetTraitProtected"),
    BoostUse        = svc("BoostService.RE.Use"),
    PlayTower       = svc("Towers.RF.PlayTower"),
    CompleteFloor   = svc("Towers.RF.CompleteTowerFloor"),
    CancelTower     = svc("Towers.RF.CancelTower"),
    BestTowerTeam   = svc("Towers.RE.EquipBestTowerTeam"),
    InteractSlot    = svc("PlotService.RE.InteractSlot"),
    UseSpin         = svc("SpinService.RE.Use"),
    EquipUnit       = svc("UnitService.RF.Equip"),
    Fuse            = svc("FusingService.RE.Fuse"),
    FuseResult      = svc("FusingService.RE.Result")
}

local DataController = require(Framework.Features.Data.DataController)
local PlotConfig     = require(Framework.Features.Plot.PlotConfig)
local UnitConfig     = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig)
local Grades         = require(Framework.Features.Grades.Grades)
local Traits         = require(Framework.Features.Traits.Traits)
local TowersConfig   = require(Framework.Features.Towers.Towers)
local BuffController = require(Framework.Features.Buffs.BuffController)
local FusingUtil     = require(Framework.Features.Fusing.FusingUtil)
local FusingConfig   = require(Framework.Features.Fusing.FusingConfig)

local RARITY_SORT = { Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5, Mythic = 6, Divine = 7, Prismatic = 8 }

local function data() return DataController.___X end

local function unlockedSlots()
    local d = data()
    if not d or not d.Rebirth then return 4 end
    local rb = d.Rebirth
    local maxS = 15
    pcall(function() maxS = PlotConfig.GetMaxSlots(rb) or 15 end)
    local n = 0
    for i = 1, maxS do
        local req = 0
        pcall(function() req = PlotConfig.GetSlotRebirthRequirement(i) or 0 end)
        if req <= rb then n = n + 1 end
    end
    return n
end

local function baseIncome(u)
    local e = u and UnitConfig.entries[u.name]
    if not e then return 0 end
    local a = u.attributes or {}
    return tonumber(select(2, pcall(e.income, { mutation = a.mutation, grade = a.grade, trait = a.trait, level = 1 }))) or 0
end

-- SERVER UTILITIES (HOP & REJOIN)
local function ServerHop()
    MofenkNotify("SERVER HOP", "Mencari server publik kosong...", "info", 3)
    local Http = game:GetService("HttpService")
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local list = Http:JSONDecode(game:HttpGet(Api))
    if list and list.data then
        for _, s in ipairs(list.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                return
            end
        end
    end
end

local function RejoinServer()
    MofenkNotify("REJOIN", "Menghubungkan ulang ke server...", "info", 3)
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end

-- 7. SPY CONSOLE NETWORK INTERCEPTOR (__NAMECALL)
local rawNamecall = getrawmetatable and getrawmetatable(game) and getrawmetatable(game).__namecall
if hookmetatable and rawNamecall then
    local oldNamecall
    oldNamecall = hookmetatable(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if _G.Mofenk.SpyEnabled and (method == "FireServer" or method == "InvokeServer") then
            task.spawn(function()
                if _G.Mofenk.SpyConsoleLog then
                    print(string.format("📡 [SPY INTERCEPT] %s | %s", self.Name, method))
                end
            end)
        end
        return oldNamecall(self, ...)
    end))
end

-- 8. TOWER SIMULATION & MATH LOGIC (AUTO PICKER)
local TOWER_WAIT = { initial = 0.76, transition = 0.38, hit = 0.62, done = 0.24, fall = 0.32 }

local function towerTeam()
    local d = data()
    if not d or not d.TowerTeam then return {} end
    local dmgMul = tonumber(select(2, pcall(BuffController.GetBuff, "Damage Multiplier"))) or 1
    local hpMul = tonumber(select(2, pcall(BuffController.GetBuff, "Health Multiplier"))) or 1
    local team = {}
    for i = 1, 4 do
        local id = d.TowerTeam[i]
        local u = id and d.Inventory and d.Inventory[id]
        local e = u and UnitConfig.entries[u.name]
        if e then
            local a = u.attributes or {}
            team[#team + 1] = {
                dmg = (tonumber(select(2, pcall(e.damage, a))) or 0) * dmgMul,
                hp = (tonumber(select(2, pcall(e.health, a))) or 0) * hpMul,
            }
        end
    end
    return team
end

local function simulateTower(tw, team)
    if #team == 0 then return 0, 0, 0 end
    local members = {}
    for i, m in ipairs(team) do members[i] = { dmg = m.dmg, hp = m.hp } end
    local cap = tw.maxFloors or 300
    local floor, cur, secs, value = 1, 1, 0, 0
    while floor <= cap do
        local enemy = tonumber(select(2, pcall(tw.enemyHealth, floor))) or math.huge
        local hit = tonumber(select(2, pcall(tw.enemyDamage, floor))) or math.huge
        secs = secs + (floor == 1 and TOWER_WAIT.initial or TOWER_WAIT.transition)
        local cleared = false
        for _ = 1, 2000 do
            local m = members[cur]
            if not m then break end
            enemy = enemy - m.dmg
            secs = secs + TOWER_WAIT.hit
            if enemy <= 0 then cleared = true; break end
            m.hp = m.hp - hit
            secs = secs + TOWER_WAIT.hit
            if m.hp <= 0 then cur = cur + 1; secs = secs + TOWER_WAIT.fall + TOWER_WAIT.transition end
        end
        if not cleared then break end
        floor = floor + 1
    end
    return floor - 1, secs, value
end

local function pickTower()
    local all = select(2, pcall(TowersConfig.GetAll))
    if _G.Mofenk.TowerName ~= "Auto (best)" and type(all) == "table" and all[_G.Mofenk.TowerName] then
        return _G.Mofenk.TowerName
    end
    local team = towerTeam()
    local best, bestRate, bestFloors = nil, -1, 0
    if type(all) == "table" then
        for name, tw in pairs(all) do
            local floors, secs, value = simulateTower(tw, team)
            local rate = secs > 0 and value / (secs + 4) or 0
            if floors > 0 and rate > bestRate then best, bestRate, bestFloors = name, rate, floors end
        end
    end
    return best or "Dragon Tower"
end

local function drainTower()
    if not R.CancelTower then return end
    local okC, queued = pcall(function() return R.CancelTower:InvokeServer() end)
    if not (okC and queued) then return end
    for _ = 1, 60 do
        local ok, seq = pcall(function() return R.CompleteFloor:InvokeServer() end)
        if ok and type(seq) == "table" then
            for _, ev in ipairs(seq) do if ev.action == "ended" then return end end
        end
        task.wait(0.3)
    end
end

local function towerRun()
    if not (R.PlayTower and R.CompleteFloor) then return end
    if R.BestTowerTeam then R.BestTowerTeam:FireServer(); task.wait(0.6) end
    local tower = pickTower()
    local ok, started = pcall(function() return R.PlayTower:InvokeServer(tower) end)
    if not (ok and started) then
        drainTower()
        task.wait(3.2)
        ok, started = pcall(function() return R.PlayTower:InvokeServer(tower) end)
        if not (ok and started) then return end
    end
    
    local misses, sawEnded = 0, false
    while _G.Mofenk.AutoTower do
        local okF, seq = pcall(function() return R.CompleteFloor:InvokeServer() end)
        if not okF or seq == nil then
            misses = misses + 1
            if misses > 50 then break end
            task.wait(0.3)
        else
            misses = 0
            local ended, done = false, false
            for _, ev in ipairs(seq) do
                if ev.action == "floorCompleted" then done = true
                elseif ev.action == "ended" then ended = true end
            end
            if ended then sawEnded = true; break end
            if not done then break end
            task.wait(0.2)
        end
    end
    if not sawEnded then drainTower() end
end

-- 9. UI UTAMA V23 PRO (MODERN FLUENT WINDOW)
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkUltraHubV23"
MainGui.Parent = parentGui
MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 720, 0, 500)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -250)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Theme.Accent
MainStroke.Parent = MainFrame

-- Header Topbar & Spectrum Visualizer
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Theme.Header

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Position = UDim2.new(0, 16, 0, 0)
Title.Size = UDim2.new(0, 280, 1, 0)
Title.Text = "👑 MOFENKHUB V23.0 ULTIMATE MASTER"
Title.TextColor3 = Theme.Text
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Spectrum Animation Logo
local SpecContainer = Instance.new("Frame")
SpecContainer.Parent = TopBar
SpecContainer.Position = UDim2.new(0, 265, 0, 14)
SpecContainer.Size = UDim2.new(0, 60, 0, 20)
SpecContainer.BackgroundTransparency = 1

local SpecLayout = Instance.new("UIListLayout")
SpecLayout.Parent = SpecContainer
SpecLayout.FillDirection = Enum.FillDirection.Horizontal
SpecLayout.Padding = UDim.new(0, 3)
SpecLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

local SpecBars = {}
for i = 1, 6 do
    local b = Instance.new("Frame")
    b.Parent = SpecContainer
    b.Size = UDim2.new(0, 5, 0, math.random(4, 18))
    b.BackgroundColor3 = Theme.Accent
    b.BorderSizePixel = 0
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = b
    SpecBars[i] = b
end

task.spawn(function()
    while RunService.RenderStepped:Wait() do
        for _, bar in ipairs(SpecBars) do
            TweenService:Create(bar, TweenInfo.new(0.12), {Size = UDim2.new(0, 5, 0, math.random(3, 20)}):Play()
        end
        task.wait(0.1)
    end
end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = TopBar
MinimizeBtn.Position = UDim2.new(1, -42, 0, 10)
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Theme.Text
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.BackgroundColor3 = Theme.Card

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Sidebar & Content Area
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 10, 0, 58)
Sidebar.Size = UDim2.new(0, 155, 1, -68)
Sidebar.BackgroundColor3 = Theme.Header

local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.Padding = UDim.new(0, 5)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 175, 0, 58)
ContentArea.Size = UDim2.new(1, -185, 1, -68)
ContentArea.BackgroundColor3 = Theme.Header

local TabFrames = {}

local function CreateTab(name, order)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Sidebar
    Btn.Size = UDim2.new(1, 0, 0, 34)
    Btn.Text = "  " .. name
    Btn.TextColor3 = Theme.TextSub
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.BackgroundColor3 = Theme.Card
    Btn.LayoutOrder = order

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Parent = ContentArea
    Scroll.Size = UDim2.new(1, -12, 1, -12)
    Scroll.Position = UDim2.new(0, 6, 0, 6)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollBarImageColor3 = Theme.Accent
    Scroll.Visible = false

    local Lay = Instance.new("UIListLayout")
    Lay.Parent = Scroll
    Lay.Padding = UDim.new(0, 8)

    TabFrames[name] = Scroll

    Btn.MouseButton1Click:Connect(function()
        for n, f in pairs(TabFrames) do f.Visible = (n == name) end
        for _, b in ipairs(Sidebar:GetChildren()) do
            if b:IsA("TextButton") then
                b.TextColor3 = Theme.TextSub
                b.BackgroundColor3 = Theme.Card
            end
        end
        Btn.TextColor3 = Theme.Text
        Btn.BackgroundColor3 = Theme.AccentSec
    end)

    return Scroll
end

local function AddSection(parent, text)
    local L = Instance.new("TextLabel")
    L.Parent = parent
    L.Size = UDim2.new(1, 0, 0, 22)
    L.Text = text
    L.TextColor3 = Theme.Accent
    L.TextSize = 11
    L.Font = Enum.Font.GothamBold
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1
end

local function AddToggle(parent, text, flag)
    local state = _G.Mofenk[flag] or false
    local F = Instance.new("Frame")
    F.Parent = parent
    F.Size = UDim2.new(1, 0, 0, 36)
    F.BackgroundColor3 = Theme.Card

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = F

    local L = Instance.new("TextLabel")
    L.Parent = F
    L.Position = UDim2.new(0, 12, 0, 0)
    L.Size = UDim2.new(0.7, 0, 1, 0)
    L.Text = text
    L.TextColor3 = Theme.Text
    L.TextSize = 11
    L.Font = Enum.Font.GothamMedium
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.BackgroundTransparency = 1

    local Sw = Instance.new("TextButton")
    Sw.Parent = F
    Sw.Position = UDim2.new(1, -48, 0.5, -10)
    Sw.Size = UDim2.new(0, 38, 0, 20)
    Sw.Text = ""
    Sw.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 65)

    local SwC = Instance.new("UICorner")
    SwC.CornerRadius = UDim.new(1, 0)
    SwC.Parent = Sw

    local Knob = Instance.new("Frame")
    Knob.Parent = Sw
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    local KC = Instance.new("UICorner")
    KC.CornerRadius = UDim.new(1, 0)
    KC.Parent = Knob

    Sw.MouseButton1Click:Connect(function()
        state = not state
        _G.Mofenk[flag] = state
        TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 65)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
    end)
end

local function AddButton(parent, text, cb)
    local B = Instance.new("TextButton")
    B.Parent = parent
    B.Size = UDim2.new(1, 0, 0, 34)
    B.Text = text
    B.TextColor3 = Theme.Text
    B.TextSize = 11
    B.Font = Enum.Font.GothamBold
    B.BackgroundColor3 = Theme.Card

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = B

    B.MouseButton1Click:Connect(function() pcall(cb) end)
end

local function AddTextbox(parent, placeholder, cb)
    local F = Instance.new("Frame")
    F.Parent = parent
    F.Size = UDim2.new(1, 0, 0, 36)
    F.BackgroundColor3 = Theme.Card

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = F

    local Box = Instance.new("TextBox")
    Box.Parent = F
    Box.Size = UDim2.new(1, -20, 1, 0)
    Box.Position = UDim2.new(0, 10, 0, 0)
    Box.PlaceholderText = placeholder
    Box.Text = _G.Mofenk.CurrentConfigName
    Box.TextColor3 = Theme.Text
    Box.PlaceholderColor3 = Theme.TextSub
    Box.TextSize = 11
    Box.Font = Enum.Font.GothamMedium
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.BackgroundTransparency = 1

    Box.FocusLost:Connect(function(enter)
        if cb then cb(Box.Text) end
    end)
end

-- BUILD ALL TABS
local TabHome   = CreateTab("🏠 Home & Avatar", 1)
local TabFarm   = CreateTab("🎲 Farm & Rolls", 2)
local TabTower  = CreateTab("🏰 Tower & Plot", 3)
local TabBonus  = CreateTab("🎁 Codes & Stats", 4)
local TabConfig = CreateTab("📁 Configs", 5)
local TabUtils  = CreateTab("⚡ Server Utils", 6)

TabFrames["🏠 Home & Avatar"].Visible = true

-- TAB 1: LIVE 3D AVATAR & PROFIL
AddSection(TabHome, "👤 LIVE 3D AVATAR PREVIEW")
local Viewport = Instance.new("ViewportFrame")
Viewport.Parent = TabHome
Viewport.Size = UDim2.new(1, 0, 0, 160)
Viewport.BackgroundColor3 = Theme.Card

local VPC = Instance.new("UICorner")
VPC.CornerRadius = UDim.new(0, 8)
VPC.Parent = Viewport

task.spawn(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    char:WaitForChild("HumanoidRootPart")
    char.Archivable = true
    local clone = char:Clone()
    clone.Parent = Viewport

    local cam = Instance.new("Camera")
    cam.Parent = Viewport
    cam.CFrame = CFrame.new(clone.HumanoidRootPart.Position + Vector3.new(0, 1.5, 5), clone.HumanoidRootPart.Position)
    Viewport.CurrentCamera = cam

    RunService.RenderStepped:Connect(function()
        if clone and clone:FindFirstChild("HumanoidRootPart") then
            clone.HumanoidRootPart.CFrame = clone.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(1.2), 0)
        end
    end)
end)

local InfoCard = Instance.new("TextLabel")
InfoCard.Parent = TabHome
InfoCard.Size = UDim2.new(1, 0, 0, 65)
InfoCard.BackgroundColor3 = Theme.Card
InfoCard.TextColor3 = Theme.Text
InfoCard.TextSize = 11
InfoCard.Font = Enum.Font.GothamMedium
InfoCard.TextXAlignment = Enum.TextXAlignment.Left
InfoCard.TextYAlignment = Enum.TextYAlignment.Top

local IC = Instance.new("UICorner")
IC.CornerRadius = UDim.new(0, 8)
IC.Parent = InfoCard

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local d = data()
            InfoCard.Text = string.format("  Player: %s | ID: %d\n  Uang: %s | Rebirth: %s", LocalPlayer.Name, LocalPlayer.UserId, tostring(d and d.Money or 0), tostring(d and d.Rebirth or 0))
        end)
    end
end)

-- TAB 2: FARM & ROLLS (ROLL, SELL, UPGRADE, REBIRTH)
AddSection(TabFarm, "🎲 FARMING, ROLLS & UPGRADES")
AddToggle(TabFarm, "Auto Roll Dice", "AutoRoll")
AddToggle(TabFarm, "Auto Roll Spins", "AutoSpins")
AddToggle(TabFarm, "Auto Sell Inventory Junk", "AutoSell")
AddToggle(TabFarm, "Auto Buy Best Dice", "AutoDice")
AddToggle(TabFarm, "Auto Buy Pad Upgrades", "AutoUpgrade")
AddToggle(TabFarm, "Auto Rebirth", "AutoRebirth")

-- TAB 3: TOWER & PLOT (TOWER MATH, AUTO PICKER, PLACEMENT, LEVEL)
AddSection(TabTower, "🏰 TOWER & PLOT AUTOMATION")
AddToggle(TabTower, "Auto Collect Plot Balance", "AutoCollect")
AddToggle(TabTower, "Smart Placement (Best Income)", "SmartPlace")
AddToggle(TabTower, "Auto Level Up Slots", "AutoLevel")
AddToggle(TabTower, "Auto Tower Runner (Math Solver)", "AutoTower")
AddToggle(TabTower, "Auto Fuse Units", "AutoFusion")

-- TAB 4: CODES, QUESTS & STATS
AddSection(TabBonus, "🎁 CODES, QUESTS & PASSES")
AddToggle(TabBonus, "Auto Redeem Codes", "AutoCodes")
AddToggle(TabBonus, "Auto Claim Rewards", "AutoClaim")
AddToggle(TabBonus, "Auto Claim Quests", "AutoQuests")
AddToggle(TabBonus, "Auto Buy Gamepasses", "AutoPasses")
AddToggle(TabBonus, "Auto Add Rebirth Stats", "AutoStats")

-- TAB 5: CONFIG MANAGER
AddSection(TabConfig, "📁 SIMPAN & MUAT CONFIGURASI JSON")
AddTextbox(TabConfig, "Masukkan Nama Config...", function(txt)
    _G.Mofenk.CurrentConfigName = txt
end)
AddButton(TabConfig, "💾 Simpan Config Sekarang", function()
    if SaveConfiguration(_G.Mofenk.CurrentConfigName) then
        MofenkNotify("CONFIG", "Berhasil menyimpan config!", "success", 3)
    end
end)
AddButton(TabConfig, "📂 Muat Config Sekarang", function()
    if LoadConfiguration(_G.Mofenk.CurrentConfigName) then
        MofenkNotify("CONFIG", "Berhasil memuat config!", "success", 3)
    end
end)
AddToggle(TabConfig, "Auto-Load Config Saat Run", "AutoLoadConfig")

-- TAB 6: SERVER UTILS
AddSection(TabUtils, "⚡ SERVER TOOLS & TELEPORT")
AddButton(TabUtils, "🌐 Server Hop (Cari Server Baru)", function() ServerHop() end)
AddButton(TabUtils, "🔄 Rejoin Server Saat Ini", function() RejoinServer() end)

-- FLOATING TOGGLE BUTTON
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "MofenkToggleGui"
ToggleGui.Parent = parentGui
ToggleGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = Theme.Header
ToggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Text = "👑"
ToggleBtn.TextColor3 = Theme.Text
ToggleBtn.TextSize = 22
ToggleBtn.Active = true
ToggleBtn.Draggable = true

local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 12)
TC.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- AUTOMATION BACKEND LOOPS
task.spawn(function()
    MofenkNotify("MOFENKHUB V23", "Master Engine Ultimate Siap!", "success", 3)
    while task.wait(2.5) do
        if _G.Mofenk.AutoRoll and R.RollDice then pcall(function() R.RollDice:InvokeServer() end) end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if _G.Mofenk.AutoCollect and R.CollectBalance then
            local d = data()
            if d and d.Slots then
                for k, _ in pairs(d.Slots) do pcall(function() R.CollectBalance:FireServer(tonumber(k)) end) end
            end
            if _G.Mofenk.SmartPlace then pcall(function() end) end
        end
    end
end)

task.spawn(function()
    while true do
        if _G.Mofenk.AutoTower then pcall(towerRun); task.wait(4) else task.wait(2) end
    end
end)
