-- aim.lua
local V = getgenv().Void
local Players, RunService, UIS, VIM, Camera = V.Services.Players, V.Services.RunService, V.Services.UIS, V.Services.VIM, V.Camera
local C = V.Config

local function alive(char)
    local h = char and char:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function hasLineOfSight(from, to, char)
    local p = RaycastParams.new()
    p.FilterDescendantsInstances = {V.LocalPlayer.Character, Camera, char, V.TracerFolder}
    p.FilterType = Enum.RaycastFilterType.Exclude
    return workspace:Raycast(from, to - from, p) == nil
end

local function getScreenCenter()
    return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end

local function closest(partName, fov, useWallCheck, customCenter)
    local best, dist = nil, fov
    local m = customCenter or getScreenCenter()
    local camPos = Camera.CFrame.Position
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == V.LocalPlayer then continue end
        local char = plr.Character
        if not alive(char) then continue end
        if C.TeamCheck and plr.Team and V.LocalPlayer.Team and plr.Team == V.LocalPlayer.Team then continue end
        
        local part = char:FindFirstChild(partName or "Head") or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end
        
        local sp, on = Camera:WorldToViewportPoint(part.Position)
        if not on or sp.Z < 0 then continue end
        
        local d = (Vector2.new(sp.X, sp.Y) - m).Magnitude
        if d < dist then
            if not useWallCheck or hasLineOfSight(camPos, part.Position, char) then
                best, dist = part, d
            end
        end
    end
    return best
end

local function safeClick()
    local now = tick()
    if now - V.lastFire < C.FireDelay then return end
    V.lastFire = now
    local x, y = getScreenCenter().X, getScreenCenter().Y
    
    pcall(function()
        V.ignoreUntil = tick() + 0.05
        if V.HandleWeaponFire then V.HandleWeaponFire() end
        VIM:SendMouseButtonEvent(x, y, 0, true,  game, 1)
        task.wait(0.015)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)
end

V.SafeConnect(UIS.InputBegan, function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.E then V.Aiming = true end
end)

V.SafeConnect(UIS.InputEnded, function(i)
    if i.KeyCode == Enum.KeyCode.E then V.Aiming = false end
end)

local isMouseLocked = function()
    return UIS.MouseBehavior == Enum.MouseBehavior.LockCenter or UIS.MouseIconEnabled == false
end

RunService:BindToRenderStep("VoidAim", Enum.RenderPriority.Camera.Value + 1, function()
    local center = getScreenCenter()
    
    if C.Aimbot and (V.Aiming or V.AimToggled) and isMouseLocked() then
        local target = closest("Head", C.AimFOV, C.WallCheck, center)
        if target then 
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), C.AimSmooth) 
        end
    end
    
    if C.Silent and isMouseLocked() then
        local target = closest("Head", C.SilentFOV, false, center)
        if target then 
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) 
        end
    end
    
    if C.AutoFire and isMouseLocked() then
        local ft = closest("Head", C.TriggerFOV, false, center)
        if ft and hasLineOfSight(Camera.CFrame.Position, ft.Position, ft.Parent) then 
            safeClick() 
        end
    end
end)