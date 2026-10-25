-- ===================================================================== --
-- 👑 MOFENKHUB V89.0 — FULL FIXED MASTER SUITE (AUTO-SCALE & LOADING ANIM)
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

local LocalPlayer = Players.LocalPlayer
local successGui, parentGui = pcall(function()
	if gethui then return gethui() elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end

pcall(function() for _, v in pairs(parentGui:GetChildren()) do if string.find(v.Name, "Mofenk") then v:Destroy() end end end)

-- ===================================================================== --
-- 1. STATE & CONFIGURATION MANAGER (DENGAN AUTO-LOAD ON/OFF)
-- ===================================================================== --
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

local F = {
	themeIndex = 1, cfgName = "MofenkConfig1", autoLoadEnabled = false,
	-- Farm & Roll
	collect = false, levelup = false, maxLevel = 40, smartLevel = false,
	rebirth = false, upgrades = false, buyDice = false, equipDice = true, autoRoll = false,
	-- Inv & Sell
	sellAuto = false, keepBest = 20, autoFuse = false,
	-- Potion
	potionAuto = false, potionBest = true, potionSpecific = {},
	-- Reroll
	gradeAuto = false, gradeAll = false, gradePlacedOnly = false, gradeTargets = {}, gradeUnits = {}, gemReserve = 100,
	traitAuto = false, traitAll = false, traitPlacedOnly = false, traitTargets = {}, traitUnits = {}, rerollReserve = 50,
	-- Tower
	tower = false, towerName = "Dragon Tower", towerMix = false, towerEquipBest = true, towerExitOn = false, towerExitFloor = 50,
	-- Client & Misc
	wsOn = false, wsValue = 16, noclip = false, afk = true, fpsOn = false,
	codesAuto = false, claimQuests = false
}

local STATE = { towerLive = "Standby", towerFloor = 0, towerDrops = 0, towerTraitsGot = "Belum Ada", activeBuffs = "Tidak Ada" }

local THEMES = {
	{ Name = "Cyberpunk", Bg = Color3.fromRGB(10, 5, 15), Card = Color3.fromRGB(20, 15, 30), Header = Color3.fromRGB(15, 10, 20), Acc1 = Color3.fromRGB(0, 255, 255), Acc2 = Color3.fromRGB(255, 0, 128) },
	{ Name = "Toxic Glow", Bg = Color3.fromRGB(5, 10, 5), Card = Color3.fromRGB(15, 25, 15), Header = Color3.fromRGB(10, 15, 10), Acc1 = Color3.fromRGB(57, 255, 20), Acc2 = Color3.fromRGB(173, 255, 47) },
	{ Name = "Crimson Hell", Bg = Color3.fromRGB(12, 0, 0), Card = Color3.fromRGB(25, 5, 5), Header = Color3.fromRGB(18, 2, 2), Acc1 = Color3.fromRGB(255, 20, 20), Acc2 = Color3.fromRGB(255, 100, 0) },
	{ Name = "Gold Luxury", Bg = Color3.fromRGB(15, 12, 5), Card = Color3.fromRGB(30, 25, 15), Header = Color3.fromRGB(20, 18, 8), Acc1 = Color3.fromRGB(255, 215, 0), Acc2 = Color3.fromRGB(255, 165, 0) },
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
		pcall(function() writefile(getCfgPath(name), HttpService:JSONEncode(F)) end)
	end
end
local function loadConfig(name)
	local path = getCfgPath(name)
	if readfile and isfile and isfile(path) then
		pcall(function() local d = HttpService:JSONDecode(readfile(path)); for k,v in pairs(d) do F[k]=v end end)
	end
end

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
	Fuse            = svc("FusingService.RE.Fuse")
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
end)

local function data() return G.DC and G.DC.___X or {} end
local function money() pcall(function() return G.DC.Money() end); return data().Money or 0 end
local function rebirthAmt() pcall(function() return G.DC.Rebirth() end); return data().Rebirth or 0 end
local function inventory() return data().Inventory or {} end
local function slots() return data().Slots or {} end
local function isUnitEntry(e) return e and type(e)=="table" and e.name and G.EntryRegistry and pcall(function() return G.EntryRegistry.getEntryConfig(e.name).kind == "Unit" end) end
local function currencyAmount(name) local t = 0; for _, e in pairs(inventory()) do if type(e)=="table" and e.name==name then t += tonumber(e.amount) or 0 end end; return t end

-- ===================================================================== --
-- 3. ANIMASI LOADING & LAYAR TRANSISI PEMBUKA
-- ===================================================================== --
local LoadGui = Instance.new("ScreenGui"); LoadGui.Name = "MofenkLoadingGui"; LoadGui.Parent = parentGui; LoadGui.ResetOnSpawn = false
LoadGui.DisplayOrder = 100000

local LoadFrame = Instance.new("Frame"); LoadFrame.Parent = LoadGui; LoadFrame.Size = UDim2.new(0, 320, 0, 110); LoadFrame.AnchorPoint = Vector2.new(0.5, 0.5); LoadFrame.Position = UDim2.new(0.5, 0, 0.5, 0); LoadFrame.BackgroundColor3 = THEMES[1].Card
local LFCorner = Instance.new("UICorner"); LFCorner.CornerRadius = UDim.new(0, 14); LFCorner.Parent = LoadFrame
local LFStroke = Instance.new("UIStroke"); LFStroke.Thickness = 2; LFStroke.Parent = LoadFrame; table.insert(ThemeElements.Acc1, LFStroke)

local LoadTitle = Instance.new("TextLabel"); LoadTitle.Parent = LoadFrame; LoadTitle.Size = UDim2.new(1, 0, 0, 40); LoadTitle.Text = "👑 MOFENKHUB PRO"; LoadTitle.Font = Enum.Font.GothamBlack; LoadTitle.TextSize = 16; LoadTitle.TextColor3 = Color3.fromRGB(255, 255, 255); LoadTitle.BackgroundTransparency = 1

local LoadBarBg = Instance.new("Frame"); LoadBarBg.Parent = LoadFrame; LoadBarBg.Size = UDim2.new(0.85, 0, 0, 12); LoadBarBg.AnchorPoint = Vector2.new(0.5, 0); LoadBarBg.Position = UDim2.new(0.5, 0, 0.55, 0); LoadBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
local LBBgC = Instance.new("UICorner"); LBBgC.CornerRadius = UDim.new(1, 0); LBBgC.Parent = LoadBarBg

local LoadBarFill = Instance.new("Frame"); LoadBarFill.Parent = LoadBarBg; LoadBarFill.Size = UDim2.new(0, 0, 1, 0); LoadBarFill.BackgroundColor3 = THEMES[1].Acc1; table.insert(ThemeElements.Acc1, LoadBarFill)
local LBFC = Instance.new("UICorner"); LBFC.CornerRadius = UDim.new(1, 0); LBFC.Parent = LoadBarFill

local LoadStatus = Instance.new("TextLabel"); LoadStatus.Parent = LoadFrame; LoadStatus.Size = UDim2.new(1, 0, 0, 25); LoadStatus.Position = UDim2.new(0, 0, 0.75, 0); LoadStatus.Text = "Memuat modul game..."; LoadStatus.Font = Enum.Font.Medium; LoadStatus.TextSize = 10; LoadStatus.TextColor3 = Color3.fromRGB(180, 180, 180); LoadStatus.BackgroundTransparency = 1

TweenService:Create(LoadBarFill, TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
task.wait(1.4)
TweenService:Create(LoadFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
task.wait(0.4)
LoadGui:Destroy()

-- ===================================================================== --
-- 4. INTERACTIVE "M" LOGO TOGGLE & AUTO-SCALE RESPONSIF
-- ===================================================================== --
local ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "MofenkToggleFront"; ToggleGui.Parent = parentGui; ToggleGui.ResetOnSpawn = false
ToggleGui.DisplayOrder = 99999

local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = ToggleGui; ToggleBtn.Size = UDim2.new(0, 55, 0, 55); ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = THEMES[1].Card; ToggleBtn.Text = "M"; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 28; ToggleBtn.TextColor3 = THEMES[1].Acc1; ToggleBtn.ZIndex = 99999
local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 14); TC.Parent = ToggleBtn
local TS = Instance.new("UIStroke"); TS.Thickness = 2.5; TS.Parent = ToggleBtn; table.insert(ThemeElements.Acc1, TS)

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
		ToggleBtn.Position = UDim2.new(0, math.clamp(startPos.X.Offset + delta.X, 10, viewport.X - 65), 0, math.clamp(startPos.Y.Offset + delta.Y, 10, viewport.Y - 65))
	end
end)

-- ===================================================================== --
-- 5. MAIN AESTHETIC UI SETUP & UISCALE (AUTO-SCALE MULTI-ACCOUNT)
-- ===================================================================== --
local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkUltraHub"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false

-- Menambahkan Auto-Scale (UIScale) agar menyesuaikan ukuran jendela Roblox yang dikecilkan saat multi-akun AFK
local ScreenScale = Instance.new("UIScale"); ScreenScale.Parent = MainGui
local function UpdateScale()
	local viewport = workspace.CurrentCamera.ViewportSize
	-- Skalabilitas otomatis mendeteksi lebar layar, ideal untuk multi-instance berukuran kecil
	local scaleFactor = math.clamp(viewport.X / 1280, 0.65, 1.1)
	ScreenScale.Scale = scaleFactor
end
UpdateScale()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)

local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui; MainFrame.Size = UDim2.new(0, 900, 0, 580); MainFrame.Position = UDim2.new(0.5, -450, 0.5, -290)
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.BackgroundTransparency = 0.15; table.insert(ThemeElements.Bg, MainFrame)
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 16); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 3; MainStroke.Parent = MainFrame
local StrokeGrad = Instance.new("UIGradient"); StrokeGrad.Parent = MainStroke; table.insert(ThemeElements.Grad, StrokeGrad)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 48); TopBar.BackgroundTransparency = 0.2; table.insert(ThemeElements.Header, TopBar)
local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 20, 0, 0); Title.Size = UDim2.new(0, 500, 1, 0); Title.Text = "👑 MOFENKHUB V89.0  |  ANIME DICE PRO"; Title.TextSize = 14; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, Title)

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -42, 0, 9); CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(255,255,255); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BackgroundTransparency = 0.2; table.insert(ThemeElements.Card, CloseBtn)
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 8); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = MainFrame; Sidebar.Position = UDim2.new(0, 10, 0, 56); Sidebar.Size = UDim2.new(0, 180, 1, -66); Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 2; Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y; Sidebar.CanvasSize = UDim2.new(0,0,0,0)
local SideLayout = Instance.new("UIListLayout"); SideLayout.Parent = Sidebar; Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y; SideLayout.Padding = UDim.new(0, 5)

local ContentArea = Instance.new("Frame"); ContentArea.Parent = MainFrame; ContentArea.Position = UDim2.new(0, 200, 0, 56); ContentArea.Size = UDim2.new(1, -210, 1, -66); ContentArea.BackgroundTransparency = 0.3; table.insert(ThemeElements.Header, ContentArea)
local ContentCorner = Instance.new("UICorner"); ContentCorner.CornerRadius = UDim.new(0, 12); ContentCorner.Parent = ContentArea

local TabFrames, TabButtons = {}, {}
local function CreateTab(name, icon)
	local Btn = Instance.new("TextButton"); Btn.Parent = Sidebar; Btn.Size = UDim2.new(1, -4, 0, 36); Btn.Text = "  " .. icon .. "  " .. name; Btn.TextColor3 = Color3.fromRGB(220,220,220); Btn.TextSize = 11; Btn.Font = Enum.Font.GothamBold; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.BackgroundTransparency = 0.3; table.insert(ThemeElements.Card, Btn)
	local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 8); Corner.Parent = Btn
	local Scroll = Instance.new("ScrollingFrame"); Scroll.Parent = ContentArea; Scroll.Size = UDim2.new(1, -16, 1, -16); Scroll.Position = UDim2.new(0, 8, 0, 8); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 3; Scroll.Visible = false; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.CanvasSize = UDim2.new(0,0,0,0)
	local Lay = Instance.new("UIListLayout"); Lay.Parent = Scroll; Scroll.ScrollingDirection = Enum.ScrollingDirection.Y; Lay.Padding = UDim.new(0, 10)
	TabFrames[name] = Scroll; TabButtons[name] = Btn
	
	Btn.MouseButton1Click:Connect(function()
		for n, f in pairs(TabFrames) do f.Visible = (n == name) end
		for _, b in pairs(TabButtons) do b.BackgroundTransparency = 0.3; b.TextColor3 = Color3.fromRGB(220,220,220); for i,v in ipairs(ThemeElements.Acc1) do if v==b then table.remove(ThemeElements.Acc1, i) end end end
		Btn.BackgroundTransparency = 0; table.insert(ThemeElements.Acc1, Btn); ApplyTheme(F.themeIndex); Btn.TextColor3 = Color3.fromRGB(255,255,255)
	end)
	return Scroll
end

local function AddGroup(parent, title)
	local GroupCard = Instance.new("Frame"); GroupCard.Parent = parent; GroupCard.Size = UDim2.new(1, 0, 0, 0); GroupCard.AutomaticSize = Enum.AutomaticSize.Y; GroupCard.BackgroundTransparency = 0.2; table.insert(ThemeElements.Card, GroupCard)
	local GC = Instance.new("UICorner"); GC.CornerRadius = UDim.new(0, 10); GC.Parent = GroupCard
	local GS = Instance.new("UIStroke"); GS.Thickness = 1; GS.Transparency = 0.7; GS.Parent = GroupCard; table.insert(ThemeElements.Acc1, GS)
	local GLayout = Instance.new("UIListLayout"); GLayout.Parent = GroupCard; GLayout.Padding = UDim.new(0, 6); GLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local GPadding = Instance.new("UIPadding"); GPadding.Parent = GroupCard; GPadding.PaddingTop = UDim.new(0, 8); GPadding.PaddingBottom = UDim.new(0, 8); GPadding.PaddingLeft = UDim.new(0, 8); GPadding.PaddingRight = UDim.new(0, 8)
	
	if title and title ~= "" then
		local HeaderLbl = Instance.new("TextLabel"); HeaderLbl.Parent = GroupCard; HeaderLbl.Size = UDim2.new(1, 0, 0, 24); HeaderLbl.Text = title; HeaderLbl.TextSize = 11; HeaderLbl.Font = Enum.Font.GothamBlack; HeaderLbl.TextXAlignment = Enum.TextXAlignment.Left; HeaderLbl.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, HeaderLbl)
	end
	return GroupCard
end

local function AddToggle(parent, text, flag, callback)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 36); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.7, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 11; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Sw = Instance.new("TextButton"); Sw.Parent = Frm; Sw.Position = UDim2.new(1, -44, 0.5, -11); Sw.Size = UDim2.new(0, 38, 0, 22); Sw.Text = ""; Sw.BackgroundColor3 = F[flag] and THEMES[1].Acc1 or Color3.fromRGB(45,45,55); local SwC = Instance.new("UICorner"); SwC.CornerRadius = UDim.new(1, 0); SwC.Parent = Sw
	local Knob = Instance.new("Frame"); Knob.Parent = Sw; Knob.Size = UDim2.new(0, 18, 0, 18); Knob.Position = F[flag] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9); Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1, 0); KC.Parent = Knob
	if F[flag] then table.insert(ThemeElements.Acc1, Sw) end
	Sw.MouseButton1Click:Connect(function()
		F[flag] = not F[flag]
		TweenService:Create(Knob, TweenInfo.new(0.2), {Position = F[flag] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
		if F[flag] then table.insert(ThemeElements.Acc1, Sw); ApplyTheme(F.themeIndex) else for i,v in ipairs(ThemeElements.Acc1) do if v==Sw then table.remove(ThemeElements.Acc1,i) end end; Sw.BackgroundColor3 = Color3.fromRGB(45,45,55) end
		if callback then pcall(callback, F[flag]) end
	end)
end

local function AddInput(parent, text, flag, isNum)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 36); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.5, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 11; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Box = Instance.new("TextBox"); Box.Parent = Frm; Box.Position = UDim2.new(0.5, 0, 0.1, 0); Box.Size = UDim2.new(0.48, 0, 0.8, 0); Box.Text = tostring(F[flag] or ""); table.insert(ThemeElements.TextAcc, Box); Box.TextSize = 11; Box.Font = Enum.Font.GothamBold; Box.BackgroundTransparency = 0.2; table.insert(ThemeElements.Header, Box); local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 6); BC.Parent = Box
	Box.FocusLost:Connect(function() F[flag] = isNum and (tonumber(Box.Text) or 0) or Box.Text end)
end

local function AddDropdown(parent, title, options, flag, isMulti)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 38); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.4, 0, 1, 0); L.Text = title; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 11; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Btn = Instance.new("TextButton"); Btn.Parent = Frm; Btn.Position = UDim2.new(0.42, 0, 0.1, 0); Btn.Size = UDim2.new(0.56, 0, 0.8, 0); Btn.Text = isMulti and (#(F[flag] or {}) .. " Terpilih") or tostring(F[flag] or "Select"); table.insert(ThemeElements.TextAcc, Btn); Btn.TextSize = 10; Btn.Font = Enum.Font.GothamBold; Btn.BackgroundTransparency = 0.2; table.insert(ThemeElements.Header, Btn); local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 6); BC.Parent = Btn
	
	local DropList = Instance.new("ScrollingFrame"); DropList.Parent = MainFrame; DropList.Size = UDim2.new(0, 220, 0, 150); table.insert(ThemeElements.Bg, DropList); DropList.BorderSizePixel = 1; DropList.Visible = false; DropList.ZIndex = 150; DropList.ScrollBarThickness = 4; DropList.AutomaticCanvasSize = Enum.AutomaticSize.Y; DropList.CanvasSize = UDim2.new(0,0,0,0)
	local DLC = Instance.new("UICorner"); DLC.CornerRadius = UDim.new(0, 8); DLC.Parent = DropList; local DLL = Instance.new("UIListLayout"); DLL.Parent = DropList
	
	local function UpdatePos()
		if DropList.Visible then DropList.Position = UDim2.new(0, Btn.AbsolutePosition.X - MainFrame.AbsolutePosition.X, 0, (Btn.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y) + Btn.AbsoluteSize.Y + 2) end
	end
	Btn:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos)

	local function Render(opts)
		for _, v in pairs(DropList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
		for _, opt in ipairs(opts) do
			local OptBtn = Instance.new("TextButton"); OptBtn.Parent = DropList; OptBtn.Size = UDim2.new(1, 0, 0, 30); OptBtn.Text = "  " .. tostring(opt.label); OptBtn.TextColor3 = Color3.fromRGB(255,255,255); OptBtn.TextSize = 10; OptBtn.Font = Enum.Font.GothamMedium; OptBtn.TextXAlignment = Enum.TextXAlignment.Left; OptBtn.BackgroundTransparency = 1; OptBtn.ZIndex = 151
			local check = Instance.new("Frame"); check.Parent = OptBtn; check.Size = UDim2.new(0, 12, 0, 12); check.Position = UDim2.new(1, -20, 0.5, -6); local cc = Instance.new("UICorner"); cc.Parent = check; check.ZIndex = 151
			local function updateVisuals()
				local sel = false
				if isMulti then for _,v in ipairs(F[flag]) do if v==opt.val then sel=true break end end else sel=(F[flag]==opt.val) end
				if sel then table.insert(ThemeElements.Acc1, check) else for i,v in ipairs(ThemeElements.Acc1) do if v==check then table.remove(ThemeElements.Acc1,i) end end; check.BackgroundColor3 = Color3.fromRGB(45,45,55) end
				ApplyTheme(F.themeIndex)
			end
			updateVisuals()
			OptBtn.MouseButton1Click:Connect(function()
				if isMulti then
					local found = false; for i,v in ipairs(F[flag]) do if v==opt.val then table.remove(F[flag],i); found=true break end end
					if not found then table.insert(F[flag], opt.val) end; Btn.Text = #(F[flag]).." Terpilih"
				else F[flag] = opt.val; Btn.Text = opt.label; DropList.Visible = false end
				updateVisuals()
			end)
		end
	end
	Render(options)
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
	end
	return t
end

-- ===================================================================== --
-- 6. 8 TABS ASSEMBLY
-- ===================================================================== --
local T_Dash = CreateTab("Dashboard", "📊")
local T_Farm = CreateTab("Farming", "⛏️")
local T_Inv = CreateTab("Inventory", "🎒")
local T_Pot = CreateTab("Potions", "🧪")
local T_Grd = CreateTab("Auto Grade", "⭐")
local T_Trt = CreateTab("Auto Trait", "🧬")
local T_Twr = CreateTab("Tower", "🏰")
local T_Set = CreateTab("Settings", "⚙️")

TabFrames["Dashboard"].Visible = true; Sidebar:GetChildren()[2].BackgroundTransparency = 0; table.insert(ThemeElements.Acc1, Sidebar:GetChildren()[2])

-- 1. DASHBOARD
local G_Profile = AddGroup(T_Dash, "PROFIL & STATISTIK PENGGUNA")
local ProfContainer = Instance.new("Frame"); ProfContainer.Parent = G_Profile; ProfContainer.Size = UDim2.new(1, 0, 0, 80); ProfContainer.BackgroundTransparency = 1
local PImg = Instance.new("ImageLabel"); PImg.Parent = ProfContainer; PImg.AnchorPoint = Vector2.new(0.5, 0.5); PImg.Position = UDim2.new(0.15, 0, 0.5, 0); PImg.Size = UDim2.new(0, 64, 0, 64); pcall(function() PImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end); local PImgC = Instance.new("UICorner"); PImgC.CornerRadius = UDim.new(1,0); PImgC.Parent = PImg; local PStr = Instance.new("UIStroke"); PStr.Thickness = 2; PStr.Parent = PImg; table.insert(ThemeElements.Acc1, PStr)

local PLbl = Instance.new("TextLabel"); PLbl.Parent = ProfContainer; PLbl.Position = UDim2.new(0.3, 0, 0, 5); PLbl.Size = UDim2.new(0.7, 0, 1, 0); PLbl.BackgroundTransparency = 1; PLbl.TextColor3 = Color3.fromRGB(255,255,255); PLbl.TextSize = 11; PLbl.Font = Enum.Font.GothamMedium; PLbl.TextXAlignment = Enum.TextXAlignment.Left; PLbl.TextYAlignment = Enum.TextYAlignment.Center

local G_Spy = AddGroup(T_Dash, "SPY INVENTORY & BUFFS")
local SLbl = Instance.new("TextLabel"); SLbl.Parent = G_Spy; SLbl.Size = UDim2.new(1, 0, 0, 80); SLbl.BackgroundTransparency = 1; SLbl.TextColor3 = Color3.fromRGB(255,255,255); SLbl.TextSize = 11; SLbl.Font = Enum.Font.GothamMedium; SLbl.TextXAlignment = Enum.TextXAlignment.Left; SLbl.TextYAlignment = Enum.TextYAlignment.Top

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
AddToggle(G_Farm1, "Auto Rebirth (Anti-Spam)", "rebirth")

local G_Farm2 = AddGroup(T_Farm, "LEVELING & UPGRADES")
AddToggle(G_Farm2, "Auto Level Up Unit", "levelup")
AddInput(G_Farm2, "Max Level Batas:", "maxLevel", true)
AddToggle(G_Farm2, "Auto Upgrade Skill Tree", "upgrades")

-- 3. INVENTORY
local G_Inv = AddGroup(T_Inv, "MANAGEMENT & AUTO SELL")
AddToggle(G_Inv, "Auto Sell Unit (Tanpa Rarity Filter)", "sellAuto")
AddInput(G_Inv, "Simpan Unit Terbaik (Keep Best):", "keepBest", true)
AddToggle(G_Inv, "Auto Fusion Unit", "autoFuse")

-- 4. POTIONS
local G_Pot = AddGroup(T_Pot, "SMART POTION MANAGER")
AddToggle(G_Pot, "Auto Gunakan Potion", "potionAuto")
AddDropdown(G_Pot, "Pilih Potion Spesifik:", GetOpts("pot"), "potionSpecific", true)

-- 5. AUTO GRADE
local G_Grd = AddGroup(T_Grd, "GRADE REROLL CONFIG")
AddToggle(G_Grd, "Aktifkan Auto Grade", "gradeAuto")
AddToggle(G_Grd, "Hanya Unit di Base (Placed)", "gradePlacedOnly")
AddDropdown(G_Grd, "Target Grade (Lewati Protected):", GetOpts("grade"), "gradeTargets", true)
AddDropdown(G_Grd, "Pilih Unit Spesifik:", GetOpts("unit"), "gradeUnits", true)
AddInput(G_Grd, "Sisakan Gems:", "gemReserve", true)

-- 6. AUTO TRAIT
local G_Trt = AddGroup(T_Trt, "TRAIT REROLL CONFIG")
AddToggle(G_Trt, "Aktifkan Auto Trait", "traitAuto")
AddToggle(G_Trt, "Hanya Unit di Base (Placed)", "traitPlacedOnly")
AddDropdown(G_Trt, "Target Trait (Lewati Protected):", GetOpts("trait"), "traitTargets", true)
AddDropdown(G_Trt, "Pilih Unit Spesifik:", GetOpts("unit"), "traitUnits", true)
AddInput(G_Trt, "Sisakan Trait Item:", "rerollReserve", true)

-- 7. TOWER
local G_Twr = AddGroup(T_Twr, "TOWER FARMING SETUP")
AddToggle(G_Twr, "Auto Tower Farming", "tower")
AddToggle(G_Twr, "Mode MIX / Random Tower", "towerMix")
AddDropdown(G_Twr, "Pilih Tower Spesifik:", {{label="Dragon Tower", val="Dragon Tower"},{label="Cursed Tower", val="Cursed Tower"},{label="Pirate Tower", val="Pirate Tower"},{label="Infinity Tower", val="Infinity Tower"}}, "towerName", false)
AddToggle(G_Twr, "Keluar di Lantai Tertentu", "towerExitOn")
AddInput(G_Twr, "Lantai Exit:", "towerExitFloor", true)

local G_TwrMon = AddGroup(T_Twr, "LIVE TOWER MONITORING & TRAIT")
local TwrLbl = Instance.new("TextLabel"); TwrLbl.Parent = G_TwrMon; TwrLbl.Size = UDim2.new(1,0,0,70); TwrLbl.BackgroundTransparency = 1; TwrLbl.TextColor3 = Color3.fromRGB(255,255,255); TwrLbl.TextSize = 11; TwrLbl.Font = Enum.Font.GothamMedium; TwrLbl.TextXAlignment = Enum.TextXAlignment.Left; TwrLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function() while task.wait(0.5) do pcall(function() TwrLbl.Text = string.format("🎮 Status: %s\n🏢 Lantai: %d | 💎 Gems Didapat: %d\n🧬 Trait Didapat: %s", STATE.towerLive, STATE.towerFloor, STATE.towerDrops, tostring(STATE.towerTraitsGot)) end) end end)

-- 8. SETTINGS & CONFIG LIST MANAGER (DENGAN AUTO-LOAD ON/OFF)
local G_Set1 = AddGroup(T_Set, "TEMA & WARNA (NEON GLOW)")
local BtnTheme = Instance.new("TextButton"); BtnTheme.Parent = G_Set1; BtnTheme.Size = UDim2.new(1, 0, 0, 34); BtnTheme.Text = "🎲 ACAK TEMA WARNA"; BtnTheme.Font = Enum.Font.GothamBlack; BtnTheme.TextSize = 11; table.insert(ThemeElements.Card, BtnTheme); table.insert(ThemeElements.TextAcc, BtnTheme); local BTC = Instance.new("UICorner"); BTC.CornerRadius = UDim.new(0,6); BTC.Parent = BtnTheme
BtnTheme.MouseButton1Click:Connect(function() F.themeIndex = math.random(1, #THEMES); ApplyTheme(F.themeIndex) end)

local G_SetConfig = AddGroup(T_Set, "CONFIG & FILE MANAGER")
AddToggle(G_SetConfig, "Auto Load Config Saat Nyala", "autoLoadEnabled")
AddInput(G_SetConfig, "Nama File Config:", "cfgName", false)

local BtnSave = Instance.new("TextButton"); BtnSave.Parent = G_SetConfig; BtnSave.Size = UDim2.new(1, 0, 0, 32); BtnSave.Text = "💾 SAVE CONFIG SEKARANG"; BtnSave.Font = Enum.Font.GothamBold; BtnSave.TextSize = 11; table.insert(ThemeElements.Header, BtnSave); table.insert(ThemeElements.TextAcc, BtnSave); local BTS = Instance.new("UICorner"); BTS.CornerRadius = UDim.new(0,6); BTS.Parent = BtnSave
BtnSave.MouseButton1Click:Connect(function() pcall(function() saveConfig(F.cfgName) end) end)

local BtnLoad = Instance.new("TextButton"); BtnLoad.Parent = G_SetConfig; BtnLoad.Size = UDim2.new(1, 0, 0, 32); BtnLoad.Text = "📂 LOAD CONFIG PILIHAN"; BtnLoad.Font = Enum.Font.GothamBold; BtnLoad.TextSize = 11; table.insert(ThemeElements.Header, BtnLoad); table.insert(ThemeElements.TextAcc, BtnLoad); local BTL = Instance.new("UICorner"); BTL.CornerRadius = UDim.new(0,6); BTL.Parent = BtnLoad
BtnLoad.MouseButton1Click:Connect(function() pcall(function() loadConfig(F.cfgName); ApplyTheme(F.themeIndex) end) end)

local BtnDelete = Instance.new("TextButton"); BtnDelete.Parent = G_SetConfig; BtnDelete.Size = UDim2.new(1, 0, 0, 32); BtnDelete.Text = "🗑️ DELETE CONFIG PILIHAN"; BtnDelete.Font = Enum.Font.GothamBold; BtnDelete.TextSize = 11; BtnDelete.TextColor3 = Color3.fromRGB(255, 60, 60); table.insert(ThemeElements.Header, BtnDelete); local BTD = Instance.new("UICorner"); BTD.CornerRadius = UDim.new(0,6); BTD.Parent = BtnDelete
BtnDelete.MouseButton1Click:Connect(function()
	pcall(function()
		local path = getCfgPath(F.cfgName)
		if delfile and isfile and isfile(path) then
			delfile(path)
		end
	end)
end)

local ListTitle = Instance.new("TextLabel"); ListTitle.Parent = G_SetConfig; ListTitle.Size = UDim2.new(1, 0, 0, 20); ListTitle.Text = "📁 PILIH CONFIG TERSEDIA:"; ListTitle.TextSize = 10; ListTitle.Font = Enum.Font.GothamBold; ListTitle.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, ListTitle)

local ConfigScroll = Instance.new("ScrollingFrame"); ConfigScroll.Parent = G_SetConfig; ConfigScroll.Size = UDim2.new(1, 0, 0, 90); ConfigScroll.BackgroundTransparency = 0.3; table.insert(ThemeElements.Header, ConfigScroll); ConfigScroll.ScrollBarThickness = 4; ConfigScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; ConfigScroll.CanvasSize = UDim2.new(0,0,0,0)
local CSC = Instance.new("UICorner"); CSC.CornerRadius = UDim.new(0, 6); CSC.Parent = ConfigScroll
local ConfigLayout = Instance.new("UIListLayout"); ConfigLayout.Parent = ConfigScroll; ConfigLayout.Padding = UDim.new(0, 4)

local function RefreshConfigList()
	for _, v in pairs(ConfigScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
	if listfiles then
		pcall(function()
			for _, file in ipairs(listfiles(CFG_FOLDER)) do
				local fileName = file:match("([^/]+)$"):gsub("%.json$", "")
				local FileBtn = Instance.new("TextButton"); FileBtn.Parent = ConfigScroll; FileBtn.Size = UDim2.new(1, 0, 0, 26); FileBtn.Text = "📄 " .. fileName; FileBtn.TextSize = 10; FileBtn.Font = Enum.Font.GothamMedium; FileBtn.TextColor3 = Color3.fromRGB(255,255,255); FileBtn.BackgroundTransparency = 0.2; table.insert(ThemeElements.Card, FileBtn)
				local FBC = Instance.new("UICorner"); FBC.CornerRadius = UDim.new(0, 4); FBC.Parent = FileBtn
				FileBtn.MouseButton1Click:Connect(function()
					pcall(function()
						F.cfgName = fileName
						loadConfig(fileName)
						ApplyTheme(F.themeIndex)
					end)
				end)
			end
		end)
	end
end
RefreshConfigList()

local BtnRefresh = Instance.new("TextButton"); BtnRefresh.Parent = G_SetConfig; BtnRefresh.Size = UDim2.new(1, 0, 0, 28); BtnRefresh.Text = "🔄 REFRESH LIST CONFIG"; BtnRefresh.Font = Enum.Font.GothamBold; BtnRefresh.TextSize = 10; table.insert(ThemeElements.Card, BtnRefresh); table.insert(ThemeElements.TextAcc, BtnRefresh); local BTR = Instance.new("UICorner"); BTR.CornerRadius = UDim.new(0,6); BTR.Parent = BtnRefresh
BtnRefresh.MouseButton1Click:Connect(RefreshConfigList)

local G_Set2 = AddGroup(T_Set, "OPTIMALISASI & TOOLS")
AddToggle(G_Set2, "Anti-AFK (Cegah Disconnect)", "afk")
AddToggle(G_Set2, "FPS Boost (Hapus Partikel Map)", "fpsOn", function(v) if v then pcall(function() game:GetService("Lighting").GlobalShadows = false; for _,e in ipairs(workspace:GetDescendants()) do if e:IsA("BasePart") then e.Material = Enum.Material.SmoothPlastic end end end) end end)
AddToggle(G_Set2, "Auto Claim Quests & Daily", "claimQuests")
AddToggle(G_Set2, "Auto Redeem Codes", "codesAuto")

local BtnHop = Instance.new("TextButton"); BtnHop.Parent = G_Set2; BtnHop.Size = UDim2.new(1, 0, 0, 34); BtnHop.Text = "🌐 SERVER HOP (PINDAH SERVER)"; BtnHop.Font = Enum.Font.GothamBlack; BtnHop.TextSize = 11; table.insert(ThemeElements.Card, BtnHop); table.insert(ThemeElements.TextAcc, BtnHop); local BTH = Instance.new("UICorner"); BTH.CornerRadius = UDim.new(0,6); BTH.Parent = BtnHop

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

-- ===================================================================== --
-- 7. FULL BACKEND THREADS (ANTI-RELOG STABIL & AMAN)
-- ===================================================================== --
ApplyTheme(F.themeIndex)

-- Cek apakah Auto Load Config Diaktifkan
if F.autoLoadEnabled then
	pcall(function() loadConfig(F.cfgName); ApplyTheme(F.themeIndex) end)
end

-- Anti-AFK Aman & Stabil (Simulasi VirtualUser klik tombol mouse agar tidak keluar otomatis setiap 20 menit)
LocalPlayer.Idled:Connect(function()
	if F.afk then
		pcall(function()
			local vu = game:GetService("VirtualUser")
			if vu then 
				vu:CaptureController()
				vu:ClickButton1(Vector2.new(0,0), workspace.CurrentCamera.CFrame) 
			end
		end)
	end
end)

task.spawn(function()
	while task.wait(120) do
		if F.afk then
			pcall(function()
				local vu = game:GetService("VirtualUser")
				if vu then 
					vu:CaptureController()
					vu:ClickButton1(Vector2.new(0,0), workspace.CurrentCamera.CFrame) 
				end
			end)
		end
	end
end)

local function unlockedSlots() local arr={}; local rb = rebirthAmt(); pcall(function() for i=1, (G.PlotConfig.GetMaxSlots(rb) or 15) do if rb >= (G.PlotConfig.GetSlotRebirthRequirement(i) or 0) then table.insert(arr, i) end end end); return arr end

-- Auto Roll Thread (Cooldown 2.1 detik)
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.autoRoll then
			pcall(function()
				if R.RollDice then
					local ok = pcall(function() return R.RollDice:InvokeServer() end)
					if ok then STATE.rolled = (STATE.rolled or 0) + 1 end
				end
			end)
			task.wait(2.1)
		else
			task.wait(1)
		end
	end
end)

-- Auto Sell Thread
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

local towerList = {"Dragon Tower", "Cursed Tower", "Pirate Tower", "Infinity Tower"}
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.tower and R.PlayTower and R.CompleteFloor then
			if F.towerEquipBest and R.BestTowerTeam then pcall(function() R.BestTowerTeam:FireServer() end) end
			task.wait(0.5)
			local pickTower = F.towerMix and towerList[math.random(1, #towerList)] or F.towerName
			STATE.towerLive = "Memulai: " .. pickTower; STATE.towerDrops = 0; STATE.towerTraitsGot = "Mencari..."
			local okStart, started = pcall(function() return R.PlayTower:InvokeServer(pickTower) end)
			if okStart and started then
				local done, fails = false, 0
				while F.tower and not done do
					local okP, seq = pcall(function() return R.CompleteFloor:InvokeServer() end)
					if okP and type(seq) == "table" and #seq > 0 then
						fails = 0
						for _, act in ipairs(seq) do
							if act.action == "floorStarted" then STATE.towerFloor = tonumber(act.floor) or 1
							elseif act.action == "floorCompleted" then
								if act.rewards and act.rewards.Gems then STATE.towerDrops += act.rewards.Gems end
								if act.rewards and act.rewards.Trait or act.trait then
									STATE.towerTraitsGot = tostring(act.rewards.Trait or act.trait)
								end
							elseif act.action == "ended" then done = true break end
						end
						if not done and F.towerExitOn and F.towerExitFloor > 0 and STATE.towerFloor >= F.towerExitFloor then
							done = true; pcall(function() R.CancelTower:InvokeServer() end)
						end
					else fails += 1; if fails > 8 then done = true end; task.wait(1) end
				end
			end
		else STATE.towerLive = "Standby"; STATE.towerTraitsGot = "Belum Ada"; task.wait(2) end
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
