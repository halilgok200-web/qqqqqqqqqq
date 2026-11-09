-- features.lua
local V = getgenv().Void
local RunService, UIS, Camera = V.Services.RunService, V.Services.UIS, V.Camera
local C = V.Config

local TweenService, Debris = V.Services.TweenService, V.Services.Debris

-- HitSound & Tracer Setup
local hitSoundObj = Instance.new("Sound")
hitSoundObj.Name = "VoidHitSound"
hitSoundObj.Volume = C.HitSoundVolume
hitSoundObj.Parent = V.Services.SoundService

V.UpdateHitSound = function()
    hitSoundObj:Stop()
    if C.HitSoundSelected == "Custom" then
        if C.HitSoundCustom ~= "" then hitSoundObj.SoundId = "rbxassetid://" .. C.HitSoundCustom end
    else
        hitSoundObj.SoundId = C.HitSoundId
    end
    hitSoundObj.Volume = C.HitSoundVolume
end
V.UpdateHitSound()

V.HandleWeaponFire = function()
    local char = V.LocalPlayer.Character
    if not char then return end

    if C.HitSoundEnabled then
        local ray = Camera:ViewportPointToRay(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {char, Camera, V.TracerFolder}
        local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
        if result and result.Instance then
            local model = result.Instance:FindFirstAncestorOfClass("Model")
            if model and V.Services.Players:GetPlayerFromCharacter(model) then
                hitSoundObj:Play()
            end
        end
    end

    if C.TracerEnabled then
        local startPos = Camera.CFrame.Position
        local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
        if rightHand then startPos = rightHand.Position end
        
        local rayOrigin = Camera.CFrame.Position
        local rayDirection = Camera.CFrame.LookVector * 1500
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {char, Camera, V.TracerFolder}
        local hitResult = workspace:Raycast(rayOrigin, rayDirection, rayParams)
        local endPos = hitResult and hitResult.Position or rayOrigin + rayDirection
        
        -- Create Tracer
        local distance = (startPos - endPos).Magnitude
        local tracerPart = Instance.new("Part")
        tracerPart.Name = "VoidTracer"
        tracerPart.Anchored = true
        tracerPart.CanCollide = false
        tracerPart.CastShadow = false
        tracerPart.Material = Enum.Material.Neon
        tracerPart.Color = C.TracerColor
        tracerPart.Size = Vector3.new(C.TracerThickness, C.TracerThickness, distance)
        tracerPart.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -distance/2)
        
        local light = Instance.new("PointLight")
        light.Color = C.TracerColor
        light.Range = 10
        light.Brightness = 5
        light.Parent = tracerPart
        tracerPart.Parent = V.TracerFolder
        
        local tweenInfo = TweenInfo.new(C.TracerLifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(tracerPart, tweenInfo, {Transparency = 1}):Play()
        TweenService:Create(light, tweenInfo, {Brightness = 0}):Play()
        Debris:AddItem(tracerPart, C.TracerLifetime)
    end
end

V.SafeConnect(UIS.InputBegan, function(input, g)
    if g or tick() < V.ignoreUntil then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        V.rapidHeld = true
        V.HandleWeaponFire()
    end
end)

V.SafeConnect(UIS.InputEnded, function(input)
    if tick() < V.ignoreUntil then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        V.rapidHeld = false
    end
end)

-- Movement
V.SafeConnect(UIS.JumpRequest, function()
    if C.Bunny then
        local hum = V.LocalPlayer.Character and V.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.FloorMaterial ~= Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function()
    if C.AirStrafe then
        local char = V.LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
                local move = hum.MoveDirection
                if move.Magnitude > 0.1 then
                    local flat = Vector3.new(move.X, 0, move.Z).Unit
                    hrp.AssemblyLinearVelocity = Vector3.new(flat.X * C.StrafeSpeed, hrp.AssemblyLinearVelocity.Y, flat.Z * C.StrafeSpeed)
                end
            end
        end
    end
end)

RunService.PreSimulation:Connect(function()
    local char = V.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or not hrp then return end
    
    if C.Spin then
        hum.AutoRotate = false
        local ang = C.SpinSpeed
        if C.SpinJitter then ang = ang + math.random(-C.JitterAmt, C.JitterAmt) end
        local pos = hrp.Position
        local _, y, _ = hrp.CFrame:ToEulerAnglesYXZ()
        hrp.CFrame = CFrame.new(pos) * CFrame.Angles(0, y + math.rad(ang), 0)
    elseif C.TPWalk then
        hum.AutoRotate = false
        local camLook = Camera.CFrame.LookVector
        local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
        if flatLook.Magnitude > 0.1 then hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + flatLook) end
    else
        hum.AutoRotate = true
    end
end)

RunService.RenderStepped:Connect(function()
    local char = V.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if C.ThirdPerson then
        V.LocalPlayer.CameraMode = Enum.CameraMode.Classic
        V.LocalPlayer.CameraMaxZoomDistance = C.TPDistance
        V.LocalPlayer.CameraMinZoomDistance = C.TPDistance
        if hum then hum.CameraOffset = Vector3.new(0, C.TPCamHeight, 0) end
    else
        V.LocalPlayer.CameraMode = Enum.CameraMode.Custom
        if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
    end
end)