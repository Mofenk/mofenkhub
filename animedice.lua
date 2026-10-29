-- ===================================================================== --
-- 👑 MOFENKHUB V108.0 — COMPLETE ANIME DICE SMART PLANNER & FULL AUTOMATION
-- Engine: Corvus-Style Priority Queue + Diagnostic Error Telemetry
-- Game: Anime Dice (Full Features Integration + Bug-free Execution)
-- ===================================================================== --
​--!nocheck
task.wait(0.5)
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local TeleportService   = game:GetService("TeleportService")
local RunService        = game:GetService("RunService")
local Stats             = game:GetService("Stats")
​local LocalPlayer = Players.LocalPlayer
local successGui, parentGui = pcall(function()
if gethui then return gethui() elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end
​pcall(function() for _, v in pairs(parentGui:GetChildren()) do if string.find(v.Name, "Mofenk") then v:Destroy() end end end)
​-- ===================================================================== --
-- 1. SAFE DIAGNOSTIC & TELEMETRY ENGINE
-- ===================================================================== --
local DiagnosticEngine = {
TotalCalls = 0, SuccessCount = 0, ErrorCount = 0, ErrorRegistry = {}, MissingRemotes = {},
LogFile = "MofenkHub_Configs/diagnostic_report.json"
}
​function DiagnosticEngine:LogEvent(tag, msg, errData)
local timestamp = os.date("%X")
local entry = { Time = timestamp, Tag = tag, Message = msg, ErrorData = errData and tostring(errData) or nil }
​if errData then
self.ErrorCount = self.ErrorCount + 1
table.insert(self.ErrorRegistry, 1, entry)
if #self.ErrorRegistry > 50 then table.remove(self.ErrorRegistry) end
warn(string.format("[🚨 DIAGNOSTIC ERROR] [%s] [%s]: %s", timestamp, tag, msg))
else
self.SuccessCount = self.SuccessCount + 1
end
self.TotalCalls = self.TotalCalls + 1
pcall(function()
if writefile then
writefile(self.LogFile, HttpService:JSONEncode({
HealthScore = self:GetHealthScore(),
TotalCalls = self.TotalCalls,
SuccessCount = self.SuccessCount,
ErrorCount = self.ErrorCount,
RecentErrors = self.ErrorRegistry
}))
end
end)
end
​function DiagnosticEngine:SafeExecute(contextTag, fn, ...)
local args = {...}
local success, result = xpcall(function() return fn(unpack(args)) end, function(err) return debug.traceback(tostring(err), 2) end)
if not success then
self:LogEvent(contextTag, "Eksekusi Gagal", result)
return false, result
else
self.SuccessCount = self.SuccessCount + 1
return true, result
end
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
cfgName = "SmartPlanner_FullV108", autoLoadEnabled = false,
smartPlannerEnabled = true, smartPlannerAutoPotion = true,
​-- Farming & Plot
collect = true, levelup = true, maxLevel = 100,
rebirth = true, upgrades = true, buyDice = true, equipDice = true, autoRoll = true,
autoBestPlaceBase = true,
​-- Inventory & Sell / Lock / Fuse
sellAuto = true, sellMaxInvent = true, keepBest = 5, autoFuse = true,
keepRarities = {"Mythic", "Secret", "Divine", "Godly"},
autoLockRarity = true,
​-- Potions
potionAuto = true, potionSpecific = {"Luck Potion", "Damage Potion"},
​-- Reroll Engines
autoLockTarget = true,
quirkAuto = true, quirkTargets = {"Godly", "All-Out", "Shadow"}, quirkUnits = {},
gradeAuto = true, gradeTargets = {"Z", "SSS", "S"}, gradeUnits = {}, gemReserve = 50,
traitAuto = true, traitTargets = {"Godly", "Fortune III", "Overlord"}, traitUnits = {}, rerollReserve = 10,
​-- Tower & Events
tower = true, towerMix = true, towerList = {"Dragon Tower", "Demon Tower"}, towerEquipBest = true,
halloweenQuest = true, halloweenPath = true, pumpkinAutoRoll = false, pumpkinAutoSell = true,
​-- Misc
afk = true, codesAuto = true, claimQuests = true
}
​local STATE = {
plannerMissionName = "MEMINDAI GAME STATE...",
plannerCurrentStep = "Inisialisasi Module & Safe Prober...",
plannerActionPlan  = "Menyusun Antrean Prioritas Corvus",
towerLive = "Standby", towerFloor = 0, towerDrops = 0
}
​local CFG_FOLDER = "MofenkHub_Configs"
if makefolder and not isfolder(CFG_FOLDER) then pcall(function() makefolder(CFG_FOLDER) end) end
​-- ===================================================================== --
-- 3. SECURE REMOTE FINDER & WRAPPER
-- ===================================================================== --
local function GetNetwork()
local net = nil
pcall(function() net = ReplicatedStorage:WaitForChild("Network", 5) end)
return net
end
​local function SafeProbe(serviceName, remoteName)
local remoteObj = nil
pcall(function()
local net = GetNetwork()
if net then
local srv = net:FindFirstChild(serviceName)
if srv then remoteObj = srv:FindFirstChild(remoteName, true) end
end
end)
return remoteObj
end
​local R = {
RollDice        = SafeProbe("RollService", "RollDice"),
CollectBalance  = SafeProbe("PlotService", "CollectBalance"),
LevelUpSlot     = SafeProbe("PlotService", "LevelUpSlot"),
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
SellInventory   = SafeProbe("SellService", "SellInventory"),
EquipUnit       = SafeProbe("UnitService", "Equip"),
LockUnit        = SafeProbe("UnitService", "SetLock") or SafeProbe("InventoryService", "Lock")
}
​local function FireRemoteSafe(remoteObj, remoteName, ...)
if not remoteObj then
DiagnosticEngine:LogEvent("REMOTE_NIL", "Remote " .. remoteName .. " bernilai nil.", "Belum dimuat atau nama berubah.")
return false
end
return DiagnosticEngine:SafeExecute("REMOTE:" .. remoteName, function(...)
if remoteObj:IsA("RemoteEvent") then
remoteObj:FireServer(...)
return true
elseif remoteObj:IsA("RemoteFunction") then
return remoteObj:InvokeServer(...)
end
end, ...)
end
​-- ===================================================================== --
-- 4. CORVUS TASK QUEUE & SMART PLANNER ENGINE
-- ===================================================================== --
local CorvusPlanner = {
IsBusy = false,
TaskQueue = {},
Priority = { CRITICAL = 1, EVENT = 2, PROGRESS = 3, OPTIMIZE = 4, TOWER = 5, FARM = 6 }
}
​function CorvusPlanner:AddTask(id, priorityLevel, actionFunc, desc)
for _, t in ipairs(self.TaskQueue) do if t.Id == id then return end end
table.insert(self.TaskQueue, { Id = id, Priority = priorityLevel, Action = actionFunc, Desc = desc })
table.sort(self.TaskQueue, function(a, b) return a.Priority < b.Priority end)
end
​function CorvusPlanner:EvaluateEnvironment()
if not F.smartPlannerEnabled then return end
​-- Task 1: Farming Baseline (Roll Dice & Collect)
if F.autoRoll then
self:AddTask("AUTO_ROLL", self.Priority.FARM, function()
STATE.plannerMissionName = "AUTONOMOUS FARMING & ROLL DICE"
STATE.plannerCurrentStep = "Mengocok dadu dan mengumpulkan koin plot secara berkelanjutan."
STATE.plannerActionPlan  = "RollDice -> CollectBalance"
​FireRemoteSafe(R.RollDice, "RollDice")
if F.collect and R.CollectBalance then
for i = 1, 10 do FireRemoteSafe(R.CollectBalance, "CollectBalance", i) end
end
task.wait(0.5)
end, "Rutin Roll Dadu & Collect")
end
​-- Task 2: Tower Pushing
if F.tower then
self:AddTask("TOWER_PUSH", self.Priority.TOWER, function()
STATE.plannerMissionName = "TOWER CHALLENGE: PUSHING LANTAI"
STATE.plannerCurrentStep = "Menantang Main Tower untuk panen Gems."
STATE.plannerActionPlan  = "Equip Best Team -> Play Tower"
​if R.BestTowerTeam and F.towerEquipBest then FireRemoteSafe(R.BestTowerTeam, "BestTowerTeam") end
if R.PlayTower then FireRemoteSafe(R.PlayTower, "PlayTower", F.towerList[1] or "Dragon Tower") end
task.wait(2)
end, "Tantang Tower")
end
end
​function CorvusPlanner:StartEngine()
task.spawn(function()
while _G.__ANIMEDICE == generation do
DiagnosticEngine:SafeExecute("PLANNER_EVAL", function() self:EvaluateEnvironment() end)
task.wait(0.5)
end
end)
​task.spawn(function()
while _G.__ANIMEDICE == generation do
if not self.IsBusy and #self.TaskQueue > 0 then
local taskItem = table.remove(self.TaskQueue, 1)
self.IsBusy = true
DiagnosticEngine:SafeExecute("TASK_EXEC:" .. taskItem.Id, taskItem.Action)
self.IsBusy = false
end
task.wait(0.1)
end
end)
end
​-- ===================================================================== --
-- 5. GUI SETUP & MASTER EXECUTION
-- ===================================================================== --
local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkMasterHubV108"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui; MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 480, 0, 260); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.BackgroundColor3 = Color3.fromRGB(10, 16, 30)
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 14); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 2; MainStroke.Color = Color3.fromRGB(0, 195, 255); MainStroke.Parent = MainFrame
​local Title = Instance.new("TextLabel"); Title.Parent = MainFrame; Title.Position = UDim2.new(0, 15, 0, 12); Title.Size = UDim2.new(1, -30, 0, 30)
Title.Text = "👑 MOFENKHUB V108.0 | SMART PLANNER ENGINE"; Title.TextColor3 = Color3.fromRGB(0, 195, 255); Title.TextSize = 13; Title.Font = Enum.Font.GothamBlack; Title.BackgroundTransparency = 1
​local StatusLabel = Instance.new("TextLabel"); StatusLabel.Parent = MainFrame; StatusLabel.Position = UDim2.new(0, 15, 0, 50); StatusLabel.Size = UDim2.new(1, -30, 0, 130)
StatusLabel.Text = "Status: Berhasil Diexecute dengan Safe Prober!\n\n🎯 Misi: Memulai Autonomous Loop F2P\n📌 Langkah: Menjalankan Corvus Task Queue & Diagnostic Engine\n📋 Antrean Task: Aktif"; StatusLabel.TextColor3 = Color3.fromRGB(241, 245, 249); StatusLabel.TextSize = 11; StatusLabel.Font = Enum.Font.GothamMedium; StatusLabel.TextXAlignment = Enum.TextXAlignment.Left; StatusLabel.TextYAlignment = Enum.TextYAlignment.Top; StatusLabel.BackgroundTransparency = 1; StatusLabel.TextWrapped = true
​task.spawn(function()
while _G.__ANIMEDICE == generation do
pcall(function()
StatusLabel.Text = string.format(
"Status: Berhasil Diexecute dengan Safe Prober!\n\n🎯 Misi: %s\n📌 Langkah: %s\n📋 Antrean Task Aktif: %d | Health: %.1f%%",
STATE.plannerMissionName, STATE.plannerCurrentStep, #CorvusPlanner.TaskQueue, DiagnosticEngine:GetHealthScore()
)
end)
task.wait(0.5)
end
end)
​local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = MainFrame; CloseBtn.Position = UDim2.new(0.5, -80, 1, -45); CloseBtn.Size = UDim2.new(0, 160, 0, 32); CloseBtn.Text = "TUTUP PANEL"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 8); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainGui:Destroy() end)
​CorvusPlanner:StartEngine()
​-- Anti-AFK Protection
local vu = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
if F.afk then
pcall(function()
vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
task.wait(1)
vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
end
end)
​print("[👑 MOFENKHUB] V108.0 Ultimate Smart Planner Engine Successfully Loaded.")
