-- ===================================================================== --
-- 👑 MOFENKHUB V35.0 — ULTIMATE AESTHETIC & ADVANCED LOGIC SUITE
-- Game: Anime Dice | Integrated Webhooks, Smart Tower & Safe Level Up
-- ===================================================================== --

--!nocheck
task.wait(0.6)
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")

local plr = Players.LocalPlayer

local successGui, parentGui = pcall(function()
	if gethui then return gethui()
	elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui
	else return plr:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then parentGui = plr:WaitForChild("PlayerGui") end

pcall(function()
	for _, v in pairs(parentGui:GetChildren()) do
		if v.Name == "MofenkUltraHubV35" or v.Name == "MofenkToggleGui" or v.Name == "MofenkNotifyGui" then
			v:Destroy()
		end
	end
end)

-- ===================================================================== --
-- 1. KONFIGURASI GLOBAL
-- ===================================================================== --
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

local CONFIG = {
	auto        = true, 
	UIScale     = 1.0,
	
	-- Roll & Farm
	autoRoll    = false,
	autoCollect = false,
	smartPlace  = false,
	autoLevel   = false,
	LevelLimit  = 40,
	
	-- Dice & Rebirth
	autoDice    = false,
	autoRebirth = false,
	
	-- Upgrade & Sell
	autoUpgrade = false,
	autoSell    = false,
	sellRarity  = 3,
	
	-- Rerolls & Boosts
	autoGrade   = false,
	gradeMin    = 3,
	autoTrait   = false,
	traitMin    = 1.5,
	autoBoost   = false,
	
	-- Fusion Machine
	autoFusion  = false,
	
	-- Tower Manager
	autoTower   = false,
	tower       = "Auto (best)",
	towerExitOn = false,
	towerExitFloor = 0,
	
	-- Webhooks
	WebhookUrl  = "",
	hookRolls   = false,
	hookStats   = false,
	hookTower   = false,
	
	-- Rewards & Extras
	autoCodes   = false,
	autoClaim   = false,
	autoQuests  = false,
}

local STATE = {
	money = 0, rolls = 0, rebirth = 0, dice = "-",
	slotsUsed = 0, slotsMax = 4, invCount = 0, invCap = 100, luck = 0,
	towerPick = "-", towerPredict = 0, towerFloor = 0, towerLive = "Standby"
}

-- ===================================================================== --
-- 2. MAPPING MODUL & REMOTES
-- ===================================================================== --
local Network = ReplicatedStorage:WaitForChild("Network", 15)
local Framework = ReplicatedStorage:WaitForChild("Framework", 15)

local function svc(path)
	local node = Network
	for part in string.gmatch(path, "[^%.]+") do node = node and node:FindFirstChild(part) end
	return node
end

local R = {
	RollDice        = svc("RollService.RF.RollDice"),
	EquipBest       = svc("PlotService.RE.EquipBest"),
	CollectBalance  = svc("PlotService.RE.CollectBalance"),
	LevelUpSlot     = svc("PlotService.RE.LevelUpSlot"),
	BuyDice         = svc("DiceShopService.RE.BuyDice"),
	EquipDice       = svc("DiceShopService.RE.EquipDice"),
	Rebirth         = svc("RebirthService.RE.Rebirth"),
	BuyUpgrade      = svc("RE.BuyUpgrade") or svc("PlotService.RE.BuyPadUpgrade"),
	SellInventory   = svc("SellService.RF.SellInventory"),
	RedeemCode      = svc("CodesService.RE.RedeemCode") or svc("MonetizationService.RE.RedeemCode"),
	QuestClaim      = svc("QuestService.RE.Claim"),
	ClaimOffline    = svc("OfflineEarningsService.RE.Claim"),
	ClaimDaily      = svc("DailyRewardService.RE.Claim"),
	ClaimGroup      = svc("GroupRewardService.RE.Claim"),
	GradeRoll       = svc("GradeService.RE.Roll"),
	TraitRoll       = svc("TraitService.RE.Roll"),
	BoostUse        = svc("BoostService.RE.Use"),
	PlayTower       = svc("Towers.RF.PlayTower") or svc("Towers.RE.PlayTower"),
	CompleteFloor   = svc("Towers.RF.CompleteTowerFloor"),
	CancelTower     = svc("Towers.RF.CancelTower"),
	BestTowerTeam   = svc("Towers.RE.EquipBestTowerTeam"),
	EquipUnit       = svc("UnitService.RF.Equip"),
	InteractSlot    = svc("PlotService.RE.InteractSlot"),
	Fuse            = svc("FusingService.RE.Fuse"),
}

local DataController = require(Framework.Features.Data.DataController)
local Dice           = require(Framework.Features.Rolling.Dice)
local Rebirths       = require(Framework.Features.Rebirth.Rebirths)
local PlotConfig     = require(Framework.Features.Plot.PlotConfig)
local MonetConfig    = require(Framework.Features.Monetization.MonetizationConfig)
local UnitConfig     = require(Framework.Features.Inventory.Kinds.Unit.UnitConfig)
local Grades         = require(Framework.Features.Grades.Grades)
local Traits         = require(Framework.Features.Traits.Traits)
local TowersConfig   = require(Framework.Features.Towers.Towers)
local BuffController = require(Framework.Features.Buffs.BuffController)
local FusingUtil     = require(Framework.Features.Fusing.FusingUtil)
local FusingConfig   = require(Framework.Features.Fusing.FusingConfig)

local TreeStructure, Upgrades, UnitUtil, BoostConfig, CODES, QuestConfig
pcall(function() TreeStructure = require(Framework.Features.Upgrades.TreeStructure) end)
pcall(function() Upgrades = require(Framework.Features.Upgrades.Upgrades) end)
pcall(function() BoostConfig = require(Framework.Features.Inventory.Kinds.Boost.BoostConfig) end)
pcall(function() QuestConfig = require(Framework.Features.Quests.QuestConfig) end)
pcall(function() CODES = require(Framework.Features.Codes.CodesConfig) end); CODES = CODES or (MonetConfig and MonetConfig.Codes) or {}
for _,m in ipairs(Framework:GetDescendants()) do 
	if m.Name=="UnitUtil" and m:IsA("ModuleScript") then pcall(function() UnitUtil = require(m) end) break end 
end

local function data() return DataController.___X end
local function fmt(n) return tostring(math.floor(tonumber(n) or 0)) end

-- ===================================================================== --
-- 3. FUNGSI WEBHOOK & LOGIKA UTAMA (TERINTEGRASI DARI REFERENSI)
-- ===================================================================== --
local function postWebhook(url, payload)
	if type(url) ~= "string" or not url:find("^https?://") then return false end
	local req = (syn and syn.request) or (http and http.request) or http_request or request
	if req then
		pcall(function() req({ Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode(payload) }) end)
	end
end

local function hookStamp() return os.date("!%Y-%m-%dT%H:%M:%S.000Z") end

local function sendStatsHook()
	if not CONFIG.hookStats or CONFIG.WebhookUrl == "" then return end
	local emb = {
		title = "Statistik Sesi Anime Dice",
		fields = {
			{ name = "Uang", value = fmt(STATE.money), inline = true },
			{ name = "Rolls", value = tostring(STATE.rolls), inline = true },
			{ name = "Rebirth", value = tostring(STATE.rebirth), inline = true }
		},
		color = 0x4ADE80, footer = { text = plr.DisplayName }, timestamp = hookStamp(),
	}
	postWebhook(CONFIG.WebhookUrl, { username = "MOFENKHUB", embeds = { emb } })
end

local function sendTowerHook(towerName, floor0, floorN, drops, result)
	if not CONFIG.hookTower or CONFIG.WebhookUrl == "" then return end
	local dropsStr = ""
	for name, amt in pairs(drops or {}) do dropsStr = dropsStr .. amt .. "x " .. name .. "\n" end
	if dropsStr == "" then dropsStr = "-" end
	local emb = {
		title = "Tower " .. result .. " - " .. towerName,
		fields = {
			{ name = "Lantai", value = floor0 .. " → " .. floorN, inline = true },
			{ name = "Hadiah (Drops)", value = dropsStr, inline = false }
		},
		color = 0xA78BFA, footer = { text = plr.DisplayName }, timestamp = hookStamp(),
	}
	postWebhook(CONFIG.WebhookUrl, { username = "MOFENKHUB", embeds = { emb } })
end

local function unlockedSlots()
	local d = data(); local rb = d.Rebirth or 0; local n = 0
	pcall(function() 
		for i = 1, (PlotConfig.GetMaxSlots(rb) or 15) do
			if rb >= (PlotConfig.GetSlotRebirthRequirement(i) or 0) then n = n + 1 end
		end
	end)
	return n
end

local function doLevelUp()
	if not R.LevelUpSlot then return end
	local d = data()
	if not d or not d.Slots then return end
	for key, slot in pairs(d.Slots) do
		if slot and slot.unitId then
			local e = d.Inventory[slot.unitId]
			if e and e.attributes then
				local lvl = tonumber(e.attributes.level) or 1
				if lvl < CONFIG.LevelLimit then
					local price = 0
					if UnitUtil then pcall(function() price = UnitUtil.GetLevelPrice(e.name, e.attributes) end) end
					if d.Money >= price then
						R.LevelUpSlot:FireServer(tonumber(key))
						task.wait(0.2)
					end
				end
			end
		end
	end
end

local badUpg = {}
local function doUpgrades()
	if not R.BuyUpgrade or not Upgrades or not TreeStructure then return end
	local d = data(); local owned = d.Upgrades or {}
	local list = {}
	local function consider(name)
		if type(name) == "string" and not owned[name] and Upgrades[name] and Upgrades[name].price then
			table.insert(list, { name = name, price = Upgrades[name].price })
		end
	end
	pcall(function()
		for _, n in ipairs(TreeStructure.GetChildren("Start") or {}) do consider(n) end
		consider("Start")
		for name in pairs(owned) do for _, n in ipairs(TreeStructure.GetChildren(name) or {}) do consider(n) end end
	end)
	table.sort(list, function(a, b) return a.price < b.price end)
	for _, u in ipairs(list) do
		if d.Money >= u.price and (badUpg[u.name] or 0) < os.clock() then
			pcall(function() R.BuyUpgrade:FireServer(u.name) end)
			task.wait(0.5)
			if d.Upgrades and not d.Upgrades[u.name] then badUpg[u.name] = os.clock() + 30 end
			break
		end
	end
end

-- ===================================================================== --
-- 4. ANTARMUKA UI (TRANSPARAN ELEGAN, PROFESIONAL)
-- ===================================================================== --
local Theme = {
	Bg = Color3.fromRGB(8, 8, 10), Header = Color3.fromRGB(15, 15, 18), Card = Color3.fromRGB(22, 22, 28),
	Accent = Color3.fromRGB(255, 60, 90), AccentSec = Color3.fromRGB(0, 230, 255),
	Text = Color3.fromRGB(255, 255, 255), TextSub = Color3.fromRGB(180, 180, 190)
}

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "MofenkUltraHubV35"
MainGui.Parent = parentGui
MainGui.ResetOnSpawn = false

local UIRescale = Instance.new("UIScale"); UIRescale.Scale = CONFIG.UIScale; UIRescale.Parent = MainGui

local MainFrame = Instance.new("Frame")
MainFrame.Parent = MainGui; MainFrame.Size = UDim2.new(0, 860, 0, 560); MainFrame.Position = UDim2.new(0.5, -430, 0.5, -280)
MainFrame.BackgroundColor3 = Theme.Bg; MainFrame.BackgroundTransparency = 0.1; MainFrame.Active = true; MainFrame.Draggable = true
MainFrame.ClipsDescendants = true; MainFrame.Visible = false
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 18); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 2.5; MainStroke.Parent = MainFrame
local StrokeGradient = Instance.new("UIGradient"); StrokeGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.AccentSec)}); StrokeGradient.Parent = MainStroke

local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 52); TopBar.BackgroundColor3 = Theme.Header; TopBar.BackgroundTransparency = 0.15
local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 20, 0, 0); Title.Size = UDim2.new(0, 500, 1, 0); Title.Text = "MOFENKHUB  |  ANIME DICE PRO"
Title.TextColor3 = Theme.Text; Title.TextSize = 14; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1
local TitleStroke = Instance.new("UIStroke"); TitleStroke.Color = Theme.AccentSec; TitleStroke.Thickness = 1.2; TitleStroke.Transparency = 0.2; TitleStroke.Parent = Title

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -46, 0, 12); CloseBtn.Size = UDim2.new(0, 28, 0, 28); CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.Text; CloseBtn.TextSize = 12; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BackgroundColor3 = Theme.Card; CloseBtn.BackgroundTransparency = 0.2
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 8); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Parent = MainFrame; Sidebar.Position = UDim2.new(0, 12, 0, 62); Sidebar.Size = UDim2.new(0, 185, 1, -74)
Sidebar.BackgroundColor3 = Theme.Header; Sidebar.BackgroundTransparency = 0.3; Sidebar.ScrollBarThickness = 2
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y; Sidebar.CanvasSize = UDim2.new(0,0,0,0)
local SideLayout = Instance.new("UIListLayout"); SideLayout.Parent = Sidebar; SideLayout.Padding = UDim.new(0, 8)

local ContentArea = Instance.new("Frame")
ContentArea.Parent = MainFrame; ContentArea.Position = UDim2.new(0, 207, 0, 62); ContentArea.Size = UDim2.new(1, -219, 1, -74)
ContentArea.BackgroundColor3 = Theme.Header; ContentArea.BackgroundTransparency = 0.3
local ContentCorner = Instance.new("UICorner"); ContentCorner.CornerRadius = UDim.new(0, 12); ContentCorner.Parent = ContentArea

local TabFrames = {}
local function CreateTab(name, order)
	local Btn = Instance.new("TextButton")
	Btn.Parent = Sidebar; Btn.Size = UDim2.new(1, -4, 0, 38); Btn.Text = "    " .. name; Btn.TextColor3 = Theme.TextSub; Btn.TextSize = 11; Btn.Font = Enum.Font.GothamBold
	Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.BackgroundColor3 = Theme.Card; Btn.BackgroundTransparency = 0.2; Btn.LayoutOrder = order
	local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 10); Corner.Parent = Btn
	local Scroll = Instance.new("ScrollingFrame")
	Scroll.Parent = ContentArea; Scroll.Size = UDim2.new(1, -16, 1, -16); Scroll.Position = UDim2.new(0, 8, 0, 8); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 3
	Scroll.ScrollBarImageColor3 = Theme.AccentSec; Scroll.Visible = false
	Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.CanvasSize = UDim2.new(0,0,0,0)
	local Lay = Instance.new("UIListLayout"); Lay.Parent = Scroll; Lay.Padding = UDim.new(0, 12)
	TabFrames[name] = Scroll
	Btn.MouseButton1Click:Connect(function()
		for n, f in pairs(TabFrames) do f.Visible = (n == name) end
		for _, b in ipairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Theme.TextSub; b.BackgroundColor3 = Theme.Card; b.BackgroundTransparency = 0.2 end end
		Btn.TextColor3 = Theme.Text; Btn.BackgroundColor3 = Theme.AccentSec; Btn.BackgroundTransparency = 0.1
	end)
	return Scroll
end

local function AddSection(parent, text)
	local L = Instance.new("TextLabel")
	L.Parent = parent; L.Size = UDim2.new(1, 0, 0, 30); L.Text = "  " .. text; L.TextColor3 = Theme.AccentSec; L.TextSize = 12; L.Font = Enum.Font.GothamBlack; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Line = Instance.new("Frame"); Line.Parent = L; Line.Size = UDim2.new(1, -12, 0, 1); Line.Position = UDim2.new(0, 12, 1, -2); Line.BackgroundColor3 = Theme.AccentSec; Line.BackgroundTransparency = 0.5
end

local function AddToggle(parent, text, flag)
	local state = CONFIG[flag] or false
	local F = Instance.new("Frame"); F.Parent = parent; F.Size = UDim2.new(1, 0, 0, 44); F.BackgroundColor3 = Theme.Card; F.BackgroundTransparency = 0.2
	local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 10); C.Parent = F
	local L = Instance.new("TextLabel"); L.Parent = F; L.Position = UDim2.new(0, 14, 0, 0); L.Size = UDim2.new(0.7, 0, 1, 0); L.Text = text; L.TextColor3 = Theme.Text; L.TextSize = 11; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Sw = Instance.new("TextButton"); Sw.Parent = F; Sw.Position = UDim2.new(1, -48, 0.5, -12); Sw.Size = UDim2.new(0, 40, 0, 24); Sw.Text = ""; Sw.BackgroundColor3 = state and Theme.AccentSec or Color3.fromRGB(45, 45, 55)
	local SwC = Instance.new("UICorner"); SwC.CornerRadius = UDim.new(1, 0); SwC.Parent = Sw
	local Knob = Instance.new("Frame"); Knob.Parent = Sw; Knob.Size = UDim2.new(0, 20, 0, 20); Knob.Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10); Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1, 0); KC.Parent = Knob
	Sw.MouseButton1Click:Connect(function()
		state = not state; CONFIG[flag] = state
		TweenService:Create(Sw, TweenInfo.new(0.25), {BackgroundColor3 = state and Theme.AccentSec or Color3.fromRGB(45, 45, 55)}):Play()
		TweenService:Create(Knob, TweenInfo.new(0.25), {Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}):Play()
	end)
end

local function AddInput(parent, text, flag, placeholder)
	local F = Instance.new("Frame"); F.Parent = parent; F.Size = UDim2.new(1, 0, 0, 44); F.BackgroundColor3 = Theme.Card; F.BackgroundTransparency = 0.2
	local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 10); C.Parent = F
	local L = Instance.new("TextLabel"); L.Parent = F; L.Position = UDim2.new(0, 14, 0, 0); L.Size = UDim2.new(0.4, 0, 1, 0); L.Text = text; L.TextColor3 = Theme.Text; L.TextSize = 11; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Box = Instance.new("TextBox"); Box.Parent = F; Box.Position = UDim2.new(0.45, 0, 0.15, 0); Box.Size = UDim2.new(0.5, 0, 0.7, 0); Box.Text = tostring(CONFIG[flag] or "")
	Box.PlaceholderText = placeholder or ""; Box.TextColor3 = Theme.AccentSec; Box.TextSize = 11; Box.Font = Enum.Font.GothamBold; Box.BackgroundColor3 = Theme.Header; Box.BackgroundTransparency = 0.2
	local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); BC.Parent = Box
	Box.FocusLost:Connect(function()
		if type(CONFIG[flag]) == "number" then CONFIG[flag] = tonumber(Box.Text) or 0 else CONFIG[flag] = Box.Text end
	end)
end

-- INISIALISASI TAB
local Tab1 = CreateTab("Dashboard", 1); local Tab2 = CreateTab("Tower Manager", 2); local Tab3 = CreateTab("Plot & Leveling", 3); local Tab4 = CreateTab("Webhooks & Settings", 4)
TabFrames["Dashboard"].Visible = true

-- TAB 1: DASHBOARD
AddSection(Tab1, "PROFIL PENGGUNA")
local ProfileWrapper = Instance.new("Frame"); ProfileWrapper.Parent = Tab1; ProfileWrapper.Size = UDim2.new(1, 0, 0, 160); ProfileWrapper.BackgroundColor3 = Theme.Card; ProfileWrapper.BackgroundTransparency = 0.15
local PWC = Instance.new("UICorner"); PWC.CornerRadius = UDim.new(0, 12); PWC.Parent = ProfileWrapper
local CoverBg = Instance.new("Frame"); CoverBg.Parent = ProfileWrapper; CoverBg.Size = UDim2.new(1, 0, 0, 60); CoverBg.BackgroundColor3 = Theme.AccentSec; CoverBg.BackgroundTransparency = 0.5
local CoverCorner = Instance.new("UICorner"); CoverCorner.CornerRadius = UDim.new(0, 12); CoverCorner.Parent = CoverBg
local AvatarImg = Instance.new("ImageLabel"); AvatarImg.Parent = ProfileWrapper; AvatarImg.AnchorPoint = Vector2.new(0.5, 0); AvatarImg.Position = UDim2.new(0.5, 0, 0, 25); AvatarImg.Size = UDim2.new(0, 70, 0, 70); AvatarImg.BackgroundColor3 = Theme.Header
pcall(function() AvatarImg.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)
local AIC = Instance.new("UICorner"); AIC.CornerRadius = UDim.new(1, 0); AIC.Parent = AvatarImg
local AvatarStroke = Instance.new("UIStroke"); AvatarStroke.Color = Theme.Card; AvatarStroke.Thickness = 4; AvatarStroke.Parent = AvatarImg
local ProfileName = Instance.new("TextLabel"); ProfileName.Parent = ProfileWrapper; ProfileName.Position = UDim2.new(0, 0, 0, 100); ProfileName.Size = UDim2.new(1, 0, 0, 25); ProfileName.Text = plr.Name; ProfileName.TextColor3 = Theme.Text; ProfileName.TextSize = 14; ProfileName.Font = Enum.Font.GothamBold; ProfileName.BackgroundTransparency = 1; ProfileName.TextXAlignment = Enum.TextXAlignment.Center
local ProfileStats = Instance.new("TextLabel"); ProfileStats.Parent = ProfileWrapper; ProfileStats.Position = UDim2.new(0, 0, 0, 125); ProfileStats.Size = UDim2.new(1, 0, 0, 20); ProfileStats.Text = "Uang: ... | Rebirth: ..."; ProfileStats.TextColor3 = Theme.TextSub; ProfileStats.TextSize = 11; ProfileStats.Font = Enum.Font.GothamMedium; ProfileStats.BackgroundTransparency = 1; ProfileStats.TextXAlignment = Enum.TextXAlignment.Center

AddSection(Tab1, "LIVE TOWER MONITORING")
local TowerMonitorCard = Instance.new("Frame"); TowerMonitorCard.Parent = Tab1; TowerMonitorCard.Size = UDim2.new(1, 0, 0, 60); TowerMonitorCard.BackgroundColor3 = Theme.Card; TowerMonitorCard.BackgroundTransparency = 0.2
local TMC = Instance.new("UICorner"); TMC.CornerRadius = UDim.new(0, 12); TMC.Parent = TowerMonitorCard
local TowerLbl = Instance.new("TextLabel"); TowerLbl.Parent = TowerMonitorCard; TowerLbl.Position = UDim2.new(0, 16, 0, 10); TowerLbl.Size = UDim2.new(1, -32, 1, -20); TowerLbl.BackgroundTransparency = 1; TowerLbl.TextColor3 = Theme.Text; TowerLbl.TextSize = 11; TowerLbl.Font = Enum.Font.GothamMedium; TowerLbl.TextXAlignment = Enum.TextXAlignment.Left; TowerLbl.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
	while task.wait(0.5) do
		pcall(function()
			ProfileStats.Text = string.format("💰 Uang: %s  |  🔄 Rebirth: %d", fmt(STATE.money), STATE.rebirth)
			TowerLbl.Text = string.format("🎮 Status: %s\n🏢 Lantai: %d", tostring(STATE.towerLive), STATE.towerFloor)
		end)
	end
end)

-- TAB 2: TOWER
AddSection(Tab2, "KONTROL TOWER")
AddToggle(Tab2, "Auto Tower Farming", "autoTower")
AddToggle(Tab2, "Auto Tower Exit at Floor", "towerExitOn")
AddInput(Tab2, "Tower Exit Floor:", "towerExitFloor", "Contoh: 50")

-- TAB 3: PLOT & LEVELING
AddSection(Tab3, "AUTO UPGRADE & LEVEL")
AddToggle(Tab3, "Auto Collect Uang Plot", "autoCollect")
AddToggle(Tab3, "Auto Upgrade Skill Tree", "autoUpgrade")
AddToggle(Tab3, "Auto Level Up Unit (Smart)", "autoLevel")
AddInput(Tab3, "Batas Max Level:", "LevelLimit", "Contoh: 40")
AddToggle(Tab3, "Auto Fusion Unit", "autoFusion")
AddToggle(Tab3, "Auto Grade (Melewati Protected)", "autoGrade")
AddToggle(Tab3, "Auto Trait (Melewati Protected)", "autoTrait")

-- TAB 4: WEBHOOK & SETTINGS
AddSection(Tab4, "DISCORD WEBHOOKS")
AddInput(Tab4, "Webhook URL:", "WebhookUrl", "https://discord.com/api/webhooks/...")
AddToggle(Tab4, "Kirim Notifikasi Tower", "hookTower")
AddToggle(Tab4, "Kirim Stat Reports", "hookStats")
AddSection(Tab4, "KLAIM & HADIAH")
AddToggle(Tab4, "Auto Redeem Codes", "autoCodes")
AddToggle(Tab4, "Auto Claim Quests", "autoQuests")

-- TOGGLE MENGAMBANG
local ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "MofenkToggleGui"; ToggleGui.Parent = parentGui; ToggleGui.ResetOnSpawn = false
local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = ToggleGui; ToggleBtn.BackgroundColor3 = Theme.Header; ToggleBtn.BackgroundTransparency = 0.1; ToggleBtn.Position = UDim2.new(0.02, 0, 0.35, 0); ToggleBtn.Size = UDim2.new(0, 60, 0, 60); ToggleBtn.Text = "F"; ToggleBtn.TextColor3 = Theme.AccentSec; ToggleBtn.TextSize = 24; ToggleBtn.Font = Enum.Font.GothamBold; ToggleBtn.AutoButtonColor = false
local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 14); TC.Parent = ToggleBtn
local ToggleStroke = Instance.new("UIStroke"); ToggleStroke.Thickness = 2.5; ToggleStroke.Parent = ToggleBtn
local TSGrad = Instance.new("UIGradient"); TSGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.AccentSec)}); TSGrad.Parent = ToggleStroke

local dragging, dragInput, dragStart, startPos
ToggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = input.Position; startPos = ToggleBtn.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
	end
end)
ToggleBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart; local viewport = workspace.CurrentCamera.ViewportSize
		ToggleBtn.Position = UDim2.new(0, math.clamp(startPos.X.Offset + delta.X, 10, viewport.X - 70), 0, math.clamp(startPos.Y.Offset + delta.Y, 10, viewport.Y - 70))
	end
end)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- ===================================================================== --
-- 5. THREADS EKSEKUSI
-- ===================================================================== --
-- Data Updater
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		local d = data(); if not d then task.wait(1); continue end
		STATE.money = d.Money or 0; STATE.rebirth = d.Rebirth or 0; STATE.rolls = d.Rolls or 0
		task.wait(2)
	end
end)

-- Level Up & Upgrade
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if CONFIG.autoCollect and R.CollectBalance then
			pcall(function() for key, _ in pairs(data().Slots or {}) do R.CollectBalance:FireServer(tonumber(key)) end end)
		end
		if CONFIG.autoLevel then pcall(doLevelUp) end
		if CONFIG.autoUpgrade then pcall(doUpgrades) end
		task.wait(2.5)
	end
end)

-- Auto Tower dengan Logika HandleSeq & Exit Floor
task.spawn(function()
	local lastFloor = 1
	local towerRunDrops = {}
	local function driveTower()
		local step = R.CompleteFloor
		local done, fails = false, 0
		while CONFIG.autoTower and _G.__ANIMEDICE == generation and not done do
			local ok, seq = pcall(function() return step:InvokeServer() end)
			if ok and type(seq) == "table" then
				if #seq > 0 then
					fails = 0
					for _, act in ipairs(seq) do
						if act.action == "floorStarted" and tonumber(act.floor) then
							lastFloor = tonumber(act.floor)
							STATE.towerFloor = lastFloor
						elseif act.action == "floorCompleted" and type(act.rewards) == "table" then
							for rn, ra in pairs(act.rewards) do towerRunDrops[rn] = (towerRunDrops[rn] or 0) + (tonumber(ra) or 0) end
						elseif act.action == "ended" then
							done = true
							if act.rewards and next(act.rewards) then
								sendTowerHook(CONFIG.tower, 1, lastFloor, towerRunDrops, "Cleared")
							end
							break
						end
					end
					-- Logika Exit At Floor
					if not done and CONFIG.towerExitOn and CONFIG.towerExitFloor > 0 and lastFloor >= CONFIG.towerExitFloor then
						done = true
						if R.CancelTower then pcall(function() R.CancelTower:InvokeServer() end) end
						sendTowerHook(CONFIG.tower, 1, lastFloor, towerRunDrops, "Exited")
						lastFloor = 1
					end
				else task.wait(0.25) end
			else
				fails = fails + 1
				if fails >= 8 then done = true end
				task.wait(1)
			end
		end
	end

	while _G.__ANIMEDICE == generation do
		if CONFIG.autoTower and R.PlayTower and R.CompleteFloor then
			if R.BestTowerTeam then pcall(function() R.BestTowerTeam:FireServer() end) end
			task.wait(0.5)
			
			-- Gunakan Pick Default atau Random
			local targetTower = "Dragon Tower"
			pcall(function()
				local all = TowersConfig.GetAll()
				if type(all) == "table" and all["Cursed Tower"] then targetTower = "Cursed Tower" end
			end)
			CONFIG.tower = targetTower
			
			STATE.towerLive = "Farming: " .. targetTower
			local okStart, started = pcall(function() return R.PlayTower:InvokeServer(targetTower) end)
			if okStart and started then
				lastFloor = 1
				towerRunDrops = {}
				driveTower()
			else
				-- Lanjutkan jika nyangkut
				local okP, seq = pcall(function() return R.CompleteFloor:InvokeServer() end)
				if okP and type(seq) == "table" and #seq > 0 then driveTower() else task.wait(3) end
			end
		else
			STATE.towerLive = "Standby"
			task.wait(2)
		end
	end
end)

-- Webhook Reporter Sesi Berkala
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		task.wait(300)
		pcall(sendStatsHook)
	end
end)

MainFrame.Visible = true
