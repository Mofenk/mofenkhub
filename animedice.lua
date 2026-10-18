-- =====================================================================
-- 👑 MOFENKHUB V43 — DEVELOPER & SPY EDITION
-- Game: Dadu Brainrot! | UI Mandiri, Game Scanner & Remote Spy ke File
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Hapus UI lama jika ada
pcall(function()
    if CoreGui:FindFirstChild("MofenkHubV43") then
        CoreGui.MofenkHubV43:Destroy()
    end
end)

-- Konfigurasi Global
_G.Mofenk = {
    AutoCollect = false,
    AutoRoll = false,
    AutoDungeon = false,
    AutoShop = false,
    AutoEquipBest = false,
    AutoEquipSquad = false,
    AutoRebirth = false,
    AutoQuest = false,
    AutoLuckyBlock = false,
    RemoteSpy = false,
    SpyNotification = false,
    DungeonList = {"Battle1", "Battle2", "Battle3", "Battle4", "Battle5"},
    DungeonNames = {"Sahur Tower", "Orcala Tower", "Bombardiro Tower", "Spiderini Tower", "Larila Tower"},
    CurrentDungeonIndex = 1
}

local function notifyUI(judul, pesan)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = judul or "👑 MofenkHub V43",
            Text = pesan,
            Duration = 3,
        })
    end)
end

-- ======================================================= --
-- SISTEM REMOTE (ANTI-ERROR)
-- ======================================================= --
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)

local function safeFire(remoteName, ...)
    pcall(function()
        if Remotes and Remotes:FindFirstChild(remoteName) then
            local remote = Remotes[remoteName]
            if remote:IsA("RemoteEvent") then 
                remote:FireServer(...)
            elseif remote:IsA("RemoteFunction") then 
                remote:InvokeServer(...) 
            end
        end
    end)
end

-- ======================================================= --
-- GAME SCANNER & METATABLE REMOTE SPY (EXPORT TO FILE)
-- ======================================================= --

-- 1. Fungsi Scanner: Membedah isi game dan jadikan File
local function scanGameToFile()
    local dump = "=== 👑 MOFENK GAME SCANNER (DUMP) ===\n"
    dump = dump .. "Waktu Scan: " .. tostring(os.date()) .. "\n\n"
    
    dump = dump .. "--- REMOTES (Events & Functions) ---\n"
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            dump = dump .. "[" .. v.ClassName .. "] Nama: " .. v.Name .. " | Path: " .. v:GetFullName() .. "\n"
        end
    end
    
    dump = dump .. "\n--- WORKSPACE (Penting) ---\n"
    for _, v in pairs(Workspace:GetChildren()) do
        dump = dump .. "Nama: " .. v.Name .. " | Tipe: " .. v.ClassName .. "\n"
    end

    if writefile then
        local fileName = "Mofenk_GameScanner_" .. tostring(math.random(1000,9999)) .. ".txt"
        pcall(function()
            writefile(fileName, dump)
            notifyUI("✅ Scanner Selesai!", "Data disimpan sebagai: " .. fileName .. " di folder workspace eksekutor.")
        end)
    else
        notifyUI("❌ Error Eksekutor", "Eksekutor Anda tidak mendukung fitur 'writefile'.")
    end
end

-- 2. Metatable Hook untuk Remote Spy
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    
    if _G.Mofenk.RemoteSpy and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        local argsString = "None"
        pcall(function() argsString = HttpService:JSONEncode(args) end)
        
        local logData = "[SPY] " .. tostring(self.Name) .. " | Method: " .. method .. " | Args: " .. argsString .. "\n"
        
        -- Simpan ke file log menggunakan appendfile atau writefile
        if appendfile then
            pcall(function() appendfile("Mofenk_SpyLog.txt", logData) end)
        elseif writefile then
            pcall(function()
                local existData = ""
                pcall(function() existData = readfile("Mofenk_SpyLog.txt") end)
                writefile("Mofenk_SpyLog.txt", existData .. logData)
            end)
        end
        
        -- Notifikasi Live (Jika Dinyalakan)
        if _G.Mofenk.SpyNotification then
            notifyUI("👁️ SPY: " .. tostring(self.Name), "Terekam & Disimpan ke File!")
        end
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- ======================================================= --
-- UI SETUP (SAMA SEPERTI V42 DENGAN TAB BARU)
-- ======================================================= --
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "MofenkHubV43"
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)
local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "👑 MofenkHub V43 — Developer Edition"
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

local SideBar = Instance.new("Frame", MainFrame)
SideBar.Size = UDim2.new(0, 140, 1, -40)
SideBar.Position = UDim2.new(0, 0, 0, 40)
SideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
local TabList = Instance.new("UIListLayout", SideBar)
TabList.Padding = UDim.new(0, 5)

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -140, 1, -40)
ContentArea.Position = UDim2.new(0, 140, 0, 40)
ContentArea.BackgroundTransparency = 1

local Tabs = {}
local function createTab(name, icon, isFirst)
    local TabBtn = Instance.new("TextButton", SideBar)
    TabBtn.Size = UDim2.new(1, 0, 0, 40)
    TabBtn.BackgroundTransparency = isFirst and 0 or 1
    TabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.Text = " " .. icon .. " " .. name
    TabBtn.TextColor3 = isFirst and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left

    local ScrollFrame = Instance.new("ScrollingFrame", ContentArea)
    ScrollFrame.Size = UDim2.new(1, -10, 1, -10)
    ScrollFrame.Position = UDim2.new(0, 5, 0, 5)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 4
    ScrollFrame.Visible = isFirst
    local Layout = Instance.new("UIListLayout", ScrollFrame)
    Layout.Padding = UDim.new(0, 8)
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)

    Tabs[name] = {Btn = TabBtn, Frame = ScrollFrame}
    TabBtn.MouseButton1Click:Connect(function()
        for tName, data in pairs(Tabs) do
            local active = (tName == name)
            data.Btn.BackgroundTransparency = active and 0 or 1
            data.Btn.TextColor3 = active and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
            data.Frame.Visible = active
        end
    end)
    return ScrollFrame
end

local function createToggle(parent, text, configKey)
    local btn = Instance.new("TextButton", parent)
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

local function createButton(parent, text, callback, color)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 36)
    btn.BackgroundColor3 = color or Color3.fromRGB(50, 50, 70)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- TABS
local TabUtama = createTab("Utama", "🏠", true)
local TabDungeon = createTab("Dungeon", "⚔️", false)
local TabDev = createTab("Scanner & Spy", "🛠️", false)

-- KONTEN UTAMA & DUNGEON
createToggle(TabUtama, "🧲 Auto Collect Uang", "AutoCollect")
createToggle(TabUtama, "🎲 Auto Roll Dadu", "AutoRoll")
createToggle(TabUtama, "🏆 Auto Equip Best Brainrot", "AutoEquipBest")
createToggle(TabUtama, "♻️ Auto Rebirth", "AutoRebirth")
createToggle(TabUtama, "📜 Auto Claim Quests", "AutoQuest")
createToggle(TabUtama, "🎁 Auto Buka Lucky Blocks", "AutoLuckyBlock")

local DungeonSelectBtn = createButton(TabDungeon, "🎯 Target: " .. _G.Mofenk.DungeonNames[_G.Mofenk.CurrentDungeonIndex], function() end)
DungeonSelectBtn.MouseButton1Click:Connect(function()
    _G.Mofenk.CurrentDungeonIndex = _G.Mofenk.CurrentDungeonIndex + 1
    if _G.Mofenk.CurrentDungeonIndex > #_G.Mofenk.DungeonNames then _G.Mofenk.CurrentDungeonIndex = 1 end
    DungeonSelectBtn.Text = "🎯 Target: " .. _G.Mofenk.DungeonNames[_G.Mofenk.CurrentDungeonIndex]
end)
createToggle(TabDungeon, "⚔️ Auto Farm Dungeon", "AutoDungeon")
createToggle(TabDungeon, "🛍️ Auto Beli Dungeon Shop", "AutoShop")
createToggle(TabDungeon, "🛡️ Auto Equip Squad", "AutoEquipSquad")

-- KONTEN SCANNER & SPY
createButton(TabDev, "🔍 SCAN GAME KE FILE .TXT", scanGameToFile, Color3.fromRGB(180, 80, 50))
createToggle(TabDev, "👁️ Nyalakan Remote Spy", "RemoteSpy")
createToggle(TabDev, "🔔 Notifikasi Saat Spy Terekam", "SpyNotification")
createButton(TabDev, "📂 Bersihkan File Spy Log", function()
    if writefile then pcall(function() writefile("Mofenk_SpyLog.txt", "=== SPY LOG RESET ===\n") end) end
    notifyUI("Log Direset", "File Mofenk_SpyLog.txt telah dibersihkan.")
end)

-- UI Draggable
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging, dragStart, startPos = true, input.Position, MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- BACKGROUND LOOP FARMING
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
            
            if _G.Mofenk.AutoDungeon then 
                safeFire("RequestDungeonTeleport", _G.Mofenk.DungeonList[_G.Mofenk.CurrentDungeonIndex]) 
            end
        end)
    end
end)

notifyUI("V43 Dimuat!", "Tab Scanner & Spy telah ditambahkan.")
