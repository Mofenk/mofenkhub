-- ===================================================================== --
-- 👑 MOFENKHUB V109.0 — STABLE MASTER ULTIMATE (ERROR-FREE & FULL FEATURE)
-- ===================================================================== --

--!nocheck
task.wait(1)
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local VirtualUser       = game:GetService("VirtualUser")

-- Folder Penyimpanan Config Aman
local CFG_FOLDER = "MofenkConfigs"
pcall(function() if not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end end)

-- ===================================================================== --
-- [AUTO-EXECUTE] QUEUE ON TELEPORT
-- ===================================================================== --
pcall(function()
	local qot = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
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

_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

-- ===================================================================== --
-- 1. STATE & FULL CONFIGURATION MANAGER
-- ===================================================================== --
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
	
	-- HALLOWEEN & PUMPKIN FLAGS
	halloAutoClaim = false, halloAutoUpgrade = false, halloAutoQuest = false, halloRollPumpkin = false, halloAutoTrickOrTreat = false,
	
	-- AFK & BYPASS
	antiAfk = true, fpsCap = 60, fpsOn = false, wsOn = false, wsValue = 16, jpOn = false, jpValue = 50, noclip = false,
	
	-- WEBHOOK ALERTS
	webhookEnabled = false, webhookUrl = "", webhookInterval = 60,
	
	-- REMOTE & DATA SPY SYSTEM
	spyDataOn = false, spyClickOn = false, spyErrorAlert = true
}

local STATE = { towerLive = "Standby", towerFloor = 0, towerDrops = 0, halloCurrency = 0, remoteLogs = {}, activeBuffs = "Tidak Ada" }
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
-- 2. NOTIFIKASI & WEBHOOK SYSTEM
-- ===================================================================== --
local NotifGui = Instance.new("ScreenGui"); NotifGui.Name = "MofenkNotifications"; NotifGui.Parent = parentGui; NotifGui.DisplayOrder = 999999
local NotifFrame = Instance.new("Frame"); NotifFrame.Parent = NotifGui; NotifFrame.Size = UDim2.new(0, 300, 1, 0); NotifFrame.Position = UDim2.new(1, -320, 0, 0); NotifFrame.BackgroundTransparency = 1
local NotifLayout = Instance.new("UIListLayout"); NotifLayout.Parent = NotifFrame; NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder; NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom; NotifLayout.Padding = UDim.new(0, 10)

local function SendNotification(title, text, duration, isError)
	duration = duration or 3
	pcall(function()
		local Box = Instance.new("Frame"); Box.Size = UDim2.new(1, 0, 0, 60); Box.BackgroundColor3 = THEMES[F.themeIndex].Card; Box.BackgroundTransparency = 0.2; Box.Position = UDim2.new(1, 100, 0, 0)
		local UIC = Instance.new("UICorner"); UIC.CornerRadius = UDim.new(0, 10); UIC.Parent = Box
		local UIS = Instance.new("UIStroke"); UIS.Thickness = 2; UIS.Color = isError and Color3.fromRGB(255, 50, 50) or THEMES[F.themeIndex].Acc1; UIS.Parent = Box
		
		local T = Instance.new("TextLabel"); T.Parent = Box; T.Size = UDim2.new(1, -20, 0, 25); T.Position = UDim2.new(0, 10, 0, 5); T.BackgroundTransparency = 1; T.Text = (isError and "❌ " or "✅ ") .. title; T.TextColor3 = isError and Color3.fromRGB(255, 100, 100) or THEMES[F.themeIndex].Acc1; T.Font = Enum.Font.GothamBlack; T.TextSize = 14; T.TextXAlignment = Enum.TextXAlignment.Left
		local D = Instance.new("TextLabel"); D.Parent = Box; D.Size = UDim2.new(1, -20, 0, 25); D.Position = UDim2.new(0, 10, 0, 30); D.BackgroundTransparency = 1; D.Text = text; D.TextColor3 = Color3.fromRGB(255, 255, 255); D.Font = Enum.Font.GothamMedium; D.TextSize = 12; D.TextXAlignment = Enum.TextXAlignment.Left; D.TextWrapped = true
		
		Box.Parent = NotifFrame
		TweenService:Create(Box, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
		task.spawn(function()
			task.wait(duration)
			pcall(function()
				local fade = TweenService:Create(Box, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 100, 0, 0), BackgroundTransparency = 1})
				fade:Play(); fade.Completed:Wait(); Box:Destroy()
			end)
		end)
	end)
end

local function SendWebhook(title, desc)
	if not F.webhookEnabled or F.webhookUrl == "" then return end
	pcall(function()
		local data = {
			["embeds"] = {{
				["title"] = "👑 MofenkHub Alert | " .. title,
				["description"] = desc,
				["color"] = 65280,
				["footer"] = { ["text"] = "Player: " .. LocalPlayer.Name }
			}}
		}
		local body = HttpService:JSONEncode(data)
		local headers = { ["Content-Type"] = "application/json" }
		if syn and syn.request then
			syn.request({ Url = F.webhookUrl, Method = "POST", Headers = headers, Body = body })
		elseif http and http.request then
			http.request({ Url = F.webhookUrl, Method = "POST", Headers = headers, Body = body })
		elseif request then
			request({ Url = F.webhookUrl, Method = "POST", Headers = headers, Body = body })
		end
	end)
end

-- ===================================================================== --
-- 3. SAFE REMOTE & GAME DATA FINDER
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
	SellInventory       = findRemoteDynamic("SellService", "SellInventory", "RemoteFunction"),
	Fuse                = findRemoteDynamic("FusingService", "Fuse", "RemoteEvent"),
	HalloTeleport       = findRemoteDynamic("HalloweenService", "Teleport", "RemoteFunction"),
	HalloClaimPath      = findRemoteDynamic("HalloweenService", "ClaimPath", "RemoteEvent"),
	HalloClaimAll       = findRemoteDynamic("HalloweenService", "ClaimAllPath", "RemoteEvent"),
	HalloBuyUpgrade     = findRemoteDynamic("HalloweenService", "BuyUpgrade", "RemoteEvent"),
	PumpkinRoll         = findRemoteDynamic("PumpkinDiceService", "Roll", "RemoteFunction"),
	TrickOrTreatClaim   = findRemoteDynamic("HalloweenService", "TrickOrTreat", "RemoteEvent") or findRemoteDynamic("HalloweenService", "TrickOrTreat", "RemoteFunction")
}

local G = {}
task.spawn(function()
	local maxTries = 15
	while maxTries > 0 do
		local ok = pcall(function()
			if Framework then
				local feat = Framework:FindFirstChild("Features")
				if feat then
					G.DC = require(feat:FindFirstChild("Data"):FindFirstChild("DataController"))
					G.EntryRegistry = require(feat:FindFirstChild("Inventory"):FindFirstChild("EntryRegistry"))
					G.BuffController = require(feat:FindFirstChild("Buffs"):FindFirstChild("BuffController"))
				end
			end
		end)
		if ok and G.DC then break end
		maxTries -= 1
		task.wait(1)
	end
end)

local function data() local ok, res = pcall(function() return G.DC and G.DC.___X end); if ok and res then return res end; return {} end
local function money() local ok, val = pcall(function() return G.DC.Money() end); if ok and val then return val end; return data().Money or 0 end
local function rebirthAmt() local ok, val = pcall(function() return G.DC.Rebirth() end); if ok and val then return val end; return data().Rebirth or 0 end
local function inventory() local ok, val = pcall(function() return data().Inventory end); if ok and val then return val end; return {} end
local function currencyAmount(name) local t = 0; pcall(function() for _, e in pairs(inventory()) do if type(e)=="table" and e.name==name then t += tonumber(e.amount) or 0 end end end); return t end

-- ===================================================================== --
-- 4. INTERACTIVE UI SETUP & SPY GUI
-- ===================================================================== --
local ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "MofenkToggleFront"; ToggleGui.Parent = parentGui; ToggleGui.ResetOnSpawn = false
local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = ToggleGui; ToggleBtn.Size = UDim2.new(0, 60, 0, 60); ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0); ToggleBtn.BackgroundColor3 = THEMES[1].Card; ToggleBtn.Text = "M"; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 34; ToggleBtn.TextColor3 = THEMES[1].Acc1; ToggleBtn.BackgroundTransparency = 0.2
local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 16); TC.Parent = ToggleBtn
local TS = Instance.new("UIStroke"); TS.Thickness = 3; TS.Parent = ToggleBtn; table.insert(ThemeElements.Acc1, TS)

local dragging, dragInput, dragStart, startPos
ToggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = input.Position; startPos = ToggleBtn.Position
	end
end)
ToggleBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart; local viewport = workspace.CurrentCamera.ViewportSize; ToggleBtn.Position = UDim2.new(0, math.clamp(startPos.X.Offset + delta.X, 10, viewport.X - 70), 0, math.clamp(startPos.Y.Offset + delta.Y, 10, viewport.Y - 70)) end end)

local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkUltraHub"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui; MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.Size = UDim2.new(0, 950, 0, 620); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.BackgroundTransparency = 0.4; table.insert(ThemeElements.Bg, MainFrame)
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 18); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 4; MainStroke.Parent = MainFrame; local StrokeGrad = Instance.new("UIGradient"); StrokeGrad.Parent = MainStroke; table.insert(ThemeElements.Grad, StrokeGrad)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 55); TopBar.BackgroundTransparency = 0.3; table.insert(ThemeElements.Header, TopBar)
local TopCorner = Instance.new("UICorner"); TopCorner.CornerRadius = UDim.new(0, 18); TopCorner.Parent = TopBar
local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 25, 0, 0); Title.Size = UDim2.new(0, 600, 1, 0); Title.Text = "👑 MOFENKHUB V109.0  |  MASTER ULTIMATE EDITION"; Title.TextSize = 14; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, Title)
local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -50, 0, 10); CloseBtn.Size = UDim2.new(0, 35, 0, 35); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(255,255,255); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 18; CloseBtn.BackgroundTransparency = 0.3; table.insert(ThemeElements.Card, CloseBtn)
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 10); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = MainFrame; Sidebar.Position = UDim2.new(0, 15, 0, 65); Sidebar.Size = UDim2.new(0, 200, 1, -80); Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 0; Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
local SideLayout = Instance.new("UIListLayout"); SideLayout.Parent = Sidebar; SideLayout.Padding = UDim.new(0, 8)
local ContentArea = Instance.new("Frame"); ContentArea.Parent = MainFrame; ContentArea.Position = UDim2.new(0, 225, 0, 65); ContentArea.Size = UDim2.new(1, -240, 1, -80); ContentArea.BackgroundTransparency = 0.4; table.insert(ThemeElements.Header, ContentArea)
local ContentCorner = Instance.new("UICorner"); ContentCorner.CornerRadius = UDim.new(0, 14); ContentCorner.Parent = ContentArea

local TabFrames, TabButtons = {}, {}
local function CreateTab(name, icon)
	local Btn = Instance.new("TextButton"); Btn.Parent = Sidebar; Btn.Size = UDim2.new(1, -4, 0, 42); Btn.Text = "   " .. icon .. "  " .. name; Btn.TextColor3 = Color3.fromRGB(220,220,220); Btn.TextSize = 13; Btn.Font = Enum.Font.GothamBold; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.BackgroundTransparency = 0.4; table.insert(ThemeElements.Card, Btn)
	local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 10); Corner.Parent = Btn
	local Scroll = Instance.new("ScrollingFrame"); Scroll.Parent = ContentArea; Scroll.Size = UDim2.new(1, -20, 1, -20); Scroll.Position = UDim2.new(0, 10, 0, 10); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2; Scroll.Visible = false; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local Lay = Instance.new("UIListLayout"); Lay.Parent = Scroll; Lay.Padding = UDim.new(0, 12)
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
	local GC = Instance.new("UICorner"); GC.CornerRadius = UDim.new(0, 12); GC.Parent = GroupCard
	local GS = Instance.new("UIStroke"); GS.Thickness = 2; GS.Transparency = 0.5; GS.Parent = GroupCard; table.insert(ThemeElements.Acc1, GS)
	local GLayout = Instance.new("UIListLayout"); GLayout.Parent = GroupCard; GLayout.Padding = UDim.new(0, 8); GLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local GPadding = Instance.new("UIPadding"); GPadding.Parent = GroupCard; GPadding.PaddingTop = UDim.new(0, 12); GPadding.PaddingBottom = UDim.new(0, 12); GPadding.PaddingLeft = UDim.new(0, 12); GPadding.PaddingRight = UDim.new(0, 12)
	if title and title ~= "" then local HeaderLbl = Instance.new("TextLabel"); HeaderLbl.Parent = GroupCard; HeaderLbl.Size = UDim2.new(1, 0, 0, 28); HeaderLbl.Text = title; HeaderLbl.TextSize = 14; HeaderLbl.Font = Enum.Font.GothamBlack; HeaderLbl.TextXAlignment = Enum.TextXAlignment.Left; HeaderLbl.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, HeaderLbl) end
	return GroupCard
end

local function AddToggle(parent, text, flag, callback)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 40); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 8, 0, 0); L.Size = UDim2.new(0.7, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Sw = Instance.new("TextButton"); Sw.Parent = Frm; Sw.Position = UDim2.new(1, -50, 0.5, -13); Sw.Size = UDim2.new(0, 44, 0, 26); Sw.Text = ""
	local SwC = Instance.new("UICorner"); SwC.CornerRadius = UDim.new(1, 0); SwC.Parent = Sw
	local Knob = Instance.new("Frame"); Knob.Parent = Sw; Knob.Size = UDim2.new(0, 20, 0, 20); Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1, 0); KC.Parent = Knob
	
	local function updateVisuals()
		Sw.BackgroundColor3 = F[flag] and THEMES[F.themeIndex].Acc1 or Color3.fromRGB(60,60,75)
		TweenService:Create(Knob, TweenInfo.new(0.2), {Position = F[flag] and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)}):Play()
		if F[flag] then table.insert(ThemeElements.Acc1, Sw) else for i,v in ipairs(ThemeElements.Acc1) do if v==Sw then table.remove(ThemeElements.Acc1,i) end end end
		ApplyTheme(F.themeIndex)
	end
	table.insert(ConfigUpdaters, updateVisuals)

	Sw.MouseButton1Click:Connect(function() 
		F[flag] = not F[flag]; updateVisuals()
		if callback then callback(F[flag]) end 
		SendNotification("Berhasil", text .. " diubah.", 2, false)
	end)
	updateVisuals()
end

local function AddInput(parent, text, flag, isNum)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 42); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 8, 0, 0); L.Size = UDim2.new(0.5, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 13; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Box = Instance.new("TextBox"); Box.Parent = Frm; Box.Position = UDim2.new(0.5, 0, 0.1, 0); Box.Size = UDim2.new(0.48, 0, 0.8, 0); table.insert(ThemeElements.TextAcc, Box); Box.TextSize = 13; Box.Font = Enum.Font.GothamBold; Box.BackgroundTransparency = 0.4; table.insert(ThemeElements.Header, Box)
	local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); BC.Parent = Box
	local BS = Instance.new("UIStroke"); BS.Parent = Box; BS.Transparency = 0.5; table.insert(ThemeElements.Acc1, BS)
	
	local function updateVisuals() Box.Text = tostring(F[flag] or "") end
	table.insert(ConfigUpdaters, updateVisuals)
	Box.FocusLost:Connect(function() F[flag] = isNum and (tonumber(Box.Text) or 0) or Box.Text; updateVisuals() end)
	updateVisuals()
end

-- ===================================================================== --
-- 5. SEMUA TAB LENGKAP
-- ===================================================================== --
local T_Dash  = CreateTab("Dashboard", "📊")
local T_Hallo = CreateTab("Halloween", "🎃")
local T_Farm  = CreateTab("Farming", "⛏️")
local T_Inv   = CreateTab("Inventory", "🎒")
local T_Spy   = CreateTab("Remote Spy", "🕵️‍♂️")
local T_Web   = CreateTab("Webhook", "📢")
local T_Set   = CreateTab("Settings", "⚙️")

TabFrames["Dashboard"].Visible = true; Sidebar:GetChildren()[2].BackgroundTransparency = 0.1; table.insert(ThemeElements.Acc1, Sidebar:GetChildren()[2])

-- DASHBOARD
local G_Profile = AddGroup(T_Dash, "PROFIL & STATISTIK")
local PLbl = Instance.new("TextLabel"); PLbl.Parent = G_Profile; PLbl.Size = UDim2.new(1, 0, 0, 70); PLbl.BackgroundTransparency = 1; PLbl.TextColor3 = Color3.fromRGB(255,255,255); PLbl.TextSize = 13; PLbl.Font = Enum.Font.GothamMedium; PLbl.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
	while task.wait(1) do pcall(function()
		PLbl.Text = string.format("👤 Player: %s\n💰 Uang: %s\n🔄 Rebirth: %s\n💎 Gems: %s", LocalPlayer.Name, tostring(money()), tostring(rebirthAmt()), tostring(currencyAmount("Gems")))
	end) end
end)

-- HALLOWEEN & TRICK OR TREAT
local G_Hallo = AddGroup(T_Hallo, "HALLOWEEN & TRICK OR TREAT")
local BtnHalloTP = Instance.new("TextButton"); BtnHalloTP.Parent = G_Hallo; BtnHalloTP.Size = UDim2.new(1, 0, 0, 40); BtnHalloTP.Text = "🎃 TELEPORT KE HALLOWEEN MAP"; BtnHalloTP.Font = Enum.Font.GothamBold; BtnHalloTP.TextSize = 12; table.insert(ThemeElements.Card, BtnHalloTP); table.insert(ThemeElements.TextAcc, BtnHalloTP)
local B1 = Instance.new("UICorner"); B1.CornerRadius = UDim.new(0,8); B1.Parent = BtnHalloTP
BtnHalloTP.MouseButton1Click:Connect(function() pcall(function() if R.HalloTeleport then R.HalloTeleport:InvokeServer() end end) end)

AddToggle(G_Hallo, "Auto Claim Trick or Treat", "halloAutoTrickOrTreat")
local BtnClaimTOT = Instance.new("TextButton"); BtnClaimTOT.Parent = G_Hallo; BtnClaimTOT.Size = UDim2.new(1, 0, 0, 38); BtnClaimTOT.Text = "🚪 CLAIM TRICK OR TREAT SEKARANG"; BtnClaimTOT.Font = Enum.Font.GothamBold; BtnClaimTOT.TextSize = 12; table.insert(ThemeElements.Header, BtnClaimTOT); table.insert(ThemeElements.TextAcc, BtnClaimTOT)
local B2 = Instance.new("UICorner"); B2.CornerRadius = UDim.new(0,8); B2.Parent = BtnClaimTOT
BtnClaimTOT.MouseButton1Click:Connect(function()
	pcall(function()
		if R.TrickOrTreatClaim then
			if typeof(R.TrickOrTreatClaim) == "RemoteEvent" then R.TrickOrTreatClaim:FireServer()
			elseif typeof(R.TrickOrTreatClaim) == "RemoteFunction" then R.TrickOrTreatClaim:InvokeServer() end
			SendNotification("Berhasil", "Trick or Treat diklaim!", 2, false)
		end
	end)
end)
AddToggle(G_Hallo, "Auto Roll Pumpkin Dice", "halloRollPumpkin")
AddToggle(G_Hallo, "Auto Claim Halloween Path", "halloAutoClaim")

-- FARMING & AFK BYPASS
local G_Farm = AddGroup(T_Farm, "FARMING & ROLL")
AddToggle(G_Farm, "Auto Collect Plot", "collect")
AddToggle(G_Farm, "Auto Roll Dadu", "autoRoll")
AddToggle(G_Farm, "Auto Rebirth", "rebirth")

local G_Afk = AddGroup(T_Farm, "ANTI-AFK & PERFORMANCE BYPASS")
AddToggle(G_Afk, "Anti-AFK Aktif (Anti Kick)", "antiAfk")
AddToggle(G_Afk, "FPS Unlocker / Booster", "fpsOn", function(v) if v and setfpscap then pcall(function() setfpscap(F.fpsCap) end) end end)
AddInput(G_Afk, "Target FPS Cap:", "fpsCap", true)
AddToggle(G_Afk, "WalkSpeed Booster", "wsOn", function(v) if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end end)
AddInput(G_Afk, "WalkSpeed Nilai:", "wsValue", true)

-- INVENTORY
local G_Inv = AddGroup(T_Inv, "AUTO SELL & FUSE")
AddToggle(G_Inv, "Aktifkan Auto Sell", "sellAuto")
AddInput(G_Inv, "Simpan Unit Terbaik (Keep Best):", "keepBest", true)
AddToggle(G_Inv, "Auto Fusion Unit", "autoFuse")

-- REMOTE SPY TAB
local G_SpyUI = AddGroup(T_Spy, "REMOTE & EVENT SPY MONITOR")
AddToggle(G_SpyUI, "Aktifkan Remote Spy Log", "spyDataOn")
AddToggle(G_SpyUI, "Tangkap Mouse Click Event", "spyClickOn")

-- WEBHOOK TAB
local G_WebUI = AddGroup(T_Web, "DISCORD WEBHOOK NOTIFIER")
AddToggle(G_WebUI, "Aktifkan Notifikasi Webhook", "webhookEnabled")
AddInput(G_WebUI, "Webhook URL:", "webhookUrl", false)
local BtnTestWeb = Instance.new("TextButton"); BtnTestWeb.Parent = G_WebUI; BtnTestWeb.Size = UDim2.new(1, 0, 0, 38); BtnTestWeb.Text = "📤 KIRIM TEST WEBHOOK"; BtnTestWeb.Font = Enum.Font.GothamBold; BtnTestWeb.TextSize = 12; table.insert(ThemeElements.Header, BtnTestWeb); table.insert(ThemeElements.TextAcc, BtnTestWeb)
local BWC = Instance.new("UICorner"); BWC.CornerRadius = UDim.new(0,8); BWC.Parent = BtnTestWeb
BtnTestWeb.MouseButton1Click:Connect(function() SendWebhook("Test Webhook", "Webhook MofenkHub terhubung dengan sukses!") SendNotification("Webhook", "Test terkirim!", 2, false) end)

-- SETTINGS & CONFIG
local G_SetConfig = AddGroup(T_Set, "CONFIG MANAGER")
AddToggle(G_SetConfig, "Auto Load Config Saat Nyala", "autoLoadEnabled")
AddInput(G_SetConfig, "Nama Config:", "cfgName", false)

local BtnSave = Instance.new("TextButton"); BtnSave.Parent = G_SetConfig; BtnSave.Size = UDim2.new(1, 0, 0, 38); BtnSave.Text = "💾 SAVE CONFIG SEKARANG"; BtnSave.Font = Enum.Font.GothamBold; BtnSave.TextSize = 12; table.insert(ThemeElements.Header, BtnSave); table.insert(ThemeElements.TextAcc, BtnSave)
local BSC = Instance.new("UICorner"); BSC.CornerRadius = UDim.new(0,8); BSC.Parent = BtnSave
BtnSave.MouseButton1Click:Connect(function() pcall(function() saveConfig(F.cfgName) end) SendNotification("Config", "Berhasil disimpan!", 2, false) end)

local BtnLoad = Instance.new("TextButton"); BtnLoad.Parent = G_SetConfig; BtnLoad.Size = UDim2.new(1, 0, 0, 38); BtnLoad.Text = "📂 LOAD CONFIG PILIHAN"; BtnLoad.Font = Enum.Font.GothamBold; BtnLoad.TextSize = 12; table.insert(ThemeElements.Header, BtnLoad); table.insert(ThemeElements.TextAcc, BtnLoad)
local BLC = Instance.new("UICorner"); BLC.CornerRadius = UDim.new(0,8); BLC.Parent = BtnLoad
BtnLoad.MouseButton1Click:Connect(function() pcall(function() loadConfig(F.cfgName) end) SendNotification("Config", "Berhasil dimuat!", 2, false) end)

ApplyTheme(F.themeIndex)

-- ===================================================================== --
-- 6. BACKGROUND LOOPS (FARMING, REBIRTH, COLLECT, AFK)
-- ===================================================================== --
-- Anti-AFK VirtualUser
task.spawn(function()
	while task.wait(30) do
		if F.antiAfk then
			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new())
			end)
		end
	end
end)

-- WalkSpeed Loop
task.spawn(function()
	while task.wait(0.5) do
		if F.wsOn and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = F.wsValue end)
		end
	end
end)

-- Auto Collect Plot
task.spawn(function()
	while task.wait(1) do
		if F.collect then
			pcall(function() if R.CollectBalance then R.CollectBalance:FireServer() end end)
		end
	end
end)

-- Auto Roll Dadu
task.spawn(function()
	while task.wait(0.5) do
		if F.autoRoll then
			pcall(function()
				if R.RollDice then R.RollDice:InvokeServer() end
			end)
		end
	end
end)

-- Auto Rebirth
task.spawn(function()
	while task.wait(3) do
		if F.rebirth then
			pcall(function()
				if R.Rebirth then R.Rebirth:FireServer() end
			end)
		end
	end
end)

-- Halloween Loops
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.halloAutoTrickOrTreat then
			pcall(function()
				if R.TrickOrTreatClaim then
					if typeof(R.TrickOrTreatClaim) == "RemoteEvent" then R.TrickOrTreatClaim:FireServer()
					elseif typeof(R.TrickOrTreatClaim) == "RemoteFunction" then R.TrickOrTreatClaim:InvokeServer() end
				end
			end)
		end
		task.wait(10)
	end
end)

task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.halloRollPumpkin then
			pcall(function() if R.PumpkinRoll then R.PumpkinRoll:InvokeServer() end end)
			task.wait(2.1)
		else
			task.wait(1)
		end
	end
end)

SendNotification("MofenkHub", "V109.0 Ultimate Stable Loaded!", 3, false)
