-- ===================================================================== --
-- 👑 MOFENKHUB V40.0 — NEON GLOW MASTER SUITE (10 THEMES)
-- Game: Anime Dice | Ultimate Logic: Smart Potion, Mix Tower, Anti-Spam
-- ===================================================================== --

--!nocheck
task.wait(0.5)
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local successGui, parentGui = pcall(function()
	if gethui then return gethui() elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end

pcall(function() for _, v in pairs(parentGui:GetChildren()) do if v.Name == "MofenkUltraHub" or v.Name == "MofenkToggle" then v:Destroy() end end end)

-- ===================================================================== --
-- 1. STATE, CONFIG & THEMES
-- ===================================================================== --
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

local F = {
	autoSave = true, themeIndex = 1,
	-- Farm
	collect = false, levelup = false, maxLevel = 40, smartLevel = false,
	rebirth = false, upgrades = false, buyDice = false, equipDice = true, autoRoll = false,
	-- Inv
	sellAuto = false, smartSell = false, sellThresholdText = "1t", autoFuse = false,
	-- Reroll & Potion
	gradeAuto = false, gradeAll = false, gradePlacedOnly = false, gradeTargets = {}, gradeUnits = {}, gemReserve = 100,
	traitAuto = false, traitAll = false, traitPlacedOnly = false, traitTargets = {}, traitUnits = {}, rerollReserve = 50,
	potionAuto = false, potionBest = true, potionSpecific = {},
	-- Tower
	tower = false, towerName = "Dragon Tower", towerMix = false, towerEquipBest = true, towerExitOn = false, towerExitFloor = 50,
	-- Client & Hooks
	wsOn = false, wsValue = 16, noclip = false, afk = true, fpsOn = false,
	codesAuto = false, claimQuests = false, hookOn = false, hookUrl = ""
}

local STATE = { towerLive = "Standby", towerFloor = 0, towerDrops = 0, activeBuffs = "Tidak Ada" }

local THEMES = {
	{ Name = "Cyberpunk", Bg = Color3.fromRGB(10, 5, 15), Card = Color3.fromRGB(20, 15, 30), Header = Color3.fromRGB(15, 10, 20), Acc1 = Color3.fromRGB(0, 255, 255), Acc2 = Color3.fromRGB(255, 0, 128) },
	{ Name = "Toxic Glow", Bg = Color3.fromRGB(5, 10, 5), Card = Color3.fromRGB(15, 25, 15), Header = Color3.fromRGB(10, 15, 10), Acc1 = Color3.fromRGB(57, 255, 20), Acc2 = Color3.fromRGB(173, 255, 47) },
	{ Name = "Crimson Hell", Bg = Color3.fromRGB(12, 0, 0), Card = Color3.fromRGB(25, 5, 5), Header = Color3.fromRGB(18, 2, 2), Acc1 = Color3.fromRGB(255, 20, 20), Acc2 = Color3.fromRGB(255, 100, 0) },
	{ Name = "Amethyst", Bg = Color3.fromRGB(10, 5, 20), Card = Color3.fromRGB(25, 15, 45), Header = Color3.fromRGB(15, 8, 30), Acc1 = Color3.fromRGB(180, 0, 255), Acc2 = Color3.fromRGB(255, 0, 255) },
	{ Name = "Gold Luxury", Bg = Color3.fromRGB(15, 12, 5), Card = Color3.fromRGB(30, 25, 15), Header = Color3.fromRGB(20, 18, 8), Acc1 = Color3.fromRGB(255, 215, 0), Acc2 = Color3.fromRGB(255, 165, 0) },
	{ Name = "Ocean Deep", Bg = Color3.fromRGB(0, 8, 15), Card = Color3.fromRGB(10, 20, 35), Header = Color3.fromRGB(5, 12, 25), Acc1 = Color3.fromRGB(0, 150, 255), Acc2 = Color3.fromRGB(0, 255, 150) },
	{ Name = "Neon Pink", Bg = Color3.fromRGB(15, 0, 10), Card = Color3.fromRGB(35, 10, 25), Header = Color3.fromRGB(20, 5, 15), Acc1 = Color3.fromRGB(255, 20, 147), Acc2 = Color3.fromRGB(255, 105, 180) },
	{ Name = "Monochrome", Bg = Color3.fromRGB(8, 8, 8), Card = Color3.fromRGB(25, 25, 25), Header = Color3.fromRGB(15, 15, 15), Acc1 = Color3.fromRGB(200, 200, 200), Acc2 = Color3.fromRGB(255, 255, 255) },
	{ Name = "Sunrise", Bg = Color3.fromRGB(15, 5, 0), Card = Color3.fromRGB(35, 15, 10), Header = Color3.fromRGB(25, 10, 5), Acc1 = Color3.fromRGB(255, 69, 0), Acc2 = Color3.fromRGB(255, 215, 0) },
	{ Name = "Hacker", Bg = Color3.fromRGB(0, 5, 0), Card = Color3.fromRGB(5, 15, 5), Header = Color3.fromRGB(2, 10, 2), Acc1 = Color3.fromRGB(0, 255, 0), Acc2 = Color3.fromRGB(0, 180, 0) },
}
local ThemeElements = { Bg = {}, Card = {}, Header = {}, Acc1 = {}, Acc2 = {}, Grad = {}, TextAcc = {} }

local function ApplyTheme(idx)
	local t = THEMES[idx]
	for _, v in ipairs(ThemeElements.Bg) do v.BackgroundColor3 = t.Bg end
	for _, v in ipairs(ThemeElements.Card) do v.BackgroundColor3 = t.Card end
	for _, v in ipairs(ThemeElements.Header) do v.BackgroundColor3 = t.Header end
	for _, v in ipairs(ThemeElements.Acc1) do if v:IsA("UIStroke") then v.Color = t.Acc1 else v.BackgroundColor3 = t.Acc1 end end
	for _, v in ipairs(ThemeElements.Grad) do v.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, t.Acc1), ColorSequenceKeypoint.new(1, t.Acc2)}) end
	for _, v in ipairs(ThemeElements.TextAcc) do v.TextColor3 = t.Acc1 end
end

-- ===================================================================== --
-- 2. BACKEND MODULES (VENXZ LOGIC)
-- ===================================================================== --
local Network = ReplicatedStorage:WaitForChild("Network", 15); local Framework = ReplicatedStorage:WaitForChild("Framework", 15)
local function svc(path) local node = Network; for part in string.gmatch(path, "[^%.]+") do node = node and node:FindFirstChild(part) end; return node end

local R = {
	CollectBalance = svc("PlotService.RE.CollectBalance"), LevelUpSlot = svc("PlotService.RE.LevelUpSlot"),
	BuyDice = svc("DiceShopService.RE.BuyDice"), EquipDice = svc("DiceShopService.RE.EquipDice"),
	Rebirth = svc("RebirthService.RE.Rebirth"), BuyUpgrade = svc("RE.BuyUpgrade") or svc("PlotService.RE.BuyPadUpgrade"),
	GradeRoll = svc("GradeService.RE.Roll"), TraitRoll = svc("TraitService.RE.Roll"), BoostUse = svc("BoostService.RE.Use"),
	PlayTower = svc("Towers.RF.PlayTower") or svc("Towers.RE.PlayTower"), CompleteFloor = svc("Towers.RF.CompleteTowerFloor"),
	CancelTower = svc("Towers.RF.CancelTower"), BestTowerTeam = svc("Towers.RE.EquipBestTowerTeam"),
	RedeemCode = svc("CodesService.RE.RedeemCode"), QuestClaim = svc("QuestService.RE.Claim")
}

local G = {}
local function need(name, p) pcall(function() G[name] = require(p) end) end
need("DC", Framework.Features.Data.DataController); need("PlotConfig", Framework.Features.Plot.PlotConfig)
need("UnitUtil", Framework.Features.Inventory.Kinds.Unit.UnitUtil); need("Upgrades", Framework.Features.Upgrades.Upgrades)
need("Rebirths", Framework.Features.Rebirth.Rebirths); need("TowersMod", Framework.Features.Towers.Towers)
need("BoostConfig", Framework.Features.Inventory.Kinds.Boost.BoostConfig); need("GradesMod", Framework.Features.Grades.Grades)
need("TraitsMod", Framework.Features.Traits.Traits); need("QuestConfig", Framework.Features.Quests.QuestConfig)
need("EntryRegistry", Framework.Features.Inventory.EntryRegistry); need("BuffController", Framework.Features.Buffs.BuffController)

local function data() return G.DC and G.DC.___X or {} end
local function money() pcall(function() return G.DC.Money() end); return data().Money or 0 end
local function rebirthAmt() pcall(function() return G.DC.Rebirth() end); return data().Rebirth or 0 end
local function inventory() return data().Inventory or {} end
local function slots() return data().Slots or {} end
local function isUnitEntry(e) return e and type(e)=="table" and e.name and G.EntryRegistry and pcall(function() return G.EntryRegistry.getEntryConfig(e.name).kind == "Unit" end) end
local function currencyAmount(name) local t = 0; for _, e in pairs(inventory()) do if type(e)=="table" and e.name==name then t += tonumber(e.amount) or 0 end end; return t end

local CFG_FILE = "MofenkHub_V40_AnimeDice.json"
local function saveConfig() if writefile then pcall(function() writefile(CFG_FILE, HttpService:JSONEncode(F)) end) end end
local function loadConfig() if readfile and isfile and isfile(CFG_FILE) then pcall(function() local d = HttpService:JSONDecode(readfile(CFG_FILE)); for k,v in pairs(d) do F[k]=v end end) end end
loadConfig()

-- ===================================================================== --
-- 3. AESTHETIC UI SETUP
-- ===================================================================== --
local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkUltraHub"; MainGui.Parent = parentGui
local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui; MainFrame.Size = UDim2.new(0, 880, 0, 580); MainFrame.Position = UDim2.new(0.5, -440, 0.5, -290); MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.ClipsDescendants = true
table.insert(ThemeElements.Bg, MainFrame)
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 16); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 3; MainStroke.Parent = MainFrame
local StrokeGrad = Instance.new("UIGradient"); StrokeGrad.Parent = MainStroke; table.insert(ThemeElements.Grad, StrokeGrad)

local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 50); table.insert(ThemeElements.Header, TopBar)
local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 20, 0, 0); Title.Size = UDim2.new(0, 500, 1, 0); Title.Text = "MOFENKHUB  |  NEON GLOW V40"; Title.TextSize = 15; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, Title)
local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -40, 0, 10); CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(255,255,255); CloseBtn.Font = Enum.Font.GothamBold; table.insert(ThemeElements.Card, CloseBtn)
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 8); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = MainFrame; Sidebar.Position = UDim2.new(0, 12, 0, 60); Sidebar.Size = UDim2.new(0, 180, 1, -72); Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 2; Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y; Sidebar.CanvasSize = UDim2.new(0,0,0,0)
local SideLayout = Instance.new("UIListLayout"); SideLayout.Parent = Sidebar; SideLayout.Padding = UDim.new(0, 8)

local ContentArea = Instance.new("Frame"); ContentArea.Parent = MainFrame; ContentArea.Position = UDim2.new(0, 200, 0, 60); ContentArea.Size = UDim2.new(1, -212, 1, -72); table.insert(ThemeElements.Header, ContentArea)
local ContentCorner = Instance.new("UICorner"); ContentCorner.CornerRadius = UDim.new(0, 12); ContentCorner.Parent = ContentArea

local TabFrames, UIDropdowns = {}, {}
local function CreateTab(name, icon)
	local Btn = Instance.new("TextButton"); Btn.Parent = Sidebar; Btn.Size = UDim2.new(1, -4, 0, 40); Btn.Text = "  " .. icon .. "  " .. name; Btn.TextColor3 = Color3.fromRGB(220,220,220); Btn.TextSize = 12; Btn.Font = Enum.Font.GothamBold; Btn.TextXAlignment = Enum.TextXAlignment.Left; table.insert(ThemeElements.Card, Btn)
	local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 10); Corner.Parent = Btn
	local Scroll = Instance.new("ScrollingFrame"); Scroll.Parent = ContentArea; Scroll.Size = UDim2.new(1, -16, 1, -16); Scroll.Position = UDim2.new(0, 8, 0, 8); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 3; Scroll.Visible = false; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.CanvasSize = UDim2.new(0,0,0,0)
	local Lay = Instance.new("UIListLayout"); Lay.Parent = Scroll; Lay.Padding = UDim.new(0, 10)
	TabFrames[name] = Scroll
	Btn.MouseButton1Click:Connect(function()
		for n, f in pairs(TabFrames) do f.Visible = (n == name) end
		for _, b in ipairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.BackgroundTransparency = 0.2; b.TextColor3 = Color3.fromRGB(220,220,220) end end
		Btn.BackgroundTransparency = 0; table.insert(ThemeElements.Acc1, Btn); ApplyTheme(F.themeIndex); Btn.TextColor3 = Color3.fromRGB(255,255,255)
	end)
	return Scroll
end

local function AddSection(parent, text)
	local L = Instance.new("TextLabel"); L.Parent = parent; L.Size = UDim2.new(1, 0, 0, 30); L.Text = "  " .. text; L.TextSize = 12; L.Font = Enum.Font.GothamBlack; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, L)
	local Line = Instance.new("Frame"); Line.Parent = L; Line.Size = UDim2.new(1, -12, 0, 1); Line.Position = UDim2.new(0, 12, 1, -2); table.insert(ThemeElements.Acc1, Line)
end

local function AddToggle(parent, text, flag, callback)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 44); table.insert(ThemeElements.Card, Frm); local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 10); C.Parent = Frm
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 14, 0, 0); L.Size = UDim2.new(0.7, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 11; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Sw = Instance.new("TextButton"); Sw.Parent = Frm; Sw.Position = UDim2.new(1, -50, 0.5, -12); Sw.Size = UDim2.new(0, 40, 0, 24); Sw.Text = ""; Sw.BackgroundColor3 = F[flag] and Color3.fromRGB(0,255,100) or Color3.fromRGB(45,45,55); local SwC = Instance.new("UICorner"); SwC.CornerRadius = UDim.new(1, 0); SwC.Parent = Sw
	local Knob = Instance.new("Frame"); Knob.Parent = Sw; Knob.Size = UDim2.new(0, 20, 0, 20); Knob.Position = F[flag] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10); Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1, 0); KC.Parent = Knob
	if F[flag] then table.insert(ThemeElements.Acc1, Sw) end
	Sw.MouseButton1Click:Connect(function()
		F[flag] = not F[flag]; if F.autoSave then pcall(saveConfig) end
		TweenService:Create(Knob, TweenInfo.new(0.2), {Position = F[flag] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}):Play()
		if F[flag] then table.insert(ThemeElements.Acc1, Sw); ApplyTheme(F.themeIndex) else for i,v in ipairs(ThemeElements.Acc1) do if v==Sw then table.remove(ThemeElements.Acc1,i) end end; Sw.BackgroundColor3 = Color3.fromRGB(45,45,55) end
		if callback then pcall(callback, F[flag]) end
	end)
end

local function AddInput(parent, text, flag, isNum)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 44); table.insert(ThemeElements.Card, Frm); local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 10); C.Parent = Frm
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 14, 0, 0); L.Size = UDim2.new(0.5, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 11; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Box = Instance.new("TextBox"); Box.Parent = Frm; Box.Position = UDim2.new(0.5, 0, 0.15, 0); Box.Size = UDim2.new(0.45, 0, 0.7, 0); Box.Text = tostring(F[flag] or ""); table.insert(ThemeElements.TextAcc, Box); Box.TextSize = 11; Box.Font = Enum.Font.GothamBold; table.insert(ThemeElements.Header, Box); local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); BC.Parent = Box
	Box.FocusLost:Connect(function() F[flag] = isNum and (tonumber(Box.Text) or 0) or Box.Text; if F.autoSave then pcall(saveConfig) end end)
end

local function AddDropdown(parent, title, options, flag, isMulti)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 46); table.insert(ThemeElements.Card, Frm); local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 10); C.Parent = Frm
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 14, 0, 0); L.Size = UDim2.new(0.4, 0, 1, 0); L.Text = title; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 11; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Btn = Instance.new("TextButton"); Btn.Parent = Frm; Btn.Position = UDim2.new(0.42, 0, 0.15, 0); Btn.Size = UDim2.new(0.55, 0, 0.7, 0); Btn.Text = isMulti and (#(F[flag] or {}) .. " Terpilih") or tostring(F[flag] or "Select"); table.insert(ThemeElements.TextAcc, Btn); Btn.TextSize = 11; Btn.Font = Enum.Font.GothamBold; table.insert(ThemeElements.Header, Btn); local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 8); BC.Parent = Btn
	
	local DropList = Instance.new("ScrollingFrame"); DropList.Parent = parent.Parent; DropList.Size = UDim2.new(0.55, 0, 0, 160); DropList.Position = UDim2.new(0.42, 0, 0, 0); table.insert(ThemeElements.Bg, DropList); DropList.BorderSizePixel = 1; DropList.Visible = false; DropList.ZIndex = 20; DropList.ScrollBarThickness = 4; DropList.AutomaticCanvasSize = Enum.AutomaticSize.Y; DropList.CanvasSize = UDim2.new(0,0,0,0)
	local DLC = Instance.new("UICorner"); DLC.CornerRadius = UDim.new(0, 8); DLC.Parent = DropList; local DLL = Instance.new("UIListLayout"); DLL.Parent = DropList
	
	local function Render(opts)
		for _, v in pairs(DropList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
		for _, opt in ipairs(opts) do
			local OptBtn = Instance.new("TextButton"); OptBtn.Parent = DropList; OptBtn.Size = UDim2.new(1, 0, 0, 30); OptBtn.Text = "  " .. tostring(opt.label); OptBtn.TextColor3 = Color3.fromRGB(255,255,255); OptBtn.TextSize = 10; OptBtn.Font = Enum.Font.GothamMedium; OptBtn.TextXAlignment = Enum.TextXAlignment.Left; OptBtn.BackgroundTransparency = 1; OptBtn.ZIndex = 21
			local check = Instance.new("Frame"); check.Parent = OptBtn; check.Size = UDim2.new(0, 14, 0, 14); check.Position = UDim2.new(1, -24, 0.5, -7); local cc = Instance.new("UICorner"); cc.Parent = check
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
				updateVisuals(); if F.autoSave then pcall(saveConfig) end
			end)
		end
	end
	Render(options)
	Btn.MouseButton1Click:Connect(function() DropList.Visible = not DropList.Visible end)
	local DropAPI = { Refresh = function(newOpts) Render(newOpts) end }; table.insert(UIDropdowns, DropAPI); return DropAPI
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
-- 4. BUILD TABS
-- ===================================================================== --
local T_Dash = CreateTab("Dashboard", "📊"); local T_Farm = CreateTab("Farm & Plot", "⛏️"); local T_Inv = CreateTab("Inventory", "🎒")
local T_Roll = CreateTab("Reroll & Boost", "🧬"); local T_Twr = CreateTab("Tower Monitor", "🏰"); local T_Set = CreateTab("Settings", "⚙️")
TabFrames["Dashboard"].Visible = true

-- DASHBOARD
AddSection(T_Dash, "PROFIL & STATISTIK")
local ProfCard = Instance.new("Frame"); ProfCard.Parent = T_Dash; ProfCard.Size = UDim2.new(1, 0, 0, 100); table.insert(ThemeElements.Card, ProfCard); local PC = Instance.new("UICorner"); PC.CornerRadius = UDim.new(0,12); PC.Parent = ProfCard
local PImg = Instance.new("ImageLabel"); PImg.Parent = ProfCard; PImg.Position = UDim2.new(0, 15, 0, 15); PImg.Size = UDim2.new(0, 70, 0, 70); pcall(function() PImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end); local PImgC = Instance.new("UICorner"); PImgC.CornerRadius = UDim.new(1,0); PImgC.Parent = PImg; local PStr = Instance.new("UIStroke"); PStr.Thickness = 2; PStr.Parent = PImg; table.insert(ThemeElements.Acc1, PStr)
local PLbl = Instance.new("TextLabel"); PLbl.Parent = ProfCard; PLbl.Position = UDim2.new(0, 100, 0, 15); PLbl.Size = UDim2.new(1, -110, 1, -30); PLbl.BackgroundTransparency = 1; PLbl.TextColor3 = Color3.fromRGB(255,255,255); PLbl.TextSize = 12; PLbl.Font = Enum.Font.GothamMedium; PLbl.TextXAlignment = Enum.TextXAlignment.Left; PLbl.TextYAlignment = Enum.TextYAlignment.Top

AddSection(T_Dash, "INVENTORY & BUFFS SPY")
local SpyCard = Instance.new("Frame"); SpyCard.Parent = T_Dash; SpyCard.Size = UDim2.new(1, 0, 0, 110); table.insert(ThemeElements.Card, SpyCard); local SC = Instance.new("UICorner"); SC.CornerRadius = UDim.new(0,12); SC.Parent = SpyCard
local SLbl = Instance.new("TextLabel"); SLbl.Parent = SpyCard; SLbl.Position = UDim2.new(0, 15, 0, 10); SLbl.Size = UDim2.new(1, -30, 1, -20); SLbl.BackgroundTransparency = 1; SLbl.TextColor3 = Color3.fromRGB(255,255,255); SLbl.TextSize = 11; SLbl.Font = Enum.Font.GothamMedium; SLbl.TextXAlignment = Enum.TextXAlignment.Left; SLbl.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
	while task.wait(1) do
		pcall(function()
			local m = money(); local rb = rebirthAmt(); local rls = G.DC.Rolls() or 0
			PLbl.Text = string.format("👤 %s\n💰 Uang: %s\n🔄 Rebirth: %s | 🎲 Rolls: %s", LocalPlayer.Name, tostring(m), tostring(rb), tostring(rls))
			
			local mut, trt, grd, tot = 0, 0, 0, 0
			for _, e in pairs(inventory()) do
				if isUnitEntry(e) then tot += 1; if e.attributes then if e.attributes.mutation then mut += 1 end; if e.attributes.trait then trt += 1 end; if e.attributes.grade then grd += 1 end end end
			end
			
			local buffs = ""; if G.BuffController and G.BuffController.ActiveBuffs then for k, v in pairs(G.BuffController.ActiveBuffs) do buffs = buffs .. k .. ", " end end
			if buffs == "" then buffs = "Tidak ada" end
			STATE.activeBuffs = buffs
			
			SLbl.Text = string.format("💎 Gems: %d | 🧬 Trait Reroll: %d\n⚔️ Total Unit: %d/100\n⚡ Quirk: %d | 🧬 Trait: %d | ⭐ Grade: %d\n🧪 Active Potion: %s", currencyAmount("Gems"), currencyAmount("Trait Reroll"), tot, mut, trt, grd, STATE.activeBuffs)
		end)
	end
end)

-- FARM & PLOT
AddSection(T_Farm, "MAIN FARMING")
AddToggle(T_Farm, "Auto Collect Plot", "collect")
AddToggle(T_Farm, "Auto Roll Dadu", "autoRoll", function(v) local s = getSig and getSig("RollService", "SetAutoRoll"); if s then pcall(function() s:Fire(v) end) end end)
AddToggle(T_Farm, "Auto Beli & Equip Dadu", "buyDice")
AddToggle(T_Farm, "Auto Rebirth (Anti-Spam)", "rebirth")
AddSection(T_Farm, "LEVELING & UPGRADES")
AddToggle(T_Farm, "Auto Level Up Unit", "levelup")
AddInput(T_Farm, "Max Level Batas:", "maxLevel", true)
AddToggle(T_Farm, "Auto Upgrade Skill Tree", "upgrades")

-- INVENTORY
AddSection(T_Inv, "MANAGEMENT")
AddToggle(T_Inv, "Auto Sell Unit", "sellAuto")
AddToggle(T_Inv, "Smart Sell (Otomatis Batas Rarity)", "smartSell")
AddToggle(T_Inv, "Auto Fusion Unit", "autoFuse")

-- REROLL & BOOST
AddSection(T_Roll, "POTIONS / BOOSTS")
AddToggle(T_Roll, "Auto Gunakan Potion", "potionAuto")
AddDropdown(T_Roll, "Pilih Potion Spesifik (Atau Kosongkan utk Semua):", GetOpts("pot"), "potionSpecific", true)
AddSection(T_Roll, "AUTO GRADE")
AddToggle(T_Roll, "Auto Grade", "gradeAuto")
AddToggle(T_Roll, "Hanya Unit di Base (Placed)", "gradePlacedOnly")
local DG_T = AddDropdown(T_Roll, "Target Grade:", GetOpts("grade"), "gradeTargets", true)
local DG_U = AddDropdown(T_Roll, "Pilih Unit Spesifik:", GetOpts("unit"), "gradeUnits", true)
AddInput(T_Roll, "Sisakan Gems:", "gemReserve", true)
AddSection(T_Roll, "AUTO TRAIT")
AddToggle(T_Roll, "Auto Trait", "traitAuto")
AddToggle(T_Roll, "Hanya Unit di Base (Placed)", "traitPlacedOnly")
local DT_T = AddDropdown(T_Roll, "Target Trait:", GetOpts("trait"), "traitTargets", true)
local DT_U = AddDropdown(T_Roll, "Pilih Unit Spesifik:", GetOpts("unit"), "traitUnits", true)

-- TOWER
AddSection(T_Twr, "TOWER FARMING (SMART & MIX)")
AddToggle(T_Twr, "Auto Tower Farming", "tower")
AddToggle(T_Twr, "Mode MIX / Random Tower", "towerMix")
AddDropdown(T_Twr, "Pilih Tower (Jika tidak Mix):", {{label="Dragon Tower", val="Dragon Tower"},{label="Cursed Tower", val="Cursed Tower"},{label="Pirate Tower", val="Pirate Tower"},{label="Infinity Tower", val="Infinity Tower"}}, "towerName", false)
AddToggle(T_Twr, "Keluar Lantai Tertentu", "towerExitOn")
AddInput(T_Twr, "Lantai Exit:", "towerExitFloor", true)

local TwrCard = Instance.new("Frame"); TwrCard.Parent = T_Twr; TwrCard.Size = UDim2.new(1, 0, 0, 70); table.insert(ThemeElements.Card, TwrCard); local TwrC = Instance.new("UICorner"); TwrC.CornerRadius = UDim.new(0,12); TwrC.Parent = TwrCard
local TwrLbl = Instance.new("TextLabel"); TwrLbl.Parent = TwrCard; TwrLbl.Position = UDim2.new(0, 15, 0, 10); TwrLbl.Size = UDim2.new(1, -30, 1, -20); TwrLbl.BackgroundTransparency = 1; TwrLbl.TextColor3 = Color3.fromRGB(255,255,255); TwrLbl.TextSize = 12; TwrLbl.Font = Enum.Font.GothamMedium; TwrLbl.TextXAlignment = Enum.TextXAlignment.Left; TwrLbl.TextYAlignment = Enum.TextYAlignment.Top
task.spawn(function() while task.wait(0.5) do pcall(function() TwrLbl.Text = string.format("🎮 Status: %s\n🏢 Lantai: %d\n💎 Gems Didapat: %d", STATE.towerLive, STATE.towerFloor, STATE.towerDrops) end) end end)

-- SETTINGS
AddSection(T_Set, "TEMA & WARNA (NEON GLOW)")
local BtnTheme = Instance.new("TextButton"); BtnTheme.Parent = T_Set; BtnTheme.Size = UDim2.new(1, 0, 0, 40); BtnTheme.Text = "🎲 RANDOMIZE THEME"; BtnTheme.Font = Enum.Font.GothamBlack; BtnTheme.TextSize = 12; table.insert(ThemeElements.Card, BtnTheme); table.insert(ThemeElements.TextAcc, BtnTheme); local BTC = Instance.new("UICorner"); BTC.CornerRadius = UDim.new(0,10); BTC.Parent = BtnTheme
BtnTheme.MouseButton1Click:Connect(function() F.themeIndex = math.random(1, #THEMES); ApplyTheme(F.themeIndex); if F.autoSave then pcall(saveConfig) end end)
AddSection(T_Set, "CLIENT OPTIMIZATION")
AddToggle(T_Set, "Anti-AFK", "afk")
AddToggle(T_Set, "FPS Boost (Hapus Map)", "fpsOn", function(v) if v then pcall(function() game:GetService("Lighting").GlobalShadows = false; for _,e in ipairs(workspace:GetDescendants()) do if e:IsA("BasePart") then e.Material = Enum.Material.SmoothPlastic end end end) end end)
AddSection(T_Set, "AUTO REWARDS")
AddToggle(T_Set, "Auto Claim Quests", "claimQuests")
AddToggle(T_Set, "Auto Redeem Codes", "codesAuto")

-- ===================================================================== --
-- 5. LOGIC THREADS (COMPLEX BACKEND)
-- ===================================================================== --
ApplyTheme(F.themeIndex)

-- Anti-AFK
LocalPlayer.Idled:Connect(function() if F.afk then pcall(function() game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame); task.wait(1); game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) end) end end)

local function unlockedSlots() local arr={}; local rb = rebirthAmt(); pcall(function() for i=1, (G.PlotConfig.GetMaxSlots(rb) or 15) do if rb >= (G.PlotConfig.GetSlotRebirthRequirement(i) or 0) then table.insert(arr, i) end end end); return arr end

-- Farm Thread (Rebirth Anti-Spam, Level, Upgrade)
task.spawn(function()
	local lastRebirthAttempt = 0
	while _G.__ANIMEDICE == generation do
		if F.collect and R.CollectBalance then pcall(function() for _, slot in ipairs(unlockedSlots()) do R.CollectBalance:FireServer(slot) end end) end
		
		-- Smart Level Up
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
		
		-- Rebirth Anti Spam
		if F.rebirth and R.Rebirth and (os.clock() - lastRebirthAttempt > 5) then
			pcall(function()
				local currentRb = rebirthAmt()
				local nextR = G.Rebirths.GetNext(currentRb)
				if nextR and money() >= (nextR.cost or 9e9) then R.Rebirth:FireServer(); lastRebirthAttempt = os.clock() end
			end)
		end
		
		-- Upgrade Tree
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

-- Smart Potion Manager Thread
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.potionAuto and R.BoostUse then
			pcall(function()
				local active = G.BuffController and G.BuffController.ActiveBuffs or {}
				for key, e in pairs(inventory()) do
					if e.name and e.amount and e.amount > 0 and G.BoostConfig and G.BoostConfig.entries[e.name] then
						local shouldUse = false
						if #F.potionSpecific == 0 then shouldUse = true else
							for _, sn in ipairs(F.potionSpecific) do if e.name == sn then shouldUse = true break end end
						end
						if shouldUse and not active[e.name] then R.BoostUse:FireServer(key); task.wait(1) end
					end
				end
			end)
		end
		task.wait(5)
	end
end)

-- Tower Logic (Mix Tower & Exit Floor)
local towerNamesList = {"Dragon Tower", "Cursed Tower", "Pirate Tower", "Infinity Tower"}
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.tower and R.PlayTower and R.CompleteFloor then
			if F.towerEquipBest and R.BestTowerTeam then pcall(function() R.BestTowerTeam:FireServer() end) end
			task.wait(0.5)
			
			local pickTower = F.towerName
			if F.towerMix then pickTower = towerNamesList[math.random(1, #towerNamesList)] end
			
			STATE.towerLive = "Memulai: " .. pickTower; STATE.towerDrops = 0
			local okStart, started = pcall(function() return R.PlayTower:InvokeServer(pickTower) end)
			
			if okStart and started then
				local done, fails = false, 0
				while F.tower and not done do
					local okP, seq = pcall(function() return R.CompleteFloor:InvokeServer() end)
					if okP and type(seq) == "table" and #seq > 0 then
						fails = 0
						for _, act in ipairs(seq) do
							if act.action == "floorStarted" then STATE.towerFloor = tonumber(act.floor) or 1
							elseif act.action == "floorCompleted" and act.rewards then
								if act.rewards.Gems then STATE.towerDrops += act.rewards.Gems end
							elseif act.action == "ended" then done = true break end
						end
						if not done and F.towerExitOn and F.towerExitFloor > 0 and STATE.towerFloor >= F.towerExitFloor then
							done = true; pcall(function() R.CancelTower:InvokeServer() end)
						end
					else fails += 1; if fails > 8 then done = true end; task.wait(1) end
				end
			end
		else STATE.towerLive = "Standby"; task.wait(2) end
	end
end)

MainFrame.Visible = true
