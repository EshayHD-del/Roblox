--=====================================================================
-- DA HILLS .VIP – FINAL FIX | FLY 100% CLEAN
--=====================================================================
local repo =
    'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager =
    loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Da Hills .vip',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2,
})

local Tabs = {
    Main = Window:AddTab('Main'),
    ESP = Window:AddTab('ESP'),
    Troll = Window:AddTab('Troll'),
    Shop = Window:AddTab('Shop'),
    Misc = Window:AddTab('Misc'),
    Settings = Window:AddTab('Settings'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

--=====================================================================
-- SERVICES
--=====================================================================
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local UserInputService = game:GetService('UserInputService')
local Workspace = game:GetService('Workspace')
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--=====================================================================
-- [1] SILENT AIM – C = TOGGLE + NAME NOTIFY
--=====================================================================
local mainGB = Tabs.Main:AddLeftGroupbox('Aimbot')
local SA = { Enabled = false, FOV = 300, Part = 'Head', Prediction = 0.135 }
local LockTarget = nil

mainGB:AddToggle('SA_On', { Text = 'Silent Aim' }):OnChanged(function(v)
    SA.Enabled = v
    if not v then
        LockTarget = nil
    end
    Library:Notify(
        v and 'Silent Aim ON – Press C to Lock' or 'Silent Aim OFF',
        2
    )
end)

mainGB
    :AddDropdown('SA_Part', {
        Values = { 'Head', 'HumanoidRootPart' },
        Default = 1,
        Text = 'Target Part',
    })
    :OnChanged(function(v)
        SA.Part = v
    end)
mainGB
    :AddSlider(
        'SA_FOV',
        { Text = 'FOV', Default = 300, Min = 50, Max = 1000, Rounding = 0 }
    )
    :OnChanged(function(v)
        SA.FOV = v
    end)
mainGB
    :AddSlider('SA_Pred', {
        Text = 'Prediction',
        Default = 0.135,
        Min = 0.1,
        Max = 0.2,
        Rounding = 3,
    })
    :OnChanged(function(v)
        SA.Prediction = v
    end)

-- FOV CIRCLE
local fov = Drawing.new('Circle')
fov.Thickness = 2
fov.NumSides = 100
fov.Filled = false
fov.Color = Color3.fromRGB(0, 255, 255)
fov.Transparency = 0.8
fov.Visible = false

local function MousePos()
    return UserInputService:GetMouseLocation()
end

local function FindTarget()
    local best, bestDist = nil, SA.FOV
    local mPos = MousePos()
    for _, plr in Players:GetPlayers() do
        if plr == LocalPlayer then
            continue
        end
        local char = plr.Character
        if
            not char
            or not char:FindFirstChild('Humanoid')
            or char.Humanoid.Health <= 0
        then
            continue
        end
        local part = char:FindFirstChild(SA.Part)
        if not part then
            continue
        end
        local scr, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then
            continue
        end
        local dist = (Vector2.new(scr.X, scr.Y) - mPos).Magnitude
        if dist < bestDist then
            bestDist = dist
            best = { Player = plr, Part = part }
        end
    end
    return best
end

--=====================================================================
-- [2] CAMLOCK – C = TOGGLE + NAME NOTIFY
--=====================================================================
local camGB = Tabs.Main:AddRightGroupbox('Camlock')
local Cam = { Enabled = false, Target = nil, Prediction = 0.176, Part = 'Head' }

camGB:AddToggle('Cam_On', { Text = 'Camlock (C)' }):OnChanged(function(v)
    Cam.Enabled = v
    if not v then
        Cam.Target = nil
    end
    Library:Notify(v and 'Camlock ON – Press C to Lock' or 'Camlock OFF', 2)
end)
camGB
    :AddDropdown(
        'Cam_Part',
        { Values = { 'Head', 'HumanoidRootPart' }, Default = 1, Text = 'Part' }
    )
    :OnChanged(function(v)
        Cam.Part = v
    end)

--=====================================================================
-- SINGLE C KEY HANDLER
--=====================================================================
UserInputService.InputBegan:Connect(function(i, g)
    if g or i.KeyCode ~= Enum.KeyCode.C then
        return
    end

    if Cam.Enabled then
        if Cam.Target then
            Library:Notify('Camlock UNLOCKED', 2)
            Cam.Target = nil
        else
            local closest = nil
            local dist = math.huge
            local center = Vector2.new(
                Camera.ViewportSize.X / 2,
                Camera.ViewportSize.Y / 2
            )
            for _, plr in Players:GetPlayers() do
                if plr == LocalPlayer then
                    continue
                end
                local char = plr.Character
                if
                    not char
                    or not char:FindFirstChild('Humanoid')
                    or char.Humanoid.Health <= 0
                then
                    continue
                end
                local part = char:FindFirstChild(Cam.Part)
                    or char:FindFirstChild('HumanoidRootPart')
                if not part then
                    continue
                end
                local pos, on = Camera:WorldToViewportPoint(part.Position)
                if not on then
                    continue
                end
                local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if d < dist then
                    dist = d
                    closest = { Player = plr, Part = part }
                end
            end
            if closest then
                Cam.Target = closest.Part
                Library:Notify('Camlocked: ' .. closest.Player.DisplayName, 2)
            else
                Library:Notify('No Camlock Target', 2)
            end
        end
        return
    end

    if SA.Enabled then
        if LockTarget and LockTarget.Player.Character then
            Library:Notify('Aimlock UNLOCKED', 2)
            LockTarget = nil
        else
            LockTarget = FindTarget()
            if LockTarget then
                Library:Notify(
                    'Aimlocked: ' .. LockTarget.Player.DisplayName,
                    2
                )
            else
                Library:Notify('No Target in FOV', 2)
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if Cam.Enabled and Cam.Target and Cam.Target.Parent then
        local vel = Cam.Target.Velocity or Vector3.new()
        Camera.CFrame = CFrame.new(
            Camera.CFrame.Position,
            Cam.Target.Position + (vel * Cam.Prediction)
        )
    end
end)

RunService.RenderStepped:Connect(function()
    if not SA.Enabled then
        fov.Visible = false
        return
    end
    fov.Radius = SA.FOV
    fov.Position = MousePos()
    fov.Visible = true
end)

--=====================================================================
-- [3] SILENT AIM HOOK – FIXED
--=====================================================================
local RS = game:GetService('ReplicatedStorage')
local ShootRemote = RS:FindFirstChild('Events')
    and RS.Events:FindFirstChild('Shoot')

if ShootRemote then
    local old = ShootRemote.FireServer
    hookfunction(
        old,
        function(
            self,
            origin,
            direction,
            gunName,
            ammo,
            spread,
            bulletCount,
            ...
        )
            if not (SA.Enabled and LockTarget and LockTarget.Part) then
                return old(
                    self,
                    origin,
                    direction,
                    gunName,
                    ammo,
                    spread,
                    bulletCount,
                    ...
                )
            end

            local char = LockTarget.Player.Character
            local hum = char and char:FindFirstChild('Humanoid')
            local part = char and char:FindFirstChild(SA.Part)
            if not char or not hum or hum.Health <= 0 or not part then
                Library:Notify('Target Dead – Auto Unlocked', 1.5)
                LockTarget = nil
                return old(
                    self,
                    origin,
                    direction,
                    gunName,
                    ammo,
                    spread,
                    bulletCount,
                    ...
                )
            end

            local gun = LocalPlayer.Character
                and LocalPlayer.Character:FindFirstChildWhichIsA('Tool')
            if not gun then
                return old(
                    self,
                    origin,
                    direction,
                    gunName,
                    ammo,
                    spread,
                    bulletCount,
                    ...
                )
            end

            local muzzle = gun:FindFirstChild('Muzzle')
                or gun:FindFirstChild('Handle')
            if not muzzle then
                return old(
                    self,
                    origin,
                    direction,
                    gunName,
                    ammo,
                    spread,
                    bulletCount,
                    ...
                )
            end

            local velocity = part.AssemblyLinearVelocity or Vector3.new()
            local predicted = part.Position + (velocity * SA.Prediction)
            local newDir = (predicted - muzzle.Position).Unit * 1000

            return old(self, muzzle.Position, newDir, gunName, ammo, 0, 1, ...)
        end
    )
    Library:Notify('SILENT AIM READY – HEADSHOTS ONLY', 4)
else
    Library:Notify('ERROR: Shoot remote not found!', 6)
end

--=====================================================================
-- [4] ESP
--=====================================================================
local espGB = Tabs.ESP:AddLeftGroupbox('ESP')
local Sense = nil

local function LoadSense()
    if Sense then
        return
    end
    Sense = loadstring(game:HttpGet('https://sirius.menu/sense'))()
    Sense.teamSettings.enemy.enabled = true
    Sense.teamSettings.enemy.box = true
    Sense.teamSettings.enemy.boxColor[1] = Color3.new(0, 0.25, 0.75)
    Sense.Load()
    Library:Notify('Sense ESP Loaded')
end

local function UnloadSense()
    if not Sense then
        return
    end
    Sense.Unload()
    Sense = nil
    Library:Notify('Sense ESP Unloaded')
end

espGB
    :AddToggle('SenseESPToggle', { Text = 'Enable ESP', Default = false })
    :OnChanged(function(v)
        if v then
            LoadSense()
        else
            UnloadSense()
        end
    end)

local colorLabel = espGB:AddLabel('Box Color')
local colorPicker = colorLabel:AddColorPicker(
    'SenseColor',
    { Default = Color3.new(0, 0.25, 0.75) }
)
Options.SenseColor:OnChanged(function(c)
    if Sense then
        Sense.teamSettings.enemy.boxColor[1] = c
    end
end)

--=====================================================================
-- [5] TROLL – FLING + TELEPORT
--=====================================================================
local trollGB = Tabs.Troll:AddLeftGroupbox('Troll')
local flingTarget, tpTarget = nil, nil
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

local function SkidFling(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass('Humanoid')
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then
        return
    end
    local THumanoid = TCharacter:FindFirstChildOfClass('Humanoid')
    local TRootPart = THumanoid and THumanoid.RootPart
    local THead = TCharacter:FindFirstChild('Head')
    local Handle = TCharacter:FindFirstChildOfClass('Accessory')
        and TCharacter:FindFirstChildOfClass('Accessory')
            :FindFirstChild('Handle')
    if not (Character and Humanoid and RootPart) then
        return
    end
    if RootPart.Velocity.Magnitude < 50 then
        getgenv().OldPos = RootPart.CFrame
    end
    if THumanoid and THumanoid.Sit then
        Library:Notify(TargetPlayer.Name .. ' is sitting')
        return
    end
    local subject = THead or Handle or THumanoid
    if subject then
        workspace.CurrentCamera.CameraSubject = subject
    end
    local FPos = function(BasePart, Pos, Ang)
        RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
        Character:SetPrimaryPartCFrame(
            CFrame.new(BasePart.Position) * Pos * Ang
        )
        RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end
    local SFBasePart = function(BasePart)
        local TimeToWait = 2
        local Time = tick()
        local Angle = 0
        repeat
            if RootPart and THumanoid then
                if BasePart.Velocity.Magnitude < 50 then
                    Angle = Angle + 100
                    FPos(
                        BasePart,
                        CFrame.new(0, 1.5, 0)
                            + THumanoid.MoveDirection
                                * BasePart.Velocity.Magnitude
                                / 1.25,
                        CFrame.Angles(math.rad(Angle), 0, 0)
                    )
                    task.wait()
                    FPos(
                        BasePart,
                        CFrame.new(0, -1.5, 0)
                            + THumanoid.MoveDirection
                                * BasePart.Velocity.Magnitude
                                / 1.25,
                        CFrame.Angles(math.rad(Angle), 0, 0)
                    )
                    task.wait()
                else
                    FPos(
                        BasePart,
                        CFrame.new(0, 1.5, THumanoid.WalkSpeed),
                        CFrame.Angles(math.rad(90), 0, 0)
                    )
                    task.wait()
                    FPos(
                        BasePart,
                        CFrame.new(0, -1.5, -THumanoid.WalkSpeed),
                        CFrame.Angles(0, 0, 0)
                    )
                    task.wait()
                end
            end
        until Time + TimeToWait < tick()
    end
    workspace.FallenPartsDestroyHeight = 0 / 0
    local BV = Instance.new('BodyVelocity')
    BV.Parent = RootPart
    BV.Velocity = Vector3.new(0, 0, 0)
    BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    local targetPart = TRootPart or THead or Handle
    if targetPart then
        SFBasePart(targetPart)
    else
        Library:Notify('No valid part')
        BV:Destroy()
        return
    end
    BV:Destroy()
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = Humanoid
    if getgenv().OldPos then
        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
            Character:SetPrimaryPartCFrame(
                getgenv().OldPos * CFrame.new(0, 0.5, 0)
            )
            Humanoid:ChangeState('GettingUp')
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    end
end

local function refreshTrollDropdowns()
    local names = {}
    for _, p in Players:GetPlayers() do
        if p ~= LocalPlayer and p.Character then
            table.insert(names, p.Name)
        end
    end
    table.sort(names)
    if Options.FlingDrop then
        Options.FlingDrop:SetValues(names)
    end
    if Options.TPDrop then
        Options.TPDrop:SetValues(names)
    end
end

Options.FlingDrop = trollGB:AddDropdown(
    'FlingDrop',
    { Values = {}, Default = 1, Text = 'Fling Target' }
)
Options.TPDrop = trollGB:AddDropdown(
    'TPDrop',
    { Values = {}, Default = 1, Text = 'Teleport Target' }
)
Options.FlingDrop:OnChanged(function(v)
    flingTarget = v
end)
Options.TPDrop:OnChanged(function(v)
    tpTarget = v
end)
refreshTrollDropdowns()
Players.PlayerAdded:Connect(function(p)
    task.wait(1)
    refreshTrollDropdowns()
end)
Players.PlayerRemoving:Connect(refreshTrollDropdowns)

trollGB:AddButton('Fling!', function()
    if not flingTarget then
        return Library:Notify('Select player!')
    end
    local t = Players:FindFirstChild(flingTarget)
    if t then
        SkidFling(t)
        Library:Notify(flingTarget .. ' FLUNG!')
    end
end)

trollGB:AddButton('Teleport To', function()
    if not tpTarget then
        return Library:Notify('Select player!')
    end
    local t = Players:FindFirstChild(tpTarget)
    if t and t.Character and t.Character:FindFirstChild('HumanoidRootPart') then
        local hrp = LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
        if hrp then
            hrp.CFrame = t.Character.HumanoidRootPart.CFrame
                * CFrame.new(0, 0, -3)
        end
        Library:Notify('Teleported to ' .. tpTarget)
    end
end)

--=====================================================================
-- [6] SHOP – FIXED CFrame
--=====================================================================
local shopGB = Tabs.Shop:AddLeftGroupbox('Shop')
local foodGB = Tabs.Shop:AddRightGroupbox('Food')

local function getPartCFrame(part)
    if part:IsA('Model') then
        return part.PrimaryPart and part.PrimaryPart.CFrame
            or (part:FindFirstChild('Handle') and part.Handle.CFrame)
            or part:GetPivot()
    end
    return part.CFrame
end

local function buyIndex(index, name)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild('HumanoidRootPart')
    if not hrp then
        return
    end
    local old = hrp.CFrame
    local ignored = Workspace:FindFirstChild('Ignored')
    if not ignored or not ignored:FindFirstChild('Shop') then
        return
    end
    local shopItems = ignored.Shop:GetChildren()
    local stand = shopItems[index]
    if stand and stand:FindFirstChildOfClass('ClickDetector') then
        local cf = getPartCFrame(stand)
        hrp.CFrame = cf * CFrame.new(0, 0, -3)
        task.wait(0.15)
        fireclickdetector(stand:FindFirstChildOfClass('ClickDetector'))
        task.wait(0.3)
        hrp.CFrame = old
        Library:Notify(name .. ' Bought!')
    end
end

shopGB:AddButton('Glock 19', function()
    buyIndex(1, 'Glock 19')
end)
shopGB:AddButton('P90', function()
    buyIndex(10, 'P90')
end)
shopGB:AddButton('Assault Rifle', function()
    buyIndex(22, 'Assault Rifle')
end)
shopGB:AddButton('Glock Suppressed', function()
    buyIndex(24, 'Glock Suppressed')
end)
shopGB:AddButton('SMG', function()
    buyIndex(30, 'SMG')
end)
shopGB:AddButton('Full Armor', function()
    buyIndex(34, 'Full Armor')
end)
shopGB:AddButton('Sniper', function()
    buyIndex(49, 'Sniper')
end)
shopGB:AddButton('SCAR', function()
    buyIndex(50, 'SCAR')
end)
shopGB:AddButton('AUG', function()
    buyIndex(51, 'AUG')
end)
shopGB:AddButton('Drum Gun', function()
    buyIndex(8, 'Drum Gun')
end)
shopGB:AddButton('Tactical Shotgun', function()
    buyIndex(15, 'Tactical Shotgun')
end)

foodGB:AddButton('Starblox Latte', function()
    buyIndex(4, 'Latte')
end)
foodGB:AddButton('Ice Cream', function()
    buyIndex(5, 'Ice Cream')
end)
foodGB:AddButton('Popcorn', function()
    buyIndex(6, 'Popcorn')
end)
foodGB:AddButton('Cranberry', function()
    buyIndex(11, 'Cranberry')
end)
foodGB:AddButton('Taco', function()
    buyIndex(14, 'Taco')
end)
foodGB:AddButton('Donut', function()
    buyIndex(20, 'Donut')
end)
foodGB:AddButton('Hamburger', function()
    buyIndex(26, 'Burger')
end)
foodGB:AddButton('HotDog', function()
    buyIndex(46, 'HotDog')
end)

--=====================================================================
-- [7] MISC – FLY FINAL | 100% ERROR-FREE
--=====================================================================
local miscGB = Tabs.Misc:AddLeftGroupbox('Misc')
local CFrameSpeedMaster = false
local CFrameSpeedActive = false
local CFrameSpeedKey = Enum.KeyCode.V
local CFrameSpeedValue = 1

local flyEnabled = false
local bodyVelocity = nil
local FlyKey = Enum.KeyCode.X
local FlySpeed = 50

-- CREATE TOGGLE AND KEEP REFERENCE
local FlyToggle =
    miscGB:AddToggle('FlyToggle', { Text = 'Fly', Default = false })

-- KEYBIND
miscGB
    :AddDropdown(
        'FlyKeybind',
        {
            Values = { 'X', 'V', 'C', 'Z', 'Q' },
            Default = 1,
            Text = 'Fly Keybind',
        }
    )
    :OnChanged(function(v)
        FlyKey = Enum.KeyCode[v]
        Library:Notify('Fly keybind: ' .. v)
    end)

miscGB
    :AddSlider(
        'FlySpeedSlider',
        { Text = 'Fly Speed', Default = 50, Min = 10, Max = 200, Rounding = 0 }
    )
    :OnChanged(function(v)
        FlySpeed = v
    end)

-- CFrame SPEED
miscGB
    :AddToggle('CFrameSpeedToggle', { Text = 'CFrame Speed', Default = false })
    :OnChanged(function(v)
        CFrameSpeedMaster = v
        if not v then
            CFrameSpeedActive = false
        end
    end)

miscGB
    :AddDropdown(
        'CFrameSpeedKeybind',
        { Values = { 'V', 'C', 'X', 'Z', 'Q' }, Default = 1, Text = 'Keybind' }
    )
    :OnChanged(function(v)
        CFrameSpeedKey = Enum.KeyCode[v]
        Library:Notify('CFrame Speed keybind: ' .. v)
    end)

miscGB
    :AddSlider(
        'CFrameSpeedSlider',
        { Text = 'Speed', Default = 1, Min = 1, Max = 200, Rounding = 0 }
    )
    :OnChanged(function(v)
        CFrameSpeedValue = v
    end)

-- INPUT HANDLER - NO MORE NIL ERRORS
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then
        return
    end

    if inp.KeyCode == CFrameSpeedKey and CFrameSpeedMaster then
        CFrameSpeedActive = not CFrameSpeedActive
        Library:Notify(
            'CFrame Speed: ' .. (CFrameSpeedActive and 'ON' or 'OFF')
        )
        return
    end

    if inp.KeyCode == FlyKey then
        flyEnabled = not flyEnabled
        FlyToggle:SetValue(flyEnabled) -- USE DIRECT REFERENCE
        Library:Notify('Fly: ' .. (flyEnabled and 'ON' or 'OFF'))

        local root = LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
        if flyEnabled and root and not bodyVelocity then
            bodyVelocity = Instance.new('BodyVelocity')
            bodyVelocity.Velocity = Vector3.zero
            bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bodyVelocity.Parent = root
        elseif not flyEnabled and bodyVelocity then
            pcall(function()
                bodyVelocity:Destroy()
            end)
            bodyVelocity = nil
        end
    end
end)

-- CFrame SPEED LOGIC
RunService.Heartbeat:Connect(function()
    if not CFrameSpeedMaster or not CFrameSpeedActive then
        return
    end
    local hrp = LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
    if not hrp then
        return
    end
    local move = LocalPlayer.Character.Humanoid.MoveDirection
    if move.Magnitude > 0 then
        hrp.CFrame = hrp.CFrame + (move * (CFrameSpeedValue / 100))
    end
end)

-- FLY LOGIC
RunService.Heartbeat:Connect(function()
    if
        not (
            flyEnabled
            and bodyVelocity
            and LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
        )
    then
        return
    end
    local root = LocalPlayer.Character.HumanoidRootPart
    local cam = Camera.CFrame
    local move = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        move += cam.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        move -= cam.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        move -= cam.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        move += cam.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.E) then
        move += Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
        move += Vector3.new(0, -1, 0)
    end
    bodyVelocity.Velocity = move.Magnitude > 0 and (move.Unit * FlySpeed)
        or Vector3.zero
end)

-- RESPAWN FIX
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if flyEnabled then
        local root = LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
        if root and not bodyVelocity then
            bodyVelocity = Instance.new('BodyVelocity')
            bodyVelocity.Velocity = Vector3.zero
            bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bodyVelocity.Parent = root
        end
    end
end)

--=====================================================================
-- [8] SETTINGS – FOV
--=====================================================================
local setGB = Tabs.Settings:AddLeftGroupbox('Settings')
local fovChanger = false
setGB
    :AddToggle('FOVChanger', { Text = 'FOV Changer', Default = false })
    :OnChanged(function(v)
        fovChanger = v
        if not v then
            Camera.FieldOfView = 120
        end
    end)
setGB
    :AddSlider(
        'FOVSlider',
        { Text = 'FOV', Default = 70, Min = 30, Max = 120, Rounding = 0 }
    )
    :OnChanged(function(v)
        if fovChanger then
            Camera.FieldOfView = v
        end
    end)

--=====================================================================
-- UI SETTINGS
--=====================================================================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('DaHills')
SaveManager:SetFolder('DaHills')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()

UserInputService.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.RightShift then
        Library:Toggle()
    end
end)

task.delay(1, function()
    Library:Toggle()
end)
