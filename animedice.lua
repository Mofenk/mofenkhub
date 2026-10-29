-- ===================================================================== --
-- 👑 MOFENKHUB V125.0 — THE ULTIMATE AUTONOMOUS OMNISCIENT ECOSYSTEM
-- Game: Anime Dice | Complete Feature Integration + Floating Mini HUD + Error Telemetry Console
-- ===================================================================== --

--!nocheck
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
local VirtualUser       = game:GetService("VirtualUser")

pcall(function()
	local qot = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
	if qot then
		qot([[
			task.wait(3)
			loadstring(game:HttpGet("https://raw.githubusercontent.com/Mofenk/mofenkhub/refs/heads/main/animedice.lua"))()
		]])
	end
end)

local LocalPlayer = Players.LocalPlayer
local successGui, parentGui = pcall(function()
	if gethui then return gethui() elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end

pcall(function() for _, v in pairs(parentGui:GetChildren()) do if string.find(v.Name, "Mofenk") then v:Destroy() end end end)

_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

-- ===================================================================== --
-- 1. SMART ERROR & DIAGNOSTIC TELEMETRY ENGINE V125.0
-- ===================================================================== --
local DiagnosticHub = {
	TotalCalls = 0,
	SuccessCount = 0,
	ErrorCount = 0,
	ErrorHistory = {}
}

function DiagnosticHub:Log(tag, message, errData)
	local timestamp = os.date("%X")
	local entry = { Time = timestamp, Tag = tag, Message = message, Error = errData and tostring(errData) or nil }
	
	if errData then
		self.ErrorCount = self.ErrorCount + 1
		table.insert(self.ErrorHistory, 1, entry)
		if #self.ErrorHistory > 50 then table.remove(self.ErrorHistory) end
		warn(string.format("[🚨 MofenkError] [%s] [%s]: %s | Details: %s", timestamp, tag, message, tostring(errData)))
	else
		self.SuccessCount = self.SuccessCount + 1
	end
	self.TotalCalls = self.TotalCalls + 1
end

function DiagnosticHub:SafeExecute(tag, fn, ...)
	local args = {...}
	local ok, result = xpcall(function() return fn(unpack(args)) end, function(err) return debug.traceback(tostring(err), 2) end)
	if not ok then
		self:Log(tag, "Eksekusi Fungsi Gagal", result)
		return false, result
	else
		self.SuccessCount = self.SuccessCount + 1
		return true, result
	end
end

function DiagnosticHub:GetHealthScore()
	if self.TotalCalls == 0 then return 100.0 end
	return math.clamp((self.SuccessCount / self.TotalCalls) * 100, 0, 100)
end

-- ===================================================================== --
-- 2. CONFIGURATION & STATE MANAGEMENT
-- ===================================================================== --
local F = {
	cfgName = "MofenkUltimateConfigV125", autoLoadEnabled = true,
	smartPlannerActive = true, adaptiveDebounce = true,
	-- Farm & Plot
	collect = true, levelup = true, maxLevel = 50, smartLevel = true,
	rebirth = true, upgrades = true, buyDice = true, equipDice = true, autoRoll = true,
	autoBestPlaceBase = true, smartPlace = true,
	-- Inventory & Auto Sell / Lock / Fuse
	sellAuto = true, sellMaxInvent = true, keepBest = 5, autoFuse = true,
	keepRarities = {"Mythic", "Secret", "Divine", "Godly"},
	autoLockRarity = true, specificSellUnits = {},
	-- Potions & Economy Forecasting
	potionAuto = true, potionBest = true, potionSpecific = {"Luck Potion", "Damage Potion"},
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
	-- Webhook & Telemetry Sync
	webhookEnabled = false, webhookUrl = "", floatingHud = true
}

local STATE = {
	towerLive = "Standby", towerFloor = 0, towerDrops = 0, towerTraitsGot = "Belum Ada",
	hauntedLive = "Standby", hauntedFloor = 0, hauntedDrops = 0, activeBuffs = "Tidak Ada",
	pingMs = 0, fpsCurrent = 60,
	aiDecision = "Initializing Ultimate Autonomous Ecosystem...",
	incomePerSec = 0, timeToNextRebirth = "Calculating..."
}

local GLASS_THEME = {
	Bg     = Color3.fromRGB(8, 14, 26),
	Card   = Color3.fromRGB(15, 25, 45),
	Header = Color3.fromRGB(11, 18, 32),
	Acc1   = Color3.fromRGB(0, 195, 255),
	Acc2   = Color3.fromRGB(37, 99, 235),
	Text   = Color3.fromRGB(241, 245, 249),
	SubText= Color3.fromRGB(148, 163, 184)
}

-- ===================================================================== --
-- 3. SAFE REMOTE BINDINGS & CLOUD/LOCAL CONFIG SYNC
-- ===================================================================== --
local Network = nil
pcall(function() Network = ReplicatedStorage:WaitForChild("Network", 5) end)

local function SafeProbe(serviceName, remoteName)
	local r = nil
	pcall(function()
		if Network and Network:FindFirstChild(serviceName) then
			r = Network[serviceName]:FindFirstChild(remoteName, true)
		end
	end)
	return r
end

local R = {
	RollDice        = SafeProbe("RollService", "RollDice"),
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
	SellInventory   = SafeProbe("SellService", "SellInventory"),
	Fuse            = SafeProbe("FusingService", "Fuse"),
	InteractSlot    = SafeProbe("PlotService", "InteractSlot"),
	EquipUnit       = SafeProbe("UnitService", "Equip"),
	LockUnit        = SafeProbe("UnitService", "SetLock") or SafeProbe("InventoryService", "Lock"),
	HWTeleport      = SafeProbe("HalloweenService", "Teleport"),
	HWSeenIntro     = SafeProbe("HalloweenService", "SeenIntro"),
	HWQuestClaim    = SafeProbe("HalloweenQuestService", "Claim"),
	HWClaimPath     = SafeProbe("HalloweenService", "ClaimAllPath"),
	HWBuyOffer      = SafeProbe("HalloweenService", "BuyOffer"),
	TrickOrTreat    = SafeProbe("TrickOrTreatService", "Knocked"),
	PumpkinRoll     = SafeProbe("PumpkinDiceService", "Roll"),
	PumpkinAutoSell = SafeProbe("PumpkinDiceService", "SetAutoSell"),
	RedeemCode      = SafeProbe("CodesService", "RedeemCode") or SafeProbe("MonetizationService", "RedeemCode"),
	QuestClaim      = SafeProbe("QuestService", "Claim"),
	ClaimDaily      = SafeProbe("DailyRewardService", "Claim"),
	ClaimOffline    = SafeProbe("OfflineEarningsService", "Claim"),
	ClaimGroup      = SafeProbe("GroupRewardService", "Claim")
}

local function SendWebhook(title, desc, color)
	if not F.webhookEnabled or F.webhookUrl == "" then return end
	local req = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
	if req then
		pcall(function()
			req({
				Url = F.webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"},
				Body = HttpService:JSONEncode({ username = "MofenkHub Autonomous AI", embeds = {{ title = title, description = desc, color = color or 3447003, footer = {text = "Player: " .. LocalPlayer.Name} }} })
			})
		end)
	end
end

local function SafeCall(remoteObj, ...)
	if not remoteObj then return false end
	local args = {...}
	local ok, res = DiagnosticHub:SafeExecute("RemoteCall", function()
		if remoteObj:IsA("RemoteEvent") then
			remoteObj:FireServer(unpack(args))
			return true
		elseif remoteObj:IsA("RemoteFunction") then
			return remoteObj:InvokeServer(unpack(args))
		end
	end)
	return ok, res
end

local G = {}
pcall(function()
	local Framework = ReplicatedStorage:WaitForChild("Framework", 5)
	if Framework then
		G.DC = require(Framework.Features.Data.DataController)
		G.PlotConfig = require(Framework.Features.Plot.PlotConfig)
		G.UnitUtil = require(Framework.Features.Inventory.Kinds.Unit.UnitUtil)
		G.Rebirths = require(Framework.Features.Rebirth.Rebirths)
		G.BoostConfig = require(Framework.Features.Inventory.Kinds.Boost.BoostConfig)
		G.BuffController = require(Framework.Features.Buffs.BuffController)
		G.EntryRegistry = require(Framework.Features.Inventory.EntryRegistry)
		G.UnitConfig = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig)
		G.DiceModule = require(Framework.Features.Rolling.Dice)
		G.TowersConfig = require(Framework.Features.Towers.Towers)
		G.GradesMod = require(Framework.Features.Grades.Grades)
		G.TraitsMod = require(Framework.Features.Traits.Traits)
		G.QuestConfig = require(Framework.Features.Quests.QuestConfig)
	end
end)

local function data() return (G.DC and G.DC.___X) or {} end
local function money() pcall(function() return G.DC.Money() end); return data().Money or 0 end
local function level() pcall(function() return G.DC.Level() end); return data().Level or 1 end
local function rebirthAmt() pcall(function() return G.DC.Rebirth() end); return data().Rebirth or 0 end
local function inventory() return data().Inventory or {} end
local function slots() return data().Slots or {} end
local function isUnitEntry(e) return e and type(e)=="table" and e.name and G.EntryRegistry and pcall(function() return G.EntryRegistry.getEntryConfig(e.name).kind == "Unit" end) end

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
	local e = G.UnitConfig and G.UnitConfig.entries and G.UnitConfig.entries[u.name]
	if not e then return 0 end
	local a = u.attributes or {}
	local lvlNum = tonumber(a.level) or 1
	local ok, inc = pcall(function()
		if e.income then return e.income({ mutation = a.mutation or a.quirk, grade = a.grade, trait = a.trait, level = lvlNum }) end
		return 0
	end)
	return tonumber(inc) or 0
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
-- 4. CORVUS TASK QUEUE & WATCHDOG CRASH RECOVERY
-- ===================================================================== --
local SmartPlanner = {
	IsBusy = false,
	TaskQueue = {},
	Priority = { CRITICAL = 1, EVENT = 2, STRATEGY = 3, PROGRESS = 4, OPTIMIZE = 5, COMPETITIVE = 6, FARM = 7 },
	LastActivity = os.clock()
}

function SmartPlanner:AddTask(id, prio, action, desc)
	for _, t in ipairs(self.TaskQueue) do if t.Id == id then return end end
	table.insert(self.TaskQueue, { Id = id, Priority = prio, Action = action, Desc = desc })
	table.sort(self.TaskQueue, function(a, b) return a.Priority < b.Priority end)
end

function SmartPlanner:EvaluateEnvironment()
	if not F.smartPlannerActive then return end
	local inv = inventory()

	local totalInc = 0
	for _, slot in pairs(slots()) do
		if slot.unitId and inv[slot.unitId] then
			totalInc += baseIncome(inv[slot.unitId])
		end
	end
	STATE.incomePerSec = totalInc

	pcall(function()
		local nr = G.Rebirths.GetNext(rebirthAmt())
		if nr and nr.cost then
			local diff = nr.cost - money()
			if diff <= 0 then STATE.timeToNextRebirth = "Ready Now!"
			elseif totalInc > 0 then STATE.timeToNextRebirth = string.format("~%d secs", math.ceil(diff / totalInc))
			else STATE.timeToNextRebirth = "Stalled (No Income)" end
		end
	end)

	local totalOwned = 0
	for _, e in pairs(inv) do if isUnitEntry(e) then totalOwned += 1 end end
	
	if (totalOwned >= 85 and F.sellMaxInvent) or F.sellAuto then
		self:AddTask("CLEAR_INVENTORY", self.Priority.CRITICAL, function()
			STATE.aiDecision = "P1: Inventory Penuh -> Auto Sell & Fuse"
			local sellList = {}
			local safeUnits = {}
			for _, s in pairs(slots()) do if s.unitId then safeUnits[s.unitId] = true end end
			for _, id in pairs(data().TowerTeam or {}) do safeUnits[id] = true end

			for id, u in pairs(inv) do
				if isUnitEntry(u) and not safeUnits[id] then
					local isLocked = u.attributes and u.attributes.locked
					local r = getUnitRarity(u.name)
					local isKeep = false
					for _, kr in ipairs(F.keepRarities) do
						if string.lower(r) == string.lower(kr) then isKeep = true break end
					end
					if not isLocked and not isKeep then table.insert(sellList, id) end
				end
				if #sellList >= 120 then break end
			end

			if #sellList > 0 then SafeCall(R.SellInventory, sellList) end
			if F.autoFuse then SafeCall(R.Fuse) end
			task.wait(1)
		end, "Clear Inventory & Fuse")
	end

	if F.halloweenTeleport or F.pumpkinAutoRoll then
		self:AddTask("HALLOWEEN_EVENTS", self.Priority.EVENT, function()
			STATE.aiDecision = "P2: Event Halloween & Pumpkin Roll"
			if F.halloweenTeleport and R.HWTeleport then SafeCall(R.HWTeleport) end
			if F.pumpkinAutoRoll and R.PumpkinRoll then
				for i = 1, (F.pumpkinRollQty or 1) do SafeCall(R.PumpkinRoll); task.wait(0.2) end
			end
			if F.trickOrTreat and R.TrickOrTreat then SafeCall(R.TrickOrTreat) end
			if F.halloweenQuest and R.HWQuestClaim then SafeCall(R.HWQuestClaim) end
			if F.halloweenPath and R.HWClaimPath then SafeCall(R.HWClaimPath) end
			task.wait(0.5)
		end, "Halloween Automation")
	end

	if F.potionAuto then
		self:AddTask("POTION_MANAGER", self.Priority.STRATEGY, function()
			STATE.aiDecision = "P3: Potion Manager (Luck Boost)"
			local activeBuffs = G.BuffController and G.BuffController.ActiveBuffs or {}
			local hasLuck = false
			for bName, _ in pairs(activeBuffs) do if string.find(string.lower(bName), "luck") then hasLuck = true break end end

			if not hasLuck then
				for id, item in pairs(inv) do
					if item.name and string.find(string.lower(item.name), "luck") then
						SafeCall(R.BoostUse, id)
						SendWebhook("🧪 Potion Activated!", "Successfully consumed Luck Potion.", 3447003)
						break
					end
				end
			end
			task.wait(0.5)
		end, "Potion Manager")
	end

	if F.rebirth and (level() >= 100 or money() >= 1e6) then
		self:AddTask("REBIRTH_PROGRESS", self.Priority.PROGRESS, function()
			STATE.aiDecision = "P4: Rebirth & Dice Upgrade"
			SafeCall(R.Rebirth)
			SendWebhook("🔄 Rebirth Executed!", "Successfully performed rebirth.", 65280)
			if F.buyDice and G.DiceModule and R.BuyDice and R.EquipDice then
				pcall(function()
					local all = G.DiceModule.GetAll()
					for key, def in pairs(all) do
						if def.price and money() >= def.price then
							SafeCall(R.BuyDice, key); task.wait(0.2); SafeCall(R.EquipDice, key)
						end
					end
				end)
			end
			task.wait(1.5)
		end, "Rebirth & Dice Upgrade")
	end

	if F.traitAuto or F.gradeAuto or F.quirkAuto then
		self:AddTask("SNIPER_REROLL", self.Priority.OPTIMIZE, function()
			STATE.aiDecision = "P5: Sniper Reroll (Trait/Grade/Quirk)"
			local topId, topScore = nil, -1
			for id, u in pairs(inv) do
				if isUnitEntry(u) then
					local s = baseIncome(u)
					if s > topScore then topScore = s; topId = id end
				end
			end

			if topId then
				if F.traitAuto and R.TraitRoll then SafeCall(R.TraitRoll, topId) end
				if F.gradeAuto and R.GradeRoll and money() > (F.gemReserve or 50) then SafeCall(R.GradeRoll, topId) end
				if F.quirkAuto and R.QuirkRoll then SafeCall(R.QuirkRoll, topId) end
			end
			task.wait(0.5)
		end, "Sniper Stat Optimization")
	end

	if F.tower or F.hauntedTower then
		self:AddTask("TOWER_PUSH", self.Priority.COMPETITIVE, function()
			STATE.aiDecision = "P6: Tower & Haunted Tower Assault"
			if F.tower and R.PlayTower then
				if F.towerEquipBest and R.BestTowerTeam then SafeCall(R.BestTowerTeam) end
				SafeCall(R.PlayTower, F.towerList[1] or "Dragon Tower")
			end
			task.wait(2)
		end, "Tower Assault")
	end

	self:AddTask("BASELINE_FARM", self.Priority.FARM, function()
		STATE.aiDecision = "P7: Baseline Farming (Roll, Collect, Quests)"
		if F.autoRoll and R.RollDice then SafeCall(R.RollDice) end
		if F.collect and R.CollectBalance then
			for i = 1, 15 do SafeCall(R.CollectBalance, i) end
		end
		if F.autoBestPlaceBase and R.EquipBestPlot then SafeCall(R.EquipBestPlot) end
		if F.claimQuests and R.ClaimDaily then
			SafeCall(R.ClaimDaily); SafeCall(R.ClaimOffline); SafeCall(R.ClaimGroup)
		end
		if F.codesAuto and R.RedeemCode then
			local codes = {"RELEASE", "UPDATE1", "UPDATE2", "UPDATE3", "UPDATE4", "1KCCU", "5KCCU"}
			for _, c in ipairs(codes) do SafeCall(R.RedeemCode, c); task.wait(0.2) end
		end
		task.wait(F.adaptiveDebounce and 0.3 or 0.1)
	end, "Baseline Farming Loop")
end

-- ===================================================================== --
-- 5. UI DASHBOARD, FLOATING MINI HUD & ERROR CONSOLE VIEWER
-- ===================================================================== --
local ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "MofenkToggleFront"; ToggleGui.Parent = parentGui; ToggleGui.ResetOnSpawn = false
ToggleGui.DisplayOrder = 99999
local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = ToggleGui; ToggleBtn.Size = UDim2.new(0, 64, 0, 64); ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = GLASS_THEME.Card; ToggleBtn.Text = "🧠"; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 28; ToggleBtn.TextColor3 = GLASS_THEME.Acc1; ToggleBtn.ZIndex = 99999
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 18)
Instance.new("UIStroke", ToggleBtn).Color = GLASS_THEME.Acc1

-- Floating Mini HUD
local HudGui = Instance.new("ScreenGui"); HudGui.Name = "MofenkFloatingHud"; HudGui.Parent = parentGui; HudGui.ResetOnSpawn = false
local MiniHud = Instance.new("TextButton"); MiniHud.Parent = HudGui; MiniHud.Size = UDim2.new(0, 220, 0, 50); MiniHud.Position = UDim2.new(0.02, 0, 0.3, 0)
MiniHud.BackgroundColor3 = GLASS_THEME.Card; MiniHud.TextColor3 = GLASS_THEME.Text; MiniHud.TextSize = 11; MiniHud.Font = Enum.Font.Code
MiniHud.TextXAlignment = Enum.TextXAlignment.Left; MiniHud.TextYAlignment = Enum.TextYAlignment.Center; MiniHud.Active = true; MiniHud.Draggable = true
Instance.new("UICorner", MiniHud).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MiniHud).Color = GLASS_THEME.Acc1

task.spawn(function()
	while generation == _G.__ANIMEDICE do
		MiniHud.Visible = F.floatingHud
		MiniHud.Text = string.format(" 🧠 Mofenk AI [HUD]
 💰 Inc: $%s/s | ⏱️ Reb: %s", FormatMoney(STATE.incomePerSec), STATE.timeToNextRebirth)
		task.wait(0.5)
	end
end)

local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkV125Hub"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui; MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 960, 0, 620); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false
MainFrame.BackgroundColor3 = GLASS_THEME.Bg; MainFrame.BackgroundTransparency = 0.08
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 18)
Instance.new("UIStroke", MainFrame).Color = GLASS_THEME.Acc1

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 54); TopBar.BackgroundColor3 = GLASS_THEME.Header
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 18)

local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 20, 0, 0); Title.Size = UDim2.new(0, 600, 1, 0)
Title.Text = "👑 MOFENKHUB V125.0 | DIAGNOSTIC TELEMETRY & ERROR CONSOLE"; Title.TextColor3 = GLASS_THEME.Acc1; Title.TextSize = 12; Title.Font = Enum.Font.GothamBlack; Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -48, 0, 11); CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Text = "✕"; CloseBtn.TextColor3 = GLASS_THEME.Text; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BackgroundColor3 = GLASS_THEME.Card
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local ConsoleBox = Instance.new("TextLabel"); ConsoleBox.Parent = MainFrame; ConsoleBox.Position = UDim2.new(0, 20, 0, 70); ConsoleBox.Size = UDim2.new(1, -40, 0, 110)
ConsoleBox.BackgroundColor3 = GLASS_THEME.Card; ConsoleBox.TextColor3 = GLASS_THEME.Text; ConsoleBox.TextSize = 11; ConsoleBox.Font = Enum.Font.Code
ConsoleBox.TextXAlignment = Enum.TextXAlignment.Left; ConsoleBox.TextYAlignment = Enum.TextYAlignment.Top; ConsoleBox.TextWrapped = true
Instance.new("UICorner", ConsoleBox).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", ConsoleBox).Color = GLASS_THEME.Acc1

-- Error Log Scrolling Console Viewer in UI
local ErrorTitle = Instance.new("TextLabel"); ErrorTitle.Parent = MainFrame; ErrorTitle.Position = UDim2.new(0, 20, 0, 190); ErrorTitle.Size = UDim2.new(1, -40, 0, 20)
ErrorTitle.Text = "🚨 REAL-TIME ERROR LOG & DIAGNOSTIC CONSOLE:"; ErrorTitle.TextColor3 = Color3.fromRGB(255, 100, 100); ErrorTitle.TextSize = 11; ErrorTitle.Font = Enum.Font.GothamBold; ErrorTitle.BackgroundTransparency = 1; ErrorTitle.TextXAlignment = Enum.TextXAlignment.Left

local LogScroll = Instance.new("ScrollingFrame"); LogScroll.Parent = MainFrame; LogScroll.Position = UDim2.new(0, 20, 0, 215); LogScroll.Size = UDim2.new(1, -40, 0, 180)
LogScroll.BackgroundColor3 = GLASS_THEME.Card; LogScroll.ScrollBarThickness = 4; LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; LogScroll.CanvasSize = UDim2.new(0,0,0,0)
Instance.new("UICorner", LogScroll).CornerRadius = UDim.new(0, 10)
local LogLayout = Instance.new("UIListLayout"); LogLayout.Parent = LogScroll; LogLayout.Padding = UDim.new(0, 4)

task.spawn(function()
	while generation == _G.__ANIMEDICE do
		local m = money(); local lvl = level(); local rb = rebirthAmt()
		local ic = 0; for _ in pairs(inventory()) do ic += 1 end
		ConsoleBox.Text = string.format(
			"📊 TELEMETRY | Health: %.1f%% | Success: %d | Errors: %d
💰 Money: %s | Lvl: %d | Rebirth: %d | Storage: %d/100
📈 Income: $%s/s | ⏱️ Time to Rebirth: %s
🧠 Directive: %s | Queue: %d Ops",
			DiagnosticHub:GetHealthScore(), DiagnosticHub.SuccessCount, DiagnosticHub.ErrorCount,
			FormatMoney(m), lvl, rb, ic, FormatMoney(STATE.incomePerSec), STATE.timeToNextRebirth, STATE.aiDecision, #SmartPlanner.TaskQueue
		)
		
		pcall(function()
			for _, v in pairs(LogScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
			if #DiagnosticHub.ErrorHistory == 0 then
				local lbl = Instance.new("TextLabel"); lbl.Parent = LogScroll; lbl.Size = UDim2.new(1, 0, 0, 28); lbl.BackgroundTransparency = 1
				lbl.Text = " ✅ Status Sistem Bersih: Belum ada eror tercatat."; lbl.TextColor3 = Color3.fromRGB(0, 255, 150)
				lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left
			else
				for _, errInfo in ipairs(DiagnosticHub.ErrorHistory) do
					local lbl = Instance.new("TextLabel"); lbl.Parent = LogScroll; lbl.Size = UDim2.new(1, 0, 0, 42); lbl.BackgroundTransparency = 1
					lbl.Text = string.format("[%s] [%s] %s
-> %s", errInfo.Time, errInfo.Tag, errInfo.Message, errInfo.Error or "")
					lbl.TextColor3 = Color3.fromRGB(255, 100, 100); lbl.Font = Enum.Font.Code; lbl.TextSize = 10
					lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Top; lbl.TextWrapped = true
				end
			end
		end)
		task.wait(0.5)
	end
end)

-- Background Coroutines & Watchdog Guard
task.spawn(function()
	while generation == _G.__ANIMEDICE do
		pcall(function() SmartPlanner:EvaluateEnvironment() end)
		task.wait(0.4)
	end
end)

task.spawn(function()
	while generation == _G.__ANIMEDICE do
		if not SmartPlanner.IsBusy and #SmartPlanner.TaskQueue > 0 then
			local taskItem = table.remove(SmartPlanner.TaskQueue, 1)
			SmartPlanner.IsBusy = true
			DiagnosticHub:SafeExecute("TaskExec:"..taskItem.Id, taskItem.Action)
			SmartPlanner.IsBusy = false
			SmartPlanner.LastActivity = os.clock()
		end
		task.wait(0.1)
	end
end)

-- Watchdog Guard (Auto-Reconnect / Crash Recovery if frozen > 30s)
task.spawn(function()
	while generation == _G.__ANIMEDICE do
		task.wait(10)
		if os.clock() - SmartPlanner.LastActivity > 30 then
			DiagnosticHub:Log("Watchdog", "Bot freeze detected! Reconnecting...")
			pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
		end
	end
end)

LocalPlayer.Idled:Connect(function()
	if F.afk then
		pcall(function()
			VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
			task.wait(1)
			VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
		end)
	end
end)

print("[MOFENKHUB V125.0] DIAGNOSTIC TELEMETRY & ERROR CONSOLE ONLINE.")
