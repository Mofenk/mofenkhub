-- ===================================================================== --
-- 👑 MOFENKHUB V113.0 — EXECUTIVE SMART PLANNER (PROFESSIONAL EDITION)
-- Game: Anime Dice | Architecture: Real-Time State Evaluator & Priority Queue
-- ===================================================================== --

--!nocheck
task.wait(1)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local successGui, parentGui = pcall(function()
	if gethui then return gethui() elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end

pcall(function() for _, v in pairs(parentGui:GetChildren()) do if string.find(v.Name, "Mofenk") then v:Destroy() end end end)

-- ===================================================================== --
-- 1. TELEMETRY & ERROR HANDLING
-- ===================================================================== --
local Telemetry = { Executions = 0, Success = 0, Errors = 0 }

function Telemetry:SafeExecute(context, fn, ...)
	local args = {...}
	local ok, result = xpcall(function() return fn(unpack(args)) end, function(err) return debug.traceback(tostring(err), 2) end)
	self.Executions = self.Executions + 1
	if not ok then
		self.Errors = self.Errors + 1
		warn(string.format("[MofenkHub Telemetry] Error at [%s]: %s", context, tostring(result)))
	else
		self.Success = self.Success + 1
	end
	return ok, result
end

-- ===================================================================== --
-- 2. SAFE REMOTE BINDINGS
-- ===================================================================== --
local function GetNetwork()
	local net = nil; pcall(function() net = ReplicatedStorage:WaitForChild("Network", 5) end); return net
end

local function BindRemote(service, remote)
	local r = nil
	pcall(function()
		local net = GetNetwork()
		if net and net:FindFirstChild(service) then r = net[service]:FindFirstChild(remote, true) end
	end)
	return r
end

local Remotes = {
	-- Core Progression
	RollDice = BindRemote("RollService", "RollDice"),
	Collect = BindRemote("PlotService", "CollectBalance"),
	LevelUp = BindRemote("PlotService", "LevelUpSlot"),
	EquipBestPlot = BindRemote("PlotService", "EquipBest"),
	Rebirth = BindRemote("RebirthService", "Rebirth"),
	BuyDice = BindRemote("DiceShopService", "BuyDice"),
	EquipDice = BindRemote("DiceShopService", "EquipDice"),
	BuyPad = BindRemote("PlotService", "BuyPadUpgrade") or BindRemote("Upgrades", "BuyUpgrade"),
	
	-- Inventory Management
	Sell = BindRemote("SellService", "SellInventory"),
	Fuse = BindRemote("FusingService", "Fuse"),
	EquipUnit = BindRemote("UnitService", "Equip"),
	LockUnit = BindRemote("UnitService", "SetLock") or BindRemote("InventoryService", "Lock"),
	
	-- Optimization
	TraitRoll = BindRemote("TraitService", "Roll") or BindRemote("Traits", "Roll"),
	GradeRoll = BindRemote("GradeService", "Roll") or BindRemote("Grades", "Roll"),
	QuirkRoll = BindRemote("QuirkService", "Roll") or BindRemote("Quirks", "Roll"),
	UseBoost = BindRemote("BoostService", "Use"),
	
	-- Competitive (Tower)
	EquipTower = BindRemote("Towers", "EquipBestTowerTeam") or BindRemote("TowerService", "EquipBestTowerTeam"),
	PlayTower = BindRemote("Towers", "PlayTower") or BindRemote("TowerService", "PlayTower"),
	
	-- Events
	PumpkinRoll = BindRemote("PumpkinDiceService", "Roll"),
	TrickOrTreat = BindRemote("TrickOrTreatService", "Knocked")
}

local function Fire(remote, ...)
	if not remote then return false end
	local args = {...}
	return Telemetry:SafeExecute("RemoteFire", function()
		if remote:IsA("RemoteEvent") then remote:FireServer(unpack(args))
		elseif remote:IsA("RemoteFunction") then remote:InvokeServer(unpack(args)) end
	end)
end

-- ===================================================================== --
-- 3. GAME STATE READER (REAL-TIME DATA ABSTRACTION)
-- ===================================================================== --
local GameState = {}

function GameState.Read()
	local state = { Money = 0, Level = 0, Inventory = {}, Slots = {}, TowerTeam = {}, Buffs = {} }
	pcall(function()
		local Framework = ReplicatedStorage:WaitForChild("Framework", 5)
		local DC = require(Framework.Features.Data.DataController)
		state.Money = DC.Money() or 0
		state.Level = DC.Level() or 0
		state.Inventory = DC.___X.Inventory or {}
		state.Slots = DC.___X.Slots or {}
		state.TowerTeam = DC.___X.TowerTeam or {}
		state.Buffs = DC.___X.Buffs or {}
	end)
	return state
end

local function GetUnitMetadata(unitName)
	local rarity, baseDmg = "Common", 10
	pcall(function()
		local Framework = ReplicatedStorage:WaitForChild("Framework", 5)
		local success, Reg = pcall(function() return require(Framework.Features.Inventory.EntryRegistry) end)
		if success and Reg then
			local cfg = Reg.getEntryConfig(unitName)
			rarity = cfg.rarity or "Common"
			baseDmg = cfg.baseDamage or 10
		else
			local cfg = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig).entries[unitName]
			rarity = cfg.rarity or "Common"
			baseDmg = cfg.baseDamage or 10
		end
	end)
	return rarity, baseDmg
end

local function CalculatePowerScore(unitData)
	if not unitData or type(unitData) ~= "table" then return 0 end
	local _, base = GetUnitMetadata(unitData.name)
	local lvl = tonumber(unitData.attributes and unitData.attributes.level) or 1
	local multiplier = 1.0
	
	if unitData.attributes then
		local g = unitData.attributes.grade
		local t = unitData.attributes.trait
		if g == "SSS" then multiplier = multiplier + 1.5 elseif g == "Z" then multiplier = multiplier + 3.0 end
		if t == "Godly" or t == "Overlord" then multiplier = multiplier + 2.5 end
	end
	return (base * lvl) * multiplier
end

-- ===================================================================== --
-- 4. EXECUTIVE CONFIGURATION
-- ===================================================================== --
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local gen = _G.__ANIMEDICE

local Config = {
	AntiAFK = true,
	-- Priority 1
	AutoSell = true, AutoFuse = true, KeepRarities = {"Mythic", "Secret", "Divine", "Godly"},
	-- Priority 2
	EventHalloween = true,
	-- Priority 3
	AutoPotion = true,
	-- Priority 4
	AutoRebirth = true, AutoDice = true,
	-- Priority 5
	AutoOptimize = true, TargetGrades = {"Z", "SSS"}, TargetTraits = {"Godly", "Fortune III", "Overlord", "Boss Slayer"},
	-- Priority 6
	AutoTower = true, TowerTarget = "Dragon Tower",
	-- Priority 7
	AutoFarming = true
}

local UIState = { Action = "System Boot Sequence", QueueLength = 0 }

-- ===================================================================== --
-- 5. EXECUTIVE SMART PLANNER ALGORITHM
-- ===================================================================== --
local Planner = {
	IsBusy = false, TaskQueue = {},
	Priority = { CRITICAL = 1, EVENT = 2, STRATEGY = 3, PROGRESS = 4, OPTIMIZE = 5, COMPETITIVE = 6, FARM = 7 }
}

function Planner:Enqueue(id, priority, action, description)
	for _, t in ipairs(self.TaskQueue) do if t.Id == id then return end end
	table.insert(self.TaskQueue, { Id = id, Priority = priority, Action = action, Desc = description })
	table.sort(self.TaskQueue, function(a, b) return a.Priority < b.Priority end)
end

function Planner:Evaluate()
	local state = GameState.Read()

	-- [P1] Inventory Operations (Critical constraints)
	local invCount = 0; for _ in pairs(state.Inventory) do invCount = invCount + 1 end
	if invCount >= 85 and Config.AutoSell then
		self:Enqueue("CLEAN_INVENTORY", self.Priority.CRITICAL, function()
			UIState.Action = "P1: Executing Inventory Cleanup"
			local trash = {}
			local locked = {}
			for _, s in pairs(state.Slots) do if s.unitId then locked[s.unitId] = true end end
			for _, id in pairs(state.TowerTeam) do locked[id] = true end

			for id, u in pairs(state.Inventory) do
				if u and u.name and not locked[id] then
					if not (u.attributes and u.attributes.locked) then
						local rarity = GetUnitRarity(u.name)
						local isKeep = false
						for _, kr in ipairs(Config.KeepRarities) do if string.lower(rarity) == string.lower(kr) then isKeep = true break end end
						if not isKeep then table.insert(trash, id) end
					end
				end
			end
			if #trash > 0 then Fire(Remotes.Sell, trash) end
			if Config.AutoFuse then Fire(Remotes.Fuse) end
			task.wait(1)
		end, "Clear Trash Units")
	end

	-- [P2] Event Automation
	if Config.EventHalloween then
		self:Enqueue("HALLOWEEN_TASKS", self.Priority.EVENT, function()
			UIState.Action = "P2: Processing Seasonal Events"
			Fire(Remotes.PumpkinRoll)
			Fire(Remotes.TrickOrTreat)
			task.wait(0.5)
		end, "Halloween Events")
	end

	-- [P3] Strategic Resource Management (Potions)
	if Config.AutoPotion then
		self:Enqueue("MANAGE_BUFFS", self.Priority.STRATEGY, function()
			UIState.Action = "P3: Validating Active Buffs"
			local luckActive = false
			for bName, _ in pairs(state.Buffs) do if string.find(string.lower(bName), "luck") then luckActive = true break end end
			
			if not luckActive then
				for id, item in pairs(state.Inventory) do
					if item.name and string.find(string.lower(item.name), "luck potion") then
						Fire(Remotes.UseBoost, id)
						break
					end
				end
			end
			task.wait(0.5)
		end, "Potion Activation")
	end

	-- [P4] Core Progression
	if Config.AutoRebirth and (state.Level >= 100 or state.Money >= 1e6) then
		self:Enqueue("REBIRTH_CYCLE", self.Priority.PROGRESS, function()
			UIState.Action = "P4: Executing Rebirth Protocol"
			Fire(Remotes.Rebirth)
			task.wait(1.5)
		end, "Account Rebirth")
	end

	-- [P5] Unit Optimization (Target Sniping)
	if Config.AutoOptimize then
		self:Enqueue("OPTIMIZE_STATS", self.Priority.OPTIMIZE, function()
			UIState.Action = "P5: Optimizing Unit Attributes"
			local topId, topScore = nil, -1
			for id, u in pairs(state.Inventory) do
				if u.name then
					local s = CalculatePowerScore(u)
					if s > topScore then topScore = s; topId = id end
				end
			end

			if topId then
				local u = state.Inventory[topId]
				local cTrait = (u.attributes and u.attributes.trait) or "None"
				local cGrade = (u.attributes and u.attributes.grade) or "None"
				
				local needTrait, needGrade = true, true
				for _, t in ipairs(Config.TargetTraits) do if cTrait == t then needTrait = false break end end
				for _, g in ipairs(Config.TargetGrades) do if cGrade == g then needGrade = false break end end

				if needTrait then Fire(Remotes.TraitRoll, topId)
				elseif needGrade then Fire(Remotes.GradeRoll, topId) end
			end
			task.wait(0.5)
		end, "Precision Reroll")
	end

	-- [P6] Competitive Execution
	if Config.AutoTower then
		self:Enqueue("TOWER_ASSAULT", self.Priority.COMPETITIVE, function()
			UIState.Action = "P6: Initiating Tower Assault"
			Fire(Remotes.EquipTower)
			Fire(Remotes.PlayTower, Config.TowerTarget)
			task.wait(2)
		end, "Tower Push")
	end

	-- [P7] Baseline Operations
	if Config.AutoFarming then
		self:Enqueue("BASELINE_FARMING", self.Priority.FARM, function()
			UIState.Action = "P7: Sustaining Baseline Economy"
			Fire(Remotes.RollDice)
			for i=1, 15 do Fire(Remotes.Collect, i) end
			Fire(Remotes.EquipBestPlot)
			task.wait(0.5)
		end, "Plot Management")
	end
end

-- ===================================================================== --
-- 6. SYSTEM INITIALIZATION & THREADING
-- ===================================================================== --
task.spawn(function()
	while gen == _G.__ANIMEDICE do
		Telemetry:SafeExecute("Evaluate", function() Planner:Evaluate() end)
		task.wait(0.5)
	end
end)

task.spawn(function()
	while gen == _G.__ANIMEDICE do
		if not Planner.IsBusy and #Planner.TaskQueue > 0 then
			local taskItem = table.remove(Planner.TaskQueue, 1)
			Planner.IsBusy = true
			Telemetry:SafeExecute("Task:"..taskItem.Id, taskItem.Action)
			Planner.IsBusy = false
		end
		UIState.QueueLength = #Planner.TaskQueue
		task.wait(0.1)
	end
end)

-- ===================================================================== --
-- 7. EXECUTIVE DASHBOARD (UI)
-- ===================================================================== --
local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkExecutiveHub"; MainGui.Parent = parentGui
local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui; MainFrame.Size = UDim2.new(0, 520, 0, 260); MainFrame.Position = UDim2.new(0.5, -260, 0.5, -130); MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30); MainFrame.Draggable = true
Instance.new("UICorner").Parent = MainFrame
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 150, 255); Instance.new("UIStroke", MainFrame).Thickness = 1.5

local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 40); TopBar.BackgroundColor3 = Color3.fromRGB(20, 30, 45)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)
local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Size = UDim2.new(1, -50, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0); Title.Text = "MOFENKHUB V113.0 | EXECUTIVE PLANNER"; Title.TextColor3 = Color3.fromRGB(0, 180, 255); Title.Font = Enum.Font.GothamBlack; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 5); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
Instance.new("UICorner").Parent = CloseBtn; CloseBtn.MouseButton1Click:Connect(function() MainGui:Destroy() end)

local ContentArea = Instance.new("Frame"); ContentArea.Parent = MainFrame; ContentArea.Size = UDim2.new(1, -30, 1, -60); ContentArea.Position = UDim2.new(0, 15, 0, 50); ContentArea.BackgroundTransparency = 1
local Display = Instance.new("TextLabel"); Display.Parent = ContentArea; Display.Size = UDim2.new(1, 0, 1, 0); Display.TextColor3 = Color3.fromRGB(230, 240, 250); Display.Font = Enum.Font.GothamMedium; Display.TextSize = 13; Display.TextXAlignment = Enum.TextXAlignment.Left; Display.TextYAlignment = Enum.TextYAlignment.Top; Display.BackgroundTransparency = 1

task.spawn(function()
	while gen == _G.__ANIMEDICE do
		local s = GameState.Read()
		local ic = 0; for _ in pairs(s.Inventory) do ic = ic + 1 end
		Display.Text = string.format(
			"▶ TELEMETRY LOGS
   • Executions: %d | Errors: %d | Health: %.1f%%

▶ SYSTEM METRICS
   • Financials: %s Coins
   • Account: Level %d
   • Storage: %d/100 Capacity

▶ AI DISPATCH
   • Current Directive: %s
   • Task Queue: %d pending operations",
			Telemetry.Executions, Telemetry.Errors, (Telemetry.Executions == 0 and 100 or math.clamp((Telemetry.Success/Telemetry.Executions)*100, 0, 100)),
			tostring(s.Money), s.Level, ic,
			UIState.Action, UIState.QueueLength
		)
		task.wait(0.2)
	end
end)

LocalPlayer.Idled:Connect(function() if Config.AntiAFK then pcall(function() VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame); task.wait(1); VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end) end end)

print("[MOFENKHUB V113.0] EXECUTIVE SMART PLANNER ONLINE.")
