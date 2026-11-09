-- menu.lua
local V = getgenv().Void
local C = V.Config
local HttpService = V.Services.HttpService
local Library = V.Library

V.Window = Library:New({
    Name = "Deagle Duels",
    Size = Vector2.new(554, 629),
    Style = 1,
    PageAmmount = 6,
})
local Window = V.Window

-- Config System
local function SerializeValue(v)
    local t = typeof(v)
    if t == "Color3" then return {__type = "Color3", R = v.R, G = v.G, B = v.B}
    elseif t == "EnumItem" then return {__type = "EnumItem", EnumType = tostring(v.EnumType), Name = v.Name}
    elseif t == "table" then
        local n = {}
        for k, x in pairs(v) do n[tostring(k)] = SerializeValue(x) end
        return n
    end
    return v
end

local function DeserializeValue(v)
    if type(v) ~= "table" then return v end
    if v.__type == "Color3" then return Color3.new(v.R, v.G, v.B)
    elseif v.__type == "EnumItem" then
        local enumName = tostring(v.EnumType):gsub("^Enum%.", "")
        local ok, item = pcall(function() return Enum[enumName][v.Name] end)
        return ok and item or Enum.KeyCode.Unknown
    end
    local n = {}
    for k, x in pairs(v) do n[k] = DeserializeValue(x) end
    return n
end

local CONFIG_FILE = "DeagleDuels_Config.json"
local UIMap = { TPDistance = {ref = "TPDist"}, TPCamHeight = {ref = "TPHeight"}, AimSmooth = {ref = "AimSmooth", toUI = function(v) return v * 100 end} }

local function SetUI(ref, value)
    local el = V.UI_Refs[ref]
    if not el then return end
    pcall(function()
        if el.Set then el:Set(value)
        elseif el.SetValue then el:SetValue(value)
        elseif el.SetState then el:SetState(value) end
    end)
end

-- Tabs
local TabCombat   = Window:Page({Name = "Combat"})
local TabVisuals  = Window:Page({Name = "Visuals"})
local TabMovement = Window:Page({Name = "Movement"})
local TabWorld    = Window:Page({Name = "World"})
local TabMisc     = Window:Page({Name = "Misc"})
local TabConfig   = Window:Page({Name = "Config"})

-- Combat
local SecAimbot = TabCombat:Section({Name = "Aimbot", Side = "Left"})
V.UI_Refs["Aimbot"] = SecAimbot:Toggle({Name = "Enable Aimbot", Default = C.Aimbot, Callback = function(v) C.Aimbot = v end, Flag = "Aimbot"})
V.UI_Refs["TeamCheck"] = SecAimbot:Toggle({Name = "Team Check", Default = C.TeamCheck, Callback = function(v) C.TeamCheck = v end, Flag = "TeamCheck"})
V.UI_Refs["WallCheck"] = SecAimbot:Toggle({Name = "Wall Check", Default = C.WallCheck, Callback = function(v) C.WallCheck = v end, Flag = "WallCheck"})
V.UI_Refs["AimFOV"] = SecAimbot:Slider({Name = "Aim FOV", Default = C.AimFOV, Value = C.AimFOV, CurrentValue = C.AimFOV, Min = 40, Max = 400, Decimals = 1, Callback = function(v) C.AimFOV = v end, Flag = "AimFOV"})
V.UI_Refs["AimSmooth"] = SecAimbot:Slider({Name = "Aim Smooth", Default = C.AimSmooth * 100, Value = C.AimSmooth * 100, CurrentValue = C.AimSmooth * 100, Min = 5, Max = 40, Decimals = 1, Callback = function(v) C.AimSmooth = v/100 end, Flag = "AimSmooth"})

local SecSilent = TabCombat:Section({Name = "Silent Aim", Side = "Right"})
V.UI_Refs["Silent"] = SecSilent:Toggle({Name = "Enable Silent", Default = C.Silent, Callback = function(v) C.Silent = v end, Flag = "Silent"})
V.UI_Refs["SilentFOV"] = SecSilent:Slider({Name = "Silent FOV", Default = C.SilentFOV, Value = C.SilentFOV, CurrentValue = C.SilentFOV, Min = 40, Max = 400, Decimals = 1, Callback = function(v) C.SilentFOV = v end, Flag = "SilentFOV"})

local SecTrigger = TabCombat:Section({Name = "Triggerbot", Side = "Left"})
V.UI_Refs["AutoFire"] = SecTrigger:Toggle({Name = "Enable Autofire", Default = C.AutoFire, Callback = function(v) C.AutoFire = v end, Flag = "AutoFire"})
V.UI_Refs["TriggerFOV"] = SecTrigger:Slider({Name = "Trigger FOV", Default = C.TriggerFOV, Value = C.TriggerFOV, CurrentValue = C.TriggerFOV, Min = 5, Max = 100, Decimals = 1, Callback = function(v) C.TriggerFOV = v end, Flag = "TriggerFOV"})

local SecSpin = TabCombat:Section({Name = "Spinbot", Side = "Right"})
V.UI_Refs["Spin"] = SecSpin:Toggle({Name = "Enable Spinbot", Default = C.Spin, Callback = function(v) C.Spin = v end, Flag = "Spin"})
V.UI_Refs["SpinSpeed"] = SecSpin:Slider({Name = "Spin Speed", Default = C.SpinSpeed, Value = C.SpinSpeed, CurrentValue = C.SpinSpeed, Min = 5, Max = 90, Decimals = 1, Callback = function(v) C.SpinSpeed = v end, Flag = "SpinSpeed"})

-- Visuals
local SecESP2D = TabVisuals:Section({Name = "ESP 2D", Side = "Left"})
V.UI_Refs["ESP2D"] = SecESP2D:Toggle({Name = "Enable ESP 2D", Default = C.ESP2D, Callback = function(v) C.ESP2D = v end, Flag = "ESP2D"})
V.UI_Refs["ESPBox"] = SecESP2D:Toggle({Name = "Box", Default = C.ESPBox, Callback = function(v) C.ESPBox = v end, Flag = "ESPBox"})
V.UI_Refs["ESPColor"] = SecESP2D:Colorpicker({Name = "ESP Color", Default = C.ESPColor, Callback = function(color) C.ESPColor = color end, Flag = "ESPColor"})

local SecESP3D = TabVisuals:Section({Name = "ESP 3D", Side = "Right"})
V.UI_Refs["ESP3D"] = SecESP3D:Toggle({Name = "Enable ESP 3D", Default = C.ESP3D, Callback = function(v) C.ESP3D = v end, Flag = "ESP3D"})
V.UI_Refs["ESP3DColor"] = SecESP3D:Colorpicker({Name = "3D Box Color", Default = C.ESP3DColor, Callback = function(color) C.ESP3DColor = color end, Flag = "ESP3DColor"})

local SecChams = TabVisuals:Section({Name = "Chams", Side = "Left"})
V.UI_Refs["Chams"] = SecChams:Toggle({Name = "Enable Chams", Default = C.Chams, Callback = function(v) C.Chams = v end, Flag = "Chams"})
V.UI_Refs["ChamsMode"] = SecChams:Dropdown({Name = "Chams Mode", Default = C.ChamsMode, Options = {"Texture","Glow","Wireframe","Glass"}, Callback = function(v) C.ChamsMode = v end, Flag = "ChamsMode"})
V.UI_Refs["ChamsColor"] = SecChams:Colorpicker({Name = "Chams Color", Default = C.ChamsColor, Callback = function(color) C.ChamsColor = color end, Flag = "ChamsColor"})

local SecTracer = TabVisuals:Section({Name = "Bullet Tracer", Side = "Right"})
V.UI_Refs["TracerEnabled"] = SecTracer:Toggle({Name = "Enable Glow Tracer", Default = C.TracerEnabled, Callback = function(v) C.TracerEnabled = v end, Flag = "TracerEnabled"})
V.UI_Refs["TracerColor"] = SecTracer:Colorpicker({Name = "Tracer Color", Default = C.TracerColor, Callback = function(color) C.TracerColor = color end, Flag = "TracerColor"})

-- Movement
local SecMove = TabMovement:Section({Name = "Movement", Side = "Left"})
V.UI_Refs["Bunny"] = SecMove:Toggle({Name = "Bunny Hop", Default = C.Bunny, Callback = function(v) C.Bunny = v end, Flag = "Bunny"})
V.UI_Refs["AirStrafe"] = SecMove:Toggle({Name = "Air Strafe", Default = C.AirStrafe, Callback = function(v) C.AirStrafe = v end, Flag = "AirStrafe"})
V.UI_Refs["StrafeSpeed"] = SecMove:Slider({Name = "Strafe Speed", Default = C.StrafeSpeed, Value = C.StrafeSpeed, CurrentValue = C.StrafeSpeed, Min = 16, Max = 50, Decimals = 1, Callback = function(v) C.StrafeSpeed = v end, Flag = "StrafeSpeed"})
V.UI_Refs["TPWalk"] = SecMove:Toggle({Name = "TP Walk (Camera Direction)", Default = C.TPWalk, Callback = function(v) C.TPWalk = v end, Flag = "TPWalk"})

-- Misc & Config
local SecTP = TabMisc:Section({Name = "Third Person", Side = "Left"})
V.UI_Refs["ThirdPerson"] = SecTP:Toggle({Name = "Enable Third Person", Default = C.ThirdPerson, Callback = function(v) C.ThirdPerson = v end, Flag = "ThirdPerson"})
V.UI_Refs["TPDist"] = SecTP:Slider({Name = "TP Distance", Default = C.TPDistance, Value = C.TPDistance, CurrentValue = C.TPDistance, Min = 5, Max = 40, Decimals = 1, Callback = function(v) C.TPDistance = v end, Flag = "TPDist"})
V.UI_Refs["TPHeight"] = SecTP:Slider({Name = "TP Height", Default = C.TPCamHeight, Value = C.TPCamHeight, CurrentValue = C.TPCamHeight, Min = 0, Max = 10, Decimals = 1, Callback = function(v) C.TPCamHeight = v end, Flag = "TPHeight"})

local SecHitSound = TabMisc:Section({Name = "Hitsound", Side = "Right"})
V.UI_Refs["HitSoundEnabled"] = SecHitSound:Toggle({Name = "Enable Hitsound", Default = C.HitSoundEnabled, Callback = function(v) C.HitSoundEnabled = v end, Flag = "HitSoundEnabled"})
V.UI_Refs["HitSoundSelected"] = SecHitSound:Dropdown({Name = "Select Sound", Default = C.HitSoundSelected, Options = {"Neverlose", "Gamesense", "Anime Kill", "Rust Headshot", "Vine Boom", "Oof", "Custom"}, Callback = function(v) 
    C.HitSoundSelected = v
    local ids = {Neverlose = "rbxassetid://6607204501", Gamesense = "rbxassetid://5632252197", ["Anime Kill"] = "rbxassetid://8426210786", ["Rust Headshot"] = "rbxassetid://5043132644", ["Vine Boom"] = "rbxassetid://9114223696", Oof = "rbxassetid://122213233"}
    if v ~= "Custom" then C.HitSoundId = ids[v] end
    if V.UpdateHitSound then V.UpdateHitSound() end
end, Flag = "HitSoundSelected"})
V.UI_Refs["HitSoundVolume"] = SecHitSound:Slider({Name = "Volume", Default = C.HitSoundVolume, Value = C.HitSoundVolume, CurrentValue = C.HitSoundVolume, Min = 0, Max = 5, Decimals = 1, Callback = function(v) C.HitSoundVolume = v if V.UpdateHitSound then V.UpdateHitSound() end end, Flag = "HitSoundVolume"})
SecHitSound:Button({Name = "Set Custom Sound ID", Callback = function() if V.OpenSoundInput then V.OpenSoundInput() end end})

local SecBinds = TabMisc:Section({Name = "Binds", Side = "Left"})
V.UI_Refs["Bind_Aimbot"] = SecBinds:Keybind({Name = "Bind Aimbot", Default = C.Binds.Aimbot, Mode = "Toggle", Callback = function(key) C.Binds.Aimbot = key end})
V.UI_Refs["Bind_Silent"] = SecBinds:Keybind({Name = "Bind Silent", Default = C.Binds.Silent, Mode = "Toggle", Callback = function(key) C.Binds.Silent = key end})
V.UI_Refs["Bind_AutoFire"] = SecBinds:Keybind({Name = "Bind Autofire", Default = C.Binds.AutoFire, Mode = "Toggle", Callback = function(key) C.Binds.AutoFire = key end})
V.UI_Refs["Bind_Spin"] = SecBinds:Keybind({Name = "Bind Spinbot", Default = C.Binds.Spin, Mode = "Toggle", Callback = function(key) C.Binds.Spin = key end})
V.UI_Refs["Bind_ESP2D"] = SecBinds:Keybind({Name = "Bind ESP", Default = C.Binds.ESP2D, Mode = "Toggle", Callback = function(key) C.Binds.ESP2D = key end})
V.UI_Refs["Bind_ThirdPerson"] = SecBinds:Keybind({Name = "Bind Third Person", Default = C.Binds.ThirdPerson, Mode = "Toggle", Callback = function(key) C.Binds.ThirdPerson = key end})

local SecMiscOther = TabMisc:Section({Name = "Other", Side = "Right"})
V.UI_Refs["ShowKeybinds"] = SecMiscOther:Toggle({Name = "Show Keybinds List", Default = C.ShowKeybinds, Callback = function(v) C.ShowKeybinds = v end, Flag = "ShowKeybinds"})
V.UI_Refs["RapidFire"] = SecMiscOther:Toggle({Name = "Rapid Fire", Default = C.RapidFire, Callback = function(v) C.RapidFire = v end, Flag = "RapidFire"})
V.UI_Refs["HideHead"] = SecMiscOther:Toggle({Name = "Hide Head", Default = C.HideHead, Callback = function(v) C.HideHead = v end, Flag = "HideHead"})

local SecLighting = TabWorld:Section({Name = "Lighting & Colors", Side = "Left"})
V.UI_Refs["WorldColorEnabled"] = SecLighting:Toggle({Name = "Custom World Color", Default = C.WorldColorEnabled, Callback = function(v) C.WorldColorEnabled = v end, Flag = "WorldColor"})
V.UI_Refs["AmbientColor"] = SecLighting:Colorpicker({Name = "Ambient Color", Default = C.AmbientColor, Callback = function(color) C.AmbientColor = color end, Flag = "AmbientColor"})
V.UI_Refs["OutdoorColor"] = SecLighting:Colorpicker({Name = "Outdoor Color", Default = C.OutdoorColor, Callback = function(color) C.OutdoorColor = color end, Flag = "OutdoorColor"})
V.UI_Refs["SkyColor"] = SecLighting:Colorpicker({Name = "Sky Tint Color", Default = C.SkyColor, Callback = function(color) C.SkyColor = color end, Flag = "SkyColor"})
V.UI_Refs["Brightness"] = SecLighting:Slider({Name = "Brightness", Default = C.Brightness, Value = C.Brightness, CurrentValue = C.Brightness, Min = 0, Max = 5, Decimals = 1, Callback = function(v) C.Brightness = v end, Flag = "Brightness"})

local SecFog = TabWorld:Section({Name = "Custom Fog", Side = "Right"})
V.UI_Refs["FogEnabled"] = SecFog:Toggle({Name = "Enable Fog", Default = C.FogEnabled, Callback = function(v) C.FogEnabled = v end, Flag = "Fog"})
V.UI_Refs["FogColor"] = SecFog:Colorpicker({Name = "Fog Color", Default = C.FogColor, Callback = function(color) C.FogColor = color end, Flag = "FogColor"})
V.UI_Refs["FogStart"] = SecFog:Slider({Name = "Fog Start", Default = C.FogStart, Value = C.FogStart, CurrentValue = C.FogStart, Min = 0, Max = 500, Decimals = 1, Callback = function(v) C.FogStart = v end, Flag = "FogStart"})
V.UI_Refs["FogEnd"] = SecFog:Slider({Name = "Fog End", Default = C.FogEnd, Value = C.FogEnd, CurrentValue = C.FogEnd, Min = 100, Max = 5000, Decimals = 1, Callback = function(v) C.FogEnd = v end, Flag = "FogEnd"})

local SecConfig = TabConfig:Section({Name = "Configuration", Side = "Left"})
SecConfig:Button({Name = "Save Config", Callback = function()
    local ok, encoded = pcall(function() return HttpService:JSONEncode(SerializeValue(C)) end)
    if not ok then warn("Config kaydedilemedi:", encoded) return end
    local wok, err = pcall(writefile, CONFIG_FILE, encoded)
    if wok then print("Config Saved!") else warn("Config yazılamadı:", err) end
end})

SecConfig:Button({Name = "Load Config", Callback = function()
    if not isfile(CONFIG_FILE) then warn("Config dosyası bulunamadı!") return end
    local ok, decoded = pcall(function() return DeserializeValue(HttpService:JSONDecode(readfile(CONFIG_FILE))) end)
    if not ok or type(decoded) ~= "table" then warn("Config yüklenemedi. Dosya bozuk.") return end

    for k, v in pairs(decoded) do
        if k == "Binds" and type(v) == "table" then
            for bindName, key in pairs(v) do
                if C.Binds[bindName] ~= nil and typeof(key) == "EnumItem" then
                    C.Binds[bindName] = key
                    SetUI("Bind_" .. bindName, key)
                end
            end
        elseif C[k] ~= nil and typeof(C[k]) == typeof(v) then
            C[k] = v
            local map = UIMap[k]
            local ref = map and map.ref or k
            SetUI(ref, (map and map.toUI) and map.toUI(v) or v)
        end
    end
    if V.UpdateHitSound then V.UpdateHitSound() end
    print("Config Loaded!")
end)

Window:Initialize()