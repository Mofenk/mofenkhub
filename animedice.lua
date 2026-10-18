-- =====================================================================
-- 👑 MOFENKHUB V45 — FAILSAFE UI EDITION (DELTA/ANDROID)
-- Game: Dadu Brainrot! | Anti-Invisible UI
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Sistem Keamanan UI (Memaksa UI Muncul di Delta)
local UI_Target
pcall(function() UI_Target = gethui() end)
if not UI_Target then
    pcall(function() UI_Target = game:GetService("CoreGui") end)
end
if not UI_Target or (typeof(UI_Target) == "Instance" and not pcall(function() return UI_Target.Name end)) then
    UI_Target = LocalPlayer:WaitForChild("PlayerGui")
end

-- Hapus UI lama jika ada
for _, v in pairs(UI_Target:GetChildren()) do
    if v.Name == "MofenkHubFailsafe" then v:Destroy() end
end

_G.Mofenk = {
    AutoCollect = false, AutoRoll = false, AutoDungeon = false, AutoShop = false,
    AutoEquipBest = false, AutoEquipSquad = false, AutoRebirth = false, AutoQuest = false, AutoLuckyBlock = false,
    DungeonList = {"Battle1", "Battle2", "Battle3", "Battle4", "Battle5"},
    DungeonNames = {"Sahur Tower", "Orcala Tower", "Bombardiro Tower", "Spiderini Tower", "Larila Tower"},
    CurrentDungeonIndex = 1
}

local function notifyUI(pesan)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "👑 MofenkHub", Text = pesan, Duration = 3})
    end)
end

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local function safeFire(remoteName, ...)
    pcall(function()
        if Remotes and Remotes:FindFirstChild(remoteName) then
            local remote = Remotes[remoteName]
            if remote:IsA("RemoteEvent") then remote:FireServer(...)
            elseif remote:IsA("RemoteFunction") then remote:InvokeServer(...) end
        end
    end)
end

-- ================== UI SETUP ==================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MofenkHubFailsafe"
ScreenGui.ResetOnSpawn = false -- Penting agar UI tidak hilang saat mati
ScreenGui.Parent = UI_Target

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 480, 0, 320)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "👑 MofenkHub V45 — Failsafe UI"
Title.TextColor3 = Color3.fromRGB(180, 160, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local ContentArea = Instance.new("ScrollingFrame", MainFrame)
ContentArea.Size = UDim2.new(1, -20, 1, -50)
ContentArea.Position = UDim2.new(0, 10, 0, 45)
ContentArea.BackgroundTransparency = 1
ContentArea.ScrollBarThickness = 4
local Layout = Instance.new("UIListLayout", ContentArea)
Layout.Padding = UDim.new(0, 8)
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)

local function createToggle(text, configKey)
    local btn = Instance.new("TextButton", ContentArea)
    btn.Size = UDim2.new(1, -10, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        _G.Mofenk[configKey] = not _G.Mofenk[configKey]
        btn.BackgroundColor3 = _G.Mofenk[configKey] and Color3.fromRGB(80, 180, 100) or Color3.fromRGB(35, 35, 50)
        btn.TextColor3 = _G.Mofenk[configKey] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        btn.Text = text .. (_G.Mofenk[configKey] and ": ON" or ": OFF")
    end)
end

local function createButton(text, callback)
    local btn = Instance.new("TextButton", ContentArea)
    btn.Size = UDim2.new(1, -10, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createToggle("🧲 Auto Collect Uang", "AutoCollect")
createToggle("🎲 Auto Roll Dadu", "AutoRoll")
createToggle("🏆 Auto Equip Best Brainrot", "AutoEquipBest")
createToggle("♻️ Auto Rebirth", "AutoRebirth")
createToggle("📜 Auto Claim Quests", "AutoQuest")
createToggle("🎁 Auto Buka Lucky Blocks", "AutoLuckyBlock")

local DungeonSelectBtn = createButton("🎯 Target: " .. _G.Mofenk.DungeonNames[_G.Mofenk.CurrentDungeonIndex], function() end)
DungeonSelectBtn.MouseButton1Click:Connect(function()
    _G.Mofenk.CurrentDungeonIndex = _G.Mofenk.CurrentDungeonIndex + 1
    if _G.Mofenk.CurrentDungeonIndex > #_G.Mofenk.DungeonNames then _G.Mofenk.CurrentDungeonIndex = 1 end
    DungeonSelectBtn.Text = "🎯 Target: " .. _G.Mofenk.DungeonNames[_G.Mofenk.CurrentDungeonIndex]
end)
createToggle("⚔️ Auto Farm Dungeon Target", "AutoDungeon")
createToggle("🛍️ Auto Beli Dungeon Shop", "AutoShop")
createToggle("🛡️ Auto Equip Squad Terkuat", "AutoEquipSquad")

-- Draggable
local dragToggle, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle, dragStart, startPos = true, input.Position, MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = false end
end)

-- Loop Farming
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.Mofenk.AutoCollect then safeFire("MoneyCollected") end
            if _G.Mofenk.AutoRoll then safeFire("RollRequest") end
            if _G.Mofenk.AutoRebirth then safeFire("RebirthRequest") end
            if _G.Mofenk.AutoEquipBest then safeFire("EquipBest") end
            if _G.Mofenk.AutoEquipSquad then safeFire("EquipBestBattleSquadRequest") end
            if _G.Mofenk.AutoQuest then safeFire("ClaimAllQuests") end
            if _G.Mofenk.AutoLuckyBlock then safeFire("OpenLuckyBlocks") end
            if _G.Mofenk.AutoShop then safeFire("DungeonShopAutoBuy") end
            if _G.Mofenk.AutoDungeon then safeFire("RequestDungeonTeleport", _G.Mofenk.DungeonList[_G.Mofenk.CurrentDungeonIndex]) end
        end)
    end
end)

notifyUI("MofenkHub V45 Berhasil Dimuat!")
