-- esp.lua
local V = getgenv().Void
local Players, RunService, Camera = V.Services.Players, V.Services.RunService, V.Camera
local C = V.Config

local function alive(char)
    local h = char and char:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function AddPlayerESP(plr)
    if plr == V.LocalPlayer then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 1.4
    box.Filled = false
    box.Visible = false
    
    local name = Drawing.new("Text")
    name.Size = 13
    name.Center = true
    name.Outline = true
    name.Visible = false
    
    local dist = Drawing.new("Text")
    dist.Size = 12
    dist.Center = true
    dist.Outline = true
    dist.Visible = false
    
    V.Drawings2D[plr] = {Box = box, Name = name, Dist = dist}
    
    local lines = {}
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Visible = false
        table.insert(lines, line)
    end
    V.Drawings3D[plr] = lines
end

local function RemovePlayerESP(plr)
    if V.Drawings2D[plr] then
        V.Drawings2D[plr].Box:Remove()
        V.Drawings2D[plr].Name:Remove()
        V.Drawings2D[plr].Dist:Remove()
        V.Drawings2D[plr] = nil
    end
    if V.Drawings3D[plr] then
        for _, line in pairs(V.Drawings3D[plr]) do line:Remove() end
        V.Drawings3D[plr] = nil
    end
    if V.ChamsHighlights[plr] then
        V.ChamsHighlights[plr]:Destroy()
        V.ChamsHighlights[plr] = nil
    end
end

for _, plr in ipairs(Players:GetPlayers()) do AddPlayerESP(plr) end
V.SafeConnect(Players.PlayerAdded, AddPlayerESP)
V.SafeConnect(Players.PlayerRemoving, RemovePlayerESP)

RunService.RenderStepped:Connect(function()
    local camPos = Camera.CFrame.Position
    
    -- 2D ESP
    for plr, d in pairs(V.Drawings2D) do
        d.Box.Visible = false
        d.Name.Visible = false
        d.Dist.Visible = false

        if not C.ESP2D or not alive(plr.Character) then continue end
        
        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
        local head = plr.Character:FindFirstChild("Head")
        if not hrp or not head then continue end
        
        local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
        local bot = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
        
        if top.Z < 0 or bot.Z < 0 then continue end
        
        local distVal = (hrp.Position - camPos).Magnitude
        if distVal > C.ESPMax then continue end
        
        local h = math.abs(top.Y - bot.Y)
        local w = h * 0.55
        
        if C.ESPBox then
            d.Box.Size = Vector2.new(w,h)
            d.Box.Position = Vector2.new(top.X - w/2, top.Y)
            d.Box.Color = C.ESPColor
            d.Box.Visible = true
        end
        
        if C.ESPName then
            d.Name.Text = plr.Name
            d.Name.Position = Vector2.new(top.X, top.Y - 14)
            d.Name.Color = C.ESPColor
            d.Name.Visible = true
        end
        
        if C.ESPDist then
            d.Dist.Text = math.floor(distVal) .. "m"
            d.Dist.Position = Vector2.new(top.X, bot.Y + 2)
            d.Dist.Color = C.ESPColor
            d.Dist.Visible = true
        end
    end

    -- 3D ESP
    for plr, lines in pairs(V.Drawings3D) do
        for i = 1, 12 do lines[i].Visible = false end

        if not C.ESP3D or not alive(plr.Character) then continue end
        
        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local distVal = (hrp.Position - camPos).Magnitude
        if distVal > C.ESPMax then continue end
        
        local c = hrp.Position
        local s = Vector3.new(4, 6, 2)
        local corners = {
            c + Vector3.new(-s.X/2, s.Y/2, -s.Z/2), c + Vector3.new(s.X/2, s.Y/2, -s.Z/2),
            c + Vector3.new(s.X/2, s.Y/2, s.Z/2), c + Vector3.new(-s.X/2, s.Y/2, s.Z/2),
            c + Vector3.new(-s.X/2, -s.Y/2, -s.Z/2), c + Vector3.new(s.X/2, -s.Y/2, -s.Z/2),
            c + Vector3.new(s.X/2, -s.Y/2, s.Z/2), c + Vector3.new(-s.X/2, -s.Y/2, s.Z/2)
        }
        
        local pts = {}
        for i, v in ipairs(corners) do
            local sp, on = Camera:WorldToViewportPoint(v)
            if on then pts[i] = Vector2.new(sp.X, sp.Y) else pts[i] = nil end
        end
        
        local edges = {{1,2},{2,3},{3,4},{4,1}, {5,6},{6,7},{7,8},{8,5}, {1,5},{2,6},{3,7},{4,8}}
        for i, edge in ipairs(edges) do
            local p1, p2 = pts[edge[1]], pts[edge[2]]
            if p1 and p2 then
                lines[i].From = p1
                lines[i].To = p2
                lines[i].Color = C.ESP3DColor
                lines[i].Visible = true
            end
        end
    end
end)

-- Chams
RunService.Heartbeat:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == V.LocalPlayer or not plr.Character then continue end
        
        if C.Chams and alive(plr.Character) then
            if not V.ChamsHighlights[plr] or not V.ChamsHighlights[plr].Parent then
                if V.ChamsHighlights[plr] then V.ChamsHighlights[plr]:Destroy() end
                local h = Instance.new("Highlight")
                h.Adornee = plr.Character
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = plr.Character
                V.ChamsHighlights[plr] = h
            end
            
            local h = V.ChamsHighlights[plr]
            h.FillColor = C.ChamsColor
            h.OutlineColor = C.ChamsColor
            if C.ChamsMode == "Texture" then h.FillTransparency = 0.5; h.OutlineTransparency = 1
            elseif C.ChamsMode == "Glow" then h.FillTransparency = 0; h.OutlineTransparency = 0
            elseif C.ChamsMode == "Wireframe" then h.FillTransparency = 1; h.OutlineTransparency = 0
            elseif C.ChamsMode == "Glass" then h.FillTransparency = 0.8; h.OutlineTransparency = 0.5 end
        else
            if V.ChamsHighlights[plr] then 
                V.ChamsHighlights[plr]:Destroy()
                V.ChamsHighlights[plr] = nil 
            end
        end
    end
end)