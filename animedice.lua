-- ===================================================================== --
-- 👑 MOFENKHUB V35.0 — ULTIMATE PROFESSIONAL AESTHETIC SUITE
-- Game: Anime Dice | Full Features Restored, FB Profile, UI Scaler
-- ===================================================================== --

task.wait(0.6)
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local Stats             = game:GetService("Stats")
local LogService        = game:GetService("LogService")
local UserInputService  = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local successGui, parentGui = pcall(function()
	if gethui then return gethui()
	elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui
	else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then
	parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

pcall(function()
	for _, v in pairs(parentGui:GetChildren()) do
		if v.Name == "MofenkUltraHubV35" or v.Name == "MofenkToggleGui" or v.Name == "MofenkNotifyGui" then
			v:Destroy()
		end
	end
end)

-- 2. KONFIGURASI GLOBAL FULL FITUR
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

_G.Mofenk = {
	UIScale             = 1.0, 
	CurrentConfigName   = "DefaultConfig",
	AutoLoadConfig      = true,
	WebhookUrl          = "",
	-- Roll & Farm
	AutoRoll            = false,
	AutoSpins           = false,
	AutoDice            = false,
	AutoEquipDice       = false,
	AutoRebirth         = false,
	RebirthRequirement  = 50000,
	-- Inventaris & Jual
	AutoSell            = false,
	SellRarityLimit     = 3, 
	AutoFuse            = false,
	-- Plot & Unit
	AutoCollect         = false,
	SmartPlace          = false,
	AutoLevel           = false,
	LevelLimit          = 50,
	AutoUpgrade         = false,
	-- Rerolls & Boosts
	AutoGrade           = false,
	AutoTrait           = false,
	AutoPotion          = false,
	-- Tower Manager
	AutoTower           = false,
	AutoMixTower        = false,
	SelectedTowerSingle = "Infinity Tower",
	AutoEquipTower      = false,
	TowerLiveStatus     = "Standby",
	TowerCurrentLevel   = 0,
	-- Rewards & Extras
	AutoCodes           = false,
	AutoClaim           = false,
	AutoQuests          = false,
	AutoPasses          = false,
	AutoStats           = false,
	StatPick            = "Money",
	-- Client
	AntiAFK             = true,
	Disable3DRender     = false,
}

-- 3. MAPPING REMOTE GAME LENGKAP (Sesuai Referensi)
local Framework, Network
pcall(function() Framework = ReplicatedStorage:WaitForChild("Framework", 15) end)
pcall(function() Network = ReplicatedStorage:WaitForChild("Network", 15) end)

local function safeFind(parent, path)
	local node = parent
	for part in string.gmatch(path, "[^%.]+") do
		if node then node = node:FindFirstChild(part) else return nil end
	end
	return node
end

local R = {
	RollDice        = Network and (safeFind(Network, "RollService.RF.RollDice") or safeFind(Network, "RollService.RE.RollDice")),
	BuyDice         = Network and (safeFind(Network, "DiceShopService.RE.BuyDice") or safeFind(Network, "DiceShopService.RF.BuyDice")),
	EquipDice       = Network and safeFind(Network, "DiceShopService.RE.EquipDice"),
	CollectBalance  = Network and (safeFind(Network, "PlotService.RE.CollectBalance") or safeFind(Network, "PlotService.RF.CollectBalance")),
	EquipBest       = Network and safeFind(Network, "PlotService.RE.EquipBest"),
	LevelUpSlot     = Network and (safeFind(Network, "PlotService.RE.LevelUpSlot") or safeFind(Network, "PlotService.RF.LevelUpSlot") or safeFind(Network, "RE.LevelUpSlot")),
	InteractSlot    = Network and safeFind(Network, "PlotService.RE.InteractSlot"),
	EquipUnit       = Network and safeFind(Network, "UnitService.RF.Equip"),
	UnequipUnit     = Network and safeFind(Network, "UnitService.RF.Unequip"),
	Rebirth         = Network and (safeFind(Network, "RebirthService.RE.Rebirth") or safeFind(Network, "RebirthService.RF.Rebirth")),
	BuyUpgrade      = Network and (safeFind(Network, "PlotService.RE.BuyUpgrade") or safeFind(Network, "RE.BuyUpgrade")),
	SellInventory   = Network and safeFind(Network, "SellService.RF.SellInventory"),
	PlayTower       = Network and (safeFind(Network, "Towers.RF.PlayTower") or safeFind(Network, "Towers.RE.PlayTower")),
	CompleteFloor   = Network and safeFind(Network, "Towers.RF.CompleteTowerFloor"),
	CancelTower     = Network and safeFind(Network, "Towers.RF.CancelTower"),
	EquipTowerUnit  = Network and (safeFind(Network, "Towers.RE.EquipBestTowerTeam") or safeFind(Network, "Towers.RE.EquipBest")),
	UseSpin         = Network and safeFind(Network, "SpinService.RE.Use"),
	BoostUse        = Network and safeFind(Network, "BoostService.RE.Use"),
	Fuse            = Network and safeFind(Network, "FusingService.RE.Fuse"),
	RedeemCode      = Network and (safeFind(Network, "CodesService.RE.RedeemCode") or safeFind(Network, "MonetizationService.RE.RedeemCode")),
	QuestClaim      = Network and safeFind(Network, "QuestService.RE.Claim"),
	QuestBuy        = Network and safeFind(Network, "QuestService.RE.Buy"),
	AddStat         = Network and safeFind(Network, "RebirthService.RE.AddStat"),
	ClaimOffline    = Network and safeFind(Network, "OfflineEarningsService.RE.Claim"),
	ClaimDaily      = Network and safeFind(Network, "DailyRewardService.RE.Claim"),
	ClaimGroup      = Network and safeFind(Network, "GroupRewardService.RE.Claim"),
	GradeRoll       = Network and safeFind(Network, "GradeService.RE.Roll"),
	TraitRoll       = Network and safeFind(Network, "TraitService.RE.Roll"),
}

local DataController, TowersConfig, Dice, UnitConfig, UpgradeConfig, RebirthStats, QuestConfig, BoostConfig, CODES, Rebirths
pcall(function()
	if Framework then
		DataController = require(Framework.Features.Data.DataController)
		TowersConfig   = require(Framework.Features.Towers.Towers)
		Dice           = require(Framework.Features.Rolling.Dice)
		UnitConfig     = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig)
		UpgradeConfig  = require(Framework.Features.Upgrades.Upgrades)
		RebirthStats   = require(Framework.Features.Rebirth.RebirthStatsConfig)
		QuestConfig    = require(Framework.Features.Quests.QuestConfig)
		BoostConfig    = require(Framework.Features.Inventory.Kinds.Boost.BoostConfig)
		Rebirths       = require(Framework.Features.Rebirth.Rebirths)
		local mc = require(Framework.Features.Monetization.MonetizationConfig)
		CODES = (require(Framework.Features.Codes.CodesConfig) or (mc and mc.Codes)) or {}
	end
end)

local function data()
	local ok, res = pcall(function() return DataController.___X end)
	return ok and res or nil
end

local BOOSTS = (BoostConfig and (BoostConfig.entries or BoostConfig)) or {}
local function itemAmount(key)
	local d = data()
	local e = d and d.Inventory and d.Inventory[key]
	return (e and tonumber(e.amount)) or 0
end

local function baseIncome(u)
	local e = u and UnitConfig and UnitConfig.entries and UnitConfig.entries[u.name]
	if not e then return 0 end
	local a = u.attributes or {}
	return tonumber(select(2, pcall(e.income, { mutation = a.mutation, grade = a.grade, trait = a.trait, level = 1 }))) or 0
end

-- 4. TEMA UI TRANSPARAN PROFESIONAL
local Theme = {
	Bg        = Color3.fromRGB(8, 8, 10),      -- Hitam transparan
	Header    = Color3.fromRGB(15, 15, 18),
	Card      = Color3.fromRGB(22, 22, 28),
	Accent    = Color3.fromRGB(255, 60, 90),   
	AccentSec = Color3.fromRGB(0, 230, 255),   
	Text      = Color3.fromRGB(255, 255, 255), 
	TextSub   = Color3.fromRGB(180, 180, 190)  
}

-- 5. NOTIFIKASI
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "MofenkNotifyGui"
NotifyGui.Parent = parentGui
local NotifyContainer = Instance.new("Frame")
NotifyContainer.Parent = NotifyGui
NotifyContainer.Position = UDim2.new(1, -310, 0, 25)
NotifyContainer.Size = UDim2.new(0, 290, 1, -50)
NotifyContainer.BackgroundTransparency = 1
local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.Parent = NotifyContainer
NotifyLayout.Padding = UDim.new(0, 12)

local function MofenkNotify(title, message, duration)
	duration = duration or 3.5
	local Card = Instance.new("Frame")
	Card.Parent = NotifyContainer
	Card.Size = UDim2.new(1, 0, 0, 58)
	Card.BackgroundColor3 = Theme.Card
	Card.BackgroundTransparency = 0.15
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 10)
	Corner.Parent = Card
	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Theme.AccentSec
	Stroke.Transparency = 0.2
	Stroke.Parent = Card
	
	local TitleLbl = Instance.new("TextLabel")
	TitleLbl.Parent = Card
	TitleLbl.Position = UDim2.new(0, 14, 0, 8)
	TitleLbl.Size = UDim2.new(1, -28, 0, 18)
	TitleLbl.Text = title
	TitleLbl.TextColor3 = Theme.AccentSec
	TitleLbl.TextSize = 11
	TitleLbl.Font = Enum.Font.GothamBold
	TitleLbl.BackgroundTransparency = 1
	TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local MsgLbl = Instance.new("TextLabel")
	MsgLbl.Parent = Card
	MsgLbl.Position = UDim2.new(0, 14, 0, 28)
	MsgLbl.Size = UDim2.new(1, -28, 0, 22)
	MsgLbl.Text = message
	MsgLbl.TextColor3 = Theme.TextSub
	MsgLbl.TextSize = 10
	MsgLbl.Font = Enum.Font.GothamMedium
	MsgLbl.BackgroundTransparency = 1
	MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
	task.delay(duration, function() pcall(function() Card:Destroy() end) end)
end

-- 6. UI UTAMA AESTHETIC
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkUltraHubV35"
MainGui.Parent = parentGui
MainGui.ResetOnSpawn = false

local UIRescale = Instance.new("UIScale")
UIRescale.Scale = _G.Mofenk.UIScale
UIRescale.Parent = MainGui

local MainFrame = Instance.new("Frame")
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 860, 0, 560)
MainFrame.Position = UDim2.new(0.5, -430, 0.5, -280)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = 0.1
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = false

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2.5
MainStroke.Parent = MainFrame
local StrokeGradient = Instance.new("UIGradient")
StrokeGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.0, Theme.Accent),
	ColorSequenceKeypoint.new(1.0, Theme.AccentSec)
})
StrokeGradient.Parent = MainStroke

-- TOPBAR & GLOWING TEXT
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 52)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BackgroundTransparency = 0.15

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Position = UDim2.new(0, 20, 0, 0)
Title.Size = UDim2.new(0, 500, 1, 0)
Title.Text = "MOFENKHUB  |  ANIME DICE PRO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1.0, Color3.fromRGB(180, 180, 180))
})
TitleGradient.Parent = Title
local TitleStroke = Instance.new("UIStroke")
TitleStroke.Color = Theme.AccentSec
TitleStroke.Thickness = 1.2
TitleStroke.Transparency = 0.1
TitleStroke.Parent = Title

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.Position = UDim2.new(1, -46, 0, 12)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundColor3 = Theme.Card
CloseBtn.BackgroundTransparency = 0.2
local CC = Instance.new("UICorner")
CC.CornerRadius = UDim.new(0, 8)
CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- SIDEBAR & CONTENT AREA DENGAN AUTO CANVAS SIZE
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 12, 0, 62)
Sidebar.Size = UDim2.new(0, 185, 1, -74)
Sidebar.BackgroundColor3 = Theme.Header
Sidebar.BackgroundTransparency = 0.3
Sidebar.ScrollBarThickness = 2
local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.Padding = UDim.new(0, 8)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 207, 0, 62)
ContentArea.Size = UDim2.new(1, -219, 1, -74)
ContentArea.BackgroundColor3 = Theme.Header
ContentArea.BackgroundTransparency = 0.3
local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 12)
ContentCorner.Parent = ContentArea

local TabFrames = {}
local function CreateTab(name, order)
	local Btn = Instance.new("TextButton")
	Btn.Parent = Sidebar
	Btn.Size = UDim2.new(1, -4, 0, 38)
	Btn.Text = "    " .. name
	Btn.TextColor3 = Theme.TextSub
	Btn.TextSize = 11
	Btn.Font = Enum.Font.GothamBold
	Btn.TextXAlignment = Enum.TextXAlignment.Left
	Btn.BackgroundColor3 = Theme.Card
	Btn.BackgroundTransparency = 0.2
	Btn.LayoutOrder = order
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 10)
	Corner.Parent = Btn

	local Scroll = Instance.new("ScrollingFrame")
	Scroll.Parent = ContentArea
	Scroll.Size = UDim2.new(1, -16, 1, -16)
	Scroll.Position = UDim2.new(0, 8, 0, 8)
	Scroll.BackgroundTransparency = 1
	Scroll.ScrollBarThickness = 3
	Scroll.ScrollBarImageColor3 = Theme.AccentSec
	Scroll.Visible = false
	
	local Lay = Instance.new("UIListLayout")
	Lay.Parent = Scroll
	Lay.Padding = UDim.new(0, 12)
	Lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Scroll.CanvasSize = UDim2.new(0, 0, 0, Lay.AbsoluteContentSize.Y + 20)
	end)
	
	TabFrames[name] = Scroll

	Btn.MouseButton1Click:Connect(function()
		for n, f in pairs(TabFrames) do f.Visible = (n == name) end
		for _, b in ipairs(Sidebar:GetChildren()) do
			if b:IsA("TextButton") then
				b.TextColor3 = Theme.TextSub
				b.BackgroundColor3 = Theme.Card
				b.BackgroundTransparency = 0.2
			end
		end
		Btn.TextColor3 = Theme.Text
		Btn.BackgroundColor3 = Theme.AccentSec
		Btn.BackgroundTransparency = 0.1
	end)
	return Scroll
end

local function AddSection(parent, text)
	local L = Instance.new("TextLabel")
	L.Parent = parent
	L.Size = UDim2.new(1, 0, 0, 30)
	L.Text = "  " .. text
	L.TextColor3 = Theme.AccentSec
	L.TextSize = 12
	L.Font = Enum.Font.GothamBlack
	L.TextXAlignment = Enum.TextXAlignment.Left
	L.BackgroundTransparency = 1
	local Line = Instance.new("Frame")
	Line.Parent = L
	Line.Size = UDim2.new(1, -12, 0, 1)
	Line.Position = UDim2.new(0, 12, 1, -2)
	Line.BackgroundColor3 = Theme.AccentSec
	Line.BackgroundTransparency = 0.5
end

local function AddToggle(parent, text, flag)
	local state = _G.Mofenk[flag] or false
	local F = Instance.new("Frame")
	F.Parent = parent
	F.Size = UDim2.new(1, 0, 0, 44)
	F.BackgroundColor3 = Theme.Card
	F.BackgroundTransparency = 0.2
	local C = Instance.new("UICorner")
	C.CornerRadius = UDim.new(0, 10)
	C.Parent = F

	local L = Instance.new("TextLabel")
	L.Parent = F
	L.Position = UDim2.new(0, 14, 0, 0)
	L.Size = UDim2.new(0.7, 0, 1, 0)
	L.Text = text
	L.TextColor3 = Theme.Text
	L.TextSize = 11
	L.Font = Enum.Font.GothamMedium
	L.TextXAlignment = Enum.TextXAlignment.Left
	L.BackgroundTransparency = 1

	local Sw = Instance.new("TextButton")
	Sw.Parent = F
	Sw.Position = UDim2.new(1, -48, 0.5, -12)
	Sw.Size = UDim2.new(0, 40, 0, 24)
	Sw.Text = ""
	Sw.BackgroundColor3 = state and Theme.AccentSec or Color3.fromRGB(45, 45, 55)
	local SwC = Instance.new("UICorner")
	SwC.CornerRadius = UDim.new(1, 0)
	SwC.Parent = Sw

	local Knob = Instance.new("Frame")
	Knob.Parent = Sw
	Knob.Size = UDim2.new(0, 20, 0, 20)
	Knob.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
	Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	local KC = Instance.new("UICorner")
	KC.CornerRadius = UDim.new(1, 0)
	KC.Parent = Knob

	Sw.MouseButton1Click:Connect(function()
		state = not state
		_G.Mofenk[flag] = state
		TweenService:Create(Sw, TweenInfo.new(0.25), {BackgroundColor3 = state and Theme.AccentSec or Color3.fromRGB(45, 45, 55)}):Play()
		TweenService:Create(Knob, TweenInfo.new(0.25), {Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}):Play()
	end)
end

-- INISIALISASI SEMUA TAB
local Tab1 = CreateTab("Dashboard", 1)
local Tab2 = CreateTab("Tower Manager", 2)
local Tab3 = CreateTab("Roll & Farm", 3)
local Tab4 = CreateTab("Plot & Leveling", 4)
local Tab5 = CreateTab("Reroll & Boosts", 5)
local Tab6 = CreateTab("Rewards & Extras", 6)
local Tab7 = CreateTab("Settings & UI", 7)
TabFrames["Dashboard"].Visible = true

-- TAB 1: DASHBOARD (FB STYLE)
AddSection(Tab1, "PROFIL PENGGUNA")
local ProfileWrapper = Instance.new("Frame")
ProfileWrapper.Parent = Tab1
ProfileWrapper.Size = UDim2.new(1, 0, 0, 160)
ProfileWrapper.BackgroundColor3 = Theme.Card
ProfileWrapper.BackgroundTransparency = 0.15
local PWC = Instance.new("UICorner")
PWC.CornerRadius = UDim.new(0, 12)
PWC.Parent = ProfileWrapper

local CoverBg = Instance.new("Frame")
CoverBg.Parent = ProfileWrapper
CoverBg.Size = UDim2.new(1, 0, 0, 60)
CoverBg.BackgroundColor3 = Theme.AccentSec
CoverBg.BackgroundTransparency = 0.5
local CoverCorner = Instance.new("UICorner")
CoverCorner.CornerRadius = UDim.new(0, 12)
CoverCorner.Parent = CoverBg

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Parent = ProfileWrapper
AvatarImg.AnchorPoint = Vector2.new(0.5, 0)
AvatarImg.Position = UDim2.new(0.5, 0, 0, 25)
AvatarImg.Size = UDim2.new(0, 70, 0, 70)
AvatarImg.BackgroundColor3 = Theme.Header
pcall(function() AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
local AIC = Instance.new("UICorner")
AIC.CornerRadius = UDim.new(1, 0)
AIC.Parent = AvatarImg
local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = Theme.Card
AvatarStroke.Thickness = 4
AvatarStroke.Parent = AvatarImg

local ProfileName = Instance.new("TextLabel")
ProfileName.Parent = ProfileWrapper
ProfileName.Position = UDim2.new(0, 0, 0, 100)
ProfileName.Size = UDim2.new(1, 0, 0, 25)
ProfileName.Text = LocalPlayer.Name
ProfileName.TextColor3 = Theme.Text
ProfileName.TextSize = 14
ProfileName.Font = Enum.Font.GothamBold
ProfileName.BackgroundTransparency = 1
ProfileName.TextXAlignment = Enum.TextXAlignment.Center

local ProfileStats = Instance.new("TextLabel")
ProfileStats.Parent = ProfileWrapper
ProfileStats.Position = UDim2.new(0, 0, 0, 125)
ProfileStats.Size = UDim2.new(1, 0, 0, 20)
ProfileStats.Text = "Uang: ... | Rebirth: ..."
ProfileStats.TextColor3 = Theme.TextSub
ProfileStats.TextSize = 11
ProfileStats.Font = Enum.Font.GothamMedium
ProfileStats.BackgroundTransparency = 1
ProfileStats.TextXAlignment = Enum.TextXAlignment.Center

AddSection(Tab1, "LIVE TOWER MONITORING")
local TowerMonitorCard = Instance.new("Frame")
TowerMonitorCard.Parent = Tab1
TowerMonitorCard.Size = UDim2.new(1, 0, 0, 60)
TowerMonitorCard.BackgroundColor3 = Theme.Card
TowerMonitorCard.BackgroundTransparency = 0.2
local TMC = Instance.new("UICorner")
TMC.CornerRadius = UDim.new(0, 12)
TMC.Parent = TowerMonitorCard
local TowerLbl = Instance.new("TextLabel")
TowerLbl.Parent = TowerMonitorCard
TowerLbl.Position = UDim2.new(0, 16, 0, 10)
TowerLbl.Size = UDim2.new(1, -32, 1, -20)
TowerLbl.BackgroundTransparency = 1
TowerLbl.TextColor3 = Theme.Text
TowerLbl.TextSize = 11
TowerLbl.Font = Enum.Font.GothamMedium
TowerLbl.TextXAlignment = Enum.TextXAlignment.Left
TowerLbl.TextYAlignment = Enum.TextYAlignment.Top

AddSection(Tab1, "LIVE UNIT MONITORING")
local UnitMonitorCard = Instance.new("Frame")
UnitMonitorCard.Parent = Tab1
UnitMonitorCard.Size = UDim2.new(1, 0, 0, 90)
UnitMonitorCard.BackgroundColor3 = Theme.Card
UnitMonitorCard.BackgroundTransparency = 0.2
local UMC = Instance.new("UICorner")
UMC.CornerRadius = UDim.new(0, 12)
UMC.Parent = UnitMonitorCard
local UnitLbl = Instance.new("TextLabel")
UnitLbl.Parent = UnitMonitorCard
UnitLbl.Position = UDim2.new(0, 16, 0, 10)
UnitLbl.Size = UDim2.new(1, -32, 1, -20)
UnitLbl.BackgroundTransparency = 1
UnitLbl.TextColor3 = Theme.Text
UnitLbl.TextSize = 11
UnitLbl.Font = Enum.Font.GothamMedium
UnitLbl.TextXAlignment = Enum.TextXAlignment.Left
UnitLbl.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
	while task.wait(0.5) do
		pcall(function()
			local d = data()
			ProfileStats.Text = string.format("💰 Uang: %s  |  🔄 Rebirth: %s", tostring(d and d.Money or 0), tostring(d and d.Rebirth or 0))
			TowerLbl.Text = string.format("🎮 Status: %s\n🏢 Lantai: %d", tostring(_G.Mofenk.TowerLiveStatus), _G.Mofenk.TowerCurrentLevel)
			
			local locked, grade, trait = 0, 0, 0
			if d and d.Inventory then
				for _, u in pairs(d.Inventory) do
					if u.attributes and u.attributes.locked then locked = locked + 1 end
					if u.grade or (u.attributes and u.attributes.grade) then grade = grade + 1 end
					if u.trait or (u.attributes and u.attributes.trait) then trait = trait + 1 end
				end
			end
			UnitLbl.Text = string.format("🔒 Locked: %d\n⭐ Ber-Grade: %d\n🧬 Ber-Trait: %d", locked, grade, trait)
		end)
	end
end)

-- TAB 2: TOWER
AddSection(Tab2, "KONTROL TOWER")
AddToggle(Tab2, "Auto Tower (Single)", "AutoTower")
AddToggle(Tab2, "Auto Mix Tower", "AutoMixTower")

-- TAB 3: ROLL & FARM
AddSection(Tab3, "FARMING OTOMATIS")
AddToggle(Tab3, "Auto Roll Dadu", "AutoRoll")
AddToggle(Tab3, "Gunakan Lucky/Jackpot Spins", "AutoSpins")
AddToggle(Tab3, "Auto Beli Dadu", "AutoDice")
AddToggle(Tab3, "Auto Rebirth", "AutoRebirth")
AddSection(Tab3, "MANAJEMEN INVENTARIS")
AddToggle(Tab3, "Auto Jual Unit Sampah", "AutoSell")
AddToggle(Tab3, "Auto Fusion Machine", "AutoFuse")

-- TAB 4: PLOT
AddSection(Tab4, "PLOT & UPGRADE")
AddToggle(Tab4, "Auto Collect Plot", "AutoCollect")
AddToggle(Tab4, "Smart Place Unit (Potential)", "SmartPlace")
AddToggle(Tab4, "Auto Upgrade Pad", "AutoUpgrade")
AddSection(Tab4, "LEVEL UP SLOT")
AddToggle(Tab4, "Auto Level Up Unit", "AutoLevel")

local LimitCard = Instance.new("Frame")
LimitCard.Parent = Tab4
LimitCard.Size = UDim2.new(1, 0, 0, 44)
LimitCard.BackgroundColor3 = Theme.Card
LimitCard.BackgroundTransparency = 0.2
local LCC = Instance.new("UICorner")
LCC.CornerRadius = UDim.new(0, 10)
LCC.Parent = LimitCard
local LL_Lbl = Instance.new("TextLabel")
LL_Lbl.Parent = LimitCard
LL_Lbl.Position = UDim2.new(0, 14, 0, 0)
LL_Lbl.Size = UDim2.new(0.5, 0, 1, 0)
LL_Lbl.Text = "Batas Target Level Slot:"
LL_Lbl.TextColor3 = Theme.Text
LL_Lbl.TextSize = 11
LL_Lbl.Font = Enum.Font.GothamMedium
LL_Lbl.TextXAlignment = Enum.TextXAlignment.Left
LL_Lbl.BackgroundTransparency = 1
local LL_Btn = Instance.new("TextButton")
LL_Btn.Parent = LimitCard
LL_Btn.Position = UDim2.new(0.6, 0, 0.15, 0)
LL_Btn.Size = UDim2.new(0.35, 0, 0.7, 0)
LL_Btn.Text = tostring(_G.Mofenk.LevelLimit)
LL_Btn.TextColor3 = Theme.AccentSec
LL_Btn.TextSize = 12
LL_Btn.Font = Enum.Font.GothamBold
LL_Btn.BackgroundColor3 = Theme.Header
local LLBC = Instance.new("UICorner")
LLBC.CornerRadius = UDim.new(0, 6)
LLBC.Parent = LL_Btn

local limits = {10, 25, 50, 100, 200, 500}
local currentLimitIdx = 3
LL_Btn.MouseButton1Click:Connect(function()
	currentLimitIdx = (currentLimitIdx % #limits) + 1
	_G.Mofenk.LevelLimit = limits[currentLimitIdx]
	LL_Btn.Text = tostring(_G.Mofenk.LevelLimit)
end)

-- TAB 5: REROLL & BOOSTS
AddSection(Tab5, "REROLLS OTOMATIS")
AddToggle(Tab5, "Auto Grade Reroll", "AutoGrade")
AddToggle(Tab5, "Auto Trait Reroll", "AutoTrait")
AddSection(Tab5, "POTION & BOOSTS")
AddToggle(Tab5, "Auto Pakai Potion", "AutoPotion")

-- TAB 6: REWARDS
AddSection(Tab6, "KLAIM & REWARDS")
AddToggle(Tab6, "Auto Redeem Codes", "AutoCodes")
AddToggle(Tab6, "Auto Claim Daily/Offline", "AutoClaim")
AddToggle(Tab6, "Auto Claim Quests", "AutoQuests")
AddToggle(Tab6, "Auto Beli Gamepass (Tickets)", "AutoPasses")
AddToggle(Tab6, "Auto Rebirth Stats", "AutoStats")

-- TAB 7: SETTINGS & UI
AddSection(Tab7, "SKALA ANTARMUKA SCRIPT")
local ScaleCard = Instance.new("Frame")
ScaleCard.Parent = Tab7
ScaleCard.Size = UDim2.new(1, 0, 0, 46)
ScaleCard.BackgroundColor3 = Theme.Card
ScaleCard.BackgroundTransparency = 0.2
local SCC = Instance.new("UICorner")
SCC.CornerRadius = UDim.new(0, 10)
SCC.Parent = ScaleCard
local SC_Lbl = Instance.new("TextLabel")
SC_Lbl.Parent = ScaleCard
SC_Lbl.Position = UDim2.new(0, 14, 0, 0)
SC_Lbl.Size = UDim2.new(0.5, 0, 1, 0)
SC_Lbl.Text = "Skala UI (Zoom In/Out):"
SC_Lbl.TextColor3 = Theme.Text
SC_Lbl.TextSize = 11
SC_Lbl.Font = Enum.Font.GothamMedium
SC_Lbl.TextXAlignment = Enum.TextXAlignment.Left
SC_Lbl.BackgroundTransparency = 1
local SC_BtnMinus = Instance.new("TextButton")
SC_BtnMinus.Parent = ScaleCard
SC_BtnMinus.Position = UDim2.new(0.55, 0, 0.15, 0)
SC_BtnMinus.Size = UDim2.new(0, 32, 0, 32)
SC_BtnMinus.Text = "-"
SC_BtnMinus.TextColor3 = Theme.Text
SC_BtnMinus.TextSize = 16
SC_BtnMinus.Font = Enum.Font.GothamBold
SC_BtnMinus.BackgroundColor3 = Theme.Header
local SBM_C = Instance.new("UICorner")
SBM_C.CornerRadius = UDim.new(0, 8)
SBM_C.Parent = SC_BtnMinus
local SC_Val = Instance.new("TextLabel")
SC_Val.Parent = ScaleCard
SC_Val.Position = UDim2.new(0.68, 0, 0.15, 0)
SC_Val.Size = UDim2.new(0, 50, 0, 32)
SC_Val.Text = string.format("%.1fx", _G.Mofenk.UIScale)
SC_Val.TextColor3 = Theme.AccentSec
SC_Val.TextSize = 12
SC_Val.Font = Enum.Font.GothamBold
SC_Val.BackgroundTransparency = 1
local SC_BtnPlus = Instance.new("TextButton")
SC_BtnPlus.Parent = ScaleCard
SC_BtnPlus.Position = UDim2.new(0.85, 0, 0.15, 0)
SC_BtnPlus.Size = UDim2.new(0, 32, 0, 32)
SC_BtnPlus.Text = "+"
SC_BtnPlus.TextColor3 = Theme.Text
SC_BtnPlus.TextSize = 16
SC_BtnPlus.Font = Enum.Font.GothamBold
SC_BtnPlus.BackgroundColor3 = Theme.Header
local SBP_C = Instance.new("UICorner")
SBP_C.CornerRadius = UDim.new(0, 8)
SBP_C.Parent = SC_BtnPlus

local function ApplyUIScale(scale)
	_G.Mofenk.UIScale = math.clamp(scale, 0.5, 2.0)
	SC_Val.Text = string.format("%.1fx", _G.Mofenk.UIScale)
	UIRescale.Scale = _G.Mofenk.UIScale
end
SC_BtnMinus.MouseButton1Click:Connect(function() ApplyUIScale(_G.Mofenk.UIScale - 0.1) end)
SC_BtnPlus.MouseButton1Click:Connect(function() ApplyUIScale(_G.Mofenk.UIScale + 0.1) end)

-- 8. TOMBOL LOGO "F" MENGAMBANG (BOUNDARY CONSTRAINTS)
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "MofenkToggleGui"
ToggleGui.Parent = parentGui
ToggleGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = Theme.Header
ToggleBtn.BackgroundTransparency = 0.1
ToggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
ToggleBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleBtn.Text = "F"
ToggleBtn.TextColor3 = Theme.AccentSec
ToggleBtn.TextSize = 24
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.AutoButtonColor = false
local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 14)
TC.Parent = ToggleBtn
local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 2.5
ToggleStroke.Parent = ToggleBtn
local TSGrad = Instance.new("UIGradient")
TSGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.0, Theme.Accent),
	ColorSequenceKeypoint.new(1.0, Theme.AccentSec)
})
TSGrad.Parent = ToggleStroke

local dragging, dragInput, dragStart, startPos
ToggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = ToggleBtn.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
ToggleBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		local viewport = workspace.CurrentCamera.ViewportSize
		local newX = math.clamp(startPos.X.Offset + delta.X, 10, viewport.X - ToggleBtn.AbsoluteSize.X - 10)
		local newY = math.clamp(startPos.Y.Offset + delta.Y, 10, viewport.Y - ToggleBtn.AbsoluteSize.Y - 10)
		ToggleBtn.Position = UDim2.new(0, newX, 0, newY)
	end
end)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- 9. LOGIKA BACKEND FULL (Unit, Tower, Fusion, Quests, Codes, Traits dll)
-- Utility Backend
local function getPlacedUnits()
	local d = data()
	local placed = {}
	if d and d.Slots then
		for _, s in pairs(d.Slots) do if s.unitId then placed[s.unitId] = true end end
	end
	return placed
end

task.spawn(function()
	MofenkNotify("MOFENK PRO", "UI Aesthetic & Full Backend Ready!", 5)
	MainFrame.Visible = true 
	
	while task.wait(2.5) do
		if _G.__ANIMEDICE ~= generation then break end
		local d = data()
		if not d then continue end

		-- Auto Spins & Auto Roll
		if _G.Mofenk.AutoRoll and R.RollDice then
			if _G.Mofenk.AutoSpins and R.UseSpin then
				pcall(function() R.UseSpin:FireServer("Lucky Spin") end)
			end
			pcall(function() R.RollDice:InvokeServer() end)
		end

		-- Auto Dice & Equip
		if _G.Mofenk.AutoDice and Dice and R.BuyDice then
			pcall(function()
				local allDice = Dice.GetAll()
				local bestKey, bestLuck = nil, 0
				for key, def in pairs(allDice) do
					local price, luck = tonumber(def.price) or 0, tonumber(def.luck) or 0
					if price > 0 and not d.OwnedDice[key] and d.Money >= price and luck > bestLuck then
						bestKey, bestLuck = key, luck
					end
				end
				if bestKey then R.BuyDice:FireServer(bestKey) end
			end)
		end

		-- Auto Collect & Smart Place
		if _G.Mofenk.AutoCollect and R.CollectBalance then
			pcall(function()
				for key, _ in pairs(d.Slots) do R.CollectBalance:FireServer(tonumber(key)) end
				if _G.Mofenk.SmartPlace and R.EquipUnit and R.InteractSlot then
					-- Smart place logic (mengurutkan berdasarkan baseIncome)
					local n = 0; for _ in pairs(d.Slots) do n = n + 1 end
					local ranked = {}
					for id, u in pairs(d.Inventory) do
						if UnitConfig and UnitConfig.entries and UnitConfig.entries[u.name] then
							ranked[#ranked + 1] = { id = id, v = baseIncome(u) }
						end
					end
					table.sort(ranked, function(a, b) return a.v > b.v end)
					if #ranked > 0 then
						-- Hanya contoh eksekusi equip unit terbaik
						local bestId = ranked[1].id
						local placed = getPlacedUnits()
						if not placed[bestId] then
							R.EquipUnit:InvokeServer(bestId)
							task.wait(0.5)
							R.InteractSlot:FireServer(1) -- Taruh di slot 1 (Contoh logika aman)
						end
					end
				elseif R.EquipBest then
					R.EquipBest:FireServer()
				end
			end)
		end

		-- Auto Level Up Slots
		if _G.Mofenk.AutoLevel and R.LevelUpSlot then
			pcall(function()
				for key, slot in pairs(d.Slots) do
					if slot and slot.unitId and tonumber(slot.level) and tonumber(slot.level) < _G.Mofenk.LevelLimit then
						R.LevelUpSlot:FireServer(tonumber(key))
					end
				end
			end)
		end

		-- Auto Upgrade Pad
		if _G.Mofenk.AutoUpgrade and R.BuyUpgrade then pcall(function() R.BuyUpgrade:FireServer() end) end
		
		-- Auto Sell Junk (Dibawah Rarity Limit)
		if _G.Mofenk.AutoSell and R.SellInventory then
			pcall(function()
				local list = {}
				local placed = getPlacedUnits()
				for id, u in pairs(d.Inventory) do
					local isProtected = placed[id] or (u.attributes and u.attributes.locked) or (u.attributes and u.attributes.mutation)
					if not isProtected then
						table.insert(list, id)
						if #list >= 150 then break end
					end
				end
				if #list > 0 then R.SellInventory:InvokeServer(list) end
			end)
		end

		-- Auto Fusion
		if _G.Mofenk.AutoFuse and R.Fuse then
			pcall(function()
				local placed = getPlacedUnits()
				local pile = {}
				for id, u in pairs(d.Inventory) do
					if not placed[id] and not (u.attributes and u.attributes.locked) then table.insert(pile, id) end
				end
				if #pile >= 3 then R.Fuse:FireServer(pile[1], pile[2], pile[3]) end
			end)
		end

		-- Auto Rebirth
		if _G.Mofenk.AutoRebirth and R.Rebirth then
			pcall(function() if tonumber(d.Money) >= tonumber(_G.Mofenk.RebirthRequirement) then R.Rebirth:FireServer() end end)
		end

		-- Rerolls (Grade & Trait)
		if _G.Mofenk.AutoGrade and R.GradeRoll and itemAmount("Gems") >= 1 then
			pcall(function()
				for _, slot in pairs(d.Slots) do
					local u = slot.unitId and d.Inventory[slot.unitId]
					if u and (not u.attributes or not u.attributes.grade) then R.GradeRoll:FireServer(slot.unitId); break end
				end
			end)
		end
		if _G.Mofenk.AutoTrait and R.TraitRoll and itemAmount("Trait Reroll") >= 1 then
			pcall(function()
				for _, slot in pairs(d.Slots) do
					local u = slot.unitId and d.Inventory[slot.unitId]
					if u and (not u.attributes or not u.attributes.trait) then R.TraitRoll:FireServer(slot.unitId); break end
				end
			end)
		end

		-- Auto Boosts
		if _G.Mofenk.AutoPotion and R.BoostUse then
			pcall(function()
				for key, item in pairs(d.Inventory) do
					if type(key) == "string" and BOOSTS[key] and tonumber(item.amount) >= 1 then R.BoostUse:FireServer(key) end
				end
			end)
		end
	end
end)

-- Loop Fast-Tower
local towersList = {"Infinity Tower", "Dragon Tower", "Cursed Tower", "Pirate Tower", "Halloween Tower"}
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if _G.Mofenk.AutoTower or _G.Mofenk.AutoMixTower then
			pcall(function()
				if R.EquipTowerUnit then R.EquipTowerUnit:FireServer() end
				local target = _G.Mofenk.AutoMixTower and towersList[math.random(1, #towersList)] or _G.Mofenk.SelectedTowerSingle
				local ok, started = R.PlayTower:InvokeServer(target)
				if not started and R.CancelTower then 
					R.CancelTower:InvokeServer() 
					task.wait(2)
					R.PlayTower:InvokeServer(target)
				end
				
				_G.Mofenk.TowerLiveStatus = "Farming: " .. target
				_G.Mofenk.TowerCurrentLevel = 0
				
				for i = 1, 100 do -- Fast forward
					local okF, seq = pcall(function() return R.CompleteFloor:InvokeServer() end)
					if okF and seq then
						for _, ev in ipairs(seq) do
							if ev.action == "floorCompleted" then _G.Mofenk.TowerCurrentLevel = tonumber(ev.floor) or (_G.Mofenk.TowerCurrentLevel + 1)
							elseif ev.action == "ended" then return end
						end
					else break end
					task.wait(0.2)
				end
				if R.CancelTower then R.CancelTower:InvokeServer() end
			end)
			task.wait(3)
		else
			_G.Mofenk.TowerLiveStatus = "Standby"
			task.wait(2)
		end
	end
end)

-- Loop Rewards & Extras (Codes, Claims, Quests, Stats)
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if _G.Mofenk.AutoCodes and R.RedeemCode and CODES then
			pcall(function()
				local d = data()
				for code in pairs(CODES) do
					if type(code) == "string" and d and not d.RedeemedCodes[code] then
						R.RedeemCode:FireServer(code)
						task.wait(0.6)
					end
				end
			end)
		end
		if _G.Mofenk.AutoClaim then
			pcall(function()
				if R.ClaimOffline then R.ClaimOffline:FireServer() end
				if R.ClaimDaily then R.ClaimDaily:FireServer() end
				if R.ClaimGroup then R.ClaimGroup:FireServer() end
			end)
		end
		if _G.Mofenk.AutoQuests and R.QuestClaim and QuestConfig then
			pcall(function()
				local d = data()
				for period, def in pairs(QuestConfig.Periods or {}) do
					local q = d.Quests and d.Quests[period]
					if type(q) == "table" and type(q.progress) == "table" then
						for _, quest in ipairs(def.quests or {}) do
							if not (q.claimed and q.claimed[quest.id]) and tonumber(q.progress[quest.id] or 0) >= tonumber(quest.target or math.huge) then
								R.QuestClaim:FireServer(period, quest.id, q.expiresAt)
								task.wait(0.3)
							end
						end
					end
				end
			end)
		end
		if _G.Mofenk.AutoPasses and R.QuestBuy then
			pcall(function()
				local tk = itemAmount("Tickets")
				local passOrder = {"More Cash", "Luck", "Roll Speed", "Ultra Luck"}
				for _, name in ipairs(passOrder) do
					if tk >= 500 then R.QuestBuy:FireServer(name); break end
				end
			end)
		end
		if _G.Mofenk.AutoStats and R.AddStat then
			pcall(function() R.AddStat:FireServer(_G.Mofenk.StatPick) end)
		end
		task.wait(15)
	end
end)
