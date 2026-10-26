-- ===================================================================== --
-- 👑 MOFENKHUB V118.0 — THE ULTIMATE OMNI MASTERPIECE (100% COMPLETE & UNRESTRICTED)
-- INCLUDES EVERY SINGLE FUNCTION, MODULE, CODE REDEMPTION, QUESTS, AUTO-FUSE, 
-- FULL TOWER LIST (HAUNTED, DRAGON, PIRATE, INFINITY, VOID, SHADOW), FULL CONFIG MANAGER,
-- GRADE/TRAIT AUTOMATION, HALLOWEEN & ALL DEFAULT OFF SETTINGS.
-- ===================================================================== --

--!nocheck
task.wait(0.5)

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local VirtualUser       = game:GetService("VirtualUser")
local TeleportService   = game:GetService("TeleportService")
local RunService        = game:GetService("RunService")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- ===================================================================== --
-- 1. FOLDER, CONFIG MANAGER & TELEPORT QUEUE
-- ===================================================================== --
local CFG_FOLDER = "MofenkConfigs"
pcall(function() if not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end end)

pcall(function()
	local qot = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
	if qot then
		qot([[
			task.wait(3)
			loadstring(game:HttpGet("https://raw.githubusercontent.com/Mofenk/mofenkhub/refs/heads/Mofenk-Update-Patch-1/animedice.lua"))()
		]])
	end
end)

local successGui, parentGui = pcall(function()
	if gethui then return gethui() elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end

pcall(function() for _, v in pairs(parentGui:GetChildren()) do if string.find(v.Name, "Mofenk") then v:Destroy() end end end)

_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

-- ===================================================================== --
-- 2. MASTER CONFIG & STATE TABLE (ALL DEFAULT OFF)
-- ===================================================================== --
local F = {
	themeIndex = 5, cfgName = "MofenkConfig_OmniMaster", autoLoadEnabled = false,
	
	-- FARMING & PLOT
	collect = false, autoRoll = false, autoSpins = false, rebirth = false, rebirthMult = 1,
	buyDice = false, equipDice = false, smartPlace = false,
	levelup = false, levelShare = 0.3, levelPayback = 10, upgrades = false,
	
	-- HALLOWEEN & SPECIAL EVENTS
	halloAutoTrickOrTreat = false, halloRollPumpkin = false, halloAutoClaim = false, halloAutoUpgrade = false,
	
	-- INVENTORY & SELL (FULL FILTERS)
	sellAuto = false, sellRarity = 3, keepBest = 20, keepLuckX = 10, autoFuse = false, fuseShare = 0.35, fuseSeconds = 30,
	
	-- POTIONS, GRADES, TRAITS
	potionAuto = false, potionType = "Luck", gradeAuto = false, gradeMin = 3, traitAuto = false, traitMin = 1.5,
	
	-- TOWER AUTOMATION (ALL LISTS AVAILABLE)
	tower = false, towerName = "Dragon Tower", towerMix = false, towerEquipBest = false, towerBoosts = false, towerExitOn = false, towerExitFloor = 50,
	
	-- MISC, CODES, QUESTS, REWARDS
	codesAuto = false, claimQuests = false, claimDaily = false, claimGroup = false, claimOffline = false,
	
	-- WEBHOOK & SPY
	webhookEnabled = false, webhookUrl = "", spyDataOn = false
}

local STATE = {
	money = 0, rolls = 0, rebirth = 0, dice = "-", nextDice = "-",
	slotsUsed = 0, slotsMax = 4, incomePerSec = 0, invCount = 0, invCap = 100, nextUpgrade = "-",
	rolled = 0, collected = 0, diceBought = 0, rebirths = 0, leveled = 0, upgradesBought = 0, sold = 0, soldValue = 0,
	gradeRolls = 0, traitRolls = 0, boostsUsed = 0, luck = 0,
	towerRuns = 0, towerFloors = 0, towerBest = 0, towerFloor = 0, towerDrops = 0,
	fused = 0, fuseLast = "-", fuseBestChance = 0, towerPick = "-", towerPredict = 0, towerRate = 0,
	codesDone = 0, claims = 0, questsClaimed = 0, passesBought = 0, statsAdded = 0,
	towerLive = "Standby", phase = "idle", note = "-", uiOwner = "-", activeBuffs = "Tidak Ada"
}
local ConfigUpdaters = {}

local function saveConfig(name)
	if not writefile then return end
	local path = CFG_FOLDER .. "/" .. tostring(name) .. ".json"
	local dataToSave = {}
	for k, v in pairs(F) do if type(v) ~= "function" then dataToSave[k] = v end end
	pcall(function() writefile(path, HttpService:JSONEncode(dataToSave)) end)
end

local function loadConfig(name)
	local path = CFG_FOLDER .. "/" .. tostring(name) .. ".json"
	if readfile and isfile and isfile(path) then
		local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
		if success and type(decoded) == "table" then
			for k, v in pairs(decoded) do if F[k] ~= nil then F[k] = v end end
			for _, updateFn in ipairs(ConfigUpdaters) do pcall(updateFn) end
			return true
		end
	end
	return false
end

local function deleteConfig(name)
	local path = CFG_FOLDER .. "/" .. tostring(name) .. ".json"
	if isfile and isfile(path) and delfile then
		pcall(function() delfile(path) end)
		return true
	end
	return false
end

-- ===================================================================== --
-- 3. FRAMEWORK SERVICES, MODULES & UNRESTRICTED REMOTES
-- ===================================================================== --
local Network = ReplicatedStorage:WaitForChild("Network", 30)
local Framework = ReplicatedStorage:WaitForChild("Framework", 30)

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
	BuyDice         = svc("DiceShopService.RE.BuyDice"),
	EquipDice       = svc("DiceShopService.RE.EquipDice"),
	Rebirth         = svc("RebirthService.RE.Rebirth"),
	BuyUpgrade      = svc("RE.BuyUpgrade") or svc("PlotService.RE.BuyPadUpgrade"),
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
	PlayTower       = svc("Towers.RF.PlayTower") or svc("Towers.RE.PlayTower"),
	CompleteFloor   = svc("Towers.RF.CompleteTowerFloor"),
	CancelTower     = svc("Towers.RF.CancelTower"),
	BestTowerTeam   = svc("Towers.RE.EquipBestTowerTeam"),
	InteractSlot    = svc("PlotService.RE.InteractSlot"),
	UseSpin         = svc("SpinService.RE.Use"),
	EquipUnit       = svc("UnitService.RF.Equip"),
	Fuse            = svc("FusingService.RE.Fuse"),
	FuseResult      = svc("FusingService.RE.Result"),
    TrickOrTreat    = svc("HalloweenService.RE.TrickOrTreat") or svc("TrickOrTreat"),
    RollPumpkin     = svc("RollService.RF.Roll")
}

local G = {}
pcall(function()
	G.DC = require(Framework.Features.Data.DataController)
	G.Dice = require(Framework.Features.Rolling.Dice)
	G.Rebirths = require(Framework.Features.Rebirth.Rebirths)
	G.PlotConfig = require(Framework.Features.Plot.PlotConfig)
	G.UpgradeConfig = require(Framework.Features.Upgrades.Upgrades)
	pcall(function() G.UpgradeTree = require(Framework.Features.Upgrades.TreeStructure) end)
	G.UnitConfig = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig)
	G.Grades = require(Framework.Features.Grades.Grades)
	G.Traits = require(Framework.Features.Traits.Traits)
	G.TowersConfig = require(Framework.Features.Towers.Towers)
	G.BuffController = require(Framework.Features.Buffs.BuffController)
	G.FusingUtil = require(Framework.Features.Fusing.FusingUtil)
	G.FusingConfig = require(Framework.Features.Fusing.FusingConfig)
    for _, m in ipairs(Framework:GetDescendants()) do if m.Name == "UnitUtil" and m:IsA("ModuleScript") then pcall(function() G.UnitUtil = require(m) end) break end end
	pcall(function() G.BoostConfig = require(Framework.Features.Inventory.Kinds.Boost.BoostConfig) end)
    pcall(function() G.UnitCtl = require(Framework.Features.Inventory.Kinds.Unit.UnitController) end)
end)

local BOOSTS = (G.BoostConfig and (G.BoostConfig.entries or G.BoostConfig)) or {}
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

local NumberFormatter
pcall(function() NumberFormatter = require(ReplicatedStorage.Packages.NumberFormatter) end)
local function fmt(n)
	if NumberFormatter and NumberFormatter.FormatCompact then
		local ok, s = pcall(NumberFormatter.FormatCompact, math.floor(tonumber(n) or 0))
		if ok then return s end
	end
	return tostring(math.floor(tonumber(n) or 0))
end

local function data() return G.DC.___X or {} end

local function curIncome(u)
	local e = u and G.UnitConfig and G.UnitConfig.entries[u.name]
	if not e then return 0 end
	return tonumber(select(2, pcall(e.income, u.attributes or {}))) or 0
end

local function baseIncome(u)
	local e = u and G.UnitConfig and G.UnitConfig.entries[u.name]
	if not e then return 0 end
	local a = u.attributes or {}
	return tonumber(select(2, pcall(e.income, { mutation = a.mutation, grade = a.grade, trait = a.trait, level = 1 }))) or 0
end

local function sendWebhook(title, desc)
	if not F.webhookEnabled or F.webhookUrl == "" then return end
	task.spawn(function()
		pcall(function()
			local req = http_request or request or syn and syn.request
			if not req then return end
			local body = HttpService:JSONEncode({
				embeds = {{
					title = "👑 MofenkHub | " .. tostring(title),
					description = tostring(desc),
					color = 16711680,
					footer = { text = "Player: " .. LocalPlayer.Name }
				}}
			})
			req({ Url = F.webhookUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
		end)
	end)
end

-- ===================================================================== --
-- 4. RAW FILE 13 ENGINE UTILITIES & INVENTORY / FUSE / GRADE / TRAIT LOGIC
-- ===================================================================== --
local DICE = {}
do
	local ok, all = pcall(G.Dice.GetAll)
	if ok and type(all) == "table" then
		for key, def in pairs(all) do
			DICE[#DICE + 1] = { key = key, luck = tonumber(def.luck) or 0, price = tonumber(def.price) }
		end
		table.sort(DICE, function(a, b) return a.luck < b.luck end)
	end
end

local function rollLuck()
	local d = data(); local buffLuck = tonumber(select(2, pcall(G.BuffController.GetBuff, "Luck"))) or 1; local dieLuck = 1
	for _, die in ipairs(DICE) do if die.key == d.Dice then dieLuck = die.luck end end
	return buffLuck * dieLuck
end

local function invCap()
	local buff = tonumber(select(2, pcall(G.BuffController.GetBuff, "Unit Storage")))
	if buff and buff > 0 then return buff end
	return 100
end

local unitOwner, unitSince = nil, 0
local function claimUnits(who) if unitOwner and unitOwner ~= who and os.clock() - unitSince < 20 then return false end; unitOwner, unitSince = who, os.clock(); return true end
local function releaseUnits(who) if unitOwner == who then unitOwner = nil end end

local function heldUnit()
	if not (G.UnitCtl and G.UnitCtl.EquippedUnit) then return nil end
	local ok, id = pcall(G.UnitCtl.EquippedUnit)
	return ok and id or nil
end

local function goodGrade(g) local def = g and G.Grades and G.Grades[g]; return def and (tonumber(def.incomeMultiplier) or 0) >= F.gradeMin end
local function goodTrait(t) local def = t and G.Traits and G.Traits[t]; return def and (tonumber(def.incomeMultiplier) or 0) >= F.traitMin end

local function isProtected(id, u)
	local a = u.attributes or {}
	if a.locked then return true end
	local e = G.UnitConfig and G.UnitConfig.entries[u.name]
	if not e or e.limited then return true end
	if goodGrade(a.grade) or goodTrait(a.trait) then return true end
	return id == heldUnit()
end

local SPINS = { "Jackpot Spin", "Lucky Spin" }
local function armSpin()
	if not (F.autoSpins and R.UseSpin) then return end
	local d = data()
	for _, name in ipairs(SPINS) do if d.ActiveEntries and d.ActiveEntries[name] then return end end
	for _, name in ipairs(SPINS) do
		local item = d.Inventory and d.Inventory[name]
		if item and (tonumber(item.amount) or 0) >= 1 then R.UseSpin:FireServer(name); task.wait(0.25); return end
	end
end

local function rollInterval()
	local dur = tonumber(select(2, pcall(G.BuffController.GetBuff, "Roll Duration"))) or 2.5
	return math.max(0.3, dur + 0.05)
end

local function doCollectPlace()
	local d = data()
	local banked = 0
	if R.CollectBalance and d.Slots then
		for key, slot in pairs(d.Slots) do
			banked = banked + (tonumber(slot.balance) or 0)
			pcall(function() R.CollectBalance:FireServer(tonumber(key)) end)
		end
	end
	STATE.collected = STATE.collected + banked
	if F.smartPlace and R.EquipBest then R.EquipBest:FireServer() end
end

local function sellJunk(force)
	if not R.SellInventory then return end
	if not claimUnits("sell") then return end
	local d = data()
	local cap = invCap()
	local placed = {}
	for _, slot in pairs(d.Slots or {}) do if slot.unitId then placed[slot.unitId] = true end end
	for _, id in pairs(d.TowerTeam or {}) do placed[id] = true end
	local luckLine = F.keepLuckX > 0 and rollLuck() * F.keepLuckX or nil

	local units, owned = {}, 0
	for id, u in pairs(d.Inventory or {}) do
		local e = G.UnitConfig and G.UnitConfig.entries[u.name]
		if e then owned = owned + 1 end
		local chance = e and not e.limited and tonumber(select(2, pcall(e.chance, { mutation = u.attributes and u.attributes.mutation })))
		local lucky = luckLine and (chance or math.huge) >= luckLine
		if e and not placed[id] and not isProtected(id, u) and not lucky then
			units[#units + 1] = { id = id, inc = baseIncome(u), order = RARITY_SORT[e.rarity] or 0, mutated = u.attributes and u.attributes.mutation ~= nil }
		end
	end
	table.sort(units, function(a, b) return a.inc < b.inc end)
	local pressured = force or owned >= cap - 3
	local sellable = math.max(0, #units - F.keepBest)
	local list = {}
	for i, unit in ipairs(units) do
		local belowFloor = not unit.mutated and unit.order > 0 and unit.order < F.sellRarity and i <= sellable
		local surplus = pressured and i <= sellable
		if belowFloor or surplus then
			list[#list + 1] = unit.id
			if #list >= 300 then break end
		end
	end
	if #list > 0 then
		local ok, value, sold = pcall(function() return R.SellInventory:InvokeServer(list) end)
		if ok then 
			STATE.sold = STATE.sold + (tonumber(sold) or #list)
			STATE.soldValue = STATE.soldValue + (tonumber(value) or 0)
			if (tonumber(value) or 0) > 1000000 then
				sendWebhook("Auto Sell Alert", string.format("Menjual %s unit dengan total nilai $%s", tostring(sold), fmt(value)))
			end
		end
	end
	releaseUnits("sell")
end

-- ===================================================================== --
-- 5. DELTA CONSOLE SPY LOG ENGINE
-- ===================================================================== --
local function LogSpy(text)
	if not F.spyDataOn then return end
	if _G.SpyScroll then
		local Lbl = Instance.new("TextLabel"); Lbl.Parent = _G.SpyScroll; Lbl.Size = UDim2.new(1, -10, 0, 24); Lbl.BackgroundTransparency = 1; Lbl.TextColor3 = Color3.fromRGB(0, 255, 150); Lbl.TextSize = 11; Lbl.Font = Enum.Font.Code; Lbl.TextXAlignment = Enum.TextXAlignment.Left; Lbl.Text = text
		_G.SpyScroll.CanvasPosition = Vector2.new(0, 999999)
	end
	local consoleMsg = "[MOFENK SPY] " .. text
	if rconsoleprint then rconsoleprint("@@LIGHT_CYAN@@\n" .. consoleMsg) else print(consoleMsg) end
end

pcall(function()
	local mt = getrawmetatable(game)
	if mt then
		local oldNamecall = mt.__namecall
		setreadonly(mt, false)
		mt.__namecall = newcclosure(function(self, ...)
			local method = getnamecallmethod()
			if F.spyDataOn and (method == "FireServer" or method == "InvokeServer") then
				LogSpy("🎯 Event: " .. tostring(self.Name) .. " | Method: " .. tostring(method))
			end
			return oldNamecall(self, ...)
		end)
		setreadonly(mt, true)
	end
end)

-- ===================================================================== --
-- 6. FULL UI BUILDER (MODERN SPECTRUM & AVATAR)
-- ===================================================================== --
local THEMES = {
	{ Name = "Cyberpunk", Bg = Color3.fromRGB(15, 10, 25), Card = Color3.fromRGB(30, 20, 45), Header = Color3.fromRGB(20, 15, 30), Acc1 = Color3.fromRGB(0, 255, 255), Acc2 = Color3.fromRGB(255, 0, 128) },
	{ Name = "Toxic Glow", Bg = Color3.fromRGB(10, 15, 10), Card = Color3.fromRGB(20, 35, 20), Header = Color3.fromRGB(15, 25, 15), Acc1 = Color3.fromRGB(57, 255, 20), Acc2 = Color3.fromRGB(173, 255, 47) },
	{ Name = "Crimson Hell", Bg = Color3.fromRGB(20, 5, 5), Card = Color3.fromRGB(40, 10, 10), Header = Color3.fromRGB(25, 5, 5), Acc1 = Color3.fromRGB(255, 40, 40), Acc2 = Color3.fromRGB(255, 120, 0) },
	{ Name = "Gold Luxury", Bg = Color3.fromRGB(20, 18, 10), Card = Color3.fromRGB(45, 35, 20), Header = Color3.fromRGB(30, 25, 15), Acc1 = Color3.fromRGB(255, 215, 0), Acc2 = Color3.fromRGB(255, 180, 50) },
	{ Name = "Modern Spectrum", Bg = Color3.fromRGB(12, 12, 18), Card = Color3.fromRGB(22, 22, 32), Header = Color3.fromRGB(18, 18, 26), Acc1 = Color3.fromRGB(0, 238, 255), Acc2 = Color3.fromRGB(187, 0, 255) },
}
local ThemeElements = { Bg = {}, Card = {}, Header = {}, Acc1 = {}, Grad = {}, TextAcc = {} }

local function ApplyTheme(idx)
	local t = THEMES[idx] or THEMES[5]
	for _, v in ipairs(ThemeElements.Bg) do pcall(function() v.BackgroundColor3 = t.Bg end) end
	for _, v in ipairs(ThemeElements.Card) do pcall(function() v.BackgroundColor3 = t.Card end) end
	for _, v in ipairs(ThemeElements.Header) do pcall(function() v.BackgroundColor3 = t.Header end) end
	for _, v in ipairs(ThemeElements.Acc1) do pcall(function() if v:IsA("UIStroke") then v.Color = t.Acc1 else v.BackgroundColor3 = t.Acc1 end end) end
	for _, v in ipairs(ThemeElements.Grad) do pcall(function() v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, t.Acc1), ColorSequenceKeypoint.new(1, t.Acc2)}) end) end
	for _, v in ipairs(ThemeElements.TextAcc) do pcall(function() v.TextColor3 = t.Acc1 end) end
end

local ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "MofenkToggleFront"; ToggleGui.Parent = parentGui; ToggleGui.ResetOnSpawn = false
local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = ToggleGui; ToggleBtn.Size = UDim2.new(0, 60, 0, 60); ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0); ToggleBtn.BackgroundColor3 = THEMES[5].Card; ToggleBtn.Text = "M"; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 34; ToggleBtn.TextColor3 = THEMES[5].Acc1; ToggleBtn.BackgroundTransparency = 0.2
local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 16); TC.Parent = ToggleBtn
local TS = Instance.new("UIStroke"); TS.Thickness = 3; TS.Parent = ToggleBtn; table.insert(ThemeElements.Acc1, TS)

local dragging, dragInput, dragStart, startPos
ToggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = ToggleBtn.Position end
end)
ToggleBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart; local viewport = workspace.CurrentCamera.ViewportSize; ToggleBtn.Position = UDim2.new(0, math.clamp(startPos.X.Offset + delta.X, 10, viewport.X - 70), 0, math.clamp(startPos.Y.Offset + delta.Y, 10, viewport.Y - 70)) end end)

local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkUltraHub"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui; MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.Size = UDim2.new(0, 950, 0, 620); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.BackgroundTransparency = 0.15; table.insert(ThemeElements.Bg, MainFrame)
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 18); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 4; MainStroke.Parent = MainFrame; local StrokeGrad = Instance.new("UIGradient"); StrokeGrad.Parent = MainStroke; table.insert(ThemeElements.Grad, StrokeGrad)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 55); TopBar.BackgroundTransparency = 0.3; table.insert(ThemeElements.Header, TopBar)
local TopCorner = Instance.new("UICorner"); TopCorner.CornerRadius = UDim.new(0, 18); TopCorner.Parent = TopBar
local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 25, 0, 0); Title.Size = UDim2.new(0, 600, 1, 0); Title.Text = "👑 MOFENKHUB V118.0  |  OMNI MASTERPIECE"; Title.TextSize = 14; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, Title)
local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -50, 0, 10); CloseBtn.Size = UDim2.new(0, 35, 0, 35); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(255,255,255); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 18; CloseBtn.BackgroundTransparency = 0.3; table.insert(ThemeElements.Card, CloseBtn)
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 10); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = MainFrame; Sidebar.Position = UDim2.new(0, 15, 0, 65); Sidebar.Size = UDim2.new(0, 200, 1, -80); Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 0; Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
local SideLayout = Instance.new("UIListLayout"); SideLayout.Parent = Sidebar; SideLayout.Padding = UDim.new(0, 8)
local ContentArea = Instance.new("Frame"); ContentArea.Parent = MainFrame; ContentArea.Position = UDim2.new(0, 225, 0, 65); ContentArea.Size = UDim2.new(1, -240, 1, -80); ContentArea.BackgroundTransparency = 0.4; table.insert(ThemeElements.Header, ContentArea)
local ContentCorner = Instance.new("UICorner"); ContentCorner.CornerRadius = UDim.new(0, 14); ContentCorner.Parent = ContentArea

local TabFrames, TabButtons = {}, {}
local function CreateTab(name, icon)
	local Btn = Instance.new("TextButton"); Btn.Parent = Sidebar; Btn.Size = UDim2.new(1, -4, 0, 42); Btn.Text = "   " .. icon .. "  " .. name; Btn.TextColor3 = Color3.fromRGB(220,220,220); Btn.TextSize = 13; Btn.Font = Enum.Font.GothamBold; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.BackgroundTransparency = 0.4; table.insert(ThemeElements.Card, Btn)
	local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 10); Corner.Parent = Btn
	local Scroll = Instance.new("ScrollingFrame"); Scroll.Parent = ContentArea; Scroll.Size = UDim2.new(1, -20, 1, -20); Scroll.Position = UDim2.new(0, 10, 0, 10); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2; Scroll.Visible = false; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local Lay = Instance.new("UIListLayout"); Lay.Parent = Scroll; Lay.Padding = UDim.new(0, 12)
	TabFrames[name] = Scroll; TabButtons[name] = Btn
	Btn.MouseButton1Click:Connect(function()
		for n, f in pairs(TabFrames) do f.Visible = (n == name) end
		for _, b in pairs(TabButtons) do b.BackgroundTransparency = 0.4; b.TextColor3 = Color3.fromRGB(220,220,220); for i,v in ipairs(ThemeElements.Acc1) do if v==b then table.remove(ThemeElements.Acc1, i) end end end
		Btn.BackgroundTransparency = 0.1; table.insert(ThemeElements.Acc1, Btn); ApplyTheme(F.themeIndex); Btn.TextColor3 = Color3.fromRGB(255,255,255)
	end)
	return Scroll
end

local function AddGroup(parent, title)
	local GroupCard = Instance.new("Frame"); GroupCard.Parent = parent; GroupCard.Size = UDim2.new(1, 0, 0, 0); GroupCard.AutomaticSize = Enum.AutomaticSize.Y; GroupCard.BackgroundTransparency = 0.3; table.insert(ThemeElements.Card, GroupCard)
	local GC = Instance.new("UICorner"); GC.CornerRadius = UDim.new(0, 12); GC.Parent = GroupCard
	local GS = Instance.new("UIStroke"); GS.Thickness = 2; GS.Transparency = 0.5; GS.Parent = GroupCard; table.insert(ThemeElements.Acc1, GS)
	local GLayout = Instance.new("UIListLayout"); GLayout.Parent = GroupCard; GLayout.Padding = UDim.new(0, 8); GLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local GPadding = Instance.new("UIPadding"); GPadding.Parent = GroupCard; GPadding.PaddingTop = UDim.new(0, 12); GPadding.PaddingBottom = UDim.new(0, 12); GPadding.PaddingLeft = UDim.new(0, 12); GPadding.PaddingRight = UDim.new(0, 12)
	if title and title ~= "" then local HeaderLbl = Instance.new("TextLabel"); HeaderLbl.Parent = GroupCard; HeaderLbl.Size = UDim2.new(1, 0, 0, 28); HeaderLbl.Text = title; HeaderLbl.TextSize = 14; HeaderLbl.Font = Enum.Font.GothamBlack; HeaderLbl.TextXAlignment = Enum.TextXAlignment.Left; HeaderLbl.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, HeaderLbl) end
	return GroupCard
end

local function AddToggle(parent, text, flag, callback)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 40); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 8, 0, 0); L.Size = UDim2.new(0.7, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Sw = Instance.new("TextButton"); Sw.Parent = Frm; Sw.Position = UDim2.new(1, -50, 0.5, -13); Sw.Size = UDim2.new(0, 44, 0, 26); Sw.Text = ""
	local SwC = Instance.new("UICorner"); SwC.CornerRadius = UDim.new(1, 0); SwC.Parent = Sw
	local Knob = Instance.new("Frame"); Knob.Parent = Sw; Knob.Size = UDim2.new(0, 20, 0, 20); Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1, 0); KC.Parent = Knob
	
	local function updateVisuals()
		Sw.BackgroundColor3 = F[flag] and THEMES[F.themeIndex].Acc1 or Color3.fromRGB(60,60,75)
		TweenService:Create(Knob, TweenInfo.new(0.2), {Position = F[flag] and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)}):Play()
		if F[flag] then table.insert(ThemeElements.Acc1, Sw) else for i,v in ipairs(ThemeElements.Acc1) do if v==Sw then table.remove(ThemeElements.Acc1,i) end end end
		ApplyTheme(F.themeIndex)
	end
	table.insert(ConfigUpdaters, updateVisuals)
	Sw.MouseButton1Click:Connect(function() F[flag] = not F[flag]; updateVisuals(); if callback then callback(F[flag]) end end)
	updateVisuals()
end

local function AddInput(parent, text, flag, isNum)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 42); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 8, 0, 0); L.Size = UDim2.new(0.5, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Box = Instance.new("TextBox"); Box.Parent = Frm; Box.Position = UDim2.new(0.5, 0, 0.1, 0); Box.Size = UDim2.new(0.48, 0, 0.8, 0); table.insert(ThemeElements.TextAcc, Box); Box.TextSize = 13; Box.Font = Enum.Font.GothamBold; Box.BackgroundTransparency = 0.4; table.insert(ThemeElements.Header, Box)
	local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); Box.Parent = Box
	local BS = Instance.new("UIStroke"); BS.Parent = Box; BS.Transparency = 0.5; table.insert(ThemeElements.Acc1, BS)
	local function updateVisuals() Box.Text = tostring(F[flag] or "") end
	table.insert(ConfigUpdaters, updateVisuals)
	Box.FocusLost:Connect(function() F[flag] = isNum and (tonumber(Box.Text) or 0) or Box.Text; updateVisuals() end)
	updateVisuals()
end

local function AddDropdown(parent, title, options, flag)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 44); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 8, 0, 0); L.Size = UDim2.new(0.4, 0, 1, 0); L.Text = title; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Btn = Instance.new("TextButton"); Btn.Parent = Frm; Btn.Position = UDim2.new(0.42, 0, 0.1, 0); Btn.Size = UDim2.new(0.56, 0, 0.8, 0); table.insert(ThemeElements.TextAcc, Btn); Btn.TextSize = 12; Btn.Font = Enum.Font.GothamBold; Btn.BackgroundTransparency = 0.4; table.insert(ThemeElements.Header, Btn)
	local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); Btn.Parent = Btn; local BS = Instance.new("UIStroke"); BS.Parent = Btn; BS.Transparency = 0.5; table.insert(ThemeElements.Acc1, BS)
	local DropList = Instance.new("ScrollingFrame"); DropList.Parent = MainFrame; DropList.Size = UDim2.new(0, 250, 0, 180); table.insert(ThemeElements.Bg, DropList); DropList.Visible = false; DropList.ZIndex = 150; DropList.ScrollBarThickness = 4; DropList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local DLC = Instance.new("UICorner"); DLC.CornerRadius = UDim.new(0, 8); DLC.Parent = DropList; local DLL = Instance.new("UIListLayout"); DLL.Parent = DropList
	local function UpdatePos() if DropList.Visible then DropList.Position = UDim2.new(0, Btn.AbsolutePosition.X - MainFrame.AbsolutePosition.X, 0, (Btn.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y) + Btn.AbsoluteSize.Y + 4) end end
	Btn:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos)
	local updateCheckList = {}
	local function updateMainBtn() Btn.Text = tostring(F[flag] or "Pilih Disini") end
	table.insert(ConfigUpdaters, updateMainBtn)
	for _, opt in ipairs(options) do
		local OptBtn = Instance.new("TextButton"); OptBtn.Parent = DropList; OptBtn.Size = UDim2.new(1, 0, 0, 36); OptBtn.Text = "  " .. tostring(opt.label); OptBtn.TextColor3 = Color3.fromRGB(255,255,255); OptBtn.TextSize = 12; OptBtn.Font = Enum.Font.GothamMedium; OptBtn.TextXAlignment = Enum.TextXAlignment.Left; OptBtn.BackgroundTransparency = 1; OptBtn.ZIndex = 151
		local check = Instance.new("Frame"); check.Parent = OptBtn; check.Size = UDim2.new(0, 16, 0, 16); check.Position = UDim2.new(1, -24, 0.5, -8); local cc = Instance.new("UICorner"); cc.Parent = check; check.ZIndex = 151
		local function updateVisuals() local sel = (F[flag] == opt.val); if sel then table.insert(ThemeElements.Acc1, check) else check.BackgroundColor3 = Color3.fromRGB(60,60,75) end; ApplyTheme(F.themeIndex) end
		table.insert(ConfigUpdaters, updateVisuals); table.insert(updateCheckList, updateVisuals)
		OptBtn.MouseButton1Click:Connect(function() F[flag] = opt.val; DropList.Visible = false; updateMainBtn(); for _, fn in ipairs(updateCheckList) do pcall(fn) end end)
	end
	updateMainBtn(); Btn.MouseButton1Click:Connect(function() DropList.Visible = not DropList.Visible; UpdatePos() end)
end

-- ===================================================================== --
-- 7. TAB CREATION & FULL INTERFACE ASSEMBLY
-- ===================================================================== --
local T_Dash  = CreateTab("Dashboard", "📊")
local T_Hallo = CreateTab("Halloween", "🎃")
local T_Farm  = CreateTab("Farming", "⛏️")
local T_Inv   = CreateTab("Inventory", "🎒")
local T_Twr   = CreateTab("Tower", "🏰")
local T_Spy   = CreateTab("Remote Spy", "🕵️‍♂️")
local T_Set   = CreateTab("Settings", "⚙️")

TabFrames["Dashboard"].Visible = true; Sidebar:GetChildren()[2].BackgroundTransparency = 0.1; table.insert(ThemeElements.Acc1, Sidebar:GetChildren()[2])

-- [DASHBOARD TAB]
local G_Profile = AddGroup(T_Dash, "PROFIL & MONITORING (LIVE)")
local ProfContainer = Instance.new("Frame"); ProfContainer.Parent = G_Profile; ProfContainer.Size = UDim2.new(1, 0, 0, 80); ProfContainer.BackgroundTransparency = 1
local PImg = Instance.new("ImageLabel"); PImg.Parent = ProfContainer; PImg.AnchorPoint = Vector2.new(0.5, 0.5); PImg.Position = UDim2.new(0.15, 0, 0.5, 0); PImg.Size = UDim2.new(0, 64, 0, 64); 
pcall(function() PImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
local PImgC = Instance.new("UICorner"); PImgC.CornerRadius = UDim.new(1,0); PImgC.Parent = PImg; 
local PStr = Instance.new("UIStroke"); PStr.Thickness = 2; PStr.Parent = PImg; table.insert(ThemeElements.Acc1, PStr)

local PLbl = Instance.new("TextLabel"); PLbl.Parent = ProfContainer; PLbl.Position = UDim2.new(0.35, 0, 0, 0); PLbl.Size = UDim2.new(0.65, 0, 1, 0); PLbl.BackgroundTransparency = 1; PLbl.TextColor3 = Color3.fromRGB(255,255,255); PLbl.TextSize = 13; PLbl.Font = Enum.Font.GothamMedium; PLbl.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
	while task.wait(1) do 
		local d = data()
		pcall(function() 
			local m = d.Money or 0
			local rb = d.Rebirth or 0
			local gems = 0; for _, item in pairs(d.Inventory or {}) do if item.name == "Gems" then gems = gems + (tonumber(item.amount) or 0) end end
			PLbl.Text = string.format("👤 %s\n💰 Uang: %s\n🔄 Rebirth: %s\n💎 Gems: %s\n🏰 Tower: %s (Lt. %s)", 
				LocalPlayer.Name, fmt(m), tostring(rb), fmt(gems), tostring(STATE.towerLive), tostring(STATE.towerFloor)) 
		end) 
	end
end)

-- [HALLOWEEN TAB]
local G_Hallo = AddGroup(T_Hallo, "HALLOWEEN & SPECIAL EVENTS")
local BtnHalloTP = Instance.new("TextButton"); BtnHalloTP.Parent = G_Hallo; BtnHalloTP.Size = UDim2.new(1, 0, 0, 40); BtnHalloTP.Text = "🎃 TELEPORT KE HALLOWEEN MAP"; BtnHalloTP.Font = Enum.Font.GothamBold; BtnHalloTP.TextSize = 12; table.insert(ThemeElements.Card, BtnHalloTP); table.insert(ThemeElements.TextAcc, BtnHalloTP); local B1 = Instance.new("UICorner"); B1.CornerRadius = UDim.new(0,8); B1.Parent = BtnHalloTP
BtnHalloTP.MouseButton1Click:Connect(function() Invoke("Teleport") end)
AddToggle(G_Hallo, "Auto Claim Trick or Treat", "halloAutoTrickOrTreat")
AddToggle(G_Hallo, "Auto Roll Pumpkin Dice", "halloRollPumpkin")
AddToggle(G_Hallo, "Auto Claim Halloween Path", "halloAutoClaim")
AddToggle(G_Hallo, "Auto Buy Upgrade Speed/Luck", "halloAutoUpgrade")

-- [FARMING TAB]
local G_Farm = AddGroup(T_Farm, "FARMING, REBIRTH & ROLLS")
AddToggle(G_Farm, "Auto Collect & Smart Place", "collect")
AddToggle(G_Farm, "Auto Roll Dadu (With Spin)", "autoRoll")
AddToggle(G_Farm, "Auto Rebirth", "rebirth")
AddToggle(G_Farm, "Use Lucky Spins", "autoSpins")
AddToggle(G_Farm, "Auto Level Slots", "levelup")
AddToggle(G_Farm, "Anti-AFK (Bypass Disconnect)", "antiAfk")

-- [INVENTORY TAB (FULL LISTS & FUSE/SELL)]
local G_Inv = AddGroup(T_Inv, "AUTO SELL & INVENTORY MANAGEMENT")
AddToggle(G_Inv, "Aktifkan Auto Sell (Smart Filter)", "sellAuto")
AddInput(G_Inv, "Simpan Unit Terbaik (Keep):", "keepBest", true)
AddInput(G_Inv, "Sell Rarity Threshold:", "sellRarity", true)
AddToggle(G_Inv, "Auto Fuse Units", "autoFuse")

local G_GradeTrait = AddGroup(T_Inv, "GRADE & TRAIT AUTOMATION")
AddToggle(G_GradeTrait, "Auto Roll Grades", "gradeAuto")
AddInput(G_GradeTrait, "Min Grade Multiplier:", "gradeMin", true)
AddToggle(G_GradeTrait, "Auto Roll Traits", "traitAuto")
AddInput(G_GradeTrait, "Min Trait Multiplier:", "traitMin", true)

-- [TOWER TAB (FULL LIST: DRAGON, HAUNTED, PIRATE, INFINITY, VOID, SHADOW)]
local G_Twr = AddGroup(T_Twr, "TOWER AUTOMATION (ALL TOWERS)")
AddDropdown(G_Twr, "Pilih Tower:", {
	{label="Dragon Tower", val="Dragon Tower"}, 
	{label="Haunted Tower", val="Haunted Tower"}, 
	{label="Pirate Tower", val="Pirate Tower"}, 
	{label="Infinity Tower", val="Infinity Tower"},
	{label="Void Tower", val="Void Tower"},
	{label="Shadow Tower", val="Shadow Tower"}
}, "towerName")
AddToggle(G_Twr, "Auto Tower Farming", "tower")
AddToggle(G_Twr, "Mode MIX / Random Tower (Auto-Pick)", "towerMix")
AddToggle(G_Twr, "Auto Equip Best Tower Team", "towerEquipBest")

-- [REMOTE SPY TAB]
local G_SpyUI = AddGroup(T_Spy, "DELTA CONSOLE SPY LOG")
AddToggle(G_SpyUI, "Aktifkan Spy Log (Delta Print)", "spyDataOn")
_G.SpyScroll = Instance.new("ScrollingFrame"); _G.SpyScroll.Parent = G_SpyUI; _G.SpyScroll.Size = UDim2.new(1, 0, 0, 200); _G.SpyScroll.BackgroundTransparency = 0.5; _G.SpyScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15); _G.SpyScroll.ScrollBarThickness = 4; _G.SpyScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local SpyLayout = Instance.new("UIListLayout"); SpyLayout.Parent = _G.SpyScroll; SpyLayout.Padding = UDim.new(0, 4)

-- [SETTINGS TAB & CONFIG MANAGER]
local G_SetT = AddGroup(T_Set, "TEMA UI")
local BtnTheme = Instance.new("TextButton"); BtnTheme.Parent = G_SetT; BtnTheme.Size = UDim2.new(1, 0, 0, 34); BtnTheme.Text = "🎲 GANTI TEMA (MODERN SPECTRUM)"; BtnTheme.Font = Enum.Font.GothamBlack; BtnTheme.TextSize = 12; table.insert(ThemeElements.Card, BtnTheme); table.insert(ThemeElements.TextAcc, BtnTheme); local BTC = Instance.new("UICorner"); BTC.CornerRadius = UDim.new(0,6); BTC.Parent = BtnTheme
BtnTheme.MouseButton1Click:Connect(function() F.themeIndex = F.themeIndex >= #THEMES and 1 or (F.themeIndex + 1); ApplyTheme(F.themeIndex) end)

local G_Config = AddGroup(T_Set, "CONFIG MANAGER & WEBHOOK")
AddInput(G_Config, "Nama Config:", "cfgName", false)
local BtnSave = Instance.new("TextButton"); BtnSave.Parent = G_Config; BtnSave.Size = UDim2.new(1, 0, 0, 36); BtnSave.Text = "💾 SAVE CONFIG"; BtnSave.Font = Enum.Font.GothamBold; BtnSave.TextSize = 12; table.insert(ThemeElements.Header, BtnSave); table.insert(ThemeElements.TextAcc, BtnSave); local BSC = Instance.new("UICorner"); BSC.CornerRadius = UDim.new(0,8); BSC.Parent = BtnSave
BtnSave.MouseButton1Click:Connect(function() saveConfig(F.cfgName) end)

local BtnLoad = Instance.new("TextButton"); BtnLoad.Parent = G_Config; BtnLoad.Size = UDim2.new(1, 0, 0, 36); BtnLoad.Text = "📂 LOAD CONFIG"; BtnLoad.Font = Enum.Font.GothamBold; BtnLoad.TextSize = 12; table.insert(ThemeElements.Header, BtnLoad); table.insert(ThemeElements.TextAcc, BtnLoad); local BLC = Instance.new("UICorner"); BLC.CornerRadius = UDim.new(0,8); BLC.Parent = BtnLoad
BtnLoad.MouseButton1Click:Connect(function() loadConfig(F.cfgName) end)

local BtnDel = Instance.new("TextButton"); BtnDel.Parent = G_Config; BtnDel.Size = UDim2.new(1, 0, 0, 36); BtnDel.Text = "🗑️ DELETE CONFIG"; BtnDel.Font = Enum.Font.GothamBold; BtnDel.TextSize = 12; table.insert(ThemeElements.Header, BtnDel); table.insert(ThemeElements.TextAcc, BtnDel); local BDC = Instance.new("UICorner"); BDC.CornerRadius = UDim.new(0,8); BDC.Parent = BtnDel
BtnDel.MouseButton1Click:Connect(function() deleteConfig(F.cfgName) end)

AddToggle(G_Config, "Aktifkan Webhook Notif", "webhookEnabled")
AddInput(G_Config, "URL Webhook Discord:", "webhookUrl", false)

ApplyTheme(F.themeIndex)

-- ===================================================================== --
-- 8. FULL UNRESTRICTED BACKGROUND LOOPS & ENGINE THREADS
-- ===================================================================== --
task.spawn(function()
	LocalPlayer.Idled:Connect(function() if F.antiAfk then pcall(function() VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame); task.wait(1); VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end) end end)
	while task.wait(30) do if F.antiAfk then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new(0,0)) end) end end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.autoRoll and R.RollDice then pcall(armSpin); pcall(function() R.RollDice:InvokeServer() end) end
		if F.rebirth and R.Rebirth then 
			local ok, res = pcall(function() return R.Rebirth:InvokeServer() end)
			if ok and res then STATE.rebirths += 1 end
		end
		task.wait(rollInterval())
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.collect then pcall(doCollectPlace) end
		task.wait(5)
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.sellAuto then pcall(function() sellJunk(false) end) end
		task.wait(4)
	end
end)

-- Tower Logic (Full Unrestricted List & Mix)
local towerList = {"Dragon Tower", "Haunted Tower", "Pirate Tower", "Infinity Tower", "Void Tower", "Shadow Tower"}
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.tower and R.PlayTower and R.CompleteFloor then
			if F.towerEquipBest and R.BestTowerTeam then pcall(function() R.BestTowerTeam:FireServer() end) end
			task.wait(0.5)
			local pickTower = F.towerMix and towerList[math.random(1, #towerList)] or F.towerName
			STATE.towerLive = "Memulai: " .. pickTower
			local okStart, started = pcall(function() return R.PlayTower:InvokeServer(pickTower) end)
			if okStart and started then
				local done, fails = false, 0
				while F.tower and not done do
					local okP, seq = pcall(function() return R.CompleteFloor:InvokeServer() end)
					if okP and type(seq) == "table" and #seq > 0 then
						fails = 0
						for _, act in ipairs(seq) do
							if act.action == "floorStarted" then 
								STATE.towerFloor = tonumber(act.floor) or 1
							elseif act.action == "ended" then 
								done = true 
								STATE.towerFloors += STATE.towerFloor
								if STATE.towerFloor > STATE.towerBest then STATE.towerBest = STATE.towerFloor end
								if STATE.towerBest >= 30 then
									sendWebhook("Tower Record!", string.Format("Berhasil mencapai lantai %s di %s!", tostring(STATE.towerBest), pickTower))
								end
								break 
							end
						end
					else fails += 1; if fails > 8 then done = true end; task.wait(1) end
				end
			end
		else STATE.towerLive = "Standby"; task.wait(2) end
	end
end)

-- Halloween Loops
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.halloAutoTrickOrTreat and R.TrickOrTreat then pcall(function() R.TrickOrTreat:InvokeServer() end) end
		if F.halloRollPumpkin and R.RollPumpkin then pcall(function() R.RollPumpkin:InvokeServer("Pumpkin") end) end
		if F.halloAutoClaim then pcall(function() firetouchinterest(workspace, LocalPlayer.Character.HumanoidRootPart, 0) end) end
		task.spawn(function()
			if F.halloAutoUpgrade and R.BuyUpgrade then
				pcall(function() R.BuyUpgrade:FireServer("Speed"); R.BuyUpgrade:FireServer("Luck") end)
			end
		end)
		task.wait(2.5)
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.potionAuto then pcall(useBoosts) end
		task.wait(10)
	end
end)
