-- =====================================================================
-- 👑 MOFENKHUB V1.0 — ANIME DICE EDITION (SAFE HTTP 404 FIX)
-- Game: Anime Dice | Safe Addon Loader, Live Avatar & Full Auto
-- =====================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- 1. PEMBERSIHAN UI & TOGGLE LAMA
local uiTarget = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
for _, v in pairs(uiTarget:GetChildren()) do 
    if v.Name == "MofenkHubAnimeDice" or v.Name == "Fluent" or v.Name == "MofenkToggleGui" or v.Name == "WindUI" or v.Name == "Rayfield" then 
        pcall(function() v:Destroy() end) 
    end 
end

-- 2. KONFIGURASI GLOBAL MASTER
_G.Mofenk = {
    AutoAFK = true,
    AutoExecute = true,
    AutoReconnect = true,
    
    SpyEnabled = true,
    SpyConsoleLog = true,
    
    -- Feature Toggles
    AutoRoll = false,
    AutoSellInventory = false,
    AutoClaimQuests = false,
    AutoClaimRewards = false,
    AutoCollectBalance = false,
    AutoLevelUpSlot = false,
    AutoInteractSlot = false,
    AutoEquipBest = false,
    AutoRebirth = false,
    AutoEquipUnit = false,
    AutoEquipGear = false,
    AutoFuse = false,
    AutoUseBoosts = false,
    AutoBuyDice = false,
    AutoBuyUpgrade = false,
    CodeToRedeem = "",
    
    EnableFly = false, FlySpeed = 50,
    EnableWalkSpeed = false, WalkSpeedVal = 16
}

-- 3. PATH REMOTE EVENT & FUNCTION
local Network = ReplicatedStorage:WaitForChild("Network", 5)

local RollService = Network and Network:FindFirstChild("RollService")
local SellService = Network and Network:FindFirstChild("SellService")
local QuestService = Network and Network:FindFirstChild("QuestService")
local DailyRewardService = Network and Network:FindFirstChild("DailyRewardService")
local OfflineEarningsService = Network and Network:FindFirstChild("OfflineEarningsService")
local GroupRewardService = Network and Network:FindFirstChild("GroupRewardService")
local PlotService = Network and Network:FindFirstChild("PlotService")
local DiceShopService = Network and Network:FindFirstChild("DiceShopService")
local RebirthService = Network and Network:FindFirstChild("RebirthService")
local UnitService = Network and Network:FindFirstChild("UnitService")
local GearService = Network and Network:FindFirstChild("GearService")
local FusingService = Network and Network:FindFirstChild("FusingService")
local CodesService = Network and Network:FindFirstChild("CodesService")
local BoostService = Network and Network:FindFirstChild("BoostService")

-- 4. SYSTEM SAFE LOAD (ANTI HTTP 404 ERROR)
local function SafeLoad(url)
    local success, content = pcall(function()
        return game:HttpGet(url, true)
    end)
    if success and type(content) == "string" and not content:find("404") and #content > 50 then
        local func, err = loadstring(content)
        if func then
            local execSuccess, module = pcall(func)
            if execSuccess then return module end
        end
    end
    return nil
end

local Fluent = SafeLoad("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua") 
    or SafeLoad("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua")

local SaveManager = SafeLoad("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua") 
    or SafeLoad("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/SaveManager.lua")

local InterfaceManager = SafeLoad("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua") 
    or SafeLoad("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/Addons/InterfaceManager.lua")

-- 5. AUTO EXECUTE (QUEUE ON TELEPORT)
local function ApplyQueueOnTeleport()
    if _G.Mofenk.AutoExecute then
        local queueFunc = queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or (queue_on_teleport)
        if queueFunc then
            pcall(function()
                queueFunc([[
                    repeat task.wait(1) until game:IsLoaded()
                    print("[MofenkHub] Auto Execute Triggered After Teleport!")
                ]])
            end)
        end
    end
end

-- 6. DATA SCANNER ENGINE 🔍
local function ScanGameRemotes()
    print("\n==========================================")
    print("📡 [ANIME DICE SCANNER] REPLICATEDSTORAGE & GAME REMOTES")
    print("==========================================")
    local count = 0
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            count = count + 1
            print(string.format("[%d] %s (%s) -> Path: %s", count, v.Name, v.ClassName, v:GetFullName()))
        end
    end
    print("==========================================\n")
    if Fluent then
        Fluent:Notify({
            Title = "Remote Scan Selesai! 📡",
            Content = "Ditemukan " .. count .. " Remote. Hasil lengkap dicetak ke F9 Console!",
            Duration = 5
        })
    end
end

local function ScanInventoryAndStats()
    print("\n==========================================")
    print("📦 [ANIME DICE SCANNER] PLAYER STATS & INVENTORY DATA")
    print("==========================================")
    
    if LocalPlayer:FindFirstChild("leaderstats") then
        print("--- LEADERSTATS ---")
        for _, stat in ipairs(LocalPlayer.leaderstats:GetChildren()) do
            print(stat.Name .. " (" .. stat.ClassName .. "): " .. tostring(stat.Value))
        end
    end

    print("--- BACKPACK / TOOLS ---")
    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        print("- Tool: " .. item.Name)
    end

    print("--- PLAYERGUI OBJECTS & DATA HOLDERS ---")
    for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
        print("GUI Layer: " .. gui.Name)
    end
    print("==========================================\n")
    if Fluent then
        Fluent:Notify({
            Title = "Inventory Scan Selesai! 📦",
            Content = "Data Stats & GUI dicetak ke F9 Console!",
            Duration = 5
        })
    end
end

local function ScanWorkspacePrompts()
    print("\n==========================================")
    print("🏗️ [ANIME DICE SCANNER] WORKSPACE PROXIMITY PROMPTS")
    print("==========================================")
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
            count = count + 1
            print(string.format("[%d] %s | Parent: %s | Path: %s", count, obj.ClassName, obj.Parent.Name, obj:GetFullName()))
        end
    end
    print("==========================================\n")
    if Fluent then
        Fluent:Notify({
            Title = "Prompt Scan Selesai! 🏗️",
            Content = "Ditemukan " .. count .. " Interactive Object di Workspace (Cek F9)!",
            Duration = 5
        })
    end
end

-- 7. REAL-TIME NETWORK SPY HOOK (__NAMECALL) 🕵️
local rawNamecall = getrawmetatable and getrawmetatable(game) and getrawmetatable(game).__namecall
if hookmetatable and rawNamecall then
    local oldNamecall
    oldNamecall = hookmetatable(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if _G.Mofenk.SpyEnabled and (method == "FireServer" or method == "InvokeServer") then
            task.spawn(function()
                local argStr = ""
                for i, arg in ipairs(args) do
                    argStr = argStr .. string.format("[%d]: %s (%s) | ", i, tostring(arg), typeof(arg))
                end
                
                local logMessage = string.format("[SPY DETECTED] Remote: %s | Method: %s | Args: %s", self.Name, method, argStr)
                
                if _G.Mofenk.SpyConsoleLog then
                    print(logMessage)
                end
                
                if Fluent then
                    Fluent:Notify({
                        Title = "📡 Remote: " .. self.Name,
                        Content = "Method: " .. method .. "\nArgs: " .. (argStr ~= "" and argStr or "Tanpa Argument"),
                        Duration = 3
                    })
                end
            end)
        end
        return oldNamecall(self, ...)
    end))
end

-- 8. FUNGSI LIVE DATA SCANNER
local function GetLiveProfileInfo()
    return string.format(
        "Username (USN) : %s\nDisplay Name    : %s\nUser ID         : %d\nAccount Age     : %d Hari",
        LocalPlayer.Name,
        LocalPlayer.DisplayName,
        LocalPlayer.UserId,
        LocalPlayer.AccountAge or 0
    )
end

local function GetLiveStatsInfo()
    local info = ""
    if LocalPlayer:FindFirstChild("leaderstats") then
        for _, stat in ipairs(LocalPlayer.leaderstats:GetChildren()) do
            info = info .. string.format("• %s: %s\n", stat.Name, tostring(stat.Value))
        end
    else
        info = "Memuat Leaderstats..."
    end
    return info ~= "" and info or "Tidak ada data leaderstats."
end

local function GetLiveInventoryInfo()
    local text = "--- ITEM BACKPACK ---\n"
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local children = backpack:GetChildren()
        if #children > 0 then
            for i, v in ipairs(children) do
                text = text .. string.format("[%d] %s (%s)\n", i, v.Name, v.ClassName)
            end
        else
            text = text .. "Backpack Kosong.\n"
        end
    end

    text = text .. "\n--- ITEM / TOOL EQUIPPED ---\n"
    local char = LocalPlayer.Character
    if char then
        local found = false
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") or obj:IsA("Model") and string.find(string.lower(obj.Name), "dice") then
                text = text .. "• " .. obj.Name .. " (" .. obj.ClassName .. ")\n"
                found = true
            end
        end
        if not found then text = text .. "Tidak Ada Item Di-Equip.\n" end
    end

    return text
end

-- 9. FUNGSI EKSEKUSI GAME AUTOMATION
local function TriggerAutoRoll()
    pcall(function()
        if RollService then
            if RollService:FindFirstChild("RF") and RollService.RF:FindFirstChild("RollDice") then
                RollService.RF.RollDice:InvokeServer()
            elseif RollService:FindFirstChild("RE") and RollService.RE:FindFirstChild("SetAutoRoll") then
                RollService.RE.SetAutoRoll:FireServer(true)
            end
        end
    end)
end

local function TriggerAutoSell()
    pcall(function()
        if SellService and SellService:FindFirstChild("RF") and SellService.RF:FindFirstChild("SellInventory") then
            SellService.RF.SellInventory:InvokeServer()
        end
    end)
end

local function TriggerCollectBalance()
    pcall(function()
        if PlotService and PlotService:FindFirstChild("RE") and PlotService.RE:FindFirstChild("CollectBalance") then
            PlotService.RE.CollectBalance:FireServer()
        end
    end)
end

local function TriggerLevelUpSlot()
    pcall(function()
        if PlotService and PlotService:FindFirstChild("RE") and PlotService.RE:FindFirstChild("LevelUpSlot") then
            PlotService.RE.LevelUpSlot:FireServer()
        end
    end)
end

local function TriggerInteractSlot()
    pcall(function()
        if PlotService and PlotService:FindFirstChild("RE") and PlotService.RE:FindFirstChild("InteractSlot") then
            PlotService.RE.InteractSlot:FireServer()
        end
    end)
end

local function TriggerEquipBest()
    pcall(function()
        if PlotService and PlotService:FindFirstChild("RE") and PlotService.RE:FindFirstChild("EquipBest") then
            PlotService.RE.EquipBest:FireServer()
        end
    end)
end

local function TriggerRebirth()
    pcall(function()
        if RebirthService and RebirthService:FindFirstChild("RE") and RebirthService.RE:FindFirstChild("Rebirth") then
            RebirthService.RE.Rebirth:FireServer()
        end
    end)
end

local function TriggerEquipUnit()
    pcall(function()
        if UnitService and UnitService:FindFirstChild("RF") and UnitService.RF:FindFirstChild("Equip") then
            UnitService.RF.Equip:InvokeServer()
        end
    end)
end

local function TriggerEquipGear()
    pcall(function()
        if GearService and GearService:FindFirstChild("RE") and GearService.RE:FindFirstChild("Equip") then
            GearService.RE.Equip:FireServer()
        end
    end)
end

local function TriggerFuse()
    pcall(function()
        if FusingService and FusingService:FindFirstChild("RE") and FusingService.RE:FindFirstChild("Fuse") then
            FusingService.RE.Fuse:FireServer()
        end
    end)
end

local function TriggerUseBoosts()
    pcall(function()
        if BoostService and BoostService:FindFirstChild("RE") and BoostService.RE:FindFirstChild("Use") then
            BoostService.RE.Use:FireServer()
        end
    end)
end

local function TriggerRedeemCode(codeStr)
    pcall(function()
        if CodesService and CodesService:FindFirstChild("RE") and CodesService.RE:FindFirstChild("RedeemCode") then
            CodesService.RE.RedeemCode:FireServer(codeStr)
        end
    end)
end

local function TriggerBuyDice()
    pcall(function()
        if DiceShopService and DiceShopService:FindFirstChild("RE") and DiceShopService.RE:FindFirstChild("BuyDice") then
            DiceShopService.RE.BuyDice:FireServer()
        end
    end)
end

local function TriggerBuyUpgrade()
    pcall(function()
        if Network and Network:FindFirstChild("RE") and Network.RE:FindFirstChild("BuyUpgrade") then
            Network.RE.BuyUpgrade:FireServer()
        end
    end)
end

local function TriggerAutoClaims()
    pcall(function()
        if _G.Mofenk.AutoClaimQuests and QuestService and QuestService:FindFirstChild("RE") and QuestService.RE:FindFirstChild("Claim") then
            QuestService.RE.Claim:FireServer()
        end
        if _G.Mofenk.AutoClaimRewards then
            if DailyRewardService and DailyRewardService:FindFirstChild("RE") and DailyRewardService.RE:FindFirstChild("Claim") then
                DailyRewardService.RE.Claim:FireServer()
            end
            if OfflineEarningsService and OfflineEarningsService:FindFirstChild("RE") and OfflineEarningsService.RE:FindFirstChild("Claim") then
                OfflineEarningsService.RE.Claim:FireServer()
            end
            if GroupRewardService and GroupRewardService:FindFirstChild("RE") and GroupRewardService.RE:FindFirstChild("Claim") then
                GroupRewardService.RE.Claim:FireServer()
            end
        end
    end)
end

-- 10. UTILITIES & PLAYER CONTROL
local function ToggleFlySystem(state)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    
    if state then
        if not hrp:FindFirstChild("MofenkFlyBV") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "MofenkFlyBV"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = hrp
            
            task.spawn(function()
                while _G.Mofenk.EnableFly and hrp:FindFirstChild("MofenkFlyBV") do
                    local cam = workspace.CurrentCamera
                    bv.Velocity = cam.CFrame.LookVector * _G.Mofenk.FlySpeed
                    task.wait(0.05)
                end
                if hrp:FindFirstChild("MofenkFlyBV") then hrp.MofenkFlyBV:Destroy() end
            end)
        end
    else
        if hrp:FindFirstChild("MofenkFlyBV") then hrp.MofenkFlyBV:Destroy() end
    end
end

local function CopyServerID()
    pcall(function() if setclipboard then setclipboard(tostring(game.JobId)) end end)
end

local function ServerHop()
    pcall(function()
        ApplyQueueOnTeleport()
        local servers = {}
        local req = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        if req and req.data then
            for _, s in ipairs(req.data) do
                if type(s) == "table" and s.id ~= game.JobId and s.playing < s.maxPlayers then 
                    table.insert(servers, s.id) 
                end
            end
        end
        if #servers > 0 then 
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else 
            TeleportService:Teleport(game.PlaceId, LocalPlayer) 
        end
    end)
end

-- Anti-Disconnect Reconnect
local PromptOverlay = CoreGui:FindFirstChild("PromptOverlay", true)
if PromptOverlay then
    PromptOverlay.ChildAdded:Connect(function(child)
        if _G.Mofenk.AutoReconnect and (child.Name == "ErrorPrompt" or child.Name == "DisconnectPrompt") then
            ApplyQueueOnTeleport()
            task.wait(2)
            pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
        end
    end)
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if _G.Mofenk.AutoAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

-- 11. FLUENT UI WINDOW & TABS SETUP
if not Fluent then return end

local Window = Fluent:CreateWindow({
    Title = "MofenkHub | Anime Dice 🎲",
    SubTitle = "by Mofenk",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark"
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home & Live Data", Icon = "home" }),
    Spy = Window:AddTab({ Title = "Spy & Scanner", Icon = "search" }),
    Main = Window:AddTab({ Title = "Main & Farm", Icon = "gamepad-2" }),
    Units = Window:AddTab({ Title = "Units & Gear", Icon = "sparkles" }),
    Player = Window:AddTab({ Title = "Player & Utilities", Icon = "user" }),
    Settings = Window:AddTab({ Title = "Settings & Config", Icon = "settings" })
}

-- TAB 1: HOME & LIVE DATA MONITOR
Tabs.Home:AddSection("👤 LIVE PROFIL USER")
local LiveProfilePara = Tabs.Home:AddParagraph({
    Title = "Data Profil Player",
    Content = GetLiveProfileInfo()
})

-- AVATAR HEADSHOT IMAGE
task.spawn(function()
    task.wait(0.5)
    pcall(function()
        if LiveProfilePara and LiveProfilePara.Frame then
            local avatarImg = Instance.new("ImageLabel")
            avatarImg.Name = "UserAvatarImage"
            avatarImg.Parent = LiveProfilePara.Frame
            avatarImg.Size = UDim2.new(0, 52, 0, 52)
            avatarImg.Position = UDim2.new(1, -62, 0, 8)
            avatarImg.BackgroundTransparency = 1
            avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = avatarImg
            
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(0, 170, 255)
            stroke.Thickness = 2
            stroke.Parent = avatarImg
        end
    end)
end)

Tabs.Home:AddSection("📊 LIVE PLAYER STATS & CURRENCY")
local LiveStatsPara = Tabs.Home:AddParagraph({
    Title = "Stats & Leaderstats",
    Content = GetLiveStatsInfo()
})

Tabs.Home:AddSection("📦 LIVE INVENTORY & ITEM MONITOR")
local LiveInvPara = Tabs.Home:AddParagraph({
    Title = "Inventory & Equipped Items",
    Content = GetLiveInventoryInfo()
})

-- LOOP UPDATE REALTIME
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            LiveProfilePara:SetDesc(GetLiveProfileInfo())
            LiveStatsPara:SetDesc(GetLiveStatsInfo())
            LiveInvPara:SetDesc(GetLiveInventoryInfo())
        end)
    end
end)

-- TAB 2: SPY & SCANNER
Tabs.Spy:AddSection("Real-Time Network Spy")
Tabs.Spy:AddToggle("SpyToggle", {
    Title = "Real-Time Remote Spy (Notifikasi Screen)",
    Default = true,
    Callback = function(V) _G.Mofenk.SpyEnabled = V end
})
Tabs.Spy:AddToggle("ConsoleLogToggle", {
    Title = "Cetak Detail Remote ke F9 Console",
    Default = true,
    Callback = function(V) _G.Mofenk.SpyConsoleLog = V end
})

Tabs.Spy:AddSection("Manual Data Scanner")
Tabs.Spy:AddButton({
    Title = "Scan Semua Remote Event & Function",
    Callback = function() ScanGameRemotes() end
})
Tabs.Spy:AddButton({
    Title = "Scan Inventory, Backpack & Stats",
    Callback = function() ScanInventoryAndStats() end
})
Tabs.Spy:AddButton({
    Title = "Scan Interactive ProximityPrompts",
    Callback = function() ScanWorkspacePrompts() end
})

-- TAB 3: MAIN & FARM
Tabs.Main:AddSection("Roll & Rebirth")
Tabs.Main:AddToggle("AutoRollToggle", {
    Title = "Auto Roll Dice",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoRoll = V end
})
Tabs.Main:AddToggle("AutoRebirthToggle", {
    Title = "Auto Rebirth",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoRebirth = V end
})

Tabs.Main:AddSection("Plot & Upgrades")
Tabs.Main:AddToggle("AutoCollectBalanceToggle", {
    Title = "Auto Collect Plot Balance",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoCollectBalance = V end
})
Tabs.Main:AddToggle("AutoLevelUpSlotToggle", {
    Title = "Auto Level Up Plot Slot",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoLevelUpSlot = V end
})
Tabs.Main:AddToggle("AutoInteractSlotToggle", {
    Title = "Auto Interact Plot Slot",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoInteractSlot = V end
})
Tabs.Main:AddToggle("AutoEquipBestToggle", {
    Title = "Auto Equip Best Plot Units",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoEquipBest = V end
})

Tabs.Main:AddSection("Upgrades & Shop")
Tabs.Main:AddToggle("AutoBuyDiceToggle", {
    Title = "Auto Buy Dice",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoBuyDice = V end
})
Tabs.Main:AddToggle("AutoBuyUpgradeToggle", {
    Title = "Auto Buy Upgrades",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoBuyUpgrade = V end
})

Tabs.Main:AddSection("Inventory & Sell")
Tabs.Main:AddToggle("AutoSellToggle", {
    Title = "Auto Sell Inventory",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoSellInventory = V end
})

Tabs.Main:AddSection("Quests & Claim Rewards")
Tabs.Main:AddToggle("AutoClaimQuestsToggle", {
    Title = "Auto Claim Quests",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoClaimQuests = V end
})
Tabs.Main:AddToggle("AutoClaimRewardsToggle", {
    Title = "Auto Claim Rewards (Daily, Group, Offline)",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoClaimRewards = V end
})

-- TAB 4: UNITS & GEAR
Tabs.Units:AddSection("Unit & Gear Management")
Tabs.Units:AddToggle("AutoEquipUnitToggle", {
    Title = "Auto Equip Unit",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoEquipUnit = V end
})
Tabs.Units:AddToggle("AutoEquipGearToggle", {
    Title = "Auto Equip Gear",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoEquipGear = V end
})
Tabs.Units:AddToggle("AutoFuseToggle", {
    Title = "Auto Fuse Units",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoFuse = V end
})

Tabs.Units:AddSection("Boosts & Codes")
Tabs.Units:AddToggle("AutoUseBoostsToggle", {
    Title = "Auto Use Active Boosts",
    Default = false,
    Callback = function(V) _G.Mofenk.AutoUseBoosts = V end
})
Tabs.Units:AddInput("CodeInput", {
    Title = "Kode Promo / Redeem Code",
    Default = "",
    Placeholder = "Masukkan kode di sini...",
    Numeric = false,
    Finished = false,
    Callback = function(Text) _G.Mofenk.CodeToRedeem = Text end
})
Tabs.Units:AddButton({
    Title = "Redeem Code Sekarang",
    Callback = function()
        if _G.Mofenk.CodeToRedeem ~= "" then
            TriggerRedeemCode(_G.Mofenk.CodeToRedeem)
            Fluent:Notify({ Title = "Redeem Sent! 🎁", Content = "Mencoba redeem kode: " .. _G.Mofenk.CodeToRedeem, Duration = 3 })
        end
    end
})

-- TAB 5: PLAYER & UTILITIES
Tabs.Player:AddSection("Protection & Automation")
Tabs.Player:AddToggle("AutoAFKToggle", {
    Title = "Auto AFK (Anti Idle Disconnect)",
    Default = true,
    Callback = function(V) _G.Mofenk.AutoAFK = V end
})
Tabs.Player:AddToggle("AutoExecToggle", {
    Title = "Auto Execute (Queue On Teleport)",
    Default = true,
    Callback = function(V) _G.Mofenk.AutoExecute = V end
})
Tabs.Player:AddToggle("AutoReconnToggle", {
    Title = "Auto Reconnect (Anti DC)",
    Default = true,
    Callback = function(V) _G.Mofenk.AutoReconnect = V end
})

Tabs.Player:AddSection("Movement")
Tabs.Player:AddToggle("FlyToggle", {
    Title = "Aktifkan Fly",
    Default = false,
    Callback = function(V) 
        _G.Mofenk.EnableFly = V 
        ToggleFlySystem(V)
    end
})
Tabs.Player:AddSlider("FlySpeedSlider", {
    Title = "Kecepatan Fly",
    Min = 20,
    Max = 200,
    Default = 50,
    Rounding = 0,
    Callback = function(V) _G.Mofenk.FlySpeed = V end
})
Tabs.Player:AddToggle("WalkSpeedToggle", {
    Title = "Aktifkan Custom WalkSpeed",
    Default = false,
    Callback = function(V) _G.Mofenk.EnableWalkSpeed = V end
})
Tabs.Player:AddSlider("WalkSpeedSlider", {
    Title = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Rounding = 0,
    Callback = function(V) _G.Mofenk.WalkSpeedVal = V end
})

Tabs.Player:AddSection("Server Utilities")
Tabs.Player:AddButton({
    Title = "Copy Server JobID",
    Callback = function() 
        CopyServerID()
        Fluent:Notify({ Title = "Berhasil Disalin! ✅", Content = "Job ID disalin ke clipboard.", Duration = 3 })
    end
})
Tabs.Player:AddButton({
    Title = "Server Hop",
    Callback = function() ServerHop() end
})

-- 12. SETUP CONFIG MANAGER & INTERFACE (JIKA ADDON TERSEDIA)
if SaveManager and InterfaceManager then
    pcall(function()
        SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)

        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})

        SaveManager:SetFolder("MofenkHub/AnimeDice")
        InterfaceManager:SetFolder("MofenkHub")

        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        SaveManager:BuildConfigSection(Tabs.Settings)

        SaveManager:LoadAutoloadConfig()
    end)
else
    Tabs.Settings:AddParagraph({
        Title = "Config Manager Status",
        Content = "Sistem Config offline (Aman). Semua fungsi bot utama tetap berjalan normal."
    })
end

-- 13. FLOATING LOGO TOGGLE BUTTON
local ToggleGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ToggleGui.Name = "MofenkToggleGui"
ToggleGui.Parent = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
ToggleGui.ResetOnSpawn = false

ToggleBtn.Name = "MofenkToggleBtn"
ToggleBtn.Parent = ToggleGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.4, 0)
ToggleBtn.Size = UDim2.new(0, 48, 0, 48)
ToggleBtn.Text = "🎲"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 22
ToggleBtn.Active = true
ToggleBtn.Draggable = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = ToggleBtn

ToggleBtn.MouseButton1Click:Connect(function()
    if Window then
        Window:Minimize()
    end
end)

-- 14. BACKGROUND MAIN LOOP ENGINE
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if _G.Mofenk.EnableWalkSpeed then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = _G.Mofenk.WalkSpeedVal
                end
            end

            if _G.Mofenk.AutoRoll then TriggerAutoRoll() end
            if _G.Mofenk.AutoRebirth then TriggerRebirth() end
            if _G.Mofenk.AutoCollectBalance then TriggerCollectBalance() end
            if _G.Mofenk.AutoLevelUpSlot then TriggerLevelUpSlot() end
            if _G.Mofenk.AutoInteractSlot then TriggerInteractSlot() end
            if _G.Mofenk.AutoEquipBest then TriggerEquipBest() end
            if _G.Mofenk.AutoEquipUnit then TriggerEquipUnit() end
            if _G.Mofenk.AutoEquipGear then TriggerEquipGear() end
            if _G.Mofenk.AutoFuse then TriggerFuse() end
            if _G.Mofenk.AutoUseBoosts then TriggerUseBoosts() end
            if _G.Mofenk.AutoBuyDice then TriggerBuyDice() end
            if _G.Mofenk.AutoBuyUpgrade then TriggerBuyUpgrade() end
            if _G.Mofenk.AutoSellInventory then TriggerAutoSell() end
            if _G.Mofenk.AutoClaimQuests or _G.Mofenk.AutoClaimRewards then TriggerAutoClaims() end
        end)
    end
end)
