-- =====================================================================
-- 👑 MOFENKHUB V39 — DEEP GAME DUMPER & STABLE EDITION
-- Game: Dadu Brainrot! | Fitur: Full Game Data Scraper ke File TXT
-- =====================================================================

local successUI, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not successUI or not Rayfield then
    task.wait(1)
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- ======================================================= --
-- 1. FUNGSI UTILITAS & AMAN DARI ERROR (NIL CHECK)
-- ======================================================= --
local function notifyUI(judul, pesan, durasi)
    pcall(function()
        if Rayfield and Rayfield.Notify then
            Rayfield:Notify({
                Title = judul or "👑 MofenkHub",
                Content = pesan or "",
                Duration = durasi or 3,
                Image = 4483345998,
            })
        end
    end)
end

-- Fungsi Rekursif untuk Men-dump Seluruh Isi Game ke File TXT
local function dumpFolderRecursive(parentObj, indentLevel)
    local result = ""
    indentLevel = indentLevel or 0
    local spacing = string.rep("  ", indentLevel)
    
    pcall(function()
        for _, child in ipairs(parentObj:GetChildren()) do
            result = result .. spacing .. "- " .. child.Name .. " [" .. child.ClassName .. "]\n"
            
            -- Jika berupa ModuleScript, coba baca isinya jika diizinkan
            if child:IsA("ModuleScript") then
                local success, content = pcall(function()
                    return require(child)
                end)
                if success and type(content) == "table" then
                    pcall(function()
                        result = result .. spacing .. "   [Data Table]: " .. HttpService:JSONEncode(content) .. "\n"
                    end)
                end
            end
            
            -- Lanjut ke anak level berikutnya (maksimal kedalaman agar tidak lag)
            if indentLevel < 4 and #child:GetChildren() > 0 then
                result = result .. dumpFolderRecursive(child, indentLevel + 1)
            end
        end
    end)
    
    return result
end

local function executeFullGameScan()
    notifyUI("Scanner Game", "Memulai pemindaian mendalam seluruh isi game...", 3)
    
    local fullDumpText = "========================================\n"
    fullDumpText = fullDumpText .. " MofenkHub - Deep Game Data Scraper\n"
    fullDumpText = fullDumpText .. " Game ID: " .. tostring(game.PlaceId) .. "\n"
    fullDumpText = fullDumpText .. " Waktu: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
    fullDumpText = fullDumpText .. "========================================\n\n"
    
    fullDumpText = fullDumpText .. "=== REPLICATED STORAGE STRUCTURE ===\n"
    fullDumpText = fullDumpText .. dumpFolderRecursive(ReplicatedStorage, 0)
    
    fullDumpText = fullDumpText .. "\n=== WORKSPACE STRUCTURE ===\n"
    fullDumpText = fullDumpText .. dumpFolderRecursive(Workspace, 0)
    
    pcall(function()
        if writefile then
            writefile("MofenkHub_GameDump_Full.txt", fullDumpText)
            notifyUI("Sukses", "Data game berhasil disimpan ke 'MofenkHub_GameDump_Full.txt'!", 5)
        else
            notifyUI("Gagal", "Executor tidak mendukung fungsi writefile.", 4)
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
-- 2. STATE UTAMA BOT
-- ======================================================= --
_G.Mofenk = {
    AutoCollect = false, CollectDelay = 1.0,
    AutoRoll = false, InstantRoll = false, AutoTrait = false,
    AutoSellRarity = false, SellRarities = {},
    AutoUpBrainrot = false, AutoUpDice = false, AutoRebirth = false,
    AutoDungeon = false, SelectedMap = "Sahur", AutoShop = false,
    AutoMeteor = false, AutoLuckyBlock = false,
    AutoReconnect = true, ReduceCPU = false
}

-- ======================================================= --
-- 3. ANTARMUKA RAYFIELD (ST
