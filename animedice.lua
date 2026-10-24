-- ===================================================================== --
-- 👑 MOFENKHUB V35.0 — ULTIMATE PROFESSIONAL CONFIG EDITION
-- Game: Anime Dice | Transparent Glass UI, Multi/Single Dropdown, Smooth Radius
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

-- 1. BERSIHKAN INSTANCE LAMA
for _, v in pairs(parentGui:GetChildren()) do
	if v.Name == "MofenkUltraHubV35" or v.Name == "MofenkToggleGui" or v.Name == "MofenkNotifyGui" then
		pcall(function() v:Destroy() end)
	end
end

-- 2. KONFIGURASI GLOBAL
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

_G.Mofenk = {
	ThemePreset     = "Spectrum Dark",
	UIScale         = 1.0,
	UIAlpha         = 0.15, -- Transparansi latar belakang
	AutoRoll        = false,
	AutoDice        = false,
	AutoEquipDice   = false,
	AutoSell        = false,
	SellAllJunk     = false,
	AutoLock        = false,
	AutoFuse        = false,
	AutoTower       = false,
	TowerName       = "Infinity Tower",
	AutoCollect     = false,
	SmartPlace      = false,
	AutoLevel       = false,
	LevelLimit      = 50,
	AutoUpgrade     = false,
	AutoRebirth     = false,
	AutoQuirk       = false,
	AutoTrait       = false,
	AutoGrade       = false,
	AutoPotion      = false,
}

-- 3. SISTEM CONFIG (SAVE & LOAD)
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

-- 5. TEMA VISUAL MODERN & TRANSPARANSI Kaca
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
	Card.BackgroundTransparency = 0.1
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 10)
	Corner.Parent = Card
	
	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Theme.Accent
	Stroke.Transparency = 0.4
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

-- 7. UI UTAMA (DENGAN TRANSPARANSI KACA & SUDUT HALUS)
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
MainFrame.BackgroundTransparency = _G.Mofenk.UIAlpha -- Background transparan kaca
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14) -- Pinggiran kotak lebih halus
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Theme.Accent
MainStroke.Transparency = 0.2
MainStroke.Parent = MainFrame

-- Topbar
local TopBar = Instance.new("Frame")
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 48)
TopBar.BackgroundColor3 = Theme.Header
TopBar.BackgroundTransparency = 0.2

-- Logo Kotak Diperbesar Sedikit
local LogoIcon = Instance.new("Frame")
LogoIcon.Parent = TopBar
LogoIcon.Position = UDim2.new(0, 14, 0.5, -18)
LogoIcon.Size = UDim2.new(0, 36, 0, 36)
LogoIcon.BackgroundColor3 = Theme.Accent
local LIC = Instance.new("UICorner")
LIC.CornerRadius = UDim.new(0, 10)
LIC.Parent = LogoIcon

local LogoInner = Instance.new("Frame")
LogoInner.Parent = LogoIcon
LogoInner.Position = UDim2.new(0.5, -8, 0.5, -8)
LogoInner.Size = UDim2.new(0, 16, 0, 16)
LogoInner.BackgroundColor3 = Theme.Bg
local LIIC = Instance.new("UICorner")
LIIC.CornerRadius = UDim.new(0, 5)
LIIC.Parent = LogoInner

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Position = UDim2.new(0, 60, 0, 0)
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
CC.CornerRadius = UDim.new(0, 8)
CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Sidebar Group Nav
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 10, 0, 56)
Sidebar.Size = UDim2.new(0, 180, 1, -66)
Sidebar.BackgroundColor3 = Theme.Header
Sidebar.BackgroundTransparency = 0.4
Sidebar.ScrollBarThickness = 2
local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.Padding = UDim.new(0, 5)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 198, 0, 56)
ContentArea.Size = UDim2.new(1, -208, 1, -66)
ContentArea.BackgroundColor3 = Theme.Header
ContentArea.BackgroundTransparency = 0.5

local TabFrames = {}
local function CreateTab(name, order)
	local Btn = Instance.new("TextButton")
	Btn.Parent = Sidebar
	Btn.Size = UDim2.new(1, -4, 0, 32)
	Btn.Text = "   " .. name
	Btn.TextColor3 = Theme.TextSub
	Btn.TextSize = 10
	Btn.Font = Enum.Font.GothamMedium
	Btn.TextXAlignment = Enum.TextXAlignment.Left
	Btn.BackgroundColor3 = Theme.Card
	Btn.BackgroundTransparency = 0.3
	Btn.LayoutOrder = order
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 8)
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
	Lay.Padding = UDim.new(0, 8)
	
	TabFrames[name] = Scroll

	Btn.MouseButton1Click:Connect(function()
		for n, f in pairs(TabFrames) do f.Visible = (n == name) end
		for _, b in ipairs(Sidebar:GetChildren()) do
			if b:IsA("TextButton") then
				b.TextColor3 = Theme.TextSub
				b.BackgroundColor3 = Theme.Card
				b.BackgroundTransparency = 0.3
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
	L.Size = UDim2.new(1, 0, 0, 24)
	L.Text = "  " .. text -- Judul teks group di bagian atas kartu
	L.TextColor3 = Theme.Accent
	L.TextSize = 11
	L.Font = Enum.Font.GothamBold
	L.TextXAlignment = Enum.TextXAlignment.Left
	L.BackgroundTransparency = 1
end

local function AddToggle(parent, text, flag)
	local state = _G.Mofenk[flag] or false
	local F = Instance.new("Frame")
	F.Parent = parent
	F.Size = UDim2.new(1, 0, 0, 36)
	F.BackgroundColor3 = Theme.Card
	F.BackgroundTransparency = 0.2
	local C = Instance.new("UICorner")
	C.CornerRadius = UDim.new(0, 8)
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

-- Komponen Single Dropdown Profesional
local function AddSingleDropdown(parent, title, options, currentVal, callback)
	local F = Instance.new("Frame")
	F.Parent = parent
	F.Size = UDim2.new(1, 0, 0, 38)
	F.BackgroundColor3 = Theme.Card
	F.BackgroundTransparency = 0.2
	local C = Instance.new("UICorner")
	C.CornerRadius = UDim.new(0, 8)
	C.Parent = F

	local L = Instance.new("TextLabel")
	L.Parent = F
	L.Position = UDim2.new(0, 12, 0, 0)
	L.Size = UDim2.new(0.45, 0, 1, 0)
	L.Text = title
	L.TextColor3 = Theme.Text
	L.TextSize = 10
	L.Font = Enum.Font.GothamMedium
	L.TextXAlignment = Enum.TextXAlignment.Left
	L.BackgroundTransparency = 1

	local Btn = Instance.new("TextButton")
	Btn.Parent = F
	Btn.Position = UDim2.new(0.45, 0, 0.15, 0)
	Btn.Size = UDim2.new(0.52, 0, 0.7, 0)
	Btn.Text = tostring(currentVal)
	Btn.TextColor3 = Theme.Accent
	Btn.TextSize = 10
	Btn.Font = Enum.Font.GothamBold
	Btn.BackgroundColor3 = Theme.Header
	Btn.BackgroundTransparency = 0.3
	local BC = Instance.new("UICorner")
	BC.CornerRadius = UDim.new(0, 6)
	BC.Parent = Btn

	local idx = 1
	for i, v in ipairs(options) do
		if v == currentVal then idx = i break end
	end

	Btn.MouseButton1Click:Connect(function()
		idx = (idx % #options) + 1
		local selected = options[idx]
		Btn.Text = tostring(selected)
		if callback then callback(selected) end
	end)
end

-- TAB PEMBUATAN
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
ProfileWrapper.BackgroundTransparency = 0.2
local PWC = Instance.new("UICorner")
PWC.CornerRadius = UDim.new(0, 10)
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
StatsProBar.BackgroundTransparency = 0.3
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
AddToggle(Tab2, "Auto Roll Dadu (Cooldown Presisi)", "AutoRoll")
AddToggle(Tab2, "Auto Beli Dadu Terbaik", "AutoDice")
AddToggle(Tab2, "Auto Equip Dadu Terbaik", "AutoEquipDice")

-- TAB 3: INVENTARIS & JUAL
AddSection(Tab3, "MANAJEMEN INVENTARIS & PENJUALAN")
AddToggle(Tab3, "Auto Jual Unit Sampah", "AutoSell")
AddToggle(Tab3, "Auto Jual Semua (Sell All Junk)", "SellAllJunk")
AddToggle(Tab3, "Auto Kunci Unit (Auto Lock)", "AutoLock")
AddToggle(Tab3, "Auto Fusion Unit Otomatis", "AutoFuse")

-- TAB 4: TOWER & PLOT
AddSection(Tab4, "PENGATURAN TOWER & PLOT")
AddToggle(Tab4, "Auto Jalankan Tower Runner", "AutoTower")
AddToggle(Tab4, "Auto Ambil Saldo Plot (Collect Money)", "AutoCollect")
AddToggle(Tab4, "Smart Placement Unit (Equip Best)", "SmartPlace")
AddToggle(Tab4, "Auto Upgrade Level Slot (Level Unit)", "AutoLevel")

AddSingleDropdown(Tab4, "Batas Maksimal Level:", {10, 25, 50, 100, 200, 500}, _G.Mofenk.LevelLimit, function(val)
	_G.Mofenk.LevelLimit = val
	MofenkNotify("LEVEL UNIT", "Batas level diatur ke: " .. val, 2)
end)

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

AddSingleDropdown(Tab4, "Target Tower:", towers, _G.Mofenk.TowerName, function(val)
	_G.Mofenk.TowerName = val
	MofenkNotify("TOWER", "Target tower diganti ke: " .. val, 2)
end)

-- TAB 5: UPGRADE & REBIRTH
AddSection(Tab5, "UPGRADE PAD & REBIRTH OTOMATIS")
AddToggle(Tab5, "Auto Beli Pad Upgrades", "AutoUpgrade")
AddToggle(Tab5, "Auto Rebirth Otomatis", "AutoRebirth")

-- TAB 6: QUIRK & BOOSTS
AddSection(Tab6, "QUIRK, TRAIT & POTION MANAGEMENT")
AddToggle(Tab6, "Auto Roll Quirk", "AutoQuirk")
AddToggle(Tab6, "Auto Roll Trait", "AutoTrait")
AddToggle(Tab6, "Auto Roll Grade", "AutoGrade")
AddToggle(Tab6, "Auto Gunakan Potion & Boosts", "AutoPotion")

-- TAB 7: SERVER, HOP & SPY INSPECTOR
AddSection(Tab7, "SERVER HOP & SPY INSPECTOR")

local BtnHop = Instance.new("TextButton")
BtnHop.Parent = Tab7
BtnHop.Size = UDim2.new(1, 0, 0, 36)
BtnHop.Text = "Pindah Server Optimal (Server Hop)"
BtnHop.TextColor3 = Theme.Text
BtnHop.TextSize = 10
BtnHop.Font = Enum.Font.GothamBold
BtnHop.BackgroundColor3 = Theme.Card
BtnHop.BackgroundTransparency = 0.2
local BHB = Instance.new("UICorner")
BHB.CornerRadius = UDim.new(0, 8)
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
BtnSpy.BackgroundTransparency = 0.2
local BSB = Instance.new("UICorner")
BSB.CornerRadius = UDim.new(0, 8)
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
	MofenkNotify("DEBUGGER", string.format("Inspeksi selesai. Ditemukan %d Remote valid.", count), 4)
end)

-- TAB 8: KONFIGURASI, TEMA & SKALA UI
AddSection(Tab8, "PENGATURAN TEMA, SKALA & KONFIGURASI")

AddSingleDropdown(Tab8, "Tema Tampilan:", {"Spectrum Dark", "Midnight Crimson", "Emerald Cyber"}, _G.Mofenk.ThemePreset, function(val)
	_G.Mofenk.ThemePreset = val
	MofenkNotify("TEMA", "Tema diubah. Eksekusi ulang skrip untuk memperbarui warna.", 3)
end)

AddSingleDropdown(Tab8, "Skala Ukuran UI:", {0.8, 0.9, 1.0, 1.1, 1.2}, _G.Mofenk.UIScale, function(val)
	_G.Mofenk.UIScale = val
	UIRescale.Scale = val
	MofenkNotify("UI SCALE", "Skala UI diubah ke " .. math.floor(val * 100) .. "%", 2)
end)

local BtnSave = Instance.new("TextButton")
BtnSave.Parent = Tab8
BtnSave.Size = UDim2.new(1, 0, 0, 36)
BtnSave.Text = "Simpan Konfigurasi (Save Config)"
BtnSave.TextColor3 = Theme.Text
BtnSave.TextSize = 10
BtnSave.Font = Enum.Font.GothamBold
BtnSave.BackgroundColor3 = Theme.Card
BtnSave.BackgroundTransparency = 0.2
local SB = Instance.new("UICorner")
SB.CornerRadius = UDim.new(0, 8)
SB.Parent = BtnSave
BtnSave.MouseButton1Click:Connect(function()
	if SaveConfig() then
		MofenkNotify("CONFIG", "Konfigurasi berhasil disimpan!", 3)
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
BtnLoad.BackgroundTransparency = 0.2
local LB = Instance.new("UICorner")
LB.CornerRadius = UDim.new(0, 8)
LB.Parent = BtnLoad
BtnLoad.MouseButton1Click:Connect(function()
	if LoadConfig() then
		UIRescale.Scale = _G.Mofenk.UIScale
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
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Text = "HUB"
ToggleBtn.TextColor3 = Theme.Accent
ToggleBtn.TextSize = 11
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true
local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 12)
TC.Parent = ToggleBtn
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- 8. THREAD UTAMA EKSEKUSI BACKEND GAME
task.spawn(function()
	MofenkNotify("MOFENK HUB", "Sistem dimuat profesional. Seluruh fitur default dalam keadaan MATI.", 4)
	while task.wait(1.5) do
		if _G.__ANIMEDICE ~= generation then break end

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
					if #listToSell > 0 then R.SellInventory:InvokeServer(listToSell) end
				end
			end)
		end

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

		if _G.Mofenk.AutoTower and R.PlayTower then
			pcall(function() R.PlayTower:InvokeServer(_G.Mofenk.TowerName) end)
		end

		if _G.Mofenk.AutoRebirth and R.Rebirth then
			pcall(function() R.Rebirth:FireServer() end)
		end
	end
end)
