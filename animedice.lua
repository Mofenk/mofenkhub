-- ===================================================================== --
-- 👑 MOFENKHUB V124.0 — THE ULTIMATE AUTONOMOUS OMNISCIENT ECOSYSTEM
-- Game: Anime Dice | Complete Feature Integration + Floating Mini HUD + Adaptive Debounce
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
-- 1. FULL COMPREHENSIVE CONFIGURATION & ADAPTIVE STATE
-- ===================================================================== --
local F = {
	cfgName = "MofenkUltimateConfigV124", autoLoadEnabled = true,
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
-- 2. SAFE REMOTE BINDINGS & CLOUD/LOCAL CONFIG SYNC
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
	local ok, res = pcall(function()
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
-- 3. CORVUS TASK QUEUE & FORECASTING ENGINE
-- ===================================================================== --
local SmartPlanner = {
	IsBusy = false,
	TaskQueue = {},
	Priority = { CRITICAL = 1, EVENT = 2, STRATEGY = 3, PROGRESS = 4, OPTIMIZE = 5, COMPETITIVE = 6, FARM = 7 }
}

function SmartPlanner:AddTask(id, prio, action, desc)
	for _, t in ipairs(self.TaskQueue) do if t.Id == id then return end end
	table.insert(self.TaskQueue, { Id = id, Priority = prio, Action = action, Desc = desc })
	table.sort(self.TaskQueue, function(a, b) return a.Priority < b.Priority end)
end

function SmartPlanner:EvaluateEnvironment()
	if not F.smartPlannerActive then return end
	local inv = inventory()

	-- Calculate total income per second
	local totalInc = 0
	for _, slot in pairs(slots()) do
		if slot.unitId and inv[slot.unitId] then
			totalInc += baseIncome(inv[slot.unitId])
		end
	end
	STATE.incomePerSec = totalInc

	-- Forecast time to next rebirth
	pcall(function()
		local nr = G.Rebirths.GetNext(rebirthAmt())
		if nr and nr.cost then
			local diff = nr.cost - money()
			if diff <= 0 then
				STATE.timeToNextRebirth = "Ready Now!"
			elseif totalInc > 0 then
				local secs = math.ceil(diff / totalInc)
				STATE.timeToNextRebirth = string.format("~%d secs", secs)
			else
				STATE.timeToNextRebirth = "Stalled (No Income)"
			end
		end
	end)

	-- [P1] CRITICAL: INVENTORY CAPACITY & AUTO FUSE / SELL
	local totalOwned = 0
	for _, e in pairs(inv) do if isUnitEntry(e) then totalOwned += 1 end end
	
	if (totalOwned >= 85 and F.sellMaxInvent) or F.sellAuto then
		self:AddTask("CLEAR_INVENTORY", self.Priority.CRITICAL, function()
			STATE.aiDecision = "P1: Inventory Penuh/Active -> Auto Sell & Fuse"
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

	-- [P2] EVENT: HALLOWEEN & PUMPKIN DICE
	if F.halloweenTeleport or F.pumpkinAutoRoll then
		self:AddTask("HALLOWEEN_EVENTS", self.Priority.EVENT, function()
			STATE.aiDecision = "P2: Event Halloween & Pumpkin Roll"
			if F.halloweenTeleport and R.HWTeleport then SafeCall(R.HWTeleport) end
			if F.pumpkinAutoRoll and R.PumpkinRoll then
				for i = 1, (F.pumpkinRollQty or 1) do
					SafeCall(R.PumpkinRoll)
					task.wait(0.2)
				end
			end
			if F.trickOrTreat and R.TrickOrTreat then SafeCall(R.TrickOrTreat) end
			if F.halloweenQuest and R.HWQuestClaim then SafeCall(R.HWQuestClaim) end
			if F.halloweenPath and R.HWClaimPath then SafeCall(R.HWClaimPath) end
			if F.halloweenOffer and R.HWBuyOffer then SafeCall(R.HWBuyOffer) end
			task.wait(0.5)
		end, "Halloween & Pumpkin Automation")
	end

	-- [P3] STRATEGY: POTION & BUFF MANAGER
	if F.potionAuto then
		self:AddTask("POTION_MANAGER", self.Priority.STRATEGY, function()
			STATE.aiDecision = "P3: Potion Manager (Maximizing Luck)"
			local activeBuffs = G.BuffController and G.BuffController.ActiveBuffs or {}
			local hasLuck = false
			for bName, _ in pairs(activeBuffs) do
				if string.find(string.lower(bName), "luck") then hasLuck = true break end
			end

			if not hasLuck then
				for id, item in pairs(inv) do
					if item.name and string.find(string.lower(item.name), "luck") then
						SafeCall(R.BoostUse, id)
						SendWebhook("🧪 Potion Activated!", "Successfully consumed Luck Potion to boost rolls.", 3447003)
						break
					end
				end
			end
			task.wait(0.5)
		end, "Potion Manager")
	end

	-- [P4] PROGRESSION: REBIRTH & DICE SHOP
	if F.rebirth and (level() >= 100 or money() >= 1e6) then
		self:AddTask("REBIRTH_PROGRESS", self.Priority.PROGRESS, function()
			STATE.aiDecision = "P4: Rebirth & Dice Upgrade"
			SafeCall(R.Rebirth)
			SendWebhook("🔄 Rebirth Executed!", "Successfully performed rebirth to scale multiplier.", 65280)
			if F.buyDice and G.DiceModule and R.BuyDice and R.EquipDice then
				pcall(function()
					local all = G.DiceModule.GetAll()
					for key, def in pairs(all) do
						if def.price and money() >= def.price then
							SafeCall(R.BuyDice, key)
							task.wait(0.2)
							SafeCall(R.EquipDice, key)
						end
					end
				end)
			end
			task.wait(1.5)
		end, "Rebirth & Dice Upgrade")
	end

	-- [P5] OPTIMIZATION: SNIPER REROLL
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

	-- [P6] COMPETITIVE: TOWER PUSHING
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

	-- [P7] BASELINE FARMING
	self:AddTask("BASELINE_FARM", self.Priority.FARM, function()
		STATE.aiDecision = "P7: Baseline Farming (Auto Roll, Collect, Quests)"
		if F.autoRoll and R.RollDice then SafeCall(R.RollDice) end
		if F.collect and R.CollectBalance then
			for i = 1, 15 do SafeCall(R.CollectBalance, i) end
		end
		if F.autoBestPlaceBase and R.EquipBestPlot then SafeCall(R.EquipBestPlot) end
		if F.claimQuests and R.ClaimDaily then
			SafeCall(R.ClaimDaily)
			SafeCall(R.ClaimOffline)
			SafeCall(R.ClaimGroup)
		end
		if F.codesAuto and R.RedeemCode then
			local codes = {"RELEASE", "UPDATE1", "UPDATE2", "UPDATE3", "UPDATE4", "1KCCU", "5KCCU"}
			for _, c in ipairs(codes) do SafeCall(R.RedeemCode, c); task.wait(0.2) end
		end
		task.wait(F.adaptiveDebounce and 0.3 or 0.1)
	end, "Baseline Farming Loop")
end

-- ===================================================================== --
-- 4. UI DASHBOARD & FLOATING MINI HUD
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

local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkV124Hub"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false
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
Title.Text = "👑 MOFENKHUB V124.0 | THE ULTIMATE AUTONOMOUS ECOSYSTEM"; Title.TextColor3 = GLASS_THEME.Acc1; Title.TextSize = 13; Title.Font = Enum.Font.GothamBlack; Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -48, 0, 11); CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Text = "✕"; CloseBtn.TextColor3 = GLASS_THEME.Text; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BackgroundColor3 = GLASS_THEME.Card
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local ConsoleBox = Instance.new("TextLabel"); ConsoleBox.Parent = MainFrame; ConsoleBox.Position = UDim2.new(0, 20, 0, 70); ConsoleBox.Size = UDim2.new(1, -40, 0, 140)
ConsoleBox.BackgroundColor3 = GLASS_THEME.Card; ConsoleBox.TextColor3 = GLASS_THEME.Text; ConsoleBox.TextSize = 11; ConsoleBox.Font = Enum.Font.Code
ConsoleBox.TextXAlignment = Enum.TextXAlignment.Left; ConsoleBox.TextYAlignment = Enum.TextYAlignment.Top; ConsoleBox.TextWrapped = true
Instance.new("UICorner", ConsoleBox).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", ConsoleBox).Color = GLASS_THEME.Acc1

task.spawn(function()
	while generation == _G.__ANIMEDICE do
		local m = money(); local lvl = level(); local rb = rebirthAmt()
		local ic = 0; for _ in pairs(inventory()) do ic += 1 end
		ConsoleBox.Text = string.format(
			"📊 TELEMETRY & ECONOMIC FORECASTING
💰 Money: %s | ⭐ Lvl: %d | 🔄 Rebirth: %d | 🎒 Storage: %d/100
📈 Income: $%s/s | ⏱️ Time to Next Rebirth: %s

🧠 OMNISCIENT AI DISPATCH (CORVUS QUEUE)
➤ Current Directive: %s
➤ Pending Task Queue: %d Operations Active",
			FormatMoney(m), lvl, rb, ic, FormatMoney(STATE.incomePerSec), STATE.timeToNextRebirth, STATE.aiDecision, #SmartPlanner.TaskQueue
		)
		task.wait(0.3)
	end
end)

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
			pcall(taskItem.Action)
			SmartPlanner.IsBusy = false
		end
		task.wait(0.1)
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

print("[MOFENKHUB V124.0] ULTIMATE AUTONOMOUS ECOSYSTEM ONLINE.")
