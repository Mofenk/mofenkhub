-- ===================================================================== --
-- 👑 MOFENKHUB V35.0 — ULTIMATE AESTHETIC & REFINED DASHBOARD SUITE
-- Game: Anime Dice | Dynamic Tower Switch, Unit-Only Monitoring, Clean Aesthetic UI
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

local LocalPlayer = Players.LocalPlayer

local successGui, parentGui = pcall(function()
	if gethui then return gethui()
	elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui
	else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then
	parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- 1. BERSIHKAN INSTANCE LAMA
pcall(function()
	for _, v in pairs(parentGui:GetChildren()) do
		if v.Name == "MofenkUltraHubV35" or v.Name == "MofenkToggleGui" or v.Name == "MofenkNotifyGui" or v.Name == "MofenkIntroGui" then
			v:Destroy()
		end
	end
end)

-- 2. KONFIGURASI GLOBAL
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

_G.Mofenk = {
	UIScale             = 1.0,
	CurrentConfigName   = "DefaultConfig",
	AutoLoadConfig      = true,
	WebhookUrl          = "",
	-- Roll & Farm
	AutoRoll            = false,
	AutoDice            = false,
	AutoEquipDice       = false,
	AutoRebirth         = false,
	RebirthRequirement  = 50000,
	-- Inventaris & Jual
	AutoSell            = false,
	SellAllJunk         = false,
	AutoLock            = false,
	AutoFuse            = false,
	-- Tower Manager
	AutoTower           = false,
	AutoMixTower        = false,
	SelectedTowerSingle = "Infinity Tower",
	AutoEquipTower      = false,
	TowerLiveStatus     = "Menunggu...",
	TowerCurrentLevel   = 0,
	GearSet             = "Luck Set",
	LiveGearName        = "Luck Set",
	-- Plot & Unit Level
	AutoCollect         = false,
	SmartPlace          = false,
	AutoLevel           = false,
	LevelLimit          = 50,
	AutoUpgrade         = false,
	-- Quirk, Traits & Potion
	AutoQuirk           = false,
	AutoTrait           = false,
	AutoGrade           = false,
	AutoPotion          = false,
	-- Client & Performance
	AntiAFK             = true,
	AutoReconnect       = true,
	Disable3DRender     = false,
}

-- 3. SISTEM CONFIG
local function GetConfigFileName(name)
	return "MofenkConfig_" .. tostring(name or "DefaultConfig") .. ".json"
end

local function SaveConfig(configName)
	local name = configName or _G.Mofenk.CurrentConfigName
	local success, encoded = pcall(function() return HttpService:JSONEncode(_G.Mofenk) end)
	if success and writefile then
		pcall(function() writefile(GetConfigFileName(name), encoded) end)
		return true
	end
	return false
end

local function LoadConfig(configName)
	local name = configName or _G.Mofenk.CurrentConfigName
	local fileName = GetConfigFileName(name)
	if readfile and pcall(function() return readfile(fileName) end) then
		local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(fileName)) end)
		if success and type(decoded) == "table" then
			for k, v in pairs(decoded) do
				if _G.Mofenk[k] ~= nil then _G.Mofenk[k] = v end
			end
			_G.Mofenk.CurrentConfigName = name
			return true
		end
	end
	return false
end

if _G.Mofenk.AutoLoadConfig then
	LoadConfig(_G.Mofenk.CurrentConfigName)
end

-- 4. MAPPING REMOTE GAME & MODUL
local Framework, Network
pcall(function() Framework = ReplicatedStorage:WaitForChild("Framework", 15) end)
pcall(function() Network = ReplicatedStorage:WaitForChild("Network", 15) end)

local function safeFind(parent, path)
	if not parent then return nil end
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
	Rebirth         = Network and (safeFind(Network, "RebirthService.RE.Rebirth") or safeFind(Network, "RebirthService.RF.Rebirth")),
	BuyUpgrade      = Network and (safeFind(Network, "PlotService.RE.BuyUpgrade") or safeFind(Network, "RE.BuyUpgrade") or safeFind(Network, "PlotService.RE.BuyPadUpgrade")),
	SellInventory   = Network and safeFind(Network, "SellService.RF.SellInventory"),
	PlayTower       = Network and (safeFind(Network, "Towers.RF.PlayTower") or safeFind(Network, "Towers.RE.PlayTower") or safeFind(Network, "Towers.RE.StartGame")),
	LeaveTower      = Network and (safeFind(Network, "Towers.RE.LeaveTower") or safeFind(Network, "Towers.RF.LeaveTower") or safeFind(Network, "Towers.RE.Quit")),
	Fuse            = Network and safeFind(Network, "FusingService.RE.Fuse"),
	BoostUse        = Network and safeFind(Network, "BoostService.RE.Use"),
	EquipTowerUnit  = Network and (safeFind(Network, "Towers.RE.EquipBest") or safeFind(Network, "Towers.RE.EquipTeam") or safeFind(Network, "Towers.RE.AutoEquip")),
	EquipGear       = Network and safeFind(Network, "GearService.RE.EquipGear"),
}

local DataController, TowersConfig, Dice, UnitClass
pcall(function()
	if Framework then
		DataController = require(Framework.Features.Data.DataController)
		TowersConfig   = require(Framework.Features.Towers.Towers)
		Dice           = require(Framework.Features.Rolling.Dice)
		UnitClass      = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig)
	end
end)

local function data()
	local ok, res = pcall(function() return DataController.___X end)
	return ok and res or nil
end

-- 5. TEMA VISUAL AESTHETIC & WARNA TERANG
local Theme = {
	Bg        = Color3.fromRGB(16, 14, 26),
	Header    = Color3.fromRGB(24, 20, 36),
	Card      = Color3.fromRGB(34, 28, 50),
	Accent    = Color3.fromRGB(255, 90, 130),
	AccentSec = Color3.fromRGB(0, 220, 255),
	Text      = Color3.fromRGB(255, 255, 255),
	TextSub   = Color3.fromRGB(200, 190, 220)
}

-- 6. SISTEM NOTIFIKASI TOAST
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "MofenkNotifyGui"
NotifyGui.Parent = parentGui
NotifyGui.ResetOnSpawn = false

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
	Card.BackgroundTransparency = 0.08
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 12)
	Corner.Parent = Card
	
	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Theme.AccentSec
	Stroke.Transparency = 0.25
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
	
	task.delay(duration, function()
		pcall(function() Card:Destroy() end)
	end)
end

-- Deteksi Error Konsol untuk Debugger Otomatis
pcall(function()
	LogService.MessageOut:Connect(function(message, messageType)
		if messageType == Enum.MessageType.MessageError then
			MofenkNotify("⚠️ ERROR TERDETEKSI", string.sub(message, 1, 60), 4)
		end
	end)
end)

-- 7. UI UTAMA (BINGKAI & ESTETIKA DIPERHALUS)
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkUltraHubV35"
MainGui.Parent = parentGui
MainGui.ResetOnSpawn = false

local UIRescale = Instance.new("UIScale")
UIRescale.Scale = _G.Mofenk.UIScale
UIRescale.Parent = MainGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 860, 0, 560)
MainFrame.Position = UDim2.new(0.5, -430, 0.5, -280)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = 0.03
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = MainFrame

local GradOverlay = Instance.new("UIGradient")
GradOverlay.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.0, Color3.fromRGB(16, 14, 28)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 55, 105)),
	ColorSequenceKeypoint.new(1.0, Color3.fromRGB(130, 25, 60))
})
GradOverlay.Transparency = NumberSequence.new(0.15)
GradOverlay.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Theme.AccentSec
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

-- Topbar (MOFENKHUB & GAME TERDETEKSI)
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 52)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BackgroundTransparency = 0.15

local LogoIcon = Instance.new("Frame")
LogoIcon.Parent = TopBar
LogoIcon.Position = UDim2.new(0, 16, 0.5, -18)
LogoIcon.Size = UDim2.new(0, 36, 0, 36)
LogoIcon.BackgroundColor3 = Theme.Accent
local LIC = Instance.new("UICorner")
LIC.CornerRadius = UDim.new(0, 10)
LIC.Parent = LogoIcon

local LogoTextF = Instance.new("TextLabel")
LogoTextF.Parent = LogoIcon
LogoTextF.Size = UDim2.new(1, 0, 1, 0)
LogoTextF.BackgroundTransparency = 1
LogoTextF.Text = "F"
LogoTextF.TextColor3 = Theme.Text
LogoTextF.TextSize = 18
LogoTextF.Font = Enum.Font.GothamBold

local Title = Instance.new("TextBox")
Title.Parent = TopBar
Title.Position = UDim2.new(0, 64, 0, 0)
Title.Size = UDim2.new(0, 540, 1, 0)
Title.Text = "MOFENKHUB — ANIME DICE SUITE"
Title.TextColor3 = Theme.Text
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.ClearTextOnFocus = false
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.Position = UDim2.new(1, -46, 0, 12)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundColor3 = Theme.Card
local CC = Instance.new("UICorner")
CC.CornerRadius = UDim.new(0, 8)
CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Sidebar Group Nav
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 12, 0, 62)
Sidebar.Size = UDim2.new(0, 185, 1, -74)
Sidebar.BackgroundColor3 = Theme.Header
Sidebar.BackgroundTransparency = 0.25
Sidebar.ScrollBarThickness = 2
local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.Padding = UDim.new(0, 8)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 207, 0, 62)
ContentArea.Size = UDim2.new(1, -219, 1, -74)
ContentArea.BackgroundColor3 = Theme.Header
ContentArea.BackgroundTransparency = 0.35

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
	Btn.BackgroundTransparency = 0.15
	Btn.LayoutOrder = order
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 10)
	Corner.Parent = Btn

	local Scroll = Instance.new("ScrollingFrame")
	Scroll.Parent = ContentArea
	Scroll.Size = UDim2.new(1, -12, 1, -12)
	Scroll.Position = UDim2.new(0, 6, 0, 6)
	Scroll.BackgroundTransparency = 1
	Scroll.ScrollBarThickness = 4
	Scroll.ScrollBarImageColor3 = Theme.AccentSec
	Scroll.Visible = false
	local Lay = Instance.new("UIListLayout")
	Lay.Parent = Scroll
	Lay.Padding = UDim.new(0, 10)
	
	TabFrames[name] = Scroll

	Btn.MouseButton1Click:Connect(function()
		for n, f in pairs(TabFrames) do f.Visible = (n == name) end
		for _, b in ipairs(Sidebar:GetChildren()) do
			if b:IsA("TextButton") then
				b.TextColor3 = Theme.TextSub
				b.BackgroundColor3 = Theme.Card
				b.BackgroundTransparency = 0.15
			end
		end
		Btn.TextColor3 = Theme.Text
		Btn.BackgroundColor3 = Theme.AccentSec
		Btn.BackgroundTransparency = 0.0
	end)
	return Scroll
end

local function AddSection(parent, text)
	local L = Instance.new("TextLabel")
	L.Parent = parent
	L.Size = UDim2.new(1, 0, 0, 28)
	L.Text = "  " .. text
	L.TextColor3 = Theme.AccentSec
	L.TextSize = 11
	L.Font = Enum.Font.GothamBold
	L.TextXAlignment = Enum.TextXAlignment.Left
	L.BackgroundTransparency = 1
end

local function AddToggle(parent, text, flag)
	local state = _G.Mofenk[flag] or false
	local F = Instance.new("Frame")
	F.Parent = parent
	F.Size = UDim2.new(1, 0, 0, 42)
	F.BackgroundColor3 = Theme.Card
	F.BackgroundTransparency = 0.12
	local C = Instance.new("UICorner")
	C.CornerRadius = UDim.new(0, 10)
	C.Parent = F

	local L = Instance.new("TextLabel")
	L.Parent = F
	L.Position = UDim2.new(0, 14, 0, 0)
	L.Size = UDim2.new(0.7, 0, 1, 0)
	L.Text = text
	L.TextColor3 = Theme.Text
	L.TextSize = 10
	L.Font = Enum.Font.GothamMedium
	L.TextXAlignment = Enum.TextXAlignment.Left
	L.BackgroundTransparency = 1

	local Sw = Instance.new("TextButton")
	Sw.Parent = F
	Sw.Position = UDim2.new(1, -46, 0.5, -10)
	Sw.Size = UDim2.new(0, 36, 0, 20)
	Sw.Text = ""
	Sw.BackgroundColor3 = state and Theme.AccentSec or Color3.fromRGB(55, 45, 75)
	local SwC = Instance.new("UICorner")
	SwC.CornerRadius = UDim.new(1, 0)
	SwC.Parent = Sw

	local Knob = Instance.new("Frame")
	Knob.Parent = Sw
	Knob.Size = UDim2.new(0, 16, 0, 16)
	Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
	Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	local KC = Instance.new("UICorner")
	KC.CornerRadius = UDim.new(1, 0)
	KC.Parent = Knob

	Sw.MouseButton1Click:Connect(function()
		state = not state
		_G.Mofenk[flag] = state
		TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.AccentSec or Color3.fromRGB(55, 45, 75)}):Play()
		TweenService:Create(Knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
	end)
end

local function AddScrollingDropdown(parent, title, options, currentVal, callback)
	local F = Instance.new("Frame")
	F.Parent = parent
	F.Size = UDim2.new(1, 0, 0, 46)
	F.BackgroundColor3 = Theme.Card
	F.BackgroundTransparency = 0.12
	local C = Instance.new("UICorner")
	C.CornerRadius = UDim.new(0, 10)
	C.Parent = F

	local L = Instance.new("TextLabel")
	L.Parent = F
	L.Position = UDim2.new(0, 14, 0, 0)
	L.Size = UDim2.new(0.4, 0, 1, 0)
	L.Text = title
	L.TextColor3 = Theme.Text
	L.TextSize = 10
	L.Font = Enum.Font.GothamMedium
	L.TextXAlignment = Enum.TextXAlignment.Left
	L.BackgroundTransparency = 1

	local Btn = Instance.new("TextButton")
	Btn.Parent = F
	Btn.Position = UDim2.new(0.42, 0, 0.15, 0)
	Btn.Size = UDim2.new(0.55, 0, 0.7, 0)
	Btn.Text = tostring(currentVal)
	Btn.TextColor3 = Theme.AccentSec
	Btn.TextSize = 10
	Btn.Font = Enum.Font.GothamBold
	Btn.BackgroundColor3 = Theme.Header
	Btn.BackgroundTransparency = 0.2
	local BC = Instance.new("UICorner")
	BC.CornerRadius = UDim.new(0, 8)
	BC.Parent = Btn

	local DropList = Instance.new("ScrollingFrame")
	DropList.Parent = parent.Parent
	DropList.Size = UDim2.new(0.55, 0, 0, 140)
	DropList.Position = UDim2.new(0.42, 0, 0, 0)
	DropList.BackgroundColor3 = Theme.Header
	DropList.BorderSizePixel = 0
	DropList.Visible = false
	DropList.ZIndex = 15
	DropList.CanvasSize = UDim2.new(0, 0, 0, #options * 32)
	DropList.ScrollBarThickness = 4
	local DLC = Instance.new("UICorner")
	DLC.CornerRadius = UDim.new(0, 8)
	DLC.Parent = DropList
	local DLL = Instance.new("UIListLayout")
	DLL.Parent = DropList

	for _, opt in ipairs(options) do
		local OptBtn = Instance.new("TextButton")
		OptBtn.Parent = DropList
		OptBtn.Size = UDim2.new(1, 0, 0, 30)
		OptBtn.Text = "  " .. tostring(opt)
		OptBtn.TextColor3 = Theme.Text
		OptBtn.TextSize = 10
		OptBtn.Font = Enum.Font.GothamMedium
		OptBtn.TextXAlignment = Enum.TextXAlignment.Left
		OptBtn.BackgroundTransparency = 1
		OptBtn.ZIndex = 16

		OptBtn.MouseButton1Click:Connect(function()
			Btn.Text = tostring(opt)
			DropList.Visible = false
			if callback then callback(opt) end
		end)
	end

	Btn.MouseButton1Click:Connect(function()
		DropList.Visible = not DropList.Visible
	end)
end

-- PEMBUATAN TAB KATEGORI
local Tab1 = CreateTab("Dashboard", 1)
local Tab2 = CreateTab("Tower Manager", 2)
local Tab3 = CreateTab("Roll & Farm", 3)
local Tab4 = CreateTab("Inventaris", 4)
local Tab5 = CreateTab("Plot & Unit", 5)
local Tab6 = CreateTab("Quirk & Potion", 6)
local Tab7 = CreateTab("Server & Client", 7)
local Tab8 = CreateTab("Remote Spy", 8)
local Tab9 = CreateTab("Config & Webhook", 9)

TabFrames["Dashboard"].Visible = true

-- TAB 1: DASHBOARD (UNIT-ONLY MONITORING & TOWER MONITORING JELAS)
AddSection(Tab1, "PROFIL PENGGUNA & STATUS UTAMA")

local ProfileWrapper = Instance.new("Frame")
ProfileWrapper.Parent = Tab1
ProfileWrapper.Size = UDim2.new(1, 0, 0, 120)
ProfileWrapper.BackgroundColor3 = Theme.Card
ProfileWrapper.BackgroundTransparency = 0.08
local PWC = Instance.new("UICorner")
PWC.CornerRadius = UDim.new(0, 12)
PWC.Parent = ProfileWrapper

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Parent = ProfileWrapper
AvatarImg.Position = UDim2.new(0, 14, 0, 14)
AvatarImg.Size = UDim2.new(0, 68, 0, 68)
AvatarImg.BackgroundColor3 = Theme.Header
pcall(function()
	AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
end)
local AIC = Instance.new("UICorner")
AIC.CornerRadius = UDim.new(1, 0)
AIC.Parent = AvatarImg

local ProfileCard = Instance.new("TextLabel")
ProfileCard.Parent = ProfileWrapper
ProfileCard.Position = UDim2.new(0, 96, 0, 12)
ProfileCard.Size = UDim2.new(1, -108, 0, 68)
ProfileCard.BackgroundTransparency = 1
ProfileCard.TextColor3 = Theme.Text
ProfileCard.TextSize = 10
ProfileCard.Font = Enum.Font.GothamMedium
ProfileCard.TextXAlignment = Enum.TextXAlignment.Left
ProfileCard.TextYAlignment = Enum.TextYAlignment.Top

local StatsProBar = Instance.new("Frame")
StatsProBar.Parent = ProfileWrapper
StatsProBar.Position = UDim2.new(0, 14, 0, 88)
StatsProBar.Size = UDim2.new(1, -28, 0, 24)
StatsProBar.BackgroundColor3 = Theme.Header
StatsProBar.BackgroundTransparency = 0.2
local SPBC = Instance.new("UICorner")
SPBC.CornerRadius = UDim.new(0, 6)
SPBC.Parent = StatsProBar

local StatsProLbl = Instance.new("TextLabel")
StatsProLbl.Parent = StatsProBar
StatsProLbl.Size = UDim2.new(1, 0, 1, 0)
StatsProLbl.BackgroundTransparency = 1
StatsProLbl.TextColor3 = Theme.AccentSec
StatsProLbl.TextSize = 10
StatsProLbl.Font = Enum.Font.GothamBold
StatsProLbl.Text = "FPS: 60 | Ping: 0ms | Active Users: 1"

AddSection(Tab1, "LIVE MONITORING TOWER & UNIT MANAGEMENT")

local LiveMonitorCard = Instance.new("Frame")
LiveMonitorCard.Parent = Tab1
LiveMonitorCard.Size = UDim2.new(1, 0, 0, 140)
LiveMonitorCard.BackgroundColor3 = Theme.Card
LiveMonitorCard.BackgroundTransparency = 0.08
local LMC = Instance.new("UICorner")
LMC.CornerRadius = UDim.new(0, 12)
LMC.Parent = LiveMonitorCard

local LiveMonitorLbl = Instance.new("TextLabel")
LiveMonitorLbl.Parent = LiveMonitorCard
LiveMonitorLbl.Position = UDim2.new(0, 16, 0, 12)
LiveMonitorLbl.Size = UDim2.new(1, -32, 1, -24)
LiveMonitorLbl.BackgroundTransparency = 1
LiveMonitorLbl.TextColor3 = Theme.Text
LiveMonitorLbl.TextSize = 10
LiveMonitorLbl.Font = Enum.Font.GothamMedium
LiveMonitorLbl.TextXAlignment = Enum.TextXAlignment.Left
LiveMonitorLbl.TextYAlignment = Enum.TextYAlignment.Top
LiveMonitorLbl.Text = " • Status Tower: Menunggu...\n • Gear Avatar Aktif: Memuat...\n • Total Unit Locked: 0\n • Total Unit Grade Terdeteksi: 0\n • Total Unit Traits Terdeteksi: 0\n • Total Unit Quirk Terdeteksi: 0"

task.spawn(function()
	local lastTime = tick()
	local frameCount = 0
	RunService.RenderStepped:Connect(function() frameCount = frameCount + 1 end)

	while task.wait(0.5) do
		local currentTime = tick()
		local fps = math.floor(frameCount / (currentTime - lastTime))
		frameCount = 0
		lastTime = currentTime

		local ping = 0
		pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)

		local totalPlayers = #Players:GetPlayers()
		pcall(function()
			local d = data()
			ProfileCard.Text = string.format(
				" • Nama Akun: %s\n • Saldo Uang: %s\n • Level Rebirth: %s",
				LocalPlayer.Name, tostring(d and d.Money or 0), tostring(d and d.Rebirth or 0)
			)
			
			local activeGear = _G.Mofenk.LiveGearName or "Luck Set"
			local towerState = _G.Mofenk.TowerLiveStatus or "Idle"
			
			local lockedUnits, gradeUnits, traitUnits, quirkUnits = 0, 0, 0, 0
			if d and d.Inventory then
				for _, u in pairs(d.Inventory) do
					if u.attributes and u.attributes.locked then lockedUnits = lockedUnits + 1 end
					if u.grade or (u.attributes and u.attributes.grade) then gradeUnits = gradeUnits + 1 end
					if u.trait or (u.attributes and u.attributes.trait) then traitUnits = traitUnits + 1 end
					if u.quirk or (u.attributes and u.attributes.quirk) then quirkUnits = quirkUnits + 1 end
				end
			end
			
			LiveMonitorLbl.Text = string.format(
				" • Status Tower: %s\n • Gear Avatar Aktif: %s\n • Total Unit Locked: %d\n • Total Unit Grade Terdeteksi: %d\n • Total Unit Traits Terdeteksi: %d\n • Total Unit Quirk Terdeteksi: %d",
				tostring(towerState), tostring(activeGear), lockedUnits, gradeUnits, traitUnits, quirkUnits
			)
		end)

		StatsProLbl.Text = string.format("⚡ FPS: %d  |  🌐 Ping: %d ms  |  👥 Server: %d", fps, ping, totalPlayers)
	end
end)

-- TAB 2: TOWER MANAGER (DENGAN KELUAR OTOMATIS & GANTI TOWER INSTAN)
AddSection(Tab2, "PENGATURAN TOWER & GEAR")
AddToggle(Tab2, "Auto Equip Best Unit Tower (Team)", "AutoEquipTower")

local towersList = {"Infinity Tower", "Dragon Tower", "Cursed Tower", "Pirate Tower", "Halloween Tower", "Event Tower Alpha"}
pcall(function()
	if TowersConfig and TowersConfig.GetAll then
		local all = TowersConfig.GetAll()
		if type(all) == "table" then
			towersList = {}
			for name, _ in pairs(all) do table.insert(towersList, name) end
		end
	end
end)

local SingleTowerBox = Instance.new("Frame")
SingleTowerBox.Parent = Tab2
SingleTowerBox.Size = UDim2.new(1, 0, 0, 100)
SingleTowerBox.BackgroundColor3 = Theme.Card
SingleTowerBox.BackgroundTransparency = 0.12
local STBC = Instance.new("UICorner")
STBC.CornerRadius = UDim.new(0, 10)
STBC.Parent = SingleTowerBox

AddToggle(SingleTowerBox, "Auto Tower (Single Target)", "AutoTower")

local SingleDDContainer = Instance.new("Frame")
SingleDDContainer.Parent = SingleTowerBox
SingleDDContainer.Position = UDim2.new(0, 14, 0, 50)
SingleDDContainer.Size = UDim2.new(1, -28, 0, 38)
SingleDDContainer.BackgroundTransparency = 1

local SDD_Lbl = Instance.new("TextLabel")
SDD_Lbl.Parent = SingleDDContainer
SDD_Lbl.Size = UDim2.new(0.4, 0, 1, 0)
SDD_Lbl.Text = "Target Tower:"
SDD_Lbl.TextColor3 = Theme.TextSub
SDD_Lbl.TextSize = 10
SDD_Lbl.Font = Enum.Font.GothamMedium
SDD_Lbl.TextXAlignment = Enum.TextXAlignment.Left
SDD_Lbl.BackgroundTransparency = 1

local SDD_Btn = Instance.new("TextButton")
SDD_Btn.Parent = SingleDDContainer
SDD_Btn.Position = UDim2.new(0.42, 0, 0.1, 0)
SDD_Btn.Size = UDim2.new(0.58, 0, 0.8, 0)
SDD_Btn.Text = tostring(_G.Mofenk.SelectedTowerSingle)
SDD_Btn.TextColor3 = Theme.AccentSec
SDD_Btn.TextSize = 10
SDD_Btn.Font = Enum.Font.GothamBold
SDD_Btn.BackgroundColor3 = Theme.Header
SDD_Btn.BackgroundTransparency = 0.2
local SDD_BC = Instance.new("UICorner")
SDD_BC.CornerRadius = UDim.new(0, 8)
SDD_BC.Parent = SDD_Btn

local SingleDropList = Instance.new("ScrollingFrame")
SingleDropList.Parent = Tab2.Parent
SingleDropList.Size = UDim2.new(0.4, 0, 0, 140)
SingleDropList.Position = UDim2.new(0.5, 0, 0, 0)
SingleDropList.BackgroundColor3 = Theme.Header
SingleDropList.BorderSizePixel = 0
SingleDropList.Visible = false
SingleDropList.ZIndex = 25
SingleDropList.CanvasSize = UDim2.new(0, 0, 0, #towersList * 30)
SingleDropList.ScrollBarThickness = 4
local SDLC = Instance.new("UICorner")
SDLC.CornerRadius = UDim.new(0, 8)
SDLC.Parent = SingleDropList
local SDLL = Instance.new("UIListLayout")
SDLL.Parent = SingleDropList

for _, tName in ipairs(towersList) do
	local optB = Instance.new("TextButton")
	optB.Parent = SingleDropList
	optB.Size = UDim2.new(1, 0, 0, 30)
	optB.Text = "  " .. tName
	optB.TextColor3 = Theme.Text
	optB.TextSize = 10
	optB.Font = Enum.Font.GothamMedium
	optB.TextXAlignment = Enum.TextXAlignment.Left
	optB.BackgroundTransparency = 1
	optB.ZIndex = 26

	optB.MouseButton1Click:Connect(function()
		_G.Mofenk.SelectedTowerSingle = tName
		SDD_Btn.Text = tName
		SingleDropList.Visible = false
		MofenkNotify("TOWER SWITCH", "Pilihan tower diganti ke: " .. tName .. ". Keluar dari tower aktif...", 2)
		pcall(function() if R.LeaveTower then R.LeaveTower:FireServer() end end)
	end)
end

SDD_Btn.MouseButton1Click:Connect(function()
	SingleDropList.Visible = not SingleDropList.Visible
end)

local MixTowerBox = Instance.new("Frame")
MixTowerBox.Parent = Tab2
MixTowerBox.Size = UDim2.new(1, 0, 0, 100)
MixTowerBox.BackgroundColor3 = Theme.Card
MixTowerBox.BackgroundTransparency = 0.12
local MTBC = Instance.new("UICorner")
MTBC.CornerRadius = UDim.new(0, 10)
MTBC.Parent = MixTowerBox

AddToggle(MixTowerBox, "Auto Mix / Random Tower (Multi-Select)", "AutoMixTower")

local MixDDContainer = Instance.new("Frame")
MixDDContainer.Parent = MixTowerBox
MixDDContainer.Position = UDim2.new(0, 14, 0, 50)
MixDDContainer.Size = UDim2.new(1, -28, 0, 38)
MixDDContainer.BackgroundTransparency = 1

local MDD_Lbl = Instance.new("TextLabel")
MDD_Lbl.Parent = MixDDContainer
MDD_Lbl.Size = UDim2.new(0.4, 0, 1, 0)
MDD_Lbl.Text = "Filter Rotasi:"
MDD_Lbl.TextColor3 = Theme.TextSub
MDD_Lbl.TextSize = 10
MDD_Lbl.Font = Enum.Font.GothamMedium
MDD_Lbl.TextXAlignment = Enum.TextXAlignment.Left
MDD_Lbl.BackgroundTransparency = 1

local MDD_Btn = Instance.new("TextButton")
MDD_Btn.Parent = MixDDContainer
MDD_Btn.Position = UDim2.new(0.42, 0, 0.1, 0)
MDD_Btn.Size = UDim2.new(0.58, 0, 0.8, 0)
MDD_Btn.Text = "Select All Towers (Active)"
MDD_Btn.TextColor3 = Theme.AccentSec
MDD_Btn.TextSize = 10
MDD_Btn.Font = Enum.Font.GothamBold
MDD_Btn.BackgroundColor3 = Theme.Header
MDD_Btn.BackgroundTransparency = 0.2
local MDD_BC = Instance.new("UICorner")
MDD_BC.CornerRadius = UDim.new(0, 8)
MDD_BC.Parent = MDD_Btn

AddScrollingDropdown(Tab2, "Pilih Gear Stat Set (Avatar):", {"Luck Set", "Damage Set", "Money Set", "Balanced Set"}, _G.Mofenk.GearSet, function(val)
	_G.Mofenk.GearSet = val
	_G.Mofenk.LiveGearName = val
	if R.EquipGear then
		pcall(function() R.EquipGear:FireServer(val) end)
	end
	MofenkNotify("GEAR SET", "Prioritas gear avatar diatur ke: " .. val, 2)
end)

-- TAB 3: ROLL & FARM
AddSection(Tab3, "AUTOMATED ROLL & FARMING")
AddToggle(Tab3, "Auto Roll Dadu (Cooldown Presisi)", "AutoRoll")
AddToggle(Tab3, "Auto Beli Dadu Terbaik", "AutoDice")
AddToggle(Tab3, "Auto Equip Dadu Terbaik", "AutoEquipDice")
AddToggle(Tab3, "Auto Rebirth Otomatis (Anti-Spam Aman)", "AutoRebirth")

-- TAB 4: INVENTARIS
AddSection(Tab4, "MANAJEMEN INVENTARIS & PENJUALAN")
AddToggle(Tab4, "Auto Jual Unit Sampah", "AutoSell")
AddToggle(Tab4, "Auto Jual Semua (Sell All Junk)", "SellAllJunk")
AddToggle(Tab4, "Auto Kunci Unit Langka (Auto Lock)", "AutoLock")
AddToggle(Tab4, "Auto Fusion Unit Otomatis", "AutoFuse")

-- TAB 5: PLOT & UNIT (PERBAIKAN FITUR LEVEL-UP UNIT)
AddSection(Tab5, "PLOT, UPGRADE & LEVEL UNIT")
AddToggle(Tab5, "Auto Ambil Saldo Plot (Collect Money)", "AutoCollect")
AddToggle(Tab5, "Smart Placement Unit (Equip Best)", "SmartPlace")
AddToggle(Tab5, "Auto Upgrade Pad", "AutoUpgrade")

local LevelBoxWrapper = Instance.new("Frame")
LevelBoxWrapper.Parent = Tab5
LevelBoxWrapper.Size = UDim2.new(1, 0, 0, 100)
LevelBoxWrapper.BackgroundColor3 = Theme.Card
LevelBoxWrapper.BackgroundTransparency = 0.12
local LBWC = Instance.new("UICorner")
LBWC.CornerRadius = UDim.new(0, 10)
LBWC.Parent = LevelBoxWrapper

local LBStroke = Instance.new("UIStroke")
LBStroke.Color = Theme.AccentSec
LBStroke.Transparency = 0.5
LBStroke.Parent = LevelBoxWrapper

local InnerLevelToggle = Instance.new("TextButton")
InnerLevelToggle.Parent = LevelBoxWrapper
InnerLevelToggle.Position = UDim2.new(0, 14, 0, 10)
InnerLevelToggle.Size = UDim2.new(1, -28, 0, 32)
InnerLevelToggle.BackgroundTransparency = 1
InnerLevelToggle.Text = ""

local ILT_Lbl = Instance.new("TextLabel")
ILT_Lbl.Parent = InnerLevelToggle
ILT_Lbl.Size = UDim2.new(0.7, 0, 1, 0)
ILT_Lbl.Text = "Auto Level Up Unit Slots (Base)"
ILT_Lbl.TextColor3 = Theme.Text
ILT_Lbl.TextSize = 10
ILT_Lbl.Font = Enum.Font.GothamMedium
ILT_Lbl.TextXAlignment = Enum.TextXAlignment.Left
ILT_Lbl.BackgroundTransparency = 1

local ILT_Sw = Instance.new("Frame")
ILT_Sw.Parent = InnerLevelToggle
ILT_Sw.Position = UDim2.new(1, -36, 0.5, -9)
ILT_Sw.Size = UDim2.new(0, 36, 0, 18)
ILT_Sw.BackgroundColor3 = _G.Mofenk.AutoLevel and Theme.AccentSec or Color3.fromRGB(55, 45, 75)
local ILTSwC = Instance.new("UICorner")
ILTSwC.CornerRadius = UDim.new(1, 0)
ILTSwC.Parent = ILT_Sw

local ILT_Knob = Instance.new("Frame")
ILT_Knob.Parent = ILT_Sw
ILT_Knob.Size = UDim2.new(0, 14, 0, 14)
ILT_Knob.Position = _G.Mofenk.AutoLevel and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
ILT_Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
local ILTKC = Instance.new("UICorner")
ILTKC.CornerRadius = UDim.new(1, 0)
ILTKC.Parent = ILT_Knob

InnerLevelToggle.MouseButton1Click:Connect(function()
	_G.Mofenk.AutoLevel = not _G.Mofenk.AutoLevel
	local state = _G.Mofenk.AutoLevel
	TweenService:Create(ILT_Sw, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.AccentSec or Color3.fromRGB(55, 45, 75)}):Play()
	TweenService:Create(ILT_Knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
end)

local DropdownInBox = Instance.new("Frame")
DropdownInBox.Parent = LevelBoxWrapper
DropdownInBox.Position = UDim2.new(0, 14, 0, 50)
DropdownInBox.Size = UDim2.new(1, -28, 0, 38)
DropdownInBox.BackgroundTransparency = 1

local DIB_Lbl = Instance.new("TextLabel")
DIB_Lbl.Parent = DropdownInBox
DIB_Lbl.Size = UDim2.new(0.4, 0, 1, 0)
DIB_Lbl.Text = "Batas Target Level:"
DIB_Lbl.TextColor3 = Theme.TextSub
DIB_Lbl.TextSize = 10
DIB_Lbl.Font = Enum.Font.GothamMedium
DIB_Lbl.TextXAlignment = Enum.TextXAlignment.Left
DIB_Lbl.BackgroundTransparency = 1

local DIB_Btn = Instance.new("TextButton")
DIB_Btn.Parent = DropdownInBox
DIB_Btn.Position = UDim2.new(0.42, 0, 0.1, 0)
DIB_Btn.Size = UDim2.new(0.58, 0, 0.8, 0)
DIB_Btn.Text = tostring(_G.Mofenk.LevelLimit)
DIB_Btn.TextColor3 = Theme.AccentSec
DIB_Btn.TextSize = 10
DIB_Btn.Font = Enum.Font.GothamBold
DIB_Btn.BackgroundColor3 = Theme.Header
DIB_Btn.BackgroundTransparency = 0.2
local DIBC = Instance.new("UICorner")
DIBC.CornerRadius = UDim.new(0, 8)
DIBC.Parent = DIB_Btn

local LevelDropList = Instance.new("ScrollingFrame")
LevelDropList.Parent = Tab5.Parent
LevelDropList.Size = UDim2.new(0.35, 0, 0, 130)
LevelDropList.Position = UDim2.new(0.55, 0, 0, 0)
LevelDropList.BackgroundColor3 = Theme.Header
LevelDropList.BorderSizePixel = 0
LevelDropList.Visible = false
LevelDropList.ZIndex = 25
LevelDropList.CanvasSize = UDim2.new(0, 0, 0, 6 * 30)
LevelDropList.ScrollBarThickness = 4
local LDLC = Instance.new("UICorner")
LDLC.CornerRadius = UDim.new(0, 8)
LDLC.Parent = LevelDropList
local LDLL = Instance.new("UIListLayout")
LDLL.Parent = LevelDropList

for _, lvlOpt in ipairs({10, 25, 50, 100, 200, 500}) do
	local OptB = Instance.new("TextButton")
	OptB.Parent = LevelDropList
	OptB.Size = UDim2.new(1, 0, 0, 30)
	OptB.Text = "  Level " .. tostring(lvlOpt)
	OptB.TextColor3 = Theme.Text
	OptB.TextSize = 10
	OptB.Font = Enum.Font.GothamMedium
	OptB.TextXAlignment = Enum.TextXAlignment.Left
	OptB.BackgroundTransparency = 1
	OptB.ZIndex = 26

	OptB.MouseButton1Click:Connect(function()
		_G.Mofenk.LevelLimit = lvlOpt
		DIB_Btn.Text = tostring(lvlOpt)
		LevelDropList.Visible = false
		MofenkNotify("LEVEL UNIT", "Batas level slot diatur ke: " .. lvlOpt, 2)
	end)
end

DIB_Btn.MouseButton1Click:Connect(function()
	LevelDropList.Visible = not LevelDropList.Visible
end)

-- TAB 6: QUIRK & POTION
AddSection(Tab6, "QUIRK, TRAIT, GRADE & POTION")
AddToggle(Tab6, "Auto Roll Quirk", "AutoQuirk")
AddToggle(Tab6, "Auto Roll Trait (Sesuai Filter)", "AutoTrait")
AddToggle(Tab6, "Auto Roll Grade (Sesuai Filter)", "AutoGrade")
AddToggle(Tab6, "Auto Gunakan Potion & Boosts", "AutoPotion")

-- TAB 7: SERVER & CLIENT
AddSection(Tab7, "SERVER HOP, ANTI-AFK & PERFORMANCE")
AddToggle(Tab7, "Anti-AFK Proteksi", "AntiAFK")
AddToggle(Tab7, "Auto Reconnect saat Terputus", "AutoReconnect")
AddToggle(Tab7, "Matikan 3D Rendering (FPS Boost)", "Disable3DRender")

local BtnHop = Instance.new("TextButton")
BtnHop.Parent = Tab7
BtnHop.Size = UDim2.new(1, 0, 0, 40)
BtnHop.Text = "Pindah Server Kosong (Server Hop)"
BtnHop.TextColor3 = Theme.Text
BtnHop.TextSize = 10
BtnHop.Font = Enum.Font.GothamBold
BtnHop.BackgroundColor3 = Theme.Card
BtnHop.BackgroundTransparency = 0.12
local BHB = Instance.new("UICorner")
BHB.CornerRadius = UDim.new(0, 10)
BHB.Parent = BtnHop
BtnHop.MouseButton1Click:Connect(function()
	MofenkNotify("SERVER", "Mencari server optimal...", 2)
	local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
	local success, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(Api)) end)
	if success and res and res.data then
		for _, s in ipairs(res.data) do
			if s.playing < s.maxPlayers and s.id ~= game.JobId then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
				return
			end
		end
	end
	MofenkNotify("SERVER", "Server penuh atau tidak ditemukan.", 3)
end)

-- TAB 8: REMOTE SPY (STATUS INFO)
AddSection(Tab8, "REMOTE SPY & PACKET INSPECTOR")

local SpyDesc = Instance.new("TextLabel")
SpyDesc.Parent = Tab8
SpyDesc.Size = UDim2.new(1, 0, 0, 42)
SpyDesc.BackgroundTransparency = 1
SpyDesc.Text = "Fitur konsol Delta untuk melacak jalur RemoteEvent/RemoteFunction diaktifkan via mode aman otomatis."
SpyDesc.TextColor3 = Theme.TextSub
SpyDesc.TextSize = 10
SpyDesc.Font = Enum.Font.GothamMedium
SpyDesc.TextXAlignment = Enum.TextXAlignment.Left
SpyDesc.TextWrapped = true

local BtnScan = Instance.new("TextButton")
BtnScan.Parent = Tab8
BtnScan.Size = UDim2.new(1, 0, 0, 40)
BtnScan.Text = "Cek Status Jaringan Remote"
BtnScan.TextColor3 = Theme.AccentSec
BtnScan.TextSize = 10
BtnScan.Font = Enum.Font.GothamBold
BtnScan.BackgroundColor3 = Theme.Card
BtnScan.BackgroundTransparency = 0.12
local BSB = Instance.new("UICorner")
BSB.CornerRadius = UDim.new(0, 10)
BSB.Parent = BSB

BtnScan.MouseButton1Click:Connect(function()
	MofenkNotify("REMOTE SPY", "Jalur remote game terhubung stabil!", 3)
end)

-- TAB 9: CONFIG & WEBHOOK
AddSection(Tab9, "MANAJEMEN CONFIG & DISCORD WEBHOOK")

AddToggle(Tab9, "Auto-Load Config Terakhir (On/Off)", "AutoLoadConfig")

local WebhookContainer = Instance.new("Frame")
WebhookContainer.Parent = Tab9
WebhookContainer.Size = UDim2.new(1, 0, 0, 46)
WebhookContainer.BackgroundColor3 = Theme.Card
WebhookContainer.BackgroundTransparency = 0.12
local WHC = Instance.new("UICorner")
WHC.CornerRadius = UDim.new(0, 10)
WHC.Parent = WebhookContainer

local WH_Lbl = Instance.new("TextLabel")
WH_Lbl.Parent = WebhookContainer
WH_Lbl.Position = UDim2.new(0, 14, 0, 0)
WH_Lbl.Size = UDim2.new(0.35, 0, 1, 0)
WH_Lbl.Text = "Discord Webhook:"
WH_Lbl.TextColor3 = Theme.Text
WH_Lbl.TextSize = 10
WH_Lbl.Font = Enum.Font.GothamMedium
WH_Lbl.TextXAlignment = Enum.TextXAlignment.Left
WH_Lbl.BackgroundTransparency = 1

local WH_Box = Instance.new("TextBox")
WH_Box.Parent = WebhookContainer
WH_Box.Position = UDim2.new(0.37, 0, 0.15, 0)
WH_Box.Size = UDim2.new(0.6, 0, 0.7, 0)
WH_Box.Text = _G.Mofenk.WebhookUrl
WH_Box.PlaceholderText = "Paste URL Webhook di sini..."
WH_Box.TextColor3 = Theme.AccentSec
WH_Box.TextSize = 9
WH_Box.Font = Enum.Font.GothamBold
WH_Box.BackgroundColor3 = Theme.Header
WH_Box.BackgroundTransparency = 0.2
local WHBC = Instance.new("UICorner")
WHBC.CornerRadius = UDim.new(0, 8)
WHBC.Parent = WH_Box

WH_Box.FocusLost:Connect(function()
	_G.Mofenk.WebhookUrl = WH_Box.Text
	MofenkNotify("WEBHOOK", "URL Webhook diperbarui!", 2)
end)

local ConfigNameContainer = Instance.new("Frame")
ConfigNameContainer.Parent = Tab9
ConfigNameContainer.Size = UDim2.new(1, 0, 0, 46)
ConfigNameContainer.BackgroundColor3 = Theme.Card
ConfigNameContainer.BackgroundTransparency = 0.12
local CNC = Instance.new("UICorner")
CNC.CornerRadius = UDim.new(0, 10)
CNC.Parent = ConfigNameContainer

local CNC_Lbl = Instance.new("TextLabel")
CNC_Lbl.Parent = ConfigNameContainer
CNC_Lbl.Position = UDim2.new(0, 14, 0, 0)
CNC_Lbl.Size = UDim2.new(0.4, 0, 1, 0)
CNC_Lbl.Text = "Nama Config:"
CNC_Lbl.TextColor3 = Theme.Text
CNC_Lbl.TextSize = 10
CNC_Lbl.Font = Enum.Font.GothamMedium
CNC_Lbl.TextXAlignment = Enum.TextXAlignment.Left
CNC_Lbl.BackgroundTransparency = 1

local CNC_Box = Instance.new("TextBox")
CNC_Box.Parent = ConfigNameContainer
CNC_Box.Position = UDim2.new(0.42, 0, 0.15, 0)
CNC_Box.Size = UDim2.new(0.55, 0, 0.7, 0)
CNC_Box.Text = _G.Mofenk.CurrentConfigName
CNC_Box.TextColor3 = Theme.AccentSec
CNC_Box.TextSize = 10
CNC_Box.Font = Enum.Font.GothamBold
CNC_Box.BackgroundColor3 = Theme.Header
CNC_Box.BackgroundTransparency = 0.2
local CNBC = Instance.new("UICorner")
CNBC.CornerRadius = UDim.new(0, 8)
CNBC.Parent = CNC_Box

CNC_Box.FocusLost:Connect(function()
	if CNC_Box.Text ~= "" then
		_G.Mofenk.CurrentConfigName = CNC_Box.Text
		MofenkNotify("CONFIG", "Nama config diatur ke: " .. _G.Mofenk.CurrentConfigName, 2)
	end
end)

local function AddConfigButton(text, color, callback)
	local Btn = Instance.new("TextButton")
	Btn.Parent = Tab9
	Btn.Size = UDim2.new(1, 0, 0, 40)
	Btn.Text = text
	Btn.TextColor3 = color
	Btn.TextSize = 10
	Btn.Font = Enum.Font.GothamBold
	Btn.BackgroundColor3 = Theme.Card
	Btn.BackgroundTransparency = 0.12
	local BC = Instance.new("UICorner")
	BC.CornerRadius = UDim.new(0, 10)
	BC.Parent = Btn
	Btn.MouseButton1Click:Connect(callback)
end

AddConfigButton("Simpan Konfigurasi (Save Config)", Theme.Text, function()
	if SaveConfig(_G.Mofenk.CurrentConfigName) then
		MofenkNotify("CONFIG", "Config '" .. _G.Mofenk.CurrentConfigName .. "' berhasil disimpan!", 3)
	else
		MofenkNotify("CONFIG", "Gagal menyimpan config.", 3)
	end
end)

AddConfigButton("Muat Konfigurasi (Load Config)", Theme.AccentSec, function()
	if LoadConfig(_G.Mofenk.CurrentConfigName) then
		UIRescale.Scale = _G.Mofenk.UIScale
		CNC_Box.Text = _G.Mofenk.CurrentConfigName
		MofenkNotify("CONFIG", "Config '" .. _G.Mofenk.CurrentConfigName .. "' berhasil dimuat!", 3)
	else
		MofenkNotify("CONFIG", "File config tidak ditemukan.", 3)
	end
end)

AddConfigButton("Kirim Tes Webhook Discord", Color3.fromRGB(0, 255, 150), function()
	if _G.Mofenk.WebhookUrl ~= "" then
		local dataToSend = {
			["content"] = "🔔 **MofenkHub Aesthetic Edition**\nPlayer: " .. LocalPlayer.Name .. "\nGame: Anime Dice\nStatus: Webhook Terhubung Aktif!"
		}
		local success = pcall(function()
			HttpService:PostAsync(_G.Mofenk.WebhookUrl, HttpService:JSONEncode(dataToSend))
		end)
		if success then
			MofenkNotify("WEBHOOK", "Pesan tes webhook berhasil dikirim!", 3)
		else
			MofenkNotify("WEBHOOK", "Gagal mengirim webhook (Cek URL).", 3)
		end
	else
		MofenkNotify("WEBHOOK", "Masukkan URL webhook terlebih dahulu!", 3)
	end
end)

AddConfigButton("Hapus Konfigurasi (Delete Config)", Color3.fromRGB(255, 75, 75), function()
	local fileName = GetConfigFileName(_G.Mofenk.CurrentConfigName)
	if delfile and pcall(function() delfile(fileName) end) then
		MofenkNotify("CONFIG", "Config '" .. _G.Mofenk.CurrentConfigName .. "' berhasil dihapus!", 3)
	else
		MofenkNotify("CONFIG", "Gagal menghapus file config.", 3)
	end
end)

-- 10. TOMBOL APUNG "F"
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "MofenkToggleGui"
ToggleGui.Parent = parentGui
ToggleGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = Theme.Header
ToggleBtn.BackgroundTransparency = 0.1
ToggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
ToggleBtn.Size = UDim2.new(0, 72, 0, 72)
ToggleBtn.Text = "F"
ToggleBtn.TextColor3 = Theme.AccentSec
ToggleBtn.TextSize = 24
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true
local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 18)
TC.Parent = ToggleBtn
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- 11. THREAD UTAMA EKSEKUSI BACKEND
task.spawn(function()
	task.spawn(function()
		pcall(function()
			local vu = game:GetService("VirtualUser")
			LocalPlayer.Idled:Connect(function()
				if _G.Mofenk.AntiAFK then
					vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
					task.wait(1)
					vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
				end
			end)
		end)
	end)

	task.spawn(function()
		pcall(function()
			CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
				if child.Name == "ErrorPrompt" and _G.Mofenk.AutoReconnect then
					task.wait(1)
					pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
				end
			end)
		end)
	end)

	MofenkNotify("MOFENK HUB", "Sistem Aesthetic Suite Siap Digunakan!", 4)
	while task.wait(2.0) do
		if _G.__ANIMEDICE ~= generation then break end

		pcall(function()
			RunService:Set3dRenderingEnabled(not _G.Mofenk.Disable3DRender)
		end)

		if _G.Mofenk.AutoRoll and R.RollDice then
			pcall(function() R.RollDice:InvokeServer() end)
		end

		if (_G.Mofenk.AutoDice or _G.Mofenk.AutoEquipDice) and Dice then
			pcall(function()
				local d = data()
				local allDice = Dice.GetAll()
				if d and allDice then
					if _G.Mofenk.AutoDice and R.BuyDice then
						local bestKey, bestPrice, bestLuck = nil, 0, 0
						for key, def in pairs(allDice) do
							local price = tonumber(def.price) or 0
							local luck = tonumber(def.luck) or 0
							if price > 0 and not d.OwnedDice[key] and d.Money >= price and luck > bestLuck then
								bestKey, bestPrice, bestLuck = key, price, luck
							end
						end
						if bestKey then
							R.BuyDice:FireServer(bestKey)
							task.wait(0.3)
						end
					end

					if _G.Mofenk.AutoEquipDice and R.EquipDice then
						local ownedBestKey, maxLuck = "-", 0
						for key, def in pairs(allDice) do
							if d.OwnedDice[key] and (tonumber(def.luck) or 0) > maxLuck then
								maxLuck = tonumber(def.luck) or 0
								ownedBestKey = key
							end
						end
						if ownedBestKey ~= "-" and d.Dice ~= ownedBestKey then
							R.EquipDice:FireServer(ownedBestKey)
						end
					end
				end
			end)
		end

		if _G.Mofenk.AutoCollect and R.CollectBalance then
			pcall(function()
				local d = data()
				if d and d.Slots then
					for key, _ in pairs(d.Slots) do
						R.CollectBalance:FireServer(tonumber(key))
					end
				end
				if R.EquipBest then R.EquipBest:FireServer() end
			end)
		end

		if (_G.Mofenk.AutoSell or _G.Mofenk.SellAllJunk) and R.SellInventory then
			pcall(function()
				local d = data()
				if d and d.Inventory and UnitClass and UnitClass.entries then
					local listToSell = {}
					for id, u in pairs(d.Inventory) do
						local e = UnitClass.entries[u.name]
						if e and not e.limited then
							local isProtected = (u.attributes and u.attributes.locked) or false
							for _, slot in pairs(d.Slots) do
								if slot.unitId == id then isProtected = true end
							end
							if not isProtected then
								table.insert(listToSell, id)
								if #listToSell >= 150 then break end
							end
						end
					end
					if #listToSell > 0 then R.SellInventory:InvokeServer(listToSell) end
				end
			end)
		end

		-- Logika Perbaikan Auto Level Up Unit Slot
		if _G.Mofenk.AutoLevel and R.LevelUpSlot then
			pcall(function()
				local d = data()
				if d and d.Slots then
					for key, slot in pairs(d.Slots) do
						if slot and slot.unitId and slot.level and slot.level < _G.Mofenk.LevelLimit then
							R.LevelUpSlot:FireServer(tonumber(key))
							task.wait(0.3)
						end
					end
				end
			end)
		end

		if _G.Mofenk.AutoUpgrade and R.BuyUpgrade then
			pcall(function() R.BuyUpgrade:FireServer() end)
		end

		-- Logika Tower Cerdas (Keluar Otomatis & Ganti Target Instan)
		local isInGameTower = false
		pcall(function()
			if workspace:FindFirstChild("Map") or workspace:FindFirstChild("Enemies") or workspace:FindFirstChild("TowersGame") then
				isInGameTower = true
			end
		end)

		if not isInGameTower then
			if _G.Mofenk.AutoTower and R.PlayTower then
				pcall(function()
					local target = _G.Mofenk.SelectedTowerSingle
					_G.Mofenk.TowerLiveStatus = "Masuk: " .. target
					_G.Mofenk.TowerCurrentLevel = _G.Mofenk.TowerCurrentLevel + 1
					R.PlayTower:InvokeServer(target)
				end)
				task.wait(10)
			elseif _G.Mofenk.AutoMixTower and R.PlayTower then
				pcall(function()
					local chosen = towersList[math.random(1, #towersList)]
					_G.Mofenk.TowerLiveStatus = "Mix: " .. chosen
					_G.Mofenk.TowerCurrentLevel = _G.Mofenk.TowerCurrentLevel + 1
					R.PlayTower:InvokeServer(chosen)
				end)
				task.wait(10)
			else
				_G.Mofenk.TowerLiveStatus = "Standby"
			end
		else
			_G.Mofenk.TowerLiveStatus = "Sedang Bertarung di Tower"
		end

		if _G.Mofenk.AutoEquipTower and R.EquipTowerUnit then
			pcall(function() R.EquipTowerUnit:FireServer() end)
		end

		if _G.Mofenk.AutoRebirth and R.Rebirth then
			pcall(function()
				local d = data()
				if d and tonumber(d.Money) and d.Money >= _G.Mofenk.RebirthRequirement then
					R.Rebirth:FireServer()
					task.wait(3)
				end
			end)
		end
	end
end)
