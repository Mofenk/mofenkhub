-- =====================================================================
-- DADU BRAINROT! ULTIMATE HUB V1.0
-- Features: Auto Roll, Auto Upgrade, Dungeon Bot, & Indo Music Profile Player
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Hapus UI lama jika ada agar tidak duplikat
if CoreGui:FindFirstChild("DaduBrainrotHub") then
    CoreGui.DaduBrainrotHub:Destroy()
end

-- ScreenGui Utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DaduBrainrotHub"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- =====================================================================
-- 1. BACKGROUND MUSIC PLAYER SYSTEM (INDONESIAN SONGS)
-- =====================================================================
local SoundFolder = Instance.new("Folder")
SoundFolder.Name = "HubMusicFolder"
SoundFolder.Parent = ScreenGui

local BackgroundMusic = Instance.new("Sound")
BackgroundMusic.Name = "BGM_Player"
-- Contoh ID Lagu Indonesia populer di Roblox (bisa diganti ID lagu lain)
-- Sialan / Sampai Jadi Debu / Melawan Restu / Kenangan Manis
BackgroundMusic.SoundId = "rbxassetid://1845773120" 
BackgroundMusic.Looped = true
BackgroundMusic.Volume = 0.5
BackgroundMusic.Parent = SoundFolder

-- List Playlist Lagu Indonesia (Roblox Audio IDs)
local Playlist = {
    {Name = "Sialan - Mahalini", ID = "rbxassetid://1845773120"},
    {Name = "Sampai Jadi Debu - Banda Neira", ID = "rbxassetid://1837424289"},
    {Name = "Evaluasi - Hindia", ID = "rbxassetid://1839245102"},
    {Name = "Hati-Hati di Jalan - Tulus", ID = "rbxassetid://1843345129"}
}
local currentSongIndex = 1

BackgroundMusic:Play()

-- =====================================================================
-- 2. MAIN UI DESIGN & LAYOUT (DARK MINIMALIST)
-- =====================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 360)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Efek Sudut Melengkung (UICorner)
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- Garis Pinggir / Border Elegan
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(80, 70, 140)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Topbar (Header)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

-- Judul Hub
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 300, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "🎲 DADU BRAINROT! | Ultimate Hub"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Tombol Close (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- =====================================================================
-- 3. SIDEBAR NAVIGATION (MENU KIRI)
-- =====================================================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 140, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = Sidebar

-- Container Halaman (Pages)
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -145, 1, -45)
Container.Position = UDim2.new(0, 145, 0, 43)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- Fungsi untuk membuat tombol Tab Menu
local function createTabButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    btn.TextSize = 12
    btn.LayoutOrder = order
    btn.Parent = Sidebar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

local tabAuto = createTabButton("Auto Farm", 1)
local tabDungeon = createTabButton("Dungeon Bot", 2)
local tabProfile = createTabButton("Profil & Musik", 3)

-- Fungsi untuk membuat Halaman Konten
local function createPage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    page.ScrollBarThickness = 4
    page.Visible = false
    page.Parent = Container

    local layout = Instance.new("UIListLayout")
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page
    return page
end

local pageAuto = createPage()
local pageDungeon = createPage()
local pageProfile = createPage()

-- Tampilkan halaman default
pageAuto.Visible = true

tabAuto.MouseButton1Click:Connect(function()
    pageAuto.Visible = true
    pageDungeon.Visible = false
    pageProfile.Visible = false
end)

tabDungeon.MouseButton1Click:Connect(function()
    pageAuto.Visible = false
    pageDungeon.Visible = true
    pageProfile.Visible = false
end)

tabProfile.MouseButton1Click:Connect(function()
    pageAuto.Visible = false
    pageDungeon.Visible = false
    pageProfile.Visible = true
end)

-- =====================================================================
-- 4. KONTEN HALAMAN 1: AUTO FARM & ROLL
-- =====================================================================
local function createToggle(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 415, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 46)
    btn.Font = Enum.Font.GothamSemibold
    btn.Text = "  " .. text .. " [OFF]"
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            btn.BackgroundColor3 = Color3.fromRGB(60, 140, 90)
            btn.Text = "  " .. text .. " [ON]"
        else
            btn.BackgroundColor3 = Color3.fromRGB(32, 32, 46)
            btn.Text = "  " .. text .. " [OFF]"
        end
        callback(active)
    end)
end

-- Implementasi Toggle Auto Roll (Memicu Remotes game Dadu Brainrot)
createToggle(pageAuto, "Auto Roll Dadu", function(state)
    getgenv().AutoRoll = state
    task.spawn(function()
        while getgenv().AutoRoll do
            pcall(function()
                -- Mengambil remote event roll jika tersedia di ReplicatedStorage
                local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
                if remotes:FindFirstChild("RollRequest") then
                    remotes.RollRequest:FireServer()
                end
            end)
            task.wait(0.5)
        end
    end)
end)

createToggle(pageAuto, "Auto Claim Rebirth Reward", function(state)
    getgenv().AutoRebirth = state
    task.spawn(function()
        while getgenv().AutoRebirth do
            pcall(function()
                local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
                if remotes:FindFirstChild("RebirthRequest") then
                    remotes.RebirthRequest:FireServer()
                end
            end)
            task.wait(2)
        end
    end)
end)

-- =====================================================================
-- 5. KONTEN HALAMAN 2: DUNGEON BOT
-- =====================================================================
createToggle(pageDungeon, "Auto Farm Dungeon (Tower / Sahur)", function(state)
    getgenv().AutoDungeon = state
    task.spawn(function()
        while getgenv().AutoDungeon do
            pcall(function()
                local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
                if remotes:FindFirstChild("DungeonRequest") then
                    remotes.DungeonRequest:FireServer("StartBattle", "Sahur")
                end
            end)
            task.wait(1)
        end
    end)
end)

-- =====================================================================
-- 6. KONTEN HALAMAN 3: PROFIL & PEMUTAR LAGU INDO
-- =====================================================================
-- Label Info Profil User
local ProfileCard = Instance.new("Frame")
ProfileCard.Size = UDim2.new(0, 415, 0, 70)
ProfileCard.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
ProfileCard.Parent = pageProfile

local PCorner = Instance.new("UICorner")
PCorner.CornerRadius = UDim.new(0, 8)
PCorner.Parent = ProfileCard

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(0, 50, 0, 50)
AvatarImg.Position = UDim2.new(0, 10, 0, 10)
AvatarImg.BackgroundTransparency = 1
AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
AvatarImg.Parent = ProfileCard

local ACorner = Instance.new("UICorner")
ACorner.CornerRadius = UDim.new(1, 0)
ACorner.Parent = AvatarImg

local NameLabel = Instance.new("TextLabel")
NameLabel.Size = UDim2.new(0, 320, 0, 25)
NameLabel.Position = UDim2.new(0, 75, 0, 12)
NameLabel.BackgroundTransparency = 1
NameLabel.Font = Enum.Font.GothamBold
NameLabel.Text = "Player: " .. LocalPlayer.Name
NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NameLabel.TextSize = 14
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.Parent = ProfileCard

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 320, 0, 20)
StatusLabel.Position = UDim2.new(0, 75, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Hub Active | Game: Dadu Brainrot!"
StatusLabel.TextColor3 = Color3.fromRGB(120, 220, 140)
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = ProfileCard

-- Panel Pemutar Musik Indonesia
local MusicPanel = Instance.new("Frame")
MusicPanel.Size = UDim2.new(0, 415, 0, 110)
MusicPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
MusicPanel.Parent = pageProfile

local MCorner = Instance.new("UICorner")
MCorner.CornerRadius = UDim.new(0, 8)
MCorner.Parent = MusicPanel

local MusicTitle = Instance.new("TextLabel")
MusicTitle.Size = UDim2.new(1, -20, 0, 30)
MusicTitle.Position = UDim2.new(0, 10, 0, 5)
MusicTitle.BackgroundTransparency = 1
MusicTitle.Font = Enum.Font.GothamBold
MusicTitle.Text = "🎵 Pemutar Musik: " .. Playlist[currentSongIndex].Name
MusicTitle.TextColor3 = Color3.fromRGB(240, 200, 100)
MusicTitle.TextSize = 12
MusicTitle.TextXAlignment = Enum.TextXAlignment.Left
MusicTitle.Parent = MusicPanel

-- Tombol Kontrol Musik (Play/Pause/Next)
local function createMusicBtn(text, posX, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 30)
    btn.Position = UDim2.new(0, posX, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Parent = MusicPanel

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.MouseButton1Click:Connect(callback)
end

createMusicBtn("Play / Pause", 10, function()
    if BackgroundMusic.IsPlaying then
        BackgroundMusic:Pause()
    else
        BackgroundMusic:Resume()
    end
end)

createMusicBtn("Ganti Lagu (Next)", 140, function()
    currentSongIndex = currentSongIndex + 1
    if currentSongIndex > #Playlist then
        currentSongIndex = 1
    end
    BackgroundMusic.SoundId = Playlist[currentSongIndex].ID
    BackgroundMusic:Play()
    MusicTitle.Text = "🎵 Pemutar Musik: " .. Playlist[currentSongIndex].Name
end)

createMusicBtn("Stop Musik", 270, function()
    BackgroundMusic:Stop()
end)

print("✅ Dadu Brainrot Hub berhasil dimuat dengan pemutar musik Indonesia!")
