-- ===================================================================== --
-- 👑 MOFENKHUB V114.0 — ULTIMATE AI DENGAN REAL-TIME SPY ERROR CATCHER
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

local LocalPlayer = Players.LocalPlayer

-- 1. AUTO RECONNECT & QUEUE ON TELEPORT
pcall(function()
	if queue_on_teleport then
		queue_on_teleport([[
			task.wait(3)
			loadstring(game:HttpGet("https://raw.githubusercontent.com/MofenkHub/AnimeDice/main/loader.lua"))()
		]])
	end
end)

task.spawn(function()
	pcall(function()
		LocalPlayer.OnTeleport:Connect(function(state)
			if state == Enum.TeleportState.Started then
				pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
			end
		end)
	end)
end)

local successGui, parentGui = pcall(function()
	if gethui then return gethui() elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end

pcall(function() for _, v in pairs(parentGui:GetChildren()) do if string.find(v.Name, "Mofenk") then v:Destroy() end end end)

-- ===================================================================== --
-- 2. ANIMASI LOADING & LOGO INTERAKTIF
-- ===================================================================== --
local LoadGui = Instance.new("ScreenGui"); LoadGui.Name = "MofenkLoadGui"; LoadGui.Parent = parentGui; LoadGui.ResetOnSpawn = false; LoadGui.DisplayOrder = 100000

local LoadCard = Instance.new("Frame"); LoadCard.Parent = LoadGui; LoadCard.AnchorPoint = Vector2.new(0.5, 0.5); LoadCard.Size = UDim2.new(0, 320, 0, 140); LoadCard.Position = UDim2.new(0.5, 0, 0.5, 0); LoadCard.BackgroundColor3 = Color3.fromRGB(11, 19, 36); LoadCard.BackgroundTransparency = 0.1
local LCC = Instance.new("UICorner"); LCC.CornerRadius = UDim.new(0, 12); LCC.Parent = LoadCard
local LCS = Instance.new("UIStroke"); LCS.Thickness = 1.5; LCS.Color = Color3.fromRGB(59, 130, 246); LCS.Parent = LoadCard

local LogoIcon = Instance.new("TextButton"); LogoIcon.Parent = LoadCard; LogoIcon.AnchorPoint = Vector2.new(0.5, 0); LogoIcon.Position = UDim2.new(0.5, 0, 0, 12); LogoIcon.Size = UDim2.new(0, 36, 0, 36); LogoIcon.BackgroundColor3 = Color3.fromRGB(59, 130, 246); LogoIcon.Text = "👑"; LogoIcon.TextSize = 18
local LIC = Instance.new("UICorner"); LIC.CornerRadius = UDim.new(1, 0); LIC.Parent = LogoIcon

task.spawn(function()
	while LoadGui and LoadGui.Parent do
		TweenService:Create(LogoIcon, TweenInfo.new(1, Enum.EasingStyle.Linear), {Rotation = LogoIcon.Rotation + 360}):Play()
		task.wait(1)
	end
end)

local LoadTitle = Instance.new("TextLabel"); LoadTitle.Parent = LoadCard; LoadTitle.Size = UDim2.new(1, 0, 0, 24); LoadTitle.Position = UDim2.new(0, 0, 0, 52); LoadTitle.Text = "MOFENK SPY & SMART PLANNER"; LoadTitle.TextColor3 = Color3.fromRGB(59, 130, 246); LoadTitle.TextSize = 10; LoadTitle.Font = Enum.Font.GothamBlack; LoadTitle.BackgroundTransparency = 1; LoadTitle.TextXAlignment = Enum.TextXAlignment.Center
local LoadStatus = Instance.new("TextLabel"); LoadStatus.Parent = LoadCard; LoadStatus.Size = UDim2.new(1, -24, 0, 20); LoadStatus.Position = UDim2.new(0, 12, 0, 78); LoadStatus.Text = "Memuat sistem Spy & Remote Wrapper..."; LoadStatus.TextColor3 = Color3.fromRGB(241, 245, 249); LoadStatus.TextSize = 9; LoadStatus.Font = Enum.Font.GothamMedium; LoadStatus.BackgroundTransparency = 1; LoadStatus.TextXAlignment = Enum.TextXAlignment.Center

local BarBg = Instance.new("Frame"); BarBg.Parent = LoadCard; BarBg.Size = UDim2.new(1, -24, 0, 6); BarBg.Position = UDim2.new(0, 12, 0, 108); BarBg.BackgroundColor3 = Color3.fromRGB(30, 41, 59); local BBC = Instance.new("UICorner"); BBC.CornerRadius = UDim.new(1, 0); BBC.Parent = BarBg
local BarFill = Instance.new("Frame"); BarFill.Parent = BarBg; BarFill.Size = UDim2.new(0, 0, 1, 0); BarFill.BackgroundColor3 = Color3.fromRGB(59, 130, 246); local BFC = Instance.new("UICorner"); BFC.CornerRadius = UDim.new(1, 0); BFC.Parent = BarFill

local function SetProgress(progress, text)
	LoadStatus.Text = text
	TweenService:Create(BarFill, TweenInfo.new(0.2), {Size = UDim2.new(progress, 0, 1, 0)}):Play()
end

-- ===================================================================== --
-- 3. CONFIGURATION & STATE MANAGER
-- ===================================================================== --
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

local F = {
	cfgName = "MofenkUltimateConfigV6", autoLoadEnabled = false,
	aiPlannerMaster = true,
	
	targetMutation = "Sovereign",
	targetMinLuckyPct = 75,
	gemReserveLimit = 150,
	
	autoRoll = true, buyDice = true, equipDice = true, collect = true,
	autoSwapBase = true, 
	autoLockRarity = true, keepRarities = {"Mythic", "Secret", "Divine", "Godly", "Sovereign"},
	autoFuseStrict = true,
	autoTower = true, towerTargetFloor = 50,
	
	afk = true, fpsOn = false
}

local MONITOR = {
	totalRolled = 0,
	totalFused = 0,
	unitsAchievedSovereign = 0,
	towerFloorsCleared = 0,
	initialMoney = 0,
	totalMoneyEarnedRealtime = 0,
	currentAiDecision = "Memindai Alur Game & Target...",
	consoleLogs = {}
}

local function PushLog(msg)
	local timestamp = os.date("%H:%M:%S")
	local formatted = "[" .. timestamp .. "] " .. msg
	table.insert(MONITOR.consoleLogs, 1, formatted)
	if #MONITOR.consoleLogs > 18 then table.remove(MONITOR.consoleLogs, #MONITOR.consoleLogs) end
	MONITOR.lastActionLog = msg
end

local GLASS_THEME = {
	Bg     = Color3.fromRGB(11, 19, 36),
	Card   = Color3.fromRGB(20, 32, 58),
	Header = Color3.fromRGB(15, 23, 42),
	Acc1   = Color3.fromRGB(59, 130, 246),
	Acc2   = Color3.fromRGB(37, 99, 235),
	Text   = Color3.fromRGB(241, 245, 249),
	SubText= Color3.fromRGB(148, 163, 184)
}

local CFG_FOLDER = "MofenkHub_Configs"
if makefolder and not isfolder(CFG_FOLDER) then pcall(function() makefolder(CFG_FOLDER) end) end

local function getCfgPath(name) return CFG_FOLDER .. "/" .. (name or F.cfgName or "DefaultConfig") .. ".json" end

local function saveConfig(name)
	if writefile then
		pcall(function() 
			writefile(getCfgPath(name), HttpService:JSONEncode(F)) 
			local pointerPath = CFG_FOLDER .. "/autoload_pointer.txt"
			if F.autoLoadEnabled then writefile(pointerPath, name or F.cfgName or "DefaultConfig")
			else if isfile and isfile(pointerPath) then delfile(pointerPath) end end
		end)
	end
end

local function loadConfig(name)
	local path = getCfgPath(name)
	if readfile and isfile and isfile(path) then
		pcall(function() 
			local d = HttpService:JSONDecode(readfile(path))
			for k,v in pairs(d) do F[k]=v end 
		end)
	end
end

local function FormatMoney(val)
	val = tonumber(val) or 0
	if val >= 1e15 then return string.format("%.2fQa", val/1e15)
	elseif val >= 1e12 then return string.format("%.2fT", val/1e12)
	elseif val >= 1e9 then return string.format("%.2fB", val/1e9)
	elseif val >= 1e6 then return string.format("%.2fM", val/1e6)
	elseif val >= 1e3 then return string.format("%.2fK", val/1e3)
	else return tostring(math.floor(val)) end
end

-- ===================================================================== --
-- 4. SAFE NETWORK WRAPPER & SPY ERROR CATCHER
-- ===================================================================== --
SetProgress(0.4, "Memindai jalur remote & mengaktifkan Spy...")
task.wait(0.3)

local Network = ReplicatedStorage:WaitForChild("Network", 15)
local Framework = ReplicatedStorage:WaitForChild("Framework", 15)

local function safeSvc(parent, path)
	local current = parent
	for segment in string.gmatch(path, "[^%.]+") do
		if current then current = current:FindFirstChild(segment) else return nil end
	end
	return current
end

-- Fungsi Spy Wrapper untuk Melacak Remote yang Error / Nil
local function spyInvoke(remoteObj, remoteName, ...)
	if not remoteObj then
		PushLog("[SPY ERROR] Remote '" .. remoteName .. "' bernilai nil/tidak ditemukan!")
		return false, "Nil Remote"
	end
	local success, res = pcall(function(...)
		if remoteObj:IsA("RemoteFunction") then
			return remoteObj:InvokeServer(...)
		elseif remoteObj:IsA("RemoteEvent") then
			remoteObj:FireServer(...)
			return true
		end
	end, ...)
	
	if not success then
		PushLog("[SPY FAILED] " .. remoteName .. " -> " .. tostring(res))
	end
	return success, res
end

local R = {
	RollDice        = safeSvc(Network, "RollService.RF.RollDice"),
	CollectBalance  = safeSvc(Network, "PlotService.RE.CollectBalance"), 
	BuyDice         = safeSvc(Network, "DiceShopService.RE.BuyDice"), 
	EquipDice       = safeSvc(Network, "DiceShopService.RE.EquipDice"),
	Rebirth         = safeSvc(Network, "RebirthService.RE.Rebirth"), 
	LockUnit        = safeSvc(Network, "UnitService.RE.SetLock"),
	EquipUnit       = safeSvc(Network, "UnitService.RF.Equip"),
	FuseUnits       = safeSvc(Network, "UnitService.RF.Fuse") or safeSvc(Network, "InventoryService.RF.Fuse"),
	PlayTower       = safeSvc(Network, "Towers.RF.PlayTower") or safeSvc(Network, "TowerService.RF.PlayTower"), 
	CompleteFloor   = safeSvc(Network, "Towers.RF.CompleteTowerFloor") or safeSvc(Network, "TowerService.RF.CompleteTowerFloor"),
	MutationRoll    = safeSvc(Network, "MutationService.RE.Roll") or safeSvc(Network, "QuirkService.RE.Roll"),
	BoostUse        = safeSvc(Network, "BoostService.RE.Use")
}

SetProgress(0.8, "Memuat database controller...")
local G = {}
pcall(function()
	G.DC = require(Framework.Features.Data.DataController)
	G.PlotConfig = require(Framework.Features.Plot.PlotConfig)
	G.Rebirths = require(Framework.Features.Rebirth.Rebirths)
	G.EntryRegistry = require(Framework.Features.Inventory.EntryRegistry)
	G.BuffController = require(Framework.Features.Buffs.BuffController)
end)

task.wait(0.4)
local function data() return G.DC and G.DC.___X or {} end
local function money() pcall(function() return G.DC.Money() end); return data().Money or 0 end

MONITOR.initialMoney = money()

SetProgress(1.0, "Sistem Siap dengan Spy Logger!")
task.wait(0.4)

TweenService:Create(LoadCard, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
task.delay(0.3, function() LoadGui:Destroy() end)

local function rebirthAmt() pcall(function() return G.DC.Rebirth() end); return data().Rebirth or 0 end
local function inventory() return data().Inventory or {} end
local function isUnitEntry(e) return e and type(e)=="table" and e.name and G.EntryRegistry and pcall(function() return G.EntryRegistry.getEntryConfig(e.name).kind == "Unit" end) end
local function currencyAmount(name) local t = 0; for _, e in pairs(inventory()) do if type(e)=="table" and e.name==name then t += tonumber(e.amount) or 0 end end; return t end

-- ===================================================================== --
-- 5. MOBILE AUTO-SCALE UI & INTERACTIVE LOGO TOGGLE
-- ===================================================================== --
local ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "MofenkToggleFront"; ToggleGui.Parent = parentGui; ToggleGui.ResetOnSpawn = false; ToggleGui.DisplayOrder = 99999

local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = ToggleGui; ToggleBtn.Size = UDim2.new(0, 42, 0, 42); ToggleBtn.Position = UDim2.new(0.015, 0, 0.32, 0)
ToggleBtn.BackgroundColor3 = GLASS_THEME.Card; ToggleBtn.Text = "👑"; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 16; ToggleBtn.ZIndex = 99999
local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 10); TC.Parent = ToggleBtn
local TS = Instance.new("UIStroke"); TS.Thickness = 1.5; TS.Color = GLASS_THEME.Acc1; TS.Parent = ToggleBtn

task.spawn(function()
	while ToggleBtn and ToggleBtn.Parent do
		TweenService:Create(ToggleBtn, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {Size = UDim2.new(0, 46, 0, 46)}):Play()
		task.wait(0.8)
		TweenService:Create(ToggleBtn, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {Size = UDim2.new(0, 42, 0, 42)}):Play()
		task.wait(0.8)
	end
end)

local NotifyGui = Instance.new("ScreenGui"); NotifyGui.Name = "MofenkNotifyGui"; NotifyGui.Parent = parentGui; NotifyGui.ResetOnSpawn = false
local NotifyHolder = Instance.new("Frame"); NotifyHolder.Parent = NotifyGui; NotifyHolder.Position = UDim2.new(1, -260, 0, 8); NotifyHolder.Size = UDim2.new(0, 240, 1, -16); NotifyHolder.BackgroundTransparency = 1
local NotifyLayout = Instance.new("UIListLayout"); NotifyLayout.Parent = NotifyHolder; NotifyLayout.Padding = UDim.new(0, 5); NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local function Notify(title, msg, duration)
	duration = duration or 2.5
	local Card = Instance.new("Frame"); Card.Parent = NotifyHolder; Card.Size = UDim2.new(1, 0, 0, 46); Card.BackgroundColor3 = GLASS_THEME.Card; Card.BackgroundTransparency = 0.15
	local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 6); CC.Parent = Card
	local CS = Instance.new("UIStroke"); CS.Thickness = 1; CS.Color = GLASS_THEME.Acc1; CS.Parent = Card
	
	local T = Instance.new("TextLabel"); T.Parent = Card; T.Position = UDim2.new(0, 8, 0, 3); T.Size = UDim2.new(1, -16, 0, 16); T.Text = title; T.TextColor3 = GLASS_THEME.Acc1; T.Font = Enum.Font.GothamBold; T.TextSize = 11; T.TextXAlignment = Enum.TextXAlignment.Left; T.BackgroundTransparency = 1
	local M = Instance.new("TextLabel"); M.Parent = Card; M.Position = UDim2.new(0, 8, 0, 19); M.Size = UDim2.new(1, -16, 0, 22); M.Text = msg; M.TextColor3 = GLASS_THEME.Text; M.Font = Enum.Font.GothamMedium; M.TextSize = 9; M.TextXAlignment = Enum.TextXAlignment.Left; M.TextWrapped = true; M.BackgroundTransparency = 1
	
	Card.Position = UDim2.new(1, 30, 0, 0)
	TweenService:Create(Card, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
	task.delay(duration, function()
		if Card and Card.Parent then
			local tw = TweenService:Create(Card, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1, Position = UDim2.new(1, 30, 0, 0)})
			tw:Play()
			tw.Completed:Connect(function() Card:Destroy() end)
		end
	end)
end

local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkUltimateHubV6"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.Size = UDim2.new(0, 440, 0, 290); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.BackgroundColor3 = GLASS_THEME.Bg; MainFrame.BackgroundTransparency = 0.1
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 10); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 1.2; MainStroke.Color = GLASS_THEME.Acc1; MainStroke.Parent = MainFrame

local UISize = Instance.new("UISizeConstraint"); UISize.Parent = MainFrame; UISize.MinSize = Vector2.new(360, 240); UISize.MaxSize = Vector2.new(800, 520)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 32); TopBar.BackgroundColor3 = GLASS_THEME.Header; TopBar.BackgroundTransparency = 0.2
local TopCorner = Instance.new("UICorner"); TopCorner.CornerRadius = UDim.new(0, 10); TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 10, 0, 0); Title.Size = UDim2.new(0, 180, 1, 0); Title.Text = "👑 MOFENK AI SPY"; Title.TextColor3 = GLASS_THEME.Acc1; Title.TextSize = 10; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1

local StatusBar = Instance.new("TextLabel"); StatusBar.Parent = TopBar; StatusBar.Position = UDim2.new(0, 195, 0, 5); StatusBar.Size = UDim2.new(1, -235, 0, 22); StatusBar.BackgroundColor3 = GLASS_THEME.Card; StatusBar.BackgroundTransparency = 0.4; StatusBar.TextColor3 = GLASS_THEME.SubText; StatusBar.TextSize = 8.5; StatusBar.Font = Enum.Font.GothamMedium; StatusBar.Text = "⚡ Status: Spy & Wrapper Aktif"
local SBC = Instance.new("UICorner"); SBC.CornerRadius = UDim.new(0, 5); SBC.Parent = StatusBar

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -30, 0, 5); CloseBtn.Size = UDim2.new(0, 22, 0, 22); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = GLASS_THEME.Text; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 11; CloseBtn.BackgroundColor3 = GLASS_THEME.Card; CloseBtn.BackgroundTransparency = 0.3
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 5); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = MainFrame; Sidebar.Position = UDim2.new(0, 6, 0, 38); Sidebar.Size = UDim2.new(0, 115, 1, -44); Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 2; Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y; Sidebar.CanvasSize = UDim2.new(0,0,0,0)
local SideLayout = Instance.new("UIListLayout"); Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y; SideLayout.Parent = Sidebar; SideLayout.Padding = UDim.new(0, 3)

local ContentArea = Instance.new("Frame"); ContentArea.Parent = MainFrame; ContentArea.Position = UDim2.new(0, 126, 0, 38); ContentArea.Size = UDim2.new(1, -132, 1, -44); ContentArea.BackgroundColor3 = GLASS_THEME.Header; ContentArea.BackgroundTransparency = 0.3
local ContentCorner = Instance.new("UICorner"); ContentCorner.CornerRadius = UDim.new(0, 8); ContentCorner.Parent = ContentArea

local TabFrames, TabButtons = {}, {}
local function CreateTab(name, icon)
	local Btn = Instance.new("TextButton"); Btn.Parent = Sidebar; Btn.Size = UDim2.new(1, -2, 0, 30); Btn.Text = " " .. icon .. " " .. name; Btn.TextColor3 = GLASS_THEME.SubText; Btn.TextSize = 9.5; Btn.Font = Enum.Font.GothamBold; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.BackgroundColor3 = GLASS_THEME.Card; Btn.BackgroundTransparency = 0.4
	local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 5); Corner.Parent = Btn
	
	local Scroll = Instance.new("ScrollingFrame"); Scroll.Parent = ContentArea; Scroll.Size = UDim2.new(1, -8, 1, -8); Scroll.Position = UDim2.new(0, 4, 0, 4); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2; Scroll.Visible = false; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.CanvasSize = UDim2.new(0,0,0,0)
	local Lay = Instance.new("UIListLayout"); Lay.Parent = Scroll; Scroll.ScrollingDirection = Enum.ScrollingDirection.Y; Lay.Padding = UDim.new(0, 6)
	TabFrames[name] = Scroll; TabButtons[name] = Btn
	
	Btn.MouseButton1Click:Connect(function()
		for n, f in pairs(TabFrames) do f.Visible = (n == name) end
		for _, b in pairs(TabButtons) do b.BackgroundTransparency = 0.4; b.TextColor3 = GLASS_THEME.SubText; b.BackgroundColor3 = GLASS_THEME.Card end
		Btn.BackgroundTransparency = 0.1; Btn.TextColor3 = GLASS_THEME.Acc1; Btn.BackgroundColor3 = GLASS_THEME.Card
	end)
	return Scroll
end

local function AddGroup(parent, title)
	local GroupCard = Instance.new("Frame"); GroupCard.Parent = parent; GroupCard.Size = UDim2.new(1, 0, 0, 0); GroupCard.AutomaticSize = Enum.AutomaticSize.Y; GroupCard.BackgroundColor3 = GLASS_THEME.Card; GroupCard.BackgroundTransparency = 0.25
	local GC = Instance.new("UICorner"); GC.CornerRadius = UDim.new(0, 6); GC.Parent = GroupCard
	local GS = Instance.new("UIStroke"); GS.Thickness = 1; GS.Color = GLASS_THEME.Acc1; GS.Transparency = 0.7; GS.Parent = GroupCard
	local GLayout = Instance.new("UIListLayout"); GLayout.Parent = GroupCard; GLayout.Padding = UDim.new(0, 5); GLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local GPadding = Instance.new("UIPadding"); GPadding.Parent = GroupCard; GPadding.PaddingTop = UDim.new(0, 6); GPadding.PaddingBottom = UDim.new(0, 6); GPadding.PaddingLeft = UDim.new(0, 6); GPadding.PaddingRight = UDim.new(0, 6)
	
	if title and title ~= "" then
		local HeaderLbl = Instance.new("TextLabel"); HeaderLbl.Parent = GroupCard; HeaderLbl.Size = UDim2.new(1, 0, 0, 18); HeaderLbl.Text = title; HeaderLbl.TextColor3 = GLASS_THEME.Acc1; HeaderLbl.TextSize = 10; HeaderLbl.Font = Enum.Font.GothamBlack; HeaderLbl.TextXAlignment = Enum.TextXAlignment.Left; HeaderLbl.BackgroundTransparency = 1
	end
	return GroupCard
end

local function AddToggle(parent, text, flag, callback)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 28); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 2, 0, 0); L.Size = UDim2.new(0.68, 0, 1, 0); L.Text = text; L.TextColor3 = GLASS_THEME.Text; L.TextSize = 9.5; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Sw = Instance.new("TextButton"); Sw.Parent = Frm; Sw.Position = UDim2.new(1, -36, 0.5, -9); Sw.Size = UDim2.new(0, 32, 0, 18); Sw.Text = ""; local SwC = Instance.new("UICorner"); SwC.CornerRadius = UDim.new(1, 0); SwC.Parent = Sw
	local Knob = Instance.new("Frame"); Knob.Parent = Sw; Knob.Size = UDim2.new(0, 14, 0, 14); Knob.BackgroundColor3 = GLASS_THEME.Text; local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1, 0); KC.Parent = Knob
	
	local function updateVisuals()
		Sw.BackgroundColor3 = F[flag] and GLASS_THEME.Acc1 or Color3.fromRGB(30, 41, 59)
		TweenService:Create(Knob, TweenInfo.new(0.2), {Position = F[flag] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
	end

	Sw.MouseButton1Click:Connect(function()
		F[flag] = not F[flag]
		updateVisuals()
		Notify("AI Planner", text, 1)
		if callback then pcall(callback, F[flag]) end
	end)
	updateVisuals()
end

-- ===================================================================== --
-- 6. TABS ASSEMBLY
-- ===================================================================== --
local T_Dash    = CreateTab("Dashboard", "📊")
local T_Console = CreateTab("AI Console", "🖥️")
local T_AI      = CreateTab("Targets", "🎯")
local T_Set     = CreateTab("Settings", "⚙️")

TabFrames["Dashboard"].Visible = true; Sidebar:GetChildren()[2].BackgroundTransparency = 0.1; Sidebar:GetChildren()[2].TextColor3 = GLASS_THEME.Acc1

local G_Prof = AddGroup(T_Dash, "STATUS & MONEY TRACKER")
local PLbl = Instance.new("TextLabel"); PLbl.Parent = G_Prof; PLbl.Size = UDim2.new(1, 0, 0, 68); PLbl.BackgroundTransparency = 1; PLbl.TextColor3 = GLASS_THEME.Text; PLbl.TextSize = 9.5; PLbl.Font = Enum.Font.GothamMedium; PLbl.TextXAlignment = Enum.TextXAlignment.Left; PLbl.TextYAlignment = Enum.TextYAlignment.Top

local G_Monitor = AddGroup(T_Dash, "📊 REAL-TIME MONITOR")
local MLbl = Instance.new("TextLabel"); MLbl.Parent = G_Monitor; MLbl.Size = UDim2.new(1, 0, 0, 68); MLbl.BackgroundTransparency = 1; MLbl.TextColor3 = GLASS_THEME.Text; MLbl.TextSize = 9.5; MLbl.Font = Enum.Font.GothamMedium; MLbl.TextXAlignment = Enum.TextXAlignment.Left; MLbl.TextYAlignment = Enum.TextYAlignment.Top

local G_ConsGroup = AddGroup(T_Console, "🖥️ LIVE SPY & EXECUTION CONSOLE")
local ConsoleBox = Instance.new("TextLabel"); ConsoleBox.Parent = G_ConsGroup; ConsoleBox.Size = UDim2.new(1, 0, 0, 180); ConsoleBox.BackgroundColor3 = Color3.fromRGB(8, 14, 26); ConsoleBox.TextColor3 = Color3.fromRGB(59, 130, 246); ConsoleBox.TextSize = 8.5; ConsoleBox.Font = Enum.Font.Code; ConsoleBox.TextXAlignment = Enum.TextXAlignment.Left; ConsoleBox.TextYAlignment = Enum.TextYAlignment.Top; ConsoleBox.TextWrapped = true
local CBCorner = Instance.new("UICorner"); CBCorner.CornerRadius = UDim.new(0, 5); CBCorner.Parent = ConsoleBox

task.spawn(function()
	while task.wait(0.8) do pcall(function()
		local m = money(); local rb = rebirthAmt()
		local currentEarned = m - MONITOR.initialMoney
		MONITOR.totalMoneyEarnedRealtime = currentEarned > 0 and currentEarned or 0
		
		PLbl.Text = string.format("👤 %s\n💰 Uang: %s (+%s Real-Time)\n🔄 Rebirth: %s | AI: %s", 
			LocalPlayer.Name, FormatMoney(m), FormatMoney(MONITOR.totalMoneyEarnedRealtime), tostring(rb), MONITOR.currentAiDecision)
		
		MLbl.Text = string.format("🎲 Roll: %d | 🧬 Fuse: %d\n👑 Sovereign: %d | 🏢 Tower: %d\n⚡ Log: %s", 
			MONITOR.totalRolled, MONITOR.totalFused, MONITOR.unitsAchievedSovereign, MONITOR.towerFloorsCleared, MONITOR.lastActionLog)
		
		ConsoleBox.Text = table.concat(MONITOR.consoleLogs, "\n")
		StatusBar.Text = "🧠 AI Engine: " .. MONITOR.currentAiDecision
	end) end
end)

local G_AIConfig = AddGroup(T_AI, "TARGET & PENGAMAN AI")
AddToggle(G_AIConfig, "Aktifkan AI Master Smart Planner", "aiPlannerMaster", function(v)
	if v then PushLog("AI Master diaktifkan.") end
end)
AddToggle(G_AIConfig, "Auto Swap Base (Unit Lucky Tertinggi)", "autoSwapBase")
AddToggle(G_AIConfig, "Auto Fuse Strict (3 ke 1 Kembar)", "autoFuseStrict")
AddToggle(G_AIConfig, "Auto Tower (Lantai Tertinggi)", "autoTower")

local G_Set = AddGroup(T_Set, "PENGATURAN CONFIG")
AddToggle(G_Set, "Auto Load Config", "autoLoadEnabled")

local BtnSave = Instance.new("TextButton"); BtnSave.Parent = G_Set; BtnSave.Size = UDim2.new(1, 0, 0, 26); BtnSave.Text = "💾 SAVE CONFIG"; BtnSave.Font = Enum.Font.GothamBold; BtnSave.TextSize = 9.5; BtnSave.TextColor3 = GLASS_THEME.Acc1; BtnSave.BackgroundColor3 = GLASS_THEME.Header; local BTS = Instance.new("UICorner"); BTS.CornerRadius = UDim.new(0,5); BTS.Parent = BtnSave
BtnSave.MouseButton1Click:Connect(function() pcall(function() saveConfig(F.cfgName); PushLog("Config disimpan."); Notify("Saved", "Berhasil.") end) end)

-- ===================================================================== --
-- 7. ULTIMATE AI SMART DECISION ENGINE DENGAN SPY CATCHER
-- ===================================================================== --

PushLog("Sistem AI & Spy Logger aktif.")

-- AI Pathfinding Loop dengan Spy Invoke
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.aiPlannerMaster then
			pcall(function()
				local gems = currencyAmount("Gems")
				
				if gems < F.gemReserveForSovereign then
					MONITOR.currentAiDecision = "Gems Menipis -> Beralih ke Tower."
					PushLog("Gems kurang (" .. gems .. "). Fokus Tower.")
					
					if F.autoTower and R.PlayTower then
						spyInvoke(R.PlayTower, "PlayTower", F.towerTargetFloor)
						task.wait(2)
						if R.CompleteFloor then
							spyInvoke(R.CompleteFloor, "CompleteFloor", F.towerTargetFloor)
						end
						MONITOR.towerFloorsCleared += 1
						PushLog("Tower Lantai " .. F.towerTargetFloor .. " diproses.")
					end
				else
					MONITOR.currentAiDecision = "Berburu Sovereign & Base Optimal."
					
					for id, u in pairs(inventory()) do
						if isUnitEntry(u) then
							for _, r in ipairs(F.keepRarities) do
								if string.lower(tostring(u.rarity)) == string.lower(r) and R.LockUnit then
									spyInvoke(R.LockUnit, "SetLock", id, true)
								end
							end
							
							if u.attributes then
								local mut = u.attributes.mutation or u.attributes.quirk or ""
								local lck = tonumber(u.attributes.lucky or u.attributes.luck) or 0
								if string.lower(tostring(mut)) == string.lower(F.targetMutation) and lck >= F.targetMinLuckyPct then
									MONITOR.unitsAchievedSovereign += 1
									PushLog("👑 Sovereign Didapat! Lucky: " .. lck .. "%")
									Notify("👑 Sovereign!", "Lucky " .. lck .. "%!", 5)
									if R.EquipUnit then spyInvoke(R.EquipUnit, "EquipUnit", id) end
								end
							end
						end
					end
					
					if F.autoSwapBase and R.EquipUnit then
						pcall(function()
							local bestId, bestScore = nil, -1
							for id, u in pairs(inventory()) do
								if isUnitEntry(u) and u.attributes then
									local score = (tonumber(u.attributes.lucky) or 0) + (tonumber(u.attributes.level) or 1) * 10
									if score > bestScore then bestScore = score; bestId = id end
								end
							end
							if bestId then spyInvoke(R.EquipUnit, "EquipUnit", bestId) end
						end)
					end
					
					if F.autoFuseStrict and R.FuseUnits then
						pcall(function()
							local groups = {}
							for id, u in pairs(inventory()) do
								if isUnitEntry(u) and not u.locked then
									local key = tostring(u.name) .. "_" .. tostring(u.rarity)
									groups[key] = groups[key] or {}
									table.insert(groups[key], id)
								end
							end
							for _, list in pairs(groups) do
								if #list >= 3 then
									spyInvoke(R.FuseUnits, "FuseUnits", {list[1], list[2], list[3]})
									MONITOR.totalFused += 1
									PushLog("Auto-Fuse 3>1 diproses.")
									task.wait(1)
								end
							end
						end)
					end
				end
			end)
		else
			MONITOR.currentAiDecision = "AI Dimatikan (Manual)."
		end
		task.wait(6)
	end
end)

-- Standard Automation Loop dengan Spy Invoke
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.autoRoll or F.aiPlannerMaster then
			pcall(function()
				if R.RollDice then 
					spyInvoke(R.RollDice, "RollDice") 
					MONITOR.totalRolled += 1
				end 
			end)
		end
		if F.collect or F.aiPlannerMaster then
			pcall(function()
				for _, slot in ipairs({1,2,3,4,5}) do
					if R.CollectBalance then spyInvoke(R.CollectBalance, "CollectBalance", slot) end
				end
			end)
		end
		task.wait(2.2 + math.random() * 0.6)
	end
end)

Notify("Ultimate AI V114 Siap!", "Spy Error Catcher & Auto-Scale Aktif.", 3)
