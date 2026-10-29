-- ===================================================================== --
-- 👑 MOFENKHUB V106.0 — ULTIMATE SMART PLANNER & FULL GAME AUTOMATION
-- Engine: Corvus-Style Priority Queue + Diagnostic Error Telemetry
-- Game: Anime Dice (Full Features Integration)
-- ===================================================================== --

--!nocheck
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

local LocalPlayer = Players.LocalPlayer
local successGui, parentGui = pcall(function()
	if gethui then return gethui() elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end

pcall(function() for _, v in pairs(parentGui:GetChildren()) do if string.find(v.Name, "Mofenk") then v:Destroy() end end end)

-- ===================================================================== --
-- 1. DIAGNOSTIC & TELEMETRY ENGINE
-- ===================================================================== --
local DiagnosticEngine = {
	TotalCalls = 0,
	SuccessCount = 0,
	ErrorCount = 0,
	ErrorRegistry = {},
	MissingRemotes = {},
	LogFile = "MofenkHub_Configs/diagnostic_report.json"
}

function DiagnosticEngine:LogEvent(tag, msg, errData)
	local timestamp = os.date("%X")
	local entry = { Time = timestamp, Tag = tag, Message = msg, ErrorData = errData and tostring(errData) or nil }
	
	if errData then
		self.ErrorCount = self.ErrorCount + 1
		table.insert(self.ErrorRegistry, 1, entry)
		if #self.ErrorRegistry > 60 then table.remove(self.ErrorRegistry) end
		warn(string.format("[🚨 DIAGNOSTIC ERROR] [%s] [%s]: %s\nStack:\n%s", timestamp, tag, msg, tostring(errData)))
	else
		self.SuccessCount = self.SuccessCount + 1
		print(string.format("[🔍 DIAGNOSTIC INFO] [%s] [%s]: %s", timestamp, tag, msg))
	end
	self.TotalCalls = self.TotalCalls + 1
	self:SaveReport()
end

function DiagnosticEngine:SafeExecute(contextTag, fn, ...)
	local args = {...}
	local success, result = xpcall(function() return fn(unpack(args)) end, function(err) return debug.traceback(tostring(err), 2) end)
	if not success then
		self:LogEvent(contextTag, "Eksekusi Fungsi Gagal!", result)
		return false, result
	else
		self.SuccessCount = self.SuccessCount + 1
		return true, result
	end
end

function DiagnosticEngine:SaveReport()
	if writefile then
		pcall(function()
			local reportData = {
				HealthScore = self:GetHealthScore(),
				TotalCalls = self.TotalCalls,
				SuccessCount = self.SuccessCount,
				ErrorCount = self.ErrorCount,
				MissingRemotes = self.MissingRemotes,
				RecentErrors = self.ErrorRegistry
			}
			writefile(self.LogFile, HttpService:JSONEncode(reportData))
		end)
	end
end

function DiagnosticEngine:GetHealthScore()
	if self.TotalCalls == 0 then return 100.0 end
	return math.clamp((self.SuccessCount / self.TotalCalls) * 100, 0, 100)
end

-- ===================================================================== --
-- 2. CONFIGURATION & STATE MANAGER
-- ===================================================================== --
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

local F = {
	cfgName = "SmartPlanner_FullV106", autoLoadEnabled = false,
	
	-- Smart Planner Core
	smartPlannerEnabled = true,
	smartPlannerMode = "AUTO_PROGRESSION",
	smartPlannerAutoPotion = true,
	
	-- Plot & Economy Farming
	collect = true, levelup = true, maxLevel = 100, smartLevel = true,
	rebirth = true, upgrades = true, buyDice = true, equipDice = true, autoRoll = true,
	autoBestPlaceBase = true, smartPlace = true,
	
	-- Inventory & Auto Sell / Lock / Fuse
	sellAuto = true, sellMaxInvent = true, keepBest = 5, autoFuse = true,
	keepRarities = {"Mythic", "Secret", "Divine", "Godly"},
	autoLockRarity = true, specificSellUnits = {},
	
	-- Potions / Boosts
	potionAuto = true, potionBest = true, potionSpecific = {"Luck Potion", "Damage Potion", "Coins Potion"},
	
	-- Quirk, Grade & Trait Reroll Engine
	autoLockTarget = true,
	quirkAuto = true, quirkTargets = {"Godly", "All-Out", "Shadow", "Crit Master", "Overlord"}, quirkUnits = {}, quirkReserve = 5,
	gradeAuto = true, gradeTargets = {"Z", "SSS", "SS", "S"}, gradeUnits = {}, gemReserve = 50,
	traitAuto = true, traitTargets = {"Godly", "Fortune III", "Overlord", "Boss Slayer", "Berserk"}, traitUnits = {}, rerollReserve = 10,
	
	-- Main Tower Setup
	tower = true, towerMix = true, towerList = {"Dragon Tower", "Demon Tower", "Ninja Tower", "Pirate Tower"}, towerEquipBest = true, towerExitOn = false, towerExitFloor = 100,
	
	-- Halloween World & Haunted Tower Events
	halloweenTeleport = false, halloweenQuest = true, halloweenPath = true, halloweenOffer = false, trickOrTreat = false,
	pumpkinRollQty = 5, pumpkinAutoRoll = false, pumpkinAutoSell = true,
	hauntedTower = false, hauntedMix = true, hauntedList = {"Haunted Front Yard", "Haunted Crypt", "Haunted Attic", "Haunted Bell Tower"}, hauntedEquipBest = true, hauntedExitOn = false, hauntedExitFloor = 50,
	
	-- Utility & System Optimization
	wsOn = false, wsValue = 16, noclip = false, afk = true, fpsOn = true,
	codesAuto = true, claimQuests = true,
	
	-- Discord Webhook
	webhookEnabled = false, webhookUrl = ""
}

local STATE = {
	plannerMissionName = "MEMINDAI GAME STATE...",
	plannerCurrentStep = "Inisialisasi Module & Probe Services...",
	plannerActionPlan  = "Menyusun Antrean Prioritas Corvus",
	plannerLuckScore   = 1.0,
	plannerTPR         = 0.0,
	
	towerLive = "Standby", towerFloor = 0, towerDrops = 0, towerTraitsGot = "Belum Ada",
	hauntedLive = "Standby", hauntedFloor = 0, hauntedDrops = 0, activeBuffs = "Tidak Ada",
	pingMs = 0, fpsCurrent = 60,
	quirkActiveUnit = "-", quirkCurrentVal = "-", quirkStatus = "Standby",
	gradeActiveUnit = "-", gradeCurrentVal = "-", gradeStatus = "Standby",
	traitActiveUnit = "-", traitCurrentVal = "-", traitStatus = "Standby"
}

local ConfigUpdaters = {}
local CFG_FOLDER = "MofenkHub_Configs"
if makefolder and not isfolder(CFG_FOLDER) then pcall(function() makefolder(CFG_FOLDER) end) end

local function getCfgPath(name) return CFG_FOLDER .. "/" .. (name or F.cfgName or "SmartPlanner_FullV106") .. ".json" end

local function saveConfig(name)
	if writefile then
		pcall(function() 
			writefile(getCfgPath(name), HttpService:JSONEncode(F)) 
			local pointerPath = CFG_FOLDER .. "/autoload_pointer.txt"
			if F.autoLoadEnabled then writefile(pointerPath, name or F.cfgName or "SmartPlanner_FullV106")
			elseif isfile and isfile(pointerPath) then delfile(pointerPath) end
		end)
	end
end

local function loadConfig(name)
	local path = getCfgPath(name)
	if readfile and isfile and isfile(path) then
		pcall(function() 
			local d = HttpService:JSONDecode(readfile(path))
			for k,v in pairs(d) do F[k]=v end 
			for _, updateUI in ipairs(ConfigUpdaters) do pcall(updateUI) end
		end)
	end
end

local function FormatMoney(val)
	val = tonumber(val) or 0
	if val >= 1e12 then return string.format("%.2fT", val/1e12)
	elseif val >= 1e9 then return string.format("%.2fB", val/1e9)
	elseif val >= 1e6 then return string.format("%.2fM", val/1e6)
	elseif val >= 1e3 then return string.format("%.2fK", val/1e3)
	else return tostring(math.floor(val)) end
end

-- ===================================================================== --
-- 3. FRAMEWORK SERVICES BINDINGS & REMOTE TELEMETRY
-- ===================================================================== --
local Network = ReplicatedStorage:WaitForChild("Network", 15)
local Framework = ReplicatedStorage:WaitForChild("Framework", 15)

local function ProbeRemote(path)
	local n = Network
	for x in string.gmatch(path, "[^%.]+") do n = n and n:FindFirstChild(x) end
	if not n then
		DiagnosticEngine.MissingRemotes[path] = true
		DiagnosticEngine:LogEvent("PROBE", "Remote Missing: " .. path, "Nama remote diubah server game.")
	end
	return n
end

local R = {
	RollDice        = ProbeRemote("RollService.RF.RollDice"),
	SetAutoRoll     = ProbeRemote("RollService.RE.SetAutoRoll"),
	CollectBalance  = ProbeRemote("PlotService.RE.CollectBalance"), 
	LevelUpSlot     = ProbeRemote("PlotService.RE.LevelUpSlot"),
	EquipBestPlot   = ProbeRemote("PlotService.RE.EquipBest"),
	BuyDice         = ProbeRemote("DiceShopService.RE.BuyDice"), 
	EquipDice       = ProbeRemote("DiceShopService.RE.EquipDice"),
	Rebirth         = ProbeRemote("RebirthService.RE.Rebirth"), 
	BuyUpgrade      = ProbeRemote("RE.BuyUpgrade") or ProbeRemote("PlotService.RE.BuyPadUpgrade"),
	QuirkRoll       = ProbeRemote("QuirkService.RE.Roll") or ProbeRemote("Quirks.RE.Roll") or ProbeRemote("MutationService.RE.Roll"),
	GradeRoll       = ProbeRemote("GradeService.RE.Roll") or ProbeRemote("Grades.RE.Roll"), 
	TraitRoll       = ProbeRemote("TraitService.RE.Roll") or ProbeRemote("Traits.RE.Roll"), 
	BoostUse        = ProbeRemote("BoostService.RE.Use"),
	PlayTower       = ProbeRemote("Towers.RF.PlayTower") or ProbeRemote("Towers.RE.PlayTower") or ProbeRemote("TowerService.RF.PlayTower"), 
	CompleteFloor   = ProbeRemote("Towers.RF.CompleteTowerFloor") or ProbeRemote("TowerService.RF.CompleteTowerFloor"),
	CancelTower     = ProbeRemote("Towers.RF.CancelTower") or ProbeRemote("TowerService.RF.CancelTower"), 
	BestTowerTeam   = ProbeRemote("Towers.RE.EquipBestTowerTeam") or ProbeRemote("TowerService.RE.EquipBestTowerTeam"),
	RedeemCode      = ProbeRemote("CodesService.RE.RedeemCode") or ProbeRemote("MonetizationService.RE.RedeemCode"),
	QuestClaim      = ProbeRemote("QuestService.RE.Claim"), 
	ClaimDaily      = ProbeRemote("DailyRewardService.RE.Claim"),
	ClaimOffline    = ProbeRemote("OfflineEarningsService.RE.Claim"), 
	ClaimGroup      = ProbeRemote("GroupRewardService.RE.Claim"),
	SellInventory   = ProbeRemote("SellService.RF.SellInventory") or ProbeRemote("SellService.RE.SellInventory"),
	UpdateAutoSell  = ProbeRemote("SellService.RE.UpdateAutoSell"),
	Fuse            = ProbeRemote("FusingService.RE.Fuse"),
	InteractSlot    = ProbeRemote("PlotService.RE.InteractSlot"),
	EquipUnit       = ProbeRemote("UnitService.RF.Equip") or ProbeRemote("UnitService.RE.Equip"),
	UnequipUnit     = ProbeRemote("UnitService.RF.Unequip") or ProbeRemote("UnitService.RE.Unequip"),
	LockUnit        = ProbeRemote("UnitService.RE.SetLock") or ProbeRemote("InventoryService.RE.Lock")
}

local function FireRemoteSafe(remoteObj, remoteName, ...)
	if not remoteObj then
		DiagnosticEngine:LogEvent("REMOTE_FIRE", "Remote " .. remoteName .. " tidak ditemukan (NIL)", "Nama remote berbeda di server game.")
		return false, "NIL_REMOTE"
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

local G = {}
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
	G.RollController = require(Framework.Features.Rolling.RollController)
	G.SellController = require(Framework.Features.Sell.SellController)
	G.DiceModule = require(Framework.Features.Rolling.Dice)
	G.TowersConfig = require(Framework.Features.Towers.Towers)
	G.UnitConfig = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig)
end)

local function data() return G.DC and G.DC.___X or {} end
local function money() pcall(function() return G.DC.Money() end); return data().Money or 0 end
local function rebirthAmt() pcall(function() return G.DC.Rebirth() end); return data().Rebirth or 0 end
local function inventory() return data().Inventory or {} end
local function isUnitEntry(e) return e and type(e)=="table" and e.name and G.EntryRegistry and pcall(function() return G.EntryRegistry.getEntryConfig(e.name).kind == "Unit" end) end

local function isBeingRolled(unitId)
	if not unitId then return false end
	if F.quirkAuto then for _, id in ipairs(F.quirkUnits or {}) do if id == unitId then return true end end end
	if F.gradeAuto then for _, id in ipairs(F.gradeUnits or {}) do if id == unitId then return true end end end
	if F.traitAuto then for _, id in ipairs(F.traitUnits or {}) do if id == unitId then return true end end end
	return false
end

local function getUnitRarity(u)
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

local function baseIncome(u)
	if not u then return 0 end
	local e = G.UnitConfig and G.UnitConfig.entries[u.name]
	if not e then return 0 end
	local a = u.attributes or {}
	local lvl = tonumber(a.level) or 1
	local ok, inc = pcall(function()
		if e.income then return e.income({ mutation = a.mutation or a.quirk, grade = a.grade, trait = a.trait, level = lvl }) end
		return 0
	end)
	return tonumber(inc) or 0
end

-- ===================================================================== --
-- 4. CORVUS-STYLE TASK QUEUE & SMART PLANNER ENGINE
-- ===================================================================== --
local CorvusPlanner = {
	IsBusy = false,
	TaskQueue = {},
	Priority = {
		CRITICAL = 1,  -- Inventory full, safety, disconnect recovery
		EVENT    = 2,  -- Halloween quest/path, pumpkin roll
		PROGRESS = 3,  -- Rebirth, Slot upgrade, Dice shop
		OPTIMIZE = 4,  -- Trait, Grade, Quirk rerolls
		TOWER    = 5,  -- Tower pushing
		FARM     = 6   -- Continuous Plot collect, roll dice
	}
}

function CorvusPlanner:AddTask(id, priorityLevel, actionFunc, desc)
	for _, taskItem in ipairs(self.TaskQueue) do
		if taskItem.Id == id then return end
	end
	table.insert(self.TaskQueue, { Id = id, Priority = priorityLevel, Action = actionFunc, Desc = desc })
	table.sort(self.TaskQueue, function(a, b) return a.Priority < b.Priority end)
end

function CorvusPlanner:EvaluateEnvironment()
	if not F.smartPlannerEnabled then return end
	
	-- 1. CRITICAL: Inventory Management
	local inv = inventory()
	local totalOwned = 0
	for _, e in pairs(inv) do if isUnitEntry(e) then totalOwned = totalOwned + 1 end end
	
	if totalOwned >= 90 then
		self:AddTask("CLEAR_INV", self.Priority.CRITICAL, function()
			STATE.plannerMissionName = "PERINGATAN: INVENTORY HAMPIR PENUH!"
			STATE.plannerCurrentStep = "Membersihkan unit trash di luar Keep Rarity."
			STATE.plannerActionPlan  = "Menjalankan Auto Sell & Auto Fuse."
			
			if F.sellAuto and R.SellInventory then
				local sellList = {}
				for id, u in pairs(inv) do
					if isUnitEntry(u) and not isBeingRolled(id) then
						local rarity = getUnitRarity(u)
						local keep = false
						for _, r in ipairs(F.keepRarities or {}) do if string.lower(rarity) == string.lower(r) then keep = true break end end
						if not keep then table.insert(sellList, id) end
					end
					if #sellList >= 100 then break end
				end
				if #sellList > 0 then FireRemoteSafe(R.SellInventory, "SellInventory", sellList) end
			end
			task.wait(1)
		end, "Membersihkan Tas Unit")
	end

	-- 2. PROGRESSION: Rebirth & Dice Shop
	local curMoney = money()
	local curLevel = 0
	pcall(function() curLevel = G.DC.Level() or 0 end)

	if curLevel >= 100 or curMoney >= 1e6 then
		self:AddTask("DO_REBIRTH", self.Priority.PROGRESS, function()
			STATE.plannerMissionName = "PROGRESI: REBIRTH DIBUKA"
			STATE.plannerCurrentStep = "Mengeksekusi Rebirth untuk meningkatkan Stat Multiplier."
			STATE.plannerActionPlan  = "Kirim Remote Rebirth -> Upgrade Slot Pad."
			
			if F.rebirth and R.Rebirth then FireRemoteSafe(R.Rebirth, "Rebirth") end
			task.wait(1.5)
		end, "Proses Rebirth Akun")
	end

	-- 3. OPTIMIZATION: Quirk, Grade, & Trait Reroll
	if F.gradeAuto or F.traitAuto or F.quirkAuto then
		self:AddTask("STAT_REROLL", self.Priority.OPTIMIZE, function()
			STATE.plannerMissionName = "OPTIMASI STAT: REROLL TRAIT / GRADE / QUIRK"
			STATE.plannerCurrentStep = "Meningkatkan Grade, Trait, dan Quirk unit DPS utama."
			STATE.plannerActionPlan  = "Mencapai Target Whitelist (Godly/Z/SSS)."
			
			if #F.gradeUnits == 0 or #F.traitUnits == 0 then
				local topId, topDmg = nil, -1
				for id, u in pairs(inv) do
					if isUnitEntry(u) and baseIncome(u) > topDmg then topDmg = baseIncome(u); topId = id end
				end
				if topId then
					F.gradeUnits = {topId}
					F.traitUnits = {topId}
					F.quirkUnits = {topId}
				end
			end
			task.wait(0.5)
		end, "Optimasi Stat Unit Top DPS")
	end

	-- 4. TOWER PUSHING
	if F.tower then
		self:AddTask("TOWER_PUSH", self.Priority.TOWER, function()
			STATE.plannerMissionName = "TOWER CHALLENGE: PUSHING LANTAI TERTINGGI"
			STATE.plannerCurrentStep = "Tantang Main Tower untuk panen Gems & Trait Drops."
			STATE.plannerActionPlan  = "Auto equip best tower team -> Teleport ke Tower."
			
			if R.BestTowerTeam and F.towerEquipBest then FireRemoteSafe(R.BestTowerTeam, "BestTowerTeam") end
			if R.PlayTower then FireRemoteSafe(R.PlayTower, "PlayTower", F.towerList[1] or "Dragon Tower") end
			task.wait(2)
		end, "Tantang Main Tower")
	end

	-- 5. FARMING BASELINE
	self:AddTask("BASE_FARM", self.Priority.FARM, function()
		STATE.plannerMissionName = "AUTONOMOUS FARMING & ROLL DICE"
		STATE.plannerCurrentStep = "Mengumpulkan koin plot & mengocok Dadu Utama."
		STATE.plannerActionPlan  = "Auto Collect -> Auto Roll Dice -> Auto Place Best Unit."
		
		if F.collect and R.CollectBalance then
			for i = 1, 15 do FireRemoteSafe(R.CollectBalance, "CollectBalance", i) end
		end
		if F.autoRoll and R.RollDice unbroken then FireRemoteSafe(R.RollDice, "RollDice") end
		task.wait(0.5)
	end, "Rutin Farming Plot & Dadu")
end

function CorvusPlanner:StartEngine()
	task.spawn(function()
		while _G.__ANIMEDICE == generation do
			DiagnosticEngine:SafeExecute("PLANNER_EVAL", function() self:EvaluateEnvironment() end)
			task.wait(0.4)
		end
	end)

	task.spawn(function()
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

-- ===================================================================== --
-- 5. GUI SETUP & MASTER EXECUTION
-- ===================================================================== --
local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkMasterHubV106"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui; MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 1060, 0, 680); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.BackgroundColor3 = Color3.fromRGB(10, 16, 30)
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 16); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 2; MainStroke.Color = Color3.fromRGB(0, 195, 255); MainStroke.Parent = MainFrame

-- Top Header
local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 52); TopBar.BackgroundColor3 = Color3.fromRGB(13, 20, 38)
local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 18, 0, 0); Title.Size = UDim2.new(0, 750, 1, 0); Title.Text = "👑 MOFENKHUB V106.0 | ULTIMATE CORVUS SMART PLANNER ENGINE"; Title.TextColor3 = Color3.fromRGB(0, 195, 255); Title.TextSize = 14; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -44, 0, 9); CloseBtn.Size = UDim2.new(0, 34, 0, 34); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(240, 240, 240); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

CorvusPlanner:StartEngine()

-- Anti-AFK Protection
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

print("[👑 MOFENKHUB] V106.0 Ultimate Smart Planner Engine Loaded.")
