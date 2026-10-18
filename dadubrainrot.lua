-- =====================================================================
-- 👑 MOFENKHUB V52 — BUG FIX EDITION
-- Game: Dadu Brainrot! | Perbaikan "vararg" error pada Delta
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- 1. SISTEM PENCARIAN TEMPAT UI
local uiTarget
pcall(function() uiTarget = CoreGui end)
if not uiTarget then uiTarget = LocalPlayer:WaitForChild("PlayerGui") end

for _, v in pairs(uiTarget:GetChildren()) do
    if v.Name == "MofenkHubV52" then v:Destroy() end
end

-- 2. KONFIGURASI GLOBAL
_G.Mofenk = _G.Mofenk or {
    AutoCollect = false, AutoRoll = false, AutoRebirth = false,
    AutoEquipBest = false, AutoEquipSquad = false,
    AutoDungeon = false, AutoShop = false, AutoQuest = false, AutoLuckyBlock = false,
    CurrentDungeon = 1
}
_G.DungeonNames = {"Sahur Tower", "Orcala Tower", "Bombardiro Tower", "Spiderini Tower", "Larila Tower"}
_G.DungeonList = {"Battle1", "Battle2", "Battle3", "Battle4", "Battle5"}

-- 3. SISTEM REMOTES (DIPERBAIKI 100%)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local function safeFire(remoteName, ...)
    local args = {...} -- TANGKAP ARGUMEN DI SINI (Memperbaiki error vararg)
    pcall(function()
        local r = Remotes and Remotes:FindFirstChild(remoteName)
        if r then
            if r:IsA("RemoteEvent") then 
                r:FireServer(unpack(args))
            elseif r:IsA("RemoteFunction") then 
                r:InvokeServer(unpack(args)) 
            end
        end
    end)
end

-- 4. MEMBANGUN UI FLAT
local SG = Instance.new("ScreenGui")
SG.Name = "MofenkHubV52"
SG.ResetOnSpawn = false
SG.Parent = uiTarget

local Main = Instance.new("Frame", SG)
Main.Size = UDim2.new(0, 350, 0, 300)
Main.Position = UDim2.new(0.5, -175, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Title.TextColor3 = Color3.fromRGB(200, 180, 255)
Title.Text = "👑 MofenkHub V52"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

local Close = Instance.new("TextButton", Title)
Close.Size = UDim2.new(0, 40, 1, 0)
Close.Position = UDim2.new(1, -40, 0, 0)
Close.BackgroundTransparency = 1
Close.TextColor3 = Color3.fromRGB(255, 60, 60)
Close.Text = "X"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 16
Close.MouseButton1Click:Connect(function() SG:Destroy() end)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.CanvasSize = UDim2.new(0,0,0,0)

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 6)
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
end)

local function MakeToggle(name, varName)
    local B = Instance.new("TextButton", Scroll)
    B.Size = UDim2.new(1, -10, 0, 35)
    B.BackgroundColor3 = _G.Mofenk[varName] and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(45, 45, 50)
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Text = name .. (_G.Mofenk[varName] and " [ON]" or " [OFF]")
    B.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    
    B.MouseButton1Click:Connect(function()
        _G.Mofenk[varName] = not _G.Mofenk[varName]
        B.BackgroundColor3 = _G.Mofenk[varName] and Color3.fromRGB(40, 120, 60) or Color3.fromRGB(45, 45, 50)
        B.Text = name .. (_G.Mofenk[varName] and " [ON]" or " [OFF]")
    end)
end

local function MakeButton(name, callback)
    local B = Instance.new("TextButton", Scroll)
    B.Size = UDim2.new(1, -10, 0, 35)
    B.BackgroundColor3 = Color3.fromRGB(70, 70, 120)
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Text = name
    B.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)
    B.MouseButton1Click:Connect(callback)
    return B
end

MakeToggle("🧲 Auto Collect Uang", "AutoCollect")
MakeToggle("🎲 Auto Roll Dadu", "AutoRoll")
MakeToggle("♻️ Auto Rebirth", "AutoRebirth")
MakeToggle("🏆 Auto Equip Best Brainrot", "AutoEquipBest")
MakeToggle("🛡️ Auto Equip Squad", "AutoEquipSquad")

local DB = MakeButton("🎯 Target: " .. _G.DungeonNames[_G.Mofenk.CurrentDungeon], function() end)
DB.MouseButton1Click:Connect(function()
    _G.Mofenk.CurrentDungeon = _G.Mofenk.CurrentDungeon + 1
    if _G.Mofenk.CurrentDungeon > 5 then _G.Mofenk.CurrentDungeon = 1 end
    DB.Text = "🎯 Target: " .. _G.DungeonNames[_G.Mofenk.CurrentDungeon]
end)

MakeToggle("⚔️ Auto Farm Dungeon Target", "AutoDungeon")
MakeToggle("🛍️ Auto Beli Dungeon Shop", "AutoShop")
MakeToggle("📜 Auto Claim Quests", "AutoQuest")
MakeToggle("🎁 Auto Buka Lucky Blocks", "AutoLuckyBlock")

task.spawn(function()
    while task.wait(0.5) do
        if not SG.Parent then break end
        pcall(function()
            if _G.Mofenk.AutoCollect then safeFire("MoneyCollected") end
            if _G.Mofenk.AutoRoll then safeFire("RollRequest") end
            if _G.Mofenk.AutoRebirth then safeFire("RebirthRequest") end
            if _G.Mofenk.AutoEquipBest then safeFire("EquipBest") end
            if _G.Mofenk.AutoEquipSquad then safeFire("EquipBestBattleSquadRequest") end
            if _G.Mofenk.AutoQuest then safeFire("ClaimAllQuests") end
            if _G.Mofenk.AutoLuckyBlock then safeFire("OpenLuckyBlocks") end
            if _G.Mofenk.AutoShop then safeFire("DungeonShopAutoBuy") end
            if _G.Mofenk.AutoDungeon then safeFire("RequestDungeonTeleport", _G.DungeonList[_G.Mofenk.CurrentDungeon]) end
        end)
    end
end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {Title="Berhasil!", Text="V52 Selesai Dimuat", Duration=3})
end)
