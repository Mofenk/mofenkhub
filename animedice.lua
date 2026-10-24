-- ===================================================================== --
-- 👑 MOFENKHUB V35.0 — ULTIMATE PROFESSIONAL CONFIG EDITION
-- Game: Anime Dice | Fixed Rebirth Spam, Tower Mix/Random, Gear Sets, Grade/Traits
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

-- 2. KONFIGURASI GLOBAL (DEFAULT MATI DI AWAL)
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

_G.Mofenk = {
	ThemePreset         = "Spectrum Dark",
	UIScale             = 1.0,
	UIAlpha             = 0.08, -- Latar belakang padat elegan (tidak transparan berlebihan)
	CurrentConfigName   = "DefaultConfig",
	-- Roll & Farm
	AutoRoll            = false,
	AutoDice            = false,
	AutoEquipDice       = false,
	-- Rebirth (Aman dari spam)
	AutoRebirth         = false,
	RebirthRequirement  = 50000, -- Batas minimal cash untuk aman dari spam
	-- Inventaris & Jual
	AutoSell            = false,
	SellAllJunk         = false,
	AutoLock            = false,
	AutoFuse            = false,
	-- Tower & Plot
	AutoTower           = false,
	TowerName           = "Infinity Tower",
	AutoMixTower        = false, -- Acak / Rotasi Tower Otomatis
	AutoEquipTower      = false, -- Auto Equip Best Unit Tower
	AutoCollect         = false,
	SmartPlace          = false,
	AutoLevel           = false,
	LevelLimit          = 50,
	AutoUpgrade         = false,
	-- Gear Set Logic (Luck, Damage, Money)
	GearSet             = "Luck Set",
	-- Quirk, Traits, Grade & Potion
	AutoQuirk           = false,
	AutoTrait           = false,
	AutoGrade           = false,
	AutoPotion          = false,
	-- Client & Performance
	AntiAFK             = true,
	AutoReconnect       = true,
	Disable3DRender     = false,
}

-- 3. SISTEM CONFIG PROFESIONAL
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

LoadConfig(_G.Mofenk.CurrentConfigName)

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
	Rebirth         = Network and (safeFind(Network, "RebirthService.RE.Rebirth") or safeFind(Network, "RebirthService.RF.Rebirth")),
	BuyUpgrade      = Network and safeFind(Network, "RE.BuyUpgrade"),
	SellInventory   = Network and safeFind(Network, "SellService.RF.SellInventory"),
	PlayTower       = Network and (safeFind(Network, "Towers.RF.PlayTower") or safeFind(Network, "Towers.RE.PlayTower")),
	Fuse            = Network and safeFind(Network, "FusingService.RE.Fuse"),
	BoostUse        = Network and safeFind(Network, "BoostService.RE.Use"),
	EquipTowerUnit  = Network and safeFind(Network, "Towers.RE.EquipBest"),
	EquipGear       = Network and safeFind(Network, "GearService.RE.EquipGear"),
}

local DataController, TowersConfig, Dice, UnitConfig
pcall(function()
	if Framework then
		DataController = require(Framework.Features.Data.DataController)
		TowersConfig   = require(Framework.Features.Towers.Towers)
		Dice           = require(Framework.Features.Rolling.Dice)
		UnitConfig     = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig)
	end
end)

local function data()
	local ok, res = pcall(function() return DataController.___X end)
	return ok and res or nil
end

-- 5. TEMA VISUAL MODERN (WARNA TERANG & ELEGAN)
local Theme = {
	Bg        = Color3.fromRGB(18, 18, 26),
	Header    = Color3.fromRGB(26, 26, 38),
	Card      = Color3.fromRGB(35, 35, 52),
	Accent    = Color3.fromRGB(0, 240, 255),
	AccentSec = Color3.fromRGB(160, 80, 255),
	Text      = Color3.fromRGB(255, 255, 255),
	TextSub   = Color3.fromRGB(185, 185, 210)
}

-- 6. SISTEM NOTIFIKASI TOAST
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
	Card.BackgroundTransparency = 0.05
	
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 10)
	Corner.Parent = Card
	
	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Theme.Accent
	Stroke.Transparency = 0.3
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

-- 7. UI UTAMA
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
MainFrame.Size = UDim2.new(0, 820, 0, 540)
MainFrame.Position = UDim2.new(0.5, -410, 0.5, -270)
MainFrame.BackgroundColor3 = Theme.Bg
MainFrame.BackgroundTransparency = _G.Mofenk.UIAlpha
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
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
TopBar.BackgroundTransparency = 0.1

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

-- Sidebar Group Nav (Diperbesar & Teks Pas)
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Parent = MainFrame
Sidebar.Position = UDim2.new(0, 10, 0, 56)
Sidebar.Size = UDim2.new(0, 175, 1, -66)
Sidebar.BackgroundColor3 = Theme.Header
Sidebar.BackgroundTransparency = 0.2
Sidebar.ScrollBarThickness = 2
local SideLayout = Instance.new("UIListLayout")
SideLayout.Parent = Sidebar
SideLayout.Padding = UDim.new(0, 6)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame
ContentArea.Position = UDim2.new(0, 193, 0, 56)
ContentArea.Size = UDim2.new(1, -203, 1, -66)
ContentArea.BackgroundColor3 = Theme.Header
ContentArea.BackgroundTransparency = 0.3

local TabFrames = {}
local function CreateTab(name, order)
	local Btn = Instance.new("TextButton")
	Btn.Parent = Sidebar
	Btn.Size = UDim2.new(1, -4, 0, 36)
	Btn.Text = "  " .. name
	Btn.TextColor3 = Theme.TextSub
	Btn.TextSize = 11
	Btn.Font = Enum.Font.GothamBold
	Btn.TextXAlignment = Enum.TextXAlignment.Left
	Btn.BackgroundColor3 = Theme.Card
	Btn.BackgroundTransparency = 0.2
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
				b.BackgroundTransparency = 0.2
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
	L.Size = UDim2.new(1, 0, 0, 26)
	L.Text = "  " .. text
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
	F.Size = UDim2.new(1, 0, 0, 38)
	F.BackgroundColor3 = Theme.Card
	F.BackgroundTransparency = 0.1
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
	Sw.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(60, 60, 85)
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
		TweenService:Create(Sw, TweenInfo.new(0.2), {BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(60, 60, 85)}):Play()
		TweenService:Create(Knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -15, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
	end)
end

-- Komponen Scrolling Dropdown
local function AddScrollingDropdown(parent, title, options, currentVal, callback)
	local F = Instance.new("Frame")
	F.Parent = parent
	F.Size = UDim2.new(1, 0, 0, 42)
	F.BackgroundColor3 = Theme.Card
	F.BackgroundTransparency = 0.1
	local C = Instance.new("UICorner")
	C.CornerRadius = UDim.new(0, 8)
	C.Parent = F

	local L = Instance.new("TextLabel")
	L.Parent = F
	L.Position = UDim2.new(0, 12, 0, 0)
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
	Btn.TextColor3 = Theme.Accent
	Btn.TextSize = 10
	Btn.Font = Enum.Font.GothamBold
	Btn.BackgroundColor3 = Theme.Header
	Btn.BackgroundTransparency = 0.2
	local BC = Instance.new("UICorner")
	BC.CornerRadius = UDim.new(0, 6)
	BC.Parent = Btn

	local DropList = Instance.new("ScrollingFrame")
	DropList.Parent = parent.Parent
	DropList.Size = UDim2.new(0.55, 0, 0, 130)
	DropList.Position = UDim2.new(0.42, 0, 0, 0)
	DropList.BackgroundColor3 = Theme.Header
	DropList.BorderSizePixel = 0
	DropList.Visible = false
	DropList.ZIndex = 10
	DropList.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
	DropList.ScrollBarThickness = 4
	local DLC = Instance.new("UICorner")
	DLC.CornerRadius = UDim.new(0, 6)
	DLC.Parent = DropList
	local DLL = Instance.new("UIListLayout")
	DLL.Parent = DropList

	for _, opt in ipairs(options) do
		local OptBtn = Instance.new("TextButton")
		OptBtn.Parent = DropList
		OptBtn.Size = UDim2.new(1, 0, 0, 28)
		OptBtn.Text = "  " .. tostring(opt)
		OptBtn.TextColor3 = Theme.Text
		OptBtn.TextSize = 10
		OptBtn.Font = Enum.Font.GothamMedium
		OptBtn.TextXAlignment = Enum.TextXAlignment.Left
		OptBtn.BackgroundTransparency = 1
		OptBtn.ZIndex = 11

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
local Tab2 = CreateTab("Tower Mode", 2) -- Tab Tower Terpisah
local Tab3 = CreateTab("Roll & Farm", 3)
local Tab4 = CreateTab("Inventaris", 4)
local Tab5 = CreateTab("Plot & Unit", 5)
local Tab6 = CreateTab("Quirk & Potion", 6)
local Tab7 = CreateTab("Server & Client", 7)
local Tab8 = CreateTab("Config Manager", 8)

TabFrames["Dashboard"].Visible = true

-- TAB 1: DASHBOARD & PROFIL
AddSection(Tab1, "PROFIL PENGGUNA & KINERJA LIVE")

local ProfileWrapper = Instance.new("Frame")
ProfileWrapper.Parent = Tab1
ProfileWrapper.Size = UDim2.new(1, 0, 0, 125)
ProfileWrapper.BackgroundColor3 = Theme.Card
ProfileWrapper.BackgroundTransparency = 0.1
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
StatsProBar.BackgroundTransparency = 0.2
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
				" • Nama Akun: %s\n • User ID: %s\n • Saldo Uang: %s\n • Tingkat Rebirth: %s",
				LocalPlayer.Name, tostring(LocalPlayer.UserId), tostring(d and d.Money or 0), tostring(d and d.Rebirth or 0)
			)
		end)

		StatsProLbl.Text = string.format("⚡ FPS: %d  |  🌐 Ping: %d ms  |  👥 Server: %d", fps, ping, totalPlayers)
	end
end)

-- TAB 2: TOWER MODE (KHUSUS TOWER & AUTO MIX / ROTASI)
AddSection(Tab2, "PENGATURAN TOWER & AUTO MIX")
AddToggle(Tab2, "Auto Jalankan Tower Runner", "AutoTower")
AddToggle(Tab2, "Auto Mix / Rotasi Tower Otomatis", "AutoMixTower")
AddToggle(Tab2, "Auto Equip Best Unit Tower", "AutoEquipTower")

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

AddScrollingDropdown(Tab2, "Pilih Target Tower:", towers, _G.Mofenk.TowerName, function(val)
	_G.Mofenk.TowerName = val
	MofenkNotify("TOWER", "Target tower diatur ke: " .. val, 2)
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

-- TAB 5: PLOT & UNIT (DENGAN PEMILIHAN GEAR SET LUCK/DAMAGE/MONEY)
AddSection(Tab5, "PLOT, UPGRADE & GEAR SETS")
AddToggle(Tab5, "Auto Ambil Saldo Plot (Collect Money)", "AutoCollect")
AddToggle(Tab5, "Smart Placement Unit (Equip Best)", "SmartPlace")
AddToggle(Tab5, "Auto Upgrade Level Slot (Level Unit)", "AutoLevel")
AddToggle(Tab5, "Auto Beli Pad Upgrades", "AutoUpgrade")

AddScrollingDropdown(Tab5, "Pilih Gear Stat Set:", {"Luck Set", "Damage Set", "Money Set", "Balanced Set"}, _G.Mofenk.GearSet, function(val)
	_G.Mofenk.GearSet = val
	MofenkNotify("GEAR SET", "Stat gear diatur ke: " .. val, 2)
end)

AddScrollingDropdown(Tab5, "Batas Maksimal Level Unit:", {10, 25, 50, 100, 200, 500}, _G.Mofenk.LevelLimit, function(val)
	_G.Mofenk.LevelLimit = val
	MofenkNotify("LEVEL UNIT", "Batas level diatur ke: " .. val, 2)
end)

-- TAB 6: QUIRK & POTION (LOGIKA GRADE & TRAIT)
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
BtnHop.Size = UDim2.new(1, 0, 0, 38)
BtnHop.Text = "Pindah Server Kosong (Server Hop)"
BtnHop.TextColor3 = Theme.Text
BtnHop.TextSize = 10
BtnHop.Font = Enum.Font.GothamBold
BtnHop.BackgroundColor3 = Theme.Card
BtnHop.BackgroundTransparency = 0.1
local BHB = Instance.new("UICorner")
BHB.CornerRadius = UDim.new(0, 8)
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

-- TAB 8: CONFIG MANAGER
AddSection(Tab8, "MANAJEMEN CONFIGURASI PRO")

local ConfigNameContainer = Instance.new("Frame")
ConfigNameContainer.Parent = Tab8
ConfigNameContainer.Size = UDim2.new(1, 0, 0, 42)
ConfigNameContainer.BackgroundColor3 = Theme.Card
ConfigNameContainer.BackgroundTransparency = 0.1
local CNC = Instance.new("UICorner")
CNC.CornerRadius = UDim.new(0, 8)
CNC.Parent = ConfigNameContainer

local CNC_Lbl = Instance.new("TextLabel")
CNC_Lbl.Parent = ConfigNameContainer
CNC_Lbl.Position = UDim2.new(0, 12, 0, 0)
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
CNC_Box.TextColor3 = Theme.Accent
CNC_Box.TextSize = 10
CNC_Box.Font = Enum.Font.GothamBold
CNC_Box.BackgroundColor3 = Theme.Header
CNC_Box.BackgroundTransparency = 0.2
local CNBC = Instance.new("UICorner")
CNBC.CornerRadius = UDim.new(0, 6)
CNBC.Parent = CNC_Box

CNC_Box.FocusLost:Connect(function(enterPressed)
	if CNC_Box.Text ~= "" then
		_G.Mofenk.CurrentConfigName = CNC_Box.Text
		MofenkNotify("CONFIG", "Nama config diatur ke: " .. _G.Mofenk.CurrentConfigName, 2)
	end
end)

local function AddConfigButton(text, color, callback)
	local Btn = Instance.new("TextButton")
	Btn.Parent = Tab8
	Btn.Size = UDim2.new(1, 0, 0, 38)
	Btn.Text = text
	Btn.TextColor3 = color
	Btn.TextSize = 10
	Btn.Font = Enum.Font.GothamBold
	Btn.BackgroundColor3 = Theme.Card
	Btn.BackgroundTransparency = 0.1
	local BC = Instance.new("UICorner")
	BC.CornerRadius = UDim.new(0, 8)
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

AddConfigButton("Muat Konfigurasi (Load Config)", Theme.Accent, function()
	if LoadConfig(_G.Mofenk.CurrentConfigName) then
		UIRescale.Scale = _G.Mofenk.UIScale
		MofenkNotify("CONFIG", "Config '" .. _G.Mofenk.CurrentConfigName .. "' berhasil dimuat!", 3)
	else
		MofenkNotify("CONFIG", "File config tidak ditemukan.", 3)
	end
end)

AddConfigButton("Buat Konfigurasi Baru (Create Config)", Color3.fromRGB(0, 255, 140), function()
	if SaveConfig(_G.Mofenk.CurrentConfigName) then
		MofenkNotify("CONFIG", "Config baru '" .. _G.Mofenk.CurrentConfigName .. "' dibuat & disimpan!", 3)
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

-- TOMBOL APUNG INTERAKTIF DIPERBESAR
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "MofenkToggleGui"
ToggleGui.Parent = parentGui
ToggleGui.ResetOnSpawn = false

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = Theme.Header
ToggleBtn.BackgroundTransparency = 0.1
ToggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0)
ToggleBtn.Size = UDim2.new(0, 56, 0, 56)
ToggleBtn.Text = "HUB"
ToggleBtn.TextColor3 = Theme.Accent
ToggleBtn.TextSize = 12
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true
local TC = Instance.new("UICorner")
TC.CornerRadius = UDim.new(0, 14)
TC.Parent = ToggleBtn
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- 8. THREAD UTAMA EKSEKUSI BACKEND & FITUR PREMIUM
task.spawn(function()
	-- Anti-AFK Handler
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

	-- Auto Reconnect Handler
	task.spawn(function()
		pcall(function()
			CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
				if child.Name == "ErrorPrompt" and _G.Mofenk.AutoReconnect then
					task.wait(1)
					pcall(function()
						TeleportService:Teleport(game.PlaceId, LocalPlayer)
					end)
				end
			end)
		end)
	end)

	MofenkNotify("MOFENK HUB", "Sistem dimuat profesional. Seluruh fitur default dalam keadaan MATI.", 4)
	while task.wait(1.5) do
		if _G.__ANIMEDICE ~= generation then break end

		-- 3D Rendering / FPS Boost Handler
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

		-- Tower Mode & Auto Mix Tower (Rotasi)
		if _G.Mofenk.AutoTower and R.PlayTower then
			pcall(function()
				local targetTower = _G.Mofenk.TowerName
				if _G.Mofenk.AutoMixTower and #towers > 0 then
					targetTower = towers[math.random(1, #towers)]
				end
				R.PlayTower:InvokeServer(targetTower)
			end)
		end

		if _G.Mofenk.AutoEquipTower and R.EquipTowerUnit then
			pcall(function() R.EquipTowerUnit:FireServer() end)
		end

		-- Logika Rebirth Anti-Spam (Mengecek Saldo Minimum / Progress Bar Cukup)
		if _G.Mofenk.AutoRebirth and R.Rebirth then
			pcall(function()
				local d = data()
				if d and tonumber(d.Money) and d.Money >= _G.Mofenk.RebirthRequirement then
					R.Rebirth:FireServer()
					task.wait(3) -- Jeda aman agar tidak spam request
				end
			end)
		end
	end
end)
