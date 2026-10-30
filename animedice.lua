-- ===================================================================== --
-- 👑 MOFENKHUB V104.2 — FULL AI SMART PLANNER & RESOURCE THRESHOLD EDITION
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
local Stats             = game:GetService("Stats")

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
-- 1. CONFIGURATION & STATE MANAGER
-- ===================================================================== --
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

local F = {
	cfgName = "MofenkConfig1", autoLoadEnabled = false,
	-- Farm & Plot
	collect = false, collectDelay = 2.0, levelup = false, maxLevel = 40, smartLevel = false,
	rebirth = false, upgrades = false, buyDice = true, equipDice = true, autoRoll = false,
	autoBestPlaceBase = false, smartPlace = true,
	-- Inventory & Dynamic Rarity Multi-Select Auto Sell / Lock
	sellAuto = false, sellMaxInvent = false, keepBest = 0, autoFuse = false,
	keepRarities = {"Mythic", "Secret", "Divine", "Godly"},
	autoLockRarity = true,
	specificSellUnits = {},
	-- Potions
	potionAuto = false, potionBest = true, potionSpecific = {},
	-- AI Master Smart Planner & Thresholds
	aiSmartPlanner = true,
	aiPriorityGoal = "Inisialisasi Scan Akun & Keamanan Limit...",
	aiResourceThreshold = true,
	aiJitterDelay = 1.8,
	-- Quirk, Grade & Trait Management
	autoLockTarget = true,
	quirkAuto = false, quirkTargets = {}, quirkUnits = {}, quirkReserve = 10,
	gradeAuto = false, gradeAll = false, gradePlacedOnly = false, gradeTargets = {}, gradeUnits = {}, gemReserve = 100,
	traitAuto = false, traitAll = false, traitPlacedOnly = false, traitTargets = {}, traitUnits = {}, rerollReserve = 50,
	-- Main Tower Setup
	tower = false, towerMix = false, towerList = {"Dragon Tower", "Demon Tower"}, towerEquipBest = true, towerExitOn = false, towerExitFloor = 50,
	-- Halloween & Haunted Tower
	halloweenTeleport = false, halloweenQuest = false, halloweenPath = false, halloweenOffer = false, trickOrTreat = false,
	pumpkinRollQty = 1, pumpkinAutoRoll = false, pumpkinAutoSell = false,
	hauntedTower = false, hauntedMix = false, hauntedList = {"Haunted Front Yard", "Haunted Crypt", "Haunted Attic", "Haunted Bell Tower"}, hauntedEquipBest = true, hauntedExitOn = false, hauntedExitFloor = 50,
	-- Client & Misc
	wsOn = false, wsValue = 16, noclip = false, afk = true, fpsOn = false,
	codesAuto = false, claimQuests = false,
	-- Webhook
	webhookEnabled = false, webhookUrl = ""
}

local STATE = {
	towerLive = "Standby", towerFloor = 0, towerDrops = 0, towerTraitsGot = "Belum Ada",
	hauntedLive = "Standby", hauntedFloor = 0, hauntedDrops = 0, activeBuffs = "Tidak Ada",
	pingMs = 0, fpsCurrent = 60,
	quirkActiveUnit = "-", quirkCurrentVal = "-", quirkStatus = "Standby",
	gradeActiveUnit = "-", gradeCurrentVal = "-", gradeStatus = "Standby",
	traitActiveUnit = "-", traitCurrentVal = "-", traitStatus = "Standby",
	aiConsoleLog = "AI Master Smart Planner: Menunggu Inisialisasi..."
}
local ConfigUpdaters = {}

-- THEME DIUBAH MENJADI HITAM PUTIH (MONOKROM)
local GLASS_THEME = {
	Bg     = Color3.fromRGB(15, 15, 15),
	Card   = Color3.fromRGB(28, 28, 28),
	Header = Color3.fromRGB(22, 22, 22),
	Acc1   = Color3.fromRGB(255, 255, 255),
	Acc2   = Color3.fromRGB(200, 200, 200),
	Text   = Color3.fromRGB(240, 240, 240),
	SubText= Color3.fromRGB(160, 160, 160)
}

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

local function AddSpyLog(txt)
	-- Disenyapkan agar tidak spam konsol/notifikasi
end

local function FormatMoney(val)
	val = tonumber(val) or 0
	if val >= 1e12 then return string.format("%.2fT", val/1e12)
	elseif val >= 1e9 then return string.format("%.2fB", val/1e9)
	elseif val >= 1e6 then return string.format("%.2fM", val/1e6)
	elseif val >= 1e3 then return string.format("%.2fK", val/1e3)
	else return tostring(math.floor(val)) end
end

-- ===================================================================== --
-- 2. FRAMEWORK & MODULE SERVICES BINDINGS
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
	QuirkRoll       = svc("QuirkService.RE.Roll") or svc("Quirks.RE.Roll") or svc("MutationService.RE.Roll"),
	GradeRoll       = svc("GradeService.RE.Roll") or svc("Grades.RE.Roll"), 
	TraitRoll       = svc("TraitService.RE.Roll") or svc("Traits.RE.Roll"), 
	BoostUse        = svc("BoostService.RE.Use"),
	PlayTower       = svc("Towers.RF.PlayTower") or svc("Towers.RE.PlayTower") or svc("TowerService.RF.PlayTower"), 
	CompleteFloor   = svc("Towers.RF.CompleteTowerFloor") or svc("TowerService.RF.CompleteTowerFloor"),
	CancelTower     = svc("Towers.RF.CancelTower") or svc("TowerService.RF.CancelTower"), 
	BestTowerTeam   = svc("Towers.RE.EquipBestTowerTeam") or svc("TowerService.RE.EquipBestTowerTeam"),
	RedeemCode      = svc("CodesService.RE.RedeemCode") or svc("MonetizationService.RE.RedeemCode"),
	QuestClaim      = svc("QuestService.RE.Claim"), 
	ClaimDaily      = svc("DailyRewardService.RE.Claim"),
	ClaimOffline    = svc("OfflineEarningsService.RE.Claim"), 
	ClaimGroup      = svc("GroupRewardService.RE.Claim"),
	SellInventory   = svc("SellService.RF.SellInventory") or svc("SellService.RE.SellInventory"),
	UpdateAutoSell  = svc("SellService.RE.UpdateAutoSell"),
	Fuse            = svc("FusingService.RE.Fuse"),
	InteractSlot    = svc("PlotService.RE.InteractSlot"),
	EquipUnit       = svc("UnitService.RF.Equip") or svc("UnitService.RE.Equip"),
	UnequipUnit     = svc("UnitService.RF.Unequip") or svc("UnitService.RE.Unequip"),
	LockUnit        = svc("UnitService.RE.SetLock") or svc("InventoryService.RE.Lock"),
	HWTeleport      = svc("HalloweenService.RF.Teleport"),
	HWSeenIntro     = svc("HalloweenService.RE.SeenIntro"),
	HWQuestClaim    = svc("HalloweenQuestService.RE.Claim"),
	HWClaimPath     = svc("HalloweenService.RE.ClaimAllPath"),
	HWBuyOffer      = svc("HalloweenService.RE.BuyOffer"),
	TrickOrTreat    = svc("TrickOrTreatService.RE.Knocked"),
	PumpkinRoll     = svc("PumpkinDiceService.RF.Roll") or svc("PumpkinDiceService.RE.Roll"),
	PumpkinAutoSell = svc("PumpkinDiceService.RF.SetAutoSell")
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
	G.QuirksMod = (Framework.Features:FindFirstChild("Quirks") and require(Framework.Features.Quirks.Quirks)) or (Framework.Features:FindFirstChild("Mutations") and require(Framework.Features.Mutations.Mutations))
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

local function isBeingRolled(unitId)
	if not unitId then return false end
	if F.quirkAuto then for _, id in ipairs(F.quirkUnits or {}) do if id == unitId then return true end end end
	if F.gradeAuto then for _, id in ipairs(F.gradeUnits or {}) do if id == unitId then return true end end end
	if F.traitAuto then for _, id in ipairs(F.traitUnits or {}) do if id == unitId then return true end end end
	return false
end

local function getUnitRarity(u)
	local rarity = "Common"
	if u and u.name then
		pcall(function()
			if G.EntryRegistry and G.EntryRegistry.getEntryConfig then
				local cfg = G.EntryRegistry.getEntryConfig(u.name)
				if cfg and cfg.rarity then rarity = cfg.rarity end
			elseif G.UnitConfig and G.UnitConfig.entries then
				local cfg = G.UnitConfig.entries[u.name]
				if cfg and cfg.rarity then rarity = cfg.rarity end
			end
		end)
	end
	return tostring(rarity)
end

local function baseIncome(u)
	if not u then return 0 end
	local e = G.UnitConfig and G.UnitConfig.entries[u.name]
	if not e then return 0 end
	local a = u.attributes or {}
	local lvl = tonumber(a.level) or 1
	local ok, inc = pcall(function()
		if e.income then
			return e.income({ mutation = a.mutation or a.quirk, grade = a.grade, trait = a.trait, level = lvl })
		end
		return 0
	end)
	return tonumber(inc) or 0
end

local function SendWebhook(title, description, colorCode)
	if not F.webhookEnabled or F.webhookUrl == "" then return end
	local req = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
	if req then
		pcall(function()
			req({
				Url = F.webhookUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"},
				Body = HttpService:JSONEncode({ username = "MofenkHub-AI", avatar_url = "https://i.imgur.com/3qGMB7j.png", embeds = {{ title = title, description = description, color = colorCode or 3447003, footer = {text = "Player: " .. LocalPlayer.Name} }} })
			})
		end)
	end
end

-- ===================================================================== --
-- 3. INTERACTIVE TOGGLE & TOAST NOTIFICATION SYSTEM (SPAM DIHAPUS)
-- ===================================================================== --
local ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "MofenkToggleFront"; ToggleGui.Parent = parentGui; ToggleGui.ResetOnSpawn = false
ToggleGui.DisplayOrder = 99999

local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = ToggleGui; ToggleBtn.Size = UDim2.new(0, 52, 0, 52); ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = GLASS_THEME.Card; ToggleBtn.Text = "AI"; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 22; ToggleBtn.TextColor3 = GLASS_THEME.Acc1; ToggleBtn.ZIndex = 99999
local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 14); TC.Parent = ToggleBtn
local TS = Instance.new("UIStroke"); TS.Thickness = 2; TS.Color = GLASS_THEME.Acc1; TS.Parent = ToggleBtn

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
		ToggleBtn.Position = UDim2.new(0, math.clamp(startPos.X.Offset + delta.X, 10, viewport.X - 60), 0, math.clamp(startPos.Y.Offset + delta.Y, 10, viewport.Y - 60))
	end
end)

-- TOAST NOTIFICATIONS (DIBATASI / DIKECUALIKAN AGAR TIDAK SPAM)
local NotifyGui = Instance.new("ScreenGui"); NotifyGui.Name = "MofenkNotifyGui"; NotifyGui.Parent = parentGui; NotifyGui.ResetOnSpawn = false
local NotifyHolder = Instance.new("Frame"); NotifyHolder.Parent = NotifyGui; NotifyHolder.Position = UDim2.new(1, -280, 0, 20); NotifyHolder.Size = UDim2.new(0, 260, 1, -40); NotifyHolder.BackgroundTransparency = 1
local NotifyLayout = Instance.new("UIListLayout"); NotifyLayout.Parent = NotifyHolder; NotifyLayout.Padding = UDim.new(0, 8); NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local function Notify(title, msg, duration)
	-- Hanya tampilkan notifikasi penting saja
end

-- ===================================================================== --
-- 4. ADAPTIVE AUTO-SCALE & COMPACT UI SETUP
-- ===================================================================== --
local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkUltraHubV104"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 880, 0, 560); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.BackgroundColor3 = GLASS_THEME.Bg; MainFrame.BackgroundTransparency = 0.05
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 14); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 1.8; MainStroke.Color = GLASS_THEME.Acc1; MainStroke.Parent = MainFrame

local ScreenScale = Instance.new("UIScale"); ScreenScale.Parent = MainGui
local baseAutoMultiplier = 1.0
local userManualZoom = 1.0

local function UpdateScale()
	local viewport = workspace.CurrentCamera.ViewportSize
	local isMobileOrSmall = viewport.X < 900 or viewport.Y < 550
	local targetBase = isMobileOrSmall and (viewport.X / 1100) or (viewport.X / 1300)
	
	baseAutoMultiplier = math.clamp(targetBase, 0.55, 1.20)
	ScreenScale.Scale = baseAutoMultiplier * userManualZoom
end
UpdateScale(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 48); TopBar.BackgroundColor3 = GLASS_THEME.Header; TopBar.BackgroundTransparency = 0.1
local TopCorner = Instance.new("UICorner"); TopCorner.CornerRadius = UDim.new(0, 14); TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 16, 0, 0); Title.Size = UDim2.new(0, 220, 1, 0); Title.Text = "👑 AI SMART PLANNER"; Title.TextColor3 = GLASS_THEME.Acc1; Title.TextSize = 13; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1

local StatusBar = Instance.new("TextLabel"); StatusBar.Parent = TopBar; StatusBar.Position = UDim2.new(0, 230, 0, 8); StatusBar.Size = UDim2.new(0, 490, 0, 32); StatusBar.BackgroundColor3 = GLASS_THEME.Card; StatusBar.BackgroundTransparency = 0.2; StatusBar.TextColor3 = GLASS_THEME.SubText; StatusBar.TextSize = 10; StatusBar.Font = Enum.Font.GothamMedium; StatusBar.Text = "🤖 AI Status: Monochromatic & Secure Mode"
local SBC = Instance.new("UICorner"); SBC.CornerRadius = UDim.new(0, 6); SBC.Parent = StatusBar

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -42, 0, 8); CloseBtn.Size = UDim2.new(0, 32, 0, 32); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = GLASS_THEME.Text; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 15; CloseBtn.BackgroundColor3 = GLASS_THEME.Card; CloseBtn.BackgroundTransparency = 0.2
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 8); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local ZoomOutBtn = Instance.new("TextButton"); ZoomOutBtn.Parent = TopBar; ZoomOutBtn.Position = UDim2.new(1, -78, 0, 8); ZoomOutBtn.Size = UDim2.new(0, 32, 0, 32); ZoomOutBtn.Text = "-"; ZoomOutBtn.TextColor3 = GLASS_THEME.Text; ZoomOutBtn.Font = Enum.Font.GothamBold; ZoomOutBtn.TextSize = 16; ZoomOutBtn.BackgroundColor3 = GLASS_THEME.Card; ZoomOutBtn.BackgroundTransparency = 0.2
local ZOC = Instance.new("UICorner"); ZOC.CornerRadius = UDim.new(0, 8); ZOC.Parent = ZoomOutBtn

local ZoomInBtn = Instance.new("TextButton"); ZoomInBtn.Parent = TopBar; ZoomInBtn.Position = UDim2.new(1, -114, 0, 8); ZoomInBtn.Size = UDim2.new(0, 32, 0, 32); ZoomInBtn.Text = "+"; ZoomInBtn.TextColor3 = GLASS_THEME.Text; ZoomInBtn.Font = Enum.Font.GothamBold; ZoomInBtn.TextSize = 15; ZoomInBtn.BackgroundColor3 = GLASS_THEME.Card; ZoomInBtn.BackgroundTransparency = 0.2
local ZIC = Instance.new("UICorner"); ZIC.CornerRadius = UDim.new(0, 8); ZIC.Parent = ZoomInBtn

ZoomInBtn.MouseButton1Click:Connect(function()
	userManualZoom = math.clamp(userManualZoom + 0.1, 0.5, 1.8)
	ScreenScale.Scale = baseAutoMultiplier * userManualZoom
end)

ZoomOutBtn.MouseButton1Click:Connect(function()
	userManualZoom = math.clamp(userManualZoom - 0.1, 0.5, 1.8)
	ScreenScale.Scale = baseAutoMultiplier * userManualZoom
end)

local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = MainFrame; Sidebar.Position = UDim2.new(0, 10, 0, 56); Sidebar.Size = UDim2.new(0, 180, 1, -66); Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 2; Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y; Sidebar.CanvasSize = UDim2.new(0,0,0,0)
local SideLayout = Instance.new("UIListLayout"); Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y; SideLayout.Parent = Sidebar; SideLayout.Padding = UDim.new(0, 5)

local ContentArea = Instance.new("Frame"); ContentArea.Parent = MainFrame; ContentArea.Position = UDim2.new(0, 198, 0, 56); ContentArea.Size = UDim2.new(1, -208, 1, -66); ContentArea.BackgroundColor3 = GLASS_THEME.Header; ContentArea.BackgroundTransparency = 0.2
local ContentCorner = Instance.new("UICorner"); ContentCorner.CornerRadius = UDim.new(0, 12); ContentCorner.Parent = ContentArea

local TabFrames, TabButtons = {}, {}
local function CreateTab(name, icon)
	local Btn = Instance.new("TextButton"); Btn.Parent = Sidebar; Btn.Size = UDim2.new(1, -4, 0, 38); Btn.Text = "  " .. icon .. "  " .. name; Btn.TextColor3 = GLASS_THEME.SubText; Btn.TextSize = 12; Btn.Font = Enum.Font.GothamBold; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.BackgroundColor3 = GLASS_THEME.Card; Btn.BackgroundTransparency = 0.3
	local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 8); Corner.Parent = Btn
	
	local Scroll = Instance.new("ScrollingFrame"); Scroll.Parent = ContentArea; Scroll.Size = UDim2.new(1, -14, 1, -14); Scroll.Position = UDim2.new(0, 7, 0, 7); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 4; Scroll.Visible = false; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.CanvasSize = UDim2.new(0,0,0,0)
	local Lay = Instance.new("UIListLayout"); Lay.Parent = Scroll; Scroll.ScrollingDirection = Enum.ScrollingDirection.Y; Lay.Padding = UDim.new(0, 10)
	TabFrames[name] = Scroll; TabButtons[name] = Btn
	
	Btn.MouseButton1Click:Connect(function()
		for n, f in pairs(TabFrames) do f.Visible = (n == name) end
		for _, b in pairs(TabButtons) do b.BackgroundTransparency = 0.3; b.TextColor3 = GLASS_THEME.SubText; b.BackgroundColor3 = GLASS_THEME.Card end
		Btn.BackgroundTransparency = 0.05; Btn.TextColor3 = GLASS_THEME.Acc1; Btn.BackgroundColor3 = GLASS_THEME.Card
	end)
	return Scroll
end

local function AddGroup(parent, title)
	local GroupCard = Instance.new("Frame"); GroupCard.Parent = parent; GroupCard.Size = UDim2.new(1, 0, 0, 0); GroupCard.AutomaticSize = Enum.AutomaticSize.Y; GroupCard.BackgroundColor3 = GLASS_THEME.Card; GroupCard.BackgroundTransparency = 0.15
	local GC = Instance.new("UICorner"); GC.CornerRadius = UDim.new(0, 10); GC.Parent = GroupCard
	local GS = Instance.new("UIStroke"); GS.Thickness = 1; GS.Color = GLASS_THEME.Acc1; GS.Transparency = 0.8; GS.Parent = GroupCard
	local GLayout = Instance.new("UIListLayout"); GLayout.Parent = GroupCard; GLayout.Padding = UDim.new(0, 8); GLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local GPadding = Instance.new("UIPadding"); GPadding.Parent = GroupCard; GPadding.PaddingTop = UDim.new(0, 10); GPadding.PaddingBottom = UDim.new(0, 10); GPadding.PaddingLeft = UDim.new(0, 10); GPadding.PaddingRight = UDim.new(0, 10)
	
	if title and title ~= "" then
		local HeaderLbl = Instance.new("TextLabel"); HeaderLbl.Parent = GroupCard; HeaderLbl.Size = UDim2.new(1, 0, 0, 24); HeaderLbl.Text = title; HeaderLbl.TextColor3 = GLASS_THEME.Acc1; HeaderLbl.TextSize = 12; HeaderLbl.Font = Enum.Font.GothamBlack; HeaderLbl.TextXAlignment = Enum.TextXAlignment.Left; HeaderLbl.BackgroundTransparency = 1
	end
	return GroupCard
end

local function AddToggle(parent, text, flag, callback)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 36); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 4, 0, 0); L.Size = UDim2.new(0.68, 0, 1, 0); L.Text = text; L.TextColor3 = GLASS_THEME.Text; L.TextSize = 12; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Sw = Instance.new("TextButton"); Sw.Parent = Frm; Sw.Position = UDim2.new(1, -44, 0.5, -11); Sw.Size = UDim2.new(0, 40, 0, 22); Sw.Text = ""; local SwC = Instance.new("UICorner"); SwC.CornerRadius = UDim.new(1, 0); SwC.Parent = Sw
	local Knob = Instance.new("Frame"); Knob.Parent = Sw; Knob.Size = UDim2.new(0, 18, 0, 18); Knob.BackgroundColor3 = GLASS_THEME.Bg; local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1, 0); KC.Parent = Knob
	
	local function updateVisuals()
		Sw.BackgroundColor3 = F[flag] and GLASS_THEME.Acc1 or Color3.fromRGB(50, 50, 50)
		Knob.BackgroundColor3 = F[flag] and Color3.fromRGB(0, 0, 0) or GLASS_THEME.Text
		TweenService:Create(Knob, TweenInfo.new(0.2), {Position = F[flag] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
	end
	table.insert(ConfigUpdaters, updateVisuals)

	Sw.MouseButton1Click:Connect(function()
		F[flag] = not F[flag]
		updateVisuals()
		if callback then pcall(callback, F[flag]) end
	end)
	updateVisuals()
end

local function AddInput(parent, text, flag, isNum)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 38); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 4, 0, 0); L.Size = UDim2.new(0.48, 0, 1, 0); L.Text = text; L.TextColor3 = GLASS_THEME.Text; L.TextSize = 12; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Box = Instance.new("TextBox"); Box.Parent = Frm; Box.Position = UDim2.new(0.5, 0, 0.1, 0); Box.Size = UDim2.new(0.5, 0, 0.8, 0); Box.TextColor3 = GLASS_THEME.Acc1; Box.TextSize = 12; Box.Font = Enum.Font.GothamBold; Box.BackgroundColor3 = GLASS_THEME.Header; Box.BackgroundTransparency = 0.1; local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 6); BC.Parent = Box
	local BS = Instance.new("UIStroke"); BS.Thickness = 1; BS.Color = GLASS_THEME.Acc1; BS.Transparency = 0.5; BS.Parent = Box
	
	local function updateVisuals() Box.Text = tostring(F[flag] or "") end
	table.insert(ConfigUpdaters, updateVisuals)

	Box.FocusLost:Connect(function() F[flag] = isNum and (tonumber(Box.Text) or 0) or Box.Text; updateVisuals() end)
	updateVisuals()
end

local function AddDropdown(parent, title, options, flag, isMulti)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 40); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 4, 0, 0); L.Size = UDim2.new(0.4, 0, 1, 0); L.Text = title; L.TextColor3 = GLASS_THEME.Text; L.TextSize = 12; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Btn = Instance.new("TextButton"); Btn.Parent = Frm; Btn.Position = UDim2.new(0.42, 0, 0.1, 0); Btn.Size = UDim2.new(0.58, 0, 0.8, 0); Btn.TextColor3 = GLASS_THEME.Acc1; Btn.TextSize = 11; Btn.Font = Enum.Font.GothamBold; Btn.BackgroundColor3 = GLASS_THEME.Header; Btn.BackgroundTransparency = 0.1; local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 6); BC.Parent = Btn
	local BS = Instance.new("UIStroke"); BS.Thickness = 1; BS.Color = GLASS_THEME.Acc1; BS.Transparency = 0.5; BS.Parent = Btn
	
	local DropList = Instance.new("Frame"); DropList.Parent = MainFrame; DropList.Size = UDim2.new(0, 280, 0, 220); DropList.BackgroundColor3 = GLASS_THEME.Bg; DropList.Visible = false; DropList.ZIndex = 300
	local DLC = Instance.new("UICorner"); DLC.CornerRadius = UDim.new(0, 8); DLC.Parent = DropList
	local DLS = Instance.new("UIStroke"); DLS.Thickness = 1.2; DLS.Color = GLASS_THEME.Acc1; DLS.Parent = DropList
	
	local SearchBox = Instance.new("TextBox"); SearchBox.Parent = DropList; SearchBox.Size = UDim2.new(1, -14, 0, 28); SearchBox.Position = UDim2.new(0, 7, 0, 7); SearchBox.PlaceholderText = "🔍 Cari Pilihan..."; SearchBox.Text = ""; SearchBox.TextColor3 = GLASS_THEME.Text; SearchBox.PlaceholderColor3 = GLASS_THEME.SubText; SearchBox.TextSize = 11; SearchBox.Font = Enum.Font.GothamMedium; SearchBox.BackgroundColor3 = GLASS_THEME.Header; SearchBox.ZIndex = 301
	local SC = Instance.new("UICorner"); SC.CornerRadius = UDim.new(0, 5); SC.Parent = SearchBox
	
	local ActionHeader = Instance.new("Frame"); ActionHeader.Parent = DropList; ActionHeader.Position = UDim2.new(0, 7, 0, 40); ActionHeader.Size = UDim2.new(1, -14, 0, 24); ActionHeader.BackgroundTransparency = 1; ActionHeader.ZIndex = 301
	
	local BtnSelAll = Instance.new("TextButton"); BtnSelAll.Parent = ActionHeader; BtnSelAll.Size = UDim2.new(0.48, 0, 1, 0); BtnSelAll.Position = UDim2.new(0, 0, 0, 0); BtnSelAll.Text = "✅ Select All"; BtnSelAll.TextColor3 = GLASS_THEME.Acc1; BtnSelAll.Font = Enum.Font.GothamBold; BtnSelAll.TextSize = 10; BtnSelAll.BackgroundColor3 = GLASS_THEME.Card; BtnSelAll.ZIndex = 301
	local SAC = Instance.new("UICorner"); SAC.CornerRadius = UDim.new(0, 4); SAC.Parent = BtnSelAll
	
	local BtnClrAll = Instance.new("TextButton"); BtnClrAll.Parent = ActionHeader; BtnClrAll.Size = UDim2.new(0.48, 0, 1, 0); BtnClrAll.Position = UDim2.new(0.52, 0, 0, 0); BtnClrAll.Text = "✕ Clear All"; BtnClrAll.TextColor3 = GLASS_THEME.SubText; BtnClrAll.Font = Enum.Font.GothamBold; BtnClrAll.TextSize = 10; BtnClrAll.BackgroundColor3 = GLASS_THEME.Card; BtnClrAll.ZIndex = 301
	local CAC = Instance.new("UICorner"); CAC.CornerRadius = UDim.new(0, 4); CAC.Parent = BtnClrAll

	local ScrollOpts = Instance.new("ScrollingFrame"); ScrollOpts.Parent = DropList; ScrollOpts.Position = UDim2.new(0, 7, 0, isMulti and 68 or 40); ScrollOpts.Size = UDim2.new(1, -14, 1, isMulti and -74 or -46); ScrollOpts.BackgroundTransparency = 1; ScrollOpts.ScrollBarThickness = 4; ScrollOpts.ZIndex = 301; ScrollOpts.AutomaticCanvasSize = Enum.AutomaticSize.Y; ScrollOpts.CanvasSize = UDim2.new(0,0,0,0)
	local DLL = Instance.new("UIListLayout"); DLL.Parent = ScrollOpts; DLL.Padding = UDim.new(0, 3)
	
	if not isMulti then ActionHeader.Visible = false end

	local function UpdatePos()
		if DropList.Visible then DropList.Position = UDim2.new(0, Btn.AbsolutePosition.X - MainFrame.AbsolutePosition.X, 0, (Btn.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y) + Btn.AbsoluteSize.Y + 2) end
	end
	Btn:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos)

	local updateCheckList = {}
	local function updateMainBtn() 
		if isMulti then
			local selectedArr = F[flag] or {}
			local count = #selectedArr
			if count == 0 then
				Btn.Text = "Pilih Multi..."
			elseif count == 1 then
				Btn.Text = tostring(selectedArr[1])
			else
				Btn.Text = tostring(selectedArr[1]) .. " (+" .. (count - 1) .. " Lainnya)"
			end
		else
			Btn.Text = tostring(F[flag] or "Pilih")
		end
	end
	table.insert(ConfigUpdaters, updateMainBtn)

	local function Render(filterText)
		filterText = string.lower(filterText or "")
		for _, v in pairs(ScrollOpts:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
		
		for _, opt in ipairs(options) do
			if filterText == "" or string.find(string.lower(opt.label), filterText) then
				local OptBtn = Instance.new("TextButton"); OptBtn.Parent = ScrollOpts; OptBtn.Size = UDim2.new(1, 0, 0, 32); OptBtn.Text = "  " .. tostring(opt.label); OptBtn.TextColor3 = GLASS_THEME.Text; OptBtn.TextSize = 11; OptBtn.Font = Enum.Font.GothamMedium; OptBtn.TextXAlignment = Enum.TextXAlignment.Left; OptBtn.BackgroundColor3 = GLASS_THEME.Card; OptBtn.BackgroundTransparency = 0.3; OptBtn.ZIndex = 302
				local OC = Instance.new("UICorner"); OC.CornerRadius = UDim.new(0, 5); OC.Parent = OptBtn
				
				local check = Instance.new("Frame"); check.Parent = OptBtn; check.Size = UDim2.new(0, 16, 0, 16); check.Position = UDim2.new(1, -22, 0.5, -8); local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 3); cc.Parent = check; check.ZIndex = 302
				
				local function updateVisuals()
					local sel = false
					if isMulti then for _,v in ipairs(F[flag] or {}) do if v==opt.val then sel=true break end end else sel=(F[flag]==opt.val) end
					check.BackgroundColor3 = sel and GLASS_THEME.Acc1 or Color3.fromRGB(50, 50, 50)
				end
				table.insert(updateCheckList, updateVisuals)
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

	Render("")
	updateMainBtn()
	SearchBox:GetPropertyChangedSignal("Text"):Connect(function() Render(SearchBox.Text) end)
	
	BtnSelAll.MouseButton1Click:Connect(function()
		if isMulti then
			F[flag] = {}
			for _, opt in ipairs(options) do table.insert(F[flag], opt.val) end
			updateMainBtn()
			for _, fn in ipairs(updateCheckList) do pcall(fn) end
		end
	end)
	
	BtnClrAll.MouseButton1Click:Connect(function()
		if isMulti then
			F[flag] = {}
			updateMainBtn()
			for _, fn in ipairs(updateCheckList) do pcall(fn) end
		end
	end)

	Btn.MouseButton1Click:Connect(function() DropList.Visible = not DropList.Visible; UpdatePos() end)
end

local function GetOpts(mode)
	local t = {}; 
	if mode == "rarity" then
		local foundRarities = {}
		pcall(function()
			if G.EntryRegistry and G.EntryRegistry.getEntries then
				for _, entry in pairs(G.EntryRegistry.getEntries()) do
					if entry and entry.rarity and not foundRarities[entry.rarity] then
						foundRarities[entry.rarity] = true
						table.insert(t, {label = tostring(entry.rarity), val = tostring(entry.rarity)})
					end
				end
			end
		end)
		local defaultRarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Divine", "Godly"}
		for _, rName in ipairs(defaultRarities) do
			if not foundRarities[rName] then
				table.insert(t, {label = rName, val = rName})
			end
		end
		table.sort(t, function(a,b) return a.label < b.label end)
	elseif mode == "grade" and G.GradesMod then for n, g in pairs(G.GradesMod) do if type(g)=="table" and g.order then table.insert(t, {label=n, val=n, order=g.order}) end end; table.sort(t, function(a,b) return a.order<b.order end)
	elseif mode == "trait" and G.TraitsMod then for n, g in pairs(G.TraitsMod) do if type(g)=="table" and g.order then table.insert(t, {label=n, val=n, order=g.order}) end end; table.sort(t, function(a,b) return a.order<b.order end)
	elseif mode == "quirk" and G.QuirksMod then for n, q in pairs(G.QuirksMod) do if type(q)=="table" then table.insert(t, {label=n, val=n}) end end; table.sort(t, function(a,b) return a.label<b.label end)
	elseif mode == "pot" and G.BoostConfig then for n, e in pairs(G.BoostConfig.entries or {}) do table.insert(t, {label=n.." [T"..tostring(e.tier)..']', val=n}) end; table.sort(t, function(a,b) return a.label<b.label end)
	elseif mode == "unit" then
		local placed = {}; pcall(function() for _, d in pairs(slots()) do if d.unitId then placed[d.unitId]=true end end end)
		for k, e in pairs(inventory()) do
			if isUnitEntry(e) then
				local lvl = (e.attributes and tonumber(e.attributes.level)) or 1
				local inc = FormatMoney(baseIncome(e))
				local labelStr = string.format("%s [Lv.%d | 💰$%s/s]%s", tostring(e.name), lvl, inc, placed[k] and " ★" or "")
				table.insert(t, {label=labelStr, val=k, inc=baseIncome(e)})
			end
		end
		table.sort(t, function(a,b) return a.inc > b.inc end)
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
		local addedTowers = {}
		pcall(function()
			local all = G.TowersConfig and G.TowersConfig.GetAll and G.TowersConfig.GetAll()
			if type(all) == "table" then
				for name in pairs(all) do
					addedTowers[name] = true
					table.insert(t, {label=name, val=name})
				end
			end
		end)
		local defaultTowers = {"Dragon Tower", "Demon Tower", "Ninja Tower", "Pirate Tower", "Hunter Tower", "Cursed Tower", "Halloween Tower", "Haunted Front Yard", "Haunted Crypt", "Haunted Attic", "Haunted Bell Tower"}
		for _, name in ipairs(defaultTowers) do
			if not addedTowers[name] then
				table.insert(t, {label=name, val=name})
			end
		end
		table.sort(t, function(a,b) return a.label < b.label end)
	end
	return t
end

-- ===================================================================== --
-- 5. TABS ASSEMBLY
-- ===================================================================== --
local T_Dash = CreateTab("Dashboard", "📊")
local T_Farm = CreateTab("Farming", "⛏️")
local T_Hlw  = CreateTab("Halloween", "🎃")
local T_Inv  = CreateTab("Inventory", "🎒")
local T_Pot  = CreateTab("Potions", "🧪")
local T_Qrk  = CreateTab("Quirk & Roll", "⚡")
local T_Grd  = CreateTab("Grade & Roll", "⭐")
local T_Trt  = CreateTab("Trait & Roll", "🧬")
local T_Twr  = CreateTab("Tower Utama", "🏰")
local T_Set  = CreateTab("Settings", "⚙️")

TabFrames["Dashboard"].Visible = true; Sidebar:GetChildren()[2].BackgroundTransparency = 0.05; Sidebar:GetChildren()[2].TextColor3 = GLASS_THEME.Acc1

-- 1. DASHBOARD TAB
local G_Profile = AddGroup(T_Dash, "PROFIL & STATISTIK REAL-TIME")
local ProfContainer = Instance.new("Frame"); ProfContainer.Parent = G_Profile; ProfContainer.Size = UDim2.new(1, 0, 0, 85); ProfContainer.BackgroundTransparency = 1
local PImg = Instance.new("ImageLabel"); PImg.Parent = ProfContainer; PImg.AnchorPoint = Vector2.new(0, 0.5); PImg.Position = UDim2.new(0, 6, 0.5, 0); PImg.Size = UDim2.new(0, 68, 0, 68); pcall(function() PImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end); local PImgC = Instance.new("UICorner"); PImgC.CornerRadius = UDim.new(1,0); PImgC.Parent = PImg; local PStr = Instance.new("UIStroke"); PStr.Thickness = 1.8; PStr.Color = GLASS_THEME.Acc1; PStr.Parent = PImg

local PLbl = Instance.new("TextLabel"); PLbl.Parent = ProfContainer; PLbl.Position = UDim2.new(0, 86, 0, 0); PLbl.Size = UDim2.new(1, -92, 1, 0); PLbl.BackgroundTransparency = 1; PLbl.TextColor3 = GLASS_THEME.Text; PLbl.TextSize = 12; PLbl.Font = Enum.Font.GothamMedium; PLbl.TextXAlignment = Enum.TextXAlignment.Left; PLbl.TextYAlignment = Enum.TextYAlignment.Center

local G_TrackerMon = AddGroup(T_Dash, "📈 DYNAMIC TASK & REAL-TIME MONEY TRACKER")
local TrackerLbl = Instance.new("TextLabel"); TrackerLbl.Parent = G_TrackerMon; TrackerLbl.Size = UDim2.new(1, 0, 0, 75); TrackerLbl.BackgroundTransparency = 1; TrackerLbl.TextColor3 = GLASS_THEME.Text; TrackerLbl.TextSize = 12; TrackerLbl.Font = Enum.Font.GothamMedium; TrackerLbl.TextXAlignment = Enum.TextXAlignment.Left; TrackerLbl.TextYAlignment = Enum.TextYAlignment.Top

local TaskTrackerState = {
	SessionStartTime = os.clock(),
	StartingMoney = 0,
	CurrentMoneyRate = 0,
	LastMoneyCheck = 0,
	LastMoneyValue = 0,
	TargetMoneyMilestone = 1e6
}

task.spawn(function()
	task.wait(1)
	pcall(function()
		TaskTrackerState.StartingMoney = money()
		TaskTrackerState.LastMoneyValue = TaskTrackerState.StartingMoney
		TaskTrackerState.LastMoneyCheck = os.clock()
	end)
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		pcall(function()
			local currentMoney = money()
			local currentTime = os.clock()
			local timeElapsed = currentTime - TaskTrackerState.LastMoneyCheck
			
			if timeElapsed >= 1 then
				local moneyGained = currentMoney - TaskTrackerState.LastMoneyValue
				TaskTrackerState.CurrentMoneyRate = math.floor(moneyGained / timeElapsed)
				TaskTrackerState.LastMoneyValue = currentMoney
				TaskTrackerState.LastMoneyCheck = currentTime
			end
			
			if currentMoney >= TaskTrackerState.TargetMoneyMilestone then
				SendWebhook("🎯 Task Target Reached!", "Akun bot berhasil mencapai milestone money sebesar **" .. FormatMoney(TaskTrackerState.TargetMoneyMilestone) .. "**", 3066993)
				TaskTrackerState.TargetMoneyMilestone = TaskTrackerState.TargetMoneyMilestone * 2.5
			end
		end)
		task.wait(1)
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		pcall(function()
			local sessionDuration = math.floor(os.clock() - TaskTrackerState.SessionStartTime)
			local hours = math.floor(sessionDuration / 3600)
			local minutes = math.floor((sessionDuration % 3600) / 60)
			local seconds = sessionDuration % 60
			local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)
			
			local currentMoney = money()
			local totalEarned = currentMoney - TaskTrackerState.StartingMoney
			if totalEarned < 0 then totalEarned = 0 end

			TrackerLbl.Text = string.format(
				"⏱️ Durasi Sesi: %s\n💰 Pendapatan Sesi Ini: +$%s (%s/detik)\n🎯 Target Money Berikutnya: %s\n📊 Status Target: Berjalan Aktif",
				timeString,
				FormatMoney(totalEarned),
				FormatMoney(TaskTrackerState.CurrentMoneyRate),
				FormatMoney(TaskTrackerState.TargetMoneyMilestone)
			)
		end)
		task.wait(0.8)
	end
end)

local G_Stats = AddGroup(T_Dash, "SYSTEM PERFORMANCE")
local SLbl = Instance.new("TextLabel"); SLbl.Parent = G_Stats; SLbl.Size = UDim2.new(1, 0, 0, 95); SLbl.BackgroundTransparency = 1; SLbl.TextColor3 = GLASS_THEME.Text; SLbl.TextSize = 12; SLbl.Font = Enum.Font.GothamMedium; SLbl.TextXAlignment = Enum.TextXAlignment.Left; SLbl.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
	local lastTime = os.clock()
	local frameCount = 0
	RunService.RenderStepped:Connect(function()
		frameCount = frameCount + 1
		local now = os.clock()
		if now - lastTime >= 1 then
			STATE.fpsCurrent = frameCount
			frameCount = 0
			lastTime = now
		end
	end)

	while task.wait(0.8) do pcall(function()
		local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() or 0)
		STATE.pingMs = ping
		local m = money(); local rb = rebirthAmt(); local rls = G.DC.Rolls() or 0
		PLbl.Text = string.format("👤 Player: %s\n💰 Money: %s\n🔄 Rebirth: %s | 🎲 Rolls: %s\n⚡ Ping: %d ms | 🖥️ FPS: %d", LocalPlayer.Name, FormatMoney(m), tostring(rb), tostring(rls), STATE.pingMs, STATE.fpsCurrent)
		
		local qrk, trt, grd, tot = 0,0,0,0
		for _, e in pairs(inventory()) do
			if isUnitEntry(e) then
				tot += 1
				if e.attributes then
					if e.attributes.quirk or e.attributes.mutation then qrk+=1 end
					if e.attributes.trait then trt+=1 end
					if e.attributes.grade then grd+=1 end
				end
			end
		end
		
		local buffs = ""; if G.BuffController and G.BuffController.ActiveBuffs then for k,v in pairs(G.BuffController.ActiveBuffs) do buffs = buffs..k..", " end end; if buffs=="" then buffs="Tidak ada" end; STATE.activeBuffs = buffs
		SLbl.Text = string.format("💎 Gems: %s | 🧬 Trait Rerolls: %s\n⚔️ Total Units: %d/100\n⚡ Quirks: %d | 🧬 Traits: %d | ⭐ Grades: %d\n🧪 Active Buffs: %s", FormatMoney(currencyAmount("Gems")), FormatMoney(currencyAmount("Trait Reroll")), tot, qrk, trt, grd, STATE.activeBuffs)
	end) end
end)

-- 2. FARMING TAB (DITAMBAHKAN UI DELAY COLLECT PLOT MONEY)
local G_Farm1 = AddGroup(T_Farm, "AI PLOT, ROLL & SMART PLACEMENT")
AddToggle(G_Farm1, "Auto Collect Plot Balance", "collect")
AddInput(G_Farm1, "Delay Collect Plot (Detik):", "collectDelay", true)
AddToggle(G_Farm1, "Auto Roll Dadu (Otomatis)", "autoRoll")
AddToggle(G_Farm1, "AI Smart Place Unit Terbaik (Money/Lucky)", "autoBestPlaceBase")
AddToggle(G_Farm1, "Auto Rebirth (Prioritas Tujuan)", "rebirth")
AddToggle(G_Farm1, "Auto Buy & Equip Best Dice Shop", "buyDice")

local G_Farm2 = AddGroup(T_Farm, "LEVELING & SKILL TREE UPGRADES")
AddToggle(G_Farm2, "Auto Level Up Unit Plot", "levelup")
AddInput(G_Farm2, "Max Level Unit Batas:", "maxLevel", true)
AddToggle(G_Farm2, "Auto Upgrade Skill Tree Pad", "upgrades")

-- 3. HALLOWEEN TAB
local G_HlwTeleport = AddGroup(T_Hlw, "HALLOWEEN WORLD & INTRO")
AddToggle(G_HlwTeleport, "Auto Teleport Ke Halloween World", "halloweenTeleport")

local G_HlwRoll = AddGroup(T_Hlw, "PUMPKIN DICE & SPECIFIC AUTO SELL")
AddDropdown(G_HlwRoll, "Kuantitas Pumpkin Roll:", {{label="Roll 1x", val=1}, {label="Roll 5x", val=5}}, "pumpkinRollQty", false)
AddToggle(G_HlwRoll, "Auto Roll Pumpkin Dice", "pumpkinAutoRoll")
AddToggle(G_HlwRoll, "Auto Sell Pumpkin Units (Server)", "pumpkinAutoSell")
AddDropdown(G_HlwRoll, "Nama Unit Spesifik Auto Sell:", GetOpts("unit_name"), "specificSellUnits", true)

local G_HlwQuests = AddGroup(T_Hlw, "HALLOWEEN REWARDS & EVENT")
AddToggle(G_HlwQuests, "Auto Claim Halloween Quests", "halloweenQuest")
AddToggle(G_HlwQuests, "Auto Claim Halloween Path Rewards", "halloweenPath")
AddToggle(G_HlwQuests, "Auto Buy Halloween Special Offers", "halloweenOffer")
AddToggle(G_HlwQuests, "Auto Trick or Treat (Knock Doors)", "trickOrTreat")

local G_HauntedTwr = AddGroup(T_Hlw, "HAUNTED TOWER FARMING (JALUR ALTERNATIF AI)")
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
AddInput(G_HauntedTwr, "Batas Lantai Exit Haunted:", "hauntedExitFloor", true)

local G_HauntedMon = AddGroup(T_Hlw, "LIVE MONITORING HAUNTED TOWER")
local HauntedLbl = Instance.new("TextLabel"); HauntedLbl.Parent = G_HauntedMon; HauntedLbl.Size = UDim2.new(1,0,0,60); HauntedLbl.BackgroundTransparency = 1; HauntedLbl.TextColor3 = GLASS_THEME.Text; HauntedLbl.TextSize = 12; HauntedLbl.Font = Enum.Font.GothamMedium; HauntedLbl.TextXAlignment = Enum.TextXAlignment.Left; HauntedLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function() while task.wait(0.5) do pcall(function() HauntedLbl.Text = string.format("🎃 Status: %s\n🏢 Lantai: %d | 🍬 Total Drops/Item: %d", STATE.hauntedLive, STATE.hauntedFloor, STATE.hauntedDrops) end) end end)

-- 4. INVENTORY TAB
local G_Inv = AddGroup(T_Inv, "MANAGEMENT, RARITY KEEP & AUTO LOCK")
AddToggle(G_Inv, "Auto Sell General (Jual Rarity Lain)", "sellAuto")
AddToggle(G_Inv, "Auto Sell Saat Inventory Penuh", "sellMaxInvent")
AddInput(G_Inv, "Simpan Unit Terbaik (Keep Best):", "keepBest", true)
AddDropdown(G_Inv, "Pilih Rarity yang Disimpan:", GetOpts("rarity"), "keepRarities", true)
AddToggle(G_Inv, "Auto Lock Unit Rarity Terpilih", "autoLockRarity")
AddToggle(G_Inv, "Auto Fusion Unit", "autoFuse")

-- 5. POTIONS TAB
local G_Pot = AddGroup(T_Pot, "AI THRESHOLD POTION MANAGER")
AddToggle(G_Pot, "Auto Gunakan Potion (Berdasarkan Resource Safe)", "potionAuto")
AddDropdown(G_Pot, "Pilih Potion Spesifik (Multi-Select):", GetOpts("pot"), "potionSpecific", true)

-- 6. QUIRK TAB
local G_QrkCtrl = AddGroup(T_Qrk, "AI THRESHOLD & QUIRK REROLL CONFIG")
AddToggle(G_QrkCtrl, "Auto Lock Unit jika Quirk Target", "autoLockTarget")
AddToggle(G_QrkCtrl, "Aktifkan Auto Quirk Reroll (Smart Threshold)", "quirkAuto")
AddDropdown(G_QrkCtrl, "Target Quirk (Multi-Select):", GetOpts("quirk"), "quirkTargets", true)
AddDropdown(G_QrkCtrl, "Pilih Unit Reroll Quirk:", GetOpts("unit"), "quirkUnits", true)
AddInput(G_QrkCtrl, "Sisakan Quirk Reserve Minimum:", "quirkReserve", true)

local G_QrkMon = AddGroup(T_Qrk, "⚡ REALTIME MONITORING QUIRK")
local QrkLbl = Instance.new("TextLabel"); QrkLbl.Parent = G_QrkMon; QrkLbl.Size = UDim2.new(1,0,0,75); QrkLbl.BackgroundTransparency = 1; QrkLbl.TextColor3 = GLASS_THEME.Text; QrkLbl.TextSize = 12; QrkLbl.Font = Enum.Font.GothamMedium; QrkLbl.TextXAlignment = Enum.TextXAlignment.Left; QrkLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function()
	while task.wait(0.3) do pcall(function()
		QrkLbl.Text = string.format("🎯 Unit Aktif: %s\n⚡ Quirk Saat Ini: %s\n📊 Log Roll: %s", STATE.quirkActiveUnit, STATE.quirkCurrentVal, STATE.quirkStatus)
	end) end
end)

-- 7. GRADE TAB
local G_GrdCtrl = AddGroup(T_Grd, "AI THRESHOLD & GRADE REROLL CONFIG")
AddToggle(G_GrdCtrl, "Aktifkan Auto Grade Reroll (Smart Threshold)", "gradeAuto")
AddToggle(G_GrdCtrl, "Hanya Unit di Base (Placed)", "gradePlacedOnly")
AddDropdown(G_GrdCtrl, "Target Grade (Multi-Select):", GetOpts("grade"), "gradeTargets", true)
AddDropdown(G_GrdCtrl, "Pilih Unit Reroll Grade:", GetOpts("unit"), "gradeUnits", true)
AddInput(G_GrdCtrl, "Sisakan Gems Minimum (Threshold):", "gemReserve", true)

local G_GrdMon = AddGroup(T_Grd, "⭐ REALTIME MONITORING GRADE")
local GrdLbl = Instance.new("TextLabel"); GrdLbl.Parent = G_GrdMon; GrdLbl.Size = UDim2.new(1,0,0,75); GrdLbl.BackgroundTransparency = 1; GrdLbl.TextColor3 = GLASS_THEME.Text; GrdLbl.TextSize = 12; GrdLbl.Font = Enum.Font.GothamMedium; GrdLbl.TextXAlignment = Enum.TextXAlignment.Left; GrdLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function()
	while task.wait(0.3) do pcall(function()
		GrdLbl.Text = string.format("🎯 Unit Aktif: %s\n🌟 Grade Saat Ini: %s\n📊 Log Roll: %s", STATE.gradeActiveUnit, STATE.gradeCurrentVal, STATE.gradeStatus)
	end) end
end)

-- 8. TRAIT TAB
local G_TrtCtrl = AddGroup(T_Trt, "AI THRESHOLD & TRAIT REROLL CONFIG")
AddToggle(G_TrtCtrl, "Aktifkan Auto Trait Reroll (Smart Threshold)", "traitAuto")
AddToggle(G_TrtCtrl, "Hanya Unit di Base (Placed)", "traitPlacedOnly")
AddDropdown(G_TrtCtrl, "Target Trait (Multi-Select):", GetOpts("trait"), "traitTargets", true)
AddDropdown(G_TrtCtrl, "Pilih Unit Reroll Trait:", GetOpts("unit"), "traitUnits", true)
AddInput(G_TrtCtrl, "Sisakan Trait Reroll Minimum (Threshold):", "rerollReserve", true)

local G_TrtMon = AddGroup(T_Trt, "🧬 REALTIME MONITORING TRAIT")
local TrtLbl = Instance.new("TextLabel"); TrtLbl.Parent = G_TrtMon; TrtLbl.Size = UDim2.new(1,0,0,75); TrtLbl.BackgroundTransparency = 1; TrtLbl.TextColor3 = GLASS_THEME.Text; TrtLbl.TextSize = 12; TrtLbl.Font = Enum.Font.GothamMedium; TrtLbl.TextXAlignment = Enum.TextXAlignment.Left; TrtLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function()
	while task.wait(0.3) do pcall(function()
		TrtLbl.Text = string.format("🎯 Unit Aktif: %s\n🧬 Trait Saat Ini: %s\n📊 Log Roll: %s", STATE.traitActiveUnit, STATE.traitCurrentVal, STATE.traitStatus)
	end) end
end)

-- 9. MAIN TOWER TAB
local G_Twr = AddGroup(T_Twr, "MAIN TOWER FARMING SETUP (JALUR ALTERNATIF)")
AddToggle(G_Twr, "Auto Main Tower Farming", "tower")
AddToggle(G_Twr, "Mode MIX / Random Tower", "towerMix")
AddDropdown(G_Twr, "Pilih Main Tower (Multi-Select):", GetOpts("towers"), "towerList", true)
AddToggle(G_Twr, "Auto Equip Best Team Tower", "towerEquipBest")
AddToggle(G_Twr, "Keluar di Lantai Tertentu", "towerExitOn")
AddInput(G_Twr, "Batas Lantai Exit Tower:", "towerExitFloor", true)

local G_TwrMon = AddGroup(T_Twr, "LIVE TOWER MONITORING & TRAIT DROPS")
local TwrLbl = Instance.new("TextLabel"); TwrLbl.Parent = G_TwrMon; TwrLbl.Size = UDim2.new(1,0,0,60); TwrLbl.BackgroundTransparency = 1; TwrLbl.TextColor3 = GLASS_THEME.Text; TwrLbl.TextSize = 12; TwrLbl.Font = Enum.Font.GothamMedium; TwrLbl.TextXAlignment = Enum.TextXAlignment.Left; TwrLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function() while task.wait(0.5) do pcall(function() TwrLbl.Text = string.format("🎮 Status: %s\n🏢 Lantai: %d | 💎 Gems Didapat: %d\n🧬 Trait Drops: %s", STATE.towerLive, STATE.towerFloor, STATE.towerDrops, tostring(STATE.towerTraitsGot)) end) end end)

-- 10. SETTINGS TAB
local G_SetConfig = AddGroup(T_Set, "📁 FILE CONFIGURATION MANAGEMENT")
AddToggle(G_SetConfig, "Auto Load Config Saat Nyala", "autoLoadEnabled")
AddInput(G_SetConfig, "Nama File Config:", "cfgName", false)

local BtnSave = Instance.new("TextButton"); BtnSave.Parent = G_SetConfig; BtnSave.Size = UDim2.new(1, 0, 0, 34); BtnSave.Text = "💾 SAVE CONFIG SEKARANG"; BtnSave.Font = Enum.Font.GothamBold; BtnSave.TextSize = 12; BtnSave.TextColor3 = GLASS_THEME.Acc1; BtnSave.BackgroundColor3 = GLASS_THEME.Header; local BTS = Instance.new("UICorner"); BTS.CornerRadius = UDim.new(0,6); BTS.Parent = BtnSave
BtnSave.MouseButton1Click:Connect(function() pcall(function() saveConfig(F.cfgName) end) end)

local BtnLoad = Instance.new("TextButton"); BtnLoad.Parent = G_SetConfig; BtnLoad.Size = UDim2.new(1, 0, 0, 34); BtnLoad.Text = "📂 LOAD CONFIG PILIHAN"; BtnLoad.Font = Enum.Font.GothamBold; BtnLoad.TextSize = 12; BtnLoad.TextColor3 = GLASS_THEME.Acc1; BtnLoad.BackgroundColor3 = GLASS_THEME.Header; local BTL = Instance.new("UICorner"); BTL.CornerRadius = UDim.new(0,6); BTL.Parent = BtnLoad
BtnLoad.MouseButton1Click:Connect(function() pcall(function() loadConfig(F.cfgName) end) end)

local BtnDelete = Instance.new("TextButton"); BtnDelete.Parent = G_SetConfig; BtnDelete.Size = UDim2.new(1, 0, 0, 34); BtnDelete.Text = "🗑️ DELETE CONFIG PILIHAN"; BtnDelete.Font = Enum.Font.GothamBold; BtnDelete.TextSize = 12; BtnDelete.TextColor3 = Color3.fromRGB(200, 200, 200); BtnDelete.BackgroundColor3 = GLASS_THEME.Header; local BTD = Instance.new("UICorner"); BTD.CornerRadius = UDim.new(0,6); BTD.Parent = BtnDelete

local ConfigScroll = Instance.new("ScrollingFrame"); ConfigScroll.Parent = G_SetConfig; ConfigScroll.Size = UDim2.new(1, 0, 0, 100); ConfigScroll.BackgroundColor3 = GLASS_THEME.Header; ConfigScroll.BackgroundTransparency = 0.3; ConfigScroll.ScrollBarThickness = 4; ConfigScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; ConfigScroll.CanvasSize = UDim2.new(0,0,0,0)
local CSC = Instance.new("UICorner"); CSC.CornerRadius = UDim.new(0, 6); CSC.Parent = ConfigScroll
local ConfigLayout = Instance.new("UIListLayout"); ConfigLayout.Parent = ConfigScroll; ConfigLayout.Padding = UDim.new(0, 4)

local function RefreshConfigList()
	for _, v in pairs(ConfigScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
	if listfiles then
		pcall(function()
			for _, file in ipairs(listfiles(CFG_FOLDER)) do
				local fileName = file:match("([^/]+)$"):gsub("%.json$", "")
				local FileBtn = Instance.new("TextButton"); FileBtn.Parent = ConfigScroll; FileBtn.Size = UDim2.new(1, 0, 0, 32); FileBtn.Text = "📄 " .. fileName; FileBtn.TextSize = 11; FileBtn.Font = Enum.Font.GothamMedium; FileBtn.TextColor3 = GLASS_THEME.Text; FileBtn.BackgroundColor3 = GLASS_THEME.Card; FileBtn.BackgroundTransparency = 0.2
				local FBC = Instance.new("UICorner"); FBC.CornerRadius = UDim.new(0, 5); FBC.Parent = FileBtn
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

local confirmDeleteClick = false
BtnDelete.MouseButton1Click:Connect(function()
	pcall(function()
		local path = getCfgPath(F.cfgName)
		if delfile and isfile and isfile(path) then 
			if not confirmDeleteClick then
				confirmDeleteClick = true
				BtnDelete.Text = "⚠️ YAKIN HAPUS '" .. tostring(F.cfgName) .. "'? (KLIK LAGI)"
				task.delay(3, function() confirmDeleteClick = false; BtnDelete.Text = "🗑️ DELETE CONFIG PILIHAN" end)
				return
			end
			confirmDeleteClick = false
			BtnDelete.Text = "🗑️ DELETE CONFIG PILIHAN"
			delfile(path) 
			RefreshConfigList()
		end
	end)
end)

local BtnRefresh = Instance.new("TextButton"); BtnRefresh.Parent = G_SetConfig; BtnRefresh.Size = UDim2.new(1, 0, 0, 32); BtnRefresh.Text = "🔄 REFRESH LIST CONFIG"; BtnRefresh.Font = Enum.Font.GothamBold; BtnRefresh.TextSize = 11; BtnRefresh.TextColor3 = GLASS_THEME.Acc1; BtnRefresh.BackgroundColor3 = GLASS_THEME.Card; local BTR = Instance.new("UICorner"); BTR.CornerRadius = UDim.new(0,6); BTR.Parent = BtnRefresh
BtnRefresh.MouseButton1Click:Connect(RefreshConfigList)

local G_Web = AddGroup(T_Set, "🔔 DISCORD WEBHOOK NOTIFIER")
AddToggle(G_Web, "Aktifkan Webhook Discord", "webhookEnabled")
AddInput(G_Web, "Webhook URL:", "webhookUrl", false)
local BtnTestWeb = Instance.new("TextButton"); BtnTestWeb.Parent = G_Web; BtnTestWeb.Size = UDim2.new(1, 0, 0, 32); BtnTestWeb.Text = "🔔 TEST KIRIM WEBHOOK"; BtnTestWeb.Font = Enum.Font.GothamBold; BtnTestWeb.TextSize = 11; BtnTestWeb.TextColor3 = GLASS_THEME.Acc1; BtnTestWeb.BackgroundColor3 = GLASS_THEME.Header; local BTWC = Instance.new("UICorner"); BTWC.CornerRadius = UDim.new(0,6); BTWC.Parent = BtnTestWeb
BtnTestWeb.MouseButton1Click:Connect(function() SendWebhook("✅ Webhook Connected!", "AI Smart Planner tersambung sukses.", 3447003) end)

local G_Set2 = AddGroup(T_Set, "⚡ OPTIMALISASI & SERVER UTILITY")
AddToggle(G_Set2, "Anti-AFK Protection", "afk")
AddToggle(G_Set2, "FPS Boost (Optimasi Partikel)", "fpsOn", function(v) if v then pcall(function() game:GetService("Lighting").GlobalShadows = false; for _,e in ipairs(workspace:GetDescendants()) do if e:IsA("BasePart") then e.Material = Enum.Material.SmoothPlastic end end end) end end)
AddToggle(G_Set2, "Auto Claim Quests & Daily Rewards", "claimQuests")
AddToggle(G_Set2, "Auto Redeem Codes", "codesAuto")

local BtnHop = Instance.new("TextButton"); BtnHop.Parent = G_Set2; BtnHop.Size = UDim2.new(1, 0, 0, 34); BtnHop.Text = "🌐 SERVER HOP (PINDAH SERVER)"; BtnHop.Font = Enum.Font.GothamBlack; BtnHop.TextSize = 12; BtnHop.TextColor3 = GLASS_THEME.Acc1; BtnHop.BackgroundColor3 = GLASS_THEME.Header; local BTH = Instance.new("UICorner"); BTH.CornerRadius = UDim.new(0,6); BTH.Parent = BtnHop

local confirmHopClick = false
BtnHop.MouseButton1Click:Connect(function()
	pcall(function()
		if not confirmHopClick then
			confirmHopClick = true
			BtnHop.Text = "⚠️ YAKIN PINDAH SERVER? (KLIK LAGI)"
			task.delay(3, function() confirmHopClick = false; BtnHop.Text = "🌐 SERVER HOP (PINDAH SERVER)" end)
			return
		end
		confirmHopClick = false
		BtnHop.Text = "🌐 SERVER HOP (PINDAH SERVER)"

		local cursor = ""; local servers = {}
		repeat
			local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
			local success, result = pcall(function() return HttpService:JSONEncode(game:HttpGet(url)) end)
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
-- 6. BACKEND THREADS & GOAL-DRIVEN AI INITIALIZATION
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
	task.wait(2)
	pcall(function()
		local rb = rebirthAmt()
		if rb < 1 then
			F.aiPriorityGoal = "Fokus: Kumpul uang & capai Rebirth pertama!"
		else
			F.aiPriorityGoal = "Fokus: Optimalisasi Money Base & Smart Reroll"
		end
	end)
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.autoLockRarity and R.LockUnit then
			pcall(function()
				for id, u in pairs(inventory()) do
					if isUnitEntry(u) and not isBeingRolled(id) then
						local rarity = getUnitRarity(u)
						local isSelectedRarity = false
						for _, rName in ipairs(F.keepRarities or {}) do
							if string.lower(tostring(rarity)) == string.lower(tostring(rName)) then
								isSelectedRarity = true
								break
							end
						end
						local isLocked = u.attributes and u.attributes.locked
						if isSelectedRarity and not isLocked then
							R.LockUnit:FireServer(id, true)
						elseif not isSelectedRarity and isLocked then
							R.LockUnit:FireServer(id, false)
						end
					end
				end
			end)
		end
		task.wait(3)
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if (F.sellAuto or F.sellMaxInvent) and R.SellInventory then
			pcall(function()
				local d = data()
				local cap = 100
				pcall(function()
					local buff = tonumber(select(2, pcall(G.BuffController.GetBuff, "Unit Storage")))
					if buff and buff > 0 then cap = buff end
				end)

				local totalOwned = 0
				local placed = {}
				for _, slot in pairs(d.Slots or {}) do if slot.unitId then placed[slot.unitId] = true end end
				for _, id in pairs(d.TowerTeam or {}) do placed[id] = true end

				local sellCandidates = {}
				for id, u in pairs(d.Inventory or {}) do
					if isUnitEntry(u) then
						totalOwned += 1
						local rarity = getUnitRarity(u)
						local isKeepRarity = false
						for _, rName in ipairs(F.keepRarities or {}) do
							if string.lower(tostring(rarity)) == string.lower(tostring(rName)) then
								isKeepRarity = true
								break
							end
						end

						if not isKeepRarity and not placed[id] and not isBeingRolled(id) then
							if u.attributes and u.attributes.locked and R.LockUnit then
								R.LockUnit:FireServer(id, false)
								task.wait(0.05)
							end
							table.insert(sellCandidates, { id = id, value = baseIncome(u) })
						end
					end
				end

				local isFull = totalOwned >= (cap - 3)
				if F.sellAuto or (F.sellMaxInvent and isFull) then
					table.sort(sellCandidates, function(a, b) return a.value < b.value end)
					local keepQty = tonumber(F.keepBest) or 0
					local sellCount = math.max(0, #sellCandidates - keepQty)
					
					local list = {}
					for i = 1, sellCount do
						table.insert(list, sellCandidates[i].id)
						if #list >= 150 then break end
					end
					
					if #list > 0 then
						pcall(function()
							if R.SellInventory:IsA("RemoteFunction") then
								R.SellInventory:InvokeServer(list)
							elseif R.SellInventory:IsA("RemoteEvent") then
								R.SellInventory:FireServer(list)
							end
						end)
					end
				end
			end)
		end
		task.wait(3.5)
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.quirkAuto and R.QuirkRoll and #F.quirkUnits > 0 then
			pcall(function()
				local inv = inventory()
				for _, unitId in ipairs(F.quirkUnits) do
					local u = inv[unitId]
					if u and u.attributes then
						if R.LockUnit and not u.attributes.locked then R.LockUnit:FireServer(unitId, true) end
						STATE.quirkActiveUnit = tostring(u.name)
						local curQuirk = u.attributes.quirk or u.attributes.mutation or "None"
						STATE.quirkCurrentVal = tostring(curQuirk)
						
						local isMatch = false
						for _, target in ipairs(F.quirkTargets) do 
							if string.lower(tostring(curQuirk)) == string.lower(tostring(target)) then isMatch = true; break end 
						end

						if isMatch then
							STATE.quirkStatus = "✅ Berhasil: " .. tostring(curQuirk)
							SendWebhook("⚡ Quirk Matched!", "Berhasil mendapatkan Quirk **" .. tostring(curQuirk) .. "**", 65280)
						else
							STATE.quirkStatus = "AI Rolling..."
							R.QuirkRoll:FireServer(unitId)
							task.wait(F.aiJitterDelay + math.random(0,5)*0.1)
						end
					end
				end
			end)
		else STATE.quirkStatus = "Standby" end
		task.wait(1.0)
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.gradeAuto and R.GradeRoll and #F.gradeUnits > 0 then
			pcall(function()
				local gemsAvailable = currencyAmount("Gems")
				local reserve = tonumber(F.gemReserve) or 100
				if gemsAvailable <= reserve then
					STATE.gradeStatus = "⚠️ Threshold Kritis: Gems di bawah cadangan"
				else
					local inv = inventory()
					for _, unitId in ipairs(F.gradeUnits) do
						local u = inv[unitId]
						if u and u.attributes then
							if R.LockUnit and not u.attributes.locked then R.LockUnit:FireServer(unitId, true) end
							STATE.gradeActiveUnit = tostring(u.name)
							local curGrade = u.attributes.grade or "None"
							STATE.gradeCurrentVal = tostring(curGrade)

							local isMatch = false
							for _, target in ipairs(F.gradeTargets) do 
								if string.lower(tostring(curGrade)) == string.lower(tostring(target)) then isMatch = true; break end 
							end

							if isMatch then
								STATE.gradeStatus = "✅ Berhasil: " .. tostring(curGrade)
								SendWebhook("⭐ Grade Matched!", "Berhasil mendapatkan Grade **" .. tostring(curGrade) .. "**", 65280)
							else
								STATE.gradeStatus = "AI Rolling Grade..."
								R.GradeRoll:FireServer(unitId)
								task.wait(F.aiJitterDelay + math.random(0,5)*0.1)
							end
						end
					end
				end
			end)
		else STATE.gradeStatus = "Standby" end
		task.wait(1.0)
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.traitAuto and R.TraitRoll and #F.traitUnits > 0 then
			pcall(function()
				local scrollsAvailable = currencyAmount("Trait Reroll")
				local reserve = tonumber(F.rerollReserve) or 50
				if scrollsAvailable <= reserve then
					STATE.traitStatus = "⚠️ Threshold Kritis: Scroll di bawah cadangan"
				else
					local inv = inventory()
					for _, unitId in ipairs(F.traitUnits) do
						local u = inv[unitId]
						if u and u.attributes then
							if R.LockUnit and not u.attributes.locked then R.LockUnit:FireServer(unitId, true) end
							STATE.traitActiveUnit = tostring(u.name)
							local curTrait = u.attributes.trait or "None"
							STATE.traitCurrentVal = tostring(curTrait)

							local isMatch = false
							for _, target in ipairs(F.traitTargets) do 
								if string.lower(tostring(curTrait)) == string.lower(tostring(target)) then isMatch = true; break end 
							end

							if isMatch then
								STATE.traitStatus = "✅ Berhasil: " .. tostring(curTrait)
								SendWebhook("🧬 Trait Matched!", "Berhasil mendapatkan Trait **" .. tostring(curTrait) .. "**", 65280)
							else
								STATE.traitStatus = "AI Rolling Trait..."
								R.TraitRoll:FireServer(unitId)
								task.wait(F.aiJitterDelay + math.random(0,5)*0.1)
							end
						end
					end
				end
			end)
		else STATE.traitStatus = "Standby" end
		task.wait(1.0)
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.halloweenTeleport and R.HWTeleport then
			pcall(function() R.HWTeleport:InvokeServer(); if R.HWSeenIntro then R.HWSeenIntro:FireServer() end end)
		end
		if F.halloweenQuest and R.HWQuestClaim then pcall(function() R.HWQuestClaim:FireServer() end) end
		if F.halloweenPath and R.HWClaimPath then pcall(function() R.HWClaimPath:FireServer() end) end
		if F.halloweenOffer and R.HWBuyOffer then pcall(function() R.HWBuyOffer:FireServer() end) end
		if F.trickOrTreat and R.TrickOrTreat then pcall(function() R.TrickOrTreat:FireServer() end) end
		task.wait(5)
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.pumpkinAutoRoll and R.PumpkinRoll then
			pcall(function()
				local qty = tonumber(F.pumpkinRollQty) or 1
				for i = 1, qty do
					if not F.pumpkinAutoRoll then break end
					if R.PumpkinRoll:IsA("RemoteFunction") then R.PumpkinRoll:InvokeServer()
					elseif R.PumpkinRoll:IsA("RemoteEvent") then R.PumpkinRoll:FireServer() end
					task.wait(0.3)
				end
			end)
		end
		if R.PumpkinAutoSell then pcall(function() R.PumpkinAutoSell:FireServer(F.pumpkinAutoSell) end) end
		task.wait(3)
	end
end)

local function unlockedSlots() local arr={}; local rb = rebirthAmt(); pcall(function() for i=1, (G.PlotConfig.GetMaxSlots(rb) or 15) do if rb >= (G.PlotConfig.GetSlotRebirthRequirement(i) or 0) then table.insert(arr, i) end end end); return arr end

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.autoRoll then
			pcall(function() if R.RollDice then R.RollDice:InvokeServer() end end)
			task.wait(F.aiJitterDelay + math.random(0, 4) * 0.1)
		else task.wait(1) end
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.autoBestPlaceBase and R.EquipUnit and R.InteractSlot then
			pcall(function()
				local d = data()
				local n = #unlockedSlots()
				local ranked = {}
				for id, u in pairs(d.Inventory or {}) do
					if isUnitEntry(u) then
						local score = baseIncome(u)
						if u.attributes then
							if u.attributes.grade then score = score * 1.2 end
							if u.attributes.trait then score = score * 1.5 end
						end
						ranked[#ranked + 1] = { id = id, v = score }
					end
				end
				table.sort(ranked, function(a, b) return a.v > b.v end)

				local want, placed = {}, {}
				for i = 1, math.min(n, #ranked) do want[ranked[i].id] = ranked[i].v end
				for _, slot in pairs(d.Slots or {}) do if slot.unitId then placed[slot.unitId] = true end end

				local bench = {}
				for i = 1, math.min(n, #ranked) do if not placed[ranked[i].id] then bench[#bench + 1] = ranked[i] end end

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
							if ok and equipped == true then task.wait(0.4); R.InteractSlot:FireServer(slot.i); task.wait(0.4) end
						end
					end
				end
			end)
		end
		task.wait(8)
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.buyDice and G.DiceModule and R.BuyDice and R.EquipDice then
			pcall(function()
				local d = data()
				local allDice = {}
				local ok, all = pcall(G.DiceModule.GetAll)
				if ok and type(all) == "table" then
					for key, def in pairs(all) do table.insert(allDice, { key = key, luck = tonumber(def.luck) or 0, price = tonumber(def.price) }) end
					table.sort(allDice, function(a, b) return a.luck < b.luck end)
				end

				local owned = d.OwnedDice or {}
				local bestOwnedName, bestOwnedLuck = "-", 0
				for _, die in ipairs(allDice) do
					if owned[die.key] and die.luck > bestOwnedLuck then bestOwnedLuck = die.luck; bestOwnedName = die.key end
				end

				local spendable = money()
				for _, die in ipairs(allDice) do
					if die.price and not owned[die.key] and spendable >= die.price and die.luck > bestOwnedLuck then
						R.BuyDice:FireServer(die.key); task.wait(0.3); owned[die.key] = true
					end
				end

				if bestOwnedName ~= "-" and d.Dice ~= bestOwnedName then R.EquipDice:FireServer(bestOwnedName) end
			end)
		end
		task.wait(5)
	end
end)

-- Farming Loop (Menggunakan variabel collectDelay yang baru)
task.spawn(function()
	local lastRebirth = 0
	while _G.__ANIMEDICE == generation do
		if F.collect and R.CollectBalance then 
			pcall(function() 
				for _, slot in ipairs(unlockedSlots()) do 
					R.CollectBalance:FireServer(slot) 
				end 
			end) 
		end
		
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
		
		-- Jeda loop farming disesuaikan dengan collectDelay
		task.wait(math.clamp(tonumber(F.collectDelay) or 2.0, 0.5, 60))
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
						for _, sn in ipairs(F.potionSpecific) do if e.name == sn then shouldUse = true; break end end
						if shouldUse and not active[e.name] and (e.amount > 2) then
							R.BoostUse:FireServer(key); task.wait(1)
						end
					end
				end
			end)
		end
		task.wait(5)
	end
end)

local function drainTower()
	if not R.CancelTower then return end
	pcall(function()
		if R.CancelTower:IsA("RemoteFunction") then R.CancelTower:InvokeServer()
		elseif R.CancelTower:IsA("RemoteEvent") then R.CancelTower:FireServer() end
	end)
	for _ = 1, 20 do
		local ok, seq = pcall(function() if R.CompleteFloor:IsA("RemoteFunction") then return R.CompleteFloor:InvokeServer() end end)
		if ok and type(seq) == "table" then for _, ev in ipairs(seq) do if ev.action == "ended" then return end end end
		task.wait(0.2)
	end
end

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.tower and R.PlayTower and R.CompleteFloor then
			drainTower(); task.wait(0.4)
			if F.towerEquipBest and R.BestTowerTeam then pcall(function() R.BestTowerTeam:FireServer() end) end
			task.wait(0.4)

			local pickTower = "Dragon Tower"
			local choices = (F.towerList and #F.towerList > 0) and F.towerList or {"Dragon Tower", "Demon Tower"}
			pickTower = F.towerMix and choices[math.random(1, #choices)] or choices[1]

			STATE.towerLive = "Jalan: " .. tostring(pickTower); STATE.towerDrops = 0; STATE.towerTraitsGot = "Mencari..."
			pcall(function()
				if R.PlayTower:IsA("RemoteFunction") then R.PlayTower:InvokeServer(pickTower)
				else R.PlayTower:FireServer(pickTower) end
			end)

			local done, fails = false, 0
			while F.tower and not done do
				local okP, seq = pcall(function() if R.CompleteFloor:IsA("RemoteFunction") then return R.CompleteFloor:InvokeServer() end end)
				if okP and type(seq) == "table" and #seq > 0 then
					fails = 0
					for _, act in ipairs(seq) do
						if act.action == "floorStarted" then 
							STATE.towerFloor = tonumber(act.floor) or 1
						elseif act.action == "floorCompleted" then
							if act.rewards and act.rewards.Gems then STATE.towerDrops += act.rewards.Gems end
							if act.rewards and (act.rewards.Trait or act.trait) then STATE.towerTraitsGot = tostring(act.rewards.Trait or act.trait) end
						elseif act.action == "ended" then done = true; break end
					end
					if not done and F.towerExitOn and F.towerExitFloor > 0 and STATE.towerFloor >= F.towerExitFloor then
						done = true; drainTower()
					end
				else fails += 1; if fails > 8 then done = true end; task.wait(1) end
			end
			drainTower(); task.wait(1.5)
		else STATE.towerLive = "Standby"; STATE.towerTraitsGot = "Belum Ada"; task.wait(2) end
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.hauntedTower and R.PlayTower and R.CompleteFloor then
			drainTower(); task.wait(0.4)
			if F.hauntedEquipBest and R.BestTowerTeam then pcall(function() R.BestTowerTeam:FireServer() end) end
			task.wait(0.4)
			
			local pickHaunted = "Haunted Front Yard"
			local choices = (F.hauntedList and #F.hauntedList > 0) and F.hauntedList or {"Haunted Front Yard"}
			pickHaunted = F.hauntedMix and choices[math.random(1, #choices)] or choices[1]

			STATE.hauntedLive = "Jalan: " .. tostring(pickHaunted); STATE.hauntedDrops = 0
			pcall(function()
				if R.PlayTower:IsA("RemoteFunction") then R.PlayTower:InvokeServer(pickHaunted)
				else R.PlayTower:FireServer(pickHaunted) end
			end)

			local done, fails = false, 0
			while F.hauntedTower and not done do
				local okP, seq = pcall(function() if R.CompleteFloor:IsA("RemoteFunction") then return R.CompleteFloor:InvokeServer() end end)
				if okP and type(seq) == "table" and #seq > 0 then
					fails = 0
					for _, act in ipairs(seq) do
						if act.action == "floorStarted" then STATE.hauntedFloor = tonumber(act.floor) or 1
						elseif act.action == "floorCompleted" then
							if act.rewards then for _, amt in pairs(act.rewards) do if type(amt) == "number" then STATE.hauntedDrops += amt end end end
						elseif act.action == "ended" then done = true; break end
					end
					if not done and F.hauntedExitOn and F.hauntedExitFloor > 0 and STATE.hauntedFloor >= F.hauntedExitFloor then
						done = true; drainTower()
					end
				else fails += 1; if fails > 8 then done = true end; task.wait(1) end
			end
			drainTower(); task.wait(1.5)
		else STATE.hauntedLive = "Standby"; task.wait(2) end
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
