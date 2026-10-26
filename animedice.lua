-- ===================================================================== --
-- 👑 MOFENKHUB V97.0 — ULTIMATE MASTER SUITE (REFINED & FIXED)
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

pcall(function() for _, v in pairs(parentGui:GetChildren()) do if string.find(v.Name, "Mofenk") then v:Destroy() end end end)

-- ===================================================================== --
-- 1. STATE & CONFIGURATION MANAGER
-- ===================================================================== --
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

local F = {
	themeIndex = 1, cfgName = "MofenkConfig1", autoLoadEnabled = false,
	-- Farm, Roll & Best Place Base
	collect = false, levelup = false, maxLevel = 40, smartLevel = false,
	rebirth = false, upgrades = false, buyDice = true, equipDice = true, autoRoll = false,
	autoBestPlaceBase = false, smartPlace = true,
	-- Inv & Sell
	sellAuto = false, keepBest = 20, autoFuse = false, specificSellUnits = {},
	-- Potion
	potionAuto = false, potionBest = true, potionSpecific = {},
	-- Reroll
	gradeAuto = false, gradeAll = false, gradePlacedOnly = false, gradeTargets = {}, gradeUnits = {}, gemReserve = 100,
	traitAuto = false, traitAll = false, traitPlacedOnly = false, traitTargets = {}, traitUnits = {}, rerollReserve = 50,
	-- Tower Utama
	tower = false, towerName = "Auto (best)", towerMix = false, towerEquipBest = true, towerExitOn = false, towerExitFloor = 50,
	-- Halloween & Haunted Tower Features
	halloweenTeleport = false, halloweenQuest = false, halloweenPath = false, halloweenOffer = false, trickOrTreat = false,
	pumpkinRollQty = 1, pumpkinAutoRoll = false, pumpkinAutoSell = false,
	hauntedTower = false, hauntedMix = false, hauntedList = {"Haunted Front Yard", "Haunted Crypt", "Haunted Attic", "Haunted Bell Tower"}, hauntedEquipBest = true, hauntedExitOn = false, hauntedExitFloor = 50,
	-- Client & Misc
	wsOn = false, wsValue = 16, noclip = false, afk = true, fpsOn = false,
	codesAuto = false, claimQuests = false,
	-- Webhook
	webhookEnabled = false, webhookUrl = ""
}

local STATE = { towerLive = "Standby", towerFloor = 0, towerDrops = 0, towerTraitsGot = "Belum Ada", hauntedLive = "Standby", hauntedFloor = 0, hauntedDrops = 0, activeBuffs = "Tidak Ada" }
local ConfigUpdaters = {}

local THEMES = {
	{ Name = "Cyberpunk", Bg = Color3.fromRGB(10, 5, 15), Card = Color3.fromRGB(20, 15, 30), Header = Color3.fromRGB(15, 10, 20), Acc1 = Color3.fromRGB(0, 255, 255), Acc2 = Color3.fromRGB(255, 0, 128) },
	{ Name = "Halloween Spooky", Bg = Color3.fromRGB(15, 8, 5), Card = Color3.fromRGB(30, 15, 10), Header = Color3.fromRGB(22, 10, 6), Acc1 = Color3.fromRGB(255, 140, 0), Acc2 = Color3.fromRGB(138, 43, 226) },
	{ Name = "Toxic Glow", Bg = Color3.fromRGB(5, 10, 5), Card = Color3.fromRGB(15, 25, 15), Header = Color3.fromRGB(10, 15, 10), Acc1 = Color3.fromRGB(57, 255, 20), Acc2 = Color3.fromRGB(173, 255, 47) },
	{ Name = "Crimson Hell", Bg = Color3.fromRGB(12, 0, 0), Card = Color3.fromRGB(25, 5, 5), Header = Color3.fromRGB(18, 2, 2), Acc1 = Color3.fromRGB(255, 20, 20), Acc2 = Color3.fromRGB(255, 100, 0) },
}
local ThemeElements = { Bg = {}, Card = {}, Header = {}, Acc1 = {}, Grad = {}, TextAcc = {} }

local function ApplyTheme(idx)
	local t = THEMES[idx] or THEMES[1]
	for _, v in ipairs(ThemeElements.Bg) do v.BackgroundColor3 = t.Bg end
	for _, v in ipairs(ThemeElements.Card) do v.BackgroundColor3 = t.Card end
	for _, v in ipairs(ThemeElements.Header) do v.BackgroundColor3 = t.Header end
	for _, v in ipairs(ThemeElements.Acc1) do if v:IsA("UIStroke") then v.Color = t.Acc1 else v.BackgroundColor3 = t.Acc1 end end
	for _, v in ipairs(ThemeElements.Grad) do v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, t.Acc1), ColorSequenceKeypoint.new(1, t.Acc2)}) end
	for _, v in ipairs(ThemeElements.TextAcc) do v.TextColor3 = t.Acc1 end
end

local CFG_FOLDER = "MofenkHub_Configs"
if makefolder and not isfolder(CFG_FOLDER) then pcall(function() makefolder(CFG_FOLDER) end) end

local function getCfgPath(name) return CFG_FOLDER .. "/" .. (name or F.cfgName or "DefaultConfig") .. ".json" end

local function saveConfig(name)
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

local function loadConfig(name)
	local path = getCfgPath(name)
	if readfile and isfile and isfile(path) then
		pcall(function() 
			local d = HttpService:JSONDecode(readfile(path))
			for k,v in pairs(d) do F[k]=v end 
			for _, updateUI in ipairs(ConfigUpdaters) do pcall(updateUI) end
			ApplyTheme(F.themeIndex)
		end)
	end
end

pcall(function()
	local pointerPath = CFG_FOLDER .. "/autoload_pointer.txt"
	if readfile and isfile and isfile(pointerPath) then
		local autoName = readfile(pointerPath)
		if autoName and autoName ~= "" then 
			F.cfgName = autoName
			local d = HttpService:JSONDecode(readfile(getCfgPath(autoName)))
			for k,v in pairs(d) do F[k]=v end 
			F.autoLoadEnabled = true 
		end
	end
end)

-- ===================================================================== --
-- 2. FRAMEWORK & MODULE BINDINGS
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
	-- Halloween & Haunted Services
	HWTeleport      = svc("HalloweenService.RF.Teleport"),
	HWSeenIntro     = svc("HalloweenService.RE.SeenIntro"),
	HWQuestClaim    = svc("HalloweenQuestService.RE.Claim"),
	HWClaimPath     = svc("HalloweenService.RE.ClaimAllPath"),
	HWBuyOffer      = svc("HalloweenService.RE.BuyOffer"),
	TrickOrTreat    = svc("TrickOrTreatService.RE.Knocked"),
	PumpkinRoll     = svc("PumpkinDiceService.RF.Roll") or svc("PumpkinDiceService.RE.Roll"),
	PumpkinAutoSell = svc("PumpkinDiceService.RE.SetAutoSell")
}

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
local function slots() return data().Slots or {} end
local function isUnitEntry(e) return e and type(e)=="table" and e.name and G.EntryRegistry and pcall(function() return G.EntryRegistry.getEntryConfig(e.name).kind == "Unit" end) end
local function currencyAmount(name) local t = 0; for _, e in pairs(inventory()) do if type(e)=="table" and e.name==name then t += tonumber(e.amount) or 0 end end; return t end

local function baseIncome(u)
	local e = u and G.UnitConfig and G.UnitConfig.entries[u.name]
	if not e then return 0 end
	local a = u.attributes or {}
	return tonumber(select(2, pcall(e.income, { mutation = a.mutation, grade = a.grade, trait = a.trait, level = 1 }))) or 0
end

local function SendWebhook(title, description, colorCode)
	if not F.webhookEnabled or F.webhookUrl == "" then return end
	local req = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
	if req then
		pcall(function()
			req({
				Url = F.webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"},
				Body = HttpService:JSONEncode({ username = "MofenkHub", avatar_url = "https://i.imgur.com/3qGMB7j.png", embeds = {{ title = title, description = description, color = colorCode or 3447003, footer = {text = "Player: " .. LocalPlayer.Name} }} })
			})
		end)
	end
end

-- ===================================================================== --
-- 3. INTERACTIVE "M" LOGO TOGGLE
-- ===================================================================== --
local ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "MofenkToggleFront"; ToggleGui.Parent = parentGui; ToggleGui.ResetOnSpawn = false
ToggleGui.DisplayOrder = 99999

local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = ToggleGui; ToggleBtn.Size = UDim2.new(0, 60, 0, 60); ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = THEMES[1].Card; ToggleBtn.Text = "M"; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 32; ToggleBtn.TextColor3 = THEMES[1].Acc1; ToggleBtn.ZIndex = 99999
local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 16); TC.Parent = ToggleBtn
local TS = Instance.new("UIStroke"); TS.Thickness = 3; TS.Parent = ToggleBtn; table.insert(ThemeElements.Acc1, TS)

local dragging, dragInput, dragStart, startPos
ToggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = input.Position; startPos = ToggleBtn.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
	end
end)
ToggleBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart; local viewport = workspace.CurrentCamera.ViewportSize
		ToggleBtn.Position = UDim2.new(0, math.clamp(startPos.X.Offset + delta.X, 10, viewport.X - 70), 0, math.clamp(startPos.Y.Offset + delta.Y, 10, viewport.Y - 70))
	end
end)

-- ===================================================================== --
-- 4. ULTIMATE UI SETUP (SCALED & LARGE TEXT FOR HIGH READABILITY)
-- ===================================================================== --
local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkUltraHubV97"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 960, 0, 620); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.BackgroundTransparency = 0.1; table.insert(ThemeElements.Bg, MainFrame)
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 18); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 3.5; MainStroke.Parent = MainFrame
local StrokeGrad = Instance.new("UIGradient"); StrokeGrad.Parent = MainStroke; table.insert(ThemeElements.Grad, StrokeGrad)

local ScreenScale = Instance.new("UIScale"); ScreenScale.Parent = MainGui
local function UpdateScale()
	local viewport = workspace.CurrentCamera.ViewportSize
	local scaleX = viewport.X / 1300; local scaleY = viewport.Y / 750
	ScreenScale.Scale = math.clamp(math.min(scaleX, scaleY), 0.65, 1.2)
end
UpdateScale(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 52); TopBar.BackgroundTransparency = 0.15; table.insert(ThemeElements.Header, TopBar)
local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 22, 0, 0); Title.Size = UDim2.new(0, 550, 1, 0); Title.Text = "👑 MOFENKHUB V97.0  |  ANIME DICE ULTIMATE"; Title.TextSize = 14; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, Title)

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -46, 0, 10); CloseBtn.Size = UDim2.new(0, 32, 0, 32); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(255,255,255); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 15; CloseBtn.BackgroundTransparency = 0.2; table.insert(ThemeElements.Card, CloseBtn)
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 10); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = MainFrame; Sidebar.Position = UDim2.new(0, 12, 0, 60); Sidebar.Size = UDim2.new(0, 195, 1, -70); Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 3; Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y; Sidebar.CanvasSize = UDim2.new(0,0,0,0)
local SideLayout = Instance.new("UIListLayout"); Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y; SideLayout.Parent = Sidebar; SideLayout.Padding = UDim.new(0, 7)

local ContentArea = Instance.new("Frame"); ContentArea.Parent = MainFrame; ContentArea.Position = UDim2.new(0, 215, 0, 60); ContentArea.Size = UDim2.new(1, -225, 1, -70); ContentArea.BackgroundTransparency = 0.25; table.insert(ThemeElements.Header, ContentArea)
local ContentCorner = Instance.new("UICorner"); ContentCorner.CornerRadius = UDim.new(0, 14); ContentCorner.Parent = ContentArea

local TabFrames, TabButtons = {}, {}
local function CreateTab(name, icon)
	local Btn = Instance.new("TextButton"); Btn.Parent = Sidebar; Btn.Size = UDim2.new(1, -4, 0, 42); Btn.Text = "   " .. icon .. "   " .. name; Btn.TextColor3 = Color3.fromRGB(240,240,240); Btn.TextSize = 13; Btn.Font = Enum.Font.GothamBold; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.BackgroundTransparency = 0.25; table.insert(ThemeElements.Card, Btn)
	local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 10); Corner.Parent = Btn
	local Scroll = Instance.new("ScrollingFrame"); Scroll.Parent = ContentArea; Scroll.Size = UDim2.new(1, -18, 1, -18); Scroll.Position = UDim2.new(0, 9, 0, 9); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 5; Scroll.Visible = false; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.CanvasSize = UDim2.new(0,0,0,0)
	local Lay = Instance.new("UIListLayout"); Lay.Parent = Scroll; Scroll.ScrollingDirection = Enum.ScrollingDirection.Y; Lay.Padding = UDim.new(0, 14)
	TabFrames[name] = Scroll; TabButtons[name] = Btn
	
	Btn.MouseButton1Click:Connect(function()
		for n, f in pairs(TabFrames) do f.Visible = (n == name) end
		for _, b in pairs(TabButtons) do b.BackgroundTransparency = 0.25; b.TextColor3 = Color3.fromRGB(240,240,240); for i,v in ipairs(ThemeElements.Acc1) do if v==b then table.remove(ThemeElements.Acc1, i) end end end
		Btn.BackgroundTransparency = 0; table.insert(ThemeElements.Acc1, Btn); ApplyTheme(F.themeIndex); Btn.TextColor3 = Color3.fromRGB(255,255,255)
	end)
	return Scroll
end

local function AddGroup(parent, title)
	local GroupCard = Instance.new("Frame"); GroupCard.Parent = parent; GroupCard.Size = UDim2.new(1, 0, 0, 0); GroupCard.AutomaticSize = Enum.AutomaticSize.Y; GroupCard.BackgroundTransparency = 0.15; table.insert(ThemeElements.Card, GroupCard)
	local GC = Instance.new("UICorner"); GC.CornerRadius = UDim.new(0, 12); GC.Parent = GroupCard
	local GS = Instance.new("UIStroke"); GS.Thickness = 1.2; GS.Transparency = 0.6; GS.Parent = GroupCard; table.insert(ThemeElements.Acc1, GS)
	local GLayout = Instance.new("UIListLayout"); GLayout.Parent = GroupCard; GLayout.Padding = UDim.new(0, 10); GLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local GPadding = Instance.new("UIPadding"); GPadding.Parent = GroupCard; GPadding.PaddingTop = UDim.new(0, 12); GPadding.PaddingBottom = UDim.new(0, 12); GPadding.PaddingLeft = UDim.new(0, 12); GPadding.PaddingRight = UDim.new(0, 12)
	
	if title and title ~= "" then
		local HeaderLbl = Instance.new("TextLabel"); HeaderLbl.Parent = GroupCard; HeaderLbl.Size = UDim2.new(1, 0, 0, 28); HeaderLbl.Text = title; HeaderLbl.TextSize = 13; HeaderLbl.Font = Enum.Font.GothamBlack; HeaderLbl.TextXAlignment = Enum.TextXAlignment.Left; HeaderLbl.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, HeaderLbl)
	end
	return GroupCard
end

local function AddToggle(parent, text, flag, callback)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 42); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.68, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Sw = Instance.new("TextButton"); Sw.Parent = Frm; Sw.Position = UDim2.new(1, -50, 0.5, -12); Sw.Size = UDim2.new(0, 42, 0, 24); Sw.Text = ""; local SwC = Instance.new("UICorner"); SwC.CornerRadius = UDim.new(1, 0); SwC.Parent = Sw
	local Knob = Instance.new("Frame"); Knob.Parent = Sw; Knob.Size = UDim2.new(0, 20, 0, 20); Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1, 0); KC.Parent = Knob
	
	local function updateVisuals()
		Sw.BackgroundColor3 = F[flag] and THEMES[F.themeIndex].Acc1 or Color3.fromRGB(50,50,60)
		TweenService:Create(Knob, TweenInfo.new(0.2), {Position = F[flag] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}):Play()
		if F[flag] then table.insert(ThemeElements.Acc1, Sw) else for i,v in ipairs(ThemeElements.Acc1) do if v==Sw then table.remove(ThemeElements.Acc1,i) end end end
		ApplyTheme(F.themeIndex)
	end
	table.insert(ConfigUpdaters, updateVisuals)

	Sw.MouseButton1Click:Connect(function() F[flag] = not F[flag]; updateVisuals(); if callback then pcall(callback, F[flag]) end end)
	updateVisuals()
end

local function AddInput(parent, text, flag, isNum)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 42); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.48, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Box = Instance.new("TextBox"); Box.Parent = Frm; Box.Position = UDim2.new(0.5, 0, 0.1, 0); Box.Size = UDim2.new(0.5, 0, 0.8, 0); table.insert(ThemeElements.TextAcc, Box); Box.TextSize = 13; Box.Font = Enum.Font.GothamBold; Box.BackgroundTransparency = 0.2; table.insert(ThemeElements.Header, Box); local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); BC.Parent = Box
	
	local function updateVisuals() Box.Text = tostring(F[flag] or "") end
	table.insert(ConfigUpdaters, updateVisuals)

	Box.FocusLost:Connect(function() F[flag] = isNum and (tonumber(Box.Text) or 0) or Box.Text; updateVisuals() end)
	updateVisuals()
end

local function AddDropdown(parent, title, options, flag, isMulti)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 44); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.4, 0, 1, 0); L.Text = title; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Btn = Instance.new("TextButton"); Btn.Parent = Frm; Btn.Position = UDim2.new(0.42, 0, 0.1, 0); Btn.Size = UDim2.new(0.58, 0, 0.8, 0); table.insert(ThemeElements.TextAcc, Btn); Btn.TextSize = 12; Btn.Font = Enum.Font.GothamBold; Btn.BackgroundTransparency = 0.2; table.insert(ThemeElements.Header, Btn); local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); BC.Parent = Btn
	
	local DropList = Instance.new("ScrollingFrame"); DropList.Parent = MainFrame; DropList.Size = UDim2.new(0, 260, 0, 180); table.insert(ThemeElements.Bg, DropList); DropList.BorderSizePixel = 1; DropList.Visible = false; DropList.ZIndex = 150; DropList.ScrollBarThickness = 5; DropList.AutomaticCanvasSize = Enum.AutomaticSize.Y; DropList.CanvasSize = UDim2.new(0,0,0,0)
	local DLC = Instance.new("UICorner"); DLC.CornerRadius = UDim.new(0, 10); DLC.Parent = DropList; local DLL = Instance.new("UIListLayout"); DLL.Parent = DropList
	
	local function UpdatePos()
		if DropList.Visible then DropList.Position = UDim2.new(0, Btn.AbsolutePosition.X - MainFrame.AbsolutePosition.X, 0, (Btn.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y) + Btn.AbsoluteSize.Y + 3) end
	end
	Btn:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos)

	local updateCheckList = {}
	local function updateMainBtn() 
		if isMulti then
			local count = #(F[flag] or {})
			Btn.Text = count > 0 and (count .. " Terpilih") or "Pilih Multi..."
		else
			Btn.Text = tostring(F[flag] or "Select")
		end
	end
	table.insert(ConfigUpdaters, updateMainBtn)

	local function Render(opts)
		for _, v in pairs(DropList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
		for _, opt in ipairs(opts) do
			local OptBtn = Instance.new("TextButton"); OptBtn.Parent = DropList; OptBtn.Size = UDim2.new(1, 0, 0, 35); OptBtn.Text = "   " .. tostring(opt.label); OptBtn.TextColor3 = Color3.fromRGB(255,255,255); OptBtn.TextSize = 12; OptBtn.Font = Enum.Font.GothamMedium; OptBtn.TextXAlignment = Enum.TextXAlignment.Left; OptBtn.BackgroundTransparency = 1; OptBtn.ZIndex = 151
			local check = Instance.new("Frame"); check.Parent = OptBtn; check.Size = UDim2.new(0, 16, 0, 16); check.Position = UDim2.new(1, -26, 0.5, -8); local cc = Instance.new("UICorner"); cc.Parent = check; check.ZIndex = 151
			
			local function updateVisuals()
				local sel = false
				if isMulti then for _,v in ipairs(F[flag] or {}) do if v==opt.val then sel=true break end end else sel=(F[flag]==opt.val) end
				if sel then table.insert(ThemeElements.Acc1, check) else for i,v in ipairs(ThemeElements.Acc1) do if v==check then table.remove(ThemeElements.Acc1,i) end end; check.BackgroundColor3 = Color3.fromRGB(50,50,60) end
				ApplyTheme(F.themeIndex)
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
	Render(options); updateMainBtn()
	Btn.MouseButton1Click:Connect(function() DropList.Visible = not DropList.Visible; UpdatePos() end)
end

local function GetOpts(mode)
	local t = {}; 
	if mode == "grade" and G.GradesMod then for n, g in pairs(G.GradesMod) do if type(g)=="table" and g.order then table.insert(t, {label=n, val=n, order=g.order}) end end; table.sort(t, function(a,b) return a.order<b.order end)
	elseif mode == "trait" and G.TraitsMod then for n, g in pairs(G.TraitsMod) do if type(g)=="table" and g.order then table.insert(t, {label=n, val=n, order=g.order}) end end; table.sort(t, function(a,b) return a.order<b.order end)
	elseif mode == "pot" and G.BoostConfig then for n, e in pairs(G.BoostConfig.entries or {}) do table.insert(t, {label=n.." [T"..tostring(e.tier).."]", val=n}) end; table.sort(t, function(a,b) return a.label<b.label end)
	elseif mode == "unit" then
		local placed = {}; pcall(function() for _, d in pairs(slots()) do if d.unitId then placed[d.unitId]=true end end end)
		for k, e in pairs(inventory()) do if isUnitEntry(e) then table.insert(t, {label=e.name .. (placed[k] and " ★" or ""), val=k}) end end
	elseif mode == "unit_name" then
		local addedNames = {}
		for _, e in pairs(inventory()) do
			if isUnitEntry(e) and e.name and not addedNames[e.name] then
				addedNames[e.name] = true
				table.insert(t, {label = e.name, val = e.name})
			end
		end
		table.sort(t, function(a,b) return a.label < b.label end)
	elseif mode == "towers" then
		table.insert(t, {label="Auto (best)", val="Auto (best)"})
		pcall(function()
			local all = G.TowersConfig and G.TowersConfig.GetAll and G.TowersConfig.GetAll()
			if type(all) == "table" then
				for name in pairs(all) do table.insert(t, {label=name, val=name}) end
			end
		end)
	end
	return t
end

-- ===================================================================== --
-- 5. 9 TABS ASSEMBLY (OPTIMIZED LAYOUT)
-- ===================================================================== --
local T_Dash = CreateTab("Dashboard", "📊")
local T_Farm = CreateTab("Farming", "⛏️")
local T_Hlw = CreateTab("Halloween", "🎃")
local T_Inv = CreateTab("Inventory", "🎒")
local T_Pot = CreateTab("Potions", "🧪")
local T_Grd = CreateTab("Auto Grade", "⭐")
local T_Trt = CreateTab("Auto Trait", "🧬")
local T_Twr = CreateTab("Tower", "🏰")
local T_Set = CreateTab("Settings", "⚙️")

TabFrames["Dashboard"].Visible = true; Sidebar:GetChildren()[2].BackgroundTransparency = 0; table.insert(ThemeElements.Acc1, Sidebar:GetChildren()[2])

-- 1. DASHBOARD
local G_Profile = AddGroup(T_Dash, "PROFIL & STATISTIK PENGGUNA")
local ProfContainer = Instance.new("Frame"); ProfContainer.Parent = G_Profile; ProfContainer.Size = UDim2.new(1, 0, 0, 85); ProfContainer.BackgroundTransparency = 1
local PImg = Instance.new("ImageLabel"); PImg.Parent = ProfContainer; PImg.AnchorPoint = Vector2.new(0.5, 0.5); PImg.Position = UDim2.new(0.15, 0, 0.5, 0); PImg.Size = UDim2.new(0, 68, 0, 68); pcall(function() PImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end); local PImgC = Instance.new("UICorner"); PImgC.CornerRadius = UDim.new(1,0); PImgC.Parent = PImg; local PStr = Instance.new("UIStroke"); PStr.Thickness = 2.5; PStr.Parent = PImg; table.insert(ThemeElements.Acc1, PStr)

local PLbl = Instance.new("TextLabel"); PLbl.Parent = ProfContainer; PLbl.Position = UDim2.new(0.3, 0, 0, 0); PLbl.Size = UDim2.new(0.7, 0, 1, 0); PLbl.BackgroundTransparency = 1; PLbl.TextColor3 = Color3.fromRGB(255,255,255); PLbl.TextSize = 13; PLbl.Font = Enum.Font.GothamMedium; PLbl.TextXAlignment = Enum.TextXAlignment.Left; PLbl.TextYAlignment = Enum.TextYAlignment.Center

local G_Spy = AddGroup(T_Dash, "SPY INVENTORY & BUFFS")
local SLbl = Instance.new("TextLabel"); SLbl.Parent = G_Spy; SLbl.Size = UDim2.new(1, 0, 0, 95); SLbl.BackgroundTransparency = 1; SLbl.TextColor3 = Color3.fromRGB(255,255,255); SLbl.TextSize = 13; SLbl.Font = Enum.Font.GothamMedium; SLbl.TextXAlignment = Enum.TextXAlignment.Left; SLbl.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
	while task.wait(1) do pcall(function()
		local m = money(); local rb = rebirthAmt(); local rls = G.DC.Rolls() or 0
		PLbl.Text = string.format("👤 %s\n💰 Uang: %s\n🔄 Rebirth: %s | 🎲 Rolls: %s", LocalPlayer.Name, tostring(m), tostring(rb), tostring(rls))
		local mut, trt, grd, tot = 0,0,0,0; for _, e in pairs(inventory()) do if isUnitEntry(e) then tot += 1; if e.attributes then if e.attributes.mutation then mut+=1 end; if e.attributes.trait then trt+=1 end; if e.attributes.grade then grd+=1 end end end end
		local buffs = ""; if G.BuffController and G.BuffController.ActiveBuffs then for k,v in pairs(G.BuffController.ActiveBuffs) do buffs = buffs..k..", " end end; if buffs=="" then buffs="Tidak ada" end; STATE.activeBuffs = buffs
		SLbl.Text = string.format("💎 Gems: %d | 🧬 Trait Reroll: %d\n⚔️ Total Unit: %d/100\n⚡ Quirk: %d | 🧬 Trait: %d | ⭐ Grade: %d\n🧪 Active Potion: %s", currencyAmount("Gems"), currencyAmount("Trait Reroll"), tot, mut, trt, grd, STATE.activeBuffs)
	end) end
end)

-- 2. FARMING
local G_Farm1 = AddGroup(T_Farm, "PLOT, ROLL & REBIRTH")
AddToggle(G_Farm1, "Auto Collect Plot", "collect")
AddToggle(G_Farm1, "Auto Roll Dadu (Otomatis)", "autoRoll")
AddToggle(G_Farm1, "Auto Smart Best Place Base (Inventory)", "autoBestPlaceBase")
AddToggle(G_Farm1, "Auto Rebirth (Anti-Spam)", "rebirth")
AddToggle(G_Farm1, "Auto Buy & Equip Dice", "buyDice")

local G_Farm2 = AddGroup(T_Farm, "LEVELING & UPGRADES")
AddToggle(G_Farm2, "Auto Level Up Unit", "levelup")
AddInput(G_Farm2, "Max Level Batas:", "maxLevel", true)
AddToggle(G_Farm2, "Auto Upgrade Skill Tree", "upgrades")

-- 3. HALLOWEEN
local G_HlwTeleport = AddGroup(T_Hlw, "HALLOWEEN EVENT TELEPORT & INTRO")
AddToggle(G_HlwTeleport, "Auto Teleport Ke Halloween World", "halloweenTeleport")

local G_HlwRoll = AddGroup(T_Hlw, "PUMPKIN DICE & UNIT MANAGEMENT")
AddDropdown(G_HlwRoll, "Pilih Kuantitas Pumpkin Roll:", {{label="Roll 1x", val=1}, {label="Roll 5x", val=5}}, "pumpkinRollQty", false)
AddToggle(G_HlwRoll, "Auto Pumpkin Dice Roll", "pumpkinAutoRoll")
AddToggle(G_HlwRoll, "Auto Sell Pumpkin Units (Service Server)", "pumpkinAutoSell")
AddDropdown(G_HlwRoll, "Pilih Nama Unit Spesifik Auto Sell:", GetOpts("unit_name"), "specificSellUnits", true)

local G_HlwQuests = AddGroup(T_Hlw, "HALLOWEEN REWARDS & QUESTS")
AddToggle(G_HlwQuests, "Auto Claim Halloween Quests", "halloweenQuest")
AddToggle(G_HlwQuests, "Auto Claim Halloween Path Rewards", "halloweenPath")
AddToggle(G_HlwQuests, "Auto Buy Halloween Special Offers", "halloweenOffer")
AddToggle(G_HlwQuests, "Auto Trick or Treat (Knock Doors)", "trickOrTreat")

local G_HauntedTwr = AddGroup(T_Hlw, "HAUNTED TOWER FARMING (HALLOWEEN)")
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

local G_HauntedMon = AddGroup(T_Hlw, "LIVE HAUNTED TOWER MONITORING & ITEMS")
local HauntedLbl = Instance.new("TextLabel"); HauntedLbl.Parent = G_HauntedMon; HauntedLbl.Size = UDim2.new(1,0,0,80); HauntedLbl.BackgroundTransparency = 1; HauntedLbl.TextColor3 = Color3.fromRGB(255,255,255); HauntedLbl.TextSize = 13; HauntedLbl.Font = Enum.Font.GothamMedium; HauntedLbl.TextXAlignment = Enum.TextXAlignment.Left; HauntedLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function() while task.wait(0.5) do pcall(function() HauntedLbl.Text = string.format("🎃 Status: %s\n🏢 Lantai: %d | 🍬 Item/Drops: %d", STATE.hauntedLive, STATE.hauntedFloor, STATE.hauntedDrops) end) end end)

-- 4. INVENTORY
local G_Inv = AddGroup(T_Inv, "MANAGEMENT & AUTO SELL")
AddToggle(G_Inv, "Auto Sell Unit (Tanpa Rarity Filter)", "sellAuto")
AddInput(G_Inv, "Simpan Unit Terbaik (Keep Best):", "keepBest", true)
AddToggle(G_Inv, "Auto Fusion Unit", "autoFuse")

-- 5. POTIONS
local G_Pot = AddGroup(T_Pot, "SMART POTION MANAGER")
AddToggle(G_Pot, "Auto Gunakan Potion", "potionAuto")
AddDropdown(G_Pot, "Pilih Potion Spesifik:", GetOpts("pot"), "potionSpecific", true)

-- 6. AUTO GRADE
local G_Grd = AddGroup(T_Grd, "GRADE REROLL CONFIG")
AddToggle(G_Grd, "Aktifkan Auto Grade", "gradeAuto")
AddToggle(G_Grd, "Hanya Unit di Base (Placed)", "gradePlacedOnly")
AddDropdown(G_Grd, "Target Grade (Lewati Protected):", GetOpts("grade"), "gradeTargets", true)
AddDropdown(G_Grd, "Pilih Unit Spesifik:", GetOpts("unit"), "gradeUnits", true)
AddInput(G_Grd, "Sisakan Gems:", "gemReserve", true)

-- 7. AUTO TRAIT
local G_Trt = AddGroup(T_Trt, "TRAIT REROLL CONFIG")
AddToggle(G_Trt, "Aktifkan Auto Trait", "traitAuto")
AddToggle(G_Trt, "Hanya Unit di Base (Placed)", "traitPlacedOnly")
AddDropdown(G_Trt, "Target Trait (Lewati Protected):", GetOpts("trait"), "traitTargets", true)
AddDropdown(G_Trt, "Pilih Unit Spesifik:", GetOpts("unit"), "traitUnits", true)
AddInput(G_Trt, "Sisakan Trait Item:", "rerollReserve", true)

-- 8. TOWER (UTAMA - STABIL & FIXED)
local G_Twr = AddGroup(T_Twr, "TOWER UTAMA FARMING SETUP")
AddToggle(G_Twr, "Auto Tower Farming", "tower")
AddToggle(G_Twr, "Mode MIX / Random Tower", "towerMix")
AddDropdown(G_Twr, "Pilih Tower Spesifik:", GetOpts("towers"), "towerName", false)
AddToggle(G_Twr, "Auto Equip Best Team Tower", "towerEquipBest")
AddToggle(G_Twr, "Keluar di Lantai Tertentu", "towerExitOn")
AddInput(G_Twr, "Lantai Exit:", "towerExitFloor", true)

local G_TwrMon = AddGroup(T_Twr, "LIVE TOWER MONITORING & TRAIT")
local TwrLbl = Instance.new("TextLabel"); TwrLbl.Parent = G_TwrMon; TwrLbl.Size = UDim2.new(1,0,0,80); TwrLbl.BackgroundTransparency = 1; TwrLbl.TextColor3 = Color3.fromRGB(255,255,255); TwrLbl.TextSize = 13; TwrLbl.Font = Enum.Font.GothamMedium; TwrLbl.TextXAlignment = Enum.TextXAlignment.Left; TwrLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function() while task.wait(0.5) do pcall(function() TwrLbl.Text = string.format("🎮 Status: %s\n🏢 Lantai: %d | 💎 Gems Didapat: %d\n🧬 Trait Didapat: %s", STATE.towerLive, STATE.towerFloor, STATE.towerDrops, tostring(STATE.towerTraitsGot)) end) end end)

-- 9. SETTINGS & CONFIG LIST MANAGER
local G_Set1 = AddGroup(T_Set, "TEMA & WARNA (NEON GLOW)")
local BtnTheme = Instance.new("TextButton"); BtnTheme.Parent = G_Set1; BtnTheme.Size = UDim2.new(1, 0, 0, 40); BtnTheme.Text = "🎲 ACAK TEMA WARNA"; BtnTheme.Font = Enum.Font.GothamBlack; BtnTheme.TextSize = 13; table.insert(ThemeElements.Card, BtnTheme); table.insert(ThemeElements.TextAcc, BtnTheme); local BTC = Instance.new("UICorner"); BTC.CornerRadius = UDim.new(0,8); BTC.Parent = BtnTheme
BtnTheme.MouseButton1Click:Connect(function() F.themeIndex = math.random(1, #THEMES); ApplyTheme(F.themeIndex) end)

local G_SetConfig = AddGroup(T_Set, "CONFIG & FILE MANAGER (PROFESSIONAL)")
AddToggle(G_SetConfig, "Auto Load Config Saat Nyala", "autoLoadEnabled")
AddInput(G_SetConfig, "Nama File Config:", "cfgName", false)

local BtnSave = Instance.new("TextButton"); BtnSave.Parent = G_SetConfig; BtnSave.Size = UDim2.new(1, 0, 0, 38); BtnSave.Text = "💾 SAVE CONFIG SEKARANG"; BtnSave.Font = Enum.Font.GothamBold; BtnSave.TextSize = 13; table.insert(ThemeElements.Header, BtnSave); table.insert(ThemeElements.TextAcc, BtnSave); local BTS = Instance.new("UICorner"); BTS.CornerRadius = UDim.new(0,8); BTS.Parent = BtnSave
BtnSave.MouseButton1Click:Connect(function() pcall(function() saveConfig(F.cfgName) end) end)

local BtnLoad = Instance.new("TextButton"); BtnLoad.Parent = G_SetConfig; BtnLoad.Size = UDim2.new(1, 0, 0, 38); BtnLoad.Text = "📂 LOAD CONFIG PILIHAN"; BtnLoad.Font = Enum.Font.GothamBold; BtnLoad.TextSize = 13; table.insert(ThemeElements.Header, BtnLoad); table.insert(ThemeElements.TextAcc, BtnLoad); local BTL = Instance.new("UICorner"); BTL.CornerRadius = UDim.new(0,8); BTL.Parent = BtnLoad
BtnLoad.MouseButton1Click:Connect(function() pcall(function() loadConfig(F.cfgName) end) end)

local BtnDelete = Instance.new("TextButton"); BtnDelete.Parent = G_SetConfig; BtnDelete.Size = UDim2.new(1, 0, 0, 38); BtnDelete.Text = "🗑️ DELETE CONFIG PILIHAN"; BtnDelete.Font = Enum.Font.GothamBold; BtnDelete.TextSize = 13; BtnDelete.TextColor3 = Color3.fromRGB(255, 60, 60); table.insert(ThemeElements.Header, BtnDelete) 
local BTD = Instance.new("UICorner"); BTD.CornerRadius = UDim.new(0,8); BTD.Parent = BtnDelete
BtnDelete.MouseButton1Click:Connect(function()
	pcall(function()
		local path = getCfgPath(F.cfgName)
		if delfile and isfile and isfile(path) then delfile(path) end
	end)
end)

local ListTitle = Instance.new("TextLabel"); ListTitle.Parent = G_SetConfig; ListTitle.Size = UDim2.new(1, 0, 0, 24); ListTitle.Text = "📁 PILIH CONFIG TERSEDIA:"; ListTitle.TextSize = 12; ListTitle.Font = Enum.Font.GothamBold; ListTitle.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, ListTitle)

local ConfigScroll = Instance.new("ScrollingFrame"); ConfigScroll.Parent = G_SetConfig; ConfigScroll.Size = UDim2.new(1, 0, 0, 110); ConfigScroll.BackgroundTransparency = 0.3; table.insert(ThemeElements.Header, ConfigScroll); ConfigScroll.ScrollBarThickness = 5; ConfigScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; ConfigScroll.CanvasSize = UDim2.new(0,0,0,0)
local CSC = Instance.new("UICorner"); CSC.CornerRadius = UDim.new(0, 8); CSC.Parent = ConfigScroll
local ConfigLayout = Instance.new("UIListLayout"); ConfigLayout.Parent = ConfigScroll; ConfigLayout.Padding = UDim.new(0, 5)

local function RefreshConfigList()
	for _, v in pairs(ConfigScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
	if listfiles then
		pcall(function()
			for _, file in ipairs(listfiles(CFG_FOLDER)) do
				local fileName = file:match("([^/]+)$"):gsub("%.json$", "")
				local FileBtn = Instance.new("TextButton"); FileBtn.Parent = ConfigScroll; FileBtn.Size = UDim2.new(1, 0, 0, 32); FileBtn.Text = "📄 " .. fileName; FileBtn.TextSize = 12; FileBtn.Font = Enum.Font.GothamMedium; FileBtn.TextColor3 = Color3.fromRGB(255,255,255); FileBtn.BackgroundTransparency = 0.2; table.insert(ThemeElements.Card, FileBtn)
				local FBC = Instance.new("UICorner"); FBC.CornerRadius = UDim.new(0, 6); FBC.Parent = FileBtn
				FileBtn.MouseButton1Click:Connect(function()
					pcall(function()
						F.cfgName = fileName
						loadConfig(fileName)
					end)
				end)
			end
		end)
	end
end
RefreshConfigList()

local BtnRefresh = Instance.new("TextButton"); BtnRefresh.Parent = G_SetConfig; BtnRefresh.Size = UDim2.new(1, 0, 0, 34); BtnRefresh.Text = "🔄 REFRESH LIST CONFIG"; BtnRefresh.Font = Enum.Font.GothamBold; BtnRefresh.TextSize = 12; table.insert(ThemeElements.Card, BtnRefresh); table.insert(ThemeElements.TextAcc, BtnRefresh); local BTR = Instance.new("UICorner"); BTR.CornerRadius = UDim.new(0,8); BTR.Parent = BtnRefresh
BtnRefresh.MouseButton1Click:Connect(RefreshConfigList)

local G_Web = AddGroup(T_Set, "DISCORD WEBHOOK")
AddToggle(G_Web, "Aktifkan Webhook Discord", "webhookEnabled")
AddInput(G_Web, "Webhook URL (Tempel di sini):", "webhookUrl", false)
local BtnTestWeb = Instance.new("TextButton"); BtnTestWeb.Parent = G_Web; BtnTestWeb.Size = UDim2.new(1, 0, 0, 36); BtnTestWeb.Text = "🔔 TEST KIRIM WEBHOOK"; BtnTestWeb.Font = Enum.Font.GothamBold; BtnTestWeb.TextSize = 12; table.insert(ThemeElements.Card, BtnTestWeb); table.insert(ThemeElements.TextAcc, BtnTestWeb); local BTWC = Instance.new("UICorner"); BTWC.CornerRadius = UDim.new(0,8); BTWC.Parent = BtnTestWeb
BtnTestWeb.MouseButton1Click:Connect(function() SendWebhook("✅ Webhook Connected!", "MofenkHub V97.0 berhasil tersambung ke Discord kamu.", 3447003) end)

local G_Set2 = AddGroup(T_Set, "OPTIMALISASI & TOOLS")
AddToggle(G_Set2, "Anti-AFK (Cegah Disconnect Profesional)", "afk")
AddToggle(G_Set2, "FPS Boost (Hapus Partikel Map)", "fpsOn", function(v) if v then pcall(function() game:GetService("Lighting").GlobalShadows = false; for _,e in ipairs(workspace:GetDescendants()) do if e:IsA("BasePart") then e.Material = Enum.Material.SmoothPlastic end end end) end end)
AddToggle(G_Set2, "Auto Claim Quests & Daily", "claimQuests")
AddToggle(G_Set2, "Auto Redeem Codes", "codesAuto")

local BtnHop = Instance.new("TextButton"); BtnHop.Parent = G_Set2; BtnHop.Size = UDim2.new(1, 0, 0, 40); BtnHop.Text = "🌐 SERVER HOP (PINDAH SERVER)"; BtnHop.Font = Enum.Font.GothamBlack; BtnHop.TextSize = 13; table.insert(ThemeElements.Card, BtnHop); table.insert(ThemeElements.TextAcc, BtnHop); local BTH = Instance.new("UICorner"); BTH.CornerRadius = UDim.new(0,8); BTH.Parent = BTH

BtnHop.MouseButton1Click:Connect(function()
	pcall(function()
		local cursor = ""; local servers = {}
		repeat
			local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
			local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
			if success and result and result.data then
				for _, s in ipairs(result.data) do
					if type(s) == "table" and s.playing and s.maxPlayers and s.playing < s.maxPlayers and s.id ~= game.JobId then
						table.insert(servers, s.id)
					end
				end
				cursor = result.nextPageCursor or ""
			else break end
		until #servers > 10 or cursor == ""

		if #servers > 0 then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
		else
			TeleportService:Teleport(game.PlaceId, LocalPlayer)
		end
	end)
end)

ApplyTheme(F.themeIndex)

-- ===================================================================== --
-- 6. FULL BACKEND THREADS (ROBUST ERROR HANDLING & STABLE TOWER)
-- ===================================================================== --

local vu = game:GetService("VirtualUser")

pcall(function()
	local PromptOverlay = CoreGui:FindFirstChild("PromptOverlay", true) or LocalPlayer.PlayerGui:FindFirstChild("PromptOverlay", true)
	if PromptOverlay then
		PromptOverlay.ChildAdded:Connect(function(child)
			if F.afk and (child.Name == "ErrorPrompt" or child.Name == "DisconnectPrompt") then
				local qot = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
				if qot then
					qot([[
						task.wait(3)
						loadstring(game:HttpGet("https://raw.githubusercontent.com/Mofenk/mofenkhub/refs/heads/main/animedice.lua"))()
					]])
				end
				task.wait(2)
				pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
			end
		end)
	end
end)

LocalPlayer.Idled:Connect(function()
	if F.afk then
		pcall(function()
			vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
			task.wait(1)
			vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
		end)
	end
end)

task.spawn(function()
	while task.wait(25) do
		if F.afk then
			pcall(function()
				vu:CaptureController()
				vu:ClickButton2(Vector2.new(0,0))
			end)
		end
	end
end)

-- Halloween Teleport & Event Automation Thread
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.halloweenTeleport and R.HWTeleport then
			pcall(function()
				R.HWTeleport:InvokeServer()
				if R.HWSeenIntro then R.HWSeenIntro:FireServer() end
			end)
		end
		if F.halloweenQuest and R.HWQuestClaim then
			pcall(function() R.HWQuestClaim:FireServer() end)
		end
		if F.halloweenPath and R.HWClaimPath then
			pcall(function() R.HWClaimPath:FireServer() end)
		end
		if F.halloweenOffer and R.HWBuyOffer then
			pcall(function() R.HWBuyOffer:FireServer() end)
		end
		if F.trickOrTreat and R.TrickOrTreat then
			pcall(function() R.TrickOrTreat:FireServer() end)
		end
		task.wait(5)
	end
end)

-- Pumpkin Dice & Specific Unit Name Sell Thread
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.pumpkinAutoRoll and R.PumpkinRoll then
			pcall(function()
				local qty = tonumber(F.pumpkinRollQty) or 1
				for i = 1, qty do
					if not F.pumpkinAutoRoll then break end
					if R.PumpkinRoll:IsA("RemoteFunction") then
						R.PumpkinRoll:InvokeServer()
					elseif R.PumpkinRoll:IsA("RemoteEvent") then
						R.PumpkinRoll:FireServer()
					end
					task.wait(0.3)
				end
			end)
		end
		if R.PumpkinAutoSell then
			pcall(function() R.PumpkinAutoSell:FireServer(F.pumpkinAutoSell) end)
		end

		if F.specificSellUnits and #F.specificSellUnits > 0 and R.SellInventory then
			pcall(function()
				local d = data()
				local placed = {}
				for _, slot in pairs(d.Slots or {}) do if slot.unitId then placed[slot.unitId] = true end end
				for _, id in pairs(d.TowerTeam or {}) do placed[id] = true end

				local sellList = {}
				for id, u in pairs(d.Inventory or {}) do
					if isUnitEntry(u) and u.name then
						local isTarget = false
						for _, targetName in ipairs(F.specificSellUnits) do
							if u.name == targetName then isTarget = true break end
						end
						
						local isProt = false
						if u.attributes and u.attributes.locked then isProt = true end

						if isTarget and not placed[id] and not isProt then
							table.insert(sellList, id)
							if #sellList >= 150 then break end
						end
					end
				end

				if #sellList > 0 then
					R.SellInventory:InvokeServer(sellList)
				end
			end)
		end

		task.wait(3)
	end
end)

local function unlockedSlots() local arr={}; local rb = rebirthAmt(); pcall(function() for i=1, (G.PlotConfig.GetMaxSlots(rb) or 15) do if rb >= (G.PlotConfig.GetSlotRebirthRequirement(i) or 0) then table.insert(arr, i) end end end); return arr end

-- Auto Roll Thread (Dilengkapi Jitter untuk Anti-Kaku)
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.autoRoll then
			pcall(function()
				if R.RollDice then
					local ok = pcall(function() return R.RollDice:InvokeServer() end)
					if ok then STATE.rolled = (STATE.rolled or 0) + 1 end
				end
			end)
			task.wait(2.0 + math.random(0, 3) * 0.1)
		else
			task.wait(1)
		end
	end
end)

-- Auto Smart Best Place Base (Inventory -> Plot)
local function heldUnit()
	if not (G.UnitController and G.UnitController.EquippedUnit) then
		local ok, id = pcall(function() return require(Framework.Features.Inventory.Kinds.Unit.UnitController).EquippedUnit() end)
		if ok and id then return id end
	end
	return nil
end

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.autoBestPlaceBase and R.EquipUnit and R.InteractSlot then
			pcall(function()
				local d = data()
				local n = #unlockedSlots()
				local ranked = {}
				for id, u in pairs(d.Inventory or {}) do
					if isUnitEntry(u) then
						ranked[#ranked + 1] = { id = id, v = baseIncome(u) }
					end
				end
				table.sort(ranked, function(a, b) return a.v > b.v end)

				local want, placed = {}, {}
				for i = 1, math.min(n, #ranked) do want[ranked[i].id] = ranked[i].v end
				for _, slot in pairs(d.Slots or {}) do if slot.unitId then placed[slot.unitId] = true end end

				local bench = {}
				for i = 1, math.min(n, #ranked) do
					if not placed[ranked[i].id] then bench[#bench + 1] = ranked[i] end
				end

				if #bench > 0 then
					local slotsArr = {}
					for i = 1, n do
						local s = d.Slots and d.Slots[tostring(i)]
						local u = s and s.unitId and d.Inventory[s.unitId]
						slotsArr[#slotsArr + 1] = { i = i, v = u and baseIncome(u) or 0, id = s and s.unitId }
					end
					table.sort(slotsArr, function(a, b) return a.v < b.v end)

					for k, cand in ipairs(bench) do
						local slot = slotsArr[k]
						if slot and (slot.id == nil or not want[slot.id]) and cand.v > slot.v * 1.1 then
							local ok, equipped = pcall(function() return R.EquipUnit:InvokeServer(cand.id) end)
							if ok and equipped == true then
								task.wait(0.5)
								R.InteractSlot:FireServer(slot.i)
								task.wait(0.5)
							elseif R.UnequipUnit and heldUnit() then
								pcall(function() R.UnequipUnit:InvokeServer() end)
							end
						end
					end
				end
			end)
		end
		task.wait(10)
	end
end)

-- Auto Buy & Equip Best Dice
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.buyDice and G.DiceModule and R.BuyDice and R.EquipDice then
			pcall(function()
				local d = data()
				local allDice = {}
				local ok, all = pcall(G.DiceModule.GetAll)
				if ok and type(all) == "table" then
					for key, def in pairs(all) do
						table.insert(allDice, { key = key, luck = tonumber(def.luck) or 0, price = tonumber(def.price) })
					end
					table.sort(allDice, function(a, b) return a.luck < b.luck end)
				end

				local owned = d.OwnedDice or {}
				local bestOwnedName, bestOwnedLuck = "-", 0
				for _, die in ipairs(allDice) do
					if owned[die.key] and die.luck > bestOwnedLuck then
						bestOwnedLuck = die.luck
						bestOwnedName = die.key
					end
				end

				local spendable = money()
				for _, die in ipairs(allDice) do
					if die.price and not owned[die.key] and spendable >= die.price then
						if die.luck > bestOwnedLuck then
							R.BuyDice:FireServer(die.key)
							task.wait(0.3)
							owned[die.key] = true
						end
					end
				end

				if bestOwnedName ~= "-" and d.Dice ~= bestOwnedName then
					R.EquipDice:FireServer(bestOwnedName)
				end
			end)
		end
		task.wait(5)
	end
end)

-- Universal Auto Sell Thread
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.sellAuto and R.SellInventory then
			pcall(function()
				local d = data()
				local cap = 100
				pcall(function()
					local buff = tonumber(select(2, pcall(G.BuffController.GetBuff, "Unit Storage")))
					if buff and buff > 0 then cap = buff end
				end)

				local placed = {}
				for _, slot in pairs(d.Slots or {}) do if slot.unitId then placed[slot.unitId] = true end end
				for _, id in pairs(d.TowerTeam or {}) do placed[id] = true end

				local units, owned = {}, 0
				for id, u in pairs(d.Inventory or {}) do
					local e = G.UnitConfig and G.UnitConfig.entries[u.name] or (G.EntryRegistry and pcall(function() return G.EntryRegistry.getEntryConfig(u.name) end))
					if e then owned = owned + 1 end
					
					local isProt = false
					if u.attributes and u.attributes.locked then isProt = true end
					if type(e) == "table" and e.limited then isProt = true end

					if not placed[id] and not isProt then
						table.insert(units, { id = id })
					end
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
				if #list > 0 then
					pcall(function() R.SellInventory:InvokeServer(list) end)
				end
			end)
		end
		task.wait(4)
	end
end)

task.spawn(function()
	local lastRebirth = 0
	while _G.__ANIMEDICE == generation do
		if F.collect and R.CollectBalance then pcall(function() for _, slot in ipairs(unlockedSlots()) do R.CollectBalance:FireServer(slot) end end) end
		if F.levelup and R.LevelUpSlot then
			pcall(function()
				local s = slots(); local m = money()
				for _, slot in ipairs(unlockedSlots()) do
					local d = s[tostring(slot)]
					if d and d.unitId then
						local e = inventory()[d.unitId]
						if e and e.attributes and (tonumber(e.attributes.level) or 1) < F.maxLevel then
							local price = 0; pcall(function() price = G.UnitUtil.GetLevelPrice(e.name, e.attributes) end)
							if m >= price then R.LevelUpSlot:FireServer(tonumber(slot)); m = m - price; task.wait(0.1) end
						end
					end
				end
			end)
		end
		if F.rebirth and R.Rebirth and (os.clock() - lastRebirth > 5) then
			pcall(function() local nr = G.Rebirths.GetNext(rebirthAmt()); if nr and money() >= (nr.cost or 9e9) then R.Rebirth:FireServer(); lastRebirth = os.clock() end end)
		end
		if F.upgrades and R.BuyUpgrade and G.Upgrades then
			pcall(function()
				local owned = G.DC.Upgrades() or {}; local list = {}
				for n, u in pairs(G.Upgrades) do if type(u)=="table" and u.price and not owned[n] then table.insert(list, {name=n, price=u.price}) end end
				table.sort(list, function(a,b) return a.price < b.price end)
				for _, u in ipairs(list) do if money() >= u.price then R.BuyUpgrade:FireServer(u.name); break end end
			end)
		end
		task.wait(2)
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.potionAuto and R.BoostUse then
			pcall(function()
				local active = G.BuffController and G.BuffController.ActiveBuffs or {}
				for key, e in pairs(inventory()) do
					if e.name and e.amount and e.amount > 0 and G.BoostConfig and G.BoostConfig.entries[e.name] then
						local shouldUse = (#F.potionSpecific == 0)
						for _, sn in ipairs(F.potionSpecific) do if e.name == sn then shouldUse = true break end end
						if shouldUse and not active[e.name] then R.BoostUse:FireServer(key); task.wait(1) end
					end
				end
			end)
		end
		task.wait(5)
	end
end)

-- FIX: Universal Auto Tower (Stabil & Fixed Play & Mix Handling)
local function drainTower()
	if not R.CancelTower then return end
	pcall(function() R.CancelTower:InvokeServer() end)
	for _ = 1, 25 do
		local ok, seq = pcall(function() return R.CompleteFloor:InvokeServer() end)
		if ok and type(seq) == "table" then
			for _, ev in ipairs(seq) do if ev.action == "ended" then return end end
		end
		task.wait(0.3)
	end
end

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.tower and R.PlayTower and R.CompleteFloor then
			-- Bersihkan sisa sesi nyangkut di awal
			drainTower()
			task.wait(0.5)

			if F.towerEquipBest and R.BestTowerTeam then pcall(function() R.BestTowerTeam:FireServer() end) end
			task.wait(0.5)

			local pickTower = F.towerName
			if F.towerMix or pickTower == "Auto (best)" then
				local allTowers = {}
				pcall(function()
					local all = G.TowersConfig and G.TowersConfig.GetAll and G.TowersConfig.GetAll()
					if type(all) == "table" then for n in pairs(all) do table.insert(allTowers, n) end end
				end)
				if #allTowers > 0 then
					pickTower = allTowers[math.random(1, #allTowers)]
				else
					pickTower = "Dragon Tower"
				end
			end

			STATE.towerLive = "Memulai: " .. tostring(pickTower); STATE.towerDrops = 0; STATE.towerTraitsGot = "Mencari..."
			local okStart, started = pcall(function() return R.PlayTower:InvokeServer(pickTower) end)
			if not (okStart and started) then
				drainTower()
				task.wait(3.0)
				pcall(function() R.PlayTower:InvokeServer(pickTower) end)
			end

			local done, fails = false, 0
			while F.tower and not done do
				local okP, seq = pcall(function() return R.CompleteFloor:InvokeServer() end)
				if okP and type(seq) == "table" and #seq > 0 then
					fails = 0
					for _, act in ipairs(seq) do
						if act.action == "floorStarted" then 
							STATE.towerFloor = tonumber(act.floor) or 1
							if STATE.towerFloor > 0 and STATE.towerFloor % 10 == 0 then
								SendWebhook("🏰 Tower Milestone Reached!", "Berhasil mencapai **Lantai " .. STATE.towerFloor .. "** di " .. tostring(pickTower), 16753920)
							end
						elseif act.action == "floorCompleted" then
							if act.rewards and act.rewards.Gems then STATE.towerDrops += act.rewards.Gems end
							if act.rewards and (act.rewards.Trait or act.trait) then
								STATE.towerTraitsGot = tostring(act.rewards.Trait or act.trait)
							end
						elseif act.action == "ended" then done = true break end
					end
					if not done and F.towerExitOn and F.towerExitFloor > 0 and STATE.towerFloor >= F.towerExitFloor then
						done = true; drainTower()
					end
				else fails += 1; if fails > 8 then done = true end; task.wait(1) end
			end
			drainTower()
			task.wait(2)
		else STATE.towerLive = "Standby"; STATE.towerTraitsGot = "Belum Ada"; task.wait(2) end
	end
end)

-- Haunted Tower (Halloween Tower) Thread
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.hauntedTower and R.PlayTower and R.CompleteFloor then
			drainTower()
			task.wait(0.5)

			if F.hauntedEquipBest and R.BestTowerTeam then pcall(function() R.BestTowerTeam:FireServer() end) end
			task.wait(0.5)
			
			local pickHaunted = "Haunted Front Yard"
			if F.hauntedMix then
				pickHaunted = F.hauntedList[math.random(1, #F.hauntedList)] or "Haunted Front Yard"
			else
				pickHaunted = F.hauntedList[1] or "Haunted Front Yard"
			end

			STATE.hauntedLive = "Memulai: " .. tostring(pickHaunted); STATE.hauntedDrops = 0
			local okStart, started = pcall(function() return R.PlayTower:InvokeServer(pickHaunted) end)
			if okStart and started then
				local done, fails = false, 0
				while F.hauntedTower and not done do
					local okP, seq = pcall(function() return R.CompleteFloor:InvokeServer() end)
					if okP and type(seq) == "table" and #seq > 0 then
						fails = 0
						for _, act in ipairs(seq) do
							if act.action == "floorStarted" then 
								STATE.hauntedFloor = tonumber(act.floor) or 1
							elseif act.action == "floorCompleted" then
								if act.rewards then
									for _, amt in pairs(act.rewards) do
										if type(amt) == "number" then STATE.hauntedDrops += amt end
									end
								end
							elseif act.action == "ended" then done = true break end
						end
						if not done and F.hauntedExitOn and F.hauntedExitFloor > 0 and STATE.hauntedFloor >= F.hauntedExitFloor then
							done = true; drainTower()
						end
					else fails += 1; if fails > 8 then done = true end; task.wait(1) end
				end
			end
			drainTower()
			task.wait(2)
		else STATE.hauntedLive = "Standby"; task.wait(2) end
	end
end)

-- Webhook Auto-Status (30 Menit)
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		task.wait(1800)
		if F.webhookEnabled then
			pcall(function()
				local m = tostring(money())
				local rb = tostring(rebirthAmt())
				local gems = tostring(currencyAmount("Gems"))
				local desc = string.format("💰 **Uang:** %s\n🔄 **Rebirth:** %s\n💎 **Gems:** %s\n🏰 **Tower:** %s (Lt. %d)\n🎃 **Haunted Tower:** %s (Lt. %d)", m, rb, gems, STATE.towerLive, STATE.towerFloor, STATE.hauntedLive, STATE.hauntedFloor)
				SendWebhook("📊 Auto-Status Update (30 Min)", desc, 5763719)
			end)
		end
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.claimQuests then
			pcall(function()
				if R.ClaimDaily then R.ClaimDaily:FireServer() end; if R.ClaimOffline then R.ClaimOffline:FireServer() end; if R.ClaimGroup then R.ClaimGroup:FireServer() end
				if R.QuestClaim and G.DC and G.DC.Quests and G.QuestConfig then
					local now = workspace:GetServerTimeNow()
					for _, p in ipairs({"Daily", "Weekly"}) do
						local q = G.DC.Quests[p]()
						if q and (tonumber(q.expiresAt) or 0) > math.floor(now) then
							for _, def in ipairs(G.QuestConfig.Periods[p].quests) do
								if not (q.claimed and q.claimed[def.id]) and (tonumber(q.progress[def.id]) or 0) >= (tonumber(def.target) or 9e9) then R.QuestClaim:FireServer(p, def.id, q.expiresAt); task.wait(0.5) end
							end
						end
					end
				end
			end)
		end
		if F.codesAuto and R.RedeemCode then
			pcall(function()
				local defaultCodes = { "RELEASE", "UPDATE1", "UPDATE2", "UPDATE3", "UPDATE4", "1KCCU", "5KCCU", "10KCCU", "20KCCU", "30KCCU", "40KCCU", "100KLIKES" }
				local redeemed = G.DC.RedeemedCodes() or {}
				for _, c in ipairs(defaultCodes) do if not redeemed[c] then R.RedeemCode:FireServer(c); task.wait(0.5) end end
			end)
		end
		task.wait(60)
	end
end)
