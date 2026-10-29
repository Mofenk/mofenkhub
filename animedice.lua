-- ===================================================================== --
-- 👑 MOFENKHUB V115.0 — EXTREME SMART PLANNER & AUTONOMOUS AI ENGINE
-- Architecture: Real-Time State Driven AI + Corvus P1-P7 Queue + Telemetry UI
-- ===================================================================== --
​--!nocheck
task.wait(0.2)
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local TeleportService   = game:GetService("TeleportService")
local RunService        = game:GetService("RunService")
local Stats             = game:GetService("Stats")
​-- Robust Teleport Queue Hook (Zero-Loss Teleport Reconnection)
pcall(function()
local qot = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
if qot then
qot([[
task.wait(3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/Mofenk/mofenkhub/refs/heads/main/animedice.lua"))()
]])
end
end)
​local LocalPlayer = Players.LocalPlayer
local successGui, parentGui = pcall(function()
if gethui then return gethui() elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end
​pcall(function() for _, v in pairs(parentGui:GetChildren()) do if string.find(v.Name, "Mofenk") then v:Destroy() end end end)
​-- ===================================================================== --
-- 1. DIAGNOSTIC & TELEMETRY ENGINE (ANTI-NIL ERROR LOGGING)
-- ===================================================================== --
local DiagnosticEngine = {
TotalCalls = 0, SuccessCount = 0, ErrorCount = 0, ErrorRegistry = {},
LogFile = "MofenkHub_Configs/diagnostic_report.json"
}
​function DiagnosticEngine:Log(tag, msg, errData)
local timestamp = os.date("%X")
local entry = { Time = timestamp, Tag = tag, Message = msg, ErrorData = errData and tostring(errData) or nil }
if errData then
self.ErrorCount = self.ErrorCount + 1
table.insert(self.ErrorRegistry, 1, entry)
if #self.ErrorRegistry > 50 then table.remove(self.ErrorRegistry) end
warn(string.format("[🚨 MofenkDiag] [%s] [%s]: %s | Error: %s", timestamp, tag, msg, tostring(errData)))
else
self.SuccessCount = self.SuccessCount + 1
end
self.TotalCalls = self.TotalCalls + 1
end
​function DiagnosticEngine:SafeExecute(tag, fn, ...)
local args = {...}
local ok, res = xpcall(function() return fn(unpack(args)) end, function(e) return debug.traceback(tostring(e), 2) end)
if not ok then self:Log(tag, "Gagal Eksekusi", res) end
return ok, res
end
​function DiagnosticEngine:GetHealthScore()
if self.TotalCalls == 0 then return 100.0 end
return math.clamp((self.SuccessCount / self.TotalCalls) * 100, 0, 100)
end
​-- ===================================================================== --
-- 2. CONFIGURATION & STATE MANAGER
-- ===================================================================== --
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE
​local F = {
cfgName = "MofenkConfigExtreme", autoLoadEnabled = false,
-- Smart AI Planner Master Switch
smartPlannerActive = true,
-- Farm & Plot
collect = true, levelup = true, maxLevel = 50, smartLevel = true,
rebirth = true, upgrades = true, buyDice = true, equipDice = true, autoRoll = true,
autoBestPlaceBase = true, smartPlace = true,
-- Inventory & Dynamic Rarity Multi-Select Auto Sell / Lock
sellAuto = true, sellMaxInvent = true, keepBest = 3, autoFuse = true,
keepRarities = {"Mythic", "Secret", "Divine", "Godly"},
autoLockRarity = true,
specificSellUnits = {},
-- Potions
potionAuto = true, potionBest = true, potionSpecific = {},
-- Quirk, Grade & Trait Management
autoLockTarget = true,
quirkAuto = true, quirkTargets = {"Godly", "All-Out", "Shadow"}, quirkUnits = {}, quirkReserve = 10,
gradeAuto = true, gradeAll = false, gradePlacedOnly = false, gradeTargets = {"Z", "SSS"}, gradeUnits = {}, gemReserve = 50,
traitAuto = true, traitAll = false, traitPlacedOnly = false, traitTargets = {"Godly", "Overlord"}, traitUnits = {}, rerollReserve = 20,
-- Main Tower Setup
tower = true, towerMix = true, towerList = {"Dragon Tower", "Demon Tower"}, towerEquipBest = true, towerExitOn = false, towerExitFloor = 50,
-- Halloween & Haunted Tower
halloweenTeleport = true, halloweenQuest = true, halloweenPath = true, halloweenOffer = true, trickOrTreat = true,
pumpkinRollQty = 5, pumpkinAutoRoll = true, pumpkinAutoSell = true,
hauntedTower = true, hauntedMix = true, hauntedList = {"Haunted Front Yard", "Haunted Crypt"}, hauntedEquipBest = true, hauntedExitOn = false, hauntedExitFloor = 50,
-- Client & Misc
wsOn = false, wsValue = 16, noclip = false, afk = true, fpsOn = true,
codesAuto = true, claimQuests = true,
-- Webhook
webhookEnabled = false, webhookUrl = ""
}
​local STATE = {
towerLive = "Standby", towerFloor = 0, towerDrops = 0, towerTraitsGot = "Belum Ada",
hauntedLive = "Standby", hauntedFloor = 0, hauntedDrops = 0, activeBuffs = "Tidak Ada",
pingMs = 0, fpsCurrent = 60,
quirkActiveUnit = "-", quirkCurrentVal = "-", quirkStatus = "Standby",
gradeActiveUnit = "-", gradeCurrentVal = "-", gradeStatus = "Standby",
traitActiveUnit = "-", traitCurrentVal = "-", traitStatus = "Standby",
aiDecision = "Inisialisasi Neural Engine..."
}
​local GLASS_THEME = {
Bg     = Color3.fromRGB(8, 14, 26),
Card   = Color3.fromRGB(15, 25, 45),
Header = Color3.fromRGB(11, 18, 32),
Acc1   = Color3.fromRGB(0, 195, 255),
Acc2   = Color3.fromRGB(37, 99, 235),
Text   = Color3.fromRGB(241, 245, 249),
SubText= Color3.fromRGB(148, 163, 184)
}
​local CFG_FOLDER = "MofenkHub_Configs"
if makefolder and not isfolder(CFG_FOLDER) then pcall(function() makefolder(CFG_FOLDER) end) end
​local function getCfgPath(name) return CFG_FOLDER .. "/" .. (name or F.cfgName or "DefaultConfig") .. ".json" end
​local function saveConfig(name)
if writefile then
pcall(function()
writefile(getCfgPath(name), HttpService:JSONEncode(F))
local pointerPath = CFG_FOLDER .. "/autoload_pointer.txt"
if F.autoLoadEnabled then
writefile(pointerPath, name or F.cfgName or "DefaultConfig")
else
if isfile and isfile(pointerPath) then delfile(pointerPath) end
end
end)
end
end
​local function loadConfig(name)
local path = getCfgPath(name)
if readfile and isfile and isfile(path) then
pcall(function()
local d = HttpService:JSONDecode(readfile(path))
for k,v in pairs(d) do F[k]=v end
end)
end
end
​local function AddSpyLog(txt)
print("[MofenkHub-Spy] [" .. os.date("%X") .. "] " .. tostring(txt))
end
​local function FormatMoney(val)
val = tonumber(val) or 0
if val >= 1e12 then return string.format("%.2fT", val/1e12)
elseif val >= 1e9 then return string.format("%.2fB", val/1e9)
elseif val >= 1e6 then return string.format("%.2fM", val/1e6)
elseif val >= 1e3 then return string.format("%.2fK", val/1e3)
else return tostring(math.floor(val)) end
end
​-- ===================================================================== --
-- 3. SECURE REMOTE PROBER & FRAMEWORK BINDINGS
-- ===================================================================== --
local Network = ReplicatedStorage:WaitForChild("Network", 15)
local Framework = ReplicatedStorage:WaitForChild("Framework", 15)
​local function SafeProbe(serviceName, remoteName)
local r = nil
pcall(function()
if Network and Network:FindFirstChild(serviceName) then
r = Network[serviceName]:FindFirstChild(remoteName, true)
end
end)
return r
end
​local R = {
RollDice        = SafeProbe("RollService", "RollDice"),
SetAutoRoll     = SafeProbe("RollService", "SetAutoRoll"),
CollectBalance  = SafeProbe("PlotService", "CollectBalance"),
LevelUpSlot     = SafeProbe("PlotService", "LevelUpSlot"),
EquipBestPlot   = SafeProbe("PlotService", "EquipBest"),
BuyDice         = SafeProbe("DiceShopService", "BuyDice"),
EquipDice       = SafeProbe("DiceShopService", "EquipDice"),
Rebirth         = SafeProbe("RebirthService", "Rebirth"),
BuyUpgrade      = SafeProbe("PlotService", "BuyPadUpgrade") or SafeProbe("Upgrades", "BuyUpgrade"),
QuirkRoll       = SafeProbe("QuirkService", "Roll") or SafeProbe("Quirks", "Roll"),
GradeRoll       = SafeProbe("GradeService", "Roll") or SafeProbe("Grades", "Roll"),
TraitRoll       = SafeProbe("TraitService", "Roll") or SafeProbe("Traits", "Roll"),
BoostUse        = SafeProbe("BoostService", "Use"),
PlayTower       = SafeProbe("Towers", "PlayTower") or SafeProbe("TowerService", "PlayTower"),
CompleteFloor   = SafeProbe("Towers", "CompleteTowerFloor") or SafeProbe("TowerService", "CompleteTowerFloor"),
CancelTower     = SafeProbe("Towers", "CancelTower") or SafeProbe("TowerService", "CancelTower"),
BestTowerTeam   = SafeProbe("Towers", "EquipBestTowerTeam") or SafeProbe("TowerService", "EquipBestTowerTeam"),
RedeemCode      = SafeProbe("CodesService", "RedeemCode") or SafeProbe("MonetizationService", "RedeemCode"),
QuestClaim      = SafeProbe("QuestService", "Claim"),
ClaimDaily      = SafeProbe("DailyRewardService", "Claim"),
ClaimOffline    = SafeProbe("OfflineEarningsService", "Claim"),
ClaimGroup      = SafeProbe("GroupRewardService", "Claim"),
SellInventory   = SafeProbe("SellService", "SellInventory"),
UpdateAutoSell  = SafeProbe("SellService", "UpdateAutoSell"),
Fuse            = SafeProbe("FusingService", "Fuse"),
InteractSlot    = SafeProbe("PlotService", "InteractSlot"),
EquipUnit       = SafeProbe("UnitService", "Equip"),
UnequipUnit     = SafeProbe("UnitService", "Unequip"),
LockUnit        = SafeProbe("UnitService", "SetLock") or SafeProbe("InventoryService", "Lock"),
HWTeleport      = SafeProbe("HalloweenService", "Teleport"),
HWSeenIntro     = SafeProbe("HalloweenService", "SeenIntro"),
HWQuestClaim    = SafeProbe("HalloweenQuestService", "Claim"),
HWClaimPath     = SafeProbe("HalloweenService", "ClaimAllPath"),
HWBuyOffer      = SafeProbe("HalloweenService", "BuyOffer"),
TrickOrTreat    = SafeProbe("TrickOrTreatService", "Knocked"),
PumpkinRoll     = SafeProbe("PumpkinDiceService", "Roll"),
PumpkinAutoSell = SafeProbe("PumpkinDiceService", "SetAutoSell")
}
​local G = {}
pcall(function()
G.DC = require(Framework.Features.Data.DataController)
G.PlotConfig = require(Framework.Features.Plot.PlotConfig)
G.UnitUtil = require(Framework.Features.Inventory.Kinds.Unit.UnitUtil)
G.Upgrades = require(Framework.Features.Upgrades.Upgrades)
G.Rebirths = require(Framework.Features.Rebirth.Rebirths)
G.BoostConfig = require(Framework.Features.Inventory.Kinds.Boost.BoostConfig)
G.GradesMod = require(Framework.Features.Grades.Grades)
G.TraitsMod = require(Framework.Features.Traits.Traits)
G.QuirksMod = (Framework.Features:FindFirstChild("Quirks") and require(Framework.Features.Quirks.Quirks)) or (Framework.Features:FindFirstChild("Mutations") and require(Framework.Features.Mutations.Mutations))
G.QuestConfig = require(Framework.Features.Quests.QuestConfig)
G.EntryRegistry = require(Framework.Features.Inventory.EntryRegistry)
G.BuffController = require(Framework.Features.Buffs.BuffController)
G.DiceModule = require(Framework.Features.Rolling.Dice)
G.TowersConfig = require(Framework.Features.Towers.Towers)
G.UnitConfig = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig)
end)
​local function data() return G.DC and G.DC.___X or {} end
local function money() pcall(function() return G.DC.Money() end); return data().Money or 0 end
local function level() pcall(function() return G.DC.Level() end); return data().Level or 1 end
local function rebirthAmt() pcall(function() return G.DC.Rebirth() end); return data().Rebirth or 0 end
local function inventory() return data().Inventory or {} end
local function slots() return data().Slots or {} end
local function isUnitEntry(e) return e and type(e)"table" and e.name and G.EntryRegistry and pcall(function() return G.EntryRegistry.getEntryConfig(e.name).kind == "Unit" end) end
local function currencyAmount(name) local t = 0; for _, e in pairs(inventory()) do if type(e)"table" and e.name==name then t += tonumber(e.amount) or 0 end end; return t end
​local function isBeingRolled(unitId)
if not unitId then return false end
if F.quirkAuto then for _, id in ipairs(F.quirkUnits or {}) do if id == unitId then return true end end end
if F.gradeAuto then for _, id in ipairs(F.gradeUnits or {}) do if id == unitId then return true end end end
if F.traitAuto then for _, id in ipairs(F.traitUnits or {}) do if id == unitId then return true end end end
return false
end
​local function getUnitRarity(u)
local rarity = "Common"
if u and u.name then
pcall(function()
if G.EntryRegistry and G.EntryRegistry.getEntryConfig then
local cfg = G.EntryRegistry.getEntryConfig(u.name)
if cfg and cfg.rarity then rarity = cfg.rarity end
elseif G.UnitConfig and G.UnitConfig.entries then
local cfg = G.UnitConfig.entries[u.name]
if cfg and cfg.rarity then rarity = cfg.rarity end
end
end)
end
return tostring(rarity)
end
​local function baseIncome(u)
if not u then return 0 end
local e = G.UnitConfig and G.UnitConfig.entries[u.name]
if not e then return 0 end
local a = u.attributes or {}
local lvlNum = tonumber(a.level) or 1
local ok, inc = pcall(function()
if e.income then return e.income({ mutation = a.mutation or a.quirk, grade = a.grade, trait = a.trait, level = lvlNum }) end
return 0
end)
return tonumber(inc) or 0
end
​local function SendWebhook(title, description, colorCode)
if not F.webhookEnabled or F.webhookUrl == "" then return end
local req = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
if req then
pcall(function()
req({
Url = F.webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"},
Body = HttpService:JSONEncode({ username = "MofenkHub Extreme", avatar_url = "https://i.imgur.com/3qGMB7j.png", embeds = {{ title = title, description = description, color = colorCode or 3447003, footer = {text = "Player: " .. LocalPlayer.Name} }} })
})
end)
end
end
​-- ===================================================================== --
-- 4. UI NOTIFICATIONS & PROFESSIONAL DASHBOARD
-- ===================================================================== --
local ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "MofenkToggleFront"; ToggleGui.Parent = parentGui; ToggleGui.ResetOnSpawn = false
ToggleGui.DisplayOrder = 99999
​local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = ToggleGui; ToggleBtn.Size = UDim2.new(0, 64, 0, 64); ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = GLASS_THEME.Card; ToggleBtn.Text = "🧠"; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 28; ToggleBtn.TextColor3 = GLASS_THEME.Acc1; ToggleBtn.ZIndex = 99999
local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 18); TC.Parent = ToggleBtn
local TS = Instance.new("UIStroke"); TS.Thickness = 2.5; TS.Color = GLASS_THEME.Acc1; TS.Parent = ToggleBtn
​-- Toast Notifications
local NotifyGui = Instance.new("ScreenGui"); NotifyGui.Name = "MofenkNotifyGui"; NotifyGui.Parent = parentGui; NotifyGui.ResetOnSpawn = false
local NotifyHolder = Instance.new("Frame"); NotifyHolder.Parent = NotifyGui; NotifyHolder.Position = UDim2.new(1, -330, 0, 20); NotifyHolder.Size = UDim2.new(0, 310, 1, -40); NotifyHolder.BackgroundTransparency = 1
local NotifyLayout = Instance.new("UIListLayout"); NotifyLayout.Parent = NotifyHolder; NotifyLayout.Padding = UDim.new(0, 8); NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Top
​local function Notify(title, msg, duration)
duration = duration or 3.5
local Card = Instance.new("Frame"); Card.Parent = NotifyHolder; Card.Size = UDim2.new(1, 0, 0, 64); Card.BackgroundColor3 = GLASS_THEME.Card; Card.BackgroundTransparency = 0.1
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 12); CC.Parent = Card
local CS = Instance.new("UIStroke"); CS.Thickness = 1.5; CS.Color = GLASS_THEME.Acc1; CS.Parent = Card
​local T = Instance.new("TextLabel"); T.Parent = Card; T.Position = UDim2.new(0, 14, 0, 6); T.Size = UDim2.new(1, -28, 0, 22); T.Text = title; T.TextColor3 = GLASS_THEME.Acc1; T.Font = Enum.Font.GothamBold; T.TextSize = 14; T.TextXAlignment = Enum.TextXAlignment.Left; T.BackgroundTransparency = 1
local M = Instance.new("TextLabel"); M.Parent = Card; M.Position = UDim2.new(0, 14, 0, 28); M.Size = UDim2.new(1, -28, 0, 30); M.Text = msg; M.TextColor3 = GLASS_THEME.Text; M.Font = Enum.Font.GothamMedium; M.TextSize = 12; M.TextXAlignment = Enum.TextXAlignment.Left; M.TextWrapped = true; M.BackgroundTransparency = 1
​Card.Position = UDim2.new(1, 50, 0, 0)
TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
​task.delay(duration, function()
if Card and Card.Parent then
local tw = TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1, Position = UDim2.new(1, 50, 0, 0)})
tw:Play()
tw.Completed:Connect(function() Card:Destroy() end)
end
end)
end
​-- Main Window UI Assembly
local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkExtremeHub"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false
​local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 1020, 0, 660); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.BackgroundColor3 = GLASS_THEME.Bg; MainFrame.BackgroundTransparency = 0.08
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 18); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 2; MainStroke.Color = GLASS_THEME.Acc1; MainStroke.Parent = MainFrame
​local ScreenScale = Instance.new("UIScale"); ScreenScale.Parent = MainGui
local function UpdateScale()
local viewport = workspace.CurrentCamera.ViewportSize
local scaleX = viewport.X / 1250; local scaleY = viewport.Y / 720
ScreenScale.Scale = math.clamp(math.min(scaleX, scaleY), 0.80, 1.30)
end
UpdateScale(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
​ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
​-- Top Bar Header
local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 56); TopBar.BackgroundColor3 = GLASS_THEME.Header; TopBar.BackgroundTransparency = 0.15
local TopCorner = Instance.new("UICorner"); TopCorner.CornerRadius = UDim.new(0, 18); TopCorner.Parent = TopBar
​local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 20, 0, 0); Title.Size = UDim2.new(0, 620, 1, 0); Title.Text = "👑 MOFENKHUB V115.0  |  EXTREME SMART PLANNER & AI ENGINE"; Title.TextColor3 = GLASS_THEME.Acc1; Title.TextSize = 15; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1
​local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -50, 0, 11); CloseBtn.Size = UDim2.new(0, 34, 0, 34); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = GLASS_THEME.Text; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 16; CloseBtn.BackgroundColor3 = GLASS_THEME.Card; CloseBtn.BackgroundTransparency = 0.3
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 10); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
​-- Sidebar Navigation
local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = MainFrame; Sidebar.Position = UDim2.new(0, 12, 0, 66); Sidebar.Size = UDim2.new(0, 210, 1, -76); Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 3; Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y; Sidebar.CanvasSize = UDim2.new(0,0,0,0)
local SideLayout = Instance.new("UIListLayout"); Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y; SideLayout.Parent = Sidebar; SideLayout.Padding = UDim.new(0, 6)
​-- Content Area Frame
local ContentArea = Instance.new("Frame"); ContentArea.Parent = MainFrame; ContentArea.Position = UDim2.new(0, 230, 0, 66); ContentArea.Size = UDim2.new(1, -242, 1, -76); ContentArea.BackgroundColor3 = GLASS_THEME.Header; ContentArea.BackgroundTransparency = 0.25
local ContentCorner = Instance.new("UICorner"); ContentCorner.CornerRadius = UDim.new(0, 14); ContentCorner.Parent = ContentArea
​local TabFrames, TabButtons = {}, {}
local ConfigUpdaters = {}
​local function CreateTab(name, icon)
local Btn = Instance.new("TextButton"); Btn.Parent = Sidebar; Btn.Size = UDim2.new(1, -4, 0, 42); Btn.Text = "   " .. icon .. "   " .. name; Btn.TextColor3 = GLASS_THEME.SubText; Btn.TextSize = 13; Btn.Font = Enum.Font.GothamBold; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.BackgroundColor3 = GLASS_THEME.Card; Btn.BackgroundTransparency = 0.4
local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 10); Corner.Parent = Btn
​local Scroll = Instance.new("ScrollingFrame"); Scroll.Parent = ContentArea; Scroll.Size = UDim2.new(1, -18, 1, -18); Scroll.Position = UDim2.new(0, 9, 0, 9); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 5; Scroll.Visible = false; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.CanvasSize = UDim2.new(0,0,0,0)
local Lay = Instance.new("UIListLayout"); Lay.Parent = Scroll; Scroll.ScrollingDirection = Enum.ScrollingDirection.Y; Lay.Padding = UDim.new(0, 12)
TabFrames[name] = Scroll; TabButtons[name] = Btn
​Btn.MouseButton1Click:Connect(function()
for n, f in pairs(TabFrames) do f.Visible = (n == name) end
for _, b in pairs(TabButtons) do b.BackgroundTransparency = 0.4; b.TextColor3 = GLASS_THEME.SubText; b.BackgroundColor3 = GLASS_THEME.Card end
Btn.BackgroundTransparency = 0.1; Btn.TextColor3 = GLASS_THEME.Acc1; Btn.BackgroundColor3 = GLASS_THEME.Card
end)
return Scroll
end
​local function AddGroup(parent, title)
local GroupCard = Instance.new("Frame"); GroupCard.Parent = parent; GroupCard.Size = UDim2.new(1, 0, 0, 0); GroupCard.AutomaticSize = Enum.AutomaticSize.Y; GroupCard.BackgroundColor3 = GLASS_THEME.Card; GroupCard.BackgroundTransparency = 0.2
local GC = Instance.new("UICorner"); GC.CornerRadius = UDim.new(0, 12); GC.Parent = GroupCard
local GS = Instance.new("UIStroke"); GS.Thickness = 1.2; GS.Color = GLASS_THEME.Acc1; GS.Transparency = 0.6; GS.Parent = GroupCard
local GLayout = Instance.new("UIListLayout"); GLayout.Parent = GroupCard; GLayout.Padding = UDim.new(0, 10); GLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local GPadding = Instance.new("UIPadding"); GPadding.Parent = GroupCard; GPadding.PaddingTop = UDim.new(0, 12); GPadding.PaddingBottom = UDim.new(0, 12); GPadding.PaddingLeft = UDim.new(0, 12); GPadding.PaddingRight = UDim.new(0, 12)
​if title and title ~= "" then
local HeaderLbl = Instance.new("TextLabel"); HeaderLbl.Parent = GroupCard; HeaderLbl.Size = UDim2.new(1, 0, 0, 28); HeaderLbl.Text = title; HeaderLbl.TextColor3 = GLASS_THEME.Acc1; HeaderLbl.TextSize = 14; HeaderLbl.Font = Enum.Font.GothamBlack; HeaderLbl.TextXAlignment = Enum.TextXAlignment.Left; HeaderLbl.BackgroundTransparency = 1
end
return GroupCard
end
​local function AddToggle(parent, text, flag, callback)
local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 42); Frm.BackgroundTransparency = 1
local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.68, 0, 1, 0); L.Text = text; L.TextColor3 = GLASS_THEME.Text; L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
local Sw = Instance.new("TextButton"); Sw.Parent = Frm; Sw.Position = UDim2.new(1, -52, 0.5, -13); Sw.Size = UDim2.new(0, 46, 0, 26); Sw.Text = ""; local SwC = Instance.new("UICorner"); SwC.CornerRadius = UDim.new(1, 0); SwC.Parent = Sw
local Knob = Instance.new("Frame"); Knob.Parent = Sw; Knob.Size = UDim2.new(0, 22, 0, 22); Knob.BackgroundColor3 = GLASS_THEME.Text; local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1, 0); KC.Parent = Knob
​local function updateVisuals()
Sw.BackgroundColor3 = F[flag] and GLASS_THEME.Acc1 or Color3.fromRGB(30, 41, 59)
TweenService:Create(Knob, TweenInfo.new(0.2), {Position = F[flag] and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)}):Play()
end
table.insert(ConfigUpdaters, updateVisuals)
​Sw.MouseButton1Click:Connect(function()
F[flag] = not F[flag]
updateVisuals()
Notify("MofenkHub Extreme", text .. ": " .. (F[flag] and "AKTIF" or "NONAKTIF"), 2)
if callback then pcall(callback, F[flag]) end
end)
updateVisuals()
end
​local function AddInput(parent, text, flag, isNum)
local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 42); Frm.BackgroundTransparency = 1
local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.48, 0, 1, 0); L.Text = text; L.TextColor3 = GLASS_THEME.Text; L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
local Box = Instance.new("TextBox"); Box.Parent = Frm; Box.Position = UDim2.new(0.5, 0, 0.1, 0); Box.Size = UDim2.new(0.5, 0, 0.8, 0); Box.TextColor3 = GLASS_THEME.Acc1; Box.TextSize = 13; Box.Font = Enum.Font.GothamBold; Box.BackgroundColor3 = GLASS_THEME.Header; Box.BackgroundTransparency = 0.25; local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); BC.Parent = Box
local BS = Instance.new("UIStroke"); BS.Thickness = 1; BS.Color = GLASS_THEME.Acc1; BS.Transparency = 0.6; BS.Parent = Box
​local function updateVisuals() Box.Text = tostring(F[flag] or "") end
table.insert(ConfigUpdaters, updateVisuals)
​Box.FocusLost:Connect(function() F[flag] = isNum and (tonumber(Box.Text) or 0) or Box.Text; updateVisuals() end)
updateVisuals()
end
​local function AddDropdown(parent, title, options, flag, isMulti)
local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 46); Frm.BackgroundTransparency = 1
local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.4, 0, 1, 0); L.Text = title; L.TextColor3 = GLASS_THEME.Text; L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
local Btn = Instance.new("TextButton"); Btn.Parent = Frm; Btn.Position = UDim2.new(0.42, 0, 0.1, 0); Btn.Size = UDim2.new(0.58, 0, 0.8, 0); Btn.TextColor3 = GLASS_THEME.Acc1; Btn.TextSize = 12; Btn.Font = Enum.Font.GothamBold; Btn.BackgroundColor3 = GLASS_THEME.Header; Btn.BackgroundTransparency = 0.25; local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); BC.Parent = Btn
local BS = Instance.new("UIStroke"); BS.Thickness = 1; BS.Color = GLASS_THEME.Acc1; BS.Transparency = 0.6; BS.Parent = Btn
​local DropList = Instance.new("Frame"); DropList.Parent = MainFrame; DropList.Size = UDim2.new(0, 310, 0, 240); DropList.BackgroundColor3 = GLASS_THEME.Bg; DropList.Visible = false; DropList.ZIndex = 300
local DLC = Instance.new("UICorner"); DLC.CornerRadius = UDim.new(0, 10); DLC.Parent = DropList
local DLS = Instance.new("UIStroke"); DLS.Thickness = 1.5; DLS.Color = GLASS_THEME.Acc1; DLS.Parent = DropList
​local SearchBox = Instance.new("TextBox"); SearchBox.Parent = DropList; SearchBox.Size = UDim2.new(1, -16, 0, 32); SearchBox.Position = UDim2.new(0, 8, 0, 8); SearchBox.PlaceholderText = "🔍 Cari Pilihan..."; SearchBox.Text = ""; SearchBox.TextColor3 = GLASS_THEME.Text; SearchBox.PlaceholderColor3 = GLASS_THEME.SubText; SearchBox.TextSize = 12; SearchBox.Font = Enum.Font.GothamMedium; SearchBox.BackgroundColor3 = GLASS_THEME.Header; SearchBox.ZIndex = 301
local SC = Instance.new("UICorner"); SC.CornerRadius = UDim.new(0, 6); SC.Parent = SearchBox
​local ActionHeader = Instance.new("Frame"); ActionHeader.Parent = DropList; ActionHeader.Position = UDim2.new(0, 8, 0, 44); ActionHeader.Size = UDim2.new(1, -16, 0, 28); ActionHeader.BackgroundTransparency = 1; ActionHeader.ZIndex = 301
​local BtnSelAll = Instance.new("TextButton"); BtnSelAll.Parent = ActionHeader; BtnSelAll.Size = UDim2.new(0.48, 0, 1, 0); BtnSelAll.Position = UDim2.new(0, 0, 0, 0); BtnSelAll.Text = "✅ Select All"; BtnSelAll.TextColor3 = GLASS_THEME.Acc1; BtnSelAll.Font = Enum.Font.GothamBold; BtnSelAll.TextSize = 11; BtnSelAll.BackgroundColor3 = GLASS_THEME.Card; BtnSelAll.ZIndex = 301
local SAC = Instance.new("UICorner"); SAC.CornerRadius = UDim.new(0, 5); SAC.Parent = BtnSelAll
​local BtnClrAll = Instance.new("TextButton"); BtnClrAll.Parent = ActionHeader; BtnClrAll.Size = UDim2.new(0.48, 0, 1, 0); BtnClrAll.Position = UDim2.new(0.52, 0, 0, 0); BtnClrAll.Text = "✕ Clear All"; BtnClrAll.TextColor3 = Color3.fromRGB(239, 68, 68); BtnClrAll.Font = Enum.Font.GothamBold; BtnClrAll.TextSize = 11; BtnClrAll.BackgroundColor3 = GLASS_THEME.Card; BtnClrAll.ZIndex = 301
local CAC = Instance.new("UICorner"); CAC.CornerRadius = UDim.new(0, 5); CAC.Parent = BtnClrAll
​local ScrollOpts = Instance.new("ScrollingFrame"); ScrollOpts.Parent = DropList; ScrollOpts.Position = UDim2.new(0, 8, 0, isMulti and 76 or 46); ScrollOpts.Size = UDim2.new(1, -16, 1, isMulti and -82 or -52); ScrollOpts.BackgroundTransparency = 1; ScrollOpts.ScrollBarThickness = 5; ScrollOpts.ZIndex = 301; ScrollOpts.AutomaticCanvasSize = Enum.AutomaticSize.Y; ScrollOpts.CanvasSize = UDim2.new(0,0,0,0)
local DLL = Instance.new("UIListLayout"); DLL.Parent = ScrollOpts; DLL.Padding = UDim.new(0, 4)
​if not isMulti then ActionHeader.Visible = false end
​local function UpdatePos()
if DropList.Visible then DropList.Position = UDim2.new(0, Btn.AbsolutePosition.X - MainFrame.AbsolutePosition.X, 0, (Btn.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y) + Btn.AbsoluteSize.Y + 3) end
end
Btn:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos)
​local updateCheckList = {}
local function updateMainBtn()
if isMulti then
local count = #(F[flag] or {})
Btn.Text = count > 0 and (count .. " Terpilih") or "Pilih Multi..."
else
Btn.Text = tostring(F[flag] or "Pilih")
end
end
table.insert(ConfigUpdaters, updateMainBtn)
​local function Render(filterText)
filterText = string.lower(filterText or "")
for _, v in pairs(ScrollOpts:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
​for _, opt in ipairs(options) do
if filterText == "" or string.find(string.lower(opt.label), filterText) then
local OptBtn = Instance.new("TextButton"); OptBtn.Parent = ScrollOpts; OptBtn.Size = UDim2.new(1, 0, 0, 36); OptBtn.Text = "  " .. tostring(opt.label); OptBtn.TextColor3 = GLASS_THEME.Text; OptBtn.TextSize = 11; OptBtn.Font = Enum.Font.GothamMedium; OptBtn.TextXAlignment = Enum.TextXAlignment.Left; OptBtn.BackgroundColor3 = GLASS_THEME.Card; OptBtn.BackgroundTransparency = 0.5; OptBtn.ZIndex = 302
local OC = Instance.new("UICorner"); OC.CornerRadius = UDim.new(0, 6); OC.Parent = OptBtn
​local check = Instance.new("Frame"); check.Parent = OptBtn; check.Size = UDim2.new(0, 18, 0, 18); check.Position = UDim2.new(1, -26, 0.5, -9); local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 4); cc.Parent = check; check.ZIndex = 302
​local function updateVisuals()
local sel = false
if isMulti then for _,v in ipairs(F[flag] or {}) do if v==opt.val then sel=true break end end else sel=(F[flag]==opt.val) end
check.BackgroundColor3 = sel and GLASS_THEME.Acc1 or Color3.fromRGB(30, 41, 59)
end
table.insert(updateCheckList, updateVisuals)
updateVisuals()
​OptBtn.MouseButton1Click:Connect(function()
if isMulti then
if not F[flag] then F[flag] = {} end
local found = false; for i,v in ipairs(F[flag]) do if v==opt.val then table.remove(F[flag],i); found=true break end end
if not found then table.insert(F[flag], opt.val) end
else F[flag] = opt.val; DropList.Visible = false end
updateMainBtn()
for _, fn in ipairs(updateCheckList) do pcall(fn) end
end)
end
end
end
​Render("")
updateMainBtn()
SearchBox:GetPropertyChangedSignal("Text"):Connect(function() Render(SearchBox.Text) end)
BtnSelAll.MouseButton1Click:Connect(function()
if isMulti then F[flag] = {}; for _, opt in ipairs(options) do table.insert(F[flag], opt.val) end; updateMainBtn(); for _, fn in ipairs(updateCheckList) do pcall(fn) end end
end)
BtnClrAll.MouseButton1Click:Connect(function()
if isMulti then F[flag] = {}; updateMainBtn(); for _, fn in ipairs(updateCheckList) do pcall(fn) end end
end)
Btn.MouseButton1Click:Connect(function() DropList.Visible = not DropList.Visible; UpdatePos() end)
end
​-- Dynamic Options Generator
local function GetOpts(mode)
local t = {};
if mode == "rarity" then
local foundRarities = {}
pcall(function()
if G.EntryRegistry and G.EntryRegistry.getEntries then
for _, entry in pairs(G.EntryRegistry.getEntries()) do
if entry and entry.rarity and not foundRarities[entry.rarity] then
foundRarities[entry.rarity] = true
table.insert(t, {label = tostring(entry.rarity), val = tostring(entry.rarity)})
end
end
end
end)
local defaultRarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Divine", "Godly"}
for _, rName in ipairs(defaultRarities) do if not foundRarities[rName] then table.insert(t, {label = rName, val = rName}) end end
table.sort(t, function(a,b) return a.label < b.label end)
elseif mode == "grade" and G.GradesMod then for n, g in pairs(G.GradesMod) do if type(g)"table" and g.order then table.insert(t, {label=n, val=n, order=g.order}) end end; table.sort(t, function(a,b) return a.order<b.order end)
elseif mode == "trait" and G.TraitsMod then for n, g in pairs(G.TraitsMod) do if type(g)"table" and g.order then table.insert(t, {label=n, val=n, order=g.order}) end end; table.sort(t, function(a,b) return a.order<b.order end)
elseif mode == "quirk" and G.QuirksMod then for n, q in pairs(G.QuirksMod) do if type(q)=="table" then table.insert(t, {label=n, val=n}) end end; table.sort(t, function(a,b) return a.label<b.label end)
elseif mode == "pot" and G.BoostConfig then for n, e in pairs(G.BoostConfig.entries or {}) do table.insert(t, {label=n.." [T"..tostring(e.tier)..']', val=n}) end; table.sort(t, function(a,b) return a.label<b.label end)
elseif mode == "unit" then
local placed = {}; pcall(function() for _, d in pairs(slots()) do if d.unitId then placed[d.unitId]=true end end end)
for k, e in pairs(inventory()) do
if isUnitEntry(e) then
local lvlNum = (e.attributes and tonumber(e.attributes.level)) or 1
local inc = FormatMoney(baseIncome(e))
local labelStr = string.format("%s [Lv.%d | 💰$%s/s]%s", tostring(e.name), lvlNum, inc, placed[k] and " ★" or "")
table.insert(t, {label=labelStr, val=k, inc=baseIncome(e)})
end
end
table.sort(t, function(a,b) return a.inc > b.inc end)
elseif mode == "unit_name" then
local addedNames = {}
for _, e in pairs(inventory()) do
if isUnitEntry(e) and e.name and not addedNames[e.name] then addedNames[e.name] = true; table.insert(t, {label = e.name, val = e.name}) end
end
table.sort(t, function(a,b) return a.label < b.label end)
elseif mode == "towers" then
local addedTowers = {}
pcall(function()
local all = G.TowersConfig and G.TowersConfig.GetAll and G.TowersConfig.GetAll()
if type(all) == "table" then for name in pairs(all) do addedTowers[name] = true; table.insert(t, {label=name, val=name}) end end
end)
local defaultTowers = {"Dragon Tower", "Demon Tower", "Ninja Tower", "Pirate Tower", "Hunter Tower", "Cursed Tower", "Halloween Tower", "Haunted Front Yard", "Haunted Crypt", "Haunted Attic", "Haunted Bell Tower"}
for _, name in ipairs(defaultTowers) do if not addedTowers[name] then table.insert(t, {label=name, val=name}) end end
table.sort(t, function(a,b) return a.label < b.label end)
end
return t
end
​-- ===================================================================== --
-- 5. TABS ASSEMBLY
-- ===================================================================== --
local T_Dash = CreateTab("Dashboard AI", "🧠")
local T_Farm = CreateTab("Farming", "⛏️")
local T_Hlw  = CreateTab("Halloween", "🎃")
local T_Inv  = CreateTab("Inventory", "🎒")
local T_Pot  = CreateTab("Potions", "🧪")
local T_Qrk  = CreateTab("Quirk & Roll", "⚡")
local T_Grd  = CreateTab("Grade & Roll", "⭐")
local T_Trt  = CreateTab("Trait & Roll", "🧬")
local T_Twr  = CreateTab("Tower Utama", "🏰")
local T_Set  = CreateTab("Settings AI", "⚙️")
​TabFrames["Dashboard AI"].Visible = true; Sidebar:GetChildren()[2].BackgroundTransparency = 0.1; Sidebar:GetChildren()[2].TextColor3 = GLASS_THEME.Acc1
​-- DASHBOARD AI TAB
local G_AI = AddGroup(T_Dash, "🧠 EXTREME SMART PLANNER & TELEMETRY CONSOLE")
local AILbl = Instance.new("TextLabel"); AILbl.Parent = G_AI; AILbl.Size = UDim2.new(1,0,0,135); AILbl.BackgroundTransparency = 1; AILbl.TextColor3 = GLASS_THEME.Text; AILbl.TextSize = 13; AILbl.Font = Enum.Font.Code; AILbl.TextXAlignment = Enum.TextXAlignment.Left; AILbl.TextYAlignment = Enum.TextYAlignment.Top
​local G_Profile = AddGroup(T_Dash, "PROFIL & STATISTIK REAL-TIME")
local ProfContainer = Instance.new("Frame"); ProfContainer.Parent = G_Profile; ProfContainer.Size = UDim2.new(1, 0, 0, 95); ProfContainer.BackgroundTransparency = 1
local PImg = Instance.new("ImageLabel"); PImg.Parent = ProfContainer; PImg.AnchorPoint = Vector2.new(0, 0.5); PImg.Position = UDim2.new(0, 8, 0.5, 0); PImg.Size = UDim2.new(0, 76, 0, 76); pcall(function() PImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end); local PImgC = Instance.new("UICorner"); PImgC.CornerRadius = UDim.new(1,0); PImgC.Parent = PImg; local PStr = Instance.new("UIStroke"); PStr.Thickness = 2; PStr.Color = GLASS_THEME.Acc1; PStr.Parent = PImg
local PLbl = Instance.new("TextLabel"); PLbl.Parent = ProfContainer; PLbl.Position = UDim2.new(0, 98, 0, 0); PLbl.Size = UDim2.new(1, -108, 1, 0); PLbl.BackgroundTransparency = 1; PLbl.TextColor3 = GLASS_THEME.Text; PLbl.TextSize = 13; PLbl.Font = Enum.Font.GothamMedium; PLbl.TextXAlignment = Enum.TextXAlignment.Left; PLbl.TextYAlignment = Enum.TextYAlignment.Center
​task.spawn(function()
local lastTime = os.clock(); local frameCount = 0
RunService.RenderStepped:Connect(function()
frameCount = frameCount + 1
local now = os.clock()
if now - lastTime >= 1 then STATE.fpsCurrent = frameCount; frameCount = 0; lastTime = now end
end)
​while task.wait(0.5) do pcall(function()
STATE.pingMs = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() or 0)
local m = money(); local rb = rebirthAmt(); local rls = G.DC.Rolls() or 0
PLbl.Text = string.format("👤 Player: %s\n💰 Money: %s | ⭐ Level: %d\n🔄 Rebirth: %s | 🎲 Rolls: %s\n⚡ Ping: %d ms | 🖥️ FPS: %d", LocalPlayer.Name, FormatMoney(m), level(), tostring(rb), tostring(rls), STATE.pingMs, STATE.fpsCurrent)
​AILbl.Text = string.format(
"🤖 AI Master State: %s\n📊 Diagnostic Health: %.1f%%\n🚨 Remote Errors Logged: %d\n\n🎯 AI Decision Directive:\n➤ %s",
F.smartPlannerActive and "ONLINE (Active P1-P7)" else "PAUSED",
DiagnosticEngine:GetHealthScore(), DiagnosticEngine.ErrorCount, STATE.aiDecision
)
end) end
end)
​-- FARMING TAB
local G_FarmAI = AddGroup(T_Farm, "🤖 SMART PLANNER MASTER SWITCH")
AddToggle(G_FarmAI, "Aktifkan Smart Planner Extreme (Autonomous AI)", "smartPlannerActive")
​local G_Farm1 = AddGroup(T_Farm, "PLOT, ROLL & REBIRTH AUTOMATION")
AddToggle(G_Farm1, "Auto Collect Plot Balance", "collect")
AddToggle(G_Farm1, "Auto Roll Dadu (Otomatis)", "autoRoll")
AddToggle(G_Farm1, "Auto Smart Place Unit Terbaik (Inventory -> Base)", "autoBestPlaceBase")
AddToggle(G_Farm1, "Auto Rebirth (Anti-Spam Delay)", "rebirth")
AddToggle(G_Farm1, "Auto Buy & Equip Best Dice Shop", "buyDice")
​local G_Farm2 = AddGroup(T_Farm, "LEVELING & SKILL TREE UPGRADES")
AddToggle(G_Farm2, "Auto Level Up Unit Plot", "levelup")
AddInput(G_Farm2, "Max Level Unit Batas:", "maxLevel", true)
AddToggle(G_Farm2, "Auto Upgrade Skill Tree Pad", "upgrades")
​-- HALLOWEEN TAB
local G_HlwTeleport = AddGroup(T_Hlw, "HALLOWEEN WORLD & INTRO")
AddToggle(G_HlwTeleport, "Auto Teleport Ke Halloween World", "halloweenTeleport")
​local G_HlwRoll = AddGroup(T_Hlw, "PUMPKIN DICE & SPECIFIC AUTO SELL")
AddDropdown(G_HlwRoll, "Kuantitas Pumpkin Roll:", {{label="Roll 1x", val=1}, {label="Roll 5x", val=5}}, "pumpkinRollQty", false)
AddToggle(G_HlwRoll, "Auto Roll Pumpkin Dice", "pumpkinAutoRoll")
AddToggle(G_HlwRoll, "Auto Sell Pumpkin Units (Server)", "pumpkinAutoSell")
AddDropdown(G_HlwRoll, "Nama Unit Spesifik Auto Sell:", GetOpts("unit_name"), "specificSellUnits", true)
​local G_HlwQuests = AddGroup(T_Hlw, "HALLOWEEN REWARDS & EVENT")
AddToggle(G_HlwQuests, "Auto Claim Halloween Quests", "halloweenQuest")
AddToggle(G_HlwQuests, "Auto Claim Halloween Path Rewards", "halloweenPath")
AddToggle(G_HlwQuests, "Auto Buy Halloween Special Offers", "halloweenOffer")
AddToggle(G_HlwQuests, "Auto Trick or Treat (Knock Doors)", "trickOrTreat")
​local G_HauntedTwr = AddGroup(T_Hlw, "HAUNTED TOWER FARMING (FIXED)")
AddToggle(G_HauntedTwr, "Auto Haunted Tower Farming", "hauntedTower")
AddToggle(G_HauntedTwr, "Mode MIX / Random Haunted Tower", "hauntedMix")
AddDropdown(G_HauntedTwr, "Pilih Haunted Tower (Multi-Select):", {
{label="Haunted Front Yard", val="Haunted Front Yard"},
{label="Haunted Crypt", val="Haunted Crypt"},
{label="Haunted Attic", val="Haunted Attic"},
{label="Haunted Bell Tower", val="Haunted Bell Tower"}
}, "hauntedList", true)
AddToggle(G_HauntedTwr, "Auto Equip Best Team Tower", "hauntedEquipBest")
AddToggle(G_HauntedTwr, "Keluar di Lantai Tertentu", "hauntedExitOn")
AddInput(G_HauntedTwr, "Batas Lantai Exit Haunted:", "hauntedExitFloor", true)
​local G_HauntedMon = AddGroup(T_Hlw, "LIVE MONITORING HAUNTED TOWER")
local HauntedLbl = Instance.new("TextLabel"); HauntedLbl.Parent = G_HauntedMon; HauntedLbl.Size = UDim2.new(1,0,0,70); HauntedLbl.BackgroundTransparency = 1; HauntedLbl.TextColor3 = GLASS_THEME.Text; HauntedLbl.TextSize = 13; HauntedLbl.Font = Enum.Font.GothamMedium; HauntedLbl.TextXAlignment = Enum.TextXAlignment.Left; HauntedLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function() while task.wait(0.5) do pcall(function() HauntedLbl.Text = string.format("🎃 Status: %s\n🏢 Lantai: %d | 🍬 Total Drops/Item: %d", STATE.hauntedLive, STATE.hauntedFloor, STATE.hauntedDrops) end) end end)
​-- INVENTORY TAB
local G_Inv = AddGroup(T_Inv, "MANAGEMENT, RARITY KEEP & AUTO LOCK")
AddToggle(G_Inv, "Auto Sell General (Jual Rarity Tidak Dicentang)", "sellAuto")
AddToggle(G_Inv, "Auto Sell Saat Inventory Penuh (Max Capacity)", "sellMaxInvent")
AddInput(G_Inv, "Simpan Unit Terbaik (Keep Best Income):", "keepBest", true)
AddDropdown(G_Inv, "Pilih Rarity yang Disimpan (Keep Rarity):", GetOpts("rarity"), "keepRarities", true)
AddToggle(G_Inv, "Auto Lock Unit Berdasarkan Rarity Terpilih", "autoLockRarity")
AddToggle(G_Inv, "Auto Fusion Unit", "autoFuse")
​-- POTIONS TAB
local G_Pot = AddGroup(T_Pot, "SMART POTION MANAGER")
AddToggle(G_Pot, "Auto Gunakan Potion", "potionAuto")
AddDropdown(G_Pot, "Pilih Potion Spesifik (Multi-Select):", GetOpts("pot"), "potionSpecific", true)
​-- QUIRK TAB
local G_QrkCtrl = AddGroup(T_Qrk, "AUTO LOCK & QUIRK REROLL CONFIG")
AddToggle(G_QrkCtrl, "Auto Lock Unit jika Quirk Target Didapat", "autoLockTarget")
AddToggle(G_QrkCtrl, "Aktifkan Auto Quirk Reroll", "quirkAuto")
AddDropdown(G_QrkCtrl, "Target Quirk (Multi-Select):", GetOpts("quirk"), "quirkTargets", true)
AddDropdown(G_QrkCtrl, "Pilih Unit Reroll Quirk (Realtime Income):", GetOpts("unit"), "quirkUnits", true)
​local G_QrkMon = AddGroup(T_Qrk, "⚡ REALTIME MONITORING QUIRK")
local QrkLbl = Instance.new("TextLabel"); QrkLbl.Parent = G_QrkMon; QrkLbl.Size = UDim2.new(1,0,0,85); QrkLbl.BackgroundTransparency = 1; QrkLbl.TextColor3 = GLASS_THEME.Text; QrkLbl.TextSize = 13; QrkLbl.Font = Enum.Font.GothamMedium; QrkLbl.TextXAlignment = Enum.TextXAlignment.Left; QrkLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function() while task.wait(0.3) do pcall(function() QrkLbl.Text = string.format("🎯 Unit Aktif: %s\n⚡ Quirk Saat Ini: %s\n📊 Log Roll: %s", STATE.quirkActiveUnit, STATE.quirkCurrentVal, STATE.quirkStatus) end) end end)
​-- GRADE TAB
local G_GrdCtrl = AddGroup(T_Grd, "AUTO GRADE REROLL CONFIG")
AddToggle(G_GrdCtrl, "Aktifkan Auto Grade Reroll", "gradeAuto")
AddToggle(G_GrdCtrl, "Hanya Unit di Base (Placed)", "gradePlacedOnly")
AddDropdown(G_GrdCtrl, "Target Grade (Multi-Select):", GetOpts("grade"), "gradeTargets", true)
AddDropdown(G_GrdCtrl, "Pilih Unit Reroll Grade (Realtime Income):", GetOpts("unit"), "gradeUnits", true)
AddInput(G_GrdCtrl, "Sisakan Gems Minimum:", "gemReserve", true)
​local G_GrdMon = AddGroup(T_Grd, "⭐ REALTIME MONITORING GRADE")
local GrdLbl = Instance.new("TextLabel"); GrdLbl.Parent = G_GrdMon; GrdLbl.Size = UDim2.new(1,0,0,85); GrdLbl.BackgroundTransparency = 1; GrdLbl.TextColor3 = GLASS_THEME.Text; GrdLbl.TextSize = 13; GrdLbl.Font = Enum.Font.GothamMedium; GrdLbl.TextXAlignment = Enum.TextXAlignment.Left; GrdLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function() while task.wait(0.3) do pcall(function() GrdLbl.Text = string.format("🎯 Unit Aktif: %s\n🌟 Grade Saat Ini: %s\n📊 Log Roll: %s", STATE.gradeActiveUnit, STATE.gradeCurrentVal, STATE.gradeStatus) end) end end)
​-- TRAIT TAB
local G_TrtCtrl = AddGroup(T_Trt, "AUTO TRAIT REROLL CONFIG")
AddToggle(G_TrtCtrl, "Aktifkan Auto Trait Reroll", "traitAuto")
AddToggle(G_TrtCtrl, "Hanya Unit di Base (Placed)", "traitPlacedOnly")
AddDropdown(G_TrtCtrl, "Target Trait (Multi-Select):", GetOpts("trait"), "traitTargets", true)
AddDropdown(G_TrtCtrl, "Pilih Unit Reroll Trait (Realtime Income):", GetOpts("unit"), "traitUnits", true)
AddInput(G_TrtCtrl, "Sisakan Trait Reroll Minimum:", "rerollReserve", true)
​local G_TrtMon = AddGroup(T_Trt, "🧬 REALTIME MONITORING TRAIT")
local TrtLbl = Instance.new("TextLabel"); TrtLbl.Parent = G_TrtMon; TrtLbl.Size = UDim2.new(1,0,0,85); TrtLbl.BackgroundTransparency = 1; TrtLbl.TextColor3 = GLASS_THEME.Text; TrtLbl.TextSize = 13; TrtLbl.Font = Enum.Font.GothamMedium; TrtLbl.TextXAlignment = Enum.TextXAlignment.Left; TrtLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function() while task.wait(0.3) do pcall(function() TrtLbl.Text = string.format("🎯 Unit Aktif: %s\n🧬 Trait Saat Ini: %s\n📊 Log Roll: %s", STATE.traitActiveUnit, STATE.traitCurrentVal, STATE.traitStatus) end) end end)
​-- MAIN TOWER TAB
local G_Twr = AddGroup(T_Twr, "MAIN TOWER FARMING SETUP")
AddToggle(G_Twr, "Auto Main Tower Farming", "tower")
AddToggle(G_Twr, "Mode MIX / Random Tower (Acak Terpilih)", "towerMix")
AddDropdown(G_Twr, "Pilih Main Tower (Multi-Select):", GetOpts("towers"), "towerList", true)
AddToggle(G_Twr, "Auto Equip Best Team Tower", "towerEquipBest")
AddToggle(G_Twr, "Keluar di Lantai Tertentu", "towerExitOn")
AddInput(G_Twr, "Batas Lantai Exit Tower:", "towerExitFloor", true)
​local G_TwrMon = AddGroup(T_Twr, "LIVE TOWER MONITORING & TRAIT DROPS")
local TwrLbl = Instance.new("TextLabel"); TwrLbl.Parent = G_TwrMon; TwrLbl.Size = UDim2.new(1,0,0,70); TwrLbl.BackgroundTransparency = 1; TwrLbl.TextColor3 = GLASS_THEME.Text; TwrLbl.TextSize = 13; TwrLbl.Font = Enum.Font.GothamMedium; TwrLbl.TextXAlignment = Enum.TextXAlignment.Left; TwrLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function() while task.wait(0.5) do pcall(function() TwrLbl.Text = string.format("🎮 Status: %s\n🏢 Lantai: %d | 💎 Gems Didapat: %d\n🧬 Trait Drops: %s", STATE.towerLive, STATE.towerFloor, STATE.towerDrops, tostring(STATE.towerTraitsGot)) end) end end)
​-- SETTINGS TAB
local G_SetConfig = AddGroup(T_Set, "FILE CONFIG MANAGEMENT")
AddToggle(G_SetConfig, "Auto Load Config Saat Nyala", "autoLoadEnabled")
AddInput(G_SetConfig, "Nama File Config:", "cfgName", false)
​local BtnSave = Instance.new("TextButton"); BtnSave.Parent = G_SetConfig; BtnSave.Size = UDim2.new(1, 0, 0, 36); BtnSave.Text = "💾 SAVE CONFIG SEKARANG"; BtnSave.Font = Enum.Font.GothamBold; BtnSave.TextSize = 13; BtnSave.TextColor3 = GLASS_THEME.Acc1; BtnSave.BackgroundColor3 = GLASS_THEME.Header; local BTS = Instance.new("UICorner"); BTS.CornerRadius = UDim.new(0,8); BTS.Parent = BtnSave
BtnSave.MouseButton1Click:Connect(function() pcall(function() saveConfig(F.cfgName); Notify("Config Saved", "Berhasil disimpan: " .. tostring(F.cfgName)) end) end)
​local BtnLoad = Instance.new("TextButton"); BtnLoad.Parent = G_SetConfig; BtnLoad.Size = UDim2.new(1, 0, 0, 36); BtnLoad.Text = "📂 LOAD CONFIG PILIHAN"; BtnLoad.Font = Enum.Font.GothamBold; BtnLoad.TextSize = 13; BtnLoad.TextColor3 = GLASS_THEME.Acc1; BtnLoad.BackgroundColor3 = GLASS_THEME.Header; local BTL = Instance.new("UICorner"); BTL.CornerRadius = UDim.new(0,8); BTL.Parent = BtnLoad
BtnLoad.MouseButton1Click:Connect(function() pcall(function() loadConfig(F.cfgName); Notify("Config Loaded", "Berhasil dimuat: " .. tostring(F.cfgName)) end) end)
​local G_Web = AddGroup(T_Set, "DISCORD WEBHOOK NOTIFIER")
AddToggle(G_Web, "Aktifkan Webhook Discord", "webhookEnabled")
AddInput(G_Web, "Webhook URL:", "webhookUrl", false)
local BtnTestWeb = Instance.new("TextButton"); BtnTestWeb.Parent = G_Web; BtnTestWeb.Size = UDim2.new(1, 0, 0, 34); BtnTestWeb.Text = "🔔 TEST KIRIM WEBHOOK"; BtnTestWeb.Font = Enum.Font.GothamBold; BtnTestWeb.TextSize = 12; BtnTestWeb.TextColor3 = GLASS_THEME.Acc1; BtnTestWeb.BackgroundColor3 = GLASS_THEME.Header; local BTWC = Instance.new("UICorner"); BTWC.CornerRadius = UDim.new(0,8); BTWC.Parent = BtnTestWeb
BtnTestWeb.MouseButton1Click:Connect(function() SendWebhook("✅ Webhook Connected!", "MofenkHub V115.0 Extreme tersambung sukses.", 3447003); Notify("Webhook", "Test webhook dikirim.") end)
​local G_Set2 = AddGroup(T_Set, "OPTIMALISASI & DISCONNECT PROTECTION")
AddToggle(G_Set2, "Anti-AFK Protection (Prevent Disconnect)", "afk")
AddToggle(G_Set2, "FPS Boost (Optimasi Map Partikel)", "fpsOn", function(v) if v then pcall(function() game:GetService("Lighting").GlobalShadows = false; for _,e in ipairs(workspace:GetDescendants()) do if e:IsA("BasePart") then e.Material = Enum.Material.SmoothPlastic end end end) end end)
AddToggle(G_Set2, "Auto Claim Quests & Daily Rewards", "claimQuests")
AddToggle(G_Set2, "Auto Redeem Codes", "codesAuto")
​local BtnHop = Instance.new("TextButton"); BtnHop.Parent = G_Set2; BtnHop.Size = UDim2.new(1, 0, 0, 38); BtnHop.Text = "🌐 SERVER HOP (PINDAH SERVER)"; BtnHop.Font = Enum.Font.GothamBlack; BtnHop.TextSize = 13; BtnHop.TextColor3 = GLASS_THEME.Acc1; BtnHop.BackgroundColor3 = GLASS_THEME.Header; local BTH = Instance.new("UICorner"); BTH.CornerRadius = UDim.new(0,8); BTH.Parent = BtnHop
BtnHop.MouseButton1Click:Connect(function()
pcall(function()
local cursor = ""; local servers = {}
repeat
local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
local success, result = pcall(function() return HttpService:JSONEncode(game:HttpGet(url)) end)
if success and result and result.data then
for _, s in ipairs(result.data) do if type(s) == "table" and s.playing and s.maxPlayers and s.playing < s.maxPlayers and s.id ~= game.JobId then table.insert(servers, s.id) end end
cursor = result.nextPageCursor or ""
else break end
until #servers > 10 or cursor == ""
if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer) else TeleportService:Teleport(game.PlaceId, LocalPlayer) end
end)
end)
​-- ===================================================================== --
-- 6. CORVUS PRIORITY QUEUE & EXTREME SMART PLANNER BACKEND
-- ===================================================================== --
local CorvusPlanner = { IsBusy = false, TaskQueue = {}, Priority = { CRITICAL = 1, EVENT = 2, POTION = 3, PROGRESS = 4, OPTIMIZE = 5, TOWER = 6, FARM = 7 } }
​function CorvusPlanner:AddTask(id, prio, act, desc)
for _, t in ipairs(self.TaskQueue) do if t.Id == id then return end end
table.insert(self.TaskQueue, { Id = id, Priority = prio, Action = act, Desc = desc })
table.sort(self.TaskQueue, function(a, b) return a.Priority < b.Priority end)
end
​function CorvusPlanner:EvaluateEnvironment()
if not F.smartPlannerActive then return end
​-- [P1] CRITICAL: INVENTORY MANAGEMENT & AUTO LOCK
local inv = inventory()
local totalUnits = 0; for _ in pairs(inv) do totalUnits += 1 end
if totalUnits >= 80 and F.sellAuto and R.SellInventory then
self:AddTask("CLEAR_INV", self.Priority.CRITICAL, function()
STATE.aiDecision = "P1: Membersihkan Inventory Penuh & Auto Sell"
local sellList = {}
local placed = {}
for _, s in pairs(slots()) do if s.unitId then placed[s.unitId] = true end end
for _, id in pairs(data().TowerTeam or {}) do placed[id] = true end
​for id, u in pairs(inv) do
if isUnitEntry(u) and not placed[id] and not isBeingRolled(id) then
local rarity = getUnitRarity(u)
local isKeep = false
for _, kr in ipairs(F.keepRarities) do if string.lower(rarity) == string.lower(kr) then isKeep = true break end end
if not isKeep then table.insert(sellList, id) end
end
end
if #sellList > 0 then
DiagnosticEngine:SafeExecute("SellExec", function() R.SellInventory:InvokeServer(sellList) end)
end
if F.autoFuse and R.Fuse then DiagnosticEngine:SafeExecute("FuseExec", function() R.Fuse:FireServer() end) end
task.wait(1)
end, "Auto Sell & Fuse")
end
​-- [P2] EVENT: HALLOWEEN
if F.halloweenTeleport then
self:AddTask("EVENT_HW", self.Priority.EVENT, function()
STATE.aiDecision = "P2: Memproses Event Halloween & Trick or Treat"
if R.HWTeleport then DiagnosticEngine:SafeExecute("HWTP", function() R.HWTeleport:InvokeServer() end) end
if R.HWSeenIntro then DiagnosticEngine:SafeExecute("HWIntro", function() R.HWSeenIntro:FireServer() end) end
if F.halloweenQuest and R.HWQuestClaim then DiagnosticEngine:SafeExecute("HWQ", function() R.HWQuestClaim:FireServer() end) end
if F.halloweenPath and R.HWClaimPath then DiagnosticEngine:SafeExecute("HWP", function() R.HWClaimPath:FireServer() end) end
if F.trickOrTreat and R.TrickOrTreat then DiagnosticEngine:SafeExecute("ToT", function() R.TrickOrTreat:FireServer() end) end
if F.pumpkinAutoRoll and R.PumpkinRoll then
for i = 1, (tonumber(F.pumpkinRollQty) or 1) do
DiagnosticEngine:SafeExecute("PRoll", function()
if R.PumpkinRoll:IsA("RemoteFunction") then R.PumpkinRoll:InvokeServer() else R.PumpkinRoll:FireServer() end
end)
task.wait(0.2)
end
end
task.wait(1)
end, "Halloween Tasks")
end
​-- [P3] SMART POTIONS
if F.potionAuto and R.BoostUse then
self:AddTask("SMART_POTION", self.Priority.POTION, function()
STATE.aiDecision = "P3: Validasi Buff Aktif & Mengaktifkan Potion"
local active = G.BuffController and G.BuffController.ActiveBuffs or {}
for key, e in pairs(inv) do
if e.name and (e.amount or 0) > 0 and G.BoostConfig and G.BoostConfig.entries[e.name] then
local shouldUse = (#F.potionSpecific == 0)
for _, sn in ipairs(F.potionSpecific) do if e.name == sn then shouldUse = true break end end
if shouldUse and not active[e.name] then
DiagnosticEngine:SafeExecute("UsePot", function() R.BoostUse:FireServer(key) end)
task.wait(0.5)
end
end
end
task.wait(1)
end, "Auto Potion")
end
​-- [P4] PROGRESSION: REBIRTH & UPGRADES
if F.rebirth and R.Rebirth then
local nr = G.Rebirths and G.Rebirths.GetNext(rebirthAmt())
if nr and money() >= (nr.cost or 9e9) then
self:AddTask("REBIRTH", self.Priority.PROGRESS, function()
STATE.aiDecision = "P4: Syarat Rebirth Terpenuhi! Eksekusi Rebirth"
DiagnosticEngine:SafeExecute("RebirthExec", function() R.Rebirth:FireServer() end)
task.wait(1.5)
end, "Account Rebirth")
end
end
​-- [P5] OPTIMIZATION: TOWER & REROLL
if F.tower and R.PlayTower then
self:AddTask("TOWER_PUSH", self.Priority.TOWER, function()
STATE.aiDecision = "P6: Menjalankan Autonomous Tower Push"
if F.towerEquipBest and R.BestTowerTeam then DiagnosticEngine:SafeExecute("EqTower", function() R.BestTowerTeam:FireServer() end) end
task.wait(0.3)
local pickTower = (F.towerList and #F.towerList > 0) and F.towerList[math.random(1, #F.towerList)] or "Dragon Tower"
STATE.towerLive = "Pushing: " .. pickTower
DiagnosticEngine:SafeExecute("PlayTwr", function()
if R.PlayTower:IsA("RemoteFunction") then R.PlayTower:InvokeServer(pickTower) else R.PlayTower:FireServer(pickTower) end
end)
task.wait(2)
end, "Tower Farming")
end
​-- [P7] BASELINE FARMING (ROLL & COLLECT)
self:AddTask("FARM", self.Priority.FARM, function()
STATE.aiDecision = "P7: Rutin Base Economy (Roll Dice & Collect Plot)"
if F.autoRoll and R.RollDice then
DiagnosticEngine:SafeExecute("Roll", function() R.RollDice:InvokeServer() end)
end
if F.collect and R.CollectBalance then
pcall(function() for _, s in ipairs(unlockedSlots()) do R.CollectBalance:FireServer(s) end end)
end
if F.autoBestPlaceBase and R.EquipUnit and R.InteractSlot then
-- Smart Place logic
pcall(function()
local n = #unlockedSlots()
local ranked = {}
for id, u in pairs(inv) do if isUnitEntry(u) then ranked[#ranked + 1] = { id = id, v = baseIncome(u) } end end
table.sort(ranked, function(a, b) return a.v > b.v end)
local want = {}
for i = 1, math.min(n, #ranked) do want[ranked[i].id] = ranked[i].v end
local placed = {}
for _, slot in pairs(slots()) do if slot.unitId then placed[slot.unitId] = true end end
for i = 1, math.min(n, #ranked) do
if not placed[ranked[i].id] then
local ok, eq = pcall(function() return R.EquipUnit:InvokeServer(ranked[i].id) end)
if ok and eq == true then task.wait(0.2); R.InteractSlot:FireServer(i) end
break
end
end
end)
end
task.wait(0.5)
end, "Baseline Farming")
end
​-- Start Corvus Scheduler Threads
task.spawn(function()
while gen == _G.__ANIMEDICE do
DiagnosticEngine:SafeExecute("AI_Eval", function() CorvusPlanner:EvaluateEnvironment() end)
task.wait(0.6)
end
end)
​task.spawn(function()
while gen == _G.__ANIMEDICE do
if not CorvusPlanner.IsBusy and #CorvusPlanner.TaskQueue > 0 then
local taskItem = table.remove(CorvusPlanner.TaskQueue, 1)
CorvusPlanner.IsBusy = true
DiagnosticEngine:SafeExecute("Task:"..taskItem.Id, taskItem.Action)
CorvusPlanner.IsBusy = false
end
task.wait(0.1)
end
end)
​-- ===================================================================== --
-- 7. INDEPENDENT REAL-TIME REROLL & AUTO-LOCK THREADS
-- ===================================================================== --
task.spawn(function()
while gen == _G.__ANIMEDICE do
if F.autoLockRarity and R.LockUnit then
pcall(function()
for id, u in pairs(inventory()) do
if isUnitEntry(u) and not isBeingRolled(id) then
local rarity = getUnitRarity(u)
local isKeep = false
for _, rName in ipairs(F.keepRarities or {}) do
if string.lower(tostring(rarity)) == string.lower(tostring(rName)) then isKeep = true; break end
end
local isLocked = u.attributes and u.attributes.locked
if isKeep and not isLocked then R.LockUnit:FireServer(id, true)
elseif not isKeep and isLocked then R.LockUnit:FireServer(id, false) end
end
end
end)
end
task.wait(3)
end
end)
​-- Quirk / Mutation Reroll
task.spawn(function()
while gen == _G.__ANIMEDICE do
if F.quirkAuto and R.QuirkRoll and #F.quirkUnits > 0 then
pcall(function()
local inv = inventory()
for _, unitId in ipairs(F.quirkUnits) do
local u = inv[unitId]
if u and u.attributes then
if R.LockUnit and not u.attributes.locked then R.LockUnit:FireServer(unitId, true) end
STATE.quirkActiveUnit = tostring(u.name)
local curQ = u.attributes.quirk or u.attributes.mutation or "None"
STATE.quirkCurrentVal = tostring(curQ)
local match = false
for _, tgt in ipairs(F.quirkTargets) do if string.lower(curQ) == string.lower(tgt) then match = true; break end end
if match then
STATE.quirkStatus = "✅ Target Didapat: " .. tostring(curQ)
SendWebhook("⚡ Quirk Matched!", "Berhasil mendapatkan Quirk " .. tostring(curQ) .. "", 65280)
else
STATE.quirkStatus = "Rolling... (" .. tostring(curQ) .. ")"
R.QuirkRoll:FireServer(unitId)
task.wait(0.4)
end
end
end
end)
else STATE.quirkStatus = "Standby" end
task.wait(0.5)
end
end)
​-- Grade Reroll
task.spawn(function()
while gen == _G.__ANIMEDICE do
if F.gradeAuto and R.GradeRoll and #F.gradeUnits > 0 then
pcall(function()
local inv = inventory()
for _, unitId in ipairs(F.gradeUnits) do
local u = inv[unitId]
if u and u.attributes and currencyAmount("Gems") > (F.gemReserve or 50) then
if R.LockUnit and not u.attributes.locked then R.LockUnit:FireServer(unitId, true) end
STATE.gradeActiveUnit = tostring(u.name)
local curG = u.attributes.grade or "None"
STATE.gradeCurrentVal = tostring(curG)
local match = false
for _, tgt in ipairs(F.gradeTargets) do if string.lower(curG) == string.lower(tgt) then match = true; break end end
if match then
STATE.gradeStatus = "✅ Target Didapat: " .. tostring(curG)
SendWebhook("⭐ Grade Matched!", "Berhasil mendapatkan Grade " .. tostring(curG) .. "", 65280)
else
STATE.gradeStatus = "Rolling... (" .. tostring(curG) .. ")"
R.GradeRoll:FireServer(unitId)
task.wait(0.4)
end
end
end
end)
else STATE.gradeStatus = "Standby" end
task.wait(0.5)
end
end)
​-- Trait Reroll
task.spawn(function()
while gen == _G.__ANIMEDICE do
if F.traitAuto and R.TraitRoll and #F.traitUnits > 0 then
pcall(function()
local inv = inventory()
for _, unitId in ipairs(F.traitUnits) do
local u = inv[unitId]
if u and u.attributes and currencyAmount("Trait Reroll") > (F.rerollReserve or 20) then
if R.LockUnit and not u.attributes.locked then R.LockUnit:FireServer(unitId, true) end
STATE.traitActiveUnit = tostring(u.name)
local curT = u.attributes.trait or "None"
STATE.traitCurrentVal = tostring(curT)
local match = false
for _, tgt in ipairs(F.traitTargets) do if string.lower(curT) == string.lower(tgt) then match = true; break end end
if match then
STATE.traitStatus = "✅ Target Didapat: " .. tostring(curT)
SendWebhook("🧬 Trait Matched!", "Berhasil mendapatkan Trait " .. tostring(curT) .. "", 65280)
else
STATE.traitStatus = "Rolling... (" .. tostring(curT) .. ")"
R.TraitRoll:FireServer(unitId)
task.wait(0.4)
end
end
end
end)
else STATE.traitStatus = "Standby" end
task.wait(0.5)
end
end)
​-- Anti-AFK & Disconnect Reconnect Protection
LocalPlayer.Idled:Connect(function()
if F.afk then
pcall(function()
local vu = game:GetService("VirtualUser")
vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
task.wait(1)
vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
end
end)
​Notify("MofenkHub V115.0 Extreme Ready!", "AI Smart Planner & Extreme Telemetry Engine Aktif.", 4)
AddSpyLog("MofenkHub V115.0 Loaded Successfully.")
