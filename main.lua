-- main.lua
if getgenv().VoidCleanup then pcall(getgenv().VoidCleanup) end

getgenv().Void = {
    Config = {},
    Services = {},
    UI_Refs = {},
    Connections = {},
    Drawings2D = {},
    Drawings3D = {},
    ChamsHighlights = {},
    Library = nil,
    Window = nil,
    TracerFolder = nil,
    HeadCache = nil,
    Aiming = false,
    AimToggled = false,
    lastFire = 0,
    rapidLast = 0,
    rapidHeld = false,
    ignoreUntil = 0
}

local V = getgenv().Void

-- Servisler
V.Services.Players = game:GetService("Players")
V.Services.RunService = game:GetService("RunService")
V.Services.UIS = game:GetService("UserInputService")
V.Services.VIM = game:GetService("VirtualInputManager")
V.Services.Lighting = game:GetService("Lighting")
V.Services.SoundService = game:GetService("SoundService")
V.Services.HttpService = game:GetService("HttpService")
V.Services.TweenService = game:GetService("TweenService")
V.Services.Debris = game:GetService("Debris")
V.LocalPlayer = V.Services.Players.LocalPlayer
V.Camera = workspace.CurrentCamera

-- Varsayılan Ayarlar
V.Config = {
    Aimbot = false, WallCheck = false, TeamCheck = false, AimFOV = 140, AimSmooth = 0.18,
    Silent = false, SilentFOV = 160,
    AutoFire = false, TriggerFOV = 15, FireDelay = 0.12,
    Spin = false, SpinSpeed = 42, SpinJitter = false, JitterAmt = 8,
    ESP2D = false, ESPBox = true, ESPName = true, ESPDist = true, ESPMax = 900, ESPColor = Color3.fromRGB(255, 55, 55),
    ESP3D = false, ESP3DColor = Color3.fromRGB(255, 55, 55),
    Chams = false, ChamsMode = "Glow", ChamsColor = Color3.fromRGB(255, 50, 50),
    Bunny = false, AirStrafe = false, StrafeSpeed = 28, TPWalk = false,
    ThirdPerson = false, TPDistance = 12, TPCamHeight = 2.5, ShowKeybinds = false,
    HideHead = false, RapidFire = false, RapidDelay = 0.05,
    WorldColorEnabled = false, AmbientColor = Color3.fromRGB(25, 25, 45), OutdoorColor = Color3.fromRGB(35, 35, 60), Brightness = 1.4,
    FogEnabled = false, FogColor = Color3.fromRGB(15, 15, 35), FogStart = 0, FogEnd = 1000,
    SkyColor = Color3.fromRGB(100, 150, 255),
    HitSoundEnabled = false, HitSoundSelected = "Neverlose", HitSoundId = "rbxassetid://6607204501", HitSoundCustom = "", HitSoundVolume = 2,
    TracerEnabled = false, TracerColor = Color3.fromRGB(0, 255, 255), TracerThickness = 0.15, TracerLifetime = 0.8,
    Binds = { Aimbot = Enum.KeyCode.Unknown, Silent = Enum.KeyCode.Unknown, AutoFire = Enum.KeyCode.Unknown, Spin = Enum.KeyCode.Unknown, ESP2D = Enum.KeyCode.Unknown, ThirdPerson = Enum.KeyCode.Unknown }
}

-- Cleanup Fonksiyonu
getgenv().VoidCleanup = function()
    for _, conn in pairs(V.Connections) do pcall(function() conn:Disconnect() end) end
    pcall(function() V.Services.RunService:UnbindFromRenderStep("VoidAim") end)
    pcall(function() V.Services.RunService:UnbindFromRenderStep("VoidESP") end)
    pcall(function() V.Services.RunService:UnbindFromRenderStep("VoidFeatures") end)
    pcall(function() game:GetService("CoreGui"):FindFirstChild("VoidUI"):Destroy() end)
    pcall(function() game:GetService("CoreGui"):FindFirstChild("CustomSoundInput"):Destroy() end)
    pcall(function() workspace:FindFirstChild("VoidTracers"):Destroy() end)
end

function V.SafeConnect(signal, func)
    local conn = signal:Connect(func)
    table.insert(V.Connections, conn)
    return conn
end

-- Kütüphaneyi Yükle
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/ro0ti/Roblox-Scripting-UI/main/GameSneeze%20Lib/GameSneeze%20Lib%20Source.lua"))()
end)
if not success then return warn("Kütüphane yüklenemedi!") end
V.Library = Library

V.TracerFolder = Instance.new("Folder")
V.TracerFolder.Name = "VoidTracers"
V.TracerFolder.Parent = workspace

V.OrigFogStart = V.Services.Lighting.FogStart
V.OrigFogEnd = V.Services.Lighting.FogEnd

-- Modülleri Yükle (GitHub Raw URL'lerini kendi repona göre değiştir)
local baseUrl = "https://raw.githubusercontent.com/halilgok200-web/qqqqqqqqqq/main/"
local modules = {"esp.lua", "aim.lua", "features.lua", "misc.lua", "menu.lua"}

for _, module in ipairs(modules) do
    local suc, err = pcall(function()
        loadstring(game:HttpGet(baseUrl .. module))()
    end)
    if not suc then warn("Modül yüklenemedi (" .. module .. "): " .. tostring(err)) end
end

print("[Deagle Duels] Tüm modüller başarıyla yüklendi!")
