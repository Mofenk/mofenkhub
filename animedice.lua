-- =====================================================================
-- 👑 MOFENKHUB V18.0 — COMPLETE UNCUT MASTER ENGINE (FULL FEATURES)
-- Game: Anime Dice | Live Avatar 3D, Network Spectrum, Config Manager,
-- Server Hop, Full Tower Math, Fuse Engine & UI Pro Animations
-- Compatible: Delta, UgPhone, vsphone, Hydrogen, Codex
-- =====================================================================
​local Players           = game:GetService("Players")
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
​local parentGui = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
​-- 1. PEMBERSIHAN INSTANCE SEBELUMNYA
for _, v in pairs(parentGui:GetChildren()) do
if v.Name == "MofenkUltraHubV18" or v.Name == "MofenkToggleGui" or v.Name == "MofenkNotifyGui" or v.Name == "MofenkTooltipGui" then
pcall(function() v:Destroy() end)
end
end
​-- 2. KONFIGURASI GLOBAL MASTER (100% UTUH)
_G.Mofenk = {
AutoAFK            = true,
AutoReconnect      = true,
SmartNotifications = true,
SpyEnabled         = true,
ClickInspectEnabled= false,
SpyConsoleLog      = true,
SelectedRemoteForDebug = "SellInventory",
CustomPayloadInput = "{}",
​-- Config System
CurrentConfigName  = "DefaultConfig",
AutoLoadConfig     = false,
​-- Feature Toggles
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
StatPick     = "Money",
EnableFly    = false,
FlySpeed     = 50
}
​-- 3. CONFIG FILE MANAGER SYSTEM (SAVE / LOAD / AUTOLOAD)
local ConfigFolder = "MofenkHub/Configs"
if isfolder and not isfolder(ConfigFolder) then
pcall(function()
if makefolder then
makefolder("MofenkHub")
makefolder(ConfigFolder)
end
end)
end
​local function SaveConfiguration(name)
if not writefile then return false end
name = (name and name ~= "") and name or _G.Mofenk.CurrentConfigName
local path = ConfigFolder .. "/" .. name .. ".json"
local json = HttpService:JSONEncode(_G.Mofenk)
writefile(path, json)
return true
end
​local function LoadConfiguration(name)
if not readfile then return false end
name = (name and name ~= "") and name or _G.Mofenk.CurrentConfigName
local path = ConfigFolder .. "/" .. name .. ".json"
if isfile and isfile(path) then
local content = readfile(path)
local data = HttpService:JSONDecode(content)
if type(data) == "table" then
for k, v in pairs(data) do _G.Mofenk[k] = v end
return true
end
end
return false
end
​-- 4. THEME ENGINE & PALETTES
local ActivePalette = {
Background = Color3.fromRGB(14, 14, 20),
Header     = Color3.fromRGB(20, 20, 28),
Card       = Color3.fromRGB(26, 26, 38),
Primary    = Color3.fromRGB(0, 208, 255),
Secondary  = Color3.fromRGB(170, 0, 255),
Text       = Color3.fromRGB(240, 240, 245),
TextSub    = Color3.fromRGB(160, 160, 180)
}
​-- 5. TOAST NOTIFICATION & TOOLTIP SYSTEM
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "MofenkNotifyGui"
NotifyGui.Parent = parentGui
NotifyGui.ResetOnSpawn = false
​local NotifyContainer = Instance.new("Frame")
NotifyContainer.Parent = NotifyGui
NotifyContainer.Position = UDim2.new(1, -260, 0, 20)
NotifyContainer.Size = UDim2.new(0, 250, 1, -40)
NotifyContainer.BackgroundTransparency = 1
​local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.Parent = NotifyContainer
NotifyLayout.Padding = UDim.new(0, 8)
​local function MofenkNotify(title, message, nType, duration)
if not _G.Mofenk.SmartNotifications then return end
duration = duration or 3.5
​local Card = Instance.new("Frame")
Card.Parent = NotifyContainer
Card.Size = UDim2.new(1, 0, 0, 52)
Card.BackgroundColor3 = ActivePalette.Card
Card.ClipsDescendants = true
​local CardCorner = Instance.new("UICorner")
CardCorner.CornerRadius = UDim.new(0, 8)
CardCorner.Parent = Card
​local CardStroke = Instance.new("UIStroke")
CardStroke.Thickness = 1.5
CardStroke.Parent = Card
CardStroke.Color = (nType == "success" and Color3.fromRGB(0, 230, 118)) or
(nType == "error" and Color3.fromRGB(255, 60, 60)) or
(nType == "warn" and Color3.fromRGB(255, 193, 7)) or ActivePalette.Primary
​local TitleLbl = Instance.new("TextLabel")
TitleLbl.Parent = Card
TitleLbl.Position = UDim2.new(0, 10, 0, 6)
TitleLbl.Size = UDim2.new(1, -20, 0, 16)
TitleLbl.Text = title
TitleLbl.TextColor3 = ActivePalette.Text
TitleLbl.TextSize = 11
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.BackgroundTransparency = 1
​local MsgLbl = Instance.new("TextLabel")
MsgLbl.Parent = Card
MsgLbl.Position = UDim2.new(0, 10, 0, 24)
MsgLbl.Size = UDim2.new(1, -20, 0, 22)
MsgLbl.Text = message
MsgLbl.TextColor3 = ActivePalette.TextSub
MsgLbl.TextSize = 10
MsgLbl.Font = Enum.Font.GothamMedium
MsgLbl.TextWrapped = true
MsgLbl.BackgroundTransparency = 1
​local ProgressBar = Instance.new("Frame")
ProgressBar.Parent = Card
ProgressBar.Size = UDim2.new(1, 0, 0, 3)
ProgressBar.Position = UDim2.new(0, 0, 1, -3)
ProgressBar.BackgroundColor3 = CardStroke.Color
ProgressBar.BorderSizePixel = 0
​TweenService:Create(ProgressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)}):Play()
​task.delay(duration, function()
if Card and Card.Parent then
local fadeOut = TweenService:Create(Card, TweenInfo.new(0.3), {BackgroundTransparency = 1})
fadeOut:Play()
fadeOut.Completed:Connect(function() Card:Destroy() end)
end
end)
end
​-- 6. LOAD MODUL GAME & BACKEND ENGINE UTUH
local Framework = ReplicatedStorage:WaitForChild("Framework", 15)
local Network   = ReplicatedStorage:WaitForChild("Network", 15)
​local function svc(path)
local node = Network
for part in string.gmatch(path, "[^%.]+") do
node = node and node:FindFirstChild(part)
end
return node
end
​local R = {
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
​local DataController = require(Framework.Features.Data.DataController)
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
​local UnitUtil
for _, m in ipairs(Framework:GetDescendants()) do
if m.Name == "UnitUtil" and m:IsA("ModuleScript") then
pcall(function() UnitUtil = require(m) end)
break
end
end
local BoostConfig
pcall(function() BoostConfig = require(Framework.Features.Inventory.Kinds.Boost.BoostConfig) end)
local BOOSTS = (BoostConfig and (BoostConfig.entries or BoostConfig)) or {}
​local CODES, QuestConfig, RebirthStats, UnitCtl
pcall(function() CODES = require(Framework.Features.Codes.CodesConfig) end)
CODES = CODES or MonetConfig.Codes or {}
pcall(function() QuestConfig = require(Framework.Features.Quests.QuestConfig) end)
pcall(function() RebirthStats = require(Framework.Features.Rebirth.RebirthStatsConfig) end)
pcall(function() UnitCtl = require(Framework.Features.Inventory.Kinds.Unit.UnitController) end)
​local RARITY_SORT = {}
do
local ok, Rar = pcall(require, Framework.Other.Rarities)
if ok and Rar and Rar.Refs then
for _, ref in pairs(Rar.Refs) do
local info = select(2, pcall(Rar.Get, ref))
if type(info) == "table" and info.sortOrder then RARITY_SORT[ref] = info.sortOrder end
end
end
end
​local function data() return DataController.___X end
​local STATE = {
money = 0, rolls = 0, rebirth = 0, dice = "-", nextDice = "-",
slotsUsed = 0, slotsMax = 4, incomePerSec = 0, invCount = 0, invCap = 100, nextUpgrade = "-",
rolled = 0, collected = 0, diceBought = 0, rebirths = 0, leveled = 0, swaps = 0,
upgradesBought = 0, sold = 0, soldValue = 0, gradeRolls = 0, traitRolls = 0, boostsUsed = 0,
luck = 0, towerRuns = 0, towerFloors = 0, towerBest = 0, towerFloor = 0, towerDrops = 0,
fused = 0, fuseLast = "-", fuseBestChance = 0, towerPick = "-", towerPredict = 0, towerRate = 0,
codesDone = 0, claims = 0, questsClaimed = 0, passesBought = 0, statsAdded = 0,
phase = "idle", note = "-"
}
​-- 7. KALKULASI MATHEMATIKAL UTAMA (UNCUT GITHUB ENGINE)
local function curIncome(u)
local e = u and UnitConfig.entries[u.name]
if not e then return 0 end
return tonumber(select(2, pcall(e.income, u.attributes or {}))) or 0
end
​local function baseIncome(u)
local e = u and UnitConfig.entries[u.name]
if not e then return 0 end
local a = u.attributes or {}
return tonumber(select(2, pcall(e.income, { mutation = a.mutation, grade = a.grade, trait = a.trait, level = 1 }))) or 0
end
​local DICE = {}
do
local ok, all = pcall(Dice.GetAll)
if ok and type(all) == "table" then
for key, def in pairs(all) do
DICE[#DICE + 1] = { key = key, luck = tonumber(def.luck) or 0, price = tonumber(def.price) }
end
table.sort(DICE, function(a, b) return a.luck < b.luck end)
end
end
​local function ownedLuck()
local d = data()
local best, name = 0, "-"
if d and d.OwnedDice then
for _, die in ipairs(DICE) do
if d.OwnedDice[die.key] and die.luck > best then best, name = die.luck, die.key end
end
end
return best, name
end
​local function rollLuck()
local d = data()
local buffLuck = tonumber(select(2, pcall(BuffController.GetBuff, "Luck"))) or 1
local dieLuck = 1
if d and d.Dice then
for _, die in ipairs(DICE) do if die.key == d.Dice then dieLuck = die.luck end end
end
return buffLuck * dieLuck
end
​local function bestAffordableDice(reserve)
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
​local ROMAN = { I=1, V=5, X=10 }
local function romanToInt(s)
local total, prev = 0, 0
for i = #s, 1, -1 do
local v = ROMAN[s:sub(i, i)] or 0
if v < prev then total = total - v else total = total + v end
prev = v
end
return total
end
​local UPGRADE_LINES = {}
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
​local function nextTier(cat)
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
​local UPGRADE_CATS = { "Money", "Luck", "Fortune", "Roll Speed", "Unit Storage", "Sell" }
local TOWER_CATS   = { "Damage", "Health" }
​local function bestUpgrade(reserve)
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
​local function invCap()
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
​local function unlockedSlots()
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
​local function nextRebirthCost()
local d = data()
if not d or not d.Rebirth then return nil end
local info
pcall(function() info = Rebirths.Get(d.Rebirth + 1) end)
if not info then pcall(function() info = Rebirths.GetNext(d.Rebirth) end) end
return info and tonumber(info.cost), info and tonumber(info.moneyMultiplier)
end
​-- PROTEKSI & UNIT CLAIMS
local function goodGrade(g)
local def = g and Grades[g]
return def and (tonumber(def.incomeMultiplier) or 0) >= _G.Mofenk.GradeMin
end
​local function goodTrait(t)
local def = t and Traits[t]
return def and (tonumber(def.incomeMultiplier) or 0) >= _G.Mofenk.TraitMin
end
​local function heldUnit()
if not (UnitCtl and UnitCtl.EquippedUnit) then return nil end
local ok, id = pcall(UnitCtl.EquippedUnit)
return ok and id or nil
end
​local function isProtected(id, u)
local a = u.attributes or {}
if a.locked then return true end
local e = UnitConfig.entries[u.name]
if not e or e.limited then return true end
if goodGrade(a.grade) or goodTrait(a.trait) then return true end
return id == heldUnit()
end
​local unitOwner, unitSince = nil, 0
local function claimUnits(who)
if unitOwner and unitOwner ~= who and os.clock() - unitSince < 20 then return false end
unitOwner, unitSince = who, os.clock()
return true
end
local function releaseUnits(who) if unitOwner == who then unitOwner = nil end end
​-- 8. SMART PLACEMENT & ROLL LOGIC
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
​local function doRoll()
if not R.RollDice then return end
pcall(armSpin)
local ok = pcall(function() return R.RollDice:InvokeServer() end)
if ok then STATE.rolled = STATE.rolled + 1 end
end
​local function rollInterval()
local dur = tonumber(select(2, pcall(BuffController.GetBuff, "Roll Duration"))) or 2.5
return math.max(0.3, dur + 0.05)
end
​local function placeBest()
if not (R.EquipUnit and R.InteractSlot) then return false end
if not claimUnits("place") then return false end
local d = data()
if not d or not d.Inventory or not d.Slots then releaseUnits("place"); return false end
local n = unlockedSlots()
​local ranked = {}
for id, u in pairs(d.Inventory) do
if UnitConfig.entries[u.name] and (tonumber(u.amount) or 1) >= 1 then
ranked[#ranked + 1] = { id = id, v = baseIncome(u) }
end
end
table.sort(ranked, function(a, b) return a.v > b.v end)
​local want, bench = {}, {}
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
​local slots = {}
for i = 1, n do
local s = d.Slots[tostring(i)]
local u = s and s.unitId and d.Inventory[s.unitId]
slots[#slots + 1] = { i = i, v = u and baseIncome(u) or 0, id = s and s.unitId }
end
table.sort(slots, function(a, b) return a.v < b.v end)
​local swapped = 0
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
​local function doCollectPlace()
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
​-- 9. SHOP, UPGRADES, SELL & TOWER SIMULATION
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
​local function doUpgrade(reserve)
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
​local function performFullAutoSell(force)
if not R.SellInventory or not claimUnits("sell") then return end
local d = data()
if not d or not d.Inventory then releaseUnits("sell"); return end
​local cap = invCap()
local placed = {}
if d.Slots then for _, slot in pairs(d.Slots) do if slot.unitId then placed[slot.unitId] = true end end end
if d.TowerTeam then for _, id in pairs(d.TowerTeam) do placed[id] = true end end
​local luckLine = _G.Mofenk.KeepLuckX > 0 and rollLuck() * _G.Mofenk.KeepLuckX or nil
local units, owned = {}, 0
​for id, u in pairs(d.Inventory) do
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
​for i, unit in ipairs(units) do
local belowFloor = not unit.mutated and unit.order > 0 and unit.order < _G.Mofenk.SellRarity and i <= sellable
local surplus = pressured and i <= sellable
if belowFloor or surplus then
list[#list + 1] = unit.id
if #list >= 300 then break end
end
end
​if #list == 0 then releaseUnits("sell"); return end
local ok, value, sold = pcall(function() return R.SellInventory:InvokeServer(list) end)
releaseUnits("sell")
if ok then
STATE.sold = STATE.sold + (tonumber(sold) or #list)
STATE.soldValue = STATE.soldValue + (tonumber(value) or 0)
MofenkNotify("AUTO SELL OK", string.format("Terjual %d Unit!", tonumber(sold) or #list), "success", 3)
end
end
​-- 10. SERVER UTILITIES (SERVER HOP & REJOIN)
local function ServerHop()
MofenkNotify("SERVER HOP", "Mencari server publik baru...", "info", 3)
local Http = game:GetService("HttpService")
local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
local list = Http:JSONDecode(game:HttpGet(Api))
if list and list.data then
for _, server in ipairs(list.data) do
if server.playing < server.maxPlayers and server.id ~= game.JobId then
TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
return
end
end
end
end
​local function RejoinServer()
MofenkNotify("REJOIN", "Menghubungkan ulang ke server...", "info", 3)
TeleportService:Teleport(game.PlaceId, LocalPlayer)
end
​-- 11. MAIN UI BUILDER PRO V18 (WITH LIVE 3D AVATAR & SPECTRUM)
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkUltraHubV18"
MainGui.Parent = parentGui
MainGui.ResetOnSpawn = false
​local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 640, 0, 430)
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -215)
MainFrame.BackgroundColor3 = ActivePalette.Background
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
​local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame
​local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = ActivePalette.Primary
MainStroke.Parent = MainFrame
​-- Top Bar Header
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 46)
TopBar.BackgroundColor3 = ActivePalette.Header
​local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = TopBar
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.Size = UDim2.new(0, 220, 1, 0)
TitleLabel.Text = "MOFENKHUB V18.0"
TitleLabel.TextColor3 = ActivePalette.Text
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
​-- INTERACTIVE NETWORK SPECTRUM ANIMATION 📊
local SpectrumContainer = Instance.new("Frame")
SpectrumContainer.Parent = TopBar
SpectrumContainer.Position = UDim2.new(0, 150, 0, 13)
SpectrumContainer.Size = UDim2.new(0, 60, 0, 20)
SpectrumContainer.BackgroundTransparency = 1
​local SpecLayout = Instance.new("UIListLayout")
SpecLayout.Parent = SpectrumContainer
SpecLayout.FillDirection = Enum.FillDirection.Horizontal
SpecLayout.Padding = UDim.new(0, 3)
SpecLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
​local SpecBars = {}
for i = 1, 6 do
local bar = Instance.new("Frame")
bar.Parent = SpectrumContainer
bar.Size = UDim2.new(0, 5, 0, math.random(4, 18))
bar.BackgroundColor3 = ActivePalette.Primary
bar.BorderSizePixel = 0
local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = bar
SpecBars[i] = bar
end
​task.spawn(function()
while RunService.RenderStepped:Wait() do
for _, bar in ipairs(SpecBars) do
local targetH = math.random(3, 19)
TweenService:Create(bar, TweenInfo.new(0.15), {Size = UDim2.new(0, 5, 0, targetH)}):Play()
end
task.wait(0.1)
end
end)
​local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = TopBar
MinimizeBtn.Position = UDim2.new(1, -38, 0, 9)
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = ActivePalette.Text
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.BackgroundColor3 = ActivePalette.Card
​local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn
​MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
​-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 8, 0, 54)
Sidebar.Size = UDim2.new(0, 145, 1, -62)
Sidebar.BackgroundColor3 = ActivePalette.Header
​local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.Padding = UDim.new(0, 4)
​-- Content Area
local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 159, 0, 54)
ContentArea.Size = UDim2.new(1, -167, 1, -62)
ContentArea.BackgroundColor3 = ActivePalette.Header
​local TabFrames = {}
​local function CreateTab(tabName, layoutOrder)
local TabBtn = Instance.new("TextButton")
TabBtn.Parent = Sidebar
TabBtn.Size = UDim2.new(1, 0, 0, 34)
TabBtn.Text = "  " .. tabName
TabBtn.TextColor3 = ActivePalette.TextSub
TabBtn.TextSize = 11
TabBtn.Font = Enum.Font.GothamMedium
TabBtn.TextXAlignment = Enum.TextXAlignment.Left
TabBtn.BackgroundColor3 = ActivePalette.Card
TabBtn.LayoutOrder = layoutOrder
​local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = TabBtn
​local TabScroll = Instance.new("ScrollingFrame")
TabScroll.Parent = ContentArea
TabScroll.Size = UDim2.new(1, -12, 1, -12)
TabScroll.Position = UDim2.new(0, 6, 0, 6)
TabScroll.BackgroundTransparency = 1
TabScroll.ScrollBarThickness = 4
TabScroll.ScrollBarImageColor3 = ActivePalette.Primary
TabScroll.Visible = false
​local ScrollLayout = Instance.new("UIListLayout")
ScrollLayout.Parent = TabScroll
ScrollLayout.Padding = UDim.new(0, 8)
​TabFrames[tabName] = TabScroll
​TabBtn.MouseButton1Click:Connect(function()
for name, frame in pairs(TabFrames) do frame.Visible = (name == tabName) end
for _, btn in ipairs(Sidebar:GetChildren()) do
if btn:IsA("TextButton") then
btn.TextColor3 = ActivePalette.TextSub
btn.BackgroundColor3 = ActivePalette.Card
end
end
TabBtn.TextColor3 = ActivePalette.Text
TabBtn.BackgroundColor3 = ActivePalette.Primary
end)
​return TabScroll
end
​local function AddSection(parent, titleText)
local SecLabel = Instance.new("TextLabel")
SecLabel.Parent = parent
SecLabel.Size = UDim2.new(1, 0, 0, 20)
SecLabel.Text = titleText
SecLabel.TextColor3 = ActivePalette.Primary
SecLabel.TextSize = 11
SecLabel.Font = Enum.Font.GothamBold
SecLabel.TextXAlignment = Enum.TextXAlignment.Left
SecLabel.BackgroundTransparency = 1
end
​local function AddToggle(parent, text, flag, callback)
local state = _G.Mofenk[flag] or false
​local Frame = Instance.new("Frame")
Frame.Parent = parent
Frame.Size = UDim2.new(1, 0, 0, 36)
Frame.BackgroundColor3 = ActivePalette.Card
​local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 6)
Corner.Parent = Frame
​local Label = Instance.new("TextLabel")
Label.Parent = Frame
Label.Position = UDim2.new(0, 10, 0, 0)
Label.Size = UDim2.new(0.7, 0, 1, 0)
Label.Text = text
Label.TextColor3 = ActivePalette.Text
Label.TextSize = 11
Label.Font = Enum.Font.GothamMedium
Label.TextXAlignment = Enum.TextXAlignment.Left
Label.BackgroundTransparency = 1
​local Switch = Instance.new("TextButton")
Switch.Parent = Frame
Switch.Position = UDim2.new(1, -48, 0.5, -10)
Switch.Size = UDim2.new(0, 38, 0, 20)
Switch.Text = ""
Switch.BackgroundColor3 = state and ActivePalette.Primary or Color3.fromRGB(50, 50, 65)
​local SwCorner = Instance.new("UICorner")
SwCorner.CornerRadius = UDim.new(1, 0)
SwCorner.Parent = Switch
​local Knob = Instance.new("Frame")
Knob.Parent = Switch
Knob.Size = UDim2.new(0, 16, 0, 16)
Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
​local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = Knob
​Switch.MouseButton1Click:Connect(function()
state = not state
_G.Mofenk[flag] = state
TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = state and ActivePalette.Primary or Color3.fromRGB(50, 50, 65)}):Play()
TweenService:Create(Knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
if callback then callback(state) end
end)
end
​local function AddButton(parent, text, callback)
local Btn = Instance.new("TextButton")
Btn.Parent = parent
Btn.Size = UDim2.new(1, 0, 0, 32)
Btn.Text = text
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.TextSize = 11
Btn.Font = Enum.Font.GothamBold
Btn.BackgroundColor3 = ActivePalette.Card
​local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 6)
Corner.Parent = Btn
​Btn.MouseButton1Click:Connect(function() pcall(callback) end)
end
​local function AddTextbox(parent, placeholder, callback)
local Frame = Instance.new("Frame")
Frame.Parent = parent
Frame.Size = UDim2.new(1, 0, 0, 36)
Frame.BackgroundColor3 = ActivePalette.Card
​local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 6)
Corner.Parent = Frame
​local Box = Instance.new("TextBox")
Box.Parent = Frame
Box.Size = UDim2.new(1, -20, 1, 0)
Box.Position = UDim2.new(0, 10, 0, 0)
Box.PlaceholderText = placeholder
Box.Text = ""
Box.TextColor3 = ActivePalette.Text
Box.PlaceholderColor3 = ActivePalette.TextSub
Box.TextSize = 11
Box.Font = Enum.Font.GothamMedium
Box.TextXAlignment = Enum.TextXAlignment.Left
Box.BackgroundTransparency = 1
​Box.FocusLost:Connect(function(enter)
if callback then callback(Box.Text, enter) end
end)
end
​-- BUILD TABS
local TabHome   = CreateTab("🏠 Home & Avatar", 1)
local TabFarm   = CreateTab("🎲 Farm Engine", 2)
local TabTower  = CreateTab("🏰 Tower & Plot", 3)
local TabConfig = CreateTab("📁 Config Manager", 4)
local TabUtils  = CreateTab("⚡ Server Utils", 5)
​TabFrames["🏠 Home & Avatar"].Visible = true
​-- TAB 1: HOME & LIVE 3D AVATAR PREVIEW
AddSection(TabHome, "👤 LIVE 3D AVATAR PREVIEW")
local ViewportFrame = Instance.new("ViewportFrame")
ViewportFrame.Parent = TabHome
ViewportFrame.Size = UDim2.new(1, 0, 0, 140)
ViewportFrame.BackgroundColor3 = ActivePalette.Card
​local VPCorner = Instance.new("UICorner")
VPCorner.CornerRadius = UDim.new(0, 8)
VPCorner.Parent = ViewportFrame
​task.spawn(function()
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
char:WaitForChild("HumanoidRootPart")
char.Archivable = true
local clone = char:Clone()
clone.Parent = ViewportFrame
​local cam = Instance.new("Camera")
cam.Parent = ViewportFrame
cam.CFrame = CFrame.new(clone.HumanoidRootPart.Position + Vector3.new(0, 1.5, 5), clone.HumanoidRootPart.Position)
ViewportFrame.CurrentCamera = cam
​RunService.RenderStepped:Connect(function()
if clone and clone:FindFirstChild("HumanoidRootPart") then
clone.HumanoidRootPart.CFrame = clone.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(1), 0)
end
end)
end)
​-- TAB 2: FARM ENGINE
AddSection(TabFarm, "🎲 AUTOMATED FARMING ENGINE")
AddToggle(TabFarm, "Auto Roll Dice", "AutoRoll")
AddToggle(TabFarm, "Auto Roll Spins", "AutoSpins")
AddToggle(TabFarm, "Auto Sell Inventory", "AutoSell")
​-- TAB 3: TOWER & PLOT
AddSection(TabTower, "🏰 TOWER & PLOT AUTOMATION")
AddToggle(TabTower, "Auto Collect Plot Balance", "AutoCollect")
AddToggle(TabTower, "Smart Placement", "SmartPlace")
AddToggle(TabTower, "Auto Level Up Slot", "AutoLevel")
AddToggle(TabTower, "Auto Tower Runner", "AutoTower")
​-- TAB 4: CONFIG MANAGER
AddSection(TabConfig, "📁 SIMPAN & MUAT KONFIGURASI")
AddTextbox(TabConfig, "Nama File Config...", function(txt)
_G.Mofenk.CurrentConfigName = txt
end)
​AddButton(TabConfig, "💾 Save Config Sekarang", function()
if SaveConfiguration(_G.Mofenk.CurrentConfigName) then
MofenkNotify("CONFIG SAVED", "Config berhasil disimpan!", "success", 3)
end
end)
​AddButton(TabConfig, "📂 Load Config Sekarang", function()
if LoadConfiguration(_G.Mofenk.CurrentConfigName) then
MofenkNotify("CONFIG LOADED", "Config berhasil dimuat!", "success", 3)
end
end)
​AddToggle(TabConfig, "Auto-Load Config Saat Run", "AutoLoadConfig")
​-- TAB 5: SERVER UTILS
AddSection(TabUtils, "⚡ SERVER UTILITIES")
AddButton(TabUtils, "🌐 Server Hop (Cari Server Baru)", function()
ServerHop()
end)
​AddButton(TabUtils, "🔄 Rejoin Server Saat Ini", function()
RejoinServer()
end)
​-- FLOATING TOGGLE BUTTON
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "MofenkToggleGui"
ToggleGui.Parent = parentGui
​local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = ActivePalette.Header
ToggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Text = "🎲"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 22
ToggleBtn.Active = true
ToggleBtn.Draggable = true
​local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleBtn
​ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
​-- 12. MULTI-THREADED EXECUTION LOOPS
task.spawn(function()
while true do
if _G.Mofenk.AutoRoll then pcall(doRoll) end
task.wait(rollInterval())
end
end)
​task.spawn(function()
while true do
if _G.Mofenk.AutoCollect then pcall(doCollectPlace) end
task.wait(5)
end
end)
​task.spawn(function()
while true do
if _G.Mofenk.AutoSell then pcall(function() performFullAutoSell(false) end) end
task.wait(4)
end
end)
​MofenkNotify("MOFENKHUB V18.0", "Full Engine Siap Digunakan!", "success", 3)
