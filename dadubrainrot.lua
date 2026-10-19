-- =====================================================================
-- 👑 MOFENKHUB V85 — OFFICIAL MOFENKHUB EDITION (BLUE/BLACK THEME)
-- Game: Dadu Brainrot! | UI Rayfield + Custom M Logo + Built-in Spy
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- 1. PEMBERSIHAN UI LAMA
local uiTarget
pcall(function() uiTarget = CoreGui end)
if not uiTarget then uiTarget = LocalPlayer:WaitForChild("PlayerGui") end
for _, v in pairs(uiTarget:GetChildren()) do 
    if v.Name == "MofenkHubV85" or v.Name == "MofenkSpyTerminal" then v:Destroy() end 
end

-- 2. KONFIGURASI GLOBAL
_G.Mofenk = {
    AutoRoll = false, AutoCollectMoney = false, CollectEvery = 5,
    AutoRebirth = false, AutoClaimQuests = false, AutoPlaytime = false, AutoWheel = false,
    AutoSell = false, SellEvery = 20, AutoRollTraits = false,
    AutoDungeon = false, TargetFloor = "Battle1", AutoBuyDungeonShop = false,
    SpyEnabled = false, LogHistory = {}
}

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
-- 3. TERMINAL SPY (LAYAR & KONSOL)
-- ==========================================
local SpyGui = Instance.new("ScreenGui")
SpyGui.Name = "MofenkSpyTerminal"
SpyGui.Parent = uiTarget

local SpyFrame = Instance.new("Frame", SpyGui)
SpyFrame.Size = UDim2.new(0, 420, 0, 260)
SpyFrame.Position = UDim2.new(1, -440, 1, -280)
SpyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
SpyFrame.BorderSizePixel = 2
SpyFrame.BorderColor3 = Color3.fromRGB(50, 150, 255) -- Aksen Biru
SpyFrame.Active = true
SpyFrame.Draggable = true
SpyFrame.Visible = false

local SpyTitle = Instance.new("TextLabel", SpyFrame)
SpyTitle.Size = UDim2.new(1, 0, 0, 25)
SpyTitle.BackgroundColor3 = Color3.fromRGB(20, 30, 45) -- Biru Gelap
SpyTitle.Text = " 📡 MOFENKHUB LIVE SPY TERMINAL"
SpyTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
SpyTitle.Font = Enum.Font.Code
SpyTitle.TextSize = 12
SpyTitle.TextXAlignment = Enum.TextXAlignment.Left

local ClearBtn = Instance.new("TextButton", SpyTitle)
ClearBtn.Size = UDim2.new(0, 70, 1, -6)
ClearBtn.Position = UDim2.new(1, -75, 0, 3)
ClearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ClearBtn.Text = "CLEAR"
ClearBtn.TextColor3 = Color3.fromRGB(255,255,255)
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextSize = 10

local CopyBtn = Instance.new("TextButton", SpyTitle)
CopyBtn.Size = UDim2.new(0, 70, 1, -6)
CopyBtn.Position = UDim2.new(1, -150, 0, 3)
CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
CopyBtn.Text = "COPY"
CopyBtn.TextColor3 = Color3.fromRGB(255,255,255)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 10

local SpyScroll = Instance.new("ScrollingFrame", SpyFrame)
SpyScroll.Size = UDim2.new(1, -10, 1, -35)
SpyScroll.Position = UDim2.new(0, 5, 0, 30)
SpyScroll.BackgroundTransparency = 1
SpyScroll.ScrollBarThickness = 3
local SpyLayout = Instance.new("UIListLayout", SpyScroll)
SpyLayout.Padding = UDim.new(0, 3)

local function dumpData(o, depth)
    depth = depth or 0
    if depth > 2 then return "{...}" end
    if type(o) == 'table' then
        local s = '{' for k,v in pairs(o) do s = s .. tostring(k) .. '=' .. dumpData(v, depth+1) .. ', ' end return s .. '}'
    elseif typeof(o) == "Instance" then return "<" .. o.Name .. ">"
    elseif type(o) == 'string' then return '"' .. o .. '"' else return tostring(o) end
end

local function LogToTerminal(remoteName, method, args)
    if not _G.Mofenk.SpyEnabled then return end
    local argStr = ""
    for i, v in ipairs(args) do argStr = argStr .. "Arg["..i.."]: " .. dumpData(v) .. " | " end
    if argStr == "" then argStr = "Tidak ada argumen" end

    local logString = "[" .. os.date("%X") .. "] " .. remoteName .. " -> " .. argStr
    table.insert(_G.Mofenk.LogHistory, logString)
    print("👁️ [MOFENK SPY] " .. logString)

    local LogItem = Instance.new("TextLabel", SpyScroll)
    LogItem.Size = UDim2.new(1, 0, 0, 0)
    LogItem.BackgroundTransparency = 1
    LogItem.TextColor3 = Color3.fromRGB(150, 220, 255)
    LogItem.Text = logString
    LogItem.Font = Enum.Font.Code
    LogItem.TextSize = 11
    LogItem.TextXAlignment = Enum.TextXAlignment.Left
    LogItem.TextYAlignment = Enum.TextYAlignment.Top
    LogItem.TextWrapped = true
    LogItem.AutomaticSize = Enum.AutomaticSize.Y

    task.wait(0.05)
    SpyScroll.CanvasSize = UDim2.new(0, 0, 0, SpyLayout.AbsoluteContentSize.Y + 5)
    SpyScroll.CanvasPosition = Vector2.new(0, 9999)
end

ClearBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(SpyScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
    _G.Mofenk.LogHistory = {}
end)

CopyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then setclipboard(table.concat(_G.Mofenk.LogHistory, "\n")) end
        CopyBtn.Text = "COPIED!"
        task.wait(1.5)
        CopyBtn.Text = "COPY"
    end)
end)

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        task.spawn(LogToTerminal, self.Name, method, {...})
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- ==========================================
-- 4. MEMUAT RAYFIELD UI (MOFENKHUB - BLUE & BLACK + LOGO M)
-- ==========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "MofenkHub | Dadu Brainrot V85",
   LoadingTitle = "Memuat MofenkHub...",
   LoadingSubtitle = "Blue & Black Edition + Logo M",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

Rayfield:Notify({
    Title = "MofenkHub Loaded!", 
    Content = "Selamat datang, Mofenk! Tema Biru-Hitam & Logo M aktif.", 
    Duration = 5, 
    Image = 6023426915 -- ID Ikon Logo Huruf M / Estetik Biru Hitam
})

-- TAB 1: MAIN FARM
local TabMain = Window:CreateTab("Main Farm", 6023426915)
TabMain:CreateSection("🔄 Farm Otomatis (Data Sinkron)")
TabMain:CreateToggle({Name = "Auto Roll", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoRoll = V end})
TabMain:CreateToggle({Name = "Auto Collect Money", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoCollectMoney = V end})
TabMain:CreateSlider({Name = "Collect Every (s)", Range = {1, 60}, Increment = 1, Suffix = "s", CurrentValue = 5, Callback = function(V) _G.Mofenk.CollectEvery = V end})
TabMain:CreateToggle({Name = "Auto Rebirth", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoRebirth = V end})

TabMain:CreateSection("🎁 Auto Claim (Presisi)")
TabMain:CreateToggle({Name = "Auto Claim Quests", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoClaimQuests = V end})
TabMain:CreateToggle({Name = "Auto Claim Playtime Gifts ('all')", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoPlaytime = V end})
TabMain:CreateToggle({Name = "Auto Spin Wheel", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoWheel = V end})

-- TAB 2: INVENTORY & TRAITS
local TabInv = Window:CreateTab("Inventory", 6023426915)
TabInv:CreateSection("💲 Management")
TabInv:CreateToggle({Name = "Auto Sell All", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoSell = V end})
TabInv:CreateToggle({Name = "Auto Roll Traits", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoRollTraits = V end})

-- TAB 3: DUNGEON
local TabDungeon = Window:CreateTab("Dungeon", 6023426915)
TabDungeon:CreateSection("⚔️ Dungeon Automation")
TabDungeon:CreateDropdown({Name = "Floor", Options = {"Battle1", "Battle2", "Battle3", "Battle4", "Battle5"}, CurrentOption = {"Battle1"}, Callback = function(Opt) _G.Mofenk.TargetFloor = Opt[1] end})
TabDungeon:CreateToggle({Name = "Auto Dungeon & Fight Boss", CurrentValue = false, Callback = function(V) _G.Mofenk.AutoDungeon = V end})

-- TAB 4: DEVELOPER & SPY
local TabDev = Window:CreateTab("Developer & Spy", 6023426915)
TabDev:CreateSection("📡 MOFENK NETWORK SPY TERMINAL")
TabDev:CreateToggle({
   Name = "Buka & Aktifkan Network Spy",
   CurrentValue = false,
   Callback = function(Value)
       _G.Mofenk.SpyEnabled = Value
       SpyFrame.Visible = Value
   end,
})

TabDev:CreateSection("🎵 PEMUTAR MUSIK")
local Music = Instance.new("Sound", CoreGui)
Music.SoundId = "rbxassetid://9048375035"
Music.Volume = 0.8; Music.Looped = true
TabDev:CreateButton({Name = "▶️ Putar Musik", Callback = function() Music:Play() end})
TabDev:CreateButton({Name = "⏹️ Hentikan Musik", Callback = function() Music:Stop() end})

-- ==========================================
-- 5. BACKGROUND FARMING ENGINE
-- ==========================================
local lastCollect, lastSell = os.time(), os.time()

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _G.Mofenk.AutoRoll then safeFire("RollRequest") end
            if _G.Mofenk.AutoRebirth then safeFire("RebirthRequest") end
            if _G.Mofenk.AutoClaimQuests then safeFire("ClaimAllQuests") end
            if _G.Mofenk.AutoPlaytime then safeFire("ClaimPlaytimeGift", "all") end
            if _G.Mofenk.AutoWheel then safeFire("WheelSpinRequest") end
            if _G.Mofenk.AutoRollTraits then safeFire("SpinTraitRequest") end
            
            if _G.Mofenk.AutoCollectMoney and (os.time() - lastCollect >= _G.Mofenk.CollectEvery) then
                safeFire("MoneyCollected")
                lastCollect = os.time()
            end
            
            if _G.Mofenk.AutoSell and (os.time() - lastSell >= _G.Mofenk.SellEvery) then
                safeFire("SellAllRequest")
                lastSell = os.time()
            end
            
            if _G.Mofenk.AutoDungeon then
                safeFire("RequestDungeonTeleport", _G.Mofenk.TargetFloor)
                safeFire("SetAutoFightBoss", true)
                if workspace.CurrentCamera then
                    VirtualUser:ClickButton1(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end
            end
        end)
    end
end)

-- Anti AFK
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end)
