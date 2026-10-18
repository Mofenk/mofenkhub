-- =====================================================================
-- 👑 MOFENKHUB V40 — STABLE UI & DEEP GAME DUMPER [INDONESIA]
-- Game: Dadu Brainrot! | 100% Tanpa Library Eksternal (Anti-Error Nil)
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Bersihkan UI lama jika ada
if CoreGui:FindFirstChild("MofenkHubV40") then
    CoreGui.MofenkHubV40:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MofenkHubV40"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- ======================================================= --
-- 1. UTILITIES & DEEP GAME DUMPER (SCRAPER KE TXT)
-- ======================================================= --
local function notifyUI(pesan)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "👑 MofenkHub V40",
            Text = pesan,
            Duration = 3,
        })
    end)
end

local function dumpFolderRecursive(parentObj, indentLevel)
    local result = ""
    indentLevel = indentLevel or 0
    local spacing = string.rep("  ", indentLevel)
    
    pcall(function()
        for _, child in ipairs(parentObj:GetChildren()) do
            result = result .. spacing .. "- " .. child.Name .. " [" .. child.ClassName .. "]\n"
            if indentLevel < 3 and #child:GetChildren() > 0 then
                result = result .. dumpFolderRecursive(child, indentLevel + 1)
            end
        end
    end)
    return result
end

local function executeFullGameScan()
    notifyUI("Memulai Pemindaian Data Game...")
    local fullDumpText = "=== MOFENKHUB DEEP GAME DATA DUMPER ===\n"
    fullDumpText = fullDumpText .. "PlaceId: " .. tostring(game.PlaceId) .. "\nWaktu: " .. os.date() .. "\n\n"
    
    fullDumpText = fullDumpText .. "=== REPLICATED STORAGE ===\n"
    fullDumpText = fullDumpText .. dumpFolderRecursive(ReplicatedStorage, 0)
    
    fullDumpText = fullDumpText .. "\n=== WORKSPACE ===\n"
    fullDumpText = fullDumpText .. dumpFolderRecursive(Workspace, 0)
    
    pcall(function()
        if writefile then
            writefile("MofenkHub_GameDump_Full.txt", fullDumpText)
            notifyUI("Sukses! File 'MofenkHub_GameDump_Full.txt' tersimpan.")
        else
            notifyUI("Gagal: Executor tidak mendukung writefile.")
        end
    end)
end

local function getRemote(name)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v.Name:lower() == tostring(name):lower() and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            return v
        end
    end
    return nil
end

local function safeFire(remoteName, ...)
    local remote = getRemote(remoteName)
    if remote then
        pcall(function(...)
            if remote:IsA("RemoteEvent") then remote:FireServer(...)
            elseif remote:IsA("RemoteFunction") then remote:InvokeServer(...) end
        end, ...)
    end
end

-- ======================================================= --
-- 2. PEMBUATAN ANTARMUKA (UI UTAMA MofenkHub)
-- ======================================================= --
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "👑 MofenkHub V40 — Dadu Brainrot [Stable Edition]"
Title.TextColor3 = Color3.fromRGB(240, 210, 255)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Konten Utama / Tombol Fitur
local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -20, 1, -55)
ContentScroll.Position = UDim2.new(0, 10, 0, 45)
ContentScroll.BackgroundTransparency = 1
ContentScroll.CanvasSize = UDim2.new(0, 0, 2, 0)
ContentScroll.ScrollBarThickness = 4
ContentScroll.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)
UIList.Parent = ContentScroll

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 480, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 240, 255)
    btn.TextSize = 12
    btn.Parent = ContentScroll

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
end

-- ======================================================= --
-- 3. MENU FITUR BOT DALAM UI STABIL
-- ======================================================= --
_G.Mofenk = {
    AutoCollect = false,
    AutoRoll = false,
    AutoDungeon = false,
    AutoShop = false
}

createButton("🧲 Toggle Auto Collect Uang (Presisi Base): OFF", function(sender)
    _G.Mofenk.AutoCollect = not _G.Mofenk.AutoCollect
    sender.Text = "🧲 Toggle Auto Collect Uang (Presisi Base): " .. (_G.Mofenk.AutoCollect and "ON" | "OFF")
end)

createButton("🎲 Toggle Auto Roll Dadu: OFF", function(sender)
    _G.Mofenk.AutoRoll = not _G.Mofenk.AutoRoll
    sender.Text = "🎲 Toggle Auto Roll Dadu: " .. (_G.Mofenk.AutoRoll and "ON" | "OFF")
end)

createButton("⚔️ Toggle Auto Farm Dungeon (Sahur): OFF", function(sender)
    _G.Mofenk.AutoDungeon = not _G.Mofenk.AutoDungeon
    sender.Text = "⚔️ Toggle Auto Farm Dungeon (Sahur): " .. (_G.Mofenk.AutoDungeon and "ON" | "OFF")
end)

createButton("🛍️ Toggle Auto Beli Toko Dungeon: OFF", function(sender)
    _G.Mofenk.AutoShop = not _G.Mofenk.AutoShop
    sender.Text = "🛍️ Toggle Auto Beli Toko Dungeon: " .. (_G.Mofenk.AutoShop and "ON" | "OFF")
end)

createButton("📥 Scan & Download Seluruh Data Game ke TXT", function()
    executeFullGameScan()
end)

createButton("🌐 Cari Server Lain (Server Hop)", function()
    pcall(function()
        local Servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")).data
        for _, server in ipairs(Servers) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end)
end)

-- ======================================================= --
-- 4. BACKGROUND LOOPS & DRAGGABLE SYSTEM
-- ======================================================= --
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Dragging System untuk HP / Delta
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Loop Utama Bot
task.spawn(function()
    while task.wait(1.0) do
        if _G.Mofenk.AutoCollect then
            safeFire("MoneyCollected")
            safeFire("ClaimCash")
            safeFire("CollectMoney")
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local root = LocalPlayer.Character.HumanoidRootPart
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local n = obj.Name:lower()
                            if n:find("cash") or n:find("money") or n:find("drop") or n:find("podium") then
                                root.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                                break
                            end
                        end
                    end
                end
            end)
        end
        
        if _G.Mofenk.AutoRoll then safeFire("RollRequest") end
        if _G.Mofenk.AutoDungeon then safeFire("RequestDungeonTeleport", "Sahur") end
        if _G.Mofenk.AutoShop then safeFire("DungeonShopAutoBuy") end
    end
end)

notifyUI("MofenkHub V40 Berhasil Dimuat Tanpa Error!")
