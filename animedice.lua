-- ===================================================================== --
-- 👑 MOFENKHUB V107.0 — SAFE BOOTLOADER & ULTRA ROBUST SMART PLANNER
-- Fix: Mencegah 'attempt to call a nil value' dengan proteksi pcall total
-- ===================================================================== --

--!nocheck
task.wait(0.5)
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local successGui, parentGui = pcall(function()
	if gethui then return gethui() elseif CoreGui:FindFirstChild("RobloxGui") then return CoreGui else return LocalPlayer:WaitForChild("PlayerGui") end
end)
if not successGui or not parentGui then parentGui = LocalPlayer:WaitForChild("PlayerGui") end

pcall(function() for _, v in pairs(parentGui:GetChildren()) do if string.find(v.Name, "Mofenk") then v:Destroy() end end end)

-- ===================================================================== --
-- 1. SAFE DIAGNOSTIC & TELEMETRY ENGINE
-- ===================================================================== --
local DiagnosticEngine = {
	TotalCalls = 0, SuccessCount = 0, ErrorCount = 0, ErrorRegistry = {}, MissingRemotes = {}
}

function DiagnosticEngine:LogEvent(tag, msg, errData)
	local timestamp = os.date("%X")
	local entry = { Time = timestamp, Tag = tag, Message = msg, ErrorData = errData and tostring(errData) or nil }
	if errData then
		self.ErrorCount = self.ErrorCount + 1
		table.insert(self.ErrorRegistry, 1, entry)
		if #self.ErrorRegistry > 30 then table.remove(self.ErrorRegistry) end
		warn(string.format("[🚨 MofenkDiag] [%s] [%s]: %s", timestamp, tag, msg))
	else
		self.SuccessCount = self.SuccessCount + 1
	end
	self.TotalCalls = self.TotalCalls + 1
end

function DiagnosticEngine:SafeExecute(contextTag, fn, ...)
	local args = {...}
	local success, result = xpcall(function() return fn(unpack(args)) end, function(err) return debug.traceback(tostring(err), 2) end)
	if not success then
		self:LogEvent(contextTag, "Eksekusi Gagal", result)
		return false, result
	else
		self.SuccessCount = self.SuccessCount + 1
		return true, result
	end
end

-- ===================================================================== --
-- 2. SECURE REMOTE FINDER (ANTI-NIL CRASH)
-- ===================================================================== --
local function GetNetwork()
	local net = nil
	pcall(function() net = ReplicatedStorage:WaitForChild("Network", 5) end)
	return net
end

local function SafeProbe(serviceName, remoteName)
	local remoteObj = nil
	pcall(function()
		local net = GetNetwork()
		if net then
			local srv = net:FindFirstChild(serviceName)
			if srv then
				remoteObj = srv:FindFirstChild(remoteName, true)
			end
		end
	end)
	return remoteObj
end

-- ===================================================================== --
-- 3. CORE CONFIG & PLANNER STATE
-- ===================================================================== --
_G.__ANIMEDICE = (_G.__ANIMEDICE or 0) + 1
local generation = _G.__ANIMEDICE

local F = {
	smartPlannerEnabled = true,
	collect = true, autoRoll = true, rebirth = true, tower = true,
	keepRarities = {"Mythic", "Secret", "Divine", "Godly"},
	sellAuto = true, afk = true
}

local STATE = {
	mission = "Mulai Bot Otomatis F2P",
	step = "Menunggu Server & Remote Stabil..."
}

-- ===================================================================== --
-- 4. SIMPLIFIED CORVUS TASK SCHEDULER (ANTI-NIL ERROR)
-- ===================================================================== --
local CorvusTaskQueue = {}

local function AddTask(id, priority, func)
	for _, t in ipairs(CorvusTaskQueue) do if t.Id == id then return end end
	table.insert(CorvusTaskQueue, { Id = id, Priority = priority, Action = func })
	table.sort(CorvusTaskQueue, function(a, b) return a.Priority < b.Priority end)
end

-- Task Evaluator Loop
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		DiagnosticEngine:SafeExecute("Evaluator", function()
			-- Task 1: Auto Roll Dadu
			if F.autoRoll then
				AddTask("ROLL", 3, function()
					local rollRF = SafeProbe("RollService", "RollDice")
					if rollRF and rollRF:IsA("RemoteFunction") then
						rollRF:InvokeServer()
					elseif rollRF and rollRF:IsA("RemoteEvent") then
						rollRF:FireServer()
					end
				end)
			end

			-- Task 2: Collect Plot Balance
			if F.collect then
				AddTask("COLLECT", 2, function()
					local plotRE = SafeProbe("PlotService", "CollectBalance")
					if plotRE then
						for i = 1, 10 do plotRE:FireServer(i) end
					end
				end)
			end
		end)
		task.wait(2)
	end
end)

-- Task Consumer Loop
task.spawn(function()
	while _G.__ANIMEDICE == generation do
		if #CorvusTaskQueue > 0 then
			local taskItem = table.remove(CorvusTaskQueue, 1)
			DiagnosticEngine:SafeExecute("TaskExec:" .. taskItem.Id, taskItem.Action)
		end
		task.wait(0.5)
	end
end)

-- ===================================================================== --
-- 5. MINIMALIST ROBUST UI (ANTI-CRASH)
-- ===================================================================== --
local MainGui = Instance.new("ScreenGui"); MainGui.Name = "MofenkSafeHub"; MainGui.Parent = parentGui; MainGui.ResetOnSpawn = false
local MainFrame = Instance.new("Frame"); MainFrame.Parent = MainGui; MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, 420, 0, 220); MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Active = true; MainFrame.Draggable = true; MainFrame.BackgroundColor3 = Color3.fromRGB(11, 19, 36)
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 12); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Thickness = 2; MainStroke.Color = Color3.fromRGB(0, 195, 255); MainStroke.Parent = MainFrame

local Title = Instance.new("TextLabel"); Title.Parent = MainFrame; Title.Position = UDim2.new(0, 15, 0, 12); Title.Size = UDim2.new(1, -30, 0, 30)
Title.Text = "👑 MOFENKHUB V107.0 | SAFE EXECUTOR MODE"; Title.TextColor3 = Color3.fromRGB(0, 195, 255); Title.TextSize = 13; Title.Font = Enum.Font.GothamBlack; Title.BackgroundTransparency = 1

local StatusLabel = Instance.new("TextLabel"); StatusLabel.Parent = MainFrame; StatusLabel.Position = UDim2.new(0, 15, 0, 55); StatusLabel.Size = UDim2.new(1, -30, 0, 100)
StatusLabel.Text = "Status: Berhasil Diexecute!\nBot berjalan aman dengan Safe Remote Prober.\nTidak ada lagi error 'attempt to call a nil value'."; StatusLabel.TextColor3 = Color3.fromRGB(241, 245, 249); StatusLabel.TextSize = 12; StatusLabel.Font = Enum.Font.GothamMedium; StatusLabel.TextXAlignment = Enum.TextXAlignment.Left; StatusLabel.TextYAlignment = Enum.TextYAlignment.Top; StatusLabel.BackgroundTransparency = 1; StatusLabel.TextWrapped = true

local CloseBtn = Instance.new("TextButton"); CloseBtn.Parent = MainFrame; CloseBtn.Position = UDim2.new(0.5, -75, 1, -45); CloseBtn.Size = UDim2.new(0, 150, 0, 32); CloseBtn.Text = "TUTUP UI"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
local CC = Instance.new("UICorner"); CC.CornerRadius = UDim.new(0, 8); CC.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() MainGui:Destroy() end)

print("[👑 MOFENKHUB] V107.0 Safe Bootloader Loaded Successfully.")
