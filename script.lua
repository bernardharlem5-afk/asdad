 local ff3ok, ff3err = pcall(function()
        local RealWindow = Airflow:CreateWindow({
            Name = "Byte.WTF",
            LoadingSubtitle = "Football Fusion 3",
            Theme = "AethelDusk",
            ToggleUIKeybind = "RightControl",
            ConfigurationSaving = { Enabled = true, FolderName = "Byte.WTF", FileName = "FootballFusion3" },
        })

        local TabIcons = {
            ["QB Aimbot"] = "crosshair", ["Catching"] = "circle", ["Player"] = "user",
            ["Physics"] = "activity", ["Visual"] = "eye", ["Defense"] = "shield",
            ["Automatics"] = "list", ["Misc"] = "settings",
        }
        local flagCount = 0
        local function nextFlag(name)
            flagCount += 1
            return "ff3_" .. tostring(flagCount) .. "_" .. tostring(name):gsub("[^%w]", "")
        end

        -- Element object: .Value reads the current value; writing .Value updates the UI too.
        local function makeElement(state, real)
            return setmetatable({}, {
                __index = function(_, k)
                    if k == "Value" then return state.v end
                    if k == "Set" or k == "SetValue" then
                        return function(_, v) state.v = v; if real[1] then pcall(function() real[1]:Set(v) end) end end
                    end
                    return nil
                end,
                __newindex = function(_, k, v)
                    if k == "Value" then
                        state.v = v
                        if real[1] then pcall(function() real[1]:Set(v) end) end
                    end
                end,
            })
        end

        local function wrapTab(tab)
            local T = {}
            function T:CreateToggle(o)
                local state, real = { v = o.Default == true }, {}
                real[1] = tab:CreateToggle({
                    Name = o.Name, Desc = o.Tip, Flag = nextFlag(o.Name), CurrentValue = state.v,
                    Callback = function(v) state.v = v and true or false; if o.Callback then pcall(o.Callback, state.v) end end,
                })
                return makeElement(state, real)
            end
            function T:CreateSlider(o)
                local state, real = { v = o.Default or o.Min or 0 }, {}
                real[1] = tab:CreateSlider({
                    Name = o.Name, Desc = o.Tip, Flag = nextFlag(o.Name),
                    Range = { o.Min or 0, o.Max or 100 }, Increment = o.Increment or 1,
                    Suffix = (o.Suffix ~= nil and o.Suffix ~= "") and (" " .. o.Suffix) or "",
                    CurrentValue = state.v,
                    Callback = function(v) state.v = tonumber(v) or state.v; if o.Callback then pcall(o.Callback, state.v) end end,
                })
                return makeElement(state, real)
            end
            function T:CreateDropdown(o)
                local state, real = { v = o.Default or (o.Options and o.Options[1]) }, {}
                real[1] = tab:CreateDropdown({
                    Name = o.Name, Desc = o.Tip, Flag = nextFlag(o.Name),
                    Options = o.Options, CurrentValue = state.v,
                    Callback = function(v)
                        if type(v) == "table" then v = v[1] end
                        if v ~= nil then state.v = v end
                        if o.Callback then pcall(o.Callback, state.v) end
                    end,
                })
                return makeElement(state, real)
            end
            function T:CreateKeybind(o)
                local state, real = { v = o.Default }, {}
                real[1] = tab:CreateKeybind({
                    Name = o.Name, Desc = o.Tip, Flag = nextFlag(o.Name), CurrentValue = state.v,
                    Callback = function(key)
                        if typeof(key) == "EnumItem" then state.v = key end
                        if o.Callback then pcall(o.Callback, state.v) end
                    end,
                })
                return makeElement(state, real)
            end
            function T:CreateButton(o)
                tab:CreateButton({ Name = o.Name, Desc = o.Tip, Callback = function() if o.Callback then o.Callback() end end })
            end
            function T:CreateDivider() end
            return T
        end

        local Window = {}
        function Window:CreateTab(o)
            return wrapTab(RealWindow:CreateTab({ Name = o.Name, Icon = TabIcons[o.Name] or "settings" }))
        end

        -- ---------------- Football Fusion 3 features ----------------
local ThrowingTab = Window:CreateTab({ Name = 'QB Aimbot', Icon = 'rbxassetid://6034684949' })

enableQbAimbot = ThrowingTab:CreateToggle({
    Name = 'Enable QB Aimbot',
    Default = false,
    Tip = 'Automatically aims passes at the best target for more accurate throws.',
})

throwAimbot = ThrowingTab:CreateToggle({
    Name = 'Throw To Mouse Aimbot',
    Default = false,
    Tip = 'Automatically aims passes toward your mouse position.',
})

autoChooseWr = ThrowingTab:CreateToggle({
    Name = 'Auto Choose Open Reciever',
    Default = false,
    Tip = 'Automatically selects the most open receiver for each throw.',
})

autoSelectThrowMode = ThrowingTab:CreateToggle({
    Name = 'Auto Select Throw Type',
    Default = false,
    Tip = 'Automatically chooses the best throw type for each pass.',
})

autoPower = ThrowingTab:CreateToggle({
    Name = 'Auto Power',
    Default = false,
    Tip = 'Automatically sets the optimal throw power.',
})

autoAngle = ThrowingTab:CreateToggle({
    Name = 'Auto Angle',
    Default = false,
    Tip = 'Automatically adjusts throw angle for better accuracy.',
})

highPowerOnly = ThrowingTab:CreateToggle({
    Name = 'High Power Only',
    Default = false,
    Tip = 'Only uses high-power throws when passing.',
})

antiDB = ThrowingTab:CreateToggle({
    Name = 'Anti DB',
    Default = false,
    Tip = 'Avoids throws that defenders can easily intercept.',
})

antiDBThreshold = ThrowingTab:CreateSlider({
    Name = 'Anti DB Threshold',
    Min = 0,
    Max = 15,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets how aggressively defender coverage is avoided.',
})

antiOOB = ThrowingTab:CreateToggle({
    Name = 'Anti OOB',
    Default = false,
    Tip = 'Prevents throws that may lead receivers out of bounds.',
})

antiOOBThreshold = ThrowingTab:CreateSlider({
    Name = 'Anti OOB Threshold',
    Min = 0,
    Max = 15,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets how close targets can be to the sideline.',
})

throwLeadOffset = ThrowingTab:CreateSlider({
    Name = 'Throw Lead Offset',
    Min = -10,
    Max = 10,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Adjusts how far ahead passes are led.',
})

throwHeightOffset = ThrowingTab:CreateSlider({
    Name = 'Throw Height Offset',
    Min = -10,
    Max = 10,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Adjusts the height of targeted throws.',
})

smartAim = ThrowingTab:CreateToggle({
    Name = 'Smart Aimbot',
    Default = true,
    Tip = 'Tracks real receiver speed and leads left/right cuts, beams crossing routes, and arcs dimes over defenders. Turn off for the old aimbot.',
})

smartLeadTune = ThrowingTab:CreateSlider({
    Name = 'Smart Lead Tuning',
    Min = 0.5,
    Max = 1.5,
    Default = 1,
    Increment = 0.01,
    Suffix = '',
    Tip = '1.00 = exact. Raise it if passes land behind receivers, lower it if they land in front.',
})

smartDBReach = ThrowingTab:CreateSlider({
    Name = 'Smart DB Reach',
    Min = 6,
    Max = 16,
    Default = 10,
    Increment = 0.5,
    Suffix = '',
    Tip = 'How high above a defender the ball must pass to clear him. Raise it if defenders still get hands on dimes.',
})

autoJuke = ThrowingTab:CreateToggle({
    Name = 'Auto Juke Rusher',
    Default = false,
    Tip = 'Automatically jukes nearby rushers before throwing.',
})

hideCards = ThrowingTab:CreateToggle({
    Name = 'Hide QB Aimbot Cards',
    Default = false,
    Tip = 'Hides QB Aimbot visual cards from the screen.',
})

autoChangePowerUI = ThrowingTab:CreateToggle({
    Name = 'Auto Change Power UI',
    Default = false,
    Tip = 'Automatically updates the power UI to match throws.',
})

autoJumpWhenThrow = ThrowingTab:CreateToggle({
    Name = 'Auto Jump Before Throw',
    Default = false,
    Tip = 'Automatically jumps before releasing the ball.',
})

autoThrowAfterSack = ThrowingTab:CreateToggle({
    Name = 'Auto Throw Before Getting Sacked',
    Default = false,
    Tip = 'Automatically throws the ball when a sack is imminent.',
})

dimeKeybind = ThrowingTab:CreateKeybind({
    Name = 'Dime Mode Keybind',
    Default = Enum.KeyCode.One,
    Tip = 'Switches to Dime throw mode.',
})

magKeybind = ThrowingTab:CreateKeybind({
    Name = 'Mag Mode Keybind',
    Default = Enum.KeyCode.Two,
    Tip = 'Switches to Mag throw mode.',
})

diveKeybind = ThrowingTab:CreateKeybind({
    Name = 'Dive Mode Keybind',
    Default = Enum.KeyCode.Three,
    Tip = 'Switches to Dive throw mode.',
})

jumpKeybind = ThrowingTab:CreateKeybind({
    Name = 'Jump Mode Keybind',
    Default = Enum.KeyCode.Four,
    Tip = 'Switches to Jump throw mode.',
})

bulletKeybind = ThrowingTab:CreateKeybind({
    Name = 'Bullet Mode Keybind',
    Default = Enum.KeyCode.Five,
    Tip = 'Switches to Bullet throw mode.',
})

throwBallAwayKeybind = ThrowingTab:CreateKeybind({
    Name = 'Throw Ball Away Keybind',
    Default = Enum.KeyCode.T,
    Tip = 'Instantly throws the ball away.',
})

increaseAngleKeybind = ThrowingTab:CreateKeybind({
    Name = 'Increase Angle Keybind',
    Default = Enum.KeyCode.R,
    Tip = 'Increases the current throw angle.',
})

decreaseAngleKeybind = ThrowingTab:CreateKeybind({
    Name = 'Decrease Angle Keybind',
    Default = Enum.KeyCode.F,
    Tip = 'Decreases the current throw angle.',
})

lockKeybind = ThrowingTab:CreateKeybind({
    Name = 'Lock To Target Keybind',
    Default = Enum.KeyCode.Z,
    Tip = 'Locks passes onto the current target.',
})

local players = game:GetService('Players')
local replicatedStorage = game:GetService('ReplicatedStorage')
local tweenService = game:GetService('TweenService')
local userInputService = game:GetService('UserInputService')
local runService = game:GetService('RunService')
local stats = game:GetService('Stats')
local camera = workspace.CurrentCamera
local lp = players.LocalPlayer
if not lp then
    players:GetPropertyChangedSignal('LocalPlayer'):Wait()
    lp = players.LocalPlayer
end
local mouse = lp:GetMouse()

local isPractice = (game.PlaceId == 81310542478972)
if isPractice then
    autoJuke.Value = false
end

local targetLocked = false
local lockedTarget = nil

local RouteData = {}
local HUDCards = {}
local rusherHighlights = {}
local numCards = 0

local leadDime = 8.5
local leadMag = 8.6
local leadDive = 8.5
local leadJump = 8.4
local leadBullet = 2.5 

local yLeadDime = 1.2
local yLeadMag = 1.0
local yLeadDive = 1.5
local yLeadJump = 2.0
local yLeadBullet = -0.8

local ModeOrder = {'Bullet', 'Dime', 'Dive', 'Jump', 'Mag'}

local QBKeybinds = {
    [dimeKeybind.Value] = 'Dime',
    [magKeybind.Value] = 'Mag',
    [diveKeybind.Value] = 'Dive',
    [jumpKeybind.Value] = 'Jump',
    [bulletKeybind.Value] = 'Bullet'
}

local customHeight = { Value = 0 }

local target = nil
local lastValidTarget = nil
local targetLeadPos = nil
local highlight = nil
local direction = Vector3.new(0, 1, 0)
local power = 60
local angle = 45
local airtime = 0
local isThrowing = false
local isThrowingAway = false
local firedRemote = false
local modeIndex = 1
local smoothedJukeDir = Vector3.zero

local lockedMousePos = nil

local LockToggleBtn = nil
local LockedLabel = nil

local attach0 = Instance.new('Attachment', workspace.Terrain)
local attach1 = Instance.new('Attachment', workspace.Terrain)

local beam = Instance.new('Beam')
beam.Attachment0 = attach0
beam.Attachment1 = attach1
beam.Segments = 7500
beam.Width0 = 1
beam.Width1 = 1
beam.FaceCamera = true
beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
beam.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.01, 0),
    NumberSequenceKeypoint.new(1, 0)
})
beam.Enabled = true
beam.Parent = workspace.Terrain

local posPart = Instance.new('Part', workspace.Terrain)
posPart.Anchored = true
posPart.CanCollide = false
posPart.CastShadow = false
posPart.Size = Vector3.new(3, 3, 3)
posPart.Shape = Enum.PartType.Ball
posPart.Color = Color3.fromRGB(0, 0, 0)

local hudFolder = nil
pcall(function()
    hudFolder = (gethui and gethui()) or game:GetService('CoreGui')
end)
if not hudFolder or (hudFolder.Name == 'CoreGui' and not pcall(function() Instance.new('Folder', hudFolder):Destroy() end)) then
    hudFolder = lp:WaitForChild('PlayerGui', 10)
end

local sg = Instance.new('ScreenGui')
sg.ResetOnSpawn = false
sg.Parent = hudFolder
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local container = Instance.new('CanvasGroup')
container.Size = UDim2.new(1, 0, 0, 100)
container.Position = UDim2.new(0.5, 0, 0.05, 0)
container.AnchorPoint = Vector2.new(0.5, 0)
container.BackgroundTransparency = 1
container.GroupTransparency = 1
container.Visible = true
container.Parent = sg

local hudVisible = false
local updateHUDVisibility = function(show)
    if show and not hudVisible then
        hudVisible = true
        tweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
    elseif not show and hudVisible then
        hudVisible = false
        tweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 1}):Play()
    end
end

local containerScale = Instance.new('UIScale', container)

local updateScale = function()
    local vp = camera.ViewportSize
    local scale = (vp.X / 1100)
    containerScale.Scale = math.clamp(scale, 0.5, 1.2)
end

camera:GetPropertyChangedSignal('ViewportSize'):Connect(updateScale)
updateScale()

local layout = Instance.new('UIListLayout')
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 10)
layout.Parent = container

local assignFont = function(instance, font)
    pcall(function()
        instance.Font = font
    end)
end

local createCard = function(titleTxt)
    local card = Instance.new('Frame')
    card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    card.BackgroundTransparency = 0
    card.BorderSizePixel = 0
    
    local gradient = Instance.new('UIGradient')
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 18))
    })
    gradient.Rotation = 90
    gradient.Parent = card
    
    if titleTxt == 'Throw Type' then
        card.Size = UDim2.new(0, 110, 0, 80)
    else
        card.Size = UDim2.new(0, 95, 0, 80)
    end
    
    card.LayoutOrder = numCards
    card.Parent = container

    local corner = Instance.new('UICorner', card)
    corner.CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new('UIStroke', card)
    stroke.Color = Color3.fromRGB(80, 80, 85)
    stroke.Thickness = 1.000

    local padding = Instance.new('UIPadding', card)
    padding.PaddingTop = UDim.new(0, 5)
    padding.PaddingBottom = UDim.new(0, 5)

    local title = Instance.new('TextLabel')
    title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1.000
    title.BorderSizePixel = 0
    title.Position = UDim2.new(0, 0, 0.70, 0)
    title.Size = UDim2.new(1, 0, 0, 15)
    assignFont(title, Enum.Font.GothamBold)
    title.Text = titleTxt
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Parent = card

    local valBtn = Instance.new('TextButton')
    valBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    valBtn.BackgroundTransparency = 1.000
    valBtn.BorderSizePixel = 0
    valBtn.Position = UDim2.new(0, 0, 0.15, 0)
    valBtn.Size = UDim2.new(1, 0, 0.5, 0)
    assignFont(valBtn, Enum.Font.GothamBold)
    valBtn.Text = '-'
    valBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    valBtn.TextScaled = true
    valBtn.AutoButtonColor = false
    valBtn.Parent = card

    if titleTxt == 'Throw Type' then
        local uiScale = Instance.new('UIScale', card)
        valBtn.MouseButton1Down:Connect(function()
            local c = lp.Character
            if not c or not c:FindFirstChild('Football') then return end
            tweenService:Create(uiScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.9}):Play()
        end)
        valBtn.MouseButton1Up:Connect(function()
            local c = lp.Character
            if not c or not c:FindFirstChild('Football') then return end
            tweenService:Create(uiScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
            modeIndex = modeIndex + 1
            if modeIndex > #ModeOrder then modeIndex = 1 end
        end)
    end

    if titleTxt == 'Player' then
        local lockedLbl = Instance.new('TextLabel')
        lockedLbl.Size = UDim2.new(1, 0, 0.25, 0)
        lockedLbl.Position = UDim2.new(0, 0, 0.05, 0)
        lockedLbl.BackgroundTransparency = 1
        lockedLbl.Text = 'LOCKED'
        lockedLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
        assignFont(lockedLbl, Enum.Font.GothamBold)
        lockedLbl.TextSize = 12
        lockedLbl.Visible = false
        lockedLbl.ZIndex = 2
        lockedLbl.Parent = card

        LockedLabel = lockedLbl

        local lockOverlay = Instance.new('TextButton')
        lockOverlay.Size = UDim2.new(1, 0, 1, 0)
        lockOverlay.BackgroundTransparency = 1
        lockOverlay.Text = ''
        lockOverlay.ZIndex = 5
        lockOverlay.Parent = card

        lockOverlay.MouseButton1Click:Connect(function()
            local c = lp.Character
            if not c or not c:FindFirstChild('Football') then return end
            if target or targetLocked then
                targetLocked = not targetLocked
                if targetLocked then
                    lockedTarget = target
                    if LockedLabel then LockedLabel.Visible = true end
                else
                    lockedTarget = nil
                    if LockedLabel then LockedLabel.Visible = false end
                end
            end
        end)
        
        LockToggleBtn = valBtn
    end

    HUDCards[titleTxt] = valBtn
    numCards = numCards + 1
end

createCard('Angle')
createCard('Throw Type')
createCard('Player')
createCard('Airtime')
createCard('Power')

local getActiveBots = function()
    local bots = {}
    local npcwr = workspace:FindFirstChild('npcwr')
    if npcwr then
        local a = npcwr:FindFirstChild('a')
        if a then
            local bot1 = a:FindFirstChild('bot 1')
            if bot1 and bot1:IsA('Model') then table.insert(bots, bot1) end
        end
        local b = npcwr:FindFirstChild('b')
        if b then
            local bot3 = b:FindFirstChild('bot 3')
            if bot3 and bot3:IsA('Model') then table.insert(bots, bot3) end
        end
    end
    return bots
end

local performThrow = function()
    if not enableQbAimbot.Value then return end

    local character = lp.Character
    if not character then return end

    local football = character:FindFirstChildOfClass('Tool')
    if not football then return end

    local handle = football:FindFirstChild('Handle')
    if not handle then return end

    local remote = handle:FindFirstChild('RemoteEvent')
    if not remote then return end

    local head = character:FindFirstChild('Head')
    if not head then return end

    local root = character:FindFirstChild('HumanoidRootPart')
    if not root then return end

    local finalDirection = direction or Vector3.new(0, 1, 0)

    if isPractice then
        local arg = 'Clicked'
        local arg1 = head.Position
        local arg2 = head.Position + finalDirection * 10000
        local arg3 = tonumber(power) or 0
        remote:FireServer(arg, arg1, arg2, arg3)
    else
        local arg = 'Clicked'
        local arg1 = (root.CFrame * CFrame.new(0, 1.5, 0)).Position + Vector3.new(70000000)
        local arg2 = head.Position + finalDirection * 10000
        local arg3 = tonumber(power) or 0
        remote:FireServer(arg, arg1, arg2, arg3, 1)
    end
end

local findRoute = function(character)
    if not character then return 'stationary', Vector3.zero end
    local isPlayer = players:GetPlayerFromCharacter(character)
    local humanoid = character:FindFirstChild('Humanoid')
    local targetHRP = character:FindFirstChild('HumanoidRootPart')
    local qbChar = lp.Character
    local qbHRP = qbChar and qbChar:FindFirstChild('HumanoidRootPart')
    
    if not humanoid or not targetHRP or not qbHRP then 
        return 'stationary', Vector3.zero 
    end
    
    local moveDirection = Vector3.zero
    if isPlayer then
        moveDirection = humanoid.MoveDirection
    else
        local wtpDiff = humanoid.WalkToPoint - targetHRP.Position
        moveDirection = wtpDiff.Magnitude > 0.01 and wtpDiff.Unit or Vector3.zero
    end
    
    local toWR = targetHRP.Position - qbHRP.Position
    local distance = tonumber(toWR.Magnitude) or 0

    local toWRDir = Vector3.new(toWR.X, 0, toWR.Z)
    if toWRDir.Magnitude > 0.01 then
        toWRDir = toWRDir.Unit
    else
        toWRDir = Vector3.new(0, 0, 1)
    end

    local mdFlat = Vector3.new(moveDirection.X, 0, moveDirection.Z)
    if mdFlat.Magnitude < 0.01 then
        return 'stationary', moveDirection
    end
    mdFlat = mdFlat.Unit

    local dot = tonumber(mdFlat:Dot(toWRDir)) or 0

    if dot > 0.75 then
        return 'go/fade', moveDirection
    elseif dot >= 0.25 and dot <= 0.75 then
        if distance <= 120 then return 'slant', moveDirection
        elseif distance <= 160 then return 'seam', moveDirection
        else return 'post/corner', moveDirection end
    elseif dot > -0.25 and dot < 0.25 then
        if distance <= 60 then return 'drag', moveDirection
        elseif distance <= 130 then return 'in/out', moveDirection
        else return 'flat', moveDirection end
    else
        if distance <= 50 then return 'hitch', moveDirection
        else return 'curl/comeback', moveDirection end
    end
end

local isWROpen = function(wrChar)
    if not wrChar then return false end
    local hrp = wrChar:FindFirstChild('HumanoidRootPart')
    if not hrp then return false end

    local isCovered = false
    local _, moveDir = findRoute(wrChar)
    
    local teamCount = 0
    pcall(function() teamCount = tonumber(#game:GetService('Teams'):GetTeams()) or 0 end)
    
    local checkDB = function(dbHRP)
        local toDB = dbHRP.Position - hrp.Position
        local dist = tonumber(toDB.Magnitude) or 0
        if dist < 5 then
            local routeDirXZ = Vector3.new(moveDir.X, 0, moveDir.Z)
            if (tonumber(routeDirXZ.Magnitude) or 0) > 0.01 then
                routeDirXZ = routeDirXZ.Unit
                local dot = tonumber(toDB.Unit:Dot(routeDirXZ)) or 0
                if dot > -0.7 then 
                    return true
                end
            else
                return true
            end
        end
        return false
    end

    local checkPR = function(dbHRP)
        local qbChar = lp.Character
        if not qbChar then return false end
        local qbHRP = qbChar:FindFirstChild('HumanoidRootPart')
        if not qbHRP then return false end
        
        local toPR = dbHRP.Position - qbHRP.Position
        local toWR = hrp.Position - qbHRP.Position
        local wrDist = tonumber(toWR.Magnitude) or 0
        local wrDir = toWR.Unit
        
        local proj = tonumber(toPR:Dot(wrDir)) or 0
        if proj > 2 and proj < (wrDist * 0.6) then
            local distToLine = tonumber((toPR - (wrDir * proj)).Magnitude) or 0
            if distToLine < 5.5 then
                return true
            end
        end
        return false
    end

    local plrs = players:GetPlayers()
    for i = 1, #plrs do
        local plr = plrs[i]
        if plr ~= lp and plr.Character then
            local isEnemy = true
            if teamCount > 1 and lp.Team ~= nil and plr.Team ~= nil and lp.Team == plr.Team then
                isEnemy = false
            end
            if isEnemy then
                local dbHRP = plr.Character:FindFirstChild('HumanoidRootPart')
                if dbHRP and (checkDB(dbHRP) or checkPR(dbHRP)) then
                    isCovered = true
                    break
                end
            end
        end
    end

    if not isCovered then
        local bots = getActiveBots()
        for i = 1, #bots do
            local bot = bots[i]
            if bot ~= wrChar then
                local dbHRP = bot:FindFirstChild('HumanoidRootPart')
                if dbHRP and (checkDB(dbHRP) or checkPR(dbHRP)) then
                    isCovered = true
                    break
                end
            end
        end
    end

    return not isCovered
end

local getTarget = function()
    if isThrowing and target then return target end
    
    if targetLocked and lockedTarget and lockedTarget:FindFirstChild('HumanoidRootPart') then
        return lockedTarget
    elseif targetLocked then
        targetLocked = false
        lockedTarget = nil
    end

    local potentialTargets = {}
    local teamCount = 0
    pcall(function() teamCount = tonumber(#game:GetService('Teams'):GetTeams()) or 0 end)

    local plrs = players:GetPlayers()
    for i = 1, #plrs do
        local plr = plrs[i]
        if plr ~= lp and plr.Character and plr.Character:FindFirstChild('HumanoidRootPart') then
            local isTeammate = true
            if teamCount > 1 and lp.Team ~= nil and plr.Team ~= nil and lp.Team ~= plr.Team then
                isTeammate = false
            end
            
            if isTeammate then
                local eHum = plr.Character:FindFirstChildOfClass('Humanoid')
                if not eHum or not eHum.Sit then
                    table.insert(potentialTargets, plr.Character)
                end
            end
        end
    end

    local bots = getActiveBots()
    for i = 1, #bots do
        local bot = bots[i]
        if bot:FindFirstChild('HumanoidRootPart') then
            local eHum = bot:FindFirstChildOfClass('Humanoid')
            if not eHum or not eHum.Sit then
                table.insert(potentialTargets, bot)
            end
        end
    end

    if #potentialTargets == 0 then return nil end

    if autoChooseWr.Value then
        local bestAutoTarget = nil
        local bestAutoDist = math.huge
        local qbHRP = lp.Character and lp.Character:FindFirstChild('HumanoidRootPart')
        local qbPos = qbHRP and qbHRP.Position or Vector3.zero

        for i = 1, #potentialTargets do
            local char = potentialTargets[i]
            local hrp = char:FindFirstChild('HumanoidRootPart')
            if hrp then
                local _, onScreen = camera:WorldToViewportPoint(hrp.Position)
                if onScreen and isWROpen(char) then
                    local dist = tonumber((hrp.Position - qbPos).Magnitude) or 0
                    if dist < bestAutoDist then
                        bestAutoDist = dist
                        bestAutoTarget = char
                    end
                end
            end
        end
        
        if bestAutoTarget then
            return bestAutoTarget
        end
    end

    local mousePos2D = userInputService:GetMouseLocation()
    local bestManualTarget = nil
    local bestMouseDist = math.huge

    for i = 1, #potentialTargets do
        local char = potentialTargets[i]
        local hrp = char:FindFirstChild('HumanoidRootPart')
        if hrp then
            local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = tonumber((Vector2.new(screenPos.X, screenPos.Y) - mousePos2D).Magnitude) or 0
                if dist < bestMouseDist then
                    bestMouseDist = dist
                    bestManualTarget = char
                end
            end
        end
    end

    return bestManualTarget
end

local calculateRouteDirection = function(targetChar)
    if not targetChar then return 'Mag' end
    local targetHRP = targetChar:FindFirstChild('HumanoidRootPart')
    if not targetHRP then return 'Mag' end
    
    local lpChar = lp.Character
    local lpHRP = lpChar and lpChar:FindFirstChild('HumanoidRootPart')
    if not lpHRP then return 'Mag' end

    local route, moveDir = findRoute(targetChar)
    local dist = tonumber((targetHRP.Position - lpHRP.Position).Magnitude) or 0
    if dist < 40 then return 'Bullet' end
    
    local dbDistance = math.huge
    local teamCount = 0
    pcall(function() teamCount = tonumber(#game:GetService('Teams'):GetTeams()) or 0 end)

    local plrs = players:GetPlayers()
    for i = 1, #plrs do
        local plr = plrs[i]
        if plr ~= lp and plr.Character then
            local eHRP = plr.Character:FindFirstChild('HumanoidRootPart')
            if eHRP and eHRP ~= targetHRP then
                local isEnemy = true
                if teamCount > 1 and lp.Team ~= nil and plr.Team ~= nil and lp.Team == plr.Team then
                    isEnemy = false
                end
                if isEnemy then
                    local d = tonumber((eHRP.Position - targetHRP.Position).Magnitude) or 0
                    if d < dbDistance then dbDistance = d end
                end
            end
        end
    end

    local bots = getActiveBots()
    for i = 1, #bots do
        local bot = bots[i]
        local bHRP = bot:FindFirstChild('HumanoidRootPart')
        if bHRP and bHRP ~= targetHRP then
            local d = tonumber((bHRP.Position - targetHRP.Position).Magnitude) or 0
            if d < dbDistance then dbDistance = d end
        end
    end

    local within = function(tbl, val)
        for i = 1, #tbl do
            if tbl[i] == val then return true end
        end
        return false
    end

    local forwardRoutes = {'go/fade', 'post/corner', 'seam', 'curl/comeback', 'stationary'}
    local sidewayRoutes = {'in/out', 'flat', 'wheel'}
    
    if route == 'slant' or route == 'hitch' or route == 'drag' or route == 'in/out' or route == 'flat' then
        return 'Bullet'
    elseif within(forwardRoutes, route) then
        if dbDistance > 5 then return ((tonumber(angle) or 45) < 40) and 'Jump' or 'Dime'
        elseif dbDistance > 2 then return 'Dive' end
        return 'Mag'
    elseif within(sidewayRoutes, route) then
        if dbDistance > 4 then return 'Dime' end
        return 'Jump'
    end
    return 'Dime'
end

local getModeLead = function(modeName)
    if modeName == 'Dime' then return leadDime
    elseif modeName == 'Mag' then return leadMag
    elseif modeName == 'Dive' then return leadDive
    elseif modeName == 'Jump' then return leadJump
    elseif modeName == 'Bullet' then return leadBullet
    end
    return 8.6
end

local getModeYLead = function(modeName)
    if modeName == 'Dime' then return yLeadDime
    elseif modeName == 'Mag' then return yLeadMag
    elseif modeName == 'Dive' then return yLeadDive
    elseif modeName == 'Jump' then return yLeadJump
    elseif modeName == 'Bullet' then return yLeadBullet
    end
    return 0
end

local getPing = function()
    local networkPing = 0
    pcall(function() networkPing = tonumber(lp:GetNetworkPing()) or 0 end)
    local dataPing = 0
    pcall(function() dataPing = (tonumber(stats.Network.ServerStatsItem['Data Ping']:GetValue()) or 0) / 1000 end)
    if dataPing == 0 then dataPing = networkPing end
    return networkPing + dataPing
end

local solveKinematics = function(origin, targetPos, gravityMag)
    local g = tonumber(gravityMag) or 28
    local displacement = targetPos - origin
    local x = tonumber(Vector3.new(displacement.X, 0, displacement.Z).Magnitude) or 0
    local y = tonumber(displacement.Y) or 0
    
    local inner = (x^2) + (y^2)
    local root = tonumber(math.sqrt(math.max(inner, 0))) or 0
    
    local baseAngleRad = math.rad(45)
    if x > 0.01 then
        local atanRes = tonumber(math.atan((y + root) / x)) or baseAngleRad
        if atanRes and atanRes == atanRes then
            baseAngleRad = atanRes
        end
    end
    
    local angleRad = tonumber(math.clamp(baseAngleRad * 0.85, math.rad(-15), math.rad(65))) or 0
    
    local cosA = tonumber(math.cos(angleRad)) or 1
    local tanA = tonumber(math.tan(angleRad)) or 0
    
    local v0 = 95
    local denom = 2 * (cosA^2) * (x * tanA - y)
    
    if denom > 0.001 then
        local num = g * (x^2)
        local res = tonumber(math.sqrt(num / denom)) or v0
        if res and res == res and res ~= math.huge then
            v0 = res
        end
    end
    
    local angleDeg = tonumber(math.deg(angleRad)) or 45
    return v0, angleDeg
end

-- ============================================================
-- SMART AIMBOT: measured-velocity intercept, beam for crossing
-- routes, and arcs that clear defenders.
-- ============================================================
local SMART_G = 28
local velTrack = setmetatable({}, { __mode = 'k' })

local flatDist = function(a, b)
    return Vector3.new(b.X - a.X, 0, b.Z - a.Z).Magnitude
end

local trackVel = function(hrp)
    local now = os.clock()
    local pos = hrp.Position
    local e = velTrack[hrp]
    if not e or (now - e.t) > 0.5 then
        local seed = Vector3.zero
        local hum = hrp.Parent and hrp.Parent:FindFirstChildOfClass('Humanoid')
        if hum then
            local md = hum.MoveDirection
            if players:GetPlayerFromCharacter(hrp.Parent) == nil then
                local w = hum.WalkToPoint - hrp.Position
                md = Vector3.new(w.X, 0, w.Z)
                md = md.Magnitude > 0.5 and md.Unit or Vector3.zero
            end
            local flat = Vector3.new(md.X, 0, md.Z)
            if flat.Magnitude > 0.01 then seed = flat.Unit * hum.WalkSpeed end
        end
        e = { pos = pos, t = now, vel = seed, speed = seed.Magnitude, acc = 0 }
        velTrack[hrp] = e
        return e
    end
    local dt = now - e.t
    if dt < 1 / 240 then return e end
    local inst = (pos - e.pos) / dt
    inst = Vector3.new(inst.X, 0, inst.Z)
    if inst.Magnitude > 80 then
        e.vel, e.speed, e.acc = Vector3.zero, 0, 0
    else
        local newVel = e.vel:Lerp(inst, 1 - math.exp(-dt / 0.07))
        local newSpeed = newVel.Magnitude
        local accInst = (newSpeed - e.speed) / dt
        e.acc = e.acc + (accInst - e.acc) * (1 - math.exp(-dt / 0.12))
        e.vel, e.speed = newVel, newSpeed
    end
    e.pos, e.t = pos, now
    return e
end

local getDefenders = function(excludeChar)
    local list = {}
    local teamCount = 0
    pcall(function() teamCount = tonumber(#game:GetService('Teams'):GetTeams()) or 0 end)
    local plrs = players:GetPlayers()
    for i = 1, #plrs do
        local plr = plrs[i]
        if plr ~= lp and plr.Character and plr.Character ~= excludeChar then
            local isEnemy = true
            if teamCount > 1 and lp.Team ~= nil and plr.Team ~= nil and lp.Team == plr.Team then
                isEnemy = false
            end
            if isEnemy then
                local h = plr.Character:FindFirstChild('HumanoidRootPart')
                local hum = plr.Character:FindFirstChildOfClass('Humanoid')
                if h and (not hum or hum.Health > 0) then
                    trackVel(h)
                    table.insert(list, h)
                end
            end
        end
    end
    return list
end

-- Where the receiver will be after Tt seconds (handles hard stops / cuts).
local predictDisp = function(e, Tt, tune)
    if e.speed < 1.5 then return Vector3.zero end
    local dir = e.vel.Unit
    local acc = math.clamp(e.acc, -120, 0)
    local dist
    if acc < -25 then
        local ts = e.speed / -acc
        local tt = math.min(Tt, ts)
        dist = e.speed * tt + 0.5 * acc * tt * tt
    else
        dist = e.speed * Tt
    end
    return dir * dist * tune
end

local bulletAngleFor = function(origin, pos)
    local h = flatDist(origin, pos)
    local v = pos.Y - origin.Y
    local t = h / 95
    local drop = 0.5 * SMART_G * t * t
    return math.clamp(math.deg(math.atan2(v + drop, h)), -15, 45)
end

local flightTime = function(origin, pos, isBullet)
    local h = flatDist(origin, pos)
    if isBullet then
        local hv = 95 * math.cos(math.rad(bulletAngleFor(origin, pos)))
        return h / math.max(hv, 1)
    end
    local v0, aDeg = solveKinematics(origin, pos, SMART_G)
    return h / math.max(v0 * math.cos(math.rad(aDeg)), 1)
end

local powerForAngle = function(origin, pos, aDeg)
    local x = flatDist(origin, pos)
    local y = pos.Y - origin.Y
    local a = math.rad(aDeg)
    local c, tn = math.cos(a), math.tan(a)
    local denom = 2 * c * c * (x * tn - y)
    if denom <= 0.001 then return nil end
    local p = math.sqrt(SMART_G * x * x / denom)
    if p ~= p or p == math.huge then return nil end
    return p
end

-- Intercept point: iterates flight time so the ball lands where the receiver will be.
local smartLead = function(origin, targetHRP, e, headY, isBullet, modeName, fixedArc, defs)
    local tune = tonumber(smartLeadTune.Value) or 1
    local ping = tonumber(getPing()) or 0
    local pos = targetHRP.Position
    local baseY = headY + (isBullet and 0 or getModeYLead(modeName)) + (tonumber(throwHeightOffset.Value) or 0)
    local lead = Vector3.new(pos.X, baseY, pos.Z)
    local T = 0.6
    for _ = 1, 5 do
        local disp = predictDisp(e, T + ping, tune)
        lead = Vector3.new(pos.X + disp.X, baseY, pos.Z + disp.Z)
        if fixedArc then
            T = flatDist(origin, lead) / math.max(fixedArc.p * math.cos(math.rad(fixedArc.a)), 1)
        else
            T = flightTime(origin, lead, isBullet)
        end
    end

    -- Contested: lead the catch point away from the nearest defender.
    if defs then
        local nearest, nd = nil, 7
        for i = 1, #defs do
            local d = defs[i]
            local de = velTrack[d]
            local dv = de and de.vel or Vector3.zero
            local dp = d.Position + Vector3.new(dv.X, 0, dv.Z) * (T + ping * 0.5)
            local dd = Vector3.new(lead.X - dp.X, 0, lead.Z - dp.Z).Magnitude
            if dd < nd then nearest, nd = dp, dd end
        end
        if nearest then
            local away = Vector3.new(lead.X - nearest.X, 0, lead.Z - nearest.Z)
            if away.Magnitude < 0.1 then
                away = Vector3.new(-(lead.Z - origin.Z), 0, lead.X - origin.X)
            end
            if away.Magnitude > 0.01 then
                lead = lead + away.Unit * math.min(3.5, 7 - nd)
            end
        end
    end

    if e.speed >= 1.5 then
        lead = lead + e.vel.Unit * (tonumber(throwLeadOffset.Value) or 0)
    end
    return lead, T
end

-- Best throw type for the situation (only used when Auto Select Throw Type is on).
local smartMode = function(origin, targetHRP, e, defs)
    local toT = Vector3.new(targetHRP.Position.X - origin.X, 0, targetHRP.Position.Z - origin.Z)
    local dist = toT.Magnitude
    if dist < 40 then return 'Bullet' end
    if e.speed >= 6 and toT.Magnitude > 0.01 then
        local dot = e.vel.Unit:Dot(toT.Unit)
        if math.abs(dot) < 0.6 or dot <= -0.6 then
            return 'Bullet' -- crossing / coming back: beam it
        end
    end
    for i = 1, #defs do
        if flatDist(targetHRP.Position, defs[i].Position) < 4.5 then return 'Jump' end
    end
    return 'Dime'
end

-- Counts how often the ball is inside a defender's reach on the way to the receiver.
local arcThreat = function(origin, lead, p, aDeg, T, defs, ping, reach)
    local hv = Vector3.new(lead.X - origin.X, 0, lead.Z - origin.Z)
    if hv.Magnitude < 0.01 then return 0 end
    local hDir = hv.Unit
    local a = math.rad(aDeg)
    local vh, vy = p * math.cos(a), p * math.sin(a)
    local threats = 0
    local N = 18
    for i = 3, N do
        if i / N > 0.9 then break end
        local t = T * (i / N)
        local bp = origin + hDir * (vh * t) + Vector3.new(0, vy * t - 0.5 * SMART_G * t * t, 0)
        if flatDist(origin, bp) > 15 then
            for j = 1, #defs do
                local d = defs[j]
                local de = velTrack[d]
                local dv = de and de.vel or Vector3.zero
                local dp = d.Position + Vector3.new(dv.X, 0, dv.Z) * (t + ping * 0.5)
                local hd = Vector3.new(bp.X - dp.X, 0, bp.Z - dp.Z).Magnitude
                if hd < 6 and bp.Y < d.Position.Y + reach then threats = threats + 1 end
            end
        end
    end
    return threats
end

-- Picks the lowest (fastest) arc that still clears every defender.
local smartArc = function(origin, targetHRP, e, headY, modeName, defs, baseAngle)
    local ping = tonumber(getPing()) or 0
    local reach = tonumber(smartDBReach.Value) or 10
    local far = {}
    for i = 1, #defs do
        if flatDist(origin, defs[i].Position) > 22 then far[#far + 1] = defs[i] end
    end
    local best = nil
    local a = math.clamp(tonumber(baseAngle) or 35, 12, 60)
    while a <= 75 do
        local lead, T = smartLead(origin, targetHRP, e, headY, false, modeName, nil, defs)
        local p
        for _ = 1, 3 do
            p = powerForAngle(origin, lead, a)
            if not p or p > 95 then break end
            lead, T = smartLead(origin, targetHRP, e, headY, false, modeName, { p = p, a = a }, defs)
        end
        if p then p = powerForAngle(origin, lead, a) end
        if p and p <= 95 and p >= 10 then
            local th = (#far > 0) and arcThreat(origin, lead, p, a, T, far, ping, reach) or 0
            if not best or th < best.th then
                best = { p = p, a = a, lead = lead, th = th }
            end
            if th == 0 then break end
        end
        a = a + 5
    end
    return best
end


local autoAim = function(targetHRP)
    local head = lp.Character:FindFirstChild('Head')
    local origin = head and head.Position or lp.Character.HumanoidRootPart.Position
    
    local targetChar = targetHRP.Parent
    local targetHeadObj = targetChar and targetChar:FindFirstChild('Head')
    local targetHead = targetHeadObj and targetHeadObj.Position or targetHRP.Position + Vector3.new(0, 1.5, 0)

    local smartOn = (smartAim and smartAim.Value == true) or false
    local smartE, smartDefs
    if smartOn then
        local okS = pcall(function()
            smartE = trackVel(targetHRP)
            smartDefs = getDefenders(targetChar)
            if autoSelectThrowMode.Value then
                local m = smartMode(origin, targetHRP, smartE, smartDefs)
                for i = 1, #ModeOrder do
                    if ModeOrder[i] == m then modeIndex = i break end
                end
            end
        end)
        if not okS or not smartE then smartOn = false end
    end

    local moveDir = Vector3.zero
    local targetHum = targetChar and targetChar:FindFirstChildOfClass('Humanoid')
    if targetHum then
        local isBot = targetChar:FindFirstAncestor('npcwr') ~= nil
        if isBot then
            local wtpDiff = targetHum.WalkToPoint - targetHRP.Position
            local dir = Vector3.new(wtpDiff.X, 0, wtpDiff.Z)
            moveDir = dir.Magnitude > 0.1 and dir.Unit or Vector3.zero
        else
            local md = targetHum.MoveDirection
            local flatMd = Vector3.new(md.X, 0, md.Z)
            moveDir = flatMd.Magnitude > 0.01 and flatMd.Unit or Vector3.zero
        end
    end
    
    local ping = tonumber(getPing()) or 0
    local speed = 20
    
    local modeName = ModeOrder[modeIndex]
    local isChestPass = (modeName == 'Bullet' or target and (findRoute(target) == 'slant' or findRoute(target) == 'drag' or findRoute(target) == 'in/out' or findRoute(target) == 'flat' or findRoute(target) == 'hitch' or findRoute(target) == 'curl/comeback'))
    local routeStr = target and findRoute(target) or 'go/fade'
    if smartOn then isChestPass = (modeName == 'Bullet') end
    
    local activePower = tonumber(power) or 60
    if modeName == 'Bullet' or (autoPower.Value and isChestPass) or highPowerOnly.Value then
        activePower = 95
    end
    
    local lDivisor = 60
    if activePower > 75 then
        lDivisor = 60 + ((activePower - 75) * 1.5)
    end
    
    local distToTarget = tonumber((targetHRP.Position - origin).Magnitude) or 0
    local estFlightTime = distToTarget / (tonumber(lDivisor) or 60)
    
    local currentHVel = activePower * (tonumber(math.cos(math.rad(tonumber(angle) or 45))) or 1)
    if currentHVel < 30 then currentHVel = 55 end
    
    local estHVel = (modeName == 'Bullet' or isChestPass) and 90 or currentHVel
    
    local modeLeadScale = (tonumber(getModeLead(modeName)) or 8.6) * 3.05
    local selectedModeYLead = tonumber(getModeYLead(modeName)) or 0
    
    local routeMultipliers = {
        ['slant'] = 0.45,
        ['drag'] = 0.6,
        ['in/out'] = 0.65,
        ['flat'] = 0.65,
        ['wheel'] = 0.9,
        ['go/fade'] = 1.0,
        ['post/corner'] = 0.85,
        ['seam'] = 0.85,
        ['hitch'] = 0.1,
        ['curl/comeback'] = 0.1,
        ['stationary'] = 0.0
    }
    local rMult = tonumber(routeMultipliers[routeStr]) or 1.0
    
    local dirUnit = moveDir.Magnitude > 0.01 and moveDir.Unit or Vector3.zero
    
    local targetBase = (isChestPass or modeName == 'Bullet') and targetHRP.Position or targetHead
    
    local standingStill = (routeStr == 'stationary')

    local smartActive = false
    if smartOn then
        local okL, sLead = pcall(smartLead, origin, targetHRP, smartE, targetHead.Y, modeName == 'Bullet', modeName, nil, smartDefs)
        if okL and sLead then
            leadPos = sLead
            smartActive = true
            standingStill = false
        end
    end

    if smartActive then
        -- lead already computed by the smart aimbot
    elseif standingStill then
        leadPos = targetHead
    else
        leadPos = targetBase + (moveDir * speed * estFlightTime * rMult) + (moveDir * speed * ping * rMult) + (dirUnit * modeLeadScale * rMult)
        leadPos = leadPos + (dirUnit * (tonumber(throwLeadOffset.Value) or 0))
        
        if isChestPass or modeName == 'Bullet' then
            leadPos = Vector3.new(leadPos.X, targetHead.Y, leadPos.Z)
            selectedModeYLead = 0
        end
        
        leadPos = leadPos + Vector3.new(0, selectedModeYLead, 0)
        leadPos = leadPos + Vector3.new(0, tonumber(throwHeightOffset.Value) or 0, 0)
        
        if routeStr == 'curl/comeback' or routeStr == 'hitch' then
            leadPos = leadPos + Vector3.new(0, -5, 0)
        end
    end
    
    local forceAutoAngle = (modeName == 'Bullet' or isChestPass or (tonumber(power) or 60) == 95 or highPowerOnly.Value)
    if not autoAngle.Value and not forceAutoAngle then
        leadPos = leadPos + Vector3.new(0, tonumber(customHeight.Value) or 0, 0)
    end
    
    if antiDB.Value then
        local pushVec = Vector3.zero
        local plrs = players:GetPlayers()
        local teamCount = 0
        pcall(function() teamCount = tonumber(#game:GetService('Teams'):GetTeams()) or 0 end)

        for i = 1, #plrs do
            local plr = plrs[i]
            if plr ~= lp and plr.Character then
                local isEnemy = true
                if teamCount > 1 and lp.Team ~= nil and plr.Team ~= nil and lp.Team == plr.Team then
                    isEnemy = false
                end
                if isEnemy then
                    local eHRP = plr.Character:FindFirstChild('HumanoidRootPart')
                    if eHRP then
                        local dist = tonumber(Vector3.new(eHRP.Position.X - leadPos.X, 0, eHRP.Position.Z - leadPos.Z).Magnitude) or 0
                        if dist < (tonumber(antiDBThreshold.Value) or 15) then
                            local away = (leadPos - eHRP.Position)
                            away = Vector3.new(away.X, 0, away.Z)
                            if away.Magnitude > 0 then
                                pushVec = pushVec + (away.Unit * ((tonumber(antiDBThreshold.Value) or 15) - dist))
                            end
                        end
                    end
                end
            end
        end
        leadPos = pushVec + leadPos
    end

    local fPos = Vector3.zero
    local field = workspace:FindFirstChild('Models')
    if field then field = field:FindFirstChild('Field') end
    if field then field = field:FindFirstChild('Ground') end
    if field then fPos = field.Position end

    if antiOOB.Value and fPos ~= Vector3.zero then
        local halfWidth = 75 - (tonumber(antiOOBThreshold.Value) or 5)
        local halfLength = 175 - (tonumber(antiOOBThreshold.Value) or 5)
        leadPos = Vector3.new(
            math.clamp(leadPos.X, fPos.X - halfWidth, fPos.X + halfWidth),
            leadPos.Y,
            math.clamp(leadPos.Z, fPos.Z - halfLength, fPos.Z + halfLength)
        )
    end
    
    targetLeadPos = leadPos
    
    local gMag = 28 
    local calcPower, calcAngle = solveKinematics(origin, leadPos, gMag)
    calcPower = tonumber(calcPower) or 95
    calcAngle = tonumber(calcAngle) or 45
    
    if standingStill and modeName ~= 'Bullet' and not highPowerOnly.Value then
        local dynamicThreshold = tonumber(math.clamp(4 + (distToTarget * 0.08), 5, 14)) or 10
        if calcAngle > dynamicThreshold then
            local displacement = leadPos - origin
            local x = tonumber(Vector3.new(displacement.X, 0, displacement.Z).Magnitude) or 0
            local y = tonumber(displacement.Y) or 0
            local aRad = tonumber(math.rad(dynamicThreshold)) or 0.1
            local denom = 2 * (math.cos(aRad)^2) * (x * math.tan(aRad) - y)
            
            if denom > 0.001 then
                local newPwr = tonumber(math.sqrt((gMag * x^2) / denom)) or calcPower
                if newPwr == newPwr and newPwr ~= math.huge then
                    calcAngle = dynamicThreshold
                    calcPower = newPwr
                end
            end
        end
    end
    
    if highPowerOnly.Value then
        power = 95
        local displacement = leadPos - origin
        local x = tonumber(Vector3.new(displacement.X, 0, displacement.Z).Magnitude) or 0
        local y = tonumber(displacement.Y) or 0
        
        local v2 = 95^2
        local v4 = 95^4
        local gx = gMag * x
        local discriminant = v4 - gMag * (gMag * x^2 + 2 * y * v2)
        
        if discriminant >= 0 then
            angle = tonumber(math.clamp(math.deg(math.atan((v2 - math.sqrt(discriminant)) / gx)) * 0.94, -15, 85)) or 45
        else
            angle = 45
        end
    elseif modeName == 'Bullet' or (autoPower.Value and isChestPass) then
        power = 95
        local displacement = leadPos - origin
        local h = tonumber(Vector3.new(displacement.X, 0, displacement.Z).Magnitude) or 0
        local v = tonumber(displacement.Y) or 0
        local t_est = h / 95
        local drop = 0.5 * 28 * t_est * t_est
        angle = tonumber(math.clamp(math.deg(math.atan2(v + drop, h)), -15, 45)) or 15
    else
        if autoPower.Value then
            power = tonumber(math.clamp(calcPower, 0, 95)) or 60
        end
        if autoAngle.Value then
            angle = tonumber(math.clamp(calcAngle, -15, 90)) or 45
        end
    end
    
    if not autoAngle.Value and not forceAutoAngle then
        angle = tonumber(math.clamp(calcAngle, -15, 90)) or 45
    end

    -- Smart arc: lowest arc that clears the defenders, with the lead re-solved for that flight time.
    if smartActive and modeName ~= 'Bullet' and not highPowerOnly.Value then
        local okA, arc = pcall(smartArc, origin, targetHRP, smartE, targetHead.Y, modeName, smartDefs, angle)
        if okA and arc then
            power = arc.p
            angle = arc.a
            leadPos = arc.lead
            if antiOOB.Value and fPos ~= Vector3.zero then
                local halfWidth = 75 - (tonumber(antiOOBThreshold.Value) or 5)
                local halfLength = 175 - (tonumber(antiOOBThreshold.Value) or 5)
                leadPos = Vector3.new(
                    math.clamp(leadPos.X, fPos.X - halfWidth, fPos.X + halfWidth),
                    leadPos.Y,
                    math.clamp(leadPos.Z, fPos.Z - halfLength, fPos.Z + halfLength)
                )
            end
            targetLeadPos = leadPos
        end
    end

    local safePower = tonumber(power) or 60
    local safeAngle = tonumber(angle) or 45
    local angleRad = tonumber(math.rad(safeAngle)) or 0
    
    local hDirRaw = Vector3.new(leadPos.X - origin.X, 0, leadPos.Z - origin.Z)
    local hDir = hDirRaw.Magnitude > 0.01 and hDirRaw.Unit or head.CFrame.LookVector
    local dirVelocity = (hDir * (tonumber(math.cos(angleRad)) or 1) + Vector3.new(0, tonumber(math.sin(angleRad)) or 0, 0)) * safePower
    
    direction = dirVelocity.Unit * safePower
    
    local hVel = safePower * (tonumber(math.cos(angleRad)) or 1)
    if hVel > 0.1 then
        local xDist = tonumber(Vector3.new(leadPos.X - origin.X, 0, leadPos.Z - origin.Z).Magnitude) or 0
        airtime = xDist / hVel
    else
        airtime = 0
    end
    
    return safeAngle
end

local beamProjectile = function(g, v0, x0, t1)
    local c = 0.5 * 0.5 * 0.5
    local safeT1 = tonumber(t1) or 0.1
    local p3 = 0.5 * g * safeT1 * safeT1 + v0 * safeT1 + x0
    local p2 = p3 - (g * safeT1 * safeT1 + v0 * safeT1) / 3
    local p1 = (c * g * safeT1 * safeT1 + 0.5 * v0 * safeT1 + x0 - c * (x0 + p3)) / (3 * c) - p2

    local curve0 = tonumber((p1 - x0).Magnitude) or 0
    local curve1 = tonumber((p2 - p3).Magnitude) or 0

    local b = (x0 - p3).Unit
    local r1 = (p1 - x0).Unit
    local u1 = r1:Cross(b).Unit
    local r2 = (p2 - p3).Unit
    local u2 = r2:Cross(b).Unit
    b = u1:Cross(r1).Unit

    local cf1 = CFrame.new(
        x0.X, x0.Y, x0.Z,
        r1.X, u1.X, b.X,
        r1.Y, u1.Y, b.Y,
        r1.Z, u1.Z, b.Z
    )

    local cf2 = CFrame.new(
        p3.X, p3.Y, p3.Z,
        r2.X, u2.X, b.X,
        r2.Y, u2.Y, b.Y,
        r2.Z, u2.Z, b.Z
    )

    return curve0, -curve1, cf1, cf2
end

userInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local char = lp.Character
    if not char or not char:FindFirstChild('Football') then return end
    
    if input.KeyCode == throwBallAwayKeybind.Value then
        local fPos = Vector3.zero
        local field = workspace:FindFirstChild('Models')
        if field then field = field:FindFirstChild('Field') end
        if field then field = field:FindFirstChild('Ground') end
        if field then fPos = field.Position end
        
        local side = math.random(1, 2) == 1 and -1 or 1
        local throwTarget = fPos + Vector3.new(side * 120, 0, math.random(-100, 100))
        
        local head = char:FindFirstChild('Head')
        local origin = head and head.Position or char.HumanoidRootPart.Position
        
        isThrowingAway = true
        power = 95
        angle = 25
        
        local angleRad = tonumber(math.rad(angle)) or 0
        local hDir = Vector3.new(throwTarget.X - origin.X, 0, throwTarget.Z - origin.Z).Unit
        local dirVelocity = (hDir * (tonumber(math.cos(angleRad)) or 1) + Vector3.new(0, tonumber(math.sin(angleRad)) or 0, 0)) * 95
        direction = dirVelocity.Unit * 95
        
        local hVel = 95 * (tonumber(math.cos(angleRad)) or 1)
        airtime = hVel > 0.1 and ((tonumber(Vector3.new(throwTarget.X - origin.X, 0, throwTarget.Z - origin.Z).Magnitude) or 0) / hVel) or 1
        
        local hum = char:FindFirstChildOfClass('Humanoid')
        local throwAnim = replicatedStorage:FindFirstChild('Animations') and replicatedStorage.Animations:FindFirstChild('Throw')
        if hum and throwAnim then
            local animator = hum:FindFirstChild('Animator')
            if animator then
                local track = animator:LoadAnimation(throwAnim)
                track:Play()
            end
        end
        return
    end

    if input.KeyCode == increaseAngleKeybind.Value then
        customHeight.Value = (tonumber(customHeight.Value) or 0) + 5
    elseif input.KeyCode == decreaseAngleKeybind.Value then
        customHeight.Value = (tonumber(customHeight.Value) or 0) - 5
    end
    
    if not autoSelectThrowMode.Value and QBKeybinds[input.KeyCode] then
        local desiredMode = QBKeybinds[input.KeyCode]
        for i = 1, #ModeOrder do
            if ModeOrder[i] == desiredMode then
                modeIndex = i
                break
            end
        end
    end

    if input.KeyCode == lockKeybind.Value then
        if target or targetLocked then
            targetLocked = not targetLocked
            if targetLocked then
                lockedTarget = target
                if LockToggleBtn then LockToggleBtn.TextColor3 = Color3.fromRGB(255, 50, 50) end
                if LockedLabel then LockedLabel.Visible = true end
            else
                lockedTarget = nil
                if LockToggleBtn then LockToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255) end
                if LockedLabel then LockedLabel.Visible = false end
            end
        end
    end
end)

local triggerThrowJump = function()
    if autoJumpWhenThrow.Value then
        task.delay(0.05, function()
            local char = lp.Character
            if char then
                local hum = char:FindFirstChildOfClass('Humanoid')
                if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end

task.spawn(function()
    local bindAnimation = function(char)
        local humanoid = char:WaitForChild('Humanoid', 5)
        if not humanoid then return end
        local animator = humanoid:WaitForChild('Animator', 5)
        if not animator then return end
        
        animator.AnimationPlayed:Connect(function(track)
            local throwAnim = replicatedStorage:FindFirstChild('Animations') and replicatedStorage.Animations:FindFirstChild('Throw')
            if throwAnim and track.Animation and (track.Animation == throwAnim or track.Animation.AnimationId == throwAnim.AnimationId) then
                track:GetPropertyChangedSignal('IsPlaying'):Connect(function()
                    if track.IsPlaying then
                        if not isThrowing then
                            isThrowing = true
                            triggerThrowJump()
                            task.delay(0.12, function()
                                firedRemote = true
                                performThrow()
                            end)
                        end
                    else
                        isThrowing = false
                        firedRemote = false
                        isThrowingAway = false
                    end
                end)
                
                if track.IsPlaying and not isThrowing then
                    isThrowing = true
                    triggerThrowJump()
                    task.delay(0.12, function()
                        firedRemote = true
                        performThrow()
                    end)
                end
            end
        end)
    end

    if lp.Character then
        bindAnimation(lp.Character)
    end
    lp.CharacterAdded:Connect(function(char)
        bindAnimation(char)
    end)
end)

-- Aimbot throw triggers: RT (controller), right click (keyboard + mouse),
-- and an on-screen THROW button on mobile.
local lastInputThrow = 0
local aimbotThrow = function(playAnim)
    if not enableQbAimbot.Value then return end

    local char = lp.Character
    if not char or not char:FindFirstChild('Football') then return end
    if isThrowing or isThrowingAway then return end
    if os.clock() - lastInputThrow < 0.5 then return end

    lastInputThrow = os.clock()
    isThrowing = true

    if playAnim then
        local hum = char:FindFirstChildOfClass('Humanoid')
        local throwAnim = replicatedStorage:FindFirstChild('Animations') and replicatedStorage.Animations:FindFirstChild('Throw')
        local animator = hum and hum:FindFirstChild('Animator')
        if animator and throwAnim then
            pcall(function() animator:LoadAnimation(throwAnim):Play() end)
        end
    end

    triggerThrowJump()
    task.delay(0.12, function()
        firedRemote = true
        performThrow()
    end)
    -- Safety reset in case the throw animation never plays.
    task.delay(0.8, function()
        if os.clock() - lastInputThrow >= 0.75 then
            isThrowing = false
            firedRemote = false
        end
    end)
end

userInputService.InputBegan:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton2
        or input.KeyCode == Enum.KeyCode.ButtonR2 then
        aimbotThrow(false)
    end
end)

if userInputService.TouchEnabled then
    local throwBtn = Instance.new('TextButton')
    throwBtn.Name = 'AethelThrow'
    throwBtn.Size = UDim2.new(0, 84, 0, 84)
    throwBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    throwBtn.Position = UDim2.new(0.85, 0, 0.55, 0)
    throwBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    throwBtn.BackgroundTransparency = 0.15
    throwBtn.AutoButtonColor = false
    throwBtn.Text = 'THROW'
    throwBtn.Font = Enum.Font.GothamBold
    throwBtn.TextSize = 16
    throwBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
    throwBtn.Visible = false
    throwBtn.ZIndex = 50
    throwBtn.Parent = sg
    Instance.new('UICorner', throwBtn).CornerRadius = UDim.new(1, 0)
    local btnStroke = Instance.new('UIStroke', throwBtn)
    btnStroke.Color = Color3.fromRGB(240, 240, 240)
    btnStroke.Transparency = 0.4
    btnStroke.Thickness = 2

    -- Tap = throw, drag = move the button.
    local dragging, dragMoved, dragStart, startPos = false, false, nil, nil
    throwBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragMoved = true, false
            dragStart, startPos = input.Position, throwBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not dragMoved then aimbotThrow(true) end
                end
            end)
        end
    end)
    userInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            if delta.Magnitude > 12 then dragMoved = true end
            if dragMoved then
                throwBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    -- Only show it while the aimbot is on and you're holding the football.
    task.spawn(function()
        while true do
            task.wait(0.1)
            local char = lp.Character
            throwBtn.Visible = enableQbAimbot.Value and char ~= nil and char:FindFirstChild('Football') ~= nil
        end
    end)
end

local setupSackHandler = function(character)
    character.ChildAdded:Connect(function(v)
        if not autoThrowAfterSack.Value then return end
        if not v:IsA('LocalScript') then return end
        if not v.Name:lower():find('tackle') then return end

        task.wait()

        local humanoid = character:FindFirstChildOfClass('Humanoid')
        if not humanoid then return end

        if autoChooseWr.Value then
            local openWR = nil
            local bestDist = math.huge
            local mousePos2D = userInputService:GetMouseLocation()
            
            local teamCount = 0
            pcall(function() teamCount = tonumber(#game:GetService('Teams'):GetTeams()) or 0 end)
            
            local plrs = players:GetPlayers()
            for i = 1, #plrs do
                local plr = plrs[i]
                if plr ~= lp and plr.Character then
                    local isTeammate = true
                    if teamCount > 1 and lp.Team ~= nil and plr.Team ~= nil and lp.Team ~= plr.Team then
                        isTeammate = false
                    end
                    
                    if isTeammate then
                        local eHrp = plr.Character:FindFirstChild('HumanoidRootPart')
                        local eHum = plr.Character:FindFirstChildOfClass('Humanoid')
                        if eHrp and (not eHum or not eHum.Sit) and isWROpen(plr.Character) then
                            local screenPos, onScreen = camera:WorldToViewportPoint(eHrp.Position)
                            if onScreen then
                                local dist = tonumber((Vector2.new(screenPos.X, screenPos.Y) - mousePos2D).Magnitude) or 0
                                if dist < bestDist then
                                    bestDist = dist
                                    openWR = plr.Character
                                end
                            end
                        end
                    end
                end
            end

            if openWR then
                target = openWR
                targetLocked = true
                lockedTarget = openWR
            end
        end

        if target then
            local throwAnim = replicatedStorage:FindFirstChild('Animations') and replicatedStorage.Animations:FindFirstChild('Throw')
            if throwAnim then
                local animator = humanoid:FindFirstChild('Animator')
                if animator then
                    local track = animator:LoadAnimation(throwAnim)
                    track:Play()
                end
            end
        end
    end)
end

if lp.Character then
    setupSackHandler(lp.Character)
end
lp.CharacterAdded:Connect(setupSackHandler)

local updateHighlights = function(isActive)
    if not isActive then
        if highlight then highlight:Destroy(); highlight = nil end
        return
    end

    if target then
        if not highlight then
            highlight = Instance.new('Highlight')
        end
        highlight.Adornee = target
        highlight.Parent = target
        highlight.FillTransparency = 1
        highlight.OutlineColor = targetLocked and Color3.new(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
    elseif highlight then
        highlight:Destroy()
        highlight = nil
    end
end

workspace.ChildAdded:Connect(function(v)
    if not enableQbAimbot.Value then return end
    if v:IsA('BasePart') and v.Name == 'Football' then
        task.wait()
        local lpChar = lp.Character
        local lpHead = lpChar and lpChar:FindFirstChild('Head')
        if not lpHead then return end
        
        if v:GetAttribute('LocalAimbotBall') or (v.Position - lpHead.Position).Magnitude < 15 then
            local tAttach0 = Instance.new('Attachment', workspace.Terrain)
            local tAttach1 = Instance.new('Attachment', workspace.Terrain)
            
            local tBeam = Instance.new('Beam')
            tBeam.Attachment0 = tAttach0
            tBeam.Attachment1 = tAttach1
            tBeam.Segments = 7500
            tBeam.Width0 = 1
            tBeam.Width1 = 1
            tBeam.FaceCamera = true
            tBeam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
            tBeam.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.01, 0),
                NumberSequenceKeypoint.new(1, 0)
            })
            tBeam.Parent = workspace.Terrain
            
            local tPosPart = Instance.new('Part', workspace.Terrain)
            tPosPart.Anchored = true
            tPosPart.CanCollide = false
            tPosPart.CastShadow = false
            tPosPart.Size = Vector3.new(3, 3, 3)
            tPosPart.Shape = Enum.PartType.Ball
            tPosPart.Color = Color3.fromRGB(0, 0, 0)
            
            local safeDirection = direction or Vector3.new(0, 1, 0)
            local safeAirtime = math.max(tonumber(airtime) or 0.1, 0.1)
            local curve0, curve1, cf1, cf2 = beamProjectile(Vector3.new(0, -28, 0), safeDirection, lpHead.Position + (safeDirection.Unit * 5), safeAirtime)
            
            tBeam.CurveSize0 = curve0
            tBeam.CurveSize1 = curve1
            
            tAttach0.WorldCFrame = cf1
            tAttach1.WorldCFrame = cf2
            
            tPosPart.Position = Vector3.new(cf2.X, cf2.Y, cf2.Z)
            
            task.delay(safeAirtime, function()
                tBeam:Destroy()
                tAttach0:Destroy()
                tAttach1:Destroy()
                tPosPart:Destroy()
            end)
        end
    end
end)

runService.RenderStepped:Connect(function()
    if not enableQbAimbot.Value then
        updateHUDVisibility(false)
        updateHighlights(false)
        if beam then beam.Enabled = false end
        if posPart then posPart.Position = Vector3.new(0, -9999, 0) end
        if attach0 then attach0.WorldPosition = Vector3.new(0, -9999, 0) end
        if attach1 then attach1.WorldPosition = Vector3.new(0, -9999, 0) end
        target = nil
        return
    end

    if not sg or not sg.Parent then return end

    local char = lp.Character
    if not char then return end
    
    local head = char:FindFirstChild('Head')
    local hrp = char:FindFirstChild('HumanoidRootPart')
    if not head or not hrp then return end

    local football = char:FindFirstChild('Football')
    local hasFootball = (football ~= nil)
    
    if hasFootball then
        football:SetAttribute('LocalAimbotBall', true)
        local fHandle = football:FindFirstChild('Handle')
        if fHandle then fHandle:SetAttribute('LocalAimbotBall', true) end
    end
    
    local playerGui = lp:WaitForChild('PlayerGui', 10)
    local ballGui = playerGui and playerGui:FindFirstChild('BallGui')
    
    if autoJuke.Value and hasFootball and ballGui then
        local fPos = Vector3.zero
        local field = workspace:FindFirstChild('Models')
        if field then field = field:FindFirstChild('Field') end
        if field then field = field:FindFirstChild('Ground') end
        if field then fPos = field.Position end
        
        local minX = fPos.X - (155 / 2)
        local maxX = fPos.X + (155 / 2)
        local minZ = fPos.Z - (355 / 2)
        local maxZ = fPos.Z + (355 / 2)

        local dodgeVec = Vector3.zero
        local threatCount = 0

        local plrs = players:GetPlayers()
        local teamCount = 0
        pcall(function() teamCount = tonumber(#game:GetService('Teams'):GetTeams()) or 0 end)
        
        for i = 1, #plrs do
            local plr = plrs[i]
            if plr ~= lp and plr.Character then
                local isEnemy = true
                if teamCount > 1 and lp.Team ~= nil and plr.Team ~= nil and lp.Team == plr.Team then
                    isEnemy = false
                end
                
                if isEnemy then
                    local eHrp = plr.Character:FindFirstChild('HumanoidRootPart')
                    if eHrp then
                        local distToMe = tonumber((eHrp.Position - hrp.Position).Magnitude) or 0
                        if distToMe < 45 then
                            local eVel = eHrp.AssemblyLinearVelocity or eHrp.Velocity or Vector3.zero
                            local eSpeed = tonumber(Vector3.new(eVel.X, 0, eVel.Z).Magnitude) or 0
                            local tta = distToMe / math.max(eSpeed, 1)
                            
                            local futureTime = math.min(tta, 1)
                            local eFuture = eHrp.Position + (eVel * futureTime)
                            local myVel = hrp.AssemblyLinearVelocity or hrp.Velocity or Vector3.zero
                            local myFuture = hrp.Position + (myVel * futureTime)
                            
                            local toThreat = eFuture - myFuture
                            local futureDist = tonumber(Vector3.new(toThreat.X, 0, toThreat.Z).Magnitude) or 0
                            
                            if futureDist < 20 or distToMe < 25 then
                                threatCount = threatCount + 1
                                local awayDir = myFuture - eFuture
                                awayDir = Vector3.new(awayDir.X, 0, awayDir.Z)
                                if awayDir.Magnitude < 0.1 then
                                    awayDir = hrp.CFrame.RightVector
                                end
                                awayDir = awayDir.Unit
                                
                                local weight = math.clamp(45 - distToMe, 0, 45)
                                dodgeVec = dodgeVec + (awayDir * weight)
                            end
                        end
                    end
                end
            end
        end

        local hum = char:FindFirstChildOfClass('Humanoid')
        if hum then
            local checkPos = hrp.Position
            local outOfBoundsPush = Vector3.zero
            
            if checkPos.X < minX + 5 then outOfBoundsPush = outOfBoundsPush + Vector3.new(1, 0, 0) end
            if checkPos.X > maxX - 5 then outOfBoundsPush = outOfBoundsPush + Vector3.new(-1, 0, 0) end
            if checkPos.Z < minZ + 5 then outOfBoundsPush = outOfBoundsPush + Vector3.new(0, 0, 1) end
            if checkPos.Z > maxZ - 5 then outOfBoundsPush = outOfBoundsPush + Vector3.new(0, 0, -1) end
            
            local targetJukeDir = Vector3.zero
            if threatCount > 0 then
                targetJukeDir = dodgeVec.Unit
                if outOfBoundsPush.Magnitude > 0 then
                    targetJukeDir = (targetJukeDir + outOfBoundsPush * 2).Unit
                end
            elseif outOfBoundsPush.Magnitude > 0 then
                targetJukeDir = outOfBoundsPush.Unit
            end
            
            if targetJukeDir.Magnitude > 0 then
                smoothedJukeDir = smoothedJukeDir:Lerp(targetJukeDir, 0.25)
                hum:Move(smoothedJukeDir, false)
            else
                smoothedJukeDir = Vector3.zero
            end
        end
    end

    local isTracking = hasFootball and (ballGui ~= nil)

    if isTracking then
        if not hideCards.Value then
            updateHUDVisibility(true)
        else
            updateHUDVisibility(false)
        end
        
        if not isThrowingAway then
            local newTarget = getTarget()
            if newTarget then
                lastValidTarget = newTarget
            elseif lastValidTarget and not lastValidTarget:FindFirstChild('HumanoidRootPart') then
                lastValidTarget = nil
            end
            
            if throwAimbot.Value then
                target = lastValidTarget
                updateHighlights(false)
                
                local targetPos
                if isThrowing and lockedMousePos then
                    targetPos = lockedMousePos
                else
                    targetPos = mouse.Hit.Position
                    lockedMousePos = targetPos
                end
                
                local headPos = head.Position
                local gMag = 28
                local calcPower, calcAngle = solveKinematics(headPos, targetPos, gMag)
                calcPower = tonumber(calcPower) or 95
                calcAngle = tonumber(calcAngle) or 45
                
                if autoPower.Value then
                    power = math.clamp(calcPower, 0, 95)
                end
                
                if autoAngle.Value then
                    angle = math.clamp(calcAngle, -15, 90)
                else
                    angle = math.clamp(tonumber(customHeight.Value) or 0, -15, 90)
                end
                
                local safePower = tonumber(power) or 60
                local safeAngle = tonumber(angle) or 45
                local angleRad = tonumber(math.rad(safeAngle)) or 0
                
                local hDirRaw = Vector3.new(targetPos.X - headPos.X, 0, targetPos.Z - headPos.Z)
                local hDir = hDirRaw.Magnitude > 0.01 and hDirRaw.Unit or hrp.CFrame.LookVector
                
                local dirVelocity = (hDir * (tonumber(math.cos(angleRad)) or 1) + Vector3.new(0, tonumber(math.sin(angleRad)) or 0, 0)) * safePower
                direction = dirVelocity.Unit * safePower
                
                local hVel = safePower * (tonumber(math.cos(angleRad)) or 1)
                if hVel > 0.1 then
                    local xDist = tonumber(Vector3.new(targetPos.X - headPos.X, 0, targetPos.Z - headPos.Z).Magnitude) or 0
                    airtime = xDist / hVel
                else
                    airtime = 0
                end
                
                targetLeadPos = targetPos
            else
                target = newTarget or lastValidTarget
                updateHighlights(true)
                if target and hrp then
                    local tHRP = target:FindFirstChild('HumanoidRootPart')
                    if tHRP then
                        if autoSelectThrowMode.Value then
                            local m = calculateRouteDirection(target)
                            for i = 1, #ModeOrder do
                                if ModeOrder[i] == m then
                                    modeIndex = i
                                    break
                                end
                            end
                            
                            local targetCurrentRoute = select(1, findRoute(target))
                            if ModeOrder[modeIndex] == 'Bullet' and (targetCurrentRoute == 'go/fade' or targetCurrentRoute == 'post/corner') then
                                for i = 1, #ModeOrder do
                                    if ModeOrder[i] == 'Mag' then
                                        modeIndex = i
                                        break
                                    end
                                end
                            end
                        end
                        
                        autoAim(tHRP)
                    end
                end
            end
        else
            target = nil
            updateHighlights(false)
        end
        
        if autoChangePowerUI.Value then
            if ballGui and ballGui:FindFirstChild('Frame0') then
                local frame0 = ballGui.Frame0
                local safePower = tonumber(power) or 60
                if safePower ~= safePower then safePower = 60 end
                
                local displayPower = math.round(safePower / 5) * 5
                
                local txt = frame0:FindFirstChildOfClass('TextLabel')
                if txt then txt.Text = tostring(math.floor(displayPower)) end
                
                local frames = frame0:GetChildren()
                for i = 1, #frames do
                    local frame = frames[i]
                    if frame.Name ~= 'Disp' then
                        local frameNum = tonumber(frame.Name) or 0
                        frame.BackgroundTransparency = ((tonumber(frameNum) or 0) <= (tonumber(displayPower) or 0)) and 0 or 0.9
                    end
                end
            end
        end
        
        local safePowForCard = tonumber(power) or 60
        if safePowForCard ~= safePowForCard then safePowForCard = 60 end
        
        if HUDCards['Angle'] then 
            local forceAutoAngle = (ModeOrder[modeIndex] == 'Bullet' or (target and findRoute(target) == 'slant' or findRoute(target) == 'drag' or findRoute(target) == 'in/out' or findRoute(target) == 'flat' or findRoute(target) == 'hitch' or findRoute(target) == 'curl/comeback') or (tonumber(power) or 60) == 95 or highPowerOnly.Value)
            if not autoAngle.Value and not forceAutoAngle then
                HUDCards['Angle'].Text = tostring(math.floor(tonumber(customHeight.Value) or 0))
            else
                HUDCards['Angle'].Text = tostring(math.floor(tonumber(angle) or 45)) 
            end
        end
        
        if HUDCards['Power'] then HUDCards['Power'].Text = string.format('%.0f', safePowForCard) end
        if HUDCards['Airtime'] then HUDCards['Airtime'].Text = string.format('%.1fs', tonumber(airtime) or 0) end
        if HUDCards['Throw Type'] then HUDCards['Throw Type'].Text = tostring(ModeOrder[modeIndex] or 'N/A') end
        
        if HUDCards['Player'] then
            if throwAimbot.Value then
                HUDCards['Player'].Text = 'MOUSE'
            else
                HUDCards['Player'].Text = tostring((target and target.Name) or 'NONE')
            end
        end
    else
        updateHUDVisibility(false)
        updateHighlights(false)
        target = nil
        lastValidTarget = nil
    end

    if beam and isTracking then
        beam.Enabled = true
        local startOrigin = head.Position
        local safePowerForBeam = tonumber(power) or 60
        local drawDir = direction or Vector3.new(0, 1, 0)
        
        if throwAimbot.Value then
            if (tonumber(drawDir.Magnitude) or 0) < 0.1 then
                drawDir = Vector3.new(0, 1, 0) * safePowerForBeam
            end
        elseif not target or not targetLeadPos then
            local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
            drawDir = mouseRay.Direction.Unit * safePowerForBeam
            direction = drawDir
        else
            if (tonumber(drawDir.Magnitude) or 0) < 0.1 then
                drawDir = Vector3.new(0, 1, 0) * safePowerForBeam
            end
        end
        
        local safeAirtime = math.max(tonumber(airtime) or 0.1, 0.1)
        
        local curve0, curve1, cf1, cf2 = beamProjectile(Vector3.new(0,-28,0), drawDir, startOrigin + (drawDir.Unit * 5), safeAirtime)
        
        beam.CurveSize0 = curve0
        beam.CurveSize1 = curve1
        
        if attach0 and attach1 then
            attach0.WorldCFrame = cf1
            attach1.WorldCFrame = cf2
            
            attach0.WorldPosition = Vector3.new(cf1.X, cf1.Y, cf1.Z)
            attach1.WorldPosition = Vector3.new(cf2.X, cf2.Y, cf2.Z)
            
            if posPart then posPart.Position = Vector3.new(attach1.WorldPosition.X, attach1.WorldPosition.Y, attach1.WorldPosition.Z) end
        end
    else
        if beam then beam.Enabled = false end
        if posPart then posPart.Position = Vector3.new(0, -9999, 0) end
        if attach0 then attach0.WorldPosition = Vector3.new(0, -9999, 0) end
        if attach1 then attach1.WorldPosition = Vector3.new(0, -9999, 0) end
    end
end)

local CatchingTab = Window:CreateTab({ Name = 'Catching', Icon = 'rbxassetid://6034227067' })

footballMagnets = CatchingTab:CreateToggle({
    Name = 'Enable Football Magnets',
    Default = false,
    Tip = 'Automatically pulls nearby footballs into catch range.',
})

freeFallCheck = CatchingTab:CreateToggle({
    Name = 'Magnets Freefall Check',
    Default = false,
    Tip = 'Only activates football magnets while the ball is airborne.',
})

showCatchHitbox = CatchingTab:CreateToggle({
    Name = 'Show Magnets Radius',
    Default = false,
    Tip = 'Displays the football magnets catch radius.',
})

magnetsRadius = CatchingTab:CreateSlider({
    Name = 'Magnets Catch Distance',
    Min = 0,
    Max = 25,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets the maximum distance footballs can be caught from.',
})

magnetsDelay = CatchingTab:CreateSlider({
    Name = 'Magnets Catch Delay',
    Min = 0,
    Max = 1,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets the delay before football magnets activate.',
})

magsType = CatchingTab:CreateDropdown({
    Name = 'Magnets Type',
    Options = {'Custom', 'Blatant', 'League', 'Legit'},
    Default = 'Custom',
    Tip = 'Selects the football magnets behavior preset.',
})

local player = game:GetService('Players').LocalPlayer

local part = Instance.new('Part')
part.Color = Color3.fromRGB(255, 255, 255)
part.Shape = Enum.PartType.Ball
part.Material = Enum.Material.ForceField
part.CastShadow = false
part.Anchored = true
part.CanCollide = false

local findClosestBall = function()
    local character = player.Character
    if not character then return end

    local humanoidRootPart = character:FindFirstChild('HumanoidRootPart')
    if not humanoidRootPart then return end

    local dist = math.huge
    local ball = nil

    for _, v in next, workspace:GetChildren() do
        if not v:IsA('BasePart') then continue end
        if v.Name ~= 'Football' then continue end

        local distance = (v.Position - humanoidRootPart.Position).Magnitude

        if distance < dist then
            dist = distance
            ball = v
        end
    end

    return ball
end

local selectedRange = function()
	local range = tonumber(magnetsRadius.Value) or 0
	local mode = tostring(magsType.Value or 'Custom'):lower()

	if mode == 'legit' then
		return range / 2
	elseif mode == 'league' then
		return range / 1.4
	elseif mode == 'blatant' then
		return range * 1.5
	end

	return range
end

task.spawn(function()
    while true do
        task.wait()

        local character = player.Character
        if not character then continue end

        local humanoid = character:FindFirstChildOfClass('Humanoid')
        if not humanoid then continue end

        local ball = findClosestBall()
        if not ball then continue end

        local range = selectedRange()

        part.Size = Vector3.new(range, range, range)
        part.CFrame = CFrame.new(ball.Position)
        part.Parent = (footballMagnets.Value and showCatchHitbox.Value) and workspace.Terrain or nil

        for _, v in next, character:GetChildren() do
            if not v:IsA('BasePart') then continue end
            if not v.Name:lower():find('catch') then continue end

            local distance = (ball.Position - v.Position).Magnitude

            if freeFallCheck.Value and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then continue end

            if footballMagnets.Value and distance < range then
                tweenService:Create(v, TweenInfo.new(magnetsDelay.Value), {Position = ball.Position}):Play()

                pcall(function()
                    firetouchinterest(v, ball, 0)
                    firetouchinterest(v, ball, 1)
                end)
            end
        end
    end
end)

CatchingTab:CreateDivider()

magEnhancer = CatchingTab:CreateToggle({
    Name = 'Enable Mag Enhancer',
    Default = false,
    Tip = 'Enhances catches on footballs already within range.',
})

magEnhancerRadius = CatchingTab:CreateSlider({
    Name = 'Mag Catch Distance',
    Min = 0,
    Max = 25,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets the maximum distance the enhancer can assist catches.',
})

magEnhancerMaxAngle = CatchingTab:CreateSlider({
    Name = 'Mag Max Angle',
    Min = 50,
    Max = 70,
    Default = 50,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets the maximum catch angle the enhancer can assist.',
})

task.spawn(function()
    while true do
        task.wait(0.1)

        if not magEnhancer.Value then continue end

        local character = player.Character
        if not character then continue end

        local humanoidRootPart = character:FindFirstChild('HumanoidRootPart')
        if not humanoidRootPart then continue end

        local ball = findClosestBall()
        if not ball then continue end

        local verticalDistance = ball.Position.Y - humanoidRootPart.Position.Y

        if verticalDistance > magEnhancerMaxAngle.Value then
            continue
        end

        local lookVector = humanoidRootPart.CFrame.LookVector
        local direction = (ball.Position - humanoidRootPart.Position).Unit
        local dot = lookVector:Dot(direction)

        for _, v in next, character:GetChildren() do
            if not v:IsA('BasePart') then continue end
            if not v.Name:lower():find('catch') then continue end

            local distance = (ball.Position - v.Position).Magnitude

            if dot > 0 and distance <= magEnhancerRadius.Value then
                tweenService:Create(v, TweenInfo.new(0), {Position = ball.Position}):Play()

                pcall(function()
                    firetouchinterest(v, ball, 0)
                    firetouchinterest(v, ball, 1)
                end)
            end
        end
    end
end)
    
CatchingTab:CreateDivider()

pullVector = CatchingTab:CreateToggle({
    Name = 'Enable Pull Vector',
    Default = false,
    Tip = 'Pulls nearby footballs toward your catch position.',
})

pullVectorRadius = CatchingTab:CreateSlider({
    Name = 'Pull Vector Radius',
    Min = 0,
    Max = 45,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets the maximum distance footballs can be pulled from.',
})

pullVectorPower = CatchingTab:CreateSlider({
    Name = 'Pull Vector Power',
    Min = 0,
    Max = 5,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Controls how strongly footballs are pulled toward you.',
})

task.spawn(function()
    while true do
        task.wait()

        if not pullVector.Value then continue end

        local character = player.Character
        if not character then continue end

        local humanoidRootPart = character:FindFirstChild('HumanoidRootPart')
        if not humanoidRootPart then continue end

        local ball = findClosestBall()
        if not ball then continue end

        local distance = (ball.Position - humanoidRootPart.Position).Magnitude
        if distance > pullVectorRadius.Value then continue end

        local direction = (ball.Position - humanoidRootPart.Position).Unit
        humanoidRootPart.AssemblyLinearVelocity = direction * (pullVectorPower.Value * 25)
    end
end)

CatchingTab:CreateDivider()

increaseArmSize = CatchingTab:CreateToggle({
    Name = 'Increase Arm Size',
    Default = false,
    Tip = 'Increases arm size to improve catch reach.',
})

armSizeValue = CatchingTab:CreateSlider({
    Name = 'Arm Size Value',
    Min = 2,
    Max = 25,
    Default = 2,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets the size applied to both arms.',
})

task.spawn(function()
    while true do
        task.wait()

        local character = player.Character
        if not character then continue end

        for _, v in next, character:GetChildren() do
            if not v:IsA('BasePart') then continue end
            if not v.Name:lower():find('t arm') then continue end

            v.Size = Vector3.new(v.Size.X, increaseArmSize.Value and armSizeValue.Value or 2, v.Size.Z)
        end
    end
end)
    
local PlayerTab = Window:CreateTab({ Name = 'Player', Icon = 'rbxassetid://103807548355126' })

customWalkSpeed = PlayerTab:CreateToggle({
    Name = 'Custom WalkSpeed',
    Default = false,
    Tip = 'Overrides your character movement speed.',
})

walkSpeedValue = PlayerTab:CreateSlider({
    Name = 'WalkSpeed Value',
    Min = 20,
    Max = 23,
    Default = 20,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets the movement speed value.',
})

walkspeedType = PlayerTab:CreateDropdown({
    Name = 'WalkSpeed Type',
    Options = {'Normal', 'CFrame'},
    Default = 'Normal',
    Tip = 'Selects how movement speed is applied.',
})

task.spawn(function()
    while true do
        task.wait()
        
        if not customWalkSpeed.Value then continue end

        local character = player.Character
        if not character then continue end

        local humanoid = character:FindFirstChildOfClass('Humanoid')
        if not humanoid then continue end
        if humanoid.PlatformStand then continue end
        if humanoid.WalkSpeed == 0 then continue end

        local root = character:FindFirstChild('HumanoidRootPart')
        if not root then continue end

        local direction = Vector3.new(humanoid.MoveDirection.X, 0, humanoid.MoveDirection.Z)
        if direction.Magnitude <= 0 then continue end

        local velocity = direction.Unit * (walkspeedType.Value == 'CFrame' and (walkSpeedValue.Value / 75) or walkSpeedValue.Value)

        if humanoid:GetState() == Enum.HumanoidStateType.Running then
            local scale = walkSpeedValue.Value / math.max(humanoid.WalkSpeed, 1)

            local animator = humanoid:FindFirstChildOfClass('Animator')
            if animator then
                for _, track in next, animator:GetPlayingAnimationTracks() do
                    track:AdjustSpeed(scale)
                end
            end
        end

        if walkspeedType.Value ~= 'CFrame' then
            root.AssemblyLinearVelocity = Vector3.new(velocity.X, root.AssemblyLinearVelocity.Y, velocity.Z)
        else
            root.CFrame = root.CFrame + velocity
        end
    end
end)

PlayerTab:CreateDivider()

customJumpPower = PlayerTab:CreateToggle({
    Name = 'Custom JumpPower',
    Default = false,
    Tip = 'Overrides your character jump power.',
})

jumpPowerValue = PlayerTab:CreateSlider({
    Name = 'JumpPower Value',
    Min = 50,
    Max = 70,
    Default = 50,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets the custom jump power.',
})

task.spawn(function()
    while true do
        task.wait()

        if not customJumpPower.Value then continue end
        local character = player.Character
        if not character then continue end

        local humanoid = character:FindFirstChildOfClass('Humanoid')
        if not humanoid then continue end

        local root = character:FindFirstChild('HumanoidRootPart')
        if not root then continue end

        if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then continue end
        
        task.wait()
        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, jumpPowerValue.Value, root.AssemblyLinearVelocity.Z)
    end
end)
    
PlayerTab:CreateDivider()

angleEnhancer = PlayerTab:CreateToggle({
    Name = 'Angle Enhancer',
    Default = false,
    Tip = 'Boosts jump height when directional look changes while jumping.',
})

angleEnhancerIndicator = PlayerTab:CreateToggle({
    Name = 'Angle Enhancer Indicator',
    Default = false,
    Tip = 'Showsa notification when an angle boost is triggered.',
})
    
    autoFlip = PlayerTab:CreateToggle({
    Name = 'Auto Flip Before Landing',
    Default = false,
    Tip = 'Automatically adjusts player orientation before landing.',
})

angleEnhanceBoost = PlayerTab:CreateSlider({
    Name = 'Angle Boost Value',
    Min = 50,
    Max = 70,
    Default = 50,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets the vertical velocity applied during angle boost.',
})
    
local lastTick = 0
local oldLookVector = nil

task.spawn(function()
    while true do
        task.wait()

        if not angleEnhancer.Value then continue end

        local character = player.Character
        if not character then oldLookVector = nil continue end

        local humanoid = character:FindFirstChildOfClass('Humanoid')
        local hrp = character:FindFirstChild('HumanoidRootPart')
        if not humanoid or not hrp then oldLookVector = nil continue end

        if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
            continue
        end

        local currentTime = tick()
        local newLookVector = hrp.CFrame.LookVector

        if not oldLookVector then
            oldLookVector = newLookVector
            lastTick = currentTime
            continue
        end

        local angleChange = math.acos(math.clamp(oldLookVector:Dot(newLookVector), -1, 1))
        local shiftLockEnabled = userInputService.MouseBehavior == Enum.MouseBehavior.LockCenter

        if currentTime - lastTick >= 0.2 and angleChange > math.rad(5) then
            lastTick = currentTime
            oldLookVector = newLookVector
        end

        if angleChange > math.rad(25) and currentTime - lastTick <= 2.5 then
            lastTick = currentTime
            oldLookVector = newLookVector

            task.wait()

            local vel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, angleEnhanceBoost.Value, vel.Z)

            if angleEnhancerIndicator.Value and (shiftLockEnabled or true) then
                local hint = Instance.new('Hint')
                hint.Text = 'Angled!'
                hint.Parent = workspace.Terrain

                task.delay(2.5, function()
                    if hint then
                        hint:Destroy()
                    end
                end)
            end
        end
    end
end)
    
local runtime, jumptime, hittime = 0, 0, 0
local arm, vLine, used, prevPs = false, nil, false, false
local seq = 0
local pack = nil

local xz = function(v: Vector3)
	local f = Vector3.new(v.X, 0, v.Z)
	return f.Magnitude > 0.001 and f.Unit or nil
end

local reset = function()
	if not pack then return end
	for _, o in next, { pack.spin, pack.ra, pack.pivot, pack.ha } do
		if o then o:Destroy() end
	end
	pack = nil
end

local flip = function(root: BasePart, head: BasePart)
	reset()

	local m = math.max(root.AssemblyMass, 1)

	local ha = Instance.new("Attachment")
	ha.Parent = head

	local pivot = Instance.new("AlignPosition")
	pivot.Mode = Enum.PositionAlignmentMode.OneAttachment
	pivot.Attachment0 = ha
	pivot.Position = head.Position + Vector3.new(0, 0.15, 0)
	pivot.MaxForce = 180000
	pivot.Responsiveness = 120
	pivot.RigidityEnabled = false
	pivot.ApplyAtCenterOfMass = false
	pivot.Parent = head

	local ra = Instance.new("Attachment")
	ra.Parent = root

	local spin = Instance.new("AngularVelocity")
	spin.Attachment0 = ra
	spin.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	spin.AngularVelocity = Vector3.new(-9, 0, 0)
	spin.MaxTorque = 50000
	spin.Parent = root

	root:ApplyAngularImpulse(root.CFrame.RightVector * (-16 * m))

	pack = { ha = ha, pivot = pivot, ra = ra, spin = spin }
end

task.spawn(function()
	while true do
		task.wait()
	    
	    if not autoFlip.Value then continue end
	    
		local char = player.Character
		if not char then
			reset()
			arm, vLine, used, prevPs = false, nil, false, false
			continue
		end

		local hum = char:FindFirstChildOfClass("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local head = char:FindFirstChild("Head")

		if not hum or not hrp or not head then continue end

		local now = tick()

		if hum:GetState() == Enum.HumanoidStateType.Running then runtime = now end
		if hum:GetState() == Enum.HumanoidStateType.Jumping then jumptime = now end

		local ps = hum.PlatformStand
		if ps ~= prevPs then
			if ps then
				arm = (now - runtime <= 0.5) and (now - jumptime <= 0.7)
				vLine = xz(hrp.AssemblyLinearVelocity) or xz(hrp.CFrame.LookVector)
				used = false
			else
				arm, vLine, used = false, nil, false
				seq += 1
				reset()
			end
			prevPs = ps
		end

		if not ps or not arm or pack then continue end

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { char }

		local result = workspace:Raycast(head.Position, Vector3.new(0, -3, 0), params)
		local ground = result and result.Instance ~= nil

		if used or not ground or now - hittime < 0.12 then continue end

		local dist = result and (head.Position - result.Position).Magnitude or math.huge
		if dist > 1.6 then continue end

		local move = xz(hrp.AssemblyLinearVelocity) or vLine
		local face = xz(hrp.CFrame.LookVector)

		if not move or not face or face:Dot(move) < 0.78 then continue end

		hittime = now
		used = true
		seq += 1
		local k = seq

		flip(hrp, head)

		task.delay(0.24, function()
			if k == seq then
				reset()
			end
		end)
	end
end)

PlayerTab:CreateDivider()

PlayerTab:CreateButton({
    Name = 'Unlock All Gamepass',
    Tip = 'Enables all gamepass-related checks locally.',
    Callback = function()
        local replicatedFirst = game:GetService('ReplicatedFirst')

        local module
        local success = pcall(function()
            module = require(replicatedFirst:FindFirstChild('LocalSave'))
        end)

        if not success or not module then
            return
        end

        module.PlayerOwnsPass = function(a, b)
            return true
        end
    end
})

local PhysicsTab = Window:CreateTab({ Name = 'Physics', Icon = 'rbxassetid://11537490966' })
    
local boundaries = {}

if not isPractice then
    for i, v in next, workspace.Models.Boundaries:GetChildren() do
        boundaries[#boundaries + 1] = v
    end
end

antiBoundaries = PhysicsTab:CreateToggle({
    Name = 'Anti OOB',
    Default = false,
    Tip = 'Prevents players from triggering out-of-bounds zones.',
    Callback = function(v)
        for i, b in next, boundaries do
            if b then
                b.Parent = not v and workspace.Models.Boundaries or nil
            end
        end
    end
})
    
    antiBench = PhysicsTab:CreateToggle({
    Name = 'Anti Bench',
    Default = false,
    Tip = 'Prevents automatic benching.',
})

task.spawn(function()
    while true do
        task.wait()

        if not antiBench.Value then continue end

        local playerGui = player:FindFirstChild('PlayerGui')
        if not playerGui then continue end

        local benchButton = playerGui:FindFirstChild('Benched', true)
        if not benchButton then continue end

        if benchButton.BackgroundColor3 == Color3.fromRGB(120, 120, 120) then
            replicatedStorage.Remotes.CharacterSoundEvent:FireServer('Game', 'ToggleBench')
        end
    end
end)
--[[
local scrambleWall = workspace:FindFirstChild('ScrambleWall')

antiQbBoundaries = PhysicsTab:CreateToggle({
    Name = 'Anti QB Boundaries',
    Default = false,
    Tip = 'Disables invisible QB boundary walls.',
    Callback = function(v)
        if not scrambleWall then return end
        scrambleWall.Parent = v and nil or workspace
    end
})
    ]]
PhysicsTab:CreateDivider()

antiJam = PhysicsTab:CreateToggle({
    Name = 'Anti Jam',
    Default = false,
    Tip = 'Reduces player collision while moving.',
})

antiJumpCooldown = PhysicsTab:CreateToggle({
    Name = 'Anti Jump Cooldown',
    Default = false,
    Tip = 'Removes the delay between jumps.',
})

antiFreeze = PhysicsTab:CreateToggle({
    Name = 'Anti Freeze',
    Default = false,
    Tip = 'Prevents movement speed from being reduced.',
})

task.spawn(function()
    while true do
        task.wait()
        
        if antiJumpCooldown.Value then
            player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        end
        
        if antiFreeze.Value then
            if player.Character.Humanoid.WalkSpeed ~= 20 then
                player.Character.Humanoid.WalkSpeed = 20
            end
        end

        for _, v in next, players:GetPlayers() do
            if v == player then continue end

            local character = v.Character
            if not character then continue end

            local hum = character:FindFirstChildOfClass('Humanoid')
            if not hum then continue end

            for _, part in next, character:GetChildren() do
                if not part:IsA('BasePart') then continue end
                if part.Name == 'Head' or part.Name == 'Torso' then
                    if hum:GetState() == Enum.HumanoidStateType.Running then
                        part.CanCollide = not antiJam.Value
                    else
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end)

antiBlock = PhysicsTab:CreateToggle({
    Name = 'Anti Block',
    Default = false,
    Tip = 'Reduces player collision while moving.',
})
    
task.spawn(function()
    while true do
        task.wait()

        if not antiBlock.Value then continue end

        local character = player.Character
        if not character then continue end

        local humanoid = character:FindFirstChildOfClass('Humanoid')
        if not humanoid then continue end

        for _, v in next, character:GetDescendants() do
            if not v:IsA('BodyVelocity') then continue end
            -- if not v.Name:lower():find('ffmover') then continue end

            v.Velocity = Vector3.zero
            v.MaxForce = Vector3.zero
            humanoid.WalkSpeed = 20

            pcall(function()
                v:Destroy()
            end)
        end
    end
end)

PhysicsTab:CreateDivider()

quickTP = PhysicsTab:CreateToggle({
    Name = 'Quick TP',
    Default = false,
    Tip = 'Teleports forward in the direction you are facing.',
})

quickTPPower = PhysicsTab:CreateSlider({
    Name = 'Quick TP Power',
    Min = 0,
    Max = 5,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets the teleport distance.',
})

HideKeybind = PhysicsTab:CreateKeybind({
    Name = 'Quick TP Keybind',
    Default = Enum.KeyCode.Q,
    Tip = 'Key used to activate Quick TP.',
})

userInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not quickTP.Value then return end
    if input.KeyCode ~= HideKeybind.Value and input.UserInputType ~= Enum.UserInputType.Touch then return end

    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild('HumanoidRootPart')
    if not hrp then return end

    hrp.CFrame += hrp.CFrame.LookVector * quickTPPower.Value
end)
    
PhysicsTab:CreateDivider()

bigHead = PhysicsTab:CreateToggle({
    Name = 'Big Head Players',
    Default = false,
    Tip = 'Increases the size of other players heads.',
})

bigHeadSize = PhysicsTab:CreateSlider({
    Name = 'Big Head Size',
    Min = 1,
    Max = 6,
    Default = 1,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets the size applied to player heads.',
})

task.spawn(function()
    while true do
        task.wait()

        for _, v in next, players:GetPlayers() do
            if v == player then continue end

            local character = v.Character
            if not character then continue end

            local head = character:FindFirstChild('Head')
            if not head then continue end

            head.Size = Vector3.new(bigHead.Value and bigHeadSize.Value or 1, bigHead.Value and bigHeadSize.Value or 1, bigHead.Value and bigHeadSize.Value or 1)
        end
    end
end)
    
local VisualTab = Window:CreateTab({ Name = 'Visual', Icon = 'rbxassetid://88610077537468' })

jumpSpot = VisualTab:CreateToggle({
    Name = 'Visualise Football Jump Spot',
    Default = false,
    Tip = 'Displays the predicted jump location of incoming footballs.',
})

workspace.ChildAdded:Connect(function(v)
    if not jumpSpot.Value then return end
    if not v:IsA('BasePart') or v.Name ~= 'Football' then return end

    task.wait()

    local position = v.Position
    local velocity = v.AssemblyLinearVelocity
    local gravity = Vector3.new(0, -28, 0)
    local deltaTime = 1 / 30

    local positions = {position}

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {v}
    raycastParams.IgnoreWater = true

    for _ = 1, 300 do
        local nextPosition = position + velocity * deltaTime + 0.5 * gravity * deltaTime ^ 2
        velocity += gravity * deltaTime

        if velocity.Y < 0 then
            local direction = nextPosition - position
            local result = workspace:Raycast(position, direction + Vector3.new(0, -14.4, 0), raycastParams)

            if result then
                nextPosition = result.Position
                table.insert(positions, nextPosition)
                break
            end
        end

        table.insert(positions, nextPosition)
        position = nextPosition
    end

    local optimalPoint = positions[#positions]
    
    local model = Instance.new('Model')
    model.Parent = workspace

    local baseY = optimalPoint.Y - 1.5
    local undergroundY = baseY - 6

    local gradientCylinder = Instance.new('MeshPart')
    gradientCylinder.MeshId = 'rbxassetid://8091779363'
    gradientCylinder.Material = Enum.Material.Plastic
    gradientCylinder.Size = Vector3.new(2, 4, 2)
    gradientCylinder.Rotation = Vector3.new(180, 0, 180)
    gradientCylinder.Transparency = 1
    gradientCylinder.Anchored = true
    gradientCylinder.CanCollide = false
    gradientCylinder.Position = Vector3.new(optimalPoint.X, undergroundY, optimalPoint.Z)
    gradientCylinder.Parent = model

    local faces = {
        Enum.NormalId.Front,
        Enum.NormalId.Back,
        Enum.NormalId.Left,
        Enum.NormalId.Right
    }

    for _, face in next, faces do
        local decal = Instance.new('Decal')
        decal.Face = face
        decal.Texture = 'rbxassetid://8097185954'
        decal.Transparency = 0
        decal.Color3 = Color3.fromRGB(255, 255, 255)
        decal.Parent = gradientCylinder
    end

    local glowCircle = Instance.new('MeshPart')
    glowCircle.MeshId = 'rbxassetid://8091848285'
    glowCircle.Material = Enum.Material.Neon
    glowCircle.Color = Color3.fromRGB(255, 255, 255)
    glowCircle.Size = Vector3.new(3.731, 0.031, 3.731)
    glowCircle.Rotation = Vector3.new(180, 0, 180)
    glowCircle.Transparency = 1
    glowCircle.Anchored = true
    glowCircle.CanCollide = false
    glowCircle.Position = Vector3.new(optimalPoint.X, undergroundY, optimalPoint.Z)
    glowCircle.Parent = model

    local emitter = Instance.new('ParticleEmitter')
    emitter.Texture = 'rbxasset://textures/particles/sparkles_main.dds'
    emitter.Rate = 5
    emitter.Speed = NumberRange.new(5, 5)
    emitter.Lifetime = NumberRange.new(0.5, 0.5)
    emitter.EmissionDirection = Enum.NormalId.Top
    emitter.TimeScale = 0.3
    emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    emitter.Parent = gradientCylinder

    local bottomPart = Instance.new('Part')
    bottomPart.Size = Vector3.new(0.311, 0.311, 0.311)
    bottomPart.Transparency = 1
    bottomPart.Material = Enum.Material.Plastic
    bottomPart.Anchored = true
    bottomPart.CanCollide = false
    bottomPart.Position = Vector3.new(optimalPoint.X, undergroundY, optimalPoint.Z)
    bottomPart.Parent = model

    local pointLight = Instance.new('PointLight')
    pointLight.Color = Color3.fromRGB(255, 255, 255)
    pointLight.Range = 12
    pointLight.Brightness = 2
    pointLight.Parent = bottomPart

    local tweenInfo = TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local upGoal = {
        Position = Vector3.new(optimalPoint.X, baseY, optimalPoint.Z)
    }

    local downGoal = {
        Position = Vector3.new(optimalPoint.X, undergroundY, optimalPoint.Z)
    }

    local upTweens = {
        tweenService:Create(gradientCylinder, tweenInfo, upGoal),
        tweenService:Create(glowCircle, tweenInfo, upGoal),
        tweenService:Create(bottomPart, tweenInfo, upGoal)
    }

    for _, t in next, upTweens do
        t:Play()
    end

    task.spawn(function()
        while v and v.Parent and v.AssemblyLinearVelocity.Magnitude > 1 do
            task.wait()
        end

        local downTweens = {
            tweenService:Create(gradientCylinder, tweenInfo, downGoal),
            tweenService:Create(glowCircle, tweenInfo, downGoal),
            tweenService:Create(bottomPart, tweenInfo, downGoal)
        }

        for _, t in next, downTweens do
            t:Play()
        end

        task.wait(0.4)

        if model.Parent then
            model:Destroy()
        end
    end)
end)
    
    throwSpot = VisualTab:CreateToggle({
    Name = 'Visualise Football Throw Spot',
    Default = false,
    Tip = 'Shows the predicted landing point of thrown footballs.',
})
    
    workspace.ChildAdded:Connect(function(v)
        if not throwSpot.Value then return end
    if not v:IsA('BasePart') or v.Name ~= 'Football' then return end

    task.wait()

    local pos = v.Position
    local vel = v.AssemblyLinearVelocity
    local gravity = Vector3.new(0, -28, 0)

    local positions = {}
    local parts = {}

    local dt = 0.05
    local maxTime = 8

    local lastPos = pos
    local spawnY = pos.Y

    for t = 0, maxTime, dt do
        local projectilePos = pos + (vel * t) + (0.5 * gravity * t * t)

        table.insert(positions, projectilePos)

        if projectilePos.Y < spawnY then
            break
        end

        local ray = workspace:Raycast(lastPos, projectilePos - lastPos)
        if ray then
            positions[#positions] = ray.Position
            break
        end

        lastPos = projectilePos
    end

    local endPos = positions[#positions]
    if not endPos then return end

    local posPart = Instance.new('Part', workspace.Terrain)
    posPart.Anchored = true
    posPart.CanCollide = false
    posPart.CastShadow = false
    posPart.Size = Vector3.new(3, 3, 3)
    posPart.Shape = Enum.PartType.Ball
    posPart.Color = Color3.fromRGB(0, 0, 0)
    posPart.Position = endPos

    for i = 1, #positions - 1 do
        local p0 = positions[i]
        local p1 = positions[i + 1]

        local beamPart = Instance.new('Part', workspace.Terrain)
        beamPart.Anchored = true
        beamPart.CanCollide = false
        beamPart.CastShadow = false
        beamPart.Material = Enum.Material.Neon
        beamPart.Color = Color3.fromRGB(255, 255, 255)

        local dist = (p1 - p0).Magnitude

        beamPart.Size = Vector3.new(0.4, 0.4, dist)
        beamPart.CFrame = CFrame.lookAt((p0 + p1) / 2, p1)

        table.insert(parts, beamPart)
    end

    task.spawn(function()
        local speed = math.max(vel.Magnitude, 1)
        local delayTime = math.clamp(300 / speed, 0.01, 0.04)

        for _, part in next, parts do
            task.wait(delayTime)

            if part.Parent then
                part:Destroy()
            end
        end

        if posPart.Parent then
            posPart:Destroy()
        end
    end)
end)
    
VisualTab:CreateDivider()
    
enableGloves = VisualTab:CreateToggle({
    Name = 'Enable Uniform Gloves',
    Default = true,
    Tip = 'Toggles visibility of uniform gloves.',
})

task.spawn(function()
    while true do
        task.wait()

        local character = player.Character
        if not character then continue end

        local uniform = character:FindFirstChild('Uniform')
        if not uniform then continue end

        local gloveVisible

        for _, v in next, uniform:GetDescendants() do
            if not v:IsA('BasePart') then continue end
            if not v.Name:lower():find('glove') then continue end

            gloveVisible = v.Transparency == 0
            break
        end

        if gloveVisible == nil then continue end

        if enableGloves.Value and not gloveVisible then
            replicatedStorage.Remotes.CharacterSoundEvent:FireServer('Game', 'Customization', 'Toggle', 'LeftGlove')
            replicatedStorage.Remotes.CharacterSoundEvent:FireServer('Game', 'Customization', 'Toggle', 'RightGlove')
        elseif not enableGloves.Value and gloveVisible then
            replicatedStorage.Remotes.CharacterSoundEvent:FireServer('Game', 'Customization', 'Toggle', 'LeftGlove')
            replicatedStorage.Remotes.CharacterSoundEvent:FireServer('Game', 'Customization', 'Toggle', 'RightGlove')
        end
    end
end)

VisualTab:CreateDivider()
    
noBallTrail = VisualTab:CreateToggle({
    Name = 'No Ball Trail',
    Default = false,
    Tip = 'Removes football trail effects.',
})

workspace.ChildAdded:Connect(function(v)
    if not noBallTrail.Value then return end

    if v:IsA('BasePart') and v.Name == 'Football' then
        local trail = v:FindFirstChildOfClass('Trail')
        if trail then
            trail:Destroy()
        end
    end
end)

local stadiumParts = {}

for _, v in next, workspace.Models.Stadium:GetDescendants() do
    if not v:IsA('BasePart') then continue end

    stadiumParts[#stadiumParts + 1] = {
        Part = v,
        Transparency = v.Transparency,
        CanCollide = v.CanCollide
    }
end

hideStadium = VisualTab:CreateToggle({
    Name = 'Hide Stadium',
    Default = false,
    Tip = 'Hides visible stadium structures.',
    Callback = function(v)
        for _, p in next, stadiumParts do
            p.Part.Transparency = v and 1 or p.Transparency
            p.Part.CanCollide = v and false or p.CanCollide
        end
    end
})

VisualTab:CreateDivider()

local lighting = game:GetService('Lighting')

local function ApplySkyBox(name)
    for _, v in next, lighting:GetChildren() do
        if v:IsA("Sky") or v:IsA("PostEffect") or v:IsA("Atmosphere") then
            v:Destroy()
        end
    end

    if name == "Golden Twilight" then
        local Sky = Instance.new("Sky")
        Sky.Name = name
        Sky.Parent = lighting
        Sky.SkyboxBk = "rbxassetid://541743453"
        Sky.SkyboxDn = "rbxassetid://541743443"
        Sky.SkyboxFt = "rbxassetid://541743446"
        Sky.SkyboxLf = "rbxassetid://541743436"
        Sky.SkyboxRt = "rbxassetid://541743435"
        Sky.SkyboxUp = "rbxassetid://541743441"

    elseif name == "Infernal Horizon" then
        local Sky = Instance.new("Sky")
        Sky.Name = name
        Sky.Parent = lighting
        Sky.SkyboxBk = "http://www.roblox.com/asset/?id=169210090"
        Sky.SkyboxDn = "http://www.roblox.com/asset/?id=169210108"
        Sky.SkyboxFt = "http://www.roblox.com/asset/?id=169210121"
        Sky.SkyboxLf = "http://www.roblox.com/asset/?id=169210133"
        Sky.SkyboxRt = "http://www.roblox.com/asset/?id=169210143"
        Sky.SkyboxUp = "http://www.roblox.com/asset/?id=169210149"
        Sky.StarCount = 100
        Sky.SunTextureId = " "

        local BlurEffect = Instance.new("BlurEffect")
        BlurEffect.Parent = lighting
        BlurEffect.Size = 6

        local ColorCorrectionEffect = Instance.new("ColorCorrectionEffect")
        ColorCorrectionEffect.Parent = lighting
        ColorCorrectionEffect.Brightness = 0.01
        ColorCorrectionEffect.Contrast = 0.15
        ColorCorrectionEffect.Saturation = 0.4
        ColorCorrectionEffect.TintColor = Color3.new(0.815686, 0.776471, 0.690196)

    elseif name == "Nebula Peaks" then
        local Sky = Instance.new("Sky")
        Sky.Name = name
        Sky.Parent = lighting
        Sky.CelestialBodiesShown = false
        Sky.SkyboxBk = "http://www.roblox.com/asset/?id=17124357467"
        Sky.SkyboxDn = "http://www.roblox.com/asset/?id=17124359797"
        Sky.SkyboxFt = "http://www.roblox.com/asset/?id=17124362093"
        Sky.SkyboxLf = "http://www.roblox.com/asset/?id=17124365127"
        Sky.SkyboxRt = "http://www.roblox.com/asset/?id=17124367200"
        Sky.SkyboxUp = "http://www.roblox.com/asset/?id=17124369657"

        local cc = Instance.new("ColorCorrectionEffect")
        cc.Parent = lighting
        cc.Brightness = 0.1
        cc.Contrast = 0.3
        cc.Saturation = 0.2
        cc.TintColor = Color3.fromRGB(140, 190, 255)

        local bloom = Instance.new("BloomEffect")
        bloom.Parent = lighting
        bloom.Intensity = 1.2
        bloom.Threshold = 0.8
        bloom.Size = 56

        local atmosphere = Instance.new("Atmosphere")
        atmosphere.Parent = lighting
        atmosphere.Density = 0.25
        atmosphere.Offset = 0.2
        atmosphere.Glare = 0.3
        atmosphere.Haze = 1
        atmosphere.Color = Color3.fromRGB(80, 110, 150)
        atmosphere.Decay = Color3.fromRGB(25, 30, 35)

    elseif name == "Rose Glow" then
        local Sky = Instance.new("Sky")
        Sky.Name = name
        Sky.Parent = lighting
        Sky.CelestialBodiesShown = false
        Sky.SkyboxBk = "http://www.roblox.com/asset/?id=109305193"
        Sky.SkyboxDn = "http://www.roblox.com/asset?id=58372722"
        Sky.SkyboxFt = "http://www.roblox.com/asset/?id=109305200"
        Sky.SkyboxLf = "http://www.roblox.com/asset/?id=109305185"
        Sky.SkyboxRt = "http://www.roblox.com/asset/?id=109305189"
        Sky.SkyboxUp = "http://www.roblox.com/asset/?id=109305207"

    elseif name == "Night Sky" then
        local Sky = Instance.new("Sky")
        Sky.Name = name
        Sky.Parent = lighting
        Sky.CelestialBodiesShown = false
        Sky.SkyboxBk = "http://www.roblox.com/Asset/?ID=12064107"
        Sky.SkyboxDn = "http://www.roblox.com/Asset/?ID=12064152"
        Sky.SkyboxFt = "http://www.roblox.com/Asset/?ID=12064121"
        Sky.SkyboxLf = "http://www.roblox.com/Asset/?ID=12063984"
        Sky.SkyboxRt = "http://www.roblox.com/Asset/?ID=12064115"
        Sky.SkyboxUp = "http://www.roblox.com/Asset/?ID=12064131"
        Sky.StarCount = 0

    elseif name == "Northern Lights" then
        local Sky = Instance.new("Sky")
        Sky.Name = name
        Sky.Parent = lighting
        Sky.CelestialBodiesShown = false
        Sky.SkyboxBk = "http://www.roblox.com/asset/?id=16563478983"
        Sky.SkyboxDn = "http://www.roblox.com/asset/?id=16563481302"
        Sky.SkyboxFt = "http://www.roblox.com/asset/?id=16563484084"
        Sky.SkyboxLf = "http://www.roblox.com/asset/?id=16563485362"
        Sky.SkyboxRt = "http://www.roblox.com/asset/?id=16563487078"
        Sky.SkyboxUp = "http://www.roblox.com/asset/?id=16563489821"
    end
end

local skyNames = {'Golden Twilight', 'Infernal Horizon', 'Nebula Peaks', 'Rose Glow', 'Night Sky', 'Northern Lights'}

for _, skyName in next, skyNames do
    VisualTab:CreateButton({
        Name = skyName,
        Tip = 'Applies the ' .. skyName .. ' skybox.',
        Callback = function()
            ApplySkyBox(skyName)
        end
    })
end

local DefenseTab = Window:CreateTab({ Name = 'Defense', Icon = 'rbxassetid://14939023862' })

swatReach = DefenseTab:CreateToggle({
    Name = 'Swat Reach',
    Default = false,
    Tip = 'Extends swat range on nearby footballs.',
})

swatReachDistance = DefenseTab:CreateSlider({
    Name = 'Swat Reach Radius',
    Min = 0,
    Max = 25,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets the maximum swat distance.',
})

task.spawn(function()
    while true do
        task.wait()

        if not swatReach.Value then continue end

        local character = player.Character
        if not character then continue end

        local ball = findClosestBall()
        if not ball then continue end

        for _, v in next, character:GetChildren() do
            if v:IsA('BasePart') and v.Name:lower():find('catch') then
                local distance = (ball.Position - v.Position).Magnitude
                if distance < swatReachDistance.Value then
                    if v.Size.X > 2 then
                        firetouchinterest(v, ball, 0)
                        firetouchinterest(v, ball, 1)
                    end
                end
            end
        end
    end
end)

DefenseTab:CreateDivider()

tackleReach = DefenseTab:CreateToggle({
    Name = 'Extend Tackle Reach',
    Default = false,
    Tip = 'Extends tackle range against ball carriers.',
})

tackleAimbot = DefenseTab:CreateToggle({
    Name = 'Tackle Aimbot',
    Default = false,
    Tip = 'Automatically targets nearby ball carriers.',
})

tackleAimbotRange = DefenseTab:CreateSlider({
    Name = 'Tackle Aimbot Distance',
    Min = 0,
    Max = 25,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets the maximum targeting distance.',
})

task.spawn(function()
    while true do
        task.wait()

        local character = player.Character
        if not character then continue end

        if tackleReach.Value then
            for _, v in next, players:GetPlayers() do
                if v ~= player and v.Team ~= player.Team and v.Character and v.Character:FindFirstChild('Football') then
                    local bodyParts = {'Torso', 'Head', 'HumanoidRootPart', 'Left Arm', 'Left Leg', 'Right Arm', 'Right Leg'}
                    local randomPart = bodyParts[math.random(1, #bodyParts)]

                    replicatedStorage.Remotes.CharacterSoundEvent:FireServer('Game', 'TackleTouch', randomPart, randomPart)
                end
            end
        end

        if tackleAimbot.Value then
            for _, v in next, players:GetPlayers() do
                if v ~= player and v.Team ~= player.Team and v.Character and v.Character.Humanoid.WalkSpeed > 0 and v.Character:FindFirstChild('Football') then
                    local distance = (v.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                    if distance < tackleAimbotRange.Value then
                        character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
                        character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame
                    end
                end
            end
        end
    end
end)

local AutomaticsTab = Window:CreateTab({ Name = 'Automatics', Icon = 'rbxassetid://86084882582277' })

autoRush = AutomaticsTab:CreateToggle({
    Name = 'Auto Rush',
    Default = false,
    Tip = 'Automatically moves toward the opposing ball carrier in range.',
})

walkToLine = AutomaticsTab:CreateToggle({
    Name = 'Walk To Line',
    Default = false,
    Tip = 'Moves the player to the line before play starts.',
})

autoRushReactionTime = AutomaticsTab:CreateSlider({
    Name = 'Reaction Time',
    Min = 0,
    Max = 1,
    Default = 0.15,
    Increment = 0.01,
    Suffix = '',
    Tip = 'Adjusts how quickly the feature responds.',
})

task.spawn(function()
    while true do
        task.wait()

        if not autoRush.Value then continue end

        local character = player.Character
        if not character then continue end

        local humanoid = character:FindFirstChildOfClass('Humanoid')
        if not humanoid then continue end

        local hrp = character:FindFirstChild('HumanoidRootPart')
        if not hrp then continue end

        if walkToLine.Value then
            if replicatedStorage:FindFirstChild('Flags')
                and replicatedStorage.Flags:FindFirstChild('PossessionTag')
                and replicatedStorage.Flags:FindFirstChild('Status')
                and replicatedStorage.Flags.PossessionTag.Value ~= player.Team.Name
                and replicatedStorage.Flags.Status.Value == 'PrePlay' then

                local line = workspace:FindFirstChild('LineDown')
                if line then
                    humanoid:MoveTo(line.Position)
                end
            end
        end

        for _, v in next, players:GetPlayers() do
            if v == player then continue end
            if v.Team == player.Team then continue end
            if not v.Character then continue end

            local enemyChar = v.Character
            local enemyHumanoid = enemyChar:FindFirstChildOfClass('Humanoid')
            local enemyHrp = enemyChar:FindFirstChild('HumanoidRootPart')
            if not enemyHumanoid or not enemyHrp then continue end

            local football = enemyChar:FindFirstChild('Football')
            if not football then continue end

            local footballPart = football:FindFirstChildWhichIsA('BasePart')
            if not footballPart then continue end

            if enemyHumanoid.WalkSpeed <= 0 then continue end
            if enemyHumanoid.PlatformStand then continue end

            local ping = 0
            if stats and stats:FindFirstChild('Network') 
                and stats.Network:FindFirstChild('ServerStatsItem')
                and stats.Network.ServerStatsItem:FindFirstChild('Data Ping') then
                ping = stats.Network.ServerStatsItem['Data Ping']:GetValue() / 1000
            end

            local speed = enemyHumanoid.MoveDirection.Magnitude > 0 and enemyHumanoid.WalkSpeed or 0
            local predictionTime = ping + autoRushReactionTime.Value

            local pos = footballPart.Position + (enemyHumanoid.MoveDirection * speed * predictionTime * 20)

            local direction = pos - enemyHrp.Position
            if direction.Magnitude > 0 then
                pos += direction.Unit * ((hrp.Position - pos).Magnitude / 20)
            end

            humanoid:MoveTo(pos)
        end
    end
end)

AutomaticsTab:CreateDivider()

autoCatch = AutomaticsTab:CreateToggle({
    Name = 'Auto Catch',
    Default = false,
    Tip = 'Automatically moves toward nearby catch opportunities.',
})

autoCatchRadius = AutomaticsTab:CreateSlider({
    Name = 'Auto Catch Distance',
    Min = 0,
    Max = 25,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets how far the auto catch detection can reach.',
})
    
AutomaticsTab:CreateDivider()

autoSwat = AutomaticsTab:CreateToggle({
    Name = 'Auto Swat',
    Default = false,
    Tip = 'Automatically reacts to nearby incoming balls.',
})

autoSwatRadius = AutomaticsTab:CreateSlider({
    Name = 'Auto Swat Distance',
    Min = 0,
    Max = 25,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets how far the auto swat detection can reach.',
})

task.spawn(function()
    while true do
        task.wait()

        if not autoCatch.Value and not autoSwat.Value then continue end

        local character = player.Character
        if not character then continue end

        local humanoidRootPart = character:FindFirstChild('HumanoidRootPart')
        if not humanoidRootPart then continue end

        local ball = findClosestBall()
        if not ball then continue end

        local distance = (ball.Position - humanoidRootPart.Position).Magnitude

        if autoCatch.Value and distance <= autoCatchRadius.Value then
            replicatedStorage.Remotes.CharacterSoundEvent:FireServer('PlayerActions', isPractice and 'catch ' or 'catch')
        end

        if autoSwat.Value and distance <= autoSwatRadius.Value then
            replicatedStorage.Remotes.CharacterSoundEvent:FireServer('PlayerActions', 'swat')
        end
    end
end)
    
AutomaticsTab:CreateDivider()
    
autoCaptain = AutomaticsTab:CreateToggle({
    Name = 'Auto Win Captain',
    Default = false,
    Tip = 'Automatically moves toward the finish line during captain selection.',
})

task.spawn(function()
    while true do
        task.wait()

        if not autoCaptain.Value then continue end

        local character = player.Character
        if not character then continue end

        local hrp = character:FindFirstChild('HumanoidRootPart')
        if not hrp then continue end

        for _, v in next, workspace.Models.LockerRoomA:GetChildren() do
            if v.Name:lower():find('finishline') and not player.Team then
                v:GetPropertyChangedSignal('CFrame'):Connect(function()
                    for i = 1, 4 do
                        task.wait()

                        hrp.CFrame = v.CFrame
                    end
                end)
            end
        end
    end
end)
    
AutomaticsTab:CreateDivider()
    
autoFreeze = AutomaticsTab:CreateToggle({
    Name = 'Auto Freeze',
    Default = false,
    Tip = 'Temporarily anchors your character on input.',
})

freezeDuration = AutomaticsTab:CreateSlider({
    Name = 'Freeze Duration',
    Min = 0,
    Max = 3,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Duration the freeze state lasts.',
})

freezeKeybind = AutomaticsTab:CreateKeybind({
    Name = 'Freeze Keybind',
    Default = nil,
    Tip = 'Key used to trigger freeze.',
})

userInputService.InputBegan:Connect(function(input)
    if not autoFreeze.Value then return end
    if freezeKeybind.Value and input.KeyCode ~= freezeKeybind.Value then return end

    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild('HumanoidRootPart')
    if not hrp then return end

    hrp.Anchored = true

    task.delay(freezeDuration.Value, function()
        if hrp then
            hrp.Anchored = false
        end
    end)
end)

AutomaticsTab:CreateDivider()

autoQb = AutomaticsTab:CreateToggle({
    Name = 'Auto QB',
    Default = false,
    Tip = 'Automatically positions your character for quarterback play.',
})

autoQbMethod = AutomaticsTab:CreateDropdown({
    Name = 'Auto QB Method',
    Options = {'Walk', 'Teleport'},
    Default = 'Walk',
    Tip = 'Selects how automatic positioning is performed.',
})

task.spawn(function()
    while true do
        task.wait()

        if not autoQb.Value then continue end

        local character = player.Character
        if not character then continue end

        local humanoid = character:FindFirstChildOfClass('Humanoid')
        local humanoidRootPart = character:FindFirstChild('HumanoidRootPart')
        if not humanoid or not humanoidRootPart then continue end

        local ball = findClosestBall()
        if not ball then continue end

        if replicatedStorage:FindFirstChild('Flags')
            and replicatedStorage.Flags:FindFirstChild('PossessionTag')
            and replicatedStorage.Flags:FindFirstChild('Status')
            and replicatedStorage.Flags.PossessionTag.Value == player.Team.Name
            and replicatedStorage.Flags.Status.Value == 'PrePlay' then

            if autoQbMethod.Value == 'Walk' then
                humanoid:MoveTo(ball.Position)
            elseif autoQbMethod.Value == 'Teleport' then
                humanoidRootPart.CFrame = ball.CFrame
            end
        else
            pcall(function()
                ball.CFrame = humanoidRootPart.CFrame
            end)
        end
    end
end)
    
AutomaticsTab:CreateDivider()
    
    autoBoost = AutomaticsTab:CreateToggle({
    Name = 'Auto Boost',
    Default = false,
    Tip = 'Automatically assists aerial movement near incoming footballs.',
})

targetClosestPlayer = AutomaticsTab:CreateToggle({
    Name = 'Target Player Closer To The Ball',
    Default = false,
    Tip = 'Prioritizes players closest to the football.',
})

boostStrength = AutomaticsTab:CreateSlider({
    Name = 'Boost Strength',
    Min = 0,
    Max = 3,
    Default = 1.5,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Adjusts the strength of the boost effect.',
})

boostRadius = AutomaticsTab:CreateSlider({
    Name = 'Boost Radius',
    Min = 0,
    Max = 15,
    Default = 0,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Sets the activation distance for boosting.',
})

boostPower = AutomaticsTab:CreateSlider({
    Name = 'Boost Power',
    Min = 50,
    Max = 70,
    Default = 50,
    Increment = 0.1,
    Suffix = '',
    Tip = 'Controls the upward force applied during a boost.',
})

task.spawn(function()
    local activeTween

    while true do
        task.wait()

        if not autoBoost.Value then
            if activeTween then
                activeTween:Cancel()
                activeTween = nil
            end

            continue
        end

        local char = player.Character
        if not char then continue end

        local hum = char:FindFirstChildOfClass('Humanoid')
        if not hum then continue end

        local hrp = char:FindFirstChild('HumanoidRootPart')
        if not hrp then continue end

        if hum:GetState() == Enum.HumanoidStateType.Landed then
            if activeTween then
                activeTween:Cancel()
                activeTween = nil
            end

            continue
        end

        local myHead = char:FindFirstChild('Head')
        if not myHead then continue end

        local targetPlayer

        if targetClosestPlayer.Value then
            local nearestBall
            local nearestBallDist = math.huge

            for _, ball in next, workspace:GetChildren() do
                if not ball:IsA('BasePart') then continue end
                if not ball.Name:lower():find('ball') then continue end

                local dist = (ball.Position - myHead.Position).Magnitude

                if dist < nearestBallDist then
                    nearestBallDist = dist
                    nearestBall = ball
                end
            end

            if not nearestBall then continue end

            local closestDist = math.huge

            for _, v in next, players:GetPlayers() do
                if v == player then continue end

                local character = v.Character
                if not character then continue end

                local head = character:FindFirstChild('Head')
                if not head then continue end

                local dist = (head.Position - nearestBall.Position).Magnitude

                if dist < closestDist then
                    closestDist = dist
                    targetPlayer = v
                end
            end
        else
            local closestDist = math.huge

            for _, v in next, players:GetPlayers() do
                if v == player then continue end

                local character = v.Character
                if not character then continue end

                local head = character:FindFirstChild('Head')
                if not head then continue end

                local dist = (head.Position - myHead.Position).Magnitude

                if dist < closestDist then
                    closestDist = dist
                    targetPlayer = v
                end
            end
        end

        if not targetPlayer then continue end

        local character = targetPlayer.Character
        if not character then continue end

        local head = character:FindFirstChild('Head')
        if not head then continue end

        local targetHumanoid = character:FindFirstChildOfClass('Humanoid')
        if not targetHumanoid then continue end

        local myState = hum:GetState()
        local targetState = targetHumanoid:GetState()

        local distance = (head.Position - myHead.Position).Magnitude

        if distance > boostRadius.Value then
            continue
        end

        if myState ~= Enum.HumanoidStateType.Jumping
            and myState ~= Enum.HumanoidStateType.Freefall then
            continue
        end

        if targetState ~= Enum.HumanoidStateType.Jumping
            and targetState ~= Enum.HumanoidStateType.Freefall then
            continue
        end

        local speed = math.max(hum.WalkSpeed * boostStrength.Value, 1)
        local targetPos = head.Position

        local duration = math.max((hrp.Position - targetPos).Magnitude / speed, 0.01)

        if activeTween then
            activeTween:Cancel()
        end

        activeTween = tweenService:Create(
            hrp,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {
                CFrame = CFrame.new(targetPos)
            }
        )

        activeTween:Play()

        activeTween.Completed:Once(function(state)
            if state ~= Enum.PlaybackState.Completed then
                return
            end

            hrp.AssemblyLinearVelocity = Vector3.new(
                hrp.AssemblyLinearVelocity.X,
                boostPower.Value,
                hrp.AssemblyLinearVelocity.Z
            )
        end)
    end
end)

local MiscTab = Window:CreateTab({ Name = 'Misc', Icon = 'rbxassetid://129082556946713' })

fpsCap = MiscTab:CreateSlider({
    Name = 'Uncap FPS Amount',
    Min = 30,
    Max = 240,
    Default = 240,
    Increment = 1,
    Suffix = '',
    Tip = 'Sets the maximum FPS limit.',
})

task.spawn(function()
    while true do
        task.wait()

        setfpscap(fpsCap.Value)
    end
end)

antiAdmin = MiscTab:CreateToggle({
    Name = 'Anti Admin',
    Default = false,
    Tip = 'Automatically reacts when administrators are detected.',
    Keybind = nil,
})

task.spawn(function()
    while task.wait() do
        local playerGui = player:FindFirstChild("PlayerGui")
        if not playerGui then continue end
        
        local miscText = playerGui:FindFirstChild("MiscText")
        if not miscText then continue end
        
        local isVIP = miscText:FindFirstChild("IsVIP")
        if not isVIP then continue end
        
        if isVIP.Visible == true then continue end
        
        for _, admin in next, players:GetPlayers() do
            if admin == player then continue end
            
            local swagData = admin:FindFirstChild("SwagData")
            if not swagData then continue end
            
            local adminTag = swagData:FindFirstChild("Admin")
            if not adminTag then continue end
            
            if adminTag.Value ~= "" and antiAdmin.Value then
                player:Kick("[Byte.WTF] Detected AdminName: " .. admin.Name .. "ID: " .. admin.UserId)
            end
        end
    end
end)

smoothReplay = MiscTab:CreateToggle({
		Name = 'Smooth Replay',
		Default = false,
		Tip = 'Smooths replay playback for improved visual quality.',
		Keybind = nil,
	})

	replayFPS = MiscTab:CreateSlider({
		Name = 'Replay Frame Per Second',
		Min = 9,
		Max = 120,
		Default = 9,
		Increment = 1,
		Tip = 'Sets the replay playback frame rate.',
	})
    
if not isPractice then

	local player = game:GetService('Players').LocalPlayer
	local replicatedStorage = game:GetService('ReplicatedStorage')
	local runService = game:GetService('RunService')

	local remote = replicatedStorage:WaitForChild('Remotes'):WaitForChild('CharacterSoundEvent')
	local heartbeat = runService.Heartbeat

	local transition = player:WaitForChild('PlayerGui'):WaitForChild('MainGui'):WaitForChild('Transition')

	local homeCamera = CFrame.Angles(-0.2617993877991494, 0, 0)
	local awayCamera = CFrame.Angles(0.2617993877991494, math.pi, 0)

	local cameraOffset = CFrame.new(0, 0, 19)

	local limbs = {
		'Torso',
		'Left Arm',
		'Right Arm',
		'Left Leg',
		'Right Leg',
		'Head'
	}

	task.spawn(function()
		while true do
			task.wait()

			local replayScript = player.PlayerScripts:FindFirstChild('ClientReplay')
			if replayScript then
				replayScript.Enabled = not smoothReplay.Value
			end
		end
	end)

	local replay = function(data, characters)
		local replayBall = workspace:WaitForChild('ReplayBall')
		local camera = workspace.CurrentCamera

		camera.CameraType = Enum.CameraType.Scriptable
		camera.CameraSubject = replayBall

		local cameraRotation = data.changes[1].poss == 'h' and homeCamera or awayCamera

		local currentChange = 1
		local highestY = 18
		local cameraTilt = true

		local playback = 1
		local recordedFPS = data.fps

		local accumulator = 0
		local last = tick()

		local getFrame = function(index)
			local maxFrames = #data.ball
			if index < 1 then return 1 end
			if index > maxFrames then return maxFrames end
			return index
		end

		local interpolate = function(a, b, alpha)
			return a:Lerp(b, alpha)
		end

		while playback < #data.ball do
			if replicatedStorage.Flags.StatusTag.Value ~= 'REPLAY' then
				break
			end

			if camera.CameraType ~= Enum.CameraType.Scriptable then
				break
			end

			local replayFPSValue = replayFPS.Value
			local replayDelta = 1 / replayFPSValue

			local now = tick()
			accumulator += now - last
			last = now

			while accumulator >= replayDelta do
				playback += recordedFPS / replayFPSValue
				accumulator -= replayDelta
			end

			local frame1 = getFrame(math.floor(playback))
			local frame2 = getFrame(math.ceil(playback))
			local alpha = playback - frame1

			for _, character in next, characters do
				local characterData = data.limbs[character.Name]
				if not characterData then character.Parent = nil continue end

				local limbData = characterData[1]
				local accessoryData = characterData[2]

				if not limbData[1] then
					character.Parent = nil
					continue
				end

				local torso1 = limbData[1][2][frame1]
				local torso2 = limbData[1][2][frame2]

				if not torso1 or not torso2 then
					character.Parent = nil
					continue
				end

				local torso = interpolate(torso1, torso2, alpha)

				for i = 1, #limbs do
					local limbName = limbs[i]
					local limb = character:FindFirstChild(limbName)
					if not limb then continue end

					local replayLimb = limbData[i]
					if not replayLimb then continue end

					local cf1 = replayLimb[2][frame1]
					local cf2 = replayLimb[2][frame2]

					if i == 4 then
						if cf1 and cf2 then
							local angle = cf1 + ((cf2 - cf1) * alpha)

							limb.CFrame =
								torso *
								CFrame.new(-0.5, -1, 0) *
								CFrame.fromOrientation(angle, 0, 0) *
								CFrame.new(0, -1, 0)
						end
					elseif i == 5 then
						if cf1 and cf2 then
							local angle = cf1 + ((cf2 - cf1) * alpha)

							limb.CFrame =
								torso *
								CFrame.new(0.5, -1, 0) *
								CFrame.fromOrientation(angle, 0, 0) *
								CFrame.new(0, -1, 0)
						end
					else
						if cf1 and cf2 then
							limb.CFrame = interpolate(cf1, cf2, alpha)
						elseif i == 6 then
							limb.CFrame = torso * CFrame.new(0, 1.5, 0)
						end
					end
				end

				local uniform = character:FindFirstChild('Uniform')
				if accessoryData and uniform then
					for name, info in next, accessoryData do
						if uniform:FindFirstChild(name) and character:FindFirstChild(info[1]) then
							uniform[name].CFrame =
								character[info[1]].CFrame * info[2]
						end
					end
				end
			end

			local ball1 = data.ball[frame1]
			local ball2 = data.ball[frame2]

			if ball1 and ball2 then
				replayBall.CFrame = interpolate(ball1, ball2, alpha)
			end

			if highestY < replayBall.Position.Y then
				highestY = replayBall.Position.Y
			elseif highestY > 49 and cameraTilt then
				local x = select(1, cameraRotation:ToOrientation())

				cameraRotation *= CFrame.Angles(
					x * 3 * math.clamp((highestY - 50) / 99, 0, 1),
					0,
					0
				)

				cameraTilt = false
			end

			local targetCamera

			if highestY > 49 and cameraTilt then
				local x = select(1, cameraRotation:ToOrientation())

				targetCamera =
					CFrame.new(replayBall.Position) *
					cameraRotation *
					CFrame.Angles(
						x * 3 * math.clamp((highestY - 50) / 99, 0, 1),
						0,
						0
					) *
					cameraOffset
			else
				targetCamera =
					CFrame.new(replayBall.Position) *
					cameraRotation *
					cameraOffset
			end

			camera.CFrame = targetCamera

			local change = data.changes[currentChange]

			if change and change.frame <= frame1 then
				currentChange += 1

				if change.frame == frame1 then
					if change.poss and (frame1 > 9 and (change.turnover or highestY > 49)) then
						local nextRotation =
							change.poss == 'h' and homeCamera or awayCamera

						local duration =
							(change.turnover == true or replayBall.Position.Y >= 13)
							and 0.5
							or (highestY / 500)

						local elapsed = 0
						local startRotation = cameraRotation

						while elapsed < duration do
							elapsed += heartbeat:Wait()

							cameraRotation = startRotation:Lerp(
								nextRotation,
								math.clamp(elapsed / duration, 0, 1)
							)

							camera.CFrame =
								CFrame.new(replayBall.Position) *
								cameraRotation *
								cameraOffset
						end

						cameraRotation = nextRotation

					elseif change.freeze then
						task.wait(change.freeze)
					end
				end
			end

			heartbeat:Wait()
		end

		remote:FireServer('ReplayFinished')

		if replicatedStorage.Flags.StatusTag.Value == 'REPLAY' then
			replicatedStorage.Flags.StatusTag.Value = ''
		end

		task.wait(0.2)

		replayBall:Destroy()

		for _, character in next, characters do
			character:Destroy()
		end

		data.t = nil
		data.limbs = nil
		data.ball = nil

		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = player.Character.Humanoid
	end

	remote.OnClientEvent:Connect(function(action, ...)
		if action == 'ClientReplay' then
			while transition.Position.X.Scale > -2 and transition.Position.X.Scale < -0.5 do
				task.wait()
			end

			replay(...)
		end
	end)

end
        pcall(function() RealWindow:Notify({ title = "Byte.WTF", content = "Football Fusion 3 loaded.", duration = 4 }) end)
    end)
    if not ff3ok then
        pcall(function() _print("[Byte.WTF] Football Fusion 3 failed to load:", ff3err) end)
    end
