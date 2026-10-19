-- =====================================================================
-- 👑 MOFENKHUB V77 — GOD MODE EDITION (194 REMOTES SYNCED)
-- Game: Dadu Brainrot! | Full Base, Speed, Item Mutation, & Dungeon
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 1. PEMBERSIHAN UI LAMA (ANTI-MACET)
local uiTarget
pcall(function() uiTarget = CoreGui end)
if not uiTarget then uiTarget = LocalPlayer:WaitForChild("PlayerGui") end
for _, v in pairs(uiTarget:GetChildren()) do if v.Name == "MofenkHubV77" then v:Destroy() end end

-- 2. KONFIGURASI GLOBAL (SUPER LENGKAP)
_G.Mofenk = _G.Mofenk or {
    -- Main Farm
    AutoRoll = false, AutoCollect = false, AutoRebirth = false,
    AutoEquipBest = false, AutoEquipSquad = false,
    -- Brainrot & Item
    AutoTrait = false, AutoSell = false, AutoMutate = false, AutoUpgradeBrainrot = false,
    AutoLuckyBlock = false, AutoQuest = false, AutoIndex = false,
    -- Upgrades (Spesifik)
    UpgSpeed = false, UpgMoney = false, UpgLuck = false, UpgDamage = false, 
    UpgRoll = false, UpgInv = false, AutoBuyDice = false,
    -- Dungeon & Base
    AutoDungeon = false, TargetFloor = "Battle1", AutoBuyShop = false,
    -- Local Player Mods
    CustomSpeed = false, WalkSpeed = 50,
    CustomJump = false, JumpPower = 100,
    InfJump = false
}

-- 3. ENGINE REMOTES (MULTI-THREADING)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local function safeFire(remoteName, ...)
    local args = {...}
    task.spawn(function()
        pcall(function()
            local r = Remotes and Remotes:FindFirstChild(remoteName)
            if r then
                if r:IsA("RemoteEvent") then r:FireServer(unpack(args))
                elseif r:IsA("RemoteFunction") then r:InvokeServer(unpack(args)) end
            end
        end)
    end)
end

-- ==========================================
-- 4. FRAMEWORK UI NATIVE MOBILE OUROBOROS
-- ==========================================
local SG = Instance.new("ScreenGui")
SG.Name = "MofenkHubV77"
SG.ResetOnSpawn = false
SG.Parent = uiTarget

local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 460, 0, 320)
Main.Position = UDim2.new(0.5, -230, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(20, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Topbar = Instance.new("Frame", Main)
Topbar.Size = UDim2.new(1, 0, 0, 40)
Topbar.BackgroundColor3 = Color3.fromRGB(35, 25, 30)
Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Topbar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "👑 Ouroboros V77 - God Mode Edition"
Title.TextColor3 = Color3.fromRGB(255, 150, 180)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Topbar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(30, 22, 28)
local TabLayout = Instance.new("UIListLayout", Sidebar)
TabLayout.Padding = UDim.new(0, 5)
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

local ContentArea = Instance.new("Frame", Main)
ContentArea.Size = UDim2.new(1, -140, 1, -40)
ContentArea.Position = UDim2.new(0, 140, 0, 40)
ContentArea.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name, icon, isFirst)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, -10, 0, 35)
    TabBtn.Position = UDim2.new(0, 5, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 180)
    TabBtn.BackgroundTransparency = isFirst and 0.7 or 1
    TabBtn.TextColor3 = isFirst and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    TabBtn.Text = " " .. icon .. " " .. name
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 12
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    
    local Scroll = Instance.new("ScrollingFrame", ContentArea)
    Scroll.Size = UDim2.new(1, -20, 1, -20)
    Scroll.Position = UDim2.new(0, 10, 0, 10)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 2
    Scroll.Visible = isFirst
    
    local Layout = Instance.new("UIListLayout", Scroll)
    Layout.Padding = UDim.new(0, 8)
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)
    
    table.insert(Tabs, {Btn = TabBtn, Frame = Scroll})
    TabBtn.MouseButton1Click:Connect(function()
        for _, tab in ipairs(Tabs) do
            local active = (tab.Btn == TabBtn)
            tab.Btn.BackgroundTransparency = active and 0.7 or 1
            tab.Btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
            tab.Frame.Visible = active
        end
    end)
    return Scroll
end

local function CreateToggle(parent, text, configKey)
    local B = Instance.new("TextButton", parent)
    B.Size = UDim2.new(1, 0, 0, 35)
    B.BackgroundColor3 = _G.Mofenk[configKey] and Color3.fromRGB(200, 100, 130) or Color3.fromRGB(45, 35, 40)
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Text = text .. (_G.Mofenk[configKey] and " [ON]" or " [OFF]")
    B.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    B.MouseButton1Click:Connect(function()
        _G.Mofenk[configKey] = not _G.Mofenk[configKey]
        B.BackgroundColor3 = _G.Mofenk[configKey] and Color3.fromRGB(200, 100, 130) or Color3.fromRGB(45, 35, 40)
        B.Text = text .. (_G.Mofenk[configKey] and " [ON]" or " [OFF]")
    end)
    return B
end

local function CreateButton(parent, text, callback)
    local B = Instance.new("TextButton", parent)
    B.Size = UDim2.new(1, 0, 0, 35)
    B.BackgroundColor3 = Color3.fromRGB(60, 50, 65)
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Text = text
    B.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    B.MouseButton1Click:Connect(callback)
    return B
end

-- ==========================================
-- 5. KONTEN TAB SPESIFIK & KOMPREHENSIF
-- ==========================================
local PageMain = CreateTab("Main Farm", "🎮", true)
CreateToggle(PageMain, "🧲 Auto Collect Money", "AutoCollect")
CreateToggle(PageMain, "🎲 Auto Roll Dadu", "AutoRoll")
CreateToggle(PageMain, "♻️ Auto Rebirth", "AutoRebirth")
CreateToggle(PageMain, "🏆 Auto Equip Best Brainrot", "AutoEquipBest")
CreateToggle(PageMain, "⚔️ Auto Equip Battle Squad", "AutoEquipSquad")
CreateToggle(PageMain, "📜 Auto Claim Quests", "AutoQuest")
CreateToggle(PageMain, "📖 Auto Claim Index", "AutoIndex")

local PageBrainrot = CreateTab("Brainrot & Item", "🎒", false)
CreateToggle(PageBrainrot, "🧬 Auto Roll Traits", "AutoTrait")
CreateToggle(PageBrainrot, "👽 Auto Apply Mutation", "AutoMutate")
CreateToggle(PageBrainrot, "📈 Auto Upgrade Brainrot", "AutoUpgradeBrainrot")
CreateToggle(PageBrainrot, "💲 Auto Sell All", "AutoSell")
CreateToggle(PageBrainrot, "🎁 Auto Open Lucky Blocks", "AutoLuckyBlock")

local PageUpgrades = CreateTab("Auto Upgrades", "💎", false)
CreateToggle(PageUpgrades, "💰 Upgrade Money Buff", "UpgMoney")
CreateToggle(PageUpgrades, "🍀 Upgrade Luck Buff", "UpgLuck")
CreateToggle(PageUpgrades, "⚔️ Upgrade Damage Buff", "UpgDamage")
CreateToggle(PageUpgrades, "⚡ Upgrade Roll Speed", "UpgRoll")
CreateToggle(PageUpgrades, "🎒 Upgrade Inv Space", "UpgInv")
CreateToggle(PageUpgrades, "🎲 Auto Buy Dice (Shop)", "AutoBuyDice")

local PageDungeon = CreateTab("Base & Dungeon", "🔥", false)
CreateButton(PageDungeon, "🏠 Teleport ke Base Saya", function() safeFire("RequestMyBaseSpawn") end)
CreateButton(PageDungeon, "🌐 Teleport ke Hub Utama", function() safeFire("RequestHubSpawn") end)
local DungBtn = CreateButton(PageDungeon, "🎯 Target: " .. _G.Mofenk.TargetFloor, function() end)
DungBtn.MouseButton1Click:Connect(function()
    if _G.Mofenk.TargetFloor == "Battle1" then _G.Mofenk.TargetFloor = "Battle2"
    elseif _G.Mofenk.TargetFloor == "Battle2" then _G.Mofenk.TargetFloor = "Battle3"
    elseif _G.Mofenk.TargetFloor == "Battle3" then _G.Mofenk.TargetFloor = "Battle4"
    elseif _G.Mofenk.TargetFloor == "Battle4" then _G.Mofenk.TargetFloor = "Battle5"
    else _G.Mofenk.TargetFloor = "Battle1" end
    DungBtn.Text = "🎯 Target: " .. _G.Mofenk.TargetFloor
end)
CreateToggle(PageDungeon, "⚔️ Auto Fight Dungeon", "AutoDungeon")
CreateToggle(PageDungeon, "🛍️ Auto Beli Dungeon Shop", "AutoBuyShop")

local PagePlayer = CreateTab("Local Player", "🏃", false)
CreateToggle(PagePlayer, "⚡ Fast Walk Speed (Kecepatan)", "CustomSpeed")
CreateToggle(PagePlayer, "🚀 High Jump (Lompatan)", "CustomJump")
CreateToggle(PagePlayer, "☁️ Infinite Jump (Terbang)", "InfJump")

local PageSettings = CreateTab("Settings", "⚙️", false)
local Music = Instance.new("Sound", CoreGui)
Music.SoundId = "rbxassetid://9048375035"
Music.Volume = 0.8; Music.Looped = true
CreateButton(PageSettings, "▶️ Putar Musik", function() Music:Play() end)
CreateButton(PageSettings, "⏹️ Hentikan Musik", function() Music:Stop() end)

-- ==========================================
-- 6. BACKGROUND LOOP (LOGIKA EKSEKUSI DATA)
-- ==========================================
task.spawn(function()
    while task.wait(0.5) do
        if not SG.Parent then break end
        
        pcall(function()
            -- Main Farm
            if _G.Mofenk.AutoCollect then safeFire("MoneyCollected") end
            if _G.Mofenk.AutoRoll then safeFire("RollRequest") end
            if _G.Mofenk.AutoRebirth then safeFire("RebirthRequest") end
            if _G.Mofenk.AutoEquipBest then safeFire("EquipBest") end
            if _G.Mofenk.AutoEquipSquad then safeFire("EquipBestBattleSquadRequest") end
            if _G.Mofenk.AutoQuest then safeFire("ClaimAllQuests") end
            if _G.Mofenk.AutoIndex then safeFire("ClaimIndexReward") end
            
            -- Brainrot & Item
            if _G.Mofenk.AutoTrait then safeFire("SpinTraitRequest") end
            if _G.Mofenk.AutoMutate then safeFire("ApplyMutationRequest") end
            if _G.Mofenk.AutoUpgradeBrainrot then safeFire("UpgradeBrainrotRequest") end
            if _G.Mofenk.AutoSell then safeFire("SellAllRequest") end
            if _G.Mofenk.AutoLuckyBlock then safeFire("OpenLuckyBlocks") end
            if _G.Mofenk.AutoBuyDice then safeFire("BuyDiceRequest") end
            
            -- Upgrades Spesifik
            if _G.Mofenk.UpgMoney then safeFire("UpgradeMoneyBuffRequest") end
            if _G.Mofenk.UpgLuck then safeFire("UpgradeLuckBuffRequest") end
            if _G.Mofenk.UpgDamage then safeFire("UpgradeDamageBuffRequest") end
            if _G.Mofenk.UpgRoll then safeFire("UpgradeRollSpeedRequest"); safeFire("UpgradeMultiRollRequest") end
            if _G.Mofenk.UpgInv then safeFire("UpgradeInventorySpaceRequest") end
            
            -- Dungeon
            if _G.Mofenk.AutoBuyShop then safeFire("DungeonShopAutoBuy") end
            if _G.Mofenk.AutoDungeon then 
                safeFire("RequestDungeonTeleport", _G.Mofenk.TargetFloor)
                safeFire("SetAutoFightBoss") 
                if workspace.CurrentCamera then
                    VirtualUser:ClickButton1(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end
        end)
    end
end)

-- ==========================================
-- 7. LOCAL PLAYER MODS (SPEED, JUMP, FLY)
-- ==========================================
RunService.Heartbeat:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            if _G.Mofenk.CustomSpeed then hum.WalkSpeed = _G.Mofenk.WalkSpeed end
            if _G.Mofenk.CustomJump then hum.JumpPower = _G.Mofenk.JumpPower end
        end
    end)
end)

UserInputService.JumpRequest:Connect(function()
    pcall(function()
        if _G.Mofenk.InfJump then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end)

-- Anti AFK
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end)
