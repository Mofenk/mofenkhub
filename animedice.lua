-- ===================================================================== --
-- 👑 MOFENKHUB V89.0 ULTIMATE — FULL UNIFIED SUITE + DISCORD WEBHOOK
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
local LocalPlayer       = Players.LocalPlayer

-- ===================================================================== --
-- [1] AUTO-EXECUTE (QUEUE ON TELEPORT) UNTUK REJOIN / SERVER HOP
-- ===================================================================== --
pcall(function()
	local qot = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or fluxus and fluxus.queue_on_teleport
	if qot then
		qot([[
			task.wait(3)
			loadstring(game:HttpGet("https://raw.githubusercontent.com/Mofenk/mofenkhub/refs/heads/main/animedice.lua"))()
		]])
	end
end)

-- ===================================================================== --
-- [2] CLEANUP UI LAMA
-- ===================================================================== --
local successGui, parentGui = pcall(function()
	if gethui then return gethui() elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end
pcall(function() for _, v in pairs(parentGui:GetChildren()) do if string.find(v.Name, "Mofenk") then v:Destroy() end end end)

-- ===================================================================== --
-- [3] CORE STATE & CONFIGURATION MANAGER (SYNCED)
-- ===================================================================== --
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

local F = {
	themeIndex = 1, cfgName = "MofenkConfig1", autoLoadEnabled = false,
	collect = false, levelup = false, maxLevel = 40, smartLevel = false,
	rebirth = false, upgrades = false, buyDice = false, equipDice = true, autoRoll = false,
	sellAuto = false, keepBest = 20, autoFuse = false,
	potionAuto = false, potionBest = true, potionSpecific = {},
	gradeAuto = false, gradeAll = false, gradePlacedOnly = false, gradeTargets = {}, gradeUnits = {}, gemReserve = 100,
	traitAuto = false, traitAll = false, traitPlacedOnly = false, traitTargets = {}, traitUnits = {}, rerollReserve = 50,
	tower = false, towerName = "Dragon Tower", towerMix = false, towerEquipBest = true, towerExitOn = false, towerExitFloor = 50,
	wsOn = false, wsValue = 16, noclip = false, afk = true, fpsOn = false,
	codesAuto = false, claimQuests = false,
	webhookEnabled = false, webhookUrl = "" -- NEW WEBHOOK LOGIC
}

local STATE = { towerLive = "Standby", towerFloor = 0, towerDrops = 0, towerTraitsGot = "Belum Ada", activeBuffs = "Tidak Ada" }
local ConfigUpdaters = {}

local THEMES = {
	{ Name = "Cyberpunk", Bg = Color3.fromRGB(10, 5, 15), Card = Color3.fromRGB(20, 15, 30), Header = Color3.fromRGB(15, 10, 20), Acc1 = Color3.fromRGB(0, 255, 255), Acc2 = Color3.fromRGB(255, 0, 128) },
	{ Name = "Toxic Glow", Bg = Color3.fromRGB(5, 10, 5), Card = Color3.fromRGB(15, 25, 15), Header = Color3.fromRGB(10, 15, 10), Acc1 = Color3.fromRGB(57, 255, 20), Acc2 = Color3.fromRGB(173, 255, 47) },
	{ Name = "Crimson Hell", Bg = Color3.fromRGB(12, 0, 0), Card = Color3.fromRGB(25, 5, 5), Header = Color3.fromRGB(18, 2, 2), Acc1 = Color3.fromRGB(255, 20, 20), Acc2 = Color3.fromRGB(255, 100, 0) },
	{ Name = "Gold Luxury", Bg = Color3.fromRGB(15, 12, 5), Card = Color3.fromRGB(30, 25, 15), Header = Color3.fromRGB(20, 18, 8), Acc1 = Color3.fromRGB(255, 215, 0), Acc2 = Color3.fromRGB(255, 165, 0) },
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

local function saveConfig(name)
	if writefile then
		pcall(function() 
			writefile(CFG_FOLDER .. "/" .. (name or "DefaultConfig") .. ".json", HttpService:JSONEncode(F)) 
			local pointerPath = CFG_FOLDER .. "/autoload_pointer.txt"
			if F.autoLoadEnabled then writefile(pointerPath, name or "DefaultConfig")
			else if isfile(pointerPath) then delfile(pointerPath) end end
		end)
	end
end

local function loadConfig(name)
	if readfile and isfile and isfile(CFG_FOLDER .. "/" .. name .. ".json") then
		pcall(function() 
			local d = HttpService:JSONDecode(readfile(CFG_FOLDER .. "/" .. name .. ".json"))
			for k,v in pairs(d) do F[k] = v end
			for _, updateUI in ipairs(ConfigUpdaters) do updateUI() end
			ApplyTheme(F.themeIndex)
		end)
	end
end

pcall(function()
	if isfile and isfile(CFG_FOLDER .. "/autoload_pointer.txt") then
		local autoName = readfile(CFG_FOLDER .. "/autoload_pointer.txt")
		if autoName and autoName ~= "" then loadConfig(autoName); F.autoLoadEnabled = true end
	end
end)

-- ===================================================================== --
-- [4] FRAMEWORK & MODULE BINDINGS
-- ===================================================================== --
local Network = ReplicatedStorage:WaitForChild("Network", 15); local Framework = ReplicatedStorage:WaitForChild("Framework", 15)
local function svc(p) local n = Network; for x in string.gmatch(p, "[^%.]+") do n = n and n:FindFirstChild(x) end; return n end

local R = {
	RollDice = svc("RollService.RF.RollDice"), CollectBalance = svc("PlotService.RE.CollectBalance"), LevelUpSlot = svc("PlotService.RE.LevelUpSlot"),
	BuyDice = svc("DiceShopService.RE.BuyDice"), EquipDice = svc("DiceShopService.RE.EquipDice"), Rebirth = svc("RebirthService.RE.Rebirth"), 
	BuyUpgrade = svc("RE.BuyUpgrade") or svc("PlotService.RE.BuyPadUpgrade"), BoostUse = svc("BoostService.RE.Use"),
	PlayTower = svc("Towers.RF.PlayTower") or svc("Towers.RE.PlayTower"), CompleteFloor = svc("Towers.RF.CompleteTowerFloor"),
	CancelTower = svc("Towers.RF.CancelTower"), BestTowerTeam = svc("Towers.RE.EquipBestTowerTeam"),
	RedeemCode = svc("CodesService.RE.RedeemCode") or svc("MonetizationService.RE.RedeemCode"), QuestClaim = svc("QuestService.RE.Claim"), 
	ClaimDaily = svc("DailyRewardService.RE.Claim"), ClaimOffline = svc("OfflineEarningsService.RE.Claim"), ClaimGroup = svc("GroupRewardService.RE.Claim"),
	SellInventory = svc("SellService.RF.SellInventory")
}

local G = {}
pcall(function()
	G.DC = require(Framework.Features.Data.DataController); G.PlotConfig = require(Framework.Features.Plot.PlotConfig)
	G.UnitUtil = require(Framework.Features.Inventory.Kinds.Unit.UnitUtil); G.Upgrades = require(Framework.Features.Upgrades.Upgrades)
	G.Rebirths = require(Framework.Features.Rebirth.Rebirths); G.BoostConfig = require(Framework.Features.Inventory.Kinds.Boost.BoostConfig)
	G.GradesMod = require(Framework.Features.Grades.Grades); G.TraitsMod = require(Framework.Features.Traits.Traits)
	G.QuestConfig = require(Framework.Features.Quests.QuestConfig); G.EntryRegistry = require(Framework.Features.Inventory.EntryRegistry)
	G.BuffController = require(Framework.Features.Buffs.BuffController); G.DiceModule = require(Framework.Features.Rolling.Dice)
end)

local function data() return G.DC and G.DC.___X or {} end
local function money() pcall(function() return G.DC.Money() end); return data().Money or 0 end
local function rebirthAmt() pcall(function() return G.DC.Rebirth() end); return data().Rebirth or 0 end
local function inventory() return data().Inventory or {} end
local function slots() return data().Slots or {} end
local function isUnitEntry(e) return e and type(e)=="table" and e.name and G.EntryRegistry and pcall(function() return G.EntryRegistry.getEntryConfig(e.name).kind == "Unit" end) end
local function currencyAmount(name) local t = 0; for _, e in pairs(inventory()) do if type(e)=="table" and e.name==name then t += tonumber(e.amount) or 0 end end; return t end

-- ===================================================================== --
-- [4.5] DISCORD WEBHOOK LOGIC
-- ===================================================================== --
local function SendWebhook(title, description, colorCode)
	if not F.webhookEnabled or F.webhookUrl == "" then return end
	local requestFunc = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
	if requestFunc then
		pcall(function()
			requestFunc({
				Url = F.webhookUrl,
				Method = "POST",
				Headers = {["Content-Type"] = "application/json"},
				Body = HttpService:JSONEncode({
					username = "MofenkHub | Anime Dice",
					avatar_url = "https://i.imgur.com/3qGMB7j.png",
					embeds = {{
						title = title,
						description = description,
						color = colorCode or 3447003,
						footer = {text = "Player: " .. LocalPlayer.Name .. " | Time: " .. os.date("%X")}
					}}
				})
			})
		end)
	end
end

-- ===================================================================== --
-- [5] UI SYSTEM (DRAG, SCALE, & COMPONENTS)
-- ===================================================================== --
local ToggleGui = Instance.new("ScreenGui"); ToggleGui.Name = "MofenkToggleFront"; ToggleGui.Parent = parentGui; ToggleGui.ResetOnSpawn = false
ToggleGui.DisplayOrder = 99999

local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Parent = ToggleGui; ToggleBtn.Size = UDim2.new(0, 55, 0, 55); ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = THEMES[1].Card; ToggleBtn.Text = "M"; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextSize = 28; ToggleBtn.TextColor3 = THEMES[1].Acc1; ToggleBtn.ZIndex = 99999
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 14)
local TS = Instance.new("UIStroke"); TS.Thickness = 2.5; TS.Parent = ToggleBtn; table.insert(ThemeElements.Acc1, TS)

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
		ToggleBtn.Position = UDim2.new(0, math.clamp(startPos.X.Offset + delta.X, 10, viewport.X - 65), 0, math.clamp(startPos.Y.Offset + delta.Y, 10, viewport.Y - 65))
	end
end)

local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkUltraHub"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui; MainFrame.AnchorPoint = Vector2.new(0.5, 0.5); MainFrame.Size = UDim2.new(0, 900, 0, 580); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0); MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.Visible = false; MainFrame.BackgroundTransparency = 0.15; table.insert(ThemeElements.Bg, MainFrame)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 3; MainStroke.Parent = MainFrame
local StrokeGrad = Instance.new("UIGradient"); StrokeGrad.Parent = MainStroke; table.insert(ThemeElements.Grad, StrokeGrad)

local ScreenScale = Instance.new("UIScale"); ScreenScale.Parent = MainGui
local function UpdateScale() local vp = workspace.CurrentCamera.ViewportSize; ScreenScale.Scale = math.clamp(math.min(vp.X/1280, vp.Y/720), 0.5, 1.1) end
UpdateScale(); workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.Size = UDim2.new(1, 0, 0, 48); TopBar.BackgroundTransparency = 0.2; table.insert(ThemeElements.Header, TopBar)
local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.Position = UDim2.new(0, 20, 0, 0); Title.Size = UDim2.new(0, 500, 1, 0); Title.Text = "👑 MOFENKHUB V89.0  |  ANIME DICE PRO"; Title.TextSize = 14; Title.Font = Enum.Font.GothamBlack; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, Title)
local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = TopBar; CloseBtn.Position = UDim2.new(1, -42, 0, 9); CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Text = "✕"; CloseBtn.TextColor3 = Color3.fromRGB(255,255,255); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BackgroundTransparency = 0.2; table.insert(ThemeElements.Card, CloseBtn)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8); CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

local Sidebar = Instance.new("ScrollingFrame"); Sidebar.Parent = MainFrame; Sidebar.Position = UDim2.new(0, 10, 0, 56); Sidebar.Size = UDim2.new(0, 180, 1, -66); Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 2; Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y; Sidebar.CanvasSize = UDim2.new(0,0,0,0)
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)
local ContentArea = Instance.new("Frame"); ContentArea.Parent = MainFrame; ContentArea.Position = UDim2.new(0, 200, 0, 56); ContentArea.Size = UDim2.new(1, -210, 1, -66); ContentArea.BackgroundTransparency = 0.3; table.insert(ThemeElements.Header, ContentArea)
Instance.new("UICorner", ContentArea).CornerRadius = UDim.new(0, 12)

local TabFrames, TabButtons = {}, {}
local function CreateTab(name, icon)
	local Btn = Instance.new("TextButton"); Btn.Parent = Sidebar; Btn.Size = UDim2.new(1, -4, 0, 36); Btn.Text = "  " .. icon .. "  " .. name; Btn.TextColor3 = Color3.fromRGB(220,220,220); Btn.TextSize = 11; Btn.Font = Enum.Font.GothamBold; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.BackgroundTransparency = 0.3; table.insert(ThemeElements.Card, Btn)
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
	local Scroll = Instance.new("ScrollingFrame"); Scroll.Parent = ContentArea; Scroll.Size = UDim2.new(1, -16, 1, -16); Scroll.Position = UDim2.new(0, 8, 0, 8); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 3; Scroll.Visible = false; Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; Scroll.CanvasSize = UDim2.new(0,0,0,0)
	Instance.new("UIListLayout", Scroll).Padding = UDim.new(0, 10)
	TabFrames[name] = Scroll; TabButtons[name] = Btn
	
	Btn.MouseButton1Click:Connect(function()
		for n, f in pairs(TabFrames) do f.Visible = (n == name) end
		for _, b in pairs(TabButtons) do b.BackgroundTransparency = 0.3; b.TextColor3 = Color3.fromRGB(220,220,220); for i,v in ipairs(ThemeElements.Acc1) do if v==b then table.remove(ThemeElements.Acc1, i) end end end
		Btn.BackgroundTransparency = 0; table.insert(ThemeElements.Acc1, Btn); ApplyTheme(F.themeIndex); Btn.TextColor3 = Color3.fromRGB(255,255,255)
	end)
	return Scroll
end

local function AddGroup(parent, title)
	local Grp = Instance.new("Frame"); Grp.Parent = parent; Grp.Size = UDim2.new(1, 0, 0, 0); Grp.AutomaticSize = Enum.AutomaticSize.Y; Grp.BackgroundTransparency = 0.2; table.insert(ThemeElements.Card, Grp)
	Instance.new("UICorner", Grp).CornerRadius = UDim.new(0, 10)
	local GS = Instance.new("UIStroke"); GS.Thickness = 1; GS.Transparency = 0.7; GS.Parent = Grp; table.insert(ThemeElements.Acc1, GS)
	local GLay = Instance.new("UIListLayout"); GLay.Parent = Grp; GLay.Padding = UDim.new(0, 6); GLay.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local GPad = Instance.new("UIPadding"); GPad.Parent = Grp; GPad.PaddingTop = UDim.new(0, 8); GPad.PaddingBottom = UDim.new(0, 8); GPad.PaddingLeft = UDim.new(0, 8); GPad.PaddingRight = UDim.new(0, 8)
	if title and title ~= "" then
		local H = Instance.new("TextLabel"); H.Parent = Grp; H.Size = UDim2.new(1, 0, 0, 24); H.Text = title; H.TextSize = 11; H.Font = Enum.Font.GothamBlack; H.TextXAlignment = Enum.TextXAlignment.Left; H.BackgroundTransparency = 1; table.insert(ThemeElements.TextAcc, H)
	end
	return Grp
end

local function AddToggle(parent, text, flag, callback)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 36); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.7, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 11; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Sw = Instance.new("TextButton"); Sw.Parent = Frm; Sw.Position = UDim2.new(1, -44, 0.5, -11); Sw.Size = UDim2.new(0, 38, 0, 22); Sw.Text = ""; Instance.new("UICorner", Sw).CornerRadius = UDim.new(1, 0)
	local Knob = Instance.new("Frame"); Knob.Parent = Sw; Knob.Size = UDim2.new(0, 18, 0, 18); Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

	local function UpdateVisuals()
		Sw.BackgroundColor3 = F[flag] and THEMES[F.themeIndex].Acc1 or Color3.fromRGB(45,45,55)
		TweenService:Create(Knob, TweenInfo.new(0.2), {Position = F[flag] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
		if F[flag] then table.insert(ThemeElements.Acc1, Sw) else for i,v in ipairs(ThemeElements.Acc1) do if v==Sw then table.remove(ThemeElements.Acc1,i) end end end
		ApplyTheme(F.themeIndex)
	end
	table.insert(ConfigUpdaters, UpdateVisuals)
	Sw.MouseButton1Click:Connect(function() F[flag] = not F[flag]; UpdateVisuals(); if callback then pcall(callback, F[flag]) end end)
	UpdateVisuals()
end

local function AddInput(parent, text, flag, isNum)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 36); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.5, 0, 1, 0); L.Text = text; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 11; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Box = Instance.new("TextBox"); Box.Parent = Frm; Box.Position = UDim2.new(0.5, 0, 0.1, 0); Box.Size = UDim2.new(0.48, 0, 0.8, 0); Box.TextSize = 11; Box.Font = Enum.Font.GothamBold; Box.BackgroundTransparency = 0.2; table.insert(ThemeElements.TextAcc, Box); table.insert(ThemeElements.Header, Box); Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
	local function UpdateVisuals() Box.Text = tostring(F[flag] or "") end
	table.insert(ConfigUpdaters, UpdateVisuals)
	Box.FocusLost:Connect(function() F[flag] = isNum and (tonumber(Box.Text) or 0) or Box.Text; UpdateVisuals() end)
	UpdateVisuals()
end

local function AddDropdown(parent, title, options, flag, isMulti)
	local Frm = Instance.new("Frame"); Frm.Parent = parent; Frm.Size = UDim2.new(1, 0, 0, 38); Frm.BackgroundTransparency = 1
	local L = Instance.new("TextLabel"); L.Parent = Frm; L.Position = UDim2.new(0, 6, 0, 0); L.Size = UDim2.new(0.4, 0, 1, 0); L.Text = title; L.TextColor3 = Color3.fromRGB(255,255,255); L.TextSize = 11; L.Font = Enum.Font.GothamMedium; L.TextXAlignment = Enum.TextXAlignment.Left; L.BackgroundTransparency = 1
	local Btn = Instance.new("TextButton"); Btn.Parent = Frm; Btn.Position = UDim2.new(0.42, 0, 0.1, 0); Btn.Size = UDim2.new(0.56, 0, 0.8, 0); table.insert(ThemeElements.TextAcc, Btn); Btn.TextSize = 10; Btn.Font = Enum.Font.GothamBold; Btn.BackgroundTransparency = 0.2; table.insert(ThemeElements.Header, Btn); Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
	
	local DropList = Instance.new("ScrollingFrame"); DropList.Parent = MainFrame; DropList.Size = UDim2.new(0, 220, 0, 150); table.insert(ThemeElements.Bg, DropList); DropList.BorderSizePixel = 1; DropList.Visible = false; DropList.ZIndex = 150; DropList.ScrollBarThickness = 4; DropList.AutomaticCanvasSize = Enum.AutomaticSize.Y; DropList.CanvasSize = UDim2.new(0,0,0,0)
	Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 8); Instance.new("UIListLayout", DropList)
	
	local function UpdatePos() if DropList.Visible then DropList.Position = UDim2.new(0, Btn.AbsolutePosition.X - MainFrame.AbsolutePosition.X, 0, (Btn.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y) + Btn.AbsoluteSize.Y + 2) end end
	Btn:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePos)

	local function UpdateVisuals() Btn.Text = isMulti and (#(F[flag] or {}) .. " Terpilih") or tostring(F[flag] or "Select") end
	table.insert(ConfigUpdaters, UpdateVisuals); UpdateVisuals()

	local function Render(opts)
		for _, v in pairs(DropList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
		for _, opt in ipairs(opts) do
			local OptBtn = Instance.new("TextButton"); OptBtn.Parent = DropList; OptBtn.Size = UDim2.new(1, 0, 0, 30); OptBtn.Text = "  " .. tostring(opt.label); OptBtn.TextColor3 = Color3.fromRGB(255,255,255); OptBtn.TextSize = 10; OptBtn.Font = Enum.Font.GothamMedium; OptBtn.TextXAlignment = Enum.TextXAlignment.Left; OptBtn.BackgroundTransparency = 1; OptBtn.ZIndex = 151
			local check = Instance.new("Frame"); check.Parent = OptBtn; check.Size = UDim2.new(0, 12, 0, 12); check.Position = UDim2.new(1, -20, 0.5, -6); Instance.new("UICorner", check).Parent = check; check.ZIndex = 151
			OptBtn.MouseButton1Click:Connect(function()
				if isMulti then
					local found = false; for i,v in ipairs(F[flag]) do if v==opt.val then table.remove(F[flag],i); found=true break end end
					if not found then table.insert(F[flag], opt.val) end
				else F[flag] = opt.val; DropList.Visible = false end
				UpdateVisuals()
			end)
		end
	end
	Render(options)
	Btn.MouseButton1Click:Connect(function() DropList.Visible = not DropList.Visible; UpdatePos() end)
end

-- ===================================================================== --
-- [6] TABS LAYOUT
-- ===================================================================== --
local T_Dash = CreateTab("Dashboard", "📊"); local T_Farm = CreateTab("Farming", "⛏️"); local T_Inv = CreateTab("Inventory", "🎒")
local T_Pot = CreateTab("Potions", "🧪"); local T_Twr = CreateTab("Tower", "🏰"); local T_Set = CreateTab("Settings", "⚙️")
TabFrames["Dashboard"].Visible = true; Sidebar:GetChildren()[2].BackgroundTransparency = 0; table.insert(ThemeElements.Acc1, Sidebar:GetChildren()[2])

-- Dashboard
local G_Profile = AddGroup(T_Dash, "PROFIL & STATISTIK"); local ProfContainer = Instance.new("Frame", G_Profile); ProfContainer.Size = UDim2.new(1, 0, 0, 80); ProfContainer.BackgroundTransparency = 1
local PImg = Instance.new("ImageLabel", ProfContainer); PImg.AnchorPoint = Vector2.new(0.5, 0.5); PImg.Position = UDim2.new(0.15, 0, 0.5, 0); PImg.Size = UDim2.new(0, 64, 0, 64); Instance.new("UICorner", PImg).CornerRadius = UDim.new(1,0); local PStr = Instance.new("UIStroke", PImg); PStr.Thickness = 2; table.insert(ThemeElements.Acc1, PStr); pcall(function() PImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
local PLbl = Instance.new("TextLabel", ProfContainer); PLbl.Position = UDim2.new(0.3, 0, 0, 5); PLbl.Size = UDim2.new(0.7, 0, 1, 0); PLbl.BackgroundTransparency = 1; PLbl.TextColor3 = Color3.fromRGB(255,255,255); PLbl.TextSize = 11; PLbl.Font = Enum.Font.GothamMedium; PLbl.TextXAlignment = Enum.TextXAlignment.Left; PLbl.TextYAlignment = Enum.TextYAlignment.Center
local G_Spy = AddGroup(T_Dash, "SPY INVENTORY"); local SLbl = Instance.new("TextLabel", G_Spy); SLbl.Size = UDim2.new(1, 0, 0, 80); SLbl.BackgroundTransparency = 1; SLbl.TextColor3 = Color3.fromRGB(255,255,255); SLbl.TextSize = 11; SLbl.Font = Enum.Font.GothamMedium; SLbl.TextXAlignment = Enum.TextXAlignment.Left; SLbl.TextYAlignment = Enum.TextYAlignment.Top

task.spawn(function()
	while task.wait(1) do pcall(function()
		local m = money(); local rb = rebirthAmt(); local rls = G.DC.Rolls() or 0
		PLbl.Text = string.format("👤 %s\n💰 Uang: %s\n🔄 Rebirth: %s | 🎲 Rolls: %s", LocalPlayer.Name, tostring(m), tostring(rb), tostring(rls))
		local tot = 0; for _, e in pairs(inventory()) do if isUnitEntry(e) then tot += 1 end end
		local buffs = ""; if G.BuffController and G.BuffController.ActiveBuffs then for k,v in pairs(G.BuffController.ActiveBuffs) do buffs = buffs..k..", " end end; if buffs=="" then buffs="Tidak ada" end; STATE.activeBuffs = buffs
		SLbl.Text = string.format("💎 Gems: %d | 🧬 Trait Reroll: %d\n⚔️ Total Unit: %d/100\n🧪 Active Potion: %s", currencyAmount("Gems"), currencyAmount("Trait Reroll"), tot, STATE.activeBuffs)
	end) end
end)

-- Farming
local G_Farm1 = AddGroup(T_Farm, "PLOT & ROLLING")
AddToggle(G_Farm1, "Auto Collect Plot", "collect"); AddToggle(G_Farm1, "Auto Roll Dadu", "autoRoll"); AddToggle(G_Farm1, "Auto Rebirth", "rebirth")
AddToggle(G_Farm1, "Auto Buy Dice", "buyDice"); AddToggle(G_Farm1, "Auto Equip Best Dice", "equipDice")
local G_Farm2 = AddGroup(T_Farm, "LEVELING")
AddToggle(G_Farm2, "Auto Level Up Unit", "levelup"); AddInput(G_Farm2, "Max Level Batas:", "maxLevel", true); AddToggle(G_Farm2, "Auto Upgrade Skill", "upgrades")

-- Inventory
local G_Inv = AddGroup(T_Inv, "AUTO SELL")
AddToggle(G_Inv, "Auto Sell Unit", "sellAuto"); AddInput(G_Inv, "Simpan Unit (Keep Best):", "keepBest", true)

-- Tower
local G_Twr = AddGroup(T_Twr, "TOWER FARMING")
AddToggle(G_Twr, "Auto Tower Farming", "tower")
AddDropdown(G_Twr, "Pilih Tower Spesifik:", {{label="Dragon Tower", val="Dragon Tower"},{label="Cursed Tower", val="Cursed Tower"},{label="Pirate Tower", val="Pirate Tower"},{label="Infinity Tower", val="Infinity Tower"}}, "towerName", false)
AddToggle(G_Twr, "Keluar di Lantai Tertentu", "towerExitOn"); AddInput(G_Twr, "Lantai Exit:", "towerExitFloor", true)

-- Settings & Config
local G_SetConfig = AddGroup(T_Set, "CONFIG MANAGER")
AddToggle(G_SetConfig, "Auto Load Config Saat Nyala", "autoLoadEnabled"); AddInput(G_SetConfig, "Nama File Config:", "cfgName", false)

local BtnSave = Instance.new("TextButton", G_SetConfig); BtnSave.Size = UDim2.new(1, 0, 0, 32); BtnSave.Text = "💾 SAVE CONFIG SEKARANG"; BtnSave.Font = Enum.Font.GothamBold; BtnSave.TextSize = 11; table.insert(ThemeElements.Header, BtnSave); table.insert(ThemeElements.TextAcc, BtnSave); Instance.new("UICorner", BtnSave).CornerRadius = UDim.new(0,6)
BtnSave.MouseButton1Click:Connect(function() pcall(function() saveConfig(F.cfgName) end) end)

local BtnLoad = Instance.new("TextButton", G_SetConfig); BtnLoad.Size = UDim2.new(1, 0, 0, 32); BtnLoad.Text = "📂 LOAD CONFIG PILIHAN"; BtnLoad.Font = Enum.Font.GothamBold; BtnLoad.TextSize = 11; table.insert(ThemeElements.Header, BtnLoad); table.insert(ThemeElements.TextAcc, BtnLoad); Instance.new("UICorner", BtnLoad).CornerRadius = UDim.new(0,6)
BtnLoad.MouseButton1Click:Connect(function() pcall(function() loadConfig(F.cfgName) end) end)

local G_Web = AddGroup(T_Set, "DISCORD WEBHOOK")
AddToggle(G_Web, "Aktifkan Webhook Discord", "webhookEnabled"); AddInput(G_Web, "Webhook URL (Tempel di sini):", "webhookUrl", false)
local BtnTestWeb = Instance.new("TextButton", G_Web); BtnTestWeb.Size = UDim2.new(1, 0, 0, 30); BtnTestWeb.Text = "🔔 TEST KIRIM WEBHOOK"; BtnTestWeb.Font = Enum.Font.GothamBold; BtnTestWeb.TextSize = 11; table.insert(ThemeElements.Card, BtnTestWeb); table.insert(ThemeElements.TextAcc, BtnTestWeb); Instance.new("UICorner", BtnTestWeb).CornerRadius = UDim.new(0,6)
BtnTestWeb.MouseButton1Click:Connect(function() SendWebhook("✅ Webhook Connected!", "MofenkHub V89.0 berhasil tersambung ke Discord kamu.", 3447003) end)

local G_Set2 = AddGroup(T_Set, "TOOLS")
AddToggle(G_Set2, "Anti-AFK (Bypass Disconnect)", "afk")
AddToggle(G_Set2, "FPS Boost (Hapus Partikel)", "fpsOn", function(v) if v then pcall(function() game:GetService("Lighting").GlobalShadows = false; for _,e in ipairs(workspace:GetDescendants()) do if e:IsA("BasePart") then e.Material = Enum.Material.SmoothPlastic end end end) end end)
AddToggle(G_Set2, "Auto Redeem Codes", "codesAuto")

local BtnHop = Instance.new("TextButton", G_Set2); BtnHop.Size = UDim2.new(1, 0, 0, 34); BtnHop.Text = "🌐 SERVER HOP"; BtnHop.Font = Enum.Font.GothamBlack; BtnHop.TextSize = 11; table.insert(ThemeElements.Card, BtnHop); table.insert(ThemeElements.TextAcc, BtnHop); Instance.new("UICorner", BtnHop).CornerRadius = UDim.new(0,6)
BtnHop.MouseButton1Click:Connect(function()
	pcall(function()
		local cursor = ""; local servers = {}
		repeat
			local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
			local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
			if success and result and result.data then
				for _, s in ipairs(result.data) do if type(s) == "table" and s.playing and s.maxPlayers and s.playing < s.maxPlayers and s.id ~= game.JobId then table.insert(servers, s.id) end end
				cursor = result.nextPageCursor or ""
			else break end
		until #servers > 10 or cursor == ""
		if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer) else TeleportService:Teleport(game.PlaceId, LocalPlayer) end
	end)
end)

ApplyTheme(F.themeIndex) 

-- ===================================================================== --
-- [7] BACKEND FARMING THREADS (SOLID LOGIC)
-- ===================================================================== --

-- Anti-AFK Kuat
task.spawn(function()
	local vu = game:GetService("VirtualUser")
	local function preventAFK() if not F.afk then return end; pcall(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end) end
	pcall(function() if getconnections then for _, conn in pairs(getconnections(LocalPlayer.Idled)) do conn:Disable() end end end)
	LocalPlayer.Idled:Connect(preventAFK)
	while task.wait(900) do preventAFK() end
end)

local function unlockedSlots() local arr={}; local rb = rebirthAmt(); pcall(function() for i=1, (G.PlotConfig.GetMaxSlots(rb) or 15) do if rb >= (G.PlotConfig.GetSlotRebirthRequirement(i) or 0) then table.insert(arr, i) end end end); return arr end

-- Auto Roll
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.autoRoll and R.RollDice then pcall(function() R.RollDice:InvokeServer() end); task.wait(2.1) else task.wait(1) end
	end
end)

-- Auto Buy & Equip Dice
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if (F.buyDice or F.equipDice) and R.EquipDice then
			pcall(function()
				local d = data(); local ownedDice = d.OwnedDice or d.Dice or (G.DC.OwnedDice and G.DC.OwnedDice()) or {}
				local currentEquipped = d.EquippedDice or (G.DC.EquippedDice and G.DC.EquippedDice()); local bestDiceName = nil; local bestDiceValue = -1
				if G.DiceModule then
					for diceId, diceData in pairs(G.DiceModule) do
						if type(diceData) == "table" then
							local diceValue = diceData.order or diceData.Luck or diceData.Price or diceData.price or 0
							if F.buyDice and not ownedDice[diceId] and R.BuyDice then
								local price = diceData.Price or diceData.price or 0
								if money() >= price then R.BuyDice:FireServer(diceId); ownedDice[diceId] = true; task.wait(0.2) end
							end
							if ownedDice[diceId] and diceValue > bestDiceValue then bestDiceValue = diceValue; bestDiceName = diceId end
						end
					end
				end
				if F.equipDice and bestDiceName and bestDiceName ~= currentEquipped then R.EquipDice:FireServer(bestDiceName) end
			end)
		end
		task.wait(3)
	end
end)

-- Leveling, Plot, Rebirth, Upgrades
task.spawn(function()
	local lastRebirth = 0
	while _G.__ANIMEDICE == generation do
		if F.collect and R.CollectBalance then pcall(function() for _, slot in ipairs(unlockedSlots()) do R.CollectBalance:FireServer(slot) end end) end
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
		if F.rebirth and R.Rebirth and (os.clock() - lastRebirth > 5) then pcall(function() local nr = G.Rebirths.GetNext(rebirthAmt()); if nr and money() >= (nr.cost or 9e9) then R.Rebirth:FireServer(); lastRebirth = os.clock() end end) end
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

-- Auto Sell
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.sellAuto and R.SellInventory then
			pcall(function()
				local d = data(); local cap = 100
				pcall(function() local buff = tonumber(select(2, pcall(G.BuffController.GetBuff, "Unit Storage"))); if buff and buff > 0 then cap = buff end end)
				local placed = {}
				for _, slot in pairs(d.Slots or {}) do if slot.unitId then placed[slot.unitId] = true end end
				local units, owned = {}, 0
				for id, u in pairs(d.Inventory or {}) do
					local e = G.UnitConfig and G.UnitConfig.entries[u.name] or (G.EntryRegistry and pcall(function() return G.EntryRegistry.getEntryConfig(u.name) end))
					if e then owned = owned + 1 end
					if not placed[id] and not (u.attributes and u.attributes.locked) and not (e and type(e)=="table" and e.limited) then table.insert(units, { id = id }) end
				end
				local pressured = owned >= cap - 3
				local sellable = math.max(0, #units - (F.keepBest or 20))
				local list = {}; for i, unit in ipairs(units) do if pressured or i <= sellable then list[#list + 1] = unit.id; if #list >= 300 then break end end end
				if #list > 0 then pcall(function() R.SellInventory:InvokeServer(list) end) end
			end)
		end
		task.wait(4)
	end
end)

-- Auto Tower & Webhook Milestones
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.tower and R.PlayTower and R.CompleteFloor then
			if F.towerEquipBest and R.BestTowerTeam then pcall(function() R.BestTowerTeam:FireServer() end) end
			task.wait(0.5)
			local pickTower = F.towerName
			local okStart, started = pcall(function() return R.PlayTower:InvokeServer(pickTower) end)
			if okStart and started then
				local done, fails = false, 0
				while F.tower and not done do
					local okP, seq = pcall(function() return R.CompleteFloor:InvokeServer() end)
					if okP and type(seq) == "table" and #seq > 0 then
						fails = 0
						for _, act in ipairs(seq) do
							if act.action == "floorStarted" then 
								STATE.towerFloor = tonumber(act.floor) or 1 
								-- Webhook: Notifikasi tiap kelipatan 10 lantai
								if STATE.towerFloor > 0 and STATE.towerFloor % 10 == 0 then
									SendWebhook("🏰 Tower Milestone Reached!", "Berhasil mencapai **Lantai " .. STATE.towerFloor .. "** di " .. pickTower, 16753920) -- Orange color
								end
							elseif act.action == "ended" then done = true break end
						end
						if not done and F.towerExitOn and F.towerExitFloor > 0 and STATE.towerFloor >= F.towerExitFloor then
							done = true; pcall(function() R.CancelTower:InvokeServer() end)
						end
					else fails += 1; if fails > 8 then done = true end; task.wait(1) end
				end
			end
		else task.wait(2) end
	end
end)

-- Webhook Auto-Status (Setiap 30 Menit)
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		task.wait(1800) -- 1800 detik = 30 menit
		if F.webhookEnabled then
			pcall(function()
				local m = tostring(money())
				local rb = tostring(rebirthAmt())
				local gems = tostring(currencyAmount("Gems"))
				local desc = string.format("💰 **Uang:** %s\n🔄 **Rebirth:** %s\n💎 **Gems:** %s\n🏰 **Tower Saat Ini:** %s (Lt. %d)", m, rb, gems, STATE.towerLive, STATE.towerFloor)
				SendWebhook("📊 Auto-Status Update (30 Min)", desc, 5763719) -- Green color
			end)
		end
	end
end)

-- Claim Codes
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if F.codesAuto and R.RedeemCode then pcall(function() local defaultCodes = {"RELEASE", "UPDATE1", "UPDATE2", "UPDATE3", "UPDATE4", "1KCCU", "5KCCU", "100KLIKES"}; local redeemed = G.DC.RedeemedCodes() or {}; for _, c in ipairs(defaultCodes) do if not redeemed[c] then R.RedeemCode:FireServer(c); task.wait(0.5) end end end) end
		task.wait(60)
	end
end)
