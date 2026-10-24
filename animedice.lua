-- =====================================================================
-- 👑 MOFENKHUB V16.0 — FULL UNCUT MASTER ENGINE (100% COMPLETE LOGIC)
-- Game: Anime Dice | 100% Uncut GitHub Engine + V14 UI Pro Systems
-- Ready for GitHub Repository & All Mobile/PC Executors
-- =====================================================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local TeleportService   = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local VirtualUser      = game:GetService("VirtualUser")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Stats             = game:GetService("Stats")
local LocalPlayer       = Players.LocalPlayer

local parentGui = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- 1. PEMBERSIHAN SISA UI RUN SEBELUMNYA
for _, v in pairs(parentGui:GetChildren()) do 
    if v.Name == "MofenkUltraHubV16" or v.Name == "MofenkToggleGui" or v.Name == "MofenkNotifyGui" then 
        pcall(function() v:Destroy() end) 
    end 
end

-- 2. KONFIGURASI GLOBAL MASTER (MATCHING GITHUB CONFIG)
_G.Mofenk = {
    AutoAFK            = true,
    AutoReconnect      = true,
    SmartNotifications = true,
    SpyEnabled         = true,
    ClickInspectEnabled= false,
    SpyConsoleLog      = true,
    SelectedRemoteForDebug = "SellInventory",
    CustomPayloadInput = "{}",
    
    -- Feature Toggles
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

-- 3. THEME SYSTEM
local Themes = {
    Cyan   = Color3.fromRGB(0, 208, 255),
    Purple = Color3.fromRGB(170, 0, 255),
    Red    = Color3.fromRGB(255, 60, 60),
    Green  = Color3.fromRGB(0, 230, 118),
    Gold   = Color3.fromRGB(255, 193, 7)
}
local CurrentTheme = Themes.Cyan
local ThemeStrokes = {}

local function UpdateThemeColor(newColor)
    CurrentTheme = newColor
    for _, stroke in ipairs(ThemeStrokes) do
        if stroke and stroke.Parent then stroke.Color = newColor end
    end
end

-- 4. SMART TOAST NOTIFICATION SYSTEM 🔔
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "MofenkNotifyGui"
NotifyGui.Parent = parentGui
NotifyGui.ResetOnSpawn = false

local NotifyContainer = Instance.new("Frame")
NotifyContainer.Name = "NotifyContainer"
NotifyContainer.Parent = NotifyGui
NotifyContainer.Position = UDim2.new(1, -260, 0, 20)
NotifyContainer.Size = UDim2.new(0, 250, 1, -40)
NotifyContainer.BackgroundTransparency = 1

local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.Parent = NotifyContainer
NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifyLayout.Padding = UDim.new(0, 8)

local function MofenkNotify(title, message, nType, duration)
    if not _G.Mofenk.SmartNotifications then return end
    duration = duration or 3.5
    
    local Card = Instance.new("Frame")
    Card.Parent = NotifyContainer
    Card.Size = UDim2.new(1, 0, 0, 52)
    Card.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    Card.BackgroundTransparency = 1
    Card.ClipsDescendants = true
    
    local CardCorner = Instance.new("UICorner")
    CardCorner.CornerRadius = UDim.new(0, 8)
    CardCorner.Parent = Card
    
    local CardStroke = Instance.new("UIStroke")
    CardStroke.Thickness = 1.5
    CardStroke.Transparency = 1
    CardStroke.Parent = Card
    
    if nType == "success" then CardStroke.Color = Color3.fromRGB(0, 230, 118)
    elseif nType == "error" then CardStroke.Color = Color3.fromRGB(255, 60, 60)
    elseif nType == "warn" or nType == "inspect" then CardStroke.Color = Color3.fromRGB(255, 193, 7)
    elseif nType == "spy" then CardStroke.Color = Color3.fromRGB(170, 0, 255)
    else CardStroke.Color = CurrentTheme end
    
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Parent = Card
    TitleLbl.Position = UDim2.new(0, 10, 0, 6)
    TitleLbl.Size = UDim2.new(1, -20, 0, 16)
    TitleLbl.Text = title
    TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLbl.TextSize = 11
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.TextTransparency = 1
    
    local MsgLbl = Instance.new("TextLabel")
    MsgLbl.Parent = Card
    MsgLbl.Position = UDim2.new(0, 10, 0, 24)
    MsgLbl.Size = UDim2.new(1, -20, 0, 22)
    MsgLbl.Text = message
    MsgLbl.TextColor3 = Color3.fromRGB(200, 200, 215)
    MsgLbl.TextSize = 10
    MsgLbl.Font = Enum.Font.GothamMedium
    MsgLbl.TextWrapped = true
    MsgLbl.BackgroundTransparency = 1
    MsgLbl.TextTransparency = 1
    
    TweenService:Create(Card, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(CardStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    TweenService:Create(TitleLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(MsgLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    
    task.delay(duration, function()
        if Card and Card.Parent then
            local fadeOut = TweenService:Create(Card, TweenInfo.new(0.3), {BackgroundTransparency = 1})
            TweenService:Create(CardStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            TweenService:Create(TitleLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(MsgLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            fadeOut:Play()
            fadeOut.Completed:Connect(function() Card:Destroy() end)
        end
    end)
end

-- 5. LOAD MODUL GAME & BACKEND ENGINE UTUH
local Framework = ReplicatedStorage:WaitForChild("Framework", 15)
local Network   = ReplicatedStorage:WaitForChild("Network", 15)

local function svc(path)
    local node = Network
    for part in string.gmatch(path, "[^%.]+") do
        node = node and node:FindFirstChild(part)
    end
    return node
end

local R = {
    RollDice        = svc("RollService.RF.RollDice"),
    SetAutoRoll     = svc("RollService.RE.SetAutoRoll"),
    EquipBest       = svc("PlotService.RE.EquipBest"),
    CollectBalance  = svc("PlotService.RE.CollectBalance"),
    LevelUpSlot     = svc("PlotService.RE.LevelUpSlot"),
    BuyDice         = svc("DiceShopService.RE.BuyDice"),
    EquipDice       = svc("DiceShopService.RE.EquipDice"),
    Rebirth         = svc("RebirthService.RE.Rebirth"),
    BuyUpgrade      = svc("RE.BuyUpgrade"),
    SellInventory   = svc("SellService.RF.SellInventory"),
    UpdateAutoSell  = svc("SellService.RE.UpdateAutoSell"),
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
local Dice           = require(Framework.Features.Rolling.Dice)
local Rebirths       = require(Framework.Features.Rebirth.Rebirths)
local PlotConfig     = require(Framework.Features.Plot.PlotConfig)
local MonetConfig    = require(Framework.Features.Monetization.MonetizationConfig)
local UpgradeConfig  = require(Framework.Features.Upgrades.Upgrades)
local UpgradeTree
pcall(function() UpgradeTree = require(Framework.Features.Upgrades.TreeStructure) end)
local UnitConfig     = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig)
local Grades         = require(Framework.Features.Grades.Grades)
local Traits         = require(Framework.Features.Traits.Traits)
local TowersConfig   = require(Framework.Features.Towers.Towers)
local BuffController = require(Framework.Features.Buffs.BuffController)
local FusingUtil     = require(Framework.Features.Fusing.FusingUtil)
local FusingConfig   = require(Framework.Features.Fusing.FusingConfig)

local UnitUtil
for _, m in ipairs(Framework:GetDescendants()) do
    if m.Name == "UnitUtil" and m:IsA("ModuleScript") then
        pcall(function() UnitUtil = require(m) end)
        break
    end
end
local BoostConfig
pcall(function() BoostConfig = require(Framework.Features.Inventory.Kinds.Boost.BoostConfig) end)
local BOOSTS = (BoostConfig and (BoostConfig.entries or BoostConfig)) or {}

local CODES, QuestConfig, RebirthStats, UnitCtl
pcall(function() CODES = require(Framework.Features.Codes.CodesConfig) end)
CODES = CODES or MonetConfig.Codes or {}
pcall(function() QuestConfig = require(Framework.Features.Quests.QuestConfig) end)
pcall(function() RebirthStats = require(Framework.Features.Rebirth.RebirthStatsConfig) end)
pcall(function() UnitCtl = require(Framework.Features.Inventory.Kinds.Unit.UnitController) end)

local RARITY_SORT = {}
do
    local ok, Rar = pcall(require, Framework.Other.Rarities)
    if ok and Rar and Rar.Refs then
        for _, ref in pairs(Rar.Refs) do
            local info = select(2, pcall(Rar.Get, ref))
            if type(info) == "table" and info.sortOrder then RARITY_SORT[ref] = info.sortOrder end
        end
    end
end

local function data() return DataController.___X end

local STATE = {
    money = 0, rolls = 0, rebirth = 0, dice = "-", nextDice = "-",
    slotsUsed = 0, slotsMax = 4, incomePerSec = 0, invCount = 0, invCap = 100, nextUpgrade = "-",
    rolled = 0, collected = 0, diceBought = 0, rebirths = 0, leveled = 0, swaps = 0,
    upgradesBought = 0, sold = 0, soldValue = 0, gradeRolls = 0, traitRolls = 0, boostsUsed = 0,
    luck = 0, towerRuns = 0, towerFloors = 0, towerBest = 0, towerFloor = 0, towerDrops = 0,
    fused = 0, fuseLast = "-", fuseBestChance = 0, towerPick = "-", towerPredict = 0, towerRate = 0,
    codesDone = 0, claims = 0, questsClaimed = 0, passesBought = 0, statsAdded = 0,
    phase = "idle", note = "-"
}

-- 6. MATEMATIKA UTAMA & KALKULASI INCOME (FULL UNCUT GITHUB LOGIC)
local function curIncome(u)
    local e = u and UnitConfig.entries[u.name]
    if not e then return 0 end
    return tonumber(select(2, pcall(e.income, u.attributes or {}))) or 0
end

local function baseIncome(u)
    local e = u and UnitConfig.entries[u.name]
    if not e then return 0 end
    local a = u.attributes or {}
    return tonumber(select(2, pcall(e.income, { mutation = a.mutation, grade = a.grade, trait = a.trait, level = 1 }))) or 0
end

-- DICE MODEL
local DICE = {}
do
    local ok, all = pcall(Dice.GetAll)
    if ok and type(all) == "table" then
        for key, def in pairs(all) do
            DICE[#DICE + 1] = { key = key, luck = tonumber(def.luck) or 0, price = tonumber(def.price) }
        end
        table.sort(DICE, function(a, b) return a.luck < b.luck end)
    end
end

local function ownedLuck()
    local d = data()
    local best, name = 0, "-"
    if d and d.OwnedDice then
        for _, die in ipairs(DICE) do
            if d.OwnedDice[die.key] and die.luck > best then best, name = die.luck, die.key end
        end
    end
    return best, name
end

local function rollLuck()
    local d = data()
    local buffLuck = tonumber(select(2, pcall(BuffController.GetBuff, "Luck"))) or 1
    local dieLuck = 1
    if d and d.Dice then
        for _, die in ipairs(DICE) do if die.key == d.Dice then dieLuck = die.luck end end
    end
    return buffLuck * dieLuck
end

local function bestAffordableDice(reserve)
    local d = data()
    if not d or not d.Money then return nil end
    local pick = nil
    local spendable = d.Money - (reserve or 0)
    for _, die in ipairs(DICE) do
        if die.price and not d.OwnedDice[die.key] and spendable >= die.price then
            if not pick or die.luck > pick.luck then pick = die end
        end
    end
    return pick
end

-- UPGRADE MODEL
local ROMAN = { I=1, V=5, X=10 }
local function romanToInt(s)
    local total, prev = 0, 0
    for i = #s, 1, -1 do
        local v = ROMAN[s:sub(i, i)] or 0
        if v < prev then total = total - v else total = total + v end
        prev = v
    end
    return total
end

local UPGRADE_LINES = {}
do
    for name, def in pairs(UpgradeConfig) do
        local cat, roman = name:match("^(.-)%s+([IVX]+)$")
        if cat and roman and def.price then
            UPGRADE_LINES[cat] = UPGRADE_LINES[cat] or {}
            local storage = 0
            if def.buffs and def.buffs["Unit Storage"] then
                storage = tonumber(def.buffs["Unit Storage"].amount) or 0
            end
            table.insert(UPGRADE_LINES[cat], {
                name = name, tier = romanToInt(roman),
                price = tonumber(def.price) or math.huge, storage = storage,
            })
        end
    end
    for _, list in pairs(UPGRADE_LINES) do table.sort(list, function(a, b) return a.tier < b.tier end) end
end

local function nextTier(cat)
    local d = data()
    if not d or not d.Upgrades then return nil end
    local owned = d.Upgrades
    for _, up in ipairs(UPGRADE_LINES[cat] or {}) do
        if not owned[up.name] then
            local parent = UpgradeTree and select(2, pcall(UpgradeTree.GetParent, up.name))
            if type(parent) == "string" and parent ~= "Start" and not owned[parent] then return nil end
            return up
        end
    end
    return nil
end

local UPGRADE_CATS = { "Money", "Luck", "Fortune", "Roll Speed", "Unit Storage", "Sell" }
local TOWER_CATS   = { "Damage", "Health" }

local function bestUpgrade(reserve)
    local d = data()
    if not d or not d.Money then return nil end
    local pick = nil
    local spendable = d.Money - (reserve or 0)
    local cats = UPGRADE_CATS
    if _G.Mofenk.AutoTower then
        cats = {}
        for _, c in ipairs(UPGRADE_CATS) do cats[#cats + 1] = c end
        for _, c in ipairs(TOWER_CATS) do cats[#cats + 1] = c end
    end
    for _, cat in ipairs(cats) do
        local up = nextTier(cat)
        if up and spendable >= up.price then
            if not pick or up.price < pick.price then pick = up end
        end
    end
    return pick
end

local function invCap()
    local buff = tonumber(select(2, pcall(BuffController.GetBuff, "Unit Storage")))
    if buff and buff > 0 then return buff end
    local cap = 100
    local d = data()
    if d and d.Upgrades then
        for _, up in ipairs(UPGRADE_LINES["Unit Storage"] or {}) do
            if d.Upgrades[up.name] then cap = cap + up.storage end
        end
    end
    return cap
end

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

local function nextRebirthCost()
    local d = data()
    if not d or not d.Rebirth then return nil end
    local info
    pcall(function() info = Rebirths.Get(d.Rebirth + 1) end)
    if not info then pcall(function() info = Rebirths.GetNext(d.Rebirth) end) end
    return info and tonumber(info.cost), info and tonumber(info.moneyMultiplier)
end

-- PROTEKSI UNIT
local function goodGrade(g)
    local def = g and Grades[g]
    return def and (tonumber(def.incomeMultiplier) or 0) >= _G.Mofenk.GradeMin
end

local function goodTrait(t)
    local def = t and Traits[t]
    return def and (tonumber(def.incomeMultiplier) or 0) >= _G.Mofenk.TraitMin
end

local function heldUnit()
    if not (UnitCtl and UnitCtl.EquippedUnit) then return nil end
    local ok, id = pcall(UnitCtl.EquippedUnit)
    return ok and id or nil
end

local function isProtected(id, u)
    local a = u.attributes or {}
    if a.locked then return true end
    local e = UnitConfig.entries[u.name]
    if not e or e.limited then return true end
    if goodGrade(a.grade) or goodTrait(a.trait) then return true end
    return id == heldUnit()
end

local unitOwner, unitSince = nil, 0
local function claimUnits(who)
    if unitOwner and unitOwner ~= who and os.clock() - unitSince < 20 then return false end
    unitOwner, unitSince = who, os.clock()
    return true
end
local function releaseUnits(who) if unitOwner == who then unitOwner = nil end end

-- 7. ROLLING & SPIN ACTIONS
local SPINS = { "Jackpot Spin", "Lucky Spin" }
local function armSpin()
    if not (_G.Mofenk.AutoSpins and R.UseSpin) then return end
    local d = data()
    if not d then return end
    for _, name in ipairs(SPINS) do
        if d.ActiveEntries and d.ActiveEntries[name] then return end
    end
    for _, name in ipairs(SPINS) do
        local item = d.Inventory and d.Inventory[name]
        if item and (tonumber(item.amount) or 0) >= 1 then
            R.UseSpin:FireServer(name)
            STATE.note = "armed " .. name
            task.wait(0.25)
            return
        end
    end
end

local function doRoll()
    if not R.RollDice then return end
    pcall(armSpin)
    local ok = pcall(function() return R.RollDice:InvokeServer() end)
    if ok then STATE.rolled = STATE.rolled + 1 end
end

local function rollInterval()
    local dur = tonumber(select(2, pcall(BuffController.GetBuff, "Roll Duration"))) or 2.5
    return math.max(0.3, dur + 0.05)
end

-- 8. SMART PLACEMENT BY POTENTIAL BASE INCOME
local function placeBest()
    if not (R.EquipUnit and R.InteractSlot) then return false end
    if not claimUnits("place") then return false end
    local d = data()
    if not d or not d.Inventory or not d.Slots then releaseUnits("place"); return false end
    local n = unlockedSlots()

    local ranked = {}
    for id, u in pairs(d.Inventory) do
        if UnitConfig.entries[u.name] and (tonumber(u.amount) or 1) >= 1 then
            ranked[#ranked + 1] = { id = id, v = baseIncome(u) }
        end
    end
    table.sort(ranked, function(a, b) return a.v > b.v end)

    local want, bench = {}, {}
    for i = 1, math.min(n, #ranked) do want[ranked[i].id] = ranked[i].v end
    local placed = {}
    for i = 1, n do
        local s = d.Slots[tostring(i)]
        if s and s.unitId then placed[s.unitId] = true end
    end
    for i = 1, math.min(n, #ranked) do
        if not placed[ranked[i].id] then bench[#bench + 1] = ranked[i] end
    end
    if #bench == 0 then releaseUnits("place"); return false end

    local slots = {}
    for i = 1, n do
        local s = d.Slots[tostring(i)]
        local u = s and s.unitId and d.Inventory[s.unitId]
        slots[#slots + 1] = { i = i, v = u and baseIncome(u) or 0, id = s and s.unitId }
    end
    table.sort(slots, function(a, b) return a.v < b.v end)

    local swapped = 0
    for k, cand in ipairs(bench) do
        local slot = slots[k]
        if slot and (slot.id == nil or not want[slot.id]) and cand.v > slot.v * 1.1 then
            local ok, equipped = pcall(function() return R.EquipUnit:InvokeServer(cand.id) end)
            if ok and equipped == true then
                task.wait(0.55)
                R.InteractSlot:FireServer(slot.i)
                task.wait(0.6)
                local now = d.Slots[tostring(slot.i)]
                if now and now.unitId == cand.id then
                    swapped = swapped + 1
                    local u = d.Inventory[cand.id]
                    STATE.note = "placed " .. tostring(u and u.name)
                elseif R.UnequipUnit and heldUnit() then
                    pcall(function() R.UnequipUnit:InvokeServer() end)
                end
            end
            task.wait(0.55)
        end
    end
    releaseUnits("place")
    STATE.swaps = STATE.swaps + swapped
    return swapped > 0
end

local function doCollectPlace()
    local d = data()
    if not d then return end
    local banked = 0
    if R.CollectBalance and d.Slots then
        for key, slot in pairs(d.Slots) do
            banked = banked + (tonumber(slot.balance) or 0)
            pcall(function() R.CollectBalance:FireServer(tonumber(key)) end)
        end
    end
    STATE.collected = STATE.collected + banked
    if _G.Mofenk.SmartPlace then
        pcall(placeBest)
    elseif R.EquipBest then
        R.EquipBest:FireServer()
    end
end

-- 9. SHOP & UPGRADES
local function doDice(reserve)
    local pick = bestAffordableDice(reserve)
    if pick then
        local curLuck = ownedLuck()
        if pick.luck > curLuck then
            R.BuyDice:FireServer(pick.key)
            STATE.diceBought = STATE.diceBought + 1
            STATE.note = "bought " .. pick.key .. " dice"
            task.wait(0.2)
        end
    end
    local _, bestName = ownedLuck()
    if bestName ~= "-" and data().Dice ~= bestName then
        R.EquipDice:FireServer(bestName)
    end
end

local function doUpgrade(reserve)
    if not R.BuyUpgrade then return end
    local d = data()
    if not d or not d.Upgrades then return end
    if UpgradeConfig.Start and not d.Upgrades.Start then
        R.BuyUpgrade:FireServer("Start")
        task.wait(0.15)
    end
    local up = bestUpgrade(reserve)
    if up then
        R.BuyUpgrade:FireServer(up.name)
        STATE.upgradesBought = STATE.upgradesBought + 1
        STATE.note = "upgrade " .. up.name
        task.wait(0.15)
    end
end

-- 10. AUTO SELL ENGINE (FULL UNCUT UNCAPPED JUNK CLEANER)
local function performFullAutoSell(force)
    if not R.SellInventory or not claimUnits("sell") then return end
    local d = data()
    if not d or not d.Inventory then releaseUnits("sell"); return end
    
    local cap = invCap()
    local placed = {}
    if d.Slots then for _, slot in pairs(d.Slots) do if slot.unitId then placed[slot.unitId] = true end end end
    if d.TowerTeam then for _, id in pairs(d.TowerTeam) do placed[id] = true end end
    
    local luckLine = _G.Mofenk.KeepLuckX > 0 and rollLuck() * _G.Mofenk.KeepLuckX or nil
    local units, owned = {}, 0
    
    for id, u in pairs(d.Inventory) do
        local e = UnitConfig.entries[u.name]
        if e then owned = owned + 1 end
        local chance = e and not e.limited and tonumber(select(2, pcall(e.chance, { mutation = u.attributes and u.attributes.mutation })))
        local lucky = luckLine and (chance or math.huge) >= luckLine
        if e and not placed[id] and not isProtected(id, u) and not lucky then
            units[#units + 1] = {
                id = id, inc = baseIncome(u), order = RARITY_SORT[e.rarity] or 0,
                mutated = u.attributes and u.attributes.mutation ~= nil,
            }
        end
    end
    table.sort(units, function(a, b) return a.inc < b.inc end)
    local pressured = force or owned >= cap - 3
    local sellable = math.max(0, #units - _G.Mofenk.KeepBest)
    local list = {}
    
    for i, unit in ipairs(units) do
        local belowFloor = not unit.mutated and unit.order > 0 and unit.order < _G.Mofenk.SellRarity and i <= sellable
        local surplus = pressured and i <= sellable
        if belowFloor or surplus then
            list[#list + 1] = unit.id
            if #list >= 300 then break end
        end
    end
    
    if #list == 0 then releaseUnits("sell"); return end
    local ok, value, sold = pcall(function() return R.SellInventory:InvokeServer(list) end)
    releaseUnits("sell")
    if ok then
        STATE.sold = STATE.sold + (tonumber(sold) or #list)
        STATE.soldValue = STATE.soldValue + (tonumber(value) or 0)
        MofenkNotify("AUTO SELL OK", string.format("Terjual %d Unit!", tonumber(sold) or #list), "success", 3)
    end
end

-- 11. REROLLS & BOOSTS
local function itemAmount(key)
    local d = data()
    local e = d and d.Inventory and d.Inventory[key]
    return (e and tonumber(e.amount)) or 0
end

local function placedUnits()
    local d = data()
    local list = {}
    if d and d.Slots then
        for _, slot in pairs(d.Slots) do
            local u = slot.unitId and d.Inventory and d.Inventory[slot.unitId]
            if u then list[#list + 1] = { id = slot.unitId, u = u, inc = baseIncome(u) } end
        end
    end
    table.sort(list, function(a, b) return a.inc > b.inc end)
    return list
end

local function syncProtectionFlags()
    local d = data()
    if not d or not d.ProtectedGrades or not d.ProtectedTraits then return end
    for name, g in pairs(Grades) do
        if type(g) == "table" then
            local want = (tonumber(g.incomeMultiplier) or 0) >= _G.Mofenk.GradeMin
            if R.GradeProtect and (d.ProtectedGrades[name] and true or false) ~= want then
                R.GradeProtect:FireServer(name, want)
            end
        end
    end
    for name, t in pairs(Traits) do
        if type(t) == "table" then
            local want = (tonumber(t.incomeMultiplier) or 0) >= _G.Mofenk.TraitMin
            if R.TraitProtect and (d.ProtectedTraits[name] and true or false) ~= want then
                R.TraitProtect:FireServer(name, want)
            end
        end
    end
end

local function doRerolls()
    syncProtectionFlags()
    local rolls = 0
    for _, p in ipairs(placedUnits()) do
        if rolls >= 8 then break end
        local attrs = p.u.attributes or {}
        if _G.Mofenk.AutoGrade and R.GradeRoll and not goodGrade(attrs.grade) and itemAmount("Gems") >= 1 then
            R.GradeRoll:FireServer(p.id)
            STATE.gradeRolls = STATE.gradeRolls + 1
            rolls = rolls + 1
            task.wait(0.25)
        end
        if _G.Mofenk.AutoTrait and R.TraitRoll and not goodTrait(attrs.trait) and itemAmount("Trait Reroll") >= 1 then
            R.TraitRoll:FireServer(p.id)
            STATE.traitRolls = STATE.traitRolls + 1
            rolls = rolls + 1
            task.wait(0.25)
        end
    end
end

local boostUntil = {}
local function useBoosts()
    if not R.BoostUse then return end
    local d = data()
    if not d or not d.Inventory then return end
    for key, item in pairs(d.Inventory) do
        local def = type(key) == "string" and BOOSTS[key]
        if def and type(def) == "table" and def.buffs and (tonumber(item.amount) or 0) >= 1 then
            local b = def.buffs
            if b.Luck or b["Money Multiplier"] or b["Roll Duration"] then
                local cat = def.category or key
                if (boostUntil[cat] or 0) < os.clock() then
                    R.BoostUse:FireServer(key)
                    boostUntil[cat] = os.clock() + (tonumber(def.duration) or 120) + 1
                    STATE.boostsUsed = STATE.boostsUsed + 1
                    STATE.note = "boost " .. key
                    task.wait(0.3)
                end
            end
        end
    end
end

-- 12. SIMULASI TOWER ENGINE UTUH
local TOWER_WAIT = { initial = 0.76, transition = 0.38, hit = 0.62, done = 0.24, fall = 0.32 }
local DROP_WEIGHT = { Luck = 1, ["Money Multiplier"] = 0.5, ["Damage Multiplier"] = 0.15 }

local function dropValue(name)
    if name == "Gems" then return 40 end
    if name == "Trait Reroll" then return 25 end
    local def = BOOSTS[name]
    if type(def) ~= "table" or type(def.buffs) ~= "table" then return 0 end
    local v = 0
    for buff, b in pairs(def.buffs) do
        local w = DROP_WEIGHT[buff] or 0
        v = v + w * math.max(0, (tonumber(b.amount) or 1) - 1) * (tonumber(def.duration) or 0)
    end
    return v
end

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
            if m.hp <= 0 then
                cur = cur + 1
                secs = secs + TOWER_WAIT.fall + TOWER_WAIT.transition
            end
        end
        if not cleared then break end
        secs = secs + TOWER_WAIT.done
        for _, tier in ipairs(tw.drops or {}) do
            if (tier.minFloor or 1) <= floor then
                for _, en in ipairs(tier.entries or {}) do
                    value = value + (tonumber(en.chance) or 0) / 100 * (tonumber(en.amount) or 1) * dropValue(en.name)
                end
            end
        end
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
    STATE.towerPick = best or "Dragon Tower"
    STATE.towerPredict = bestFloors
    STATE.towerRate = bestRate
    return STATE.towerPick
end

local function useTowerBoosts()
    if not (_G.Mofenk.TowerBoosts and R.BoostUse) then return end
    local d = data()
    if not d or not d.Inventory then return end
    for key, item in pairs(d.Inventory) do
        local def = type(key) == "string" and BOOSTS[key]
        if type(def) == "table" and type(def.buffs) == "table" and def.buffs["Damage Multiplier"] and (tonumber(item.amount) or 0) >= 1 then
            local cat = def.category or key
            if (boostUntil[cat] or 0) < os.clock() then
                R.BoostUse:FireServer(key)
                boostUntil[cat] = os.clock() + (tonumber(def.duration) or 120) + 1
                STATE.boostsUsed = STATE.boostsUsed + 1
                task.wait(0.3)
            end
        end
    end
end

local function drainTower()
    if not R.CancelTower then return end
    local okC, queued = pcall(function() return R.CancelTower:InvokeServer() end)
    if not (okC and queued) then return end
    for _ = 1, 60 do
        local ok, seq = pcall(function() return R.CompleteFloor:InvokeServer() end)
        if ok and type(seq) == "table" then
            for _, ev in ipairs(seq) do
                if ev.action == "ended" then return end
            end
        end
        task.wait(0.3)
    end
end

local function towerRun()
    if not (R.PlayTower and R.CompleteFloor) then return end
    if R.BestTowerTeam then R.BestTowerTeam:FireServer(); task.wait(0.6) end
    useTowerBoosts()
    task.wait(0.4)
    local tower = pickTower()
    local ok, started = pcall(function() return R.PlayTower:InvokeServer(tower) end)
    if not (ok and started) then
        drainTower()
        task.wait(3.2)
        ok, started = pcall(function() return R.PlayTower:InvokeServer(tower) end)
        if not (ok and started) then STATE.note = "tower refused"; return end
    end
    STATE.towerRuns = STATE.towerRuns + 1
    STATE.towerFloor = 0
    local misses, sawEnded = 0, false
    while _G.Mofenk.AutoTower do
        local okF, seq = pcall(function() return R.CompleteFloor:InvokeServer() end)
        if not okF or seq == nil or (type(seq) == "table" and #seq == 0) then
            misses = misses + 1
            if misses > 50 then break end
            task.wait(0.3)
        else
            misses = 0
            local ended, done = false, false
            for _, ev in ipairs(seq) do
                if ev.action == "floorCompleted" then
                    done = true
                    STATE.towerFloor = tonumber(ev.floor) or (STATE.towerFloor + 1)
                    if type(ev.rewards) == "table" then STATE.towerDrops = STATE.towerDrops + #ev.rewards end
                elseif ev.action == "ended" then
                    ended = true
                    if type(ev.rewards) == "table" then STATE.towerDrops = STATE.towerDrops + #ev.rewards end
                end
            end
            if done then STATE.towerFloors = STATE.towerFloors + 1 end
            if STATE.towerFloor > STATE.towerBest then STATE.towerBest = STATE.towerFloor end
            if ended then sawEnded = true; break end
            if not done then break end
            task.wait(0.2)
        end
    end
    if not sawEnded then drainTower() end
    STATE.note = "tower ended at floor " .. tostring(STATE.towerFloor)
end

-- 13. FUSE MACHINE LOGIC
local fuseResult
if R.FuseResult then
    R.FuseResult.OnClientEvent:Connect(function(unit, err, newId)
        fuseResult = { unit = unit, err = err, newId = newId }
    end)
end
local badTrio = {}
local fuseNext = 0

local function fuseOnce()
    local d = data()
    if not d or not d.Inventory or not d.Slots then return false end
    local busy = {}
    for _, slot in pairs(d.Slots) do if slot.unitId then busy[slot.unitId] = true end end
    if d.TowerTeam then for _, id in pairs(d.TowerTeam) do busy[id] = true end end
    
    local ranked = {}
    for id, u in pairs(d.Inventory) do
        if UnitConfig.entries[u.name] then ranked[#ranked + 1] = { id = id, v = baseIncome(u) } end
    end
    table.sort(ranked, function(a, b) return a.v > b.v end)
    for i = 1, math.min(#ranked, unlockedSlots() + 2) do busy[ranked[i].id] = true end

    local pile = {}
    for id, u in pairs(d.Inventory) do
        if not busy[id] and UnitConfig.entries[u.name] and not isProtected(id, u) then
            local ch = select(2, pcall(FusingUtil.GetChance, u))
            if type(ch) == "number" then pile[#pile + 1] = { id = id, ch = ch } end
        end
    end
    table.sort(pile, function(a, b) return a.ch > b.ch end)

    local budget = math.min(d.Money * math.clamp(_G.Mofenk.FuseShare, 0, 1), math.max(STATE.incomePerSec, 0) * _G.Mofenk.FuseSeconds)
    for i = 1, #pile - 2 do
        local a, b, c = pile[i], pile[i + 1], pile[i + 2]
        local sum = a.ch + b.ch + c.ch
        local key = a.id .. b.id .. c.id
        local okP, pools = pcall(FusingUtil.BuildPools, sum)
        if okP and not pools then badTrio[key] = true end
        if not badTrio[key] and sum * FusingConfig.AverageMultiplier >= a.ch then
            local cost = FusingConfig.GetCost(sum)
            if cost <= budget and cost <= d.Money then
                fuseResult = nil
                fuseNext = os.clock() + 15
                R.Fuse:FireServer(a.id, b.id, c.id)
                for _ = 1, 25 do if fuseResult then break end task.wait(0.2) end
                local r = fuseResult
                if r and r.unit then
                    STATE.fused = STATE.fused + 1
                    local ch = r.newId and d.Inventory[r.newId] and select(2, pcall(FusingUtil.GetChance, d.Inventory[r.newId]))
                    if type(ch) == "number" and ch > STATE.fuseBestChance then STATE.fuseBestChance = ch end
                    STATE.fuseLast = tostring(r.unit.name)
                    STATE.note = "fused -> " .. STATE.fuseLast
                    return true
                end
                return false
            end
        end
    end
    return false
end

local function doFuse()
    if not R.Fuse or os.clock() < fuseNext then return false end
    if not claimUnits("fuse") then return false end
    local ok, did = pcall(fuseOnce)
    releaseUnits("fuse")
    return ok and did or false
end

-- 14. REBIRTH & SLOT LEVELING
local function doRebirth()
    local cost = nextRebirthCost()
    if not cost then return false end
    if data().Money >= cost * math.max(1, _G.Mofenk.RebirthMult) then
        R.Rebirth:FireServer()
        STATE.rebirths = STATE.rebirths + 1
        STATE.note = "rebirth -> " .. tostring(data().Rebirth)
        task.wait(0.5)
        return true
    end
    return false
end

local function levelPayback(u)
    if not (UnitUtil and UnitUtil.GetLevelPrice) then return math.huge end
    local price = tonumber(select(2, pcall(UnitUtil.GetLevelPrice, u.name, u.attributes or {})))
    local mult = tonumber(select(2, pcall(BuffController.GetBuff, "Money Multiplier"))) or 1
    local gain = 0.25 * baseIncome(u) * mult
    if not price or gain <= 0 then return math.huge end
    return price / gain
end

local function doLevel()
    local d = data()
    if not d or not d.Slots then return false end
    local lowestKey, lowestLvl
    for key, slot in pairs(d.Slots) do
        if slot.unitId and d.Inventory and d.Inventory[slot.unitId] then
            local pb = levelPayback(d.Inventory[slot.unitId])
            if not lowestLvl or pb < lowestLvl then lowestLvl, lowestKey = pb, key end
        end
    end
    if not lowestKey or lowestLvl > _G.Mofenk.LevelPayback * 60 then return false end
    local before = d.Money
    R.LevelUpSlot:FireServer(tonumber(lowestKey))
    task.wait(0.12)
    if d.Money < before then
        STATE.leveled = STATE.leveled + 1
        return true
    end
    return false
end

local function nextLuckGoal()
    local d = data()
    if not d then return nil end
    local curLuck = 0
    if d.OwnedDice then
        for _, die in ipairs(DICE) do
            if d.OwnedDice[die.key] and die.luck > curLuck then curLuck = die.luck end
        end
    end
    local goal
    for _, die in ipairs(DICE) do
        if die.price and not (d.OwnedDice and d.OwnedDice[die.key]) and die.luck > curLuck then
            if not goal or die.price < goal then goal = die.price end
        end
    end
    if _G.Mofenk.AutoRebirth then
        local cost = nextRebirthCost()
        if cost then
            local rb = cost * math.max(1, _G.Mofenk.RebirthMult)
            if not goal or rb < goal then goal = rb end
        end
    end
    return goal
end

local function savingForLuck()
    local goal = nextLuckGoal()
    local money = data() and data().Money or 0
    return goal and money < goal and money + STATE.incomePerSec * _G.Mofenk.SaveMinutes * 60 >= goal
end

local function levelSlots()
    if savingForLuck() then STATE.phase = "saving for luck"; return end
    local floor = data().Money * (1 - math.clamp(_G.Mofenk.LevelShare, 0, 1))
    for _ = 1, 15 do
        if data().Money <= floor then break end
        if not doLevel() then break end
    end
end

-- 15. REWARDS, QUESTS, CODES, PASSES & STATS
local function doCodes()
    if not R.RedeemCode then return end
    local d = data()
    if not d or not d.RedeemedCodes then return end
    local did = 0
    for code in pairs(CODES) do
        if type(code) == "string" and not d.RedeemedCodes[code] then
            R.RedeemCode:FireServer(code)
            did = did + 1
            task.wait(0.6)
        end
    end
    if did > 0 then STATE.codesDone = STATE.codesDone + did end
end

local function doQuests()
    if not (QuestConfig and QuestConfig.Periods and R.QuestClaim) then return end
    local d = data()
    if not d or not d.Quests then return end
    for period, def in pairs(QuestConfig.Periods) do
        local q = d.Quests[period]
        if type(q) == "table" and type(q.progress) == "table" then
            for _, quest in ipairs(def.quests or {}) do
                local claimed = q.claimed and q.claimed[quest.id]
                if not claimed and (tonumber(q.progress[quest.id]) or 0) >= (tonumber(quest.target) or math.huge) then
                    R.QuestClaim:FireServer(period, quest.id, q.expiresAt)
                    STATE.questsClaimed = STATE.questsClaimed + 1
                    task.wait(0.3)
                end
            end
        end
    end
end

local PASS_ORDER = { "More Cash", "Luck", "Roll Speed", "Ultra Luck", "More Grades", "More Traits" }
local function doPasses()
    if not (QuestConfig and QuestConfig.Shop and R.QuestBuy) then return end
    local d = data()
    local tickets = itemAmount("Tickets")
    local price = {}
    for _, item in ipairs(QuestConfig.Shop) do
        if item.gamepass then price[item.name] = tonumber(item.tickets) end
    end
    for _, name in ipairs(PASS_ORDER) do
        if price[name] and not (d and d.OwnedGamepasses and d.OwnedGamepasses[name]) then
            if tickets >= price[name] then
                R.QuestBuy:FireServer(name)
                STATE.passesBought = STATE.passesBought + 1
            end
            return
        end
    end
end

local function doStats()
    if not (RebirthStats and RebirthStats.Get and R.AddStat) then return end
    local d = data()
    if not d or not d.Rebirth then return end
    local left = tonumber(select(2, pcall(RebirthStats.GetRemaining, d.Rebirth, d.RebirthStats))) or 0
    for _ = 1, math.min(left, 30) do
        R.AddStat:FireServer(_G.Mofenk.StatPick)
        STATE.statsAdded = STATE.statsAdded + 1
        task.wait(0.15)
    end
end

local function doClaims()
    for _, ev in ipairs({ R.ClaimOffline, R.ClaimDaily, R.ClaimGroup }) do
        if ev then pcall(function() ev:FireServer() end) end
    end
    STATE.claims = STATE.claims + 1
end

-- 16. SERIALIZER & LOGGING ENGINE
local LogScroll = nil
local function MofenkLog(msg, logType)
    local timestamp = os.date("%H:%M:%S")
    local formattedMsg = string.format("[%s] %s", timestamp, tostring(msg))
    print(formattedMsg)
    
    if LogScroll and LogScroll.Parent then
        local LogItem = Instance.new("TextLabel")
        LogItem.Parent = LogScroll
        LogItem.Size = UDim2.new(1, -10, 0, 18)
        LogItem.Text = formattedMsg
        if logType == "error" then LogItem.TextColor3 = Color3.fromRGB(255, 90, 90)
        elseif logType == "success" then LogItem.TextColor3 = Color3.fromRGB(100, 255, 150)
        elseif logType == "inspect" then LogItem.TextColor3 = Color3.fromRGB(255, 215, 0)
        elseif logType == "send" then LogItem.TextColor3 = Color3.fromRGB(120, 200, 255)
        else LogItem.TextColor3 = Color3.fromRGB(200, 210, 225) end
        LogItem.TextSize = 11
        LogItem.Font = Enum.Font.Code
        LogItem.BackgroundTransparency = 1
        LogScroll.CanvasPosition = Vector2.new(0, 99999)
    end
end

-- 17. REAL-TIME NETWORK SPY HOOK (__NAMECALL)
local rawNamecall = getrawmetatable and getrawmetatable(game) and getrawmetatable(game).__namecall
if hookmetatable and rawNamecall then
    local oldNamecall
    oldNamecall = hookmetatable(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if _G.Mofenk.SpyEnabled and (method == "FireServer" or method == "InvokeServer") then
            task.spawn(function()
                local argStr = #args > 0 and tostring(args[1]) or "None"
                if _G.Mofenk.SpyConsoleLog then
                    MofenkLog(string.format("📡 [SPY] %s | %s(%s)", self.Name, method, argStr), "send")
                end
                MofenkNotify("📡 SPY DETECTED", string.format("%s (%s)", self.Name, method), "spy", 2)
            end)
        end
        return oldNamecall(self, ...)
    end))
end

-- 18. MAIN UI BUILDER (PRO V16 UI ENGINE)
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkUltraHubV16"
MainGui.Parent = parentGui
MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 620, 0, 420)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = CurrentTheme
MainStroke.Parent = MainFrame
table.insert(ThemeStrokes, MainStroke)

-- Header Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.Size = UDim2.new(0, 280, 1, 0)
TitleLabel.Text = "MOFENKHUB V16.0 — UNCUT ENGINE"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Parent = TopBar
StatsLabel.Position = UDim2.new(0, 300, 0, 0)
StatsLabel.Size = UDim2.new(0, 180, 1, 0)
StatsLabel.Text = "FPS: -- | Ping: -- ms"
StatsLabel.TextColor3 = Color3.fromRGB(160, 170, 200)
StatsLabel.TextSize = 11
StatsLabel.Font = Enum.Font.GothamMedium

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = TopBar
MinimizeBtn.Position = UDim2.new(1, -38, 0, 8)
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 8, 0, 52)
Sidebar.Size = UDim2.new(0, 145, 1, -60)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)

local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.Padding = UDim.new(0, 4)

-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 159, 0, 52)
ContentArea.Size = UDim2.new(1, -167, 1, -60)
ContentArea.BackgroundColor3 = Color3.fromRGB(20, 20, 26)

local TabFrames = {}

local function CreateTab(tabName, layoutOrder)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Parent = Sidebar
    TabBtn.Size = UDim2.new(1, 0, 0, 34)
    TabBtn.Text = " " .. tabName
    TabBtn.TextColor3 = Color3.fromRGB(170, 170, 190)
    TabBtn.TextSize = 11
    TabBtn.Font = Enum.Font.GothamMedium
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    TabBtn.LayoutOrder = layoutOrder

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = TabBtn

    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Parent = ContentArea
    TabScroll.Size = UDim2.new(1, -12, 1, -12)
    TabScroll.Position = UDim2.new(0, 6, 0, 6)
    TabScroll.BackgroundTransparency = 1
    TabScroll.ScrollBarThickness = 4
    TabScroll.ScrollBarImageColor3 = CurrentTheme
    TabScroll.Visible = false

    local ScrollLayout = Instance.new("UIListLayout")
    ScrollLayout.Parent = TabScroll
    ScrollLayout.Padding = UDim.new(0, 8)

    TabFrames[tabName] = TabScroll

    TabBtn.MouseButton1Click:Connect(function()
        for name, frame in pairs(TabFrames) do frame.Visible = (name == tabName) end
        for _, btn in ipairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.TextColor3 = Color3.fromRGB(170, 170, 190)
                btn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
            end
        end
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    end)

    return TabScroll
end

local function AddSection(parent, titleText)
    local SecLabel = Instance.new("TextLabel")
    SecLabel.Parent = parent
    SecLabel.Size = UDim2.new(1, 0, 0, 20)
    SecLabel.Text = titleText
    SecLabel.TextColor3 = CurrentTheme
    SecLabel.TextSize = 11
    SecLabel.Font = Enum.Font.GothamBold
    SecLabel.TextXAlignment = Enum.TextXAlignment.Left
    SecLabel.BackgroundTransparency = 1
    table.insert(ThemeStrokes, SecLabel)
end

local function AddToggle(parent, text, flag, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = parent
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(230, 230, 240)
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Switch = Instance.new("TextButton")
    Switch.Parent = Frame
    Switch.Position = UDim2.new(1, -48, 0.5, -10)
    Switch.Size = UDim2.new(0, 38, 0, 20)
    Switch.Text = ""
    Switch.BackgroundColor3 = _G.Mofenk[flag] and CurrentTheme or Color3.fromRGB(50, 50, 65)

    local SwCorner = Instance.new("UICorner")
    SwCorner.CornerRadius = UDim.new(1, 0)
    SwCorner.Parent = Switch

    Switch.MouseButton1Click:Connect(function()
        _G.Mofenk[flag] = not _G.Mofenk[flag]
        Switch.BackgroundColor3 = _G.Mofenk[flag] and CurrentTheme or Color3.fromRGB(50, 50, 65)
        MofenkNotify("FITUR DIUBAH", text .. " -> " .. tostring(_G.Mofenk[flag]), _G.Mofenk[flag] and "success" or "warn", 2)
        if callback then callback(_G.Mofenk[flag]) end
    end)
end

local function AddSlider(parent, text, min, max, default, flag)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.Size = UDim2.new(1, 0, 0, 46)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.6, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 240)
    label.TextSize = 11
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local valLabel = Instance.new("TextLabel")
    valLabel.Parent = frame
    valLabel.Size = UDim2.new(0.3, 0, 0, 20)
    valLabel.Position = UDim2.new(0.7, -10, 0, 4)
    valLabel.Text = tostring(_G.Mofenk[flag] or default)
    valLabel.TextColor3 = CurrentTheme
    valLabel.TextSize = 11
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.BackgroundTransparency = 1

    local bar = Instance.new("Frame")
    bar.Parent = frame
    bar.Size = UDim2.new(1, -20, 0, 6)
    bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)

    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.Size = UDim2.new(((_G.Mofenk[flag] or default) - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = CurrentTheme

    local dragging = false
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        _G.Mofenk[flag] = value
        valLabel.Text = tostring(value)
        fill.Size = UDim2.new(pos, 0, 1, 0)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function AddButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = parent
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamBold
    Btn.BackgroundColor3 = Color3.fromRGB(34, 34, 46)

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    Btn.MouseButton1Click:Connect(function() pcall(callback) end)
end

-- BUILD TABS
local TabHome     = CreateTab("🏠 Home & Profil", 1)
local TabDebug    = CreateTab("🛠️ Remote Debugger", 2)
local TabFarm     = CreateTab("🌾 Khusus Farm", 3)
local TabTower    = CreateTab("🏰 Tower & Plot", 4)
local TabUnit     = CreateTab("⚔️ Unit & Gear", 5)
local TabShop     = CreateTab("⬆️ Upgrade & Shop", 6)
local TabPlayer   = CreateTab("⚡ Player & Utils", 7)
local TabConsole  = CreateTab("🔍 Console & Log", 8)

TabFrames["🏠 Home & Profil"].Visible = true

-- TAB 1: HOME
AddSection(TabHome, "👤 LIVE PROFIL USER")
local ProfLabel = Instance.new("TextLabel")
ProfLabel.Parent = TabHome
ProfLabel.Size = UDim2.new(1, 0, 0, 45)
ProfLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
ProfLabel.TextSize = 11
ProfLabel.Font = Enum.Font.GothamMedium
ProfLabel.TextXAlignment = Enum.TextXAlignment.Left
ProfLabel.BackgroundTransparency = 1

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local gData = data()
            ProfLabel.Text = string.format("User: %s | ID: %d\nUang: %s | Rebirth: %d", LocalPlayer.Name, LocalPlayer.UserId, tostring(gData and gData.Money or 0), gData and gData.Rebirth or 0)
        end)
    end
end)

-- TAB 3: KHUSUS FARM
AddSection(TabFarm, "🎲 AUTOMATED FARMING ENGINE")
AddToggle(TabFarm, "Auto Roll Dice (Pace Cooldown)", "AutoRoll")
AddToggle(TabFarm, "Auto Roll Spins (Lucky/Jackpot)", "AutoSpins")
AddToggle(TabFarm, "Auto Sell Inventory (Full Logic)", "AutoSell")
AddSlider(TabFarm, "Batas Rarity Jual (1-10)", 1, 10, 3, "SellRarity")
AddSlider(TabFarm, "Simpan Unit Cadangan Terbaik", 0, 100, 20, "KeepBest")

AddButton(TabFarm, "⚡ Manual Sell Junk Sekarang", function()
    performFullAutoSell(true)
end)

-- TAB 4: TOWER & PLOT
AddSection(TabTower, "🏰 TOWER & PLOT AUTOMATION")
AddToggle(TabTower, "Auto Collect Money / Plot Balance", "AutoCollect")
AddToggle(TabTower, "Smart Placement (Potential Base)", "SmartPlace")
AddToggle(TabTower, "Auto Level Up Slot (Smart Payback)", "AutoLevel")
AddToggle(TabTower, "Auto Tower Runner (Simulated Floor)", "AutoTower")
AddSlider(TabTower, "Batas Budget Leveling Slot (%)", 10, 90, 30, "LevelShare")

-- TAB 5: UNIT & GEAR
AddSection(TabUnit, "⚔️ UNIT MANAGEMENT & REROLLS")
AddToggle(TabUnit, "Auto Reroll Grade (Gems)", "AutoGrade")
AddToggle(TabUnit, "Auto Reroll Trait (Trait Rerolls)", "AutoTrait")
AddToggle(TabUnit, "Auto Fuse Units (Balanced Trios)", "AutoFusion")
AddToggle(TabUnit, "Auto Use Boosts", "AutoBoost")

-- TAB 6: SHOP & REBIRTH
AddSection(TabShop, "🛒 SHOP & REBIRTH PROGRESS")
AddToggle(TabShop, "Auto Buy Best Dice", "AutoDice")
AddToggle(TabShop, "Auto Buy Pad Upgrades", "AutoUpgrade")
AddToggle(TabShop, "Auto Rebirth", "AutoRebirth")
AddSlider(TabShop, "Rebirth Bank Multiplier", 1, 20, 1, "RebirthMult")

-- TAB 8: CONSOLE
AddSection(TabConsole, "📝 LIVE IN-UI CONSOLE LOG")
LogScroll = Instance.new("ScrollingFrame")
LogScroll.Parent = TabConsole
LogScroll.Size = UDim2.new(1, 0, 0, 200)
LogScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
LogScroll.ScrollBarThickness = 4

-- FLOATING TOGGLE BUTTON
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "MofenkToggleGui"
ToggleGui.Parent = parentGui
ToggleGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Text = "🎲"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 22
ToggleBtn.Active = true
ToggleBtn.Draggable = true

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- 19. ALL MULTI-THREADED EXECUTION LOOPS (EXACT GITHUB MATCH)
task.spawn(function()
    while true do
        if _G.Mofenk.AutoRoll then pcall(doRoll) end
        task.wait(rollInterval())
    end
end)

task.spawn(function()
    while true do
        if _G.Mofenk.AutoCollect then pcall(doCollectPlace) end
        task.wait(5)
    end
end)

task.spawn(function()
    while true do
        if _G.Mofenk.AutoSell then pcall(function() performFullAutoSell(false) end) end
        task.wait(4)
    end
end)

task.spawn(function()
    while true do
        if _G.Mofenk.AutoGrade or _G.Mofenk.AutoTrait then pcall(doRerolls) end
        task.wait(3)
    end
end)

task.spawn(function()
    while true do
        if _G.Mofenk.AutoFusion and not savingForLuck() then pcall(doFuse) end
        task.wait(4)
    end
end)

task.spawn(function()
    while true do
        if _G.Mofenk.AutoBoost then pcall(useBoosts) end
        task.wait(10)
    end
end)

task.spawn(function()
    while true do
        if _G.Mofenk.AutoTower then pcall(towerRun); task.wait(3) else task.wait(2) end
    end
end)

task.spawn(function()
    while true do
        if STATE then
            STATE.phase = "spending"
            local cost = _G.Mofenk.AutoRebirth and nextRebirthCost() or nil
            local need = cost and cost * math.max(1, _G.Mofenk.RebirthMult) or nil
            if need and data() and data().Money >= need then
                if _G.Mofenk.AutoDice then pcall(doDice, need) end
                if _G.Mofenk.AutoUpgrade then pcall(doUpgrade, need) end
                pcall(doRebirth)
            else
                local diceReserve, upReserve = 0, 0
                if need then
                    local nextDice
                    for _, die in ipairs(DICE) do
                        if die.price and not (data() and data().OwnedDice and data().OwnedDice[die.key]) and die.luck > ownedLuck() then
                            if not nextDice or die.price < nextDice then nextDice = die.price end
                        end
                    end
                    if nextDice and nextDice >= need then diceReserve = need end
                end
                if savingForLuck() then upReserve = nextLuckGoal() or 0 end
                if _G.Mofenk.AutoDice then pcall(doDice, diceReserve) end
                if _G.Mofenk.AutoUpgrade then pcall(doUpgrade, upReserve) end
            end
            if _G.Mofenk.AutoLevel then pcall(levelSlots) end
        end
        task.wait(3)
    end
end)

task.spawn(function()
    while true do
        if _G.Mofenk.AutoCodes then pcall(doCodes) end
        if _G.Mofenk.AutoClaim then pcall(doClaims) end
        if _G.Mofenk.AutoQuests then pcall(doQuests) end
        if _G.Mofenk.AutoPasses then pcall(doPasses) end
        if _G.Mofenk.AutoStats then pcall(doStats) end
        task.wait(30)
    end
end)

MofenkNotify("MOFENKHUB V16.0", "Full Uncut Engine siap dipakai!", "success", 3)
