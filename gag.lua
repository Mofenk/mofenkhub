-- [[ GROW A GARDEN (GAG) HUB - FULL SCRIPT WITH AUTO-EXECUTE ]] --
​local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
​local LocalPlayer = Players.LocalPlayer
​-- Wait for game load
if not game:IsLoaded() then
game.Loaded:Wait()
end
​-- ================= AUTO EXECUTE ON TELEPORT CONFIG ================= --
-- Masukkan URL raw script kamu di sini jika di-host di GitHub / Gist / Netlify.
getgenv().GAG_ScriptUrl = getgenv().GAG_ScriptUrl or "https://raw.githubusercontent.com/username/repo/main/gag_hub.lua"
​local function queueAutoExec()
local rawUrl = getgenv().GAG_ScriptUrl
local code = string.format('loadstring(game:HttpGet("%s"))()', rawUrl)
​local q = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
if typeof(q) == "function" then
pcall(q, code)
print("[GAG Hub] Auto-execute queued successfully for next server.")
else
print("[GAG Hub] Executor does not support queue_on_teleport.")
end
end
​-- Persiapkan auto-execute setiap kali pemain akan berpindah server
TeleportService.TeleportInitFailed:Connect(function()
print("[GAG Hub] Teleport failed.")
end)
​-- ================= UI LIBRARY INITIALIZATION ================= --
local Rayfield
do
local success, lib = pcall(function()
return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)
if success and type(lib) == "table" then
Rayfield = lib
else
error("[GAG Hub] Failed to load Rayfield UI library.", 0)
end
end
​local Window = Rayfield:CreateWindow({
Name = "Grow A Garden | Hub",
Icon = 106073659711836,
LoadingTitle = "Grow A Garden",
LoadingSubtitle = "v2.0 | Auto-Exec & Utilities",
Theme = "Default",
DisableRayfieldPrompts = true,
DisableBuildWarnings = false,
ConfigurationSaving = {
Enabled = false,
FolderName = "GAG_Hub",
FileName = "Config",
},
KeySystem = false,
})
​-- Feature State Flags
local F = {
afk = true,
autoReconnect = true,
autoHop40 = false,
autoExecOnHop = true,
wsOn = false,
wsValue = 16,
flyOn = false,
flySpeed = 50,
noclip = false,
fpsOn = false,
saveSettings = true,
spyHook = false,
}
​local CFG_FOLDER = "GAG_Hub"
local PROFILE_FOLDER = CFG_FOLDER .. "/profiles"
​local function cfgPath()
return CFG_FOLDER .. "/config_" .. tostring(LocalPlayer.UserId) .. ".json"
end
​local function saveNow()
if typeof(writefile) ~= "function" or typeof(makefolder) ~= "function" then return false end
pcall(function() makefolder(CFG_FOLDER) end)
local ok, txt = pcall(function()
return HttpService:JSONEncode({ v = 1, F = F })
end)
if ok then
pcall(function() writefile(cfgPath(), txt) end)
end
return ok
end
​-- ================= TAB SETUP ================= --
local tDash = Window:CreateTab("Dashboard", 93129522258096)
local tSpy = Window:CreateTab("Spy & Scanner", 137296756955034)
local tServer = Window:CreateTab("Server & Hop", 72821498911763)
local tSettings = Window:CreateTab("Settings", 103326255092488)
​-- ================= 1. DASHBOARD & PROFILE ================= --
tDash:CreateSection("Player Info")
tDash:CreateParagraph({
Title = "Profile Dashboard",
Content = "Username: " .. LocalPlayer.Name .. "\nDisplay Name: " .. LocalPlayer.DisplayName .. "\nUser ID: " .. tostring(LocalPlayer.UserId) .. "\nPlace ID: " .. tostring(game.PlaceId)
})
​local hopCountdownLabel = tDash:CreateParagraph({
Title = "Auto Hop Timer (40m)",
Content = "Status: Disabled"
})
​-- ================= 2. SPY & REMOTE SCANNER ================= --
tSpy:CreateSection("Remote Scanner (Console Print)")
​local function scanAndPrintRemotes()
print("\n================ [ SPY REMOTE SCANNER STARTED ] ================")
local count = 0
local servicesToScan = {
ReplicatedStorage,
game:GetService("Workspace"),
game:GetService("Players"),
game:GetService("Lighting"),
}
​for _, service in ipairs(servicesToScan) do
print("--> Scanning Service: " .. service.Name)
for _, obj in ipairs(service:GetDescendants()) do
if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
count = count + 1
print(string.format("[%s] Path: %s", obj.ClassName, obj:GetFullName()))
end
end
end
print("================ [ SCAN COMPLETE: " .. tostring(count) .. " REMOTES FOUND ] ================\n")
Rayfield:Notify({ Title = "Spy Scanner", Content = "Found " .. count .. " remotes. Check Delta/Roblox Console!", Duration = 4 })
end
​tSpy:CreateButton({
Name = "Scan All Services & Print Remotes",
Callback = function()
task.spawn(scanAndPrintRemotes)
end,
})
​tSpy:CreateSection("Remote Call Listener (Spy Hook)")
tSpy:CreateToggle({
Name = "Hook Remote Calls (Print FireServer / InvokeServer)",
CurrentValue = false,
Callback = function(v)
F.spyHook = v
if v then
Rayfield:Notify({ Title = "Spy Remote", Content = "Hook Active! Fired remotes will print to console.", Duration = 4 })
end
end,
})
​-- Namecall Hook
if hookmetamethod then
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
local method = getnamecallmethod()
if F.spyHook and (method == "FireServer" or method == "InvokeServer") then
local args = {...}
print(string.format("[SPY LOG] %s -> %s | Args: %s", self:GetFullName(), method, HttpService:JSONEncode(args)))
end
return oldNamecall(self, ...)
end)
end
​-- ================= 3. SERVER HOP (40-MIN TIMER & LIST) ================= --
tServer:CreateSection("Auto Server Hop (40 Minutes)")
​local hopTimeRemaining = 2400 -- 40 minutes
​local function hopServerFromList()
if F.autoExecOnHop then
queueAutoExec()
end
​Rayfield:Notify({ Title = "Server Hop", Content = "Searching server list...", Duration = 4 })
local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
local success, response = pcall(function() return game:HttpGet(url) end)
​if success and response then
local data = HttpService:JSONDecode(response)
if data and data.data then
for _, s in ipairs(data.data) do
if s.id ~= game.JobId and s.playing < s.maxPlayers then
Rayfield:Notify({ Title = "Server Hop", Content = "Teleporting to: " .. s.id, Duration = 4 })
TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
return
end
end
end
end
-- Fallback
TeleportService:Teleport(game.PlaceId, LocalPlayer)
end
​tServer:CreateToggle({
Name = "Enable 40-Min Auto Server Hop",
CurrentValue = false,
Callback = function(v)
F.autoHop40 = v
if v then
hopTimeRemaining = 2400
else
hopCountdownLabel:Set({ Title = "Auto Hop Timer (40m)", Content = "Status: Disabled" })
end
end,
})
​tServer:CreateToggle({
Name = "Queue Auto-Exec on Teleport",
CurrentValue = true,
Callback = function(v)
F.autoExecOnHop = v
end,
})
​tServer:CreateButton({
Name = "Hop Server Now",
Callback = function()
task.spawn(hopServerFromList)
end,
})
​tServer:CreateButton({
Name = "Rejoin Same Server",
Callback = function()
if F.autoExecOnHop then queueAutoExec() end
TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end,
})
​-- Timer Loop
task.spawn(function()
while task.wait(1) do
if F.autoHop40 then
hopTimeRemaining = hopTimeRemaining - 1
local mins = math.floor(hopTimeRemaining / 60)
local secs = hopTimeRemaining % 60
hopCountdownLabel:Set({
Title = "Auto Hop Timer (40m)",
Content = string.format("Next Hop In: %02d:%02d", mins, secs)
})
if hopTimeRemaining <= 0 then
hopTimeRemaining = 2400
hopServerFromList()
end
end
end
end)
​-- ================= 4. ANTI-AFK & AUTO RECONNECT ================= --
-- Anti-AFK
local Vu = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
if F.afk then
Vu:CaptureController()
Vu:ClickButton2(Vector2.new())
print("[GAG Hub] Anti-AFK triggered.")
end
end)
​-- Auto Reconnect
local function setupAutoReconnect()
GuiService.ErrorMessageChanged:Connect(function()
if F.autoReconnect then
local err = GuiService:GetErrorMessage()
if err and err ~= "" then
print("[GAG Hub] Disconnection detected (" .. tostring(err) .. "). Reconnecting...")
if F.autoExecOnHop then queueAutoExec() end
task.wait(2)
TeleportService:Teleport(game.PlaceId, LocalPlayer)
end
end
end)
​pcall(function()
local prompt = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
if prompt and prompt:FindFirstChild("promptOverlay") then
prompt.promptOverlay.ChildAdded:Connect(function(child)
if F.autoReconnect and child.Name == "ErrorPrompt" then
print("[GAG Hub] Prompt disconnect detected. Reconnecting...")
if F.autoExecOnHop then queueAutoExec() end
task.wait(2)
TeleportService:Teleport(game.PlaceId, LocalPlayer)
end
end)
end
end)
end
task.spawn(setupAutoReconnect)
​-- ================= 5. SETTINGS & CHARACTER ================= --
tSettings:CreateSection("Protection")
​tSettings:CreateToggle({
Name = "Anti-AFK",
CurrentValue = true,
Callback = function(v) F.afk = v end,
})
​tSettings:CreateToggle({
Name = "Auto Reconnect",
CurrentValue = true,
Callback = function(v) F.autoReconnect = v end,
})
​tSettings:CreateSection("Character Movement")
​local function applyWS()
local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
if hum then hum.WalkSpeed = F.wsOn and F.wsValue or 16 end
end
​tSettings:CreateToggle({
Name = "WalkSpeed Toggle",
CurrentValue = false,
Callback = function(v) F.wsOn = v applyWS() end,
})
​tSettings:CreateSlider({
Name = "WalkSpeed Value",
Range = {16, 250},
Increment = 1,
CurrentValue = 16,
Callback = function(v) F.wsValue = math.floor(v) applyWS() end,
})
​-- Fly Setup
local flyGyro, flyVel, flyConn, flyKeys = nil, nil, nil, {}
local function flyStop()
if flyConn then flyConn:Disconnect() flyConn = nil end
if flyGyro then flyGyro:Destroy() flyGyro = nil end
if flyVel then flyVel:Destroy() flyVel = nil end
table.clear(flyKeys)
end
​local function flyStart()
flyStop()
local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
if not hrp or not hum then return end
​hum.PlatformStand = true
flyGyro = Instance.new("BodyGyro", hrp)
flyGyro.P = 9000
flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
flyGyro.CFrame = hrp.CFrame
​flyVel = Instance.new("BodyVelocity", hrp)
flyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
flyVel.Velocity = Vector3.zero
​flyConn = RunService.RenderStepped:Connect(function()
if not F.flyOn then return end
local cam = workspace.CurrentCamera
if not cam then return end
local dir = Vector3.zero
if flyKeys[Enum.KeyCode.W] then dir = dir + cam.CFrame.LookVector end
if flyKeys[Enum.KeyCode.S] then dir = dir - cam.CFrame.LookVector end
if flyKeys[Enum.KeyCode.A] then dir = dir - cam.CFrame.RightVector end
if flyKeys[Enum.KeyCode.D] then dir = dir + cam.CFrame.RightVector end
if flyKeys[Enum.KeyCode.Space] then dir = dir + Vector3.new(0, 1, 0) end
if flyKeys[Enum.KeyCode.LeftShift] then dir = dir - Vector3.new(0, 1, 0) end
​if dir.Magnitude > 0 then dir = dir.Unit * F.flySpeed end
flyVel.Velocity = dir
flyGyro.CFrame = cam.CFrame
end)
end
​UIS.InputBegan:Connect(function(i, g)
if not g and F.flyOn then flyKeys[i.KeyCode] = true end
end)
UIS.InputEnded:Connect(function(i) flyKeys[i.KeyCode] = nil end)
​tSettings:CreateToggle({
Name = "Fly (WASD + Space/Shift)",
CurrentValue = false,
Callback = function(v)
F.flyOn = v
if v then flyStart() else flyStop() local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") if hum then hum.PlatformStand = false end end
end,
})
​tSettings:CreateSlider({
Name = "Fly Speed",
Range = {10, 200},
Increment = 5,
CurrentValue = 50,
Callback = function(v) F.flySpeed = v end,
})
​-- Noclip
RunService.Stepped:Connect(function()
if F.noclip and LocalPlayer.Character then
for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
if p:IsA("BasePart") then p.CanCollide = false end
end
end
end)
​tSettings:CreateToggle({
Name = "Noclip",
CurrentValue = false,
Callback = function(v) F.noclip = v end,
})
​-- FPS Boost
local fpsRestore = {}
local function applyFpsBoost(on)
if on then
pcall(function()
local L = game:GetService("Lighting")
table.insert(fpsRestore, { o = L, p = "GlobalShadows", v = L.GlobalShadows })
L.GlobalShadows = false
for _, o in ipairs(workspace:GetDescendants()) do
if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") then
table.insert(fpsRestore, { o = o, p = "Enabled", v = o.Enabled })
o.Enabled = false
end
end
end)
else
for _, r in ipairs(fpsRestore) do pcall(function() r.o[r.p] = r.v end) end
table.clear(fpsRestore)
end
end
​tSettings:CreateToggle({
Name = "FPS Boost",
CurrentValue = false,
Callback = function(v) F.fpsOn = v applyFpsBoost(v) end,
})
​-- ================= 6. CONFIG PRESETS ================= --
tSettings:CreateSection("Config Presets")
​local function profilePath(nm) return PROFILE_FOLDER .. "/" .. nm .. ".json" end
​local function saveProfile(nm)
if typeof(writefile) ~= "function" or typeof(makefolder) ~= "function" then return false end
pcall(function() makefolder(CFG_FOLDER) end)
pcall(function() makefolder(PROFILE_FOLDER) end)
return pcall(function() writefile(profilePath(nm), HttpService:JSONEncode({ v = 1, F = F })) end)
end
​local function listProfiles()
local out = {}
if typeof(listfiles) ~= "function" then return out end
local ok, files = pcall(function() return listfiles(PROFILE_FOLDER) end)
if ok and type(files) == "table" then
for _, f in ipairs(files) do
local nm = tostring(f):gsub("^.*[/\]", ""):gsub("%.json$", "")
if nm ~= "" then table.insert(out, nm) end
end
end
return out
end
​local cfgDrop
local cfgSelName = ""
local cfgNameInput = tSettings:CreateInput({
Name = "New Config Name",
CurrentValue = "",
PlaceholderText = "e.g. gag-preset",
RemoveTextAfterFocusLost = false,
Callback = function() end,
})
​local function refreshCfgList()
if not cfgDrop then return end
local list = listProfiles()
table.sort(list)
pcall(function() cfgDrop:Refresh(list) end)
end
​cfgDrop = tSettings:CreateDropdown({
Name = "Saved Presets",
Options = listProfiles(),
CurrentOption = {},
MultipleOptions = false,
Callback = function(sel)
cfgSelName = (type(sel) == "table") and (sel[1] or "") or (sel or "")
end,
})
​tSettings:CreateButton({
Name = "Save New Config",
Callback = function()
local nm = cfgNameInput and cfgNameInput.CurrentValue or ""
if nm == "" then Rayfield:Notify({ Title = "Config", Content = "Enter config name first.", Duration = 3 }) return end
if saveProfile(nm) then
Rayfield:Notify({ Title = "Config", Content = "Saved preset: " .. nm, Duration = 3 })
refreshCfgList()
end
end,
})
​tSettings:CreateButton({
Name = "Delete Config",
Callback = function()
if cfgSelName == "" then return end
pcall(function() delfile(profilePath(cfgSelName)) end)
cfgSelName = ""
refreshCfgList()
Rayfield:Notify({ Title = "Config", Content = "Deleted selected preset.", Duration = 3 })
end,
})
​-- Auto-Save settings loop
task.spawn(function()
while task.wait(5) do
if F.saveSettings then pcall(saveNow) end
end
end)
​Rayfield:Notify({ Title = "Grow A Garden Hub", Content = "Script & Auto-Exec ready!", Duration = 4 })
