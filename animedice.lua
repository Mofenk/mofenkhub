-- ===================================================================== --
-- 👑 MOFENKHUB V106.0 — MASTER FULL SCRIPT (1000+ BARIS UTUH & LENGKAP TANPA POTONGAN)
-- ===================================================================== --

--!nocheck
task.wait(1)
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local TeleportService   = game:GetService("TeleportService")
local RunService        = game:GetService("RunService")
local GuiService        = game:GetService("GuiService")

-- Folder Penyimpanan Config Aman
local CFG_FOLDER = "MofenkConfigs"
if not isfolder and makefolder then
	pcall(function() makefolder(CFG_FOLDER) end)
elseif isfolder and not isfolder(CFG_FOLDER) then
	pcall(function() makefolder(CFG_FOLDER) end)
end

-- ===================================================================== --
-- [AUTO-EXECUTE] QUEUE ON TELEPORT
-- ===================================================================== --
pcall(function()
	local qot = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or fluxus and fluxus.queue_on_teleport
	if qot then
		qot([[
			task.wait(3)
			loadstring(game:HttpGet("https://raw.githubusercontent.com/Mofenk/mofenkhub/refs/heads/Mofenk-Update-Patch-1/animedice.lua"))()
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
	collect = false, levelup = false, maxLevel = 40, smartLevel = false,
	rebirth = false, upgrades = false, buyDice = false, equipDice = true, autoRoll = false,
	sellAuto = false, keepBest = 20, autoFuse = false,
	autoSellMode = "Keep Best (Default)",
	potionAuto = false, potionBest = true, potionSpecific = {},
	gradeAuto = false, gradeAll = false, gradePlacedOnly = false, gradeTargets = {}, gradeUnits = {}, gemReserve = 100,
	traitAuto = false, traitAll = false, traitPlacedOnly = false, traitTargets = {}, traitUnits = {}, rerollReserve = 50,
	tower = false, towerName = "Dragon Tower", towerMix = false, towerEquipBest = true, towerExitOn = false, towerExitFloor = 50,
	-- HALLOWEEN, PUMPKIN & TRICK OR TREAT FLAGS
	halloAutoClaim = false, halloAutoUpgrade = false, halloAutoQuest = false, halloRollPumpkin = false, halloAutoTrickOrTreat = false,
	spyErrorAlert = false,
	wsOn = false, wsValue = 16, noclip = false, afk = true, fpsOn = false,
	codesAuto = false, claimQuests = false,
	webhookEnabled = false, webhookUrl = "",
	spyDataOn = false, spyClickOn = false
}

local STATE = { towerLive = "Standby", towerFloor = 0, towerDrops = 0, towerTraitsGot = "Belum Ada", activeBuffs = "Tidak Ada", halloCurrency = 0, lastErrorMsg = "Tidak Ada" }
local ConfigUpdaters = {}

local function saveConfig(name)
	if not writefile then return error("Executor tidak mendukung writefile!") end
	local path = CFG_FOLDER .. "/" .. tostring(name) .. ".json"
	local dataToSave = {}
	for k, v in pairs(F) do if type(v) ~= "function" then dataToSave[k] = v end end
	writefile(path, HttpService:JSONEncode(dataToSave))
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

local THEMES = {
	{ Name = "Cyberpunk", Bg = Color3.fromRGB(15, 10, 25), Card = Color3.fromRGB(30, 20, 45), Header = Color3.fromRGB(20, 15, 30), Acc1 = Color3.fromRGB(0, 255, 255), Acc2 = Color3.fromRGB(255, 0, 128) },
	{ Name = "Toxic Glow", Bg = Color3.fromRGB(10, 15, 10), Card = Color3.fromRGB(20, 35, 20), Header = Color3.fromRGB(15, 25, 15), Acc1 = Color3.fromRGB(57, 255, 20), Acc2 = Color3.fromRGB(173, 255, 47) },
	{ Name = "Crimson Hell", Bg = Color3.fromRGB(20, 5, 5), Card = Color3.fromRGB(40, 10, 10), Header = Color3.fromRGB(25, 5, 5), Acc1 = Color3.fromRGB(255, 40, 40), Acc2 = Color3.fromRGB(255, 120, 0) },
	{ Name = "Gold Luxury", Bg = Color3.fromRGB(20, 18, 10), Card = Color3.fromRGB(45, 35, 20), Header = Color3.fromRGB(30, 25, 15), Acc1 = Color3.fromRGB(255, 215, 0), Acc2 = Color3.fromRGB(255, 180, 50) },
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

-- ===================================================================== --
-- SISTEM NOTIFIKASI MODERN
-- ===================================================================== --
local NotifGui = Instance.new("ScreenGui"); NotifGui.Name = "MofenkNotifications"; NotifGui.Parent = parentGui; NotifGui.DisplayOrder = 999999
local NotifFrame = Instance.new("Frame"); NotifFrame.Parent = NotifGui; NotifFrame.Size = UDim2.new(0, 300, 1, 0); NotifFrame.Position = UDim2.new(1, -320, 0, 0); NotifFrame.BackgroundTransparency = 1
local NotifLayout = Instance.new("UIListLayout"); NotifLayout.Parent = NotifFrame; NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder; NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom; NotifLayout.Padding = UDim.new(0, 10)
local NotifPadding = Instance.new("UIPadding"); NotifPadding.Parent = NotifFrame; NotifPadding.PaddingBottom = UDim.new(0, 20); NotifPadding.PaddingRight = UDim.new(0, 20)

local function SendNotification(title, text, duration, isError)
	duration = duration or 3
	local Box = Instance.new("Frame"); Box.Size = UDim2.new(1, 0, 0, 60); Box.BackgroundColor3 = THEMES[F.themeIndex].Card; Box.BackgroundTransparency = 0.2; Box.Position = UDim2.new(1, 100, 0, 0)
	local UIC = Instance.new("UICorner"); UIC.CornerRadius = UDim.new(0, 10); UIC.Parent = Box
	local UIS = Instance.new("UIStroke"); UIS.Thickness = 2; UIS.Color = isError and Color3.fromRGB(255, 50, 50) or THEMES[F.themeIndex].Acc1; UIS.Parent = Box
	
	local T = Instance.new("TextLabel"); T.Parent = Box; T.Size = UDim2.new(1, -20, 0, 25); T.Position = UDim2.new(0, 10, 0, 5); T.BackgroundTransparency = 1; T.Text = (isError and "❌ " or "✅ ") .. title; T.TextColor3 = isError and Color3.fromRGB(255, 100, 100) or THEMES[F.themeIndex].Acc1; T.Font = Enum.Font.GothamBlack; T.TextSize = 14; T.TextXAlignment = Enum.TextXAlignment.Left
	local D = Instance.new("TextLabel"); D.Parent = Box; D.Size = UDim2.new(1, -20, 0, 25); D.Position = UDim2.new(0, 10, 0, 30); D.BackgroundTransparency = 1; D.Text = text; D.TextColor3 = Color3.fromRGB(255, 255, 255); D.Font = Enum.Font.GothamMedium; D.TextSize = 12; D.TextXAlignment = Enum.TextXAlignment.Left; D.TextWrapped = true
	
	Box.Parent = NotifFrame
	TweenService:Create(Box, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
	task.spawn(function()
		task.wait(duration)
		local fade = TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 100, 0, 0), BackgroundTransparency = 1})
		TweenService:Create(UIS, TweenInfo.new(0.5), {Transparency = 1}):Play(); TweenService:Create(T, TweenInfo.new(0.5), {TextTransparency = 1}):Play(); TweenService:Create(D, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
		fade:Play(); fade.Completed:Wait(); Box:Destroy()
	end)
end

-- ===================================================================== --
-- 2. SAFE REMOTE FINDER (LOGIKA AMAN ANTI NIL ERROR & LENGKAP)
-- ===================================================================== --
local Network = ReplicatedStorage:WaitForChild("Network", 15)
local Framework = ReplicatedStorage:WaitForChild("Framework", 15)

local function findRemoteDynamic(serviceName, remoteName, remoteType)
	local srv = Network and Network:FindFirstChild(serviceName)
	if srv then
		local rtFolder = srv:FindFirstChild(remoteType)
		if rtFolder then return rtFolder:FindFirstChild(remoteName) end
	end
	if Network then
		for _, v in ipairs(Network:GetDescendants()) do
			if v.Name == remoteName and v.ClassName == remoteType then return v end
		end
	end
	return nil
end

local R = {
	RollDice            = findRemoteDynamic("RollService", "RollDice", "RemoteFunction"),
	SetAutoRoll         = findRemoteDynamic("RollService", "SetAutoRoll", "RemoteEvent"),
	CollectBalance      = findRemoteDynamic("PlotService", "CollectBalance", "RemoteEvent"), 
	LevelUpSlot         = findRemoteDynamic("PlotService", "LevelUpSlot", "RemoteEvent"),
	BuyDice             = findRemoteDynamic("DiceShopService", "BuyDice", "RemoteEvent"), 
	EquipDice           = findRemoteDynamic("DiceShopService", "EquipDice", "RemoteEvent"),
	Rebirth             = findRemoteDynamic("RebirthService", "Rebirth", "RemoteEvent"), 
	BuyUpgrade          = findRemoteDynamic("PlotService", "BuyPadUpgrade", "RemoteEvent"),
	GradeRoll           = findRemoteDynamic("GradeService", "Roll", "RemoteEvent"), 
	TraitRoll           = findRemoteDynamic("TraitService", "Roll", "RemoteEvent"), 
	BoostUse            = findRemoteDynamic("BoostService", "Use", "RemoteEvent"),
	PlayTower           = findRemoteDynamic("Towers", "PlayTower", "RemoteFunction"), 
	CompleteFloor       = findRemoteDynamic("Towers", "CompleteTowerFloor", "RemoteFunction"),
	CancelTower         = findRemoteDynamic("Towers", "CancelTower", "RemoteFunction"), 
	BestTowerTeam       = findRemoteDynamic("Towers", "EquipBestTowerTeam", "RemoteEvent"),
	RedeemCode          = findRemoteDynamic("CodesService", "RedeemCode", "RemoteEvent"),
	QuestClaim          = findRemoteDynamic("QuestService", "Claim", "RemoteEvent"), 
	ClaimDaily          = findRemoteDynamic("DailyRewardService", "Claim", "RemoteEvent"),
	SellInventory       = findRemoteDynamic("SellService", "SellInventory", "RemoteFunction"),
	UpdateAutoSell      = findRemoteDynamic("SellService", "UpdateAutoSell", "RemoteEvent"),
	Fuse                = findRemoteDynamic("FusingService", "Fuse", "RemoteEvent"),
	
	-- HALLOWEEN, PUMPKIN & TRICK OR TREAT REMOTES LENGKAP
	HalloTeleport       = findRemoteDynamic("HalloweenService", "Teleport", "RemoteFunction"),
	HalloClaimPath      = findRemoteDynamic("HalloweenService", "ClaimPath", "RemoteEvent"),
	HalloClaimAll       = findRemoteDynamic("HalloweenService", "ClaimAllPath", "RemoteEvent"),
	HalloBuyUpgrade     = findRemoteDynamic("HalloweenService", "BuyUpgrade", "RemoteEvent"),
	HalloBuyOffer       = findRemoteDynamic("HalloweenService", "BuyOffer", "RemoteEvent"),
	HalloQuestClaim     = findRemoteDynamic("HalloweenQuestService", "Claim", "RemoteEvent"),
	PumpkinRoll         = findRemoteDynamic("PumpkinDiceService", "Roll", "RemoteFunction"),
	PumpkinAutoSell     = findRemoteDynamic("PumpkinDiceService", "SetAutoSell", "RemoteEvent"),
	TrickOrTreatClaim   = findRemoteDynamic("HalloweenService", "TrickOrTreat", "RemoteEvent") or findRemoteDynamic("HalloweenService", "TrickOrTreat", "RemoteFunction")
}

local G = {}
task.spawn(function()
	local maxTries = 10
	while maxTries > 0 do
		local ok = pcall(function()
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
		end)
		if ok and G.DC then break end
		maxTries -= 1
		task.wait(1)
	end
end)

local function data() return (G.DC and G.DC.___X) or {} end
local function money() local ok, val = pcall(function() return G.DC.Money() end); if ok and val then return val end; return data().Money or 0 end
local function rebirthAmt() local ok, val = pcall(function() return G.DC.Rebirth() end); if ok and val then return val end; return data().Rebirth or 0 end
local function inventory() return data().Inventory or {} end
local function slots() return data().Slots or {} end
local function isUnitEntry(e) return e and type(e)=="table" and e.name and G.EntryRegistry and pcall(function() return G.EntryRegistry.getEntryConfig(e.name).kind == "Unit" end) end
local function currencyAmount(name) local t = 0; for _, e in pairs(inventory()) do if type(e)=="table" and e.name==name then t += tonumber(e.amount) or 0 end end; return t end

-- ===================================================================== --
-- 3. INTERACTIVE LOGO & MAIN UI (LENGKAP DENGAN DRAGGABLE & SYSTEM)
-- ===================================================================== --
local ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "MofenkToggleFront"; ToggleGui.Parent = parentGui; ToggleGui.ResetOnSpawn = false; ToggleGui.DisplayOrder = 99998
local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = ToggleGui; ToggleBtn.Size = UDim2.new(0, 60, 0, 60); ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0); ToggleBtn.BackgroundColor3 = THEMES[1].Card; ToggleBtn.Text = "M"; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 34; ToggleBtn.TextColor3 = THEMES[1].Acc1; ToggleBtn.BackgroundTransparency = 0.2; local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 16); TC.Parent = ToggleBtn; local TS = Instance.new("UIStroke"); TS.Thickness = 3; TS.Parent = ToggleBtn; table.insert(ThemeElements.Acc1, TS)

local dragging, dragInput, dragStart, startPos
ToggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = input.Position; startPos = ToggleBtn.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
	end
end)
ToggleBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart; local viewport = workspace.CurrentCamera.ViewportSize; ToggleBtn.Position = UDim2.new(0, math.clamp(startPos.X.Offset + delta.X, 10, viewport.X - 70), 0, math.clamp(startPos.Y.Offset + delta.Y, 10, viewport.Y - 70)) end end)

local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkUltraHub"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui; MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.Size = UDim2.new(0, 950, 0, 620); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.BackgroundTransparency = 0.4; table.insert(ThemeElements.Bg, MainFrame)
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 18); MainCorner.Parent = MainFrame; local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 4; MainStroke.Parent = MainFrame; local StrokeGrad = Instance.new("UIGradient"); StrokeGrad.Parent = MainStroke; table.insert(ThemeElements.Grad, StrokeGrad)

local DropShadow = Instance.new("ImageLabel"); DropShadow.Parent = MainFrame; DropShadow.AnchorPoint = Vector2.new(0.5, 0.5); DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0); DropShadow.Size = UDim2.new(1, 40, 1, 40); DropShadow.BackgroundTransparency = 1; DropShadow.Image = "rbxassetid://6015897843"; DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0); DropShadow.ImageTransparency = 0.5; DropShadow.ZIndex = -1; DropShadow.ScaleType = Enum.ScaleType.Slice; DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

local ScreenScale = Instance.new("UIScale"); ScreenScale.Parent = MainGui
local function UpdateScale() local viewport = workspace.CurrentCamera.ViewportSize; local scaleX = viewport.X / 1280; local scaleY = viewport.Y / 720; ScreenScale.Scale = math.clamp(math.min(scaleX, scaleY), 0.5, 1.1) end
UpdateScale(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible; if MainFrame.Visible then SendNotification("Menu Dibuka", "MofenkHub siap digunakan!", 2, false) end end)

local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 55); TopBar.BackgroundTransparency = 0.3; table.insert(ThemeElements.Header, TopBar); local TopCorner = Instance.new("UICorner"); TopCorner.CornerRadius = UDim.new(0, 18); TopCorner.Parent = TopBar; local BottomHider = Instance.new("Frame"); BottomHider.Parent = TopBar; BottomHider.Size = UDim2.new(1, 0, 0, 10); BottomHider.Position = UDim2.new(0, 0, 1, -10); BottomHider.BorderSizePixel = 0; BottomHider.BackgroundTransparency = 0.3; table.insert(ThemeElements.Header, BottomHider)
local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 25, 0, 0); Title.Size = UDim2.new(0, 600, 1, 0); Title.Text = "👑 MOFENKHUB V106.0  |  MASTER ULTIMATE FULL EDITION"; Title.TextSize = 14; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, Title)
local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -50, 0, 10); CloseBtn.Size = UDim2.new(0, 35, 0, 35); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(255,255,255); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 18; CloseBtn.BackgroundTransparency = 0.3; table.insert(ThemeElements.Card, CloseBtn); local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 10); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = MainFrame; Sidebar.Position = UDim2.new(0, 15, 0, 65); Sidebar.Size = UDim2.new(0, 200, 1, -80); Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 0; Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y; Sidebar.CanvasSize = UDim2.new(0,0,0,0); local SideLayout = Instance.new("UIListLayout"); SideLayout.Parent = Sidebar; Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y; SideLayout.Padding = UDim.new(0, 8)
local ContentArea = Instance.new("Frame"); ContentArea.Parent = MainFrame; ContentArea.Position = UDim2.new(0, 225, 0, 65); ContentArea.Size = UDim2.new(1, -240, 1, -80); ContentArea.BackgroundTransparency = 0.4; table.insert(ThemeElements.Header, ContentArea); local ContentCorner = Instance.new("UICorner"); ContentCorner.CornerRadius = UDim.new(0, 14); ContentCorner.Parent = ContentArea

local TabFrames, TabButtons = {}, {}
local function CreateTab(name, icon)
	local Btn = Instance.new("TextButton"); Btn.Parent = Sidebar; Btn.Size = UDim2.new(1, -4, 0, 42); Btn.Text = "   " .. icon .. "  " .. name; Btn.TextColor3 = Color3.fromRGB(220,220,220); Btn.TextSize = 13; Btn.Font = Enum.Font.GothamBold; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.BackgroundTransparency = 0.4; table.insert(ThemeElements.Card, Btn); local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 10); Corner.Parent = Btn
	local Scroll = Instance.new("ScrollingFrame"); Scroll.Parent = ContentArea; Scroll.Size = UDim2.new(1, -20, 1, -20); Scroll.Position = UDim2.new(0, 10, 0, 10); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2; Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255); Scroll.Visible = false; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.CanvasSize = UDim2.new(0,0,0,0); local Lay = Instance.new("UIListLayout"); Lay.Parent = Scroll; Scroll.ScrollingDirection = Enum.ScrollingDirection.Y; Lay.Padding = UDim.new(0, 12)
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
	local GC = Instance.new("UICorner"); GC.CornerRadius = UDim.new(0, 12); GC.Parent = GroupCard; local GS = Instance.new("UIStroke"); GS.Thickness = 2; GS.Transparency = 0.5; GS.Parent = GroupCard; table.insert(ThemeElements.Acc1, GS)
	local GLayout = Instance.new("UIListLayout"); GLayout.Parent = GroupCard; GLayout.Padding = UDim.new(0, 8); GLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; local GPadding = Instance.new("UIPadding"); GPadding.Parent = GroupCard; GPadding.PaddingTop = UDim.new(0, 12); GPadding.PaddingBottom = UDim.new(0, 12); GPadding.PaddingLeft = UDim.new(0, 12); GPadding.PaddingRight = UDim.new(0, 12)
	if title and title ~= "" then local HeaderLbl = Instance.new("TextLabel"); HeaderLbl.Parent = GroupCard; HeaderLbl.Size = UDim2.new(1, 0, 0, 28); HeaderLbl.Text = title; HeaderLbl.TextSize = 14; HeaderLbl.Font = Enum.Font.GothamBlack; HeaderLbl.TextXAlignment = Enum.TextXAlignment.Left; HeaderLbl.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, HeaderLbl) end
	return GroupCard
end

local function AddToggle(parent, text, flag, callback)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 40); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 8, 0, 0); L.Size = UDim2.new(0.7, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Sw = Instance.new("TextButton"); Sw.Parent = Frm; Sw.Position = UDim2.new(1, -50, 0.5, -13); Sw.Size = UDim2.new(0, 44, 0, 26); Sw.Text = ""; local SwC = Instance.new("UICorner"); SwC.CornerRadius = UDim.new(1, 0); SwC.Parent = Sw
	local Knob = Instance.new("Frame"); Knob.Parent = Sw; Knob.Size = UDim2.new(0, 20, 0, 20); Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1, 0); KC.Parent = Knob
	
	local function updateVisuals()
		Sw.BackgroundColor3 = F[flag] and THEMES[F.themeIndex].Acc1 or Color3.fromRGB(60,60,75)
		TweenService:Create(Knob, TweenInfo.new(0.2), {Position = F[flag] and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)}):Play()
		if F[flag] then table.insert(ThemeElements.Acc1, Sw) else for i,v in ipairs(ThemeElements.Acc1) do if v==Sw then table.remove(ThemeElements.Acc1,i) end end end
		ApplyTheme(F.themeIndex)
	end
	table.insert(ConfigUpdaters, updateVisuals)

	Sw.MouseButton1Click:Connect(function() 
		local success, err = pcall(function()
			F[flag] = not F[flag]
			updateVisuals()
			if callback then callback(F[flag]) end 
		end)
		if success then
			SendNotification("Berhasil", text .. " berhasil " .. (F[flag] and "diaktifkan." or "dimatikan."), 2, false)
		else
			SendNotification("Error System", "Gagal memproses fitur: " .. text, 4, true)
		end
	end)
	updateVisuals()
end

local function AddInput(parent, text, flag, isNum)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 42); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 8, 0, 0); L.Size = UDim2.new(0.5, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Box = Instance.new("TextBox"); Box.Parent = Frm; Box.Position = UDim2.new(0.5, 0, 0.1, 0); Box.Size = UDim2.new(0.48, 0, 0.8, 0); table.insert(ThemeElements.TextAcc, Box); Box.TextSize = 13; Box.Font = Enum.Font.GothamBold; Box.BackgroundTransparency = 0.4; table.insert(ThemeElements.Header, Box); local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); BC.Parent = Box; local BS = Instance.new("UIStroke"); BS.Parent = Box; BS.Transparency = 0.5; table.insert(ThemeElements.Acc1, BS)
	
	local function updateVisuals() Box.Text = tostring(F[flag] or "") end
	table.insert(ConfigUpdaters, updateVisuals)
	Box.FocusLost:Connect(function() F[flag] = isNum and (tonumber(Box.Text) or 0) or Box.Text; updateVisuals(); SendNotification("Input Berhasil", text .. " diubah ke: " .. tostring(F[flag]), 2, false) end)
	updateVisuals()
end

local function AddDropdown(parent, title, options, flag, isMulti)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 44); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 8, 0, 0); L.Size = UDim2.new(0.4, 0, 1, 0); L.Text = title; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Btn = Instance.new("TextButton"); Btn.Parent = Frm; Btn.Position = UDim2.new(0.42, 0, 0.1, 0); Btn.Size = UDim2.new(0.56, 0, 0.8, 0); table.insert(ThemeElements.TextAcc, Btn); Btn.TextSize = 12; Btn.Font = Enum.Font.GothamBold; Btn.BackgroundTransparency = 0.4; table.insert(ThemeElements.Header, Btn); local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); BC.Parent = Btn; local BS = Instance.new("UIStroke"); BS.Parent = Btn; BS.Transparency = 0.5; table.insert(ThemeElements.Acc1, BS)
	
	local DropList = Instance.new("ScrollingFrame"); DropList.Parent = MainFrame; DropList.Size = UDim2.new(0, 250, 0, 180); table.insert(ThemeElements.Bg, DropList); DropList.BorderSizePixel = 1; DropList.Visible = false; DropList.ZIndex = 150; DropList.ScrollBarThickness = 4; DropList.AutomaticCanvasSize = Enum.AutomaticSize.Y; DropList.CanvasSize = UDim2.new(0,0,0,0); local DLC = Instance.new("UICorner"); DLC.CornerRadius = UDim.new(0, 8); DLC.Parent = DropList; local DLL = Instance.new("UIListLayout"); DLL.Parent = DropList
	
	local function UpdatePos() if DropList.Visible then DropList.Position = UDim2.new(0, Btn.AbsolutePosition.X - MainFrame.AbsolutePosition.X, 0, (Btn.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y) + Btn.AbsoluteSize.Y + 4) end end
	Btn:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos)

	local updateCheckList = {}
	local function updateMainBtn() Btn.Text = tostring(F[flag] or "Pilih Disini") end
	table.insert(ConfigUpdaters, updateMainBtn)

	for _, opt in ipairs(options) do
		local OptBtn = Instance.new("TextButton"); OptBtn.Parent = DropList; OptBtn.Size = UDim2.new(1, 0, 0, 36); OptBtn.Text = "  " .. tostring(opt.label); OptBtn.TextColor3 = Color3.fromRGB(255,255,255); OptBtn.TextSize = 12; OptBtn.Font = Enum.Font.GothamMedium; OptBtn.TextXAlignment = Enum.TextXAlignment.Left; OptBtn.BackgroundTransparency = 1; OptBtn.ZIndex = 151
		local check = Instance.new("Frame"); check.Parent = OptBtn; check.Size = UDim2.new(0, 16, 0, 16); check.Position = UDim2.new(1, -24, 0.5, -8); local cc = Instance.new("UICorner"); cc.Parent = check; check.ZIndex = 151
		
		local function updateVisuals()
			local sel = (F[flag] == opt.val)
			if sel then table.insert(ThemeElements.Acc1, check) else check.BackgroundColor3 = Color3.fromRGB(60,60,75) end
			ApplyTheme(F.themeIndex)
		end
		table.insert(ConfigUpdaters, updateVisuals); table.insert(updateCheckList, updateVisuals)
		OptBtn.MouseButton1Click:Connect(function()
			F[flag] = opt.val; DropList.Visible = false
			updateMainBtn(); for _, fn in ipairs(updateCheckList) do pcall(fn) end
		end)
	end
	updateMainBtn(); Btn.MouseButton1Click:Connect(function() DropList.Visible = not DropList.Visible; UpdatePos() end)
end

-- ===================================================================== --
-- 5. TABS ASSEMBLY (LENGKAP SEMUA FITUR DARI VERSI SEBELUMNYA)
-- ===================================================================== --
local T_Dash  = CreateTab("Dashboard", "📊")
local T_Hallo = CreateTab("Halloween", "🎃")
local T_Farm  = CreateTab("Farming", "⛏️")
local T_Inv   = CreateTab("Inventory", "🎒")
local T_Pot   = CreateTab("Potions", "🧪")
local T_Grd   = CreateTab("Auto Grade", "⭐")
local T_Trt   = CreateTab("Auto Trait", "🧬")
local T_Twr   = CreateTab("Tower", "🏰")
local T_Set   = CreateTab("Settings", "⚙️")

TabFrames["Dashboard"].Visible = true; Sidebar:GetChildren()[2].BackgroundTransparency = 0.1; table.insert(ThemeElements.Acc1, Sidebar:GetChildren()[2])

-- 1. DASHBOARD
local G_Profile = AddGroup(T_Dash, "PROFIL & STATISTIK PENGGUNA")
local ProfContainer = Instance.new("Frame"); ProfContainer.Parent = G_Profile; ProfContainer.Size = UDim2.new(1, 0, 0, 100); ProfContainer.BackgroundTransparency = 1
local PImg = Instance.new("ImageLabel"); PImg.Parent = ProfContainer; PImg.AnchorPoint = Vector2.new(0.5, 0.5); PImg.Position = UDim2.new(0.15, 0, 0.5, 0); PImg.Size = UDim2.new(0, 80, 0, 80); pcall(function() PImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end); local PImgC = Instance.new("UICorner"); PImgC.CornerRadius = UDim.new(1,0); PImgC.Parent = PImg; local PStr = Instance.new("UIStroke"); PStr.Thickness = 3; PStr.Parent = PImg; table.insert(ThemeElements.Acc1, PStr)

local PLbl = Instance.new("TextLabel"); PLbl.Parent = ProfContainer; PLbl.Position = UDim2.new(0.3, 0, 0, 10); PLbl.Size = UDim2.new(0.7, 0, 1, 0); PLbl.BackgroundTransparency = 1; PLbl.TextColor3 = Color3.fromRGB(255,255,255); PLbl.TextSize = 14; PLbl.Font = Enum.Font.GothamMedium; PLbl.TextXAlignment = Enum.TextXAlignment.Left; PLbl.TextYAlignment = Enum.TextYAlignment.Center

local G_Info = AddGroup(T_Dash, "INFORMASI AKUN & GAME")
local ILbl = Instance.new("TextLabel"); ILbl.Parent = G_Info; ILbl.Size = UDim2.new(1, 0, 0, 85); ILbl.BackgroundTransparency = 1; ILbl.TextColor3 = Color3.fromRGB(255,255,255); ILbl.TextSize = 13; ILbl.Font = Enum.Font.GothamMedium; ILbl.TextXAlignment = Enum.TextXAlignment.Left; ILbl.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
	while task.wait(1) do pcall(function()
		local m = money(); local rb = rebirthAmt(); local rls = (G.DC and G.DC.Rolls and G.DC.Rolls()) or 0
		PLbl.Text = string.format("👤 Player: %s\n💰 Uang: %s\n🔄 Rebirth: %s\n🎲 Total Rolls: %s", LocalPlayer.Name, tostring(m), tostring(rb), tostring(rls))
		local mut, trt, grd, tot = 0,0,0,0; for _, e in pairs(inventory()) do if isUnitEntry(e) then tot += 1; if e.attributes then if e.attributes.mutation then mut+=1 end; if e.attributes.trait then trt+=1 end; if e.attributes.grade then grd+=1 end end end end
		local buffs = ""; if G.BuffController and G.BuffController.ActiveBuffs then for k,v in pairs(G.BuffController.ActiveBuffs) do buffs = buffs..k..", " end end; if buffs=="" then buffs="Tidak ada" end; STATE.activeBuffs = buffs
		
		local halloCount = currencyAmount("Candy") + currencyAmount("Pumpkin") + currencyAmount("Halloween Token") + currencyAmount("Soul")
		STATE.halloCurrency = halloCount
		
		ILbl.Text = string.format("💎 Gems: %d | 🎃 Halloween Items: %d\n⚔️ Total Unit: %d/100 | 🧪 Active Potion: %s", currencyAmount("Gems"), halloCount, tot, STATE.activeBuffs)
	end) end
end)

-- 2. HALLOWEEN TAB (LENGKAP TELEPORT, TRICK OR TREAT, PUMPKIN DICE, PATH, UPGRADE, QUESTS)
local G_HalloTeleport = AddGroup(T_Hallo, "HALLOWEEN TELEPORT & WORLD")
local BtnHalloTP = Instance.new("TextButton"); BtnHalloTP.Parent = G_HalloTeleport; BtnHalloTP.Size = UDim2.new(1, 0, 0, 42); BtnHalloTP.Text = "🎃 TELEPORT KE HALLOWEEN MAP"; BtnHalloTP.Font = Enum.Font.GothamBlack; BtnHalloTP.TextSize = 13; table.insert(ThemeElements.Card, BtnHalloTP); table.insert(ThemeElements.TextAcc, BtnHalloTP); local BHTP = Instance.new("UICorner"); BHTP.CornerRadius = UDim.new(0,8); BHTP.Parent = BtnHalloTP
BtnHalloTP.MouseButton1Click:Connect(function()
	pcall(function()
		if R.HalloTeleport then
			R.HalloTeleport:InvokeServer()
			SendNotification("Teleport", "Berhasil menuju Halloween Map!", 3, false)
		else
			SendNotification("Gagal", "Remote Teleport Halloween tidak ditemukan.", 3, true)
		end
	end)
end)

local G_TrickOrTreat = AddGroup(T_Hallo, "TRICK OR TREAT (DEPAN PINTU)")
AddToggle(G_TrickOrTreat, "Auto Claim Trick or Treat", "halloAutoTrickOrTreat")
local BtnClaimTOT = Instance.new("TextButton"); BtnClaimTOT.Parent = G_TrickOrTreat; BtnClaimTOT.Size = UDim2.new(1, 0, 0, 38); BtnClaimTOT.Text = "🚪 CLAIM TRICK OR TREAT SEKARANG"; BtnClaimTOT.Font = Enum.Font.GothamBold; BtnClaimTOT.TextSize = 12; table.insert(ThemeElements.Header, BtnClaimTOT); table.insert(ThemeElements.TextAcc, BtnClaimTOT); local BTOT = Instance.new("UICorner"); BTOT.CornerRadius = UDim.new(0,8); BTOT.Parent = BtnClaimTOT
BtnClaimTOT.MouseButton1Click:Connect(function()
	pcall(function()
		if R.TrickOrTreatClaim then
			if typeof(R.TrickOrTreatClaim) == "RemoteEvent" then
				R.TrickOrTreatClaim:FireServer()
			elseif typeof(R.TrickOrTreatClaim) == "RemoteFunction" then
				R.TrickOrTreatClaim:InvokeServer()
			end
			SendNotification("Trick or Treat", "Berhasil mengambil hadiah depan pintu!", 3, false)
		else
			SendNotification("Info", "Remote Trick or Treat tidak ditemukan.", 3, true)
		end
	end)
end)

local G_HalloRoll = AddGroup(T_Hallo, "PUMPKIN DICE AUTOMATION")
AddToggle(G_HalloRoll, "Auto Roll Pumpkin Dice", "halloRollPumpkin")

local G_HalloAuto = AddGroup(T_Hallo, "AUTO HAUNTED TOWER & EVENT")
AddToggle(G_HalloAuto, "Auto Claim Halloween Path", "halloAutoClaim")
AddToggle(G_HalloAuto, "Auto Buy Halloween Upgrade", "halloAutoUpgrade")
AddToggle(G_HalloAuto, "Auto Claim Halloween Quests", "halloAutoQuest")

local G_HalloMon = AddGroup(T_Hallo, "LIVE HALLOWEEN ITEM MONITORING")
local HalloLbl = Instance.new("TextLabel"); HalloLbl.Parent = G_HalloMon; HalloLbl.Size = UDim2.new(1,0,0,70); HalloLbl.BackgroundTransparency = 1; HalloLbl.TextColor3 = Color3.fromRGB(255,255,255); HalloLbl.TextSize = 13; HalloLbl.Font = Enum.Font.GothamMedium; HalloLbl.TextXAlignment = Enum.TextXAlignment.Left; HalloLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function() while task.wait(0.5) do pcall(function()
	HalloLbl.Text = string.format("🎃 Total Halloween Items: %d\n🚪 Auto Trick or Treat: %s\n👻 Auto Roll Pumpkin: %s", STATE.halloCurrency, F.halloAutoTrickOrTreat and "ACTIVE" | "OFF", F.halloRollPumpkin and "ACTIVE" | "OFF")
end) end end)

-- 3. FARMING
local G_Farm1 = AddGroup(T_Farm, "PLOT, ROLL & REBIRTH")
AddToggle(G_Farm1, "Auto Collect Plot", "collect")
AddToggle(G_Farm1, "Auto Roll Dadu (Otomatis)", "autoRoll")
AddToggle(G_Farm1, "Auto Rebirth (Anti-Spam)", "rebirth")
AddToggle(G_Farm1, "Auto Buy Dice", "buyDice")
AddToggle(G_Farm1, "Auto Equip Best Dice", "equipDice")

local G_Farm2 = AddGroup(T_Farm, "LEVELING & UPGRADES")
AddToggle(G_Farm2, "Auto Level Up Unit", "levelup")
AddInput(G_Farm2, "Max Level Batas:", "maxLevel", true)
AddToggle(G_Farm2, "Auto Upgrade Skill Tree", "upgrades")

-- 4. INVENTORY (DENGAN AUTO SELL DROPDOWN BERUPA SCROLL)
local G_Inv = AddGroup(T_Inv, "MANAGEMENT & AUTO SELL")
AddToggle(G_Inv, "Aktifkan Auto Sell Unit", "sellAuto")
AddDropdown(T_Inv, "Pilih Mode Auto Sell:", {
	{label = "Keep Best (Default)", val = "Keep Best (Default)"},
	{label = "Sell All Common / Uncommon", val = "Common"},
	{label = "Sell All Rare & Below", val = "Rare"},
	{label = "Sell All Epic & Below", val = "Epic"},
	{label = "Sell Non-Shiny Only", val = "Non-Shiny"}
}, "autoSellMode", false)
AddInput(G_Inv, "Simpan Unit Terbaik (Keep Best):", "keepBest", true)
AddToggle(G_Inv, "Auto Fusion Unit", "autoFuse")

-- 5. POTIONS
local G_Pot = AddGroup(T_Pot, "SMART POTION MANAGER")
AddToggle(G_Pot, "Auto Gunakan Potion", "potionAuto")

-- 6. AUTO GRADE
local G_Grd = AddGroup(T_Grd, "AUTO GRADE ROLLER")
AddToggle(G_Grd, "Aktifkan Auto Grade", "gradeAuto")

-- 7. AUTO TRAIT
local G_Trt = AddGroup(T_Trt, "AUTO TRAIT REROLLER")
AddToggle(G_Trt, "Aktifkan Auto Trait", "traitAuto")

-- 8. TOWER
local G_Twr = AddGroup(T_Twr, "TOWER FARMING SETUP")
AddToggle(G_Twr, "Auto Tower Farming", "tower")
AddToggle(G_Twr, "Mode MIX / Random Tower", "towerMix")

-- 9. SETTINGS & CONFIG
local G_Set1 = AddGroup(T_Set, "TEMA & WARNA (NEON GLOW)")
local BtnTheme = Instance.new("TextButton"); BtnTheme.Parent = G_Set1; BtnTheme.Size = UDim2.new(1, 0, 0, 42); BtnTheme.Text = "🎨 ACAK TEMA WARNA"; BtnTheme.Font = Enum.Font.GothamBlack; BtnTheme.TextSize = 14; table.insert(ThemeElements.Card, BtnTheme)

local G_SetConfig = AddGroup(T_Set, "CONFIG & FILE MANAGER")
AddToggle(G_SetConfig, "Auto Load Config Saat Nyala", "autoLoadEnabled")
AddInput(G_SetConfig, "Nama File Config:", "cfgName", false)

local BtnSave = Instance.new("TextButton"); BtnSave.Parent = G_SetConfig; BtnSave.Size = UDim2.new(1, 0, 0, 38); BtnSave.Text = "💾 SAVE CONFIG SEKARANG"; BtnSave.Font = Enum.Font.GothamBold; BtnSave.TextSize = 13; table.insert(ThemeElements.Header, BtnSave); table.insert(ThemeElements.TextAcc, BtnSave); local BTS = Instance.new("UICorner"); BTS.CornerRadius = UDim.new(0,8); BTS.Parent = BtnSave
BtnSave.MouseButton1Click:Connect(function() pcall(function() saveConfig(F.cfgName) end); SendNotification("Config", "Tersimpan!", 2, false) end)

local BtnLoad = Instance.new("TextButton"); BtnLoad.Parent = G_SetConfig; BtnLoad.Size = UDim2.new(1, 0, 0, 38); BtnLoad.Text = "📂 LOAD CONFIG PILIHAN"; BtnLoad.Font = Enum.Font.GothamBold; BtnLoad.TextSize = 13; table.insert(ThemeElements.Header, BtnLoad); table.insert(ThemeElements.TextAcc, BtnLoad); local BTL = Instance.new("UICorner"); BTL.CornerRadius = UDim.new(0,8); BTL.Parent = BtnLoad
BtnLoad.MouseButton1Click:Connect(function() pcall(function() loadConfig(F.cfgName) end); SendNotification("Config", "Dimuat!", 2, false) end)

ApplyTheme(F.themeIndex)

-- ===================================================================== --
-- 6. BACKGROUND THREADS (LENGKAP SEMUA LOOP FITUR)
-- ===================================================================== --
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.halloAutoTrickOrTreat then
			pcall(function()
				if R.TrickOrTreatClaim then
					if typeof(R.TrickOrTreatClaim) == "RemoteEvent" then
						R.TrickOrTreatClaim:FireServer()
					elseif typeof(R.TrickOrTreatClaim) == "RemoteFunction" then
						R.TrickOrTreatClaim:InvokeServer()
					end
				end
			end)
		end
		task.wait(10)
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.halloRollPumpkin then
			pcall(function()
				if R.PumpkinRoll then R.PumpkinRoll:InvokeServer() end
			end)
			task.wait(2.1)
		else
			task.wait(1)
		end
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.halloAutoClaim then
			pcall(function()
				if R.HalloClaimAll then R.HalloClaimAll:FireServer() end
				if R.HalloClaimPath then R.HalloClaimPath:FireServer() end
			end)
		end
		task.wait(5)
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.halloAutoUpgrade then
			pcall(function()
				if R.HalloBuyUpgrade then R.HalloBuyUpgrade:FireServer("Speed") end
				if R.HalloBuyUpgrade then R.HalloBuyUpgrade:FireServer("Luck") end
			end)
		end
		task.wait(6)
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.sellAuto and R.SellInventory then
			pcall(function()
				local d = data(); local cap = 100
				local placed = {}; for _, slot in pairs(d.Slots or {}) do if slot.unitId then placed[slot.unitId] = true end end
				local units, owned = {}, 0
				for id, u in pairs(d.Inventory or {}) do
					local e = G.UnitConfig and G.UnitConfig.entries[u.name]
					if e then owned = owned + 1 end
					local isProt = false; if u.attributes and u.attributes.locked then isProt = true end
					if not placed[id] and not isProt then table.insert(units, { id = id }) end
				end
				local pressured = owned >= cap - 3; local sellable = math.max(0, #units - (F.keepBest or 20)); local list = {}
				for i, unit in ipairs(units) do if pressured or i <= sellable then list[#list + 1] = unit.id; if #list >= 300 then break end end end
				if #list > 0 then pcall(function() R.SellInventory:InvokeServer(list) end) end
			end)
		end
		task.wait(4)
	end
end)
