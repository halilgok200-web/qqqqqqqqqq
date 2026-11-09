-- misc.lua
local V = getgenv().Void
local RunService, UIS, Lighting = V.Services.RunService, V.Services.UIS, V.Services.Lighting
local C = V.Config

RunService.Heartbeat:Connect(function()
    if C.RapidFire and V.rapidHeld then
        local now = tick()
        if now - V.rapidLast >= C.RapidDelay then
            V.rapidLast = now
            local x, y = V.Camera.ViewportSize.X / 2, V.Camera.ViewportSize.Y / 2
            pcall(function()
                V.ignoreUntil = tick() + 0.05
                if V.HandleWeaponFire then V.HandleWeaponFire() end
                V.Services.VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
                task.wait(0.002)
                V.Services.VIM:SendMouseButtonEvent(x, y, 0, true,  game, 1)
                task.wait(0.002)
                V.Services.VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
            end)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local head = V.LocalPlayer.Character and V.LocalPlayer.Character:FindFirstChild("Head")
    if C.HideHead and head then
        if not V.HeadCache then V.HeadCache = {Size = head.Size, Transparency = head.Transparency, CanCollide = head.CanCollide} end
        head.Transparency = 1 head.CanCollide = false head.Size = Vector3.new(0.1,0.1,0.1)
        local face = head:FindFirstChildOfClass("Decal")
        if face then face.Transparency = 1 end
    elseif not C.HideHead and V.HeadCache and head then
        head.Size = V.HeadCache.Size head.Transparency = V.HeadCache.Transparency head.CanCollide = V.HeadCache.CanCollide
        local face = head:FindFirstChildOfClass("Decal")
        if face then face.Transparency = 0 end
        V.HeadCache = nil
    end

    if C.WorldColorEnabled then
        Lighting.Ambient = C.AmbientColor Lighting.OutdoorAmbient = C.OutdoorColor Lighting.Brightness = C.Brightness
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm then atm.Color = C.SkyColor end
    end
    
    if C.FogEnabled then
        Lighting.FogColor = C.FogColor Lighting.FogStart = C.FogStart Lighting.FogEnd = C.FogEnd
    else
        Lighting.FogStart = V.OrigFogStart Lighting.FogEnd = V.OrigFogEnd
    end
end)

-- Keybinds
V.SafeConnect(UIS.InputBegan, function(input, g)
    if g then return end
    if input.KeyCode == C.Binds.Aimbot and C.Binds.Aimbot ~= Enum.KeyCode.Unknown then C.Aimbot = not C.Aimbot end
    if input.KeyCode == C.Binds.Silent and C.Binds.Silent ~= Enum.KeyCode.Unknown then C.Silent = not C.Silent end
    if input.KeyCode == C.Binds.AutoFire and C.Binds.AutoFire ~= Enum.KeyCode.Unknown then C.AutoFire = not C.AutoFire end
    if input.KeyCode == C.Binds.Spin and C.Binds.Spin ~= Enum.KeyCode.Unknown then C.Spin = not C.Spin end
    if input.KeyCode == C.Binds.ESP2D and C.Binds.ESP2D ~= Enum.KeyCode.Unknown then C.ESP2D = not C.ESP2D end
    if input.KeyCode == C.Binds.ThirdPerson and C.Binds.ThirdPerson ~= Enum.KeyCode.Unknown then C.ThirdPerson = not C.ThirdPerson end
end)

-- Watermark & Keybind List
local uiGui = Instance.new("ScreenGui")
uiGui.Name = "VoidUI"
uiGui.ResetOnSpawn = false
uiGui.Parent = game:GetService("CoreGui")

local watermarkLabel = Instance.new("TextLabel")
watermarkLabel.Parent = uiGui
watermarkLabel.Position = UDim2.new(1, -300, 0, 10)
watermarkLabel.Size = UDim2.new(0, 280, 0, 20)
watermarkLabel.BackgroundTransparency = 1
watermarkLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
watermarkLabel.Font = Enum.Font.GothamBold
watermarkLabel.TextSize = 14
watermarkLabel.TextXAlignment = Enum.TextXAlignment.Right
watermarkLabel.TextStrokeTransparency = 0.5

local keybindFrame = Instance.new("Frame")
keybindFrame.Size = UDim2.new(0, 200, 0, 150)
keybindFrame.Position = UDim2.new(0, 10, 0.5, -75)
keybindFrame.BackgroundTransparency = 1
keybindFrame.Visible = false
keybindFrame.Parent = uiGui

local keybindText = Instance.new("TextLabel")
keybindText.Size = UDim2.new(1, 0, 1, 0)
keybindText.BackgroundTransparency = 1
keybindText.TextColor3 = Color3.new(1,1,1)
keybindText.TextXAlignment = Enum.TextXAlignment.Left
keybindText.TextYAlignment = Enum.TextYAlignment.Top
keybindText.Font = Enum.Font.GothamBold
keybindText.TextSize = 14
keybindText.TextStrokeTransparency = 0.5
keybindText.Parent = keybindFrame

task.spawn(function()
    while task.wait(1) do
        local time = os.date("%H:%M:%S")
        watermarkLabel.Text = string.format("xanaxsikis | %s | %s", V.LocalPlayer.Name, time)
        if C.ShowKeybinds then
            keybindFrame.Visible = true
            local txt = "Keybinds:\n"
            for feature, key in pairs(C.Binds) do
                if typeof(key) == "EnumItem" and key ~= Enum.KeyCode.Unknown then txt = txt .. string.format("[%s] %s\n", key.Name, feature) end
            end
            keybindText.Text = txt
        else keybindFrame.Visible = false end
    end
end)

-- Custom Sound GUI
local customInputGui = Instance.new("ScreenGui")
customInputGui.Name = "CustomSoundInput"
customInputGui.ResetOnSpawn = false
customInputGui.Parent = game:GetService("CoreGui")
customInputGui.Enabled = false

local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(0, 300, 0, 110)
inputFrame.Position = UDim2.new(0.5, -150, 0.5, -55)
inputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
inputFrame.BorderSizePixel = 0
inputFrame.Parent = customInputGui

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -20, 0, 35)
inputBox.Position = UDim2.new(0, 10, 0, 10)
inputBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
inputBox.TextColor3 = Color3.new(1,1,1)
inputBox.PlaceholderText = "Örn: 123456789"
inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
inputBox.Text = ""
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 14
inputBox.Parent = inputFrame

local confirmBtn = Instance.new("TextButton")
confirmBtn.Size = UDim2.new(1, -20, 0, 35)
confirmBtn.Position = UDim2.new(0, 10, 0, 55)
confirmBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
confirmBtn.Text = "Set Sound ID"
confirmBtn.TextColor3 = Color3.new(1,1,1)
confirmBtn.Font = Enum.Font.GothamBold
confirmBtn.Parent = inputFrame

V.SafeConnect(confirmBtn.MouseButton1Click, function()
    local idText = inputBox.Text:gsub("%D", "")
    if idText ~= "" then
        C.HitSoundCustom = idText
        C.HitSoundSelected = "Custom"
        if V.UpdateHitSound then V.UpdateHitSound() end
        customInputGui.Enabled = false
    end
end)

V.OpenSoundInput = function() customInputGui.Enabled = true end