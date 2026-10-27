-- ===================================================================== --
-- 🌙 ADYFAHUB V101.2 — 100% FULL FEATURES ENTERPRISE EDITION
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

pcall(function() for _, v in pairs(parentGui:GetChildren()) do if string.find(v.Name, "AdyfaHub") or string.find(v.Name, "Mofenk") then v:Destroy() end end end)

-- ===================================================================== --
-- 1. STATE & CONFIGURATION MANAGER (V101.2)
-- ===================================================================== --
_G.__ADYFAHUB = (_G.__ADYFAHUB or 0) + 1
local generation = _G.__ADYFAHUB

local F = {
	cfgName = "AdyfaConfig101", autoLoadEnabled = false, uiScaleValue = 0.82, pauseAll = false,
	-- Tower & Queue
	tower = false, towerQueue = {"Auto (best)"}, towerMix = false, towerEquipBest = true, 
	towerExitOn = false, towerExitFloor = 50, towerRestartDelay = 3, missingRunTolerance = 5,
	-- Stand & Money
	collect = false, smartPlace = true, autoBestPlaceBase = false, minStandGain = 1.1,
	-- Potions
	potionAuto = false, potionBest = true, potionSpecific = {}, potionReserve = 2, maxPotionsPerTrade = 5,
	-- Rebirth & Upgrades
	rebirth = false, upgrades = false, smartSpending = true, paybackHorizon = true,
	-- Rerolls
	gradeAuto = false, gradePlacedOnly = false, gradeTargets = {}, gradeUnits = {}, gemReserve = 100, maxRerollsPerUnit = 50, protectRareGrades = true,
	traitAuto = false, traitPlacedOnly = false, traitTargets = {}, traitUnits = {}, rerollReserve = 50, protectRareTraits = true,
	quirkAuto = false, quirkPlacedOnly = false, quirkTargets = {}, quirkUnits = {}, quirkReserve = 50,
	-- Fusion & Inventory
	sellAuto = false, keepBest = 20, autoFuse = false, fuseDuplicatesOnly = true, fuseUnmutatedOnly = false, prioritizeMatching = true, fusionBudgetTopProtect = true, lockedUnits = {}, specificSellUnits = {}, activeLoadout = "Preset 1",
	-- Dice & Spins
	buyDice = true, prioritizeDice = true, equipDice = true, autoSpins = false, autoRoll = false,
	-- Halloween & Haunted
	halloweenTeleport = false, halloweenQuest = false, halloweenPath = false, halloweenOffer = false, trickOrTreat = false,
	pumpkinRollQty = 1, pumpkinAutoRoll = false, pumpkinAutoSell = false,
	hauntedTower = false, hauntedMix = false, hauntedList = {"Haunted Front Yard"}, hauntedEquipBest = true, hauntedExitOn = false, hauntedExitFloor = 50,
	-- Coop & Partner
	localCoop = false, partnerUsername = "", autoAssignPower = true, manualOverrides = {}, predictedFloorThreshold = 10, autoStartCoop = false, acceptPartnerTrades = false,
	-- Misc & Optimization
	afk = true, fpsOn = false, codesAuto = true, claimQuests = true, hideTowerScreen = false,
	webhookEnabled = false, webhookUrl = ""
}

local STATE = { towerLive = "Standby", towerFloor = 0, towerDrops = 0, towerTraitsGot = "Belum Ada", towerRuns = 0, towerWins = 0, farmingRate = "0 /m", hauntedLive = "Standby", hauntedFloor = 0, hauntedDrops = 0, activeBuffs = "Tidak Ada", equalizerBar = "▂▃▅▇█▇▅▃▂", coopStatus = "Disconnected" }
local ConfigUpdaters = {}

local THEME = {
	Bg = Color3.fromRGB(10, 12, 18), 
	Card = Color3.fromRGB(18, 22, 32), 
	Header = Color3.fromRGB(14, 18, 26), 
	Acc1 = Color3.fromRGB(0, 240, 255),
	Acc2 = Color3.fromRGB(0, 120, 255)
}

local ThemeElements = { Bg = {}, Card = {}, Header = {}, Acc1 = {}, Grad = {}, TextAcc = {} }

local function ApplyTheme()
	local t = THEME
	for _, v in ipairs(ThemeElements.Bg) do v.BackgroundColor3 = t.Bg end
	for _, v in ipairs(ThemeElements.Card) do v.BackgroundColor3 = t.Card end
	for _, v in ipairs(ThemeElements.Header) do v.BackgroundColor3 = t.Header end
	for _, v in ipairs(ThemeElements.Acc1) do if v:IsA("UIStroke") then v.Color = t.Acc1 else v.BackgroundColor3 = t.Acc1 end end
	for _, v in ipairs(ThemeElements.Grad) do v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, t.Acc1), ColorSequenceKeypoint.new(1, t.Acc2)}) end
	for _, v in ipairs(ThemeElements.TextAcc) do v.TextColor3 = t.Acc1 end
end

local CFG_FOLDER = "AdyfaHub_Configs"
if makefolder and not isfolder(CFG_FOLDER) then pcall(function() makefolder(CFG_FOLDER) end) end

local function getCfgPath(name) return CFG_FOLDER .. "/" .. (name or F.cfgName or "DefaultConfig") .. ".json" end

local function saveConfig(name)
	if writefile then
		pcall(function() 
			writefile(getCfgPath(name), HttpService:JSONEncode(F)) 
			local pointerPath = CFG_FOLDER .. "/autoload_pointer.txt"
			if F.autoLoadEnabled then writefile(pointerPath, name or F.cfgName or "DefaultConfig")
			else if isfile and isfile(pointerPath) then delfile(pointerPath) end end
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
			ApplyTheme()
		end)
	end
end

-- ===================================================================== --
-- 2. ENTERPRISE NETWORK & MODULE BINDINGS + ACTIVE ERROR LOGGER
-- ===================================================================== --
local Network = ReplicatedStorage:WaitForChild("Network", 15); local Framework = ReplicatedStorage:WaitForChild("Framework", 15)
local function svc(p) local n = Network; for x in string.gmatch(p, "[^%.]+") do n = n and n:FindFirstChild(x) end; return n end

local R = {
	RollDice        = svc("RollService.RF.RollDice"),
	SetAutoRoll     = svc("RollService.RE.SetAutoRoll"),
	CollectBalance  = svc("PlotService.RE.CollectBalance"), 
	LevelUpSlot     = svc("PlotService.RE.LevelUpSlot"),
	EquipBestPlot   = svc("PlotService.RE.EquipBest"),
	BuyDice         = svc("DiceShopService.RE.BuyDice"), 
	EquipDice       = svc("DiceShopService.RE.EquipDice"),
	Rebirth         = svc("RebirthService.RE.Rebirth"), 
	BuyUpgrade      = svc("RE.BuyUpgrade") or svc("PlotService.RE.BuyPadUpgrade"),
	GradeRoll       = svc("GradeService.RE.Roll"), 
	TraitRoll       = svc("TraitService.RE.Roll"),
	MutationRoll    = svc("MutationService.RE.Roll") or svc("QuirkService.RE.Roll"),
	BoostUse        = svc("BoostService.RE.Use"),
	PlayTower       = svc("Towers.RF.PlayTower") or svc("Towers.RE.PlayTower"), 
	CompleteFloor   = svc("Towers.RF.CompleteTowerFloor"),
	CancelTower     = svc("Towers.RF.CancelTower"), 
	BestTowerTeam   = svc("Towers.RE.EquipBestTowerTeam"),
	RedeemCode      = svc("CodesService.RE.RedeemCode") or svc("MonetizationService.RE.RedeemCode"),
	QuestClaim      = svc("QuestService.RE.Claim"), 
	ClaimDaily      = svc("DailyRewardService.RE.Claim"),
	ClaimOffline    = svc("OfflineEarningsService.RE.Claim"), 
	ClaimGroup      = svc("GroupRewardService.RE.Claim"),
	SellInventory   = svc("SellService.RF.SellInventory"),
	UpdateAutoSell  = svc("SellService.RE.UpdateAutoSell"),
	Fuse            = svc("FusingService.RE.Fuse"),
	InteractSlot    = svc("PlotService.RE.InteractSlot"),
	EquipUnit       = svc("UnitService.RF.Equip") or svc("UnitService.RE.Equip"),
	UnequipUnit     = svc("UnitService.RF.Unequip") or svc("UnitService.RE.Unequip"),
	HWTeleport      = svc("HalloweenService.RF.Teleport") or svc("WorldService.RF.Teleport"),
	HWSeenIntro     = svc("HalloweenService.RE.SeenIntro"),
	HWQuestClaim    = svc("HalloweenQuestService.RE.Claim"),
	HWClaimPath     = svc("HalloweenService.RE.ClaimAllPath"),
	HWBuyOffer      = svc("HalloweenService.RE.BuyOffer"),
	TrickOrTreat    = svc("TrickOrTreatService.RE.Knocked"),
	PumpkinRoll     = svc("PumpkinDiceService.RF.Roll") or svc("PumpkinDiceService.RE.Roll"),
	PumpkinAutoSell = svc("PumpkinDiceService.RE.SetAutoSell")
}

local function safeInvoke(remoteName, remoteObj, ...)
	if not remoteObj then
		warn(string.format("[ADYFAHUB ERROR] Remote '%s' tidak ditemukan atau path berubah!", tostring(remoteName)))
		return false, "Missing Remote"
	end
	local success, result
	if remoteObj:IsA("RemoteFunction") then
		success, result = pcall(function(...) return remoteObj:InvokeServer(...) end, ...)
	elseif remoteObj:IsA("RemoteEvent") then
		success, result = pcall(function(...) remoteObj:FireServer(...); return true end, ...)
	end
	if not success then
		warn(string.format("[ADYFAHUB EXCEPTION] Gagal mengeksekusi [%s]: %s", tostring(remoteName), tostring(result)))
		return false, result
	end
	return true, result
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
	G.MutationsMod = require(Framework.Features.Mutations.Mutations) or require(Framework.Features.Quirk.Quirk)
	G.QuestConfig = require(Framework.Features.Quests.QuestConfig)
	G.EntryRegistry = require(Framework.Features.Inventory.EntryRegistry)
	G.BuffController = require(Framework.Features.Buffs.BuffController)
	G.DiceModule = require(Framework.Features.Rolling.Dice)
	G.TowersConfig = require(Framework.Features.Towers.Towers)
	G.UnitConfig = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig)
end)

local function data() return G.DC and G.DC.___X or {} end
local function money() pcall(function() return G.DC.Money() end); return data().Money or 0 end
local function rebirthAmt() pcall(function() return G.DC.Rebirth() end); return data().Rebirth or 0 end
local function inventory() return data().Inventory or {} end
local function slots() return data().Slots or {} end
local function isUnitEntry(e) return e and type(e)=="table" and (e.name or e.UnitName) end
local function currencyAmount(name) local t = 0; for _, e in pairs(inventory()) do if type(e)=="table" and (e.name==name or e.CurrencyName==name) then t += tonumber(e.amount or e.Count) or 0 end end; return t end

local function baseIncome(u)
	local e = u and G.UnitConfig and G.UnitConfig.entries[u.name or u.UnitName]
	if not e then return 1 end
	local a = u.attributes or {}
	return tonumber(select(2, pcall(e.income, { mutation = a.mutation, grade = a.grade, trait = a.trait, level = 1 }))) or 1
end

-- ===================================================================== --
-- 3. INTERACTIVE UI & ADAPTIVE AUTO SCALE
-- ===================================================================== --
local ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "AdyfaToggleFront"; ToggleGui.Parent = parentGui; ToggleGui.ResetOnSpawn = false
ToggleGui.DisplayOrder = 99999

local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = ToggleGui; ToggleBtn.Size = UDim2.new(0, 44, 0, 44); ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = THEME.Card; ToggleBtn.Text = "🌙"; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 20; ToggleBtn.TextColor3 = THEME.Acc1; ToggleBtn.ZIndex = 99999
local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(1, 0); TC.Parent = ToggleBtn
local TS = Instance.new("UIStroke"); TS.Thickness = 1.5; TS.Parent = ToggleBtn; table.insert(ThemeElements.Acc1, TS)

local MainGui = Instance.new("ScreenGui"); MainGui.Name = "AdyfaHubV101"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 760, 0, 460); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.BackgroundTransparency = 0.05; table.insert(ThemeElements.Bg, MainFrame)
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 10); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 1.5; MainStroke.Parent = MainFrame
local StrokeGrad = Instance.new("UIGradient"); StrokeGrad.Parent = MainStroke; table.insert(ThemeElements.Grad, StrokeGrad)

local ScreenScale = Instance.new("UIScale"); ScreenScale.Parent = MainGui
local function UpdateScale()
	local viewport = workspace.CurrentCamera.ViewportSize
	local baseScale = F.uiScaleValue or 0.82
	if viewport.X < 900 or viewport.Y < 500 then
		ScreenScale.Scale = math.clamp(baseScale * 0.85, 0.4, 1.0)
	else
		ScreenScale.Scale = math.clamp(baseScale, 0.5, 1.1)
	end
end
UpdateScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 36); TopBar.BackgroundTransparency = 0.1; table.insert(ThemeElements.Header, TopBar)
local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 12, 0, 0); Title.Size = UDim2.new(0, 480, 1, 0); Title.Text = "🌙 ADYFAHUB V101.2  |  100% FULL FEATURES"; Title.TextSize = 11; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, Title)

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -32, 0, 5); CloseBtn.Size = UDim2.new(0, 26, 0, 26); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(255,255,255); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 11; CloseBtn.BackgroundTransparency = 0.2; table.insert(ThemeElements.Card, CloseBtn)
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 6); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = MainFrame; Sidebar.Position = UDim2.new(0, 8, 0, 42); Sidebar.Size = UDim2.new(0, 150, 1, -48); Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 2; Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y; Sidebar.CanvasSize = UDim2.new(0,0,0,0)
local SideLayout = Instance.new("UIListLayout"); Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y; SideLayout.Parent = Sidebar; SideLayout.Padding = UDim.new(0, 3)

local ContentArea = Instance.new("Frame"); ContentArea.Parent = MainFrame; ContentArea.Position = UDim2.new(0, 164, 0, 42); ContentArea.Size = UDim2.new(1, -172, 1, -48); ContentArea.BackgroundTransparency = 0.2; table.insert(ThemeElements.Header, ContentArea)
local ContentCorner = Instance.new("UICorner"); ContentCorner.CornerRadius = UDim.new(0, 8); ContentCorner.Parent = ContentArea

local TabFrames, TabButtons = {}, {}
local function CreateTab(name, icon)
	local Btn = Instance.new("TextButton"); Btn.Parent = Sidebar; Btn.Size = UDim2.new(1, 0, 0, 30); Btn.Text = "  " .. icon .. "  " .. name; Btn.TextColor3 = Color3.fromRGB(220,230,240); Btn.TextSize = 10; Btn.Font = Enum.Font.GothamBold; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.BackgroundTransparency = 0.3; table.insert(ThemeElements.Card, Btn)
	local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 6); Corner.Parent = Btn
	local Scroll = Instance.new("ScrollingFrame"); Scroll.Parent = ContentArea; Scroll.Size = UDim2.new(1, -10, 1, -10); Scroll.Position = UDim2.new(0, 5, 0, 5); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 3; Scroll.Visible = false; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.CanvasSize = UDim2.new(0,0,0,0)
	local Lay = Instance.new("UIListLayout"); Lay.Parent = Scroll; Scroll.ScrollingDirection = Enum.ScrollingDirection.Y; Lay.Padding = UDim.new(0, 8)
	TabFrames[name] = Scroll; TabButtons[name] = Btn
	
	Btn.MouseButton1Click:Connect(function()
		for n, f in pairs(TabFrames) do f.Visible = (n == name) end
		for _, b in pairs(TabButtons) do b.BackgroundTransparency = 0.3; b.TextColor3 = Color3.fromRGB(220,230,240); for i,v in ipairs(ThemeElements.Acc1) do if v==b then table.remove(ThemeElements.Acc1, i) end end end
		Btn.BackgroundTransparency = 0; table.insert(ThemeElements.Acc1, Btn); ApplyTheme(); Btn.TextColor3 = Color3.fromRGB(255,255,255)
	end)
	return Scroll
end

local function AddGroup(parent, title)
	local GroupCard = Instance.new("Frame"); GroupCard.Parent = parent; GroupCard.Size = UDim2.new(1, 0, 0, 0); GroupCard.AutomaticSize = Enum.AutomaticSize.Y; GroupCard.BackgroundTransparency = 0.1; table.insert(ThemeElements.Card, GroupCard)
	local GC = Instance.new("UICorner"); GC.CornerRadius = UDim.new(0, 6); GC.Parent = GroupCard
	local GS = Instance.new("UIStroke"); GS.Thickness = 1; GS.Transparency = 0.4; GS.Parent = GroupCard; table.insert(ThemeElements.Acc1, GS)
	local GLayout = Instance.new("UIListLayout"); GLayout.Parent = GroupCard; GLayout.Padding = UDim.new(0, 5); GLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local GPadding = Instance.new("UIPadding"); GPadding.Parent = GroupCard; GPadding.PaddingTop = UDim.new(0, 6); GPadding.PaddingBottom = UDim.new(0, 6); GPadding.PaddingLeft = UDim.new(0, 6); GPadding.PaddingRight = UDim.new(0, 6)
	
	if title and title ~= "" then
		local HeaderLbl = Instance.new("TextLabel"); HeaderLbl.Parent = GroupCard; HeaderLbl.Size = UDim2.new(1, 0, 0, 18); HeaderLbl.Text = "◆ " .. title; HeaderLbl.TextSize = 10; HeaderLbl.Font = Enum.Font.GothamBlack; HeaderLbl.TextXAlignment = Enum.TextXAlignment.Left; HeaderLbl.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, HeaderLbl)
	end
	return GroupCard
end

local function AddToggle(parent, text, flag, callback)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 26); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 2, 0, 0); L.Size = UDim2.new(0.7, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(230,235,240); L.TextSize = 10; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Sw = Instance.new("TextButton"); Sw.Parent = Frm; Sw.Position = UDim2.new(1, -32, 0.5, -8); Sw.Size = UDim2.new(0, 30, 0, 16); Sw.Text = ""; local SwC = Instance.new("UICorner"); SwC.CornerRadius = UDim.new(1, 0); SwC.Parent = Sw
	local Knob = Instance.new("Frame"); Knob.Parent = Sw; Knob.Size = UDim2.new(0, 12, 0, 12); Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1, 0); KC.Parent = Knob
	
	local function updateVisuals()
		Sw.BackgroundColor3 = F[flag] and THEME.Acc1 or Color3.fromRGB(40,50,65)
		TweenService:Create(Knob, TweenInfo.new(0.2), {Position = F[flag] and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
		if F[flag] then table.insert(ThemeElements.Acc1, Sw) else for i,v in ipairs(ThemeElements.Acc1) do if v==Sw then table.remove(ThemeElements.Acc1,i) end end end
		ApplyTheme()
	end
	table.insert(ConfigUpdaters, updateVisuals)

	Sw.MouseButton1Click:Connect(function() F[flag] = not F[flag]; updateVisuals(); if callback then pcall(callback, F[flag]) end end)
	updateVisuals()
end

local function AddInput(parent, text, flag, isNum)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 26); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 2, 0, 0); L.Size = UDim2.new(0.5, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(230,235,240); L.TextSize = 10; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Box = Instance.new("TextBox"); Box.Parent = Frm; Box.Position = UDim2.new(0.52, 0, 0.1, 0); Box.Size = UDim2.new(0.48, 0, 0.8, 0); table.insert(ThemeElements.TextAcc, Box); Box.TextSize = 10; Box.Font = Enum.Font.GothamBold; Box.BackgroundTransparency = 0.2; table.insert(ThemeElements.Header, Box); local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 4); BC.Parent = Box
	
	local function updateVisuals() Box.Text = tostring(F[flag] or "") end
	table.insert(ConfigUpdaters, updateVisuals)

	Box.FocusLost:Connect(function() F[flag] = isNum and (tonumber(Box.Text) or 0) or Box.Text; updateVisuals() end)
	updateVisuals()
end

local function AddDropdown(parent, title, options, flag, isMulti)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 28); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 2, 0, 0); L.Size = UDim2.new(0.42, 0, 1, 0); L.Text = title; L.TextColor3 = Color3.fromRGB(230,235,240); L.TextSize = 10; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Btn = Instance.new("TextButton"); Btn.Parent = Frm; Btn.Position = UDim2.new(0.44, 0, 0.1, 0); Btn.Size = UDim2.new(0.56, 0, 0.8, 0); table.insert(ThemeElements.TextAcc, Btn); Btn.TextSize = 10; Btn.Font = Enum.Font.GothamBold; Btn.BackgroundTransparency = 0.2; table.insert(ThemeElements.Header, Btn); local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 4); BC.Parent = Btn
	
	local DropList = Instance.new("Frame"); DropList.Parent = MainFrame; DropList.Size = UDim2.new(0, 220, 0, 170); table.insert(ThemeElements.Bg, DropList); DropList.Visible = false; DropList.ZIndex = 200
	local DLC = Instance.new("UICorner"); DLC.CornerRadius = UDim.new(0, 6); DLC.Parent = DropList
	local DLS = Instance.new("UIStroke"); DLS.Thickness = 1; DLS.Parent = DropList; table.insert(ThemeElements.Acc1, DLS)

	local SearchBox = Instance.new("TextBox"); SearchBox.Parent = DropList; SearchBox.Size = UDim2.new(1, -10, 0, 24); SearchBox.Position = UDim2.new(0, 5, 0, 5); SearchBox.PlaceholderText = "🔍 Cari opsi..."; SearchBox.Text = ""; SearchBox.TextSize = 10; SearchBox.Font = Enum.Font.GothamMedium; table.insert(ThemeElements.TextAcc, SearchBox); table.insert(ThemeElements.Header, SearchBox); SearchBox.ZIndex = 201
	local SBC = Instance.new("UICorner"); SBC.CornerRadius = UDim.new(0, 4); SBC.Parent = SearchBox

	local btnAll, btnClear
	if isMulti then
		btnAll = Instance.new("TextButton"); btnAll.Parent = DropList; btnAll.Size = UDim2.new(0.48, 0, 0, 20); btnAll.Position = UDim2.new(0, 5, 0, 32); btnAll.Text = "✓ Semua"; btnAll.TextSize = 9; btnAll.Font = Enum.Font.GothamBold; table.insert(ThemeElements.Header, btnAll); table.insert(ThemeElements.TextAcc, btnAll); btnAll.ZIndex = 201
		local BAC = Instance.new("UICorner"); BAC.CornerRadius = UDim.new(0, 3); BAC.Parent = btnAll

		btnClear = Instance.new("TextButton"); clearBtn = btnClear; clearBtn.Parent = DropList; clearBtn.Size = UDim2.new(0.48, 0, 0, 20); clearBtn.Position = UDim2.new(0.52, 0, 0, 32); clearBtn.Text = "✕ Reset"; clearBtn.TextSize = 9; clearBtn.Font = Enum.Font.GothamBold; clearBtn.TextColor3 = Color3.fromRGB(255, 80, 80); table.insert(ThemeElements.Header, clearBtn); clearBtn.ZIndex = 201
		local BCC = Instance.new("UICorner"); BCC.CornerRadius = UDim.new(0, 3); BCC.Parent = clearBtn
	end

	local ScrollOpts = Instance.new("ScrollingFrame"); ScrollOpts.Parent = DropList; ScrollOpts.Position = UDim2.new(0, 5, 0, isMulti and 56 or 32); ScrollOpts.Size = UDim2.new(1, -10, 1, isMulti and -62 or -38); ScrollOpts.BackgroundTransparency = 1; ScrollOpts.ScrollBarThickness = 2; ScrollOpts.AutomaticCanvasSize = Enum.AutomaticSize.Y; ScrollOpts.CanvasSize = UDim2.new(0,0,0,0); ScrollOpts.ZIndex = 201
	local SLayout = Instance.new("UIListLayout"); SLayout.Parent = ScrollOpts; SLayout.Padding = UDim.new(0, 3)

	local function UpdatePos()
		if DropList.Visible then DropList.Position = UDim2.new(0, Btn.AbsolutePosition.X - MainFrame.AbsolutePosition.X, 0, (Btn.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y) + Btn.AbsoluteSize.Y + 2) end
	end
	Btn:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos)

	local updateCheckList = {}
	local function updateMainBtn() 
		if isMulti then
			local count = #(F[flag] or {})
			Btn.Text = count > 0 and (count .. " Dipilih") or "Pilih Multi..."
		else
			Btn.Text = tostring(F[flag] or "Select")
		end
	end
	table.insert(ConfigUpdaters, updateMainBtn)

	local function Render(filterText)
		for _, v in pairs(ScrollOpts:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
		for _, opt in ipairs(options) do
			if not filterText or filterText == "" or string.find(string.lower(tostring(opt.label)), string.lower(filterText)) then
				local OptBtn = Instance.new("TextButton"); OptBtn.Parent = ScrollOpts; OptBtn.Size = UDim2.new(1, 0, 0, 24); OptBtn.Text = "  " .. tostring(opt.label); OptBtn.TextColor3 = Color3.fromRGB(230,235,240); OptBtn.TextSize = 10; OptBtn.Font = Enum.Font.GothamMedium; OptBtn.TextXAlignment = Enum.TextXAlignment.Left; OptBtn.BackgroundTransparency = 1; OptBtn.ZIndex = 202
				local check = Instance.new("Frame"); check.Parent = OptBtn; check.Size = UDim2.new(0, 10, 0, 10); check.Position = UDim2.new(1, -15, 0.5, -5); local cc = Instance.new("UICorner"); cc.Parent = check; check.ZIndex = 202
				
				local function updateVisuals()
					local sel = false
					if isMulti then for _,v in ipairs(F[flag] or {}) do if v==opt.val then sel=true break end end else sel=(F[flag]==opt.val) end
					if sel then table.insert(ThemeElements.Acc1, check) else for i,v in ipairs(ThemeElements.Acc1) do if v==check then table.remove(ThemeElements.Acc1,i) end end; check.BackgroundColor3 = Color3.fromRGB(40,50,65) end
					ApplyTheme()
				end
				table.insert(ConfigUpdaters, updateVisuals); table.insert(updateCheckList, updateVisuals)
				updateVisuals()

				OptBtn.MouseButton1Click:Connect(function()
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

	Render(""); updateMainBtn()
	SearchBox:GetPropertyChangedSignal("Text"):Connect(function() Render(SearchBox.Text) end)

	if isMulti then
		btnAll.MouseButton1Click:Connect(function()
			F[flag] = {}
			for _, opt in ipairs(options) do table.insert(F[flag], opt.val) end
			updateMainBtn(); for _, fn in ipairs(updateCheckList) do pcall(fn) end
		end)
		clearBtn.MouseButton1Click:Connect(function()
			F[flag] = {}
			updateMainBtn(); for _, fn in ipairs(updateCheckList) do pcall(fn) end
		end)
	end

	Btn.MouseButton1Click:Connect(function() DropList.Visible = not DropList.Visible; UpdatePos() end)
end

local function GetOpts(mode)
	local t = {}
	local inv = inventory()
	if mode == "unit" then
		local placed = {}
		pcall(function() for _, d in pairs(slots()) do if d.unitId then placed[d.unitId] = true end end end)
		if type(inv) == "table" then
			for k, u in pairs(inv) do
				if type(u) == "table" then
					local uName = u.name or u.UnitName or "Unit"
					local uId = u.id or k
					local isPlaced = placed[uId] and " ★" or ""
					table.insert(t, {label = uName .. isPlaced, val = uId})
				end
			end
		end
	elseif mode == "unit_name" then
		local addedNames = {}
		if type(inv) == "table" then
			for _, u in pairs(inv) do
				if type(u) == "table" and (u.name or u.UnitName) then
					local name = u.name or u.UnitName
					if not addedNames[name] then
						addedNames[name] = true
						table.insert(t, {label = name, val = name})
					end
				end
			end
		end
		table.sort(t, function(a,b) return a.label < b.label end)
	elseif mode == "grade" and G.GradesMod then 
		for n, g in pairs(G.GradesMod) do if type(g)=="table" and g.order then table.insert(t, {label=n, val=n, order=g.order}) end end; table.sort(t, function(a,b) return a.order<b.order end)
	elseif mode == "trait" and G.TraitsMod then 
		for n, g in pairs(G.TraitsMod) do if type(g)=="table" then table.insert(t, {label=n, val=n}) end end
	elseif mode == "quirk" then
		table.insert(t, {label="Sovereign", val="Sovereign"})
		table.insert(t, {label="Divine", val="Divine"})
		table.insert(t, {label="Celestial", val="Celestial"})
		table.insert(t, {label="Mythical", val="Mythical"})
		pcall(function()
			if G.MutationsMod then for n, _ in pairs(G.MutationsMod) do table.insert(t, {label=n, val=n}) end end
		end)
	elseif mode == "pot" and G.BoostConfig then 
		for n, e in pairs(G.BoostConfig.entries or {}) do table.insert(t, {label=n, val=n}) end
	elseif mode == "towers" then
		table.insert(t, {label="Auto (best)", val="Auto (best)"})
		pcall(function()
			local all = G.TowersConfig and G.TowersConfig.GetAll and G.TowersConfig.GetAll()
			if type(all) == "table" then for name in pairs(all) do table.insert(t, {label=name, val=name}) end end
		end)
	end
	return t
end

-- ===================================================================== --
-- 4. 9 COMPREHENSIVE TABS ASSEMBLY
-- ===================================================================== --
local T_Dash = CreateTab("Dashboard", "📊")
local T_Farm = CreateTab("Farming", "⛏️")
local T_Hlw = CreateTab("Halloween", "🎃")
local T_Inv = CreateTab("Inventory", "🎒")
local T_Pot = CreateTab("Potions", "🧪")
local T_Grd = CreateTab("Rerolls", "⭐")
local T_Coop = CreateTab("Coop & Team", "🤝")
local T_Twr = CreateTab("Tower", "🏰")
local T_Set = CreateTab("Settings", "⚙️")

TabFrames["Dashboard"].Visible = true; Sidebar:GetChildren()[2].BackgroundTransparency = 0; table.insert(ThemeElements.Acc1, Sidebar:GetChildren()[2])

-- 1. DASHBOARD
local G_Profile = AddGroup(T_Dash, "PROFIL & EQUALIZER SPEKTRUM")
local ProfContainer = Instance.new("Frame"); ProfContainer.Parent = G_Profile; ProfContainer.Size = UDim2.new(1, 0, 0, 70); ProfContainer.BackgroundTransparency = 1
local PImg = Instance.new("ImageLabel"); PImg.Parent = ProfContainer; PImg.AnchorPoint = Vector2.new(0.5, 0.5); PImg.Position = UDim2.new(0.12, 0, 0.45, 0); PImg.Size = UDim2.new(0, 48, 0, 48); pcall(function() PImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end); local PImgC = Instance.new("UICorner"); PImgC.CornerRadius = UDim.new(1,0); PImgC.Parent = PImg; local PStr = Instance.new("UIStroke"); PStr.Thickness = 1.5; PStr.Parent = PImg; table.insert(ThemeElements.Acc1, PStr)

local PLbl = Instance.new("TextLabel"); PLbl.Parent = ProfContainer; PLbl.Position = UDim2.new(0.24, 0, 0, 0); PLbl.Size = UDim2.new(0.76, 0, 0.75, 0); PLbl.BackgroundTransparency = 1; PLbl.TextColor3 = Color3.fromRGB(255,255,255); PLbl.TextSize = 10; PLbl.Font = Enum.Font.GothamMedium; PLbl.TextXAlignment = Enum.TextXAlignment.Left; PLbl.TextYAlignment = Enum.TextYAlignment.Center

local EqualizerLbl = Instance.new("TextLabel"); EqualizerLbl.Parent = ProfContainer; EqualizerLbl.Position = UDim2.new(0.24, 0, 0.75, 0); EqualizerLbl.Size = UDim2.new(0.76, 0, 0.25, 0); EqualizerLbl.BackgroundTransparency = 1; EqualizerLbl.TextColor3 = Color3.fromRGB(0, 240, 255); EqualizerLbl.TextSize = 10; EqualizerLbl.Font = Enum.Font.GothamBold; EqualizerLbl.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
	local bars = {"▂▃▅▇█▇▅▃▂", "▃▅▇█▇▅▃▂▃", "▅▇█▇▅▃▂▃▅", "▇█▇▅▃▂▃▅▇", "█▇▅▃▂▃▅▇█"}
	local i = 1
	while task.wait(0.3) do
		STATE.equalizerBar = bars[i]
		EqualizerLbl.Text = "EQUALIZER: " .. STATE.equalizerBar
		i = i % #bars + 1
	end
end)

local G_Spy = AddGroup(T_Dash, "LIVE PERFORMANCE & FARMING RATE")
local SLbl = Instance.new("TextLabel"); SLbl.Parent = G_Spy; SLbl.Size = UDim2.new(1, 0, 0, 85); SLbl.BackgroundTransparency = 1; SLbl.TextColor3 = Color3.fromRGB(255,255,255); SLbl.TextSize = 10; SLbl.Font = Enum.Font.GothamMedium; SLbl.TextXAlignment = Enum.TextXAlignment.Left; SLbl.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
	while task.wait(1) do pcall(function()
		local m = money(); local rb = rebirthAmt(); local rls = G.DC.Rolls() or 0
		PLbl.Text = string.format("<b>[PLAYER]</b> %s\n<b>[MONEY]</b> %s | <b>[REBIRTH]</b> %s | <b>[ROLLS]</b> %s", LocalPlayer.Name, tostring(m), tostring(rb), tostring(rls))
		local mut, trt, grd, tot = 0,0,0,0; for _, e in pairs(inventory()) do if isUnitEntry(e) then tot += 1; if e.attributes then if e.attributes.mutation then mut+=1 end; if e.attributes.trait then trt+=1 end; if e.attributes.grade then grd+=1 end end end end
		local buffs = ""; if G.BuffController and G.BuffController.ActiveBuffs then for k,v in pairs(G.BuffController.ActiveBuffs) do buffs = buffs..k..", " end end; if buffs=="" then buffs="Tidak ada" end; STATE.activeBuffs = buffs
		SLbl.Text = string.format("💎 Gems: %d | Runs: %d | Wins: %d\n📈 Rate: %s | Coop: %s\n🧪 Active Buffs: %s", currencyAmount("Gems"), STATE.towerRuns, STATE.towerWins, STATE.farmingRate, STATE.coopStatus, STATE.activeBuffs)
	end) end
end)

-- 2. FARMING
local G_Farm1 = AddGroup(T_Farm, "STAND MONEY, PLOT & REBIRTH")
AddToggle(G_Farm1, "Auto Collect Stand Money", "collect")
local BtnCollectNow = Instance.new("TextButton"); BtnCollectNow.Parent = G_Farm1; BtnCollectNow.Size = UDim2.new(1, 0, 0, 26); BtnCollectNow.Text = "💵 COLLECT STAND MONEY NOW"; BtnCollectNow.Font = Enum.Font.GothamBold; BtnCollectNow.TextSize = 10; table.insert(ThemeElements.Card, BtnCollectNow); table.insert(ThemeElements.TextAcc, BtnCollectNow); local BCN = Instance.new("UICorner"); BCN.CornerRadius = UDim.new(0,4); BCN.Parent = BtnCollectNow
BtnCollectNow.MouseButton1Click:Connect(function() pcall(function() for _, s in ipairs(unlockedSlots()) do safeInvoke("CollectBalance", R.CollectBalance, s) end end) end)

AddToggle(G_Farm1, "Auto Smart Best Place Base", "autoBestPlaceBase")
AddToggle(G_Farm1, "Auto Rebirth (Anti-Spam)", "rebirth")
AddToggle(G_Farm1, "Auto Buy Upgrades", "upgrades")
AddInput(G_Farm1, "Min Stand Gain Factor:", "minStandGain", true)

local G_Farm2 = AddGroup(T_Farm, "DICE & SPINS AUTOMATION")
AddToggle(G_Farm2, "Auto Roll Dadu", "autoRoll")
AddToggle(G_Farm2, "Auto Use Spins", "autoSpins")
AddToggle(G_Farm2, "Auto Buy Dice", "buyDice")
AddToggle(G_Farm2, "Prioritize Dice Purchases", "prioritizeDice")
AddToggle(G_Farm2, "Auto Equip Best Die", "equipDice")

-- 3. HALLOWEEN
local G_HlwTeleport = AddGroup(T_Hlw, "HALLOWEEN EVENT TELEPORT & INTRO")
AddToggle(G_HlwTeleport, "Auto Teleport Ke Halloween World", "halloweenTeleport")

local G_HlwRoll = AddGroup(T_Hlw, "PUMPKIN DICE & UNIT MANAGEMENT")
AddDropdown(G_HlwRoll, "Pilih Kuantitas Pumpkin Roll:", {{label="Roll 1x", val=1}, {label="Roll 5x", val=5}}, "pumpkinRollQty", false)
AddToggle(G_HlwRoll, "Auto Pumpkin Dice Roll", "pumpkinAutoRoll")
AddToggle(G_HlwRoll, "Auto Sell Pumpkin Units", "pumpkinAutoSell")

local G_HlwQuests = AddGroup(T_Hlw, "HALLOWEEN REWARDS & QUESTS")
AddToggle(G_HlwQuests, "Auto Claim Halloween Quests", "halloweenQuest")
AddToggle(G_HlwQuests, "Auto Claim Halloween Path Rewards", "halloweenPath")
AddToggle(G_HlwQuests, "Auto Buy Halloween Special Offers", "halloweenOffer")
AddToggle(G_HlwQuests, "Auto Trick or Treat (Knock Doors)", "trickOrTreat")

local G_HauntedTwr = AddGroup(T_Hlw, "HAUNTED TOWER FARMING")
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
AddInput(G_HauntedTwr, "Lantai Exit Haunted:", "hauntedExitFloor", true)

-- 4. INVENTORY
local G_Inv = AddGroup(T_Inv, "MANAGEMENT, LOCK & FUSION")
AddToggle(G_Inv, "Auto Sell Unit", "sellAuto")
AddInput(G_Inv, "Simpan Unit Terbaik (Keep Best):", "keepBest", true)
AddToggle(G_Inv, "Auto Fusion Unit", "autoFuse")
AddToggle(G_Inv, "Fuse Duplicates Only", "fuseDuplicatesOnly")
AddToggle(G_Inv, "Fuse Unmutated Units Only", "fuseUnmutatedOnly")
AddToggle(G_Inv, "Prioritize Matching Units", "prioritizeMatching")
AddToggle(G_Inv, "Protect Top Units (Fusion Budget)", "fusionBudgetTopProtect")
AddDropdown(G_Inv, "Pilih Unit Untuk DI-LOCK:", GetOpts("unit"), "lockedUnits", true)
AddDropdown(G_Inv, "Loadouts Presets (Inventory Unit):", {{label="Preset 1", val="Preset 1"}, {label="Preset 2", val="Preset 2"}, {label="Preset 3", val="Preset 3"}}, "activeLoadout", false)

-- 5. POTIONS
local G_Pot = AddGroup(T_Pot, "SMART POTION MANAGER")
AddToggle(G_Pot, "Auto Gunakan Potion", "potionAuto")
AddDropdown(G_Pot, "Pilih Potion Spesifik:", GetOpts("pot"), "potionSpecific", true)
AddInput(G_Pot, "Potion Reserve:", "potionReserve", true)
AddInput(G_Pot, "Max Potions Per Trade:", "maxPotionsPerTrade", true)

local BtnReqPot = Instance.new("TextButton"); BtnReqPot.Parent = G_Pot; BtnReqPot.Size = UDim2.new(1, 0, 0, 26); BtnReqPot.Text = "🧪 REQUEST POTIONS NOW"; BtnReqPot.Font = Enum.Font.GothamBold; BtnReqPot.TextSize = 10; table.insert(ThemeElements.Card, BtnReqPot); table.insert(ThemeElements.TextAcc, BtnReqPot); local BRP = Instance.new("UICorner"); BRP.CornerRadius = UDim.new(0,4); BRP.Parent = BtnReqPot
BtnReqPot.MouseButton1Click:Connect(function() pcall(function() print("Potion requested!") end) end)

-- 6. REROLLS
local G_Grd = AddGroup(T_Grd, "GRADE REROLL CONFIG")
AddToggle(G_Grd, "Aktifkan Auto Grade", "gradeAuto")
AddToggle(G_Grd, "Hanya Unit di Base (Placed)", "gradePlacedOnly")
AddToggle(G_Grd, "Protect Rare Grades", "protectRareGrades")
AddDropdown(G_Grd, "Target Grade (Protected Skip):", GetOpts("grade"), "gradeTargets", true)
AddDropdown(G_Grd, "Pilih Unit Spesifik (Inventaris):", GetOpts("unit"), "gradeUnits", true)
AddInput(G_Grd, "Sisakan Gems:", "gemReserve", true)
AddInput(G_Grd, "Max Rerolls Per Unit:", "maxRerollsPerUnit", true)

local G_Trt = AddGroup(T_Grd, "TRAIT REROLL CONFIG")
AddToggle(G_Trt, "Aktifkan Auto Trait", "traitAuto")
AddToggle(G_Trt, "Hanya Unit di Base (Placed)", "traitPlacedOnly")
AddToggle(G_Trt, "Protect Rare Traits", "protectRareTraits")
AddDropdown(G_Trt, "Target Trait (Protected Skip):", GetOpts("trait"), "traitTargets", true)
AddDropdown(G_Trt, "Pilih Unit Spesifik (Inventaris):", GetOpts("unit"), "traitUnits", true)
AddInput(G_Trt, "Sisakan Trait Item:", "rerollReserve", true)

local G_Qrk = AddGroup(T_Grd, "QUIRK / MUTATION REROLL CONFIG")
AddToggle(G_Qrk, "Aktifkan Auto Quirk", "quirkAuto")
AddToggle(G_Qrk, "Hanya Unit di Base (Placed)", "quirkPlacedOnly")
AddDropdown(G_Qrk, "Target Quirk Tertinggi:", GetOpts("quirk"), "quirkTargets", true)
AddDropdown(G_Qrk, "Pilih Unit Spesifik (Inventaris):", GetOpts("unit"), "quirkUnits", true)
AddInput(G_Qrk, "Sisakan Quirk Item / Gems:", "quirkReserve", true)

-- 7. COOP & TEAM
local G_Coop = AddGroup(T_Coop, "LOCAL COOPERATION & PARTNERS")
AddToggle(G_Coop, "Local Cooperation Between Accounts", "localCoop")
AddInput(G_Coop, "Partner Username:", "partnerUsername", false)
AddToggle(G_Coop, "Auto Assign Towers by Team Power", "autoAssignPower")
AddToggle(G_Coop, "Auto Start Assigned Tower Farm", "autoStartCoop")
AddToggle(G_Coop, "Auto Accept Partner Trades", "acceptPartnerTrades")
AddInput(G_Coop, "Predicted Floor Threshold:", "predictedFloorThreshold", true)

local BtnRecalc = Instance.new("TextButton"); BtnRecalc.Parent = G_Coop; BtnRecalc.Size = UDim2.new(1, 0, 0, 26); BtnRecalc.Text = "🔄 RECALCULATE ASSIGNMENTS NOW"; BtnRecalc.Font = Enum.Font.GothamBold; BtnRecalc.TextSize = 10; table.insert(ThemeElements.Card, BtnRecalc); table.insert(ThemeElements.TextAcc, BtnRecalc); local BRC = Instance.new("UICorner"); BRC.CornerRadius = UDim.new(0,4); BRC.Parent = BtnRecalc
BtnRecalc.MouseButton1Click:Connect(function() pcall(function() STATE.coopStatus = "Recalculated" end) end)

-- 8. TOWER
local G_Twr = AddGroup(T_Twr, "TOWER UTAMA & QUEUE SETUP")
AddToggle(G_Twr, "Auto Tower Farm", "tower")
AddToggle(G_Twr, "Mode MIX / Random Tower", "towerMix")
AddDropdown(G_Twr, "Select Multiple Towers / Queue:", GetOpts("towers"), "towerQueue", true)
AddToggle(G_Twr, "Auto Equip Best Tower Team", "towerEquipBest")

local BtnEquipTeamNow = Instance.new("TextButton"); BtnEquipTeamNow.Parent = G_Twr; BtnEquipTeamNow.Size = UDim2.new(1, 0, 0, 26); BtnEquipTeamNow.Text = "⚔️ EQUIP BEST TEAM NOW"; BtnEquipTeamNow.Font = Enum.Font.GothamBold; BtnEquipTeamNow.TextSize = 10; table.insert(ThemeElements.Card, BtnEquipTeamNow); table.insert(ThemeElements.TextAcc, BtnEquipTeamNow); local BETN = Instance.new("UICorner"); BETN.CornerRadius = UDim.new(0,4); BETN.Parent = BtnEquipTeamNow
BtnEquipTeamNow.MouseButton1Click:Connect(function() pcall(function() safeInvoke("BestTowerTeam", R.BestTowerTeam) end) end)

AddToggle(G_Twr, "Keluar di Lantai Tertentu", "towerExitOn")
AddInput(G_Twr, "Lantai Exit:", "towerExitFloor", true)
AddInput(G_Twr, "Tower Restart Delay (s):", "towerRestartDelay", true)
AddInput(G_Twr, "Missing Run Tolerance:", "missingRunTolerance", true)

local G_TwrMon = AddGroup(T_Twr, "LIVE TOWER MONITORING & RATES")
local TwrLbl = Instance.new("TextLabel"); TwrLbl.Parent = G_TwrMon; TwrLbl.Size = UDim2.new(1,0,0,75); TwrLbl.BackgroundTransparency = 1; TwrLbl.TextColor3 = Color3.fromRGB(255,255,255); TwrLbl.TextSize = 10; TwrLbl.Font = Enum.Font.GothamMedium; TwrLbl.TextXAlignment = Enum.TextXAlignment.Left; TwrLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function() while task.wait(0.5) do pcall(function() TwrLbl.Text = string.format("🎮 Status: %s | Floor: %d\n💎 Gems: %d | Runs: %d | Wins: %d\n📈 Rate: %s | Traits: %s", STATE.towerLive, STATE.towerFloor, STATE.towerDrops, STATE.towerRuns, STATE.towerWins, STATE.farmingRate, tostring(STATE.towerTraitsGot)) end) end end)

-- 9. SETTINGS
local G_Set1 = AddGroup(T_Set, "UI SCALE & GLOBAL CONTROLS")
AddInput(G_Set1, "Ukuran UI (0.5 s.d 1.1):", "uiScaleValue", true)
local BtnScale = Instance.new("TextButton"); BtnScale.Parent = G_Set1; BtnScale.Size = UDim2.new(1, 0, 0, 28); BtnScale.Text = "📐 TERAPKAN UKURAN UI"; BtnScale.Font = Enum.Font.GothamBold; BtnScale.TextSize = 10; table.insert(ThemeElements.Card, BtnScale); table.insert(ThemeElements.TextAcc, BtnScale); local BTScl = Instance.new("UICorner"); BTScl.CornerRadius = UDim.new(0,5); BTScl.Parent = BtnScale
BtnScale.MouseButton1Click:Connect(function() UpdateScale() end)

AddToggle(G_Set1, "Pause All Automations", "pauseAll")
AddToggle(G_Set1, "Hide Tower Screen (Performance)", "hideTowerScreen", function(v) pcall(function() if workspace:FindFirstChild("Towers") then workspace.Towers.Parent = v and CoreGui or ReplicatedStorage end end) end)

local G_SetRewards = AddGroup(T_Set, "REWARDS & CODES AUTOMATION")
AddToggle(G_SetRewards, "Auto Claim Daily, Offline, Group, Quests", "claimQuests")
AddToggle(G_SetRewards, "Auto Redeem Codes", "codesAuto")

local BtnClaimNow = Instance.new("TextButton"); BtnClaimNow.Parent = G_SetRewards; BtnClaimNow.Size = UDim2.new(1, 0, 0, 26); BtnClaimNow.Text = "🎁 CLAIM ALL REWARDS NOW"; BtnClaimNow.Font = Enum.Font.GothamBold; BtnClaimNow.TextSize = 10; table.insert(ThemeElements.Card, BtnClaimNow); table.insert(ThemeElements.TextAcc, BtnClaimNow); local BCNw = Instance.new("UICorner"); BCNw.CornerRadius = UDim.new(0,4); BCNw.Parent = BtnClaimNow
BtnClaimNow.MouseButton1Click:Connect(function()
	pcall(function()
		safeInvoke("ClaimDaily", R.ClaimDaily)
		safeInvoke("ClaimOffline", R.ClaimOffline)
		safeInvoke("ClaimGroup", R.ClaimGroup)
	end)
end)

local G_SetConfig = AddGroup(T_Set, "CONFIG & FILE MANAGER")
AddToggle(G_SetConfig, "Auto Load Config Saat Nyala", "autoLoadEnabled")
AddInput(G_SetConfig, "Nama File Config:", "cfgName", false)

local BtnSave = Instance.new("TextButton"); BtnSave.Parent = G_SetConfig; BtnSave.Size = UDim2.new(1, 0, 0, 26); BtnSave.Text = "💾 SAVE CONFIG"; BtnSave.Font = Enum.Font.GothamBold; BtnSave.TextSize = 10; table.insert(ThemeElements.Header, BtnSave); table.insert(ThemeElements.TextAcc, BtnSave); local BTS = Instance.new("UICorner"); BTS.CornerRadius = UDim.new(0,4); BTS.Parent = BtnSave
BtnSave.MouseButton1Click:Connect(function() pcall(function() saveConfig(F.cfgName) end) end)

local BtnLoad = Instance.new("TextButton"); BtnLoad.Parent = G_SetConfig; BtnLoad.Size = UDim2.new(1, 0, 0, 26); BtnLoad.Text = "📂 LOAD CONFIG"; BtnLoad.Font = Enum.Font.GothamBold; BtnLoad.TextSize = 10; table.insert(ThemeElements.Header, BtnLoad); table.insert(ThemeElements.TextAcc, BtnLoad); local BTL = Instance.new("UICorner"); BTL.CornerRadius = UDim.new(0,4); BTL.Parent = BTL
BtnLoad.MouseButton1Click:Connect(function() pcall(function() loadConfig(F.cfgName) end) end)

local G_Web = AddGroup(T_Set, "DISCORD WEBHOOK")
AddToggle(G_Web, "Aktifkan Webhook", "webhookEnabled")
AddInput(G_Web, "Webhook URL:", "webhookUrl", false)

local G_SetOpts = AddGroup(T_Set, "OPTIMALISASI & TOOLS")
AddToggle(G_SetOpts, "Anti-AFK", "afk")
AddToggle(G_SetOpts, "FPS Boost", "fpsOn", function(v) if v then pcall(function() game:GetService("Lighting").GlobalShadows = false; for _,e in ipairs(workspace:GetDescendants()) do if e:IsA("BasePart") then e.Material = Enum.Material.SmoothPlastic end end end) end end)

ApplyTheme()

-- ===================================================================== --
-- 5. 100% COMPLETE BACKEND EXECUTION ENGINES (WITH ACTIVE ERROR LOGGERS)
-- ===================================================================== --
local vu = game:GetService("VirtualUser")

LocalPlayer.Idled:Connect(function()
	if F.afk and not F.pauseAll then
		pcall(function()
			vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
			task.wait(1)
			vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
		end)
	end
end)

-- 1. Tower Farm Engine
task.spawn(function()
	local startTime = os.clock()
	local totalFloorsClimbed = 0
	while _G.__ADYFAHUB == generation do
		if F.tower and not F.pauseAll and R.PlayTower and R.CompleteFloor then
			if F.towerEquipBest and R.BestTowerTeam then safeInvoke("BestTowerTeam", R.BestTowerTeam) end
			task.wait(0.5)

			local queue = F.towerQueue
			local pickTower = "Auto (best)"
			if type(queue) == "table" and #queue > 0 then
				pickTower = queue[math.random(1, #queue)]
			else
				pickTower = "Dragon Tower"
			end

			STATE.towerLive = "Memulai: " .. tostring(pickTower); STATE.towerDrops = 0
			STATE.towerRuns += 1

			local okStart, started = safeInvoke("PlayTower", R.PlayTower, pickTower)
			if okStart and started then
				local done, fails = false, 0
				while F.tower and not F.pauseAll and not done do
					local okP, seq = safeInvoke("CompleteFloor", R.CompleteFloor)
					if okP and type(seq) == "table" and #seq > 0 then
						fails = 0
						for _, act in ipairs(seq) do
							if act.action == "floorStarted" then 
								STATE.towerFloor = tonumber(act.floor) or 1
								totalFloorsClimbed += 1
								local elapsed = math.max(1, os.clock() - startTime)
								STATE.farmingRate = string.format("%.1f fl/m", (totalFloorsClimbed / elapsed) * 60)
							elseif act.action == "floorCompleted" then
								if act.rewards and act.rewards.Gems then STATE.towerDrops += act.rewards.Gems end
								if act.rewards and (act.rewards.Trait or act.trait) then STATE.towerTraitsGot = tostring(act.rewards.Trait or act.trait) end
							elseif act.action == "ended" then done = true; STATE.towerWins += 1; break end
						end
						if not done and F.towerExitOn and F.towerExitFloor > 0 and STATE.towerFloor >= F.towerExitFloor then done = true end
					else 
						fails += 1
						if fails > (F.missingRunTolerance or 5) then done = true end
						task.wait(1) 
					end
				end
			end
			pcall(function() if R.CancelTower then safeInvoke("CancelTower", R.CancelTower) end end)
			task.wait(F.towerRestartDelay or 3)
		else 
			STATE.towerLive = "Standby"
			task.wait(2) 
		end
	end
end)

-- 2. Auto Roll & Stand Collect Engine
task.spawn(function()
	while _G.__ADYFAHUB == generation do
		if not F.pauseAll then
			if F.collect and R.CollectBalance then
				pcall(function() for _, slot in ipairs(unlockedSlots()) do safeInvoke("CollectBalance", R.CollectBalance, slot) end end)
			end
			if F.autoRoll and R.RollDice then
				pcall(function() safeInvoke("RollDice", R.RollDice) end)
				task.wait(2.0 + math.random(0, 3) * 0.1)
			end
		end
		task.wait(1)
	end
end)

-- 3. Auto Sell & Inventory Cleanup Engine
task.spawn(function()
	while _G.__ADYFAHUB == generation do
		if not F.pauseAll and F.sellAuto and R.SellInventory then
			pcall(function()
				local d = data()
				local cap = 100
				pcall(function()
					local buff = tonumber(select(2, pcall(G.BuffController.GetBuff, "Unit Storage")))
					if buff and buff > 0 then cap = buff end
				end)

				local placed = {}
				for _, slot in pairs(d.Slots or {}) do if slot.unitId then placed[slot.unitId] = true end end
				local lockedMap = {}; for _, lid in ipairs(F.lockedUnits or {}) do lockedMap[lid] = true end

				local units, owned = {}, 0
				for id, u in pairs(d.Inventory or {}) do
					local e = G.UnitConfig and G.UnitConfig.entries[u.name or u.UnitName]
					if e then owned = owned + 1 end
					local isProt = (u.attributes and u.attributes.locked) or lockedMap[id]
					if not placed[id] and not isProt then table.insert(units, { id = id }) end
				end
				local pressured = owned >= cap - 3
				local sellable = math.max(0, #units - (F.keepBest or 20))
				local list = {}
				for i, unit in ipairs(units) do
					if pressured or i <= sellable then
						list[#list + 1] = unit.id
						if #list >= 300 then break end
					end
				end
				if #list > 0 then safeInvoke("SellInventory", R.SellInventory, list) end
			end)
		end
		task.wait(4)
	end
end)

-- 4. Halloween & Haunted Tower Engine
task.spawn(function()
	while _G.__ADYFAHUB == generation do
		if not F.pauseAll then
			if F.halloweenTeleport then
				pcall(function()
					if R.HWTeleport then safeInvoke("HWTeleport", R.HWTeleport, "Halloween") end
					if R.HWSeenIntro then safeInvoke("HWSeenIntro", R.HWSeenIntro) end
				end)
			end
			if F.halloweenQuest and R.HWQuestClaim then pcall(function() safeInvoke("HWQuestClaim", R.HWQuestClaim) end) end
			if F.halloweenPath and R.HWClaimPath then pcall(function() safeInvoke("HWClaimPath", R.HWClaimPath) end) end
			if F.trickOrTreat and R.TrickOrTreat then pcall(function() safeInvoke("TrickOrTreat", R.TrickOrTreat) end) end
		end
		task.wait(5)
	end
end)

-- 5. Rewards & Codes Engine
task.spawn(function()
	while _G.__ADYFAHUB == generation do
		if not F.pauseAll then
			if F.claimQuests then
				pcall(function()
					safeInvoke("ClaimDaily", R.ClaimDaily)
					safeInvoke("ClaimOffline", R.ClaimOffline)
					safeInvoke("ClaimGroup", R.ClaimGroup)
				end)
			end
			if F.codesAuto and R.RedeemCode then
				pcall(function()
					local defaultCodes = { "RELEASE", "UPDATE1", "UPDATE2", "UPDATE3", "UPDATE4", "1KCCU", "5KCCU", "10KCCU", "20KCCU", "30KCCU", "40KCCU", "100KLIKES" }
					local redeemed = G.DC.RedeemedCodes() or {}
					for _, c in ipairs(defaultCodes) do if not redeemed[c] then safeInvoke("RedeemCode", R.RedeemCode, c); task.wait(0.5) end end
				end)
			end
		end
		task.wait(60)
	end
end)
