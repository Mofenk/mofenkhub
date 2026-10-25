-- ===================================================================== --
-- 👑 MOFENKHUB V90.0 — FINAL DIRECT REMOTE SYNC (AUTO ROLL & SELL ALL)
-- ===================================================================== --

--!nocheck
task.wait(0.5)
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local TeleportService   = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local successGui, parentGui = pcall(function()
	if gethui then return gethui() elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end

pcall(function() for _, v in pairs(parentGui:GetChildren()) do if string.find(v.Name, "Mofenk") then v:Destroy() end end end)

_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

local F = {
	autoSave = true, themeIndex = 1,
	collect = false, levelup = false, maxLevel = 40,
	rebirth = false, upgrades = false, autoRoll = false,
	sellAuto = false, smartSell = false, sellRarityLimit = 2, autoFuse = false,
	potionAuto = false, potionSpecific = {},
	gradeAuto = false, gradePlacedOnly = false, gradeTargets = {}, gradeUnits = {}, gemReserve = 100,
	traitAuto = false, traitPlacedOnly = false, traitTargets = {}, traitUnits = {}, rerollReserve = 50,
	tower = false, towerName = "Dragon Tower", towerMix = false, towerEquipBest = true, towerExitOn = false, towerExitFloor = 50,
	afk = true, fpsOn = false, codesAuto = false, claimQuests = false
}

local STATE = { towerLive = "Standby", towerFloor = 0, towerDrops = 0, activeBuffs = "Tidak Ada" }

local THEMES = {
	{ Name = "Cyberpunk", Bg = Color3.fromRGB(10, 5, 15), Card = Color3.fromRGB(20, 15, 30), Header = Color3.fromRGB(15, 10, 20), Acc1 = Color3.fromRGB(0, 255, 255), Acc2 = Color3.fromRGB(255, 0, 128) },
	{ Name = "Toxic Glow", Bg = Color3.fromRGB(5, 10, 5), Card = Color3.fromRGB(15, 25, 15), Header = Color3.fromRGB(10, 15, 10), Acc1 = Color3.fromRGB(57, 255, 20), Acc2 = Color3.fromRGB(173, 255, 47) },
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

local CFG_FOLDER = "MofenkHub_Configs"
if makefolder and not isfolder(CFG_FOLDER) then pcall(function() makefolder(CFG_FOLDER) end) end
local function getCfgPath(name) return CFG_FOLDER .. "/" .. (name or "DefaultConfig") .. ".json" end
local function saveConfig(name) if writefile then pcall(function() writefile(getCfgPath(name or "DefaultConfig"), HttpService:JSONEncode(F)) end) end end
local function loadConfig(name)
	local path = getCfgPath(name or "DefaultConfig")
	if readfile and isfile and isfile(path) then
		pcall(function() local d = HttpService:JSONDecode(readfile(path)); for k,v in pairs(d) do F[k]=v end end)
	end
end
loadConfig("DefaultConfig")

-- ===================================================================== --
-- DIRECT REMOTES DARI KONSOL GAME
-- ===================================================================== --
local Net = ReplicatedStorage:WaitForChild("Network", 15)
local R = {
	Roll          = Net:FindFirstChild("RollService", true) and Net.RollService:FindFirstChild("RE", true) and Net.RollService.RE:FindFirstChild("Roll") 
	                or Net:FindFirstChild("Roll", true),
	SellInventory = Net:FindFirstChild("SellService", true) and Net.SellService:FindFirstChild("RF", true) and Net.SellService.RF:FindFirstChild("SellInventory") 
	                or Net:FindFirstChild("SellInventory", true),
	CollectBalance= Net:FindFirstChild("PlotService", true) and Net.PlotService:FindFirstChild("RE", true) and Net.PlotService.RE:FindFirstChild("CollectBalance"),
	LevelUpSlot   = Net:FindFirstChild("PlotService", true) and Net.PlotService:FindFirstChild("RE", true) and Net.PlotService.RE:FindFirstChild("LevelUpSlot"),
	Rebirth       = Net:FindFirstChild("RebirthService", true) and Net.RebirthService:FindFirstChild("RE", true) and Net.RebirthService.RE:FindFirstChild("Rebirth"),
	BuyUpgrade    = Net:FindFirstChild("BuyUpgrade", true),
	BoostUse      = Net:FindFirstChild("BoostService", true) and Net.BoostService:FindFirstChild("RE", true) and Net.BoostService.RE:FindFirstChild("Use"),
	PlayTower     = Net:FindFirstChild("PlayTower", true),
	CompleteFloor = Net:FindFirstChild("CompleteTowerFloor", true),
	RedeemCode    = Net:FindFirstChild("RedeemCode", true),
	QuestClaim    = Net:FindFirstChild("Claim", true)
}

local G = {}
pcall(function()
	local Framework = ReplicatedStorage:WaitForChild("Framework", 15)
	G.DC = require(Framework.Features.Data.DataController)
	G.PlotConfig = require(Framework.Features.Plot.PlotConfig)
	G.UnitUtil = require(Framework.Features.Inventory.Kinds.Unit.UnitUtil)
	G.Rebirths = require(Framework.Features.Rebirth.Rebirths)
	G.BoostConfig = require(Framework.Features.Inventory.Kinds.Boost.BoostConfig)
	G.EntryRegistry = require(Framework.Features.Inventory.EntryRegistry)
end)

local function data() return G.DC and G.DC.___X or {} end
local function money() pcall(function() return G.DC.Money() end); return data().Money or 0 end
local function rebirthAmt() pcall(function() return G.DC.Rebirth() end); return data().Rebirth or 0 end
local function inventory() return data().Inventory or {} end
local function slots() return data().Slots or {} end
local function isUnitEntry(e) return e and type(e)=="table" and e.name and G.EntryRegistry and pcall(function() return G.EntryRegistry.getEntryConfig(e.name).kind == "Unit" end) end

-- ===================================================================== --
-- UI FLOATING "M"
-- ===================================================================== --
local ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "MofenkToggleFront"; ToggleGui.Parent = parentGui; ToggleGui.ResetOnSpawn = false
ToggleGui.DisplayOrder = 99999
local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = ToggleGui; ToggleBtn.Size = UDim2.new(0, 55, 0, 55); ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = THEMES[1].Card; ToggleBtn.Text = "M"; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 28; ToggleBtn.TextColor3 = THEMES[1].Acc1; ToggleBtn.ZIndex = 99999
local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 14); TC.Parent = ToggleBtn
local TS = Instance.new("UIStroke"); TS.Thickness = 2.5; TS.Parent = ToggleBtn; table.insert(ThemeElements.Acc1, TS)

local dragging, dragInput, dragStart, startPos
ToggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = input.Position; startPos = ToggleBtn.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart; local viewport = workspace.CurrentCamera.ViewportSize
		ToggleBtn.Position = UDim2.new(0, math.clamp(startPos.X.Offset + delta.X, 10, viewport.X - 65), 0, math.clamp(startPos.Y.Offset + delta.Y, 10, viewport.Y - 65))
	end
end)

-- ===================================================================== --
-- MAIN UI SETUP
-- ===================================================================== --
local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkUltraHub"; MainGui.Parent = parentGui
local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui; MainFrame.Size = UDim2.new(0, 900, 0, 580); MainFrame.Position = UDim2.new(0.5, -450, 0.5, -290)
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.BackgroundTransparency = 0.15; table.insert(ThemeElements.Bg, MainFrame)
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 16); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 3; MainStroke.Parent = MainFrame
local StrokeGrad = Instance.new("UIGradient"); StrokeGrad.Parent = MainStroke; table.insert(ThemeElements.Grad, StrokeGrad)

ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 48); TopBar.BackgroundTransparency = 0.2; table.insert(ThemeElements.Header, TopBar)
local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 20, 0, 0); Title.Size = UDim2.new(0, 500, 1, 0); Title.Text = "👑 MOFENKHUB V90.0  |  ANIME DICE PRO"; Title.TextSize = 14; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, Title)

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -42, 0, 9); CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(255,255,255); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BackgroundTransparency = 0.2; table.insert(ThemeElements.Card, CloseBtn)
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 8); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = MainFrame; Sidebar.Position = UDim2.new(0, 10, 0, 56); Sidebar.Size = UDim2.new(0, 180, 1, -66); Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 2; Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
local SideLayout = Instance.new("UIListLayout"); SideLayout.Parent = Sidebar; Sidebar.ScrollingDirection = Enum.ScrollingDirection.Y; SideLayout.Padding = UDim.new(0, 5)

local ContentArea = Instance.new("Frame"); ContentArea.Parent = MainFrame; ContentArea.Position = UDim2.new(0, 200, 0, 56); ContentArea.Size = UDim2.new(1, -210, 1, -66); ContentArea.BackgroundTransparency = 0.3; table.insert(ThemeElements.Header, ContentArea)
local ContentCorner = Instance.new("UICorner"); ContentCorner.CornerRadius = UDim.new(0, 12); ContentCorner.Parent = ContentArea

local TabFrames, TabButtons = {}, {}
local function CreateTab(name, icon)
	local Btn = Instance.new("TextButton"); Btn.Parent = Sidebar; Btn.Size = UDim2.new(1, -4, 0, 36); Btn.Text = "  " .. icon .. "  " .. name; Btn.TextColor3 = Color3.fromRGB(220,220,220); Btn.TextSize = 11; Btn.Font = Enum.Font.GothamBold; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.BackgroundTransparency = 0.3; table.insert(ThemeElements.Card, Btn)
	local Corner = Instance.new("UICorner"); Corner.CornerRadius = UDim.new(0, 8); Corner.Parent = Btn
	local Scroll = Instance.new("ScrollingFrame"); Scroll.Parent = ContentArea; Scroll.Size = UDim2.new(1, -16, 1, -16); Scroll.Position = UDim2.new(0, 8, 0, 8); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 3; Scroll.Visible = false; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local Lay = Instance.new("UIListLayout"); Lay.Parent = Scroll; Scroll.ScrollingDirection = Enum.ScrollingDirection.Y; Lay.Padding = UDim.new(0, 10)
	TabFrames[name] = Scroll; TabButtons[name] = Btn
	
	Btn.MouseButton1Click:Connect(function()
		for n, f in pairs(TabFrames) do f.Visible = (n == name) end
		for _, b in pairs(TabButtons) do b.BackgroundTransparency = 0.3; b.TextColor3 = Color3.fromRGB(220,220,220); for i,v in ipairs(ThemeElements.Acc1) do if v==b then table.remove(ThemeElements.Acc1, i) end end end
		Btn.BackgroundTransparency = 0; table.insert(ThemeElements.Acc1, Btn); ApplyTheme(F.themeIndex); Btn.TextColor3 = Color3.fromRGB(255,255,255)
	end)
	return Scroll
end

local function AddGroup(parent, title)
	local GroupCard = Instance.new("Frame"); GroupCard.Parent = parent; GroupCard.Size = UDim2.new(1, 0, 0, 0); GroupCard.AutomaticSize = Enum.AutomaticSize.Y; GroupCard.BackgroundTransparency = 0.2; table.insert(ThemeElements.Card, GroupCard)
	local GC = Instance.new("UICorner"); GC.CornerRadius = UDim.new(0, 10); GC.Parent = GroupCard
	local GS = Instance.new("UIStroke"); GS.Thickness = 1; GS.Transparency = 0.7; GS.Parent = GroupCard; table.insert(ThemeElements.Acc1, GS)
	local GLayout = Instance.new("UIListLayout"); GLayout.Parent = GroupCard; GLayout.Padding = UDim.new(0, 6); GLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local GPadding = Instance.new("UIPadding"); GPadding.Parent = GroupCard; GPadding.PaddingTop = UDim.new(0, 8); GPadding.PaddingBottom = UDim.new(0, 8); GPadding.PaddingLeft = UDim.new(0, 8); GPadding.PaddingRight = UDim.new(0, 8)
	
	if title and title ~= "" then
		local HeaderLbl = Instance.new("TextLabel"); HeaderLbl.Parent = GroupCard; HeaderLbl.Size = UDim2.new(1, 0, 0, 24); HeaderLbl.Text = title; HeaderLbl.TextSize = 11; HeaderLbl.Font = Enum.Font.GothamBlack; HeaderLbl.TextXAlignment = Enum.TextXAlignment.Left; HeaderLbl.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, HeaderLbl)
	end
	return GroupCard
end

local function AddToggle(parent, text, flag, callback)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 36); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.7, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 11; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Sw = Instance.new("TextButton"); Sw.Parent = Frm; Sw.Position = UDim2.new(1, -44, 0.5, -11); Sw.Size = UDim2.new(0, 38, 0, 22); Sw.Text = ""; Sw.BackgroundColor3 = F[flag] and THEMES[1].Acc1 or Color3.fromRGB(45,45,55); local SwC = Instance.new("UICorner"); SwC.CornerRadius = UDim.new(1, 0); SwC.Parent = Sw
	local Knob = Instance.new("Frame"); Knob.Parent = Sw; Knob.Size = UDim2.new(0, 18, 0, 18); Knob.Position = F[flag] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9); Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(1, 0); KC.Parent = Knob
	if F[flag] then table.insert(ThemeElements.Acc1, Sw) end
	Sw.MouseButton1Click:Connect(function()
		F[flag] = not F[flag]; if F.autoSave then pcall(function() saveConfig("DefaultConfig") end) end
		TweenService:Create(Knob, TweenInfo.new(0.2), {Position = F[flag] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
		if F[flag] then table.insert(ThemeElements.Acc1, Sw); ApplyTheme(F.themeIndex) else for i,v in ipairs(ThemeElements.Acc1) do if v==Sw then table.remove(ThemeElements.Acc1,i) end end; Sw.BackgroundColor3 = Color3.fromRGB(45,45,55) end
		if callback then pcall(callback, F[flag]) end
	end)
end

local function AddInput(parent, text, flag, isNum)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 36); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.5, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 11; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Box = Instance.new("TextBox"); Box.Parent = Frm; Box.Position = UDim2.new(0.5, 0, 0.1, 0); Box.Size = UDim2.new(0.48, 0, 0.8, 0); Box.Text = tostring(F[flag] or ""); table.insert(ThemeElements.TextAcc, Box); Box.TextSize = 11; Box.Font = Enum.Font.GothamBold; Box.BackgroundTransparency = 0.2; table.insert(ThemeElements.Header, Box); local BC = Instance.new("UICorner"); BC.CornerRadius = UDim.new(0, 6); BC.Parent = Box
	Box.FocusLost:Connect(function() F[flag] = isNum and (tonumber(Box.Text) or 0) or Box.Text; if F.autoSave then pcall(function() saveConfig("DefaultConfig") end) end end)
end

-- ===================================================================== --
-- TABS ASSEMBLY
-- ===================================================================== --
local T_Dash = CreateTab("Dashboard", "📊")
local T_Farm = CreateTab("Farming", "⛏️")
local T_Inv = CreateTab("Inventory", "🎒")
local T_Set = CreateTab("Settings", "⚙️")

TabFrames["Dashboard"].Visible = true; Sidebar:GetChildren()[2].BackgroundTransparency = 0; table.insert(ThemeElements.Acc1, Sidebar:GetChildren()[2])

-- 1. DASHBOARD
local G_Profile = AddGroup(T_Dash, "PROFIL & STATISTIK")
local PLbl = Instance.new("TextLabel"); PLbl.Parent = G_Profile; PLbl.Size = UDim2.new(1, 0, 0, 60); PLbl.BackgroundTransparency = 1; PLbl.TextColor3 = Color3.fromRGB(255,255,255); PLbl.TextSize = 11; PLbl.Font = Enum.Font.GothamMedium; PLbl.TextXAlignment = Enum.TextXAlignment.Left
task.spawn(function()
	while task.wait(1) do pcall(function()
		PLbl.Text = string.format("👤 %s\n💰 Uang: %s\n🔄 Rebirth: %s", LocalPlayer.Name, tostring(money()), tostring(rebirthAmt()))
	end) end
end)

-- 2. FARMING (AUTO ROLL DIRECT REMOTE SYNC)
local G_Farm1 = AddGroup(T_Farm, "PLOT & AUTO ROLL")
AddToggle(G_Farm1, "Auto Collect Plot", "collect")
AddToggle(G_Farm1, "Auto Roll Dadu (Direct Remote)", "autoRoll")
AddToggle(G_Farm1, "Auto Rebirth", "rebirth")

-- 3. INVENTORY (AUTO SELL & SELL ALL DIRECT REMOTE SYNC)
local G_Inv = AddGroup(T_Inv, "AUTO SELL & SELL ALL")
AddToggle(G_Inv, "Auto Sell Unit", "sellAuto")
AddToggle(G_Inv, "Smart Sell (Batas Rarity)", "smartSell")
AddInput(G_Inv, "Max Rarity Jual (1-5):", "sellRarityLimit", true)

-- 4. SETTINGS
local G_SetConfig = AddGroup(T_Set, "CONFIG MANAGER")
local cfgNameInput = "MofenkConfig1"
AddInput(G_SetConfig, "Nama File Config:", "cfgName", false)
local BtnSave = Instance.new("TextButton"); BtnSave.Parent = G_SetConfig; BtnSave.Size = UDim2.new(1, 0, 0, 32); BtnSave.Text = "💾 SAVE CONFIG"; BtnSave.Font = Enum.Font.GothamBold; BtnSave.TextSize = 11; table.insert(ThemeElements.Header, BtnSave); table.insert(ThemeElements.TextAcc, BtnSave); Instance.new("UICorner", BtnSave).CornerRadius = UDim.new(0,6)
BtnSave.MouseButton1Click:Connect(function() pcall(function() saveConfig(cfgNameInput) end) end)

local BtnLoad = Instance.new("TextButton"); BtnLoad.Parent = G_SetConfig; BtnLoad.Size = UDim2.new(1, 0, 0, 32); BtnLoad.Text = "📂 LOAD CONFIG"; BtnLoad.Font = Enum.Font.GothamBold; BtnLoad.TextSize = 11; table.insert(ThemeElements.Header, BtnLoad); table.insert(ThemeElements.TextAcc, BtnLoad); Instance.new("UICorner", BtnLoad).CornerRadius = UDim.new(0,6)
BtnLoad.MouseButton1Click:Connect(function() pcall(function() loadConfig(cfgNameInput); ApplyTheme(F.themeIndex) end) end)

local BtnHop = Instance.new("TextButton"); BtnHop.Parent = G_SetConfig; BtnHop.Size = UDim2.new(1, 0, 0, 34); BtnHop.Text = "🌐 SERVER HOP"; BtnHop.Font = Enum.Font.GothamBlack; BtnHop.TextSize = 11; table.insert(ThemeElements.Card, BtnHop); table.insert(ThemeElements.TextAcc, BtnHop); Instance.new("UICorner", BtnHop).CornerRadius = UDim.new(0,6)
BtnHop.MouseButton1Click:Connect(function()
	pcall(function()
		local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
		for _, s in ipairs(servers.data or {}) do
			if s.playing < s.maxPlayers and s.id ~= game.JobId then
				game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
				break
			end
		end
	end)
end)

ApplyTheme(F.themeIndex)

-- ===================================================================== --
-- BACKEND THREADS (DIPERCEPAT DAN DIPASTIKAN MENGEKSEKUSI REMOTE)
-- ===================================================================== --

-- Auto Roll Thread (Direct Remote Fire)
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.autoRoll and R.Roll then
			pcall(function()
				if typeof(R.Roll) == "RemoteEvent" then
					R.Roll:FireServer()
				elseif typeof(R.Roll) == "RemoteFunction" then
					R.Roll:InvokeServer()
				end
			end)
			task.wait(0.15)
		else
			task.wait(1)
		end
	end
end)

-- Auto Sell & Sell All Thread (Direct Remote Function)
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.sellAuto and R.SellInventory then
			pcall(function()
				local keysToSell = {}
				for key, e in pairs(inventory()) do
					if isUnitEntry(e) then
						local rarity = tonumber(e.rarity) or tonumber(e.tier) or 1
						if not e.attributes or not e.attributes.locked then
							if F.smartSell and rarity <= (F.sellRarityLimit or 2) then
								table.insert(keysToSell, key)
							elseif not F.smartSell then
								table.insert(keysToSell, key)
							end
						end
					end
				end
				if #keysToSell > 0 then
					if typeof(R.SellInventory) == "RemoteFunction" then
						R.SellInventory:InvokeServer(keysToSell)
					elseif typeof(R.SellInventory) == "RemoteEvent" then
						R.SellInventory:FireServer(keysToSell)
					end
				end
			end)
		end
		task.wait(3)
	end
end)

-- Farming & Misc Tasks
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.collect and R.CollectBalance then
			pcall(function() for i=1, 15 do R.CollectBalance:FireServer(i) end end)
		end
		if F.rebirth and R.Rebirth then
			pcall(function() if money() >= 9e9 then R.Rebirth:FireServer() end end)
		end
		task.wait(2)
	end
end)
