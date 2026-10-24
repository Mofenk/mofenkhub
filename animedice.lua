-- ===================================================================== --
-- 👑 MOFENKHUB V35.0 — ULTIMATE PROFESSIONAL CONFIG EDITION
-- Game: Anime Dice | Fully Synchronized Engine, Level Limit, Potion/Boosts
-- ===================================================================== --

task.wait(1.5)
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local Stats             = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local parentGui = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- 1. BERSIHKAN INSTANCE LAMA AGAR BERSIH DARI DUPLIKAT
for _, v in pairs(parentGui:GetChildren()) do
	if v.Name == "MofenkUltraHubV35" or v.Name == "MofenkToggleGui" or v.Name == "MofenkNotifyGui" then
		pcall(function() v:Destroy() end)
	end
end

-- 2. KONFIGURASI GLOBAL (DEFAULT AMAN / MATI DI AWAL)
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

_G.Mofenk = {
	-- Tampilan & Skala UI
	ThemePreset     = "Spectrum Dark",
	UIScale         = 1.0,
	-- Farm & Roll
	AutoRoll        = false,
	AutoDice        = false,
	AutoEquipDice   = false,
	-- Jual & Inventaris
	AutoSell        = false,
	SellAllJunk     = false,
	AutoLock        = false,
	AutoFuse        = false,
	-- Tower & Plot
	AutoTower       = false,
	TowerName       = "Infinity Tower",
	AutoCollect     = false,
	SmartPlace      = false,
	AutoLevel       = false,
	LevelLimit      = 50,       -- Batas maksimal level unit yang diinginkan
	-- Upgrade & Rebirth
	AutoUpgrade     = false,
	AutoRebirth     = false,
	RebirthMult     = 1,
	-- Quirk, Traits, Grade & Potion
	AutoQuirk       = false,
	AutoTrait       = false,
	AutoGrade       = false,
	AutoPotion      = false,
	-- Quest & Redeem
	AutoCodes       = false,
	AutoClaim       = false,
	AutoQuests      = false,
}

-- 3. SISTEM CONFIG (SAVE & LOAD TEKS / JSON)
local CONFIG_FILE_NAME = "MofenkAnimeDice_ConfigV35.json"

local function SaveConfig()
	local success, encoded = pcall(function() return HttpService:JSONEncode(_G.Mofenk) end)
	if success and writefile then
		pcall(function() writefile(CONFIG_FILE_NAME, encoded) end)
		return true
	end
	return false
end

local function LoadConfig()
	if readfile and pcall(function() return readfile(CONFIG_FILE_NAME) end) then
		local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE_NAME)) end)
		if success and type(decoded) == "table" then
			for k, v in pairs(decoded) do
				if _G.Mofenk[k] ~= nil then _G.Mofenk[k] = v end
			end
			return true
		end
	end
	return false
end

LoadConfig()

-- 4. MAPPING REMOTE GAME & MODUL ASLI FILE
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
	LevelUpSlot     = Network and safeFind(Network, "PlotService.RE.LevelUpSlot"),
	Rebirth         = Network and safeFind(Network, "RebirthService.RE.Rebirth"),
	BuyUpgrade      = Network and safeFind(Network, "RE.BuyUpgrade"),
	SellInventory   = Network and safeFind(Network, "SellService.RF.SellInventory"),
	PlayTower       = Network and (safeFind(Network, "Towers.RF.PlayTower") or safeFind(Network, "Towers.RE.PlayTower")),
	Fuse            = Network and safeFind(Network, "FusingService.RE.Fuse"),
	BoostUse        = Network and safeFind(Network, "BoostService.RE.Use"),
}

local DataController, TowersConfig, Dice, UnitConfig, BoostConfig
pcall(function()
	if Framework then
		DataController = require(Framework.Features.Data.DataController)
		TowersConfig   = require(Framework.Features.Towers.Towers)
		Dice           = require(Framework.Features.Rolling.Dice)
		UnitConfig     = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig)
		BoostConfig    = require(Framework.Features.Inventory.Kinds.Boost.BoostConfig)
	end
end)

local function data()
	local ok, res = pcall(function() return DataController.___X end)
	return ok and res or nil
end

-- 5. TEMA VISUAL MODERN & PROFESIONAL
local Themes = {
	["Spectrum Dark"] = {
		Bg        = Color3.fromRGB(13, 13, 19),
		Header    = Color3.fromRGB(19, 19, 28),
		Card      = Color3.fromRGB(25, 25, 36),
		Accent    = Color3.fromRGB(0, 220, 255),
		AccentSec = Color3.fromRGB(120, 50, 240),
		Text      = Color3.fromRGB(245, 245, 250),
		TextSub   = Color3.fromRGB(145, 145, 170)
	},
	["Midnight Crimson"] = {
		Bg        = Color3.fromRGB(16, 11, 11),
		Header    = Color3.fromRGB(23, 15, 15),
		Card      = Color3.fromRGB(32, 20, 20),
		Accent    = Color3.fromRGB(255, 75, 75),
		AccentSec = Color3.fromRGB(190, 35, 90),
		Text      = Color3.fromRGB(250, 242, 242),
		TextSub   = Color3.fromRGB(170, 145, 145)
	},
	["Emerald Cyber"] = {
		Bg        = Color3.fromRGB(10, 16, 13),
		Header    = Color3.fromRGB(14, 23, 18),
		Card      = Color3.fromRGB(20, 32, 25),
		Accent    = Color3.fromRGB(0, 255, 140),
		AccentSec = Color3.fromRGB(35, 160, 120),
		Text      = Color3.fromRGB(242, 250, 245),
		TextSub   = Color3.fromRGB(145, 170, 155)
	}
}

local Theme = Themes[_G.Mofenk.ThemePreset] or Themes["Spectrum Dark"]

-- 6. SISTEM NOTIFIKASI TOAST ELEGAN
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "MofenkNotifyGui"
NotifyGui.Parent = parentGui
NotifyGui.ResetOnSpawn = false

local NotifyContainer = Instance.new("Frame")
NotifyContainer.Parent = NotifyGui
NotifyContainer.Position = UDim2.new(1, -290, 0, 20)
NotifyContainer.Size = UDim2.new(0, 280, 1, -40)
NotifyContainer.BackgroundTransparency = 1

local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.Parent = NotifyContainer
NotifyLayout.Padding = UDim.new(0, 10)

local function MofenkNotify(title, message, duration)
	duration = duration or 3.5
	local Card = Instance.new("Frame")
	Card.Parent = NotifyContainer
	Card.Size = UDim2.new(1, 0, 0, 52)
	Card.BackgroundColor3 = Theme.Card
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 8)
	Corner.Parent = Card
	
	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Theme.Accent
	Stroke.Transparency = 0.5
	Stroke.Parent = Card
	
	local TitleLbl = Instance.new("TextLabel")
	TitleLbl.Parent = Card
	TitleLbl.Position = UDim2.new(0, 12, 0, 6)
	TitleLbl.Size = UDim2.new(1, -24, 0, 18)
	TitleLbl.Text = title
	TitleLbl.TextColor3 = Theme.Accent
	TitleLbl.TextSize = 11
	TitleLbl.Font = Enum.Font.GothamBold
	TitleLbl.BackgroundTransparency = 1
	TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local MsgLbl = Instance.new("TextLabel")
	MsgLbl.Parent = Card
	MsgLbl.Position = UDim2.new(0, 12, 0, 24)
	MsgLbl.Size = UDim2.new(1, -24, 0, 22)
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

-- 7. UI UTAMA (MODULAR PANEL DENGAN SKALA UI & LOGO VEKTOR)
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
MainFrame.Size = UDim2.new(0, 800, 0, 540)
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -270)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Theme.Accent
MainStroke.Parent = MainFrame

-- Topbar
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Theme.Header

local LogoIcon = Instance.new("Frame")
LogoIcon.Parent = TopBar
LogoIcon.Position = UDim2.new(0, 12, 0.5, -16)
LogoIcon.Size = UDim2.new(0, 32, 0, 32)
LogoIcon.BackgroundColor3 = Theme.Accent
local LIC = Instance.new("UICorner")
LIC.CornerRadius = UDim.new(0, 8)
LIC.Parent = LogoIcon

local LogoInner = Instance.new("Frame")
LogoInner.Parent = LogoIcon
LogoInner.Position = UDim2.new(0.5, -7, 0.5, -7)
LogoInner.Size = UDim2.new(0, 14, 0, 14)
LogoInner.BackgroundColor3 = Theme.Bg
local LIIC = Instance.new("UICorner")
LIIC.CornerRadius = UDim.new(0, 4)
LIIC.Parent = LogoInner

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Position = UDim2.new(0, 54, 0, 0)
Title.Size = UDim2.new(0, 500, 1, 0)
Title.Text = "MOFENK HUB — ANIME DICE MASTER SUITE"
Title.TextColor3 = Theme.Text
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.Position = UDim2.new(1, -42, 0, 10)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Text
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundColor3 = Theme.Card
local CC = Instance.new("UICorner")
CC.CornerRadius = UDim.new(0, 6)
CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Sidebar Group Nav
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 10, 0, 56)
Sidebar.Size = UDim2.new(0, 180, 1, -66)
Sidebar.BackgroundColor3 = Theme.Header
Sidebar.ScrollBarThickness = 2
local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.Padding = UDim.new(0, 4)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 198, 0, 56)
ContentArea.Size = UDim2.new(1, -208, 1, -66)
ContentArea.BackgroundColor3 = Theme.Header

local TabFrames = {}
local function CreateTab(name, order)
	local Btn = Instance.new("TextButton")
	Btn.Parent = Sidebar
	Btn.Size = UDim2.new(1, -4, 0, 32)
	Btn.Text = "   " + name
	Btn.Text = "   " .. name
	Btn.TextColor3 = Theme.TextSub
	Btn.TextSize = 10
	Btn.Font = Enum.Font.GothamMedium
	Btn.TextXAlignment = Enum.TextXAlignment.Left
	Btn.BackgroundColor3 = Theme.Card
	Btn.LayoutOrder = order
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 6)
	Corner.Parent = Btn

	local Scroll = Instance.new("ScrollingFrame")
	Scroll.Parent = ContentArea
	Scroll.Size = UDim2.new(1, -10, 1, -10)
	Scroll.Position = UDim2.new(0, 5, 0, 5)
	Scroll.BackgroundTransparency = 1
	Scroll.ScrollBarThickness = 4
	Scroll.ScrollBarImageColor3 = Theme.Accent
	Scroll.Visible = false
	local Lay = Instance.new("UIListLayout")
	Lay.Parent = Scroll
	Lay.Padding = UDim.new(0, 6)
	
	TabFrames[name] = Scroll

	Btn.MouseButton1Click:Connect(function()
		for n, f in pairs(TabFrames) do f.Visible = (n == name) end
		for _, b in ipairs(Sidebar:GetChildren()) do
			if b:IsA("TextButton") then
				b.TextColor3 = Theme.TextSub
				b.BackgroundColor3 = Theme.Card
			end
		end
		Btn.TextColor3 = Theme.Text
		Btn.BackgroundColor3 = Theme.AccentSec
	end)
	return Scroll
end

local function AddSection(parent, text)
	local L = Instance.new("TextLabel")
	L.Parent = parent
	L.Size = UDim2.new(1, 0, 0, 22)
	L.Text = text
	L.TextColor3 = Theme.Accent
	L.TextSize = 10
	L.Font = Enum.Font.GothamBold
	L.TextXAlignment = Enum.TextXAlignment.Left
	L.BackgroundTransparency = 1
end

local function AddToggle(parent, text, flag)
	local state = _G.Mofenk[flag] or false
	local F = Instance.new("Frame")
	F.Parent = parent
	F.Size = UDim2.new(1, 0, 0, 34)
	F.BackgroundColor3 = Theme.Card
	local C = Instance.new("UICorner")
	C.CornerRadius = UDim.new(0, 6)
	C.Parent = F

	local L = Instance.new("TextLabel")
	L.Parent = F
	L.Position = UDim2.new(0, 12, 0, 0)
	L.Size = UDim2.new(0.7, 0, 1, 0)
	L.Text = text
	L.TextColor3 = Theme.Text
	L.TextSize = 10
	L.Font = Enum.Font.GothamMedium
	L.TextXAlignment = Enum.TextXAlignment.Left
	L.BackgroundTransparency = 1

	local Sw = Instance.new("TextButton")
	Sw.Parent = F
	Sw.Position = UDim2.new(1, -42, 0.5, -9)
	Sw.Size = UDim2.new(0, 32, 0, 18)
	Sw.Text = ""
	Sw.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(45, 45, 60)
	local SwC = Instance.new("UICorner")
	SwC.CornerRadius = UDim.new(1, 0)
	SwC.Parent = Sw

	local Knob = Instance.new("Frame")
	Knob.Parent = Sw
	Knob.Size = UDim2.new(0, 14, 0, 14)
	Knob.Position = state and UDim2.new(1, -15, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
	Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	local KC = Instance.new("UICorner")
	KC.CornerRadius = UDim.new(1, 0)
	KC.Parent = Knob

	Sw.MouseButton1Click:Connect(function()
		state = not state
		_G.Mofenk[flag] = state
		TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(45, 45, 60)}):Play()
		TweenService:Create(Knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -15, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
	end)
end

-- TAB PEMBUATAN DENGAN JUDUL TEKS DI BAGIAN ATAS
local Tab1 = CreateTab("Dashboard & Profil", 1)
local Tab2 = CreateTab("Roll & Automasi", 2)
local Tab3 = CreateTab("Inventaris & Jual", 3)
local Tab4 = CreateTab("Tower & Plot", 4)
local Tab5 = CreateTab("Upgrade & Rebirth", 5)
local Tab6 = CreateTab("Quirk & Boosts", 6)
local Tab7 = CreateTab("Server & Debugger", 7)
local Tab8 = CreateTab("Konfigurasi & Tema", 8)

TabFrames["Dashboard & Profil"].Visible = true

-- TAB 1: DASHBOARD & PROFIL
AddSection(Tab1, "PROFIL PENGGUNA & KINERJA LIVE")

local ProfileWrapper = Instance.new("Frame")
ProfileWrapper.Parent = Tab1
ProfileWrapper.Size = UDim2.new(1, 0, 0, 125)
ProfileWrapper.BackgroundColor3 = Theme.Card
local PWC = Instance.new("UICorner")
PWC.CornerRadius = UDim.new(0, 8)
PWC.Parent = ProfileWrapper

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Parent = ProfileWrapper
AvatarImg.Position = UDim2.new(0, 12, 0, 12)
AvatarImg.Size = UDim2.new(0, 68, 0, 68)
AvatarImg.BackgroundColor3 = Theme.Header
AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
local AIC = Instance.new("UICorner")
AIC.CornerRadius = UDim.new(1, 0)
AIC.Parent = AvatarImg

local ProfileCard = Instance.new("TextLabel")
ProfileCard.Parent = ProfileWrapper
ProfileCard.Position = UDim2.new(0, 92, 0, 10)
ProfileCard.Size = UDim2.new(1, -102, 0, 72)
ProfileCard.BackgroundTransparency = 1
ProfileCard.TextColor3 = Theme.Text
ProfileCard.TextSize = 10
ProfileCard.Font = Enum.Font.GothamMedium
ProfileCard.TextXAlignment = Enum.TextXAlignment.Left
ProfileCard.TextYAlignment = Enum.TextYAlignment.Top

local StatsProBar = Instance.new("Frame")
StatsProBar.Parent = ProfileWrapper
StatsProBar.Position = UDim2.new(0, 12, 0, 88)
StatsProBar.Size = UDim2.new(1, -24, 0, 26)
StatsProBar.BackgroundColor3 = Theme.Header
local SPBC = Instance.new("UICorner")
SPBC.CornerRadius = UDim.new(0, 6)
SPBC.Parent = StatsProBar

local StatsProLbl = Instance.new("TextLabel")
StatsProLbl.Parent = StatsProBar
StatsProLbl.Size = UDim2.new(1, 0, 1, 0)
StatsProLbl.BackgroundTransparency = 1
StatsProLbl.TextColor3 = Theme.Accent
StatsProLbl.TextSize = 10
StatsProLbl.Font = Enum.Font.GothamBold
StatsProLbl.Text = "FPS: 60 | Ping: 0ms | Active Users: 1"

task.spawn(function()
	local lastTime = tick()
	local frameCount = 0
	RunService.RenderStepped:Connect(function()
		frameCount = frameCount + 1
	end)

	while task.wait(0.5) do
		local currentTime = tick()
		local fps = math.floor(frameCount / (currentTime - lastTime))
		frameCount = 0
		lastTime = currentTime

		local ping = 0
		pcall(function()
			ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
		end)

		local totalPlayers = #Players:GetPlayers()
		pcall(function()
			local d = data()
			ProfileCard.Text = string.format(
				" • Nama Akun: %s\n • User ID: %s\n • Saldo Uang: %s\n • Tingkat Rebirth: %s",
				LocalPlayer.Name, tostring(LocalPlayer.UserId), tostring(d and d.Money or 0), tostring(d and d.Rebirth or 0)
			)
		end)

		StatsProLbl.Text = string.format("⚡ Spectrum FPS: %d FPS  |  🌐 Jaringan Ping: %d ms  |  👥 Live Server: %d", fps, ping, totalPlayers)
	end
end)

-- TAB 2: ROLL & AUTOMASI
AddSection(Tab2, "PENGATURAN ROLL & DADU")
AddToggle(Tab2, "Auto Roll Dadu (Cooldown Game Presisi)", "AutoRoll")
AddToggle(Tab2, "Auto Beli Dadu Terbaik (Auto Buy Dice)", "AutoDice")
AddToggle(Tab2, "Auto Equip Dadu Terbaik (Auto Equip Best Dice)", "AutoEquipDice")

-- TAB 3: INVENTARIS & JUAL
AddSection(Tab3, "MANAJEMEN INVENTARIS & PENJUALAN")
AddToggle(Tab3, "Auto Jual Unit/Item Sampah", "AutoSell")
AddToggle(Tab3, "Auto Jual Semua Item (Sell All Junk)", "SellAllJunk")
AddToggle(Tab3, "Auto Kunci Unit (Auto Lock)", "AutoLock")
AddToggle(Tab3, "Auto Fusion Unit (Brainrot/Trio)", "AutoFuse")

-- TAB 4: TOWER & PLOT (DENGAN BATAS LEVEL UNIT)
AddSection(Tab4, "PENGATURAN TOWER, PLOT & LEVEL UNIT")
AddToggle(Tab4, "Auto Jalankan Tower Runner", "AutoTower")
AddToggle(Tab4, "Auto Ambil Saldo Plot (Collect Money)", "AutoCollect")
AddToggle(Tab4, "Smart Placement Unit (Equip Best)", "SmartPlace")
AddToggle(Tab4, "Auto Upgrade Level Slot (Level Unit)", "AutoLevel")

local LevelLimitContainer = Instance.new("Frame")
LevelLimitContainer.Parent = Tab4
LevelLimitContainer.Size = UDim2.new(1, 0, 0, 36)
LevelLimitContainer.BackgroundColor3 = Theme.Card
local LLC = Instance.new("UICorner")
LLC.CornerRadius = UDim.new(0, 6)
LLC.Parent = LevelLimitContainer

local LevelLimitLbl = Instance.new("TextLabel")
LevelLimitLbl.Parent = LevelLimitContainer
LevelLimitLbl.Position = UDim2.new(0, 12, 0, 0)
LevelLimitLbl.Size = UDim2.new(0.6, 0, 1, 0)
LevelLimitLbl.Text = "Batas Level Maksimal Unit:"
LevelLimitLbl.TextColor3 = Theme.Text
LevelLimitLbl.TextSize = 10
LevelLimitLbl.Font = Enum.Font.GothamMedium
LevelLimitLbl.TextXAlignment = Enum.TextXAlignment.Left
LevelLimitLbl.BackgroundTransparency = 1

local LevelLimitBtn = Instance.new("TextButton")
LevelLimitBtn.Parent = LevelLimitContainer
LevelLimitBtn.Position = UDim2.new(0.6, 0, 0.15, 0)
LevelLimitBtn.Size = UDim2.new(0.38, 0, 0.7, 0)
local levelSteps = {10, 25, 50, 100, 200, 500}
local lIdx = 3
LevelLimitBtn.Text = "Level " .. tostring(_G.Mofenk.LevelLimit)
LevelLimitBtn.TextColor3 = Theme.Accent
LevelLimitBtn.TextSize = 10
LevelLimitBtn.Font = Enum.Font.GothamBold
LevelLimitBtn.BackgroundColor3 = Theme.Header
local LLBC = Instance.new("UICorner")
LLBC.CornerRadius = UDim.new(0, 4)
LLBC.Parent = LevelLimitBtn

LevelLimitBtn.MouseButton1Click:Connect(function()
	lIdx = (lIdx % #levelSteps) + 1
	_G.Mofenk.LevelLimit = levelSteps[lIdx]
	LevelLimitBtn.Text = "Level " .. tostring(_G.Mofenk.LevelLimit)
	MofenkNotify("LEVEL UNIT", "Batas maksimal level diatur ke: " .. _G.Mofenk.LevelLimit, 2)
end)

local TowerContainer = Instance.new("Frame")
TowerContainer.Parent = Tab4
TowerContainer.Size = UDim2.new(1, 0, 0, 36)
TowerContainer.BackgroundColor3 = Theme.Card
local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 6)
TC.Parent = TowerContainer

local TowerLbl = Instance.new("TextLabel")
TowerLbl.Parent = TowerContainer
TowerLbl.Position = UDim2.new(0, 12, 0, 0)
TowerLbl.Size = UDim2.new(0.4, 0, 1, 0)
TowerLbl.Text = "Target Tower:"
TowerLbl.TextColor3 = Theme.Text
TowerLbl.TextSize = 10
TowerLbl.Font = Enum.Font.GothamMedium
TowerLbl.TextXAlignment = Enum.TextXAlignment.Left
TowerLbl.BackgroundTransparency = 1

local TowerBtn = Instance.new("TextButton")
TowerBtn.Parent = TowerContainer
TowerBtn.Position = UDim2.new(0.4, 0, 0.15, 0)
TowerBtn.Size = UDim2.new(0.58, 0, 0.7, 0)
TowerBtn.Text = _G.Mofenk.TowerName
TowerBtn.TextColor3 = Theme.Accent
TowerBtn.TextSize = 10
TowerBtn.Font = Enum.Font.GothamBold
TowerBtn.BackgroundColor3 = Theme.Header
local TBC = Instance.new("UICorner")
TBC.CornerRadius = UDim.new(0, 4)
TBC.Parent = TowerBtn

local towers = {"Infinity Tower", "Dragon Tower", "Cursed Tower", "Pirate Tower"}
pcall(function()
	if TowersConfig and TowersConfig.GetAll then
		local all = TowersConfig.GetAll()
		if type(all) == "table" then
			towers = {}
			for name, _ in pairs(all) do table.insert(towers, name) end
		end
	end
end)

local tIdx = 1
TowerBtn.MouseButton1Click:Connect(function()
	tIdx = (tIdx % #towers) + 1
	_G.Mofenk.TowerName = towers[tIdx]
	TowerBtn.Text = _G.Mofenk.TowerName
	MofenkNotify("TOWER", "Target tower diganti ke: " .. _G.Mofenk.TowerName, 2)
end)

-- TAB 5: UPGRADE & REBIRTH
AddSection(Tab5, "UPGRADE PAD & REBIRTH OTOMATIS")
AddToggle(Tab5, "Auto Beli Pad Upgrades", "AutoUpgrade")
AddToggle(Tab5, "Auto Rebirth Otomatis", "AutoRebirth")

-- TAB 6: QUIRK & POTION (DENGAN DATA POTION / BOOSTS LENGKAP)
AddSection(Tab6, "QUIRK, TRAIT & POTION MANAGEMENT")
AddToggle(Tab6, "Auto Roll Quirk", "AutoQuirk")
AddToggle(Tab6, "Auto Roll Trait", "AutoTrait")
AddToggle(Tab6, "Auto Roll Grade", "AutoGrade")
AddToggle(Tab6, "Auto Gunakan Potion & Boosts (Auto Potion)", "AutoPotion")

-- TAB 7: SERVER, HOP & SPY INSPECTOR (DEBUGGER)
AddSection(Tab7, "SERVER HOP & SPY INSPECTOR")

local BtnHop = Instance.new("TextButton")
BtnHop.Parent = Tab7
BtnHop.Size = UDim2.new(1, 0, 0, 36)
BtnHop.Text = "Pindah Server Optimal (Server Hop)"
BtnHop.TextColor3 = Theme.Text
BtnHop.TextSize = 10
BtnHop.Font = Enum.Font.GothamBold
BtnHop.BackgroundColor3 = Theme.Card
local BHB = Instance.new("UICorner")
BHB.CornerRadius = UDim.new(0, 6)
BHB.Parent = BtnHop
BtnHop.MouseButton1Click:Connect(function()
	MofenkNotify("SERVER", "Memindai server publik kosong...", 2)
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
	MofenkNotify("SERVER", "Gagal menemukan server lain.", 3)
end)

local BtnSpy = Instance.new("TextButton")
BtnSpy.Parent = Tab7
BtnSpy.Size = UDim2.new(1, 0, 0, 36)
BtnSpy.Text = "Inspeksi Remote & Path Game (Debugger)"
BtnSpy.TextColor3 = Theme.Accent
BtnSpy.TextSize = 10
BtnSpy.Font = Enum.Font.GothamBold
BtnSpy.BackgroundColor3 = Theme.Card
local BSB = Instance.new("UICorner")
BSB.CornerRadius = UDim.new(0, 6)
BSB.Parent = BtnSpy
BtnSpy.MouseButton1Click:Connect(function()
	local count = 0
	if Network then
		for _, v in ipairs(Network:GetDescendants()) do
			if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
				count = count + 1
			end
		end
	end
	MofenkNotify("DEBUGGER", string.format("Inspeksi selesai. Ditemukan %d Remote valid di path Network.", count), 4)
end)

-- TAB 8: KONFIGURASI, TEMA & SKALA UI
AddSection(Tab8, "PENGATURAN TEMA, SKALA & KONFIGURASI")

local ThemeContainer = Instance.new("Frame")
ThemeContainer.Parent = Tab8
ThemeContainer.Size = UDim2.new(1, 0, 0, 36)
ThemeContainer.BackgroundColor3 = Theme.Card
local ThC = Instance.new("UICorner")
ThC.CornerRadius = UDim.new(0, 6)
ThC.Parent = ThemeContainer

local ThemeLbl = Instance.new("TextLabel")
ThemeLbl.Parent = ThemeContainer
ThemeLbl.Position = UDim2.new(0, 12, 0, 0)
ThemeLbl.Size = UDim2.new(0.4, 0, 1, 0)
ThemeLbl.Text = "Tema Tampilan:"
ThemeLbl.TextColor3 = Theme.Text
ThemeLbl.TextSize = 10
ThemeLbl.Font = Enum.Font.GothamMedium
ThemeLbl.TextXAlignment = Enum.TextXAlignment.Left
ThemeLbl.BackgroundTransparency = 1

local ThemeBtn = Instance.new("TextButton")
ThemeBtn.Parent = ThemeContainer
ThemeBtn.Position = UDim2.new(0.4, 0, 0.15, 0)
ThemeBtn.Size = UDim2.new(0.58, 0, 0.7, 0)
ThemeBtn.Text = _G.Mofenk.ThemePreset
ThemeBtn.TextColor3 = Theme.Accent
ThemeBtn.TextSize = 10
ThemeBtn.Font = Enum.Font.GothamBold
ThemeBtn.BackgroundColor3 = Theme.Header
local ThBC = Instance.new("UICorner")
ThBC.CornerRadius = UDim.new(0, 4)
ThBC.Parent = ThemeBtn

local themeNames = {"Spectrum Dark", "Midnight Crimson", "Emerald Cyber"}
local thIdx = 1
ThemeBtn.MouseButton1Click:Connect(function()
	thIdx = (thIdx % #themeNames) + 1
	_G.Mofenk.ThemePreset = themeNames[thIdx]
	ThemeBtn.Text = _G.Mofenk.ThemePreset
	MofenkNotify("TEMA", "Tema diubah. Eksekusi ulang skrip untuk memperbarui warna latar.", 3)
end)

-- Kontrol Skala UI (Perbesar / Perkecil)
local ScaleContainer = Instance.new("Frame")
ScaleContainer.Parent = Tab8
ScaleContainer.Size = UDim2.new(1, 0, 0, 36)
ScaleContainer.BackgroundColor3 = Theme.Card
local ScC = Instance.new("UICorner")
ScC.CornerRadius = UDim.new(0, 6)
ScC.Parent = ScaleContainer

local ScaleLbl = Instance.new("TextLabel")
ScaleLbl.Parent = ScaleContainer
ScaleLbl.Position = UDim2.new(0, 12, 0, 0)
ScaleLbl.Size = UDim2.new(0.5, 0, 1, 0)
ScaleLbl.Text = "Skala Ukuran UI:"
ScaleLbl.TextColor3 = Theme.Text
ScaleLbl.TextSize = 10
ScaleLbl.Font = Enum.Font.GothamMedium
ScaleLbl.TextXAlignment = Enum.TextXAlignment.Left
ScaleLbl.BackgroundTransparency = 1

local ScaleBtn = Instance.new("TextButton")
ScaleBtn.Parent = ScaleContainer
ScaleBtn.Position = UDim2.new(0.5, 0, 0.15, 0)
ScaleBtn.Size = UDim2.new(0.48, 0, 0.7, 0)
local scales = {0.8, 0.9, 1.0, 1.1, 1.2}
local sIdx = 3
ScaleBtn.Text = math.floor(_G.Mofenk.UIScale * 100) .. "%"
ScaleBtn.TextColor3 = Theme.Accent
ScaleBtn.TextSize = 10
ScaleBtn.Font = Enum.Font.GothamBold
ScaleBtn.BackgroundColor3 = Theme.Header
local ScBC = Instance.new("UICorner")
ScBC.CornerRadius = UDim.new(0, 4)
ScBC.Parent = ScaleBtn

ScaleBtn.MouseButton1Click:Connect(function()
	sIdx = (sIdx % #scales) + 1
	_G.Mofenk.UIScale = scales[sIdx]
	UIRescale.Scale = _G.Mofenk.UIScale
	ScaleBtn.Text = math.floor(_G.Mofenk.UIScale * 100) .. "%"
	MofenkNotify("UI SCALE", "Skala ukuran UI diubah ke " .. ScaleBtn.Text, 2)
end)

local BtnSave = Instance.new("TextButton")
BtnSave.Parent = Tab8
BtnSave.Size = UDim2.new(1, 0, 0, 36)
BtnSave.Text = "Simpan Konfigurasi (Save Config)"
BtnSave.TextColor3 = Theme.Text
BtnSave.TextSize = 10
BtnSave.Font = Enum.Font.GothamBold
BtnSave.BackgroundColor3 = Theme.Card
local SB = Instance.new("UICorner")
SB.CornerRadius = UDim.new(0, 6)
SB.Parent = BtnSave
BtnSave.MouseButton1Click:Connect(function()
	if SaveConfig() then
		MofenkNotify("CONFIG", "Konfigurasi berhasil disimpan ke teks lokal!", 3)
	else
		MofenkNotify("CONFIG", "Gagal menyimpan konfigurasi.", 3)
	end
end)

local BtnLoad = Instance.new("TextButton")
BtnLoad.Parent = Tab8
BtnLoad.Size = UDim2.new(1, 0, 0, 36)
BtnLoad.Text = "Muat Konfigurasi (Load Config)"
BtnLoad.TextColor3 = Theme.Text
BtnLoad.TextSize = 10
BtnLoad.Font = Enum.Font.GothamBold
BtnLoad.BackgroundColor3 = Theme.Card
local LB = Instance.new("UICorner")
LB.CornerRadius = UDim.new(0, 6)
LB.Parent = BtnLoad
BtnLoad.MouseButton1Click:Connect(function()
	if LoadConfig() then
		UIRescale.Scale = _G.Mofenk.UIScale
		ScaleBtn.Text = math.floor(_G.Mofenk.UIScale * 100) .. "%"
		MofenkNotify("CONFIG", "Konfigurasi berhasil dimuat!", 3)
	else
		MofenkNotify("CONFIG", "File konfigurasi tidak ditemukan.", 3)
	end
end)

-- TOMBOL APUNG INTERAKTIF
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "MofenkToggleGui"
ToggleGui.Parent = parentGui
ToggleGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = Theme.Header
ToggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
ToggleBtn.Size = UDim2.new(0, 46, 0, 46)
ToggleBtn.Text = "HUB"
ToggleBtn.TextColor3 = Theme.Accent
ToggleBtn.TextSize = 11
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true
local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 10)
TC.Parent = ToggleBtn
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- 8. THREAD UTAMA EKSEKUSI BACKEND GAME (SINKRONISASI MODUL ASLI FILE)
task.spawn(function()
	MofenkNotify("MOFENK HUB", "Sistem dimuat profesional. Seluruh fitur default dalam keadaan MATI.", 4)
	while task.wait(1.5) do
		if _G.__ANIMEDICE ~= generation then break end

		-- 1. Auto Roll Dadu (Cooldown Presisi)
		if _G.Mofenk.AutoRoll and R.RollDice then
			pcall(function() R.RollDice:InvokeServer() end)
		end

		-- 2. Auto Buy Dice & Auto Equip Best Dice (Sesuai Logika Modul Asli File)
		if (_G.Mofenk.AutoDice or _G.Mofenk.AutoEquipDice) and Dice then
			pcall(function()
				local d = data()
				local allDice = Dice.GetAll()
				if d and allDice then
					-- Auto Buy Dice Terbaik
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

					-- Auto Equip Best Dice
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

		-- 3. Auto Collect Saldo Plot (Collect Money + Smart Place / Equip Best)
		if _G.Mofenk.AutoCollect and R.CollectBalance then
			pcall(function()
				local d = data()
				if d and d.Slots then
					for key, _ in pairs(d.Slots) do
						R.CollectBalance:FireServer(tonumber(key))
					end
				end
				if R.EquipBest then
					R.EquipBest:FireServer()
				end
			end)
		end

		-- 4. Auto Jual Inventaris (Auto Sell & Sell All Junk)
		if (_G.Mofenk.AutoSell or _G.Mofenk.SellAllJunk) and R.SellInventory then
			pcall(function()
				local d = data()
				if d and d.Inventory and UnitConfig and UnitConfig.entries then
					local listToSell = {}
					for id, u in pairs(d.Inventory) do
						local e = UnitConfig.entries[u.name]
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
					if #listToSell > 0 then
						R.SellInventory:InvokeServer(listToSell)
					end
				end
			end)
		end

		-- 5. Auto Level Unit (Dengan Batas Maksimal Level / Level Limit)
		if _G.Mofenk.AutoLevel and R.LevelUpSlot then
			pcall(function()
				local d = data()
				if d and d.Slots then
					for key, slot in pairs(d.Slots) do
						if slot.unitId and slot.level and slot.level < _G.Mofenk.LevelLimit then
							R.LevelUpSlot:FireServer(tonumber(key))
							task.wait(0.2)
						end
					end
				end
			end)
		end

		-- 6. Auto Potion & Boosts (Menggunakan Potion/Boosts dari Inventory)
		if _G.Mofenk.AutoPotion and R.BoostUse then
			pcall(function()
				local d = data()
				if d and d.Inventory and BoostConfig then
					for key, item in pairs(d.Inventory) do
						if BOOSTS and BOOSTS[key] and (tonumber(item.amount) or 0) > 0 then
							R.BoostUse:FireServer(key)
							task.wait(0.3)
						end
					end
				end
			end)
		end

		-- 7. Auto Tower Runner
		if _G.Mofenk.AutoTower and R.PlayTower then
			pcall(function() R.PlayTower:InvokeServer(_G.Mofenk.TowerName) end)
		end

		-- 8. Auto Rebirth
		if _G.Mofenk.AutoRebirth and R.Rebirth then
			pcall(function() R.Rebirth:FireServer() end)
		end
	end
end)
