-- ============================================================
-- Byte.WTF  |  Practical Basketball  |  Airflow UI
-- ============================================================
local Airflow = loadstring(game:HttpGet("https://raw.githubusercontent.com/PookiePepelsss/Airflow-UI/refs/heads/main/Source.luau"))()
Airflow:LoadFont({Name = "ValleySans"})

Airflow.Themes.FatalBlue = {
    Background  = Color3.fromRGB(5,   10,  22),
    Surface     = Color3.fromRGB(9,   16,  34),
    Surface2    = Color3.fromRGB(13,  22,  45),
    Surface3    = Color3.fromRGB(20,  32,  60),
    Stroke      = Color3.fromRGB(28,  45,  90),
    StrokeHover = Color3.fromRGB(55,  90, 180),
    Accent      = Color3.fromRGB(60,  120, 255),
    AccentDark  = Color3.fromRGB(8,   18,  50),
    Text        = Color3.fromRGB(220, 230, 255),
    Muted       = Color3.fromRGB(110, 140, 200),
    Glow        = Color3.fromRGB(60,  120, 255),
    Warning     = Color3.fromRGB(240, 176, 108),
    Success     = Color3.fromRGB(150, 220, 170),
    Error       = Color3.fromRGB(240, 120, 120),
}

local LOGO_ID = 85087336560627 -- your asset id (decal, image or model all work)
do
    local url = "rbxassetid://" .. LOGO_ID
    Airflow.Assets.Logo = url
    -- If the id is a Decal/Model, pull the real image id out of it.
    pcall(function()
        local obj = game:GetObjects(url)[1]
        if not obj then return end
        local img
        if obj:IsA("Decal") or obj:IsA("Texture") then
            img = obj.Texture
        elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            img = obj.Image
        else
            local d = obj:FindFirstChildWhichIsA("Decal", true) or obj:FindFirstChildWhichIsA("Texture", true)
            if d then
                img = d.Texture
            else
                local il = obj:FindFirstChildWhichIsA("ImageLabel", true) or obj:FindFirstChildWhichIsA("ImageButton", true)
                if il then img = il.Image end
            end
        end
        if type(img) == "string" and img ~= "" then Airflow.Assets.Logo = img end
        obj:Destroy()
    end)
end

-- Services
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

    -- // Config
    local Aural = {
        Shooting = {
            PerfectTiming = true,
            ReleasePoint  = 97,
        },
        Dribbling = {
            DribbleGlide = false,
            GlideSpeed   = 25,
        },
        Defense = {
            AutoBlock       = false,
            BlockRange      = 12,
            BlockDelay      = 150,
            BlockTeamCheck  = true,
            AutoGuard       = false,
            GuardSprint     = false,
            TeamCheck       = true,
            BallHandlerOnly = true,
            GuardDistance   = 4,
            GuardStrength   = 70,
            GuardRange      = 45,
        },
        Player = {
            CframeSpeed      = false,
            CframeSpeedValue = 8,
            AutoSprint       = false,
            InfiniteStamina  = false,
        },
        Effects = {
            GoalEffect     = false,
            GoalEffectName = "Fire",
            IncludeTrail   = true,
        },
    }

    -- // Shared state
    local Running     = true
    local Connections = {}
    local Characters  = nil
    local Remotes     = {}
    local Hoops       = {}

    local FireServer = Instance.new("RemoteEvent").FireServer
    local function Fire(Remote, ...)
        if Remote then FireServer(Remote, ...) end
    end

    local function Connect(Signal, Callback)
        local C = Signal:Connect(Callback)
        table.insert(Connections, C)
        return C
    end

    -- // Helpers
    local function Flat(v) return Vector3.new(v.X, 0, v.Z) end

    local function GetCharacter()
        return Characters and LocalPlayer and Characters:FindFirstChild(LocalPlayer.Name)
    end

    local function GetRoot(m) return m and m:FindFirstChild("HumanoidRootPart") end

    local function GetProxy()
        local P = workspace:FindFirstChild("ProxyCharacter")
        if P and P:FindFirstChild("MovementVelocity") then
            return P, P.MovementVelocity, P:FindFirstChild("MovementGyro")
        end
        return nil
    end

    local function HasBall(Model)
        if not Model then return false end
        if Model:GetAttribute("Basketball") then return true end
        local Root = Model:FindFirstChild("HumanoidRootPart")
        local Weld = Root and Root:FindFirstChild("Basketball")
        return Weld ~= nil and Weld:IsA("Motor6D") and Weld.Part1 ~= nil
    end

    local function IsOpponent(Model, Mine, TeamCheck)
        if not TeamCheck then return true end
        local MyTeam = Mine:GetAttribute("Team")
        return MyTeam == nil or MyTeam == 0 or Model:GetAttribute("Team") ~= MyTeam
    end

    local function GetOthers(Mine)
        local List = {}
        if not Characters then return List end
        for _, Model in Characters:GetChildren() do
            local Root = Model ~= Mine and Model.Name ~= "InvisCharacter" and GetRoot(Model)
            if Root then table.insert(List, { Model = Model, Root = Root }) end
        end
        return List
    end

    local function GetGoal(Model)
        local G = Model and Model:GetAttribute("Goal")
        if typeof(G) == "CFrame"  then return G.Position end
        if typeof(G) == "Vector3" then return G end
        local Root = GetRoot(Model)
        if not Root then return nil end
        local Closest, CD = nil, math.huge
        for Hoop in Hoops do
            if Hoop.Parent then
                local D = (Hoop.Position - Root.Position).Magnitude
                if D < CD then Closest, CD = Hoop.Position, D end
            else Hoops[Hoop] = nil end
        end
        return Closest
    end

    local function GetMoveDirection()
        local Cam   = workspace.CurrentCamera
        local Look  = Flat(Cam.CFrame.LookVector)
        local Right = Flat(Cam.CFrame.RightVector)
        local Dir   = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then Dir += Look  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then Dir -= Look  end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then Dir += Right end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then Dir -= Right end
        if Dir.Magnitude > 0.01 then return Dir.Unit end
        local Proxy = GetProxy()
        local Vel   = Proxy and Flat(Proxy.AssemblyLinearVelocity)
        if Vel and Vel.Magnitude > 2 then return Vel.Unit end
        return Vector3.zero
    end

    local MeterTypes   = { "Vertical", "Rocket", "Bat", "Funnel", "Hoop", "Roblox", "None" }
    local BlockActions = { Shooting = true, Dunking = true, ContactLayup = true }

    -- // Effect list
    local EffectAssets, EffectOptions = nil, {}
    pcall(function()
        EffectAssets = ReplicatedStorage
            :WaitForChild("Assets", 5)
            :WaitForChild("Models", 5)
            :WaitForChild("GreenEffects", 5)
        for _, E in (EffectAssets:FindFirstChild("Goal") or EffectAssets):GetChildren() do
            table.insert(EffectOptions, E.Name)
        end
        table.sort(EffectOptions)
    end)

    local ApplyEffects = function() end

    -- ═══════════════════════════════════════════════════
    --  WINDOW
    -- ═══════════════════════════════════════════════════

    local Window = Airflow:CreateWindow({
        Name              = "Byte.WTF",
        LoadingSubtitle   = "Practical Basketball",
        Theme             = "FatalBlue",
        ToggleUIKeybind   = "F5",
        ConfigurationSaving = {
            Enabled    = true,
            FolderName = "Byte.WTF",
            FileName   = "PracticalBasketball",
        },
    })

    local function Notify(title, content, duration)
        pcall(function() Window:Notify({ title = title, content = content, duration = duration or 4 }) end)
    end

    -- // Tabs
    local ShootingTab = Window:CreateTab({ Name = "Shooting", Icon = "crosshair" })
    local OffenseTab  = Window:CreateTab({ Name = "Offense",  Icon = "activity"  })
    local DefenseTab  = Window:CreateTab({ Name = "Defense",  Icon = "shield"    })
    local VisualsTab  = Window:CreateTab({ Name = "Visuals",  Icon = "eye"       })
    local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "settings"  })

    -- ── SHOOTING ──────────────────────────────────────

    ShootingTab:CreateSection("Auto Time")
    local PerfTimingToggle = ShootingTab:CreateToggle({
        Name = "Auto Time", Desc = "Releases every shot at the top of the meter",
        Flag = "PerfectTiming", CurrentValue = Aural.Shooting.PerfectTiming,
        Callback = function(v) Aural.Shooting.PerfectTiming = v end,
    })
    ShootingTab:CreateKeybind({
        Name = "Auto Time keybind", Flag = "PerfectTimingKey",
        Callback = function()
            local v = not Aural.Shooting.PerfectTiming
            pcall(function() PerfTimingToggle:Set(v) end)
            Aural.Shooting.PerfectTiming = v
        end,
    })
    ShootingTab:CreateSlider({
        Name = "Release Point", Desc = "How full the meter is when the release lands",
        Range = { 90, 100 }, Increment = 0.5, Suffix = "%",
        CurrentValue = Aural.Shooting.ReleasePoint, Flag = "ReleasePoint",
        Callback = function(v) Aural.Shooting.ReleasePoint = v end,
    })

    ShootingTab:CreateSection("Shot Meter")
    ShootingTab:CreateDropdown({
        Name = "Change Meter", Desc = "Switches your shot meter type",
        Options = MeterTypes, CurrentValue = "Vertical", Flag = "MeterType",
        Callback = function(v)
            if not v then return end
            Fire(Remotes.UpdateSetting, { "Meter" }, "Type", v)
            Notify("Meter", "Set to " .. v)
        end,
    })

    -- ── OFFENSE ───────────────────────────────────────

    OffenseTab:CreateSection("Dribble Glide")
    local GlideToggle = OffenseTab:CreateToggle({
        Name = "Glide", Desc = "Dribble moves travel further",
        Flag = "DribbleGlide", CurrentValue = Aural.Dribbling.DribbleGlide,
        Callback = function(v) Aural.Dribbling.DribbleGlide = v end,
    })
    OffenseTab:CreateKeybind({
        Name = "Glide keybind", Flag = "DribbleGlideKey",
        Callback = function()
            local v = not Aural.Dribbling.DribbleGlide
            pcall(function() GlideToggle:Set(v) end)
            Aural.Dribbling.DribbleGlide = v
        end,
    })
    OffenseTab:CreateSlider({
        Name = "Glide Speed", Desc = "Extra speed on every dribble move",
        Range = { 0, 100 }, Increment = 1, Suffix = "%",
        CurrentValue = Aural.Dribbling.GlideSpeed, Flag = "GlideSpeed",
        Callback = function(v) Aural.Dribbling.GlideSpeed = v end,
    })

    OffenseTab:CreateSection("Movement")
    local CFrameToggle = OffenseTab:CreateToggle({
        Name = "CFrame Speed", Desc = "Moves you forward each frame on top of normal movement",
        Flag = "CframeSpeed", CurrentValue = Aural.Player.CframeSpeed,
        Callback = function(v) Aural.Player.CframeSpeed = v end,
    })
    OffenseTab:CreateKeybind({
        Name = "CFrame Speed keybind", Flag = "CframeSpeedKey",
        Callback = function()
            local v = not Aural.Player.CframeSpeed
            pcall(function() CFrameToggle:Set(v) end)
            Aural.Player.CframeSpeed = v
        end,
    })
    OffenseTab:CreateSlider({
        Name = "CFrame Amount", Desc = "Extra studs added per frame while moving",
        Range = { 1, 30 }, Increment = 0.5, Suffix = " studs",
        CurrentValue = Aural.Player.CframeSpeedValue, Flag = "CframeSpeedValue",
        Callback = function(v) Aural.Player.CframeSpeedValue = v end,
    })
    OffenseTab:CreateToggle({
        Name = "Auto Sprint", Desc = "Holds sprint automatically so you never slow down",
        Flag = "AutoSprint", CurrentValue = Aural.Player.AutoSprint,
        Callback = function(v) Aural.Player.AutoSprint = v end,
    })
    OffenseTab:CreateToggle({
        Name = "Infinite Stamina", Desc = "Stops stamina from ever running out",
        Flag = "InfiniteStamina", CurrentValue = Aural.Player.InfiniteStamina,
        Callback = function(v) Aural.Player.InfiniteStamina = v end,
    })

    -- ── DEFENSE ───────────────────────────────────────

    DefenseTab:CreateSection("Block")
    local BlockToggle = DefenseTab:CreateToggle({
        Name = "Auto Block", Desc = "Jumps at nearby shots, layups and dunks",
        Flag = "AutoBlock", CurrentValue = Aural.Defense.AutoBlock,
        Callback = function(v) Aural.Defense.AutoBlock = v end,
    })
    DefenseTab:CreateKeybind({
        Name = "Block keybind", Flag = "AutoBlockKey",
        Callback = function()
            local v = not Aural.Defense.AutoBlock
            pcall(function() BlockToggle:Set(v) end)
            Aural.Defense.AutoBlock = v
        end,
    })
    DefenseTab:CreateSlider({
        Name = "Block Range", Desc = "How far away a shot triggers the block",
        Range = { 3, 30 }, Increment = 1, Suffix = " studs",
        CurrentValue = Aural.Defense.BlockRange, Flag = "BlockRange",
        Callback = function(v) Aural.Defense.BlockRange = v end,
    })
    DefenseTab:CreateSlider({
        Name = "Block Delay", Desc = "Waits before jumping — filters pump fakes",
        Range = { 0, 500 }, Increment = 10, Suffix = "ms",
        CurrentValue = Aural.Defense.BlockDelay, Flag = "BlockDelay",
        Callback = function(v) Aural.Defense.BlockDelay = v end,
    })
    DefenseTab:CreateToggle({
        Name = "Team Check", Desc = "Never blocks a teammate",
        Flag = "BlockTeamCheck", CurrentValue = Aural.Defense.BlockTeamCheck,
        Callback = function(v) Aural.Defense.BlockTeamCheck = v end,
    })

    DefenseTab:CreateSection("Guard")
    local GuardToggle = DefenseTab:CreateToggle({
        Name = "Auto Guard", Desc = "Stays between your man and the hoop",
        Flag = "AutoGuard", CurrentValue = Aural.Defense.AutoGuard,
        Callback = function(v) Aural.Defense.AutoGuard = v end,
    })
    DefenseTab:CreateKeybind({
        Name = "Guard keybind", Flag = "AutoGuardKey",
        Callback = function()
            local v = not Aural.Defense.AutoGuard
            pcall(function() GuardToggle:Set(v) end)
            Aural.Defense.AutoGuard = v
        end,
    })
    DefenseTab:CreateToggle({
        Name = "Guard Sprint", Desc = "Sprints to keep up when your man gets ahead",
        Flag = "GuardSprint", CurrentValue = Aural.Defense.GuardSprint,
        Callback = function(v) Aural.Defense.GuardSprint = v end,
    })
    DefenseTab:CreateToggle({
        Name = "Team Check", Desc = "Never guards your own teammates",
        Flag = "GuardTeamCheck", CurrentValue = Aural.Defense.TeamCheck,
        Callback = function(v) Aural.Defense.TeamCheck = v end,
    })
    DefenseTab:CreateToggle({
        Name = "Ball Handler Only", Desc = "Only guards the player with the ball",
        Flag = "BallHandlerOnly", CurrentValue = Aural.Defense.BallHandlerOnly,
        Callback = function(v) Aural.Defense.BallHandlerOnly = v end,
    })
    DefenseTab:CreateSlider({
        Name = "Guard Distance", Desc = "How tight to play your man",
        Range = { 1, 10 }, Increment = 0.5, Suffix = " studs",
        CurrentValue = Aural.Defense.GuardDistance, Flag = "GuardDistance",
        Callback = function(v) Aural.Defense.GuardDistance = v end,
    })
    DefenseTab:CreateSlider({
        Name = "Guard Strength", Desc = "How aggressively it corrects your position",
        Range = { 10, 100 }, Increment = 1, Suffix = "%",
        CurrentValue = Aural.Defense.GuardStrength, Flag = "GuardStrength",
        Callback = function(v) Aural.Defense.GuardStrength = v end,
    })
    DefenseTab:CreateSlider({
        Name = "Guard Range", Desc = "Max distance before guard kicks in",
        Range = { 10, 80 }, Increment = 1, Suffix = " studs",
        CurrentValue = Aural.Defense.GuardRange, Flag = "GuardRange",
        Callback = function(v) Aural.Defense.GuardRange = v end,
    })
    local GuardStatus = DefenseTab:CreateLabel("guarding: none")

    -- ── VISUALS ───────────────────────────────────────

    VisualsTab:CreateSection("Goal Effect")
    VisualsTab:CreateToggle({
        Name = "Goal Effect Changer", Desc = "Every green plays this effect at the rim",
        Flag = "GoalEffect", CurrentValue = Aural.Effects.GoalEffect,
        Callback = function(v) Aural.Effects.GoalEffect = v; ApplyEffects() end,
    })
    VisualsTab:CreateDropdown({
        Name = "Effect",
        Options = #EffectOptions > 0 and EffectOptions or { "Fire" },
        CurrentValue = Aural.Effects.GoalEffectName, Flag = "GoalEffectName",
        Callback = function(v)
            Aural.Effects.GoalEffectName = v or Aural.Effects.GoalEffectName
            ApplyEffects()
        end,
    })
    VisualsTab:CreateToggle({
        Name = "Ball Trail Too", Desc = "Also applies the effect to the ball trail",
        Flag = "GoalEffectTrail", CurrentValue = Aural.Effects.IncludeTrail,
        Callback = function(v) Aural.Effects.IncludeTrail = v; ApplyEffects() end,
    })

    -- ── SETTINGS ──────────────────────────────────────

    SettingsTab:CreateSection("Configs")
    local ConfigName = "default"
    SettingsTab:CreateInput({
        Name = "Config name", Placeholder = "default",
        CurrentValue = "default", Flag = "ConfigName",
        Callback = function(v) ConfigName = (v ~= "") and v or "default" end,
    })
    SettingsTab:CreateButton({
        Name = "Save config",
        Callback = function()
            pcall(function() Window:SaveConfig(ConfigName) end)
            Notify("Config", "Saved: " .. ConfigName)
        end,
    })
    SettingsTab:CreateButton({
        Name = "Load config",
        Callback = function()
            pcall(function() Window:LoadConfig(ConfigName) end)
            Notify("Config", "Loaded: " .. ConfigName)
        end,
    })

    pcall(function() Window:LoadConfig() end)

    -- ═══════════════════════════════════════════════════
    --  FEATURE LOGIC
    -- ═══════════════════════════════════════════════════

    task.spawn(function()
        if not LocalPlayer then
            repeat task.wait() until Players.LocalPlayer
            LocalPlayer = Players.LocalPlayer
        end

        while game.PlaceId == 0 do task.wait() end

        local ok, RS = pcall(function()
            return ReplicatedStorage
                :WaitForChild("Aero", 30)
                :WaitForChild("AeroRemoteServices", 30)
        end)
        if not ok or not RS then
            Notify("Byte.WTF", "Remotes not found — game not supported.", 5)
            return
        end

        Characters = workspace:WaitForChild("Characters", 30)

        local function GetRemote(svc, name)
            return RS:WaitForChild(svc):WaitForChild(name)
        end

        Remotes.Shoot         = GetRemote("InputService",     "Shoot")
        Remotes.Jump          = GetRemote("InputService",     "Jump")
        Remotes.Sprint        = GetRemote("InputService",     "Sprint")
        Remotes.HoldG         = GetRemote("InputService",     "HoldG")
        Remotes.UpdateSetting = GetRemote("PlayerService",    "UpdateSetting")
        Remotes.MeterRegister = GetRemote("MeterService",     "RegisterPacket")
        Remotes.MeterUnregister = GetRemote("MeterService",   "UnregisterPacket")
        Remotes.RunGreenEffect  = GetRemote("InterfaceService", "RunGreenEffect")

        -- Hoop tracker
        local function TrackHoop(O)
            if O.Name == "Goal" and O:IsA("BasePart") and O.Parent
                and O.Parent:FindFirstChild("PaintZone") then
                Hoops[O] = true
            end
        end
        for _, O in workspace:GetDescendants() do TrackHoop(O) end
        Connect(workspace.DescendantAdded, TrackHoop)

        -- ── SHOT TRACKING + AUTO TIME ──────────────────
        do
            local MeterMaps = {
                Vertical = function(O) return (-O.Y - 0.25) / 1.25 end,
                Rocket   = function(O) return -O.Y end,
                Bat      = function(O) return -O.Y end,
                None     = function(O) return -O.Y end,
                Hoop     = function(O) return  O.Y end,
                Roblox   = function(O) return  O.X end,
            }
            local DefaultFill = 0.38

            local Shot = {
                Active   = false,
                Start    = 0,
                Meter    = "Vertical",
                Samples  = {},
                Slope    = nil,
                Released = false,
            }

            local Bound, BoundConnections = nil, {}

            local function BeginShot(MeterType)
                Shot.Active   = true
                Shot.Start    = os.clock()
                Shot.Meter    = MeterType or Shot.Meter
                Shot.Samples  = {}
                Shot.Slope    = nil
                Shot.Released = false
            end

            local function Release()
                Shot.Released = true
                Fire(Remotes.Shoot, { Shoot = false })
            end

            local function Fit()
                local N = #Shot.Samples
                local SX, SY, SXX, SXY = 0, 0, 0, 0
                for _, S in Shot.Samples do
                    local X = S[1] - Shot.Start
                    SX += X; SY += S[2]; SXX += X*X; SXY += X*S[2]
                end
                local D = N * SXX - SX * SX
                if D == 0 then return nil end
                local Slope = (N * SXY - SX * SY) / D
                return Slope, (SY - Slope * SX) / N
            end

            local function GetReleaseTime()
                local Target = Aural.Shooting.ReleasePoint / 100
                if MeterMaps[Shot.Meter] then
                    if #Shot.Samples < 3 then return nil end
                    local Slope, Intercept = Fit()
                    if not Slope or Slope < 0.5 then return nil end
                    Shot.Slope = Slope
                    return Shot.Start + (Target - Intercept) / Slope
                end
                return Shot.Start + DefaultFill * Target
            end

            local function Bind(Character)
                for _, C in BoundConnections do C:Disconnect() end
                BoundConnections = {}
                Bound = Character
                if not Character then return end

                table.insert(BoundConnections,
                    Character:GetAttributeChangedSignal("meterOffset"):Connect(function()
                        local Offset = Character:GetAttribute("meterOffset")
                        local Map    = MeterMaps[Shot.Meter]
                        if not Shot.Active or typeof(Offset) ~= "Vector2" or not Map then return end
                        if not Shot.Released then
                            table.insert(Shot.Samples, { os.clock(), Map(Offset) })
                        end
                    end))

                table.insert(BoundConnections,
                    Character:GetAttributeChangedSignal("Action"):Connect(function()
                        if Character:GetAttribute("Action") == "Shooting"
                            and (not Shot.Active or os.clock() - Shot.Start > 0.3) then
                            BeginShot(nil)
                        end
                    end))
            end

            Connect(Remotes.MeterRegister.OnClientEvent, function(Model, MeterType)
                if Model ~= Bound then return end
                if not Shot.Active or os.clock() - Shot.Start > 0.3 then
                    BeginShot(MeterType)
                else
                    Shot.Meter = MeterType or Shot.Meter
                end
            end)

            Connect(Remotes.MeterUnregister.OnClientEvent, function(Model)
                if Model == Bound then Shot.Active = false end
            end)

            Connect(RunService.Heartbeat, function()
                local Character = GetCharacter()
                if Character ~= Bound then Bind(Character) end
                if not Character then return end

                if Shot.Active and not Shot.Released and Aural.Shooting.PerfectTiming then
                    if Character:GetAttribute("ReleasedShot") == true
                        and os.clock() - Shot.Start > 0.1 then
                        Shot.Released = true
                    else
                        local RT = GetReleaseTime()
                        if (RT and os.clock() >= RT) or os.clock() - Shot.Start > 1.2 then
                            Release()
                        end
                    end
                end
                if Shot.Active and os.clock() - Shot.Start > 3 then Shot.Active = false end
            end)
        end

        -- ── AUTO BLOCK ─────────────────────────────────
        do
            local Blocked   = setmetatable({}, { __mode = "k" })
            local LastBlock = 0

            local function Jump(Toward)
                local Proxy, _, Gyro = GetProxy()
                if not Proxy then return end
                if Gyro and Toward then
                    Gyro.CFrame = CFrame.lookAt(Proxy.Position,
                        Vector3.new(Toward.X, Proxy.Position.Y, Toward.Z))
                end
                Fire(Remotes.Shoot, { Shoot = true, Input = "E", UseSpace = true })
                Fire(Remotes.Jump)
                task.delay(0.3, function() Fire(Remotes.Shoot, { Shoot = false }) end)
            end

            Connect(RunService.Heartbeat, function()
                if not Aural.Defense.AutoBlock or os.clock() - LastBlock < 0.8 then return end
                local Character = GetCharacter()
                local Root      = GetRoot(Character)
                if not Root or HasBall(Character) or Character:GetAttribute("Action") ~= "" then return end
                for _, Other in GetOthers(Character) do
                    local Action = Other.Model:GetAttribute("Action")
                    if BlockActions[Action]
                        and IsOpponent(Other.Model, Character, Aural.Defense.BlockTeamCheck)
                        and not (Blocked[Other.Model] and os.clock() - Blocked[Other.Model] < 1.5) then
                        if (Other.Root.Position - Root.Position).Magnitude <= Aural.Defense.BlockRange then
                            Blocked[Other.Model] = os.clock()
                            LastBlock = os.clock()
                            task.delay(Aural.Defense.BlockDelay / 1000, function()
                                if Running and BlockActions[Other.Model:GetAttribute("Action")]
                                    and (Other.Root.Position - Root.Position).Magnitude
                                        <= Aural.Defense.BlockRange + 4 then
                                    Jump(Other.Root.Position)
                                end
                            end)
                            return
                        end
                    end
                end
            end)
        end

        -- ── GUARD · GLIDE · CFRAME · STAMINA ──────────
        do
            local Guarding, Sprinting = false, false
            local LastGuard   = 0
            local ShownTarget = nil

            local function ShowTarget(Model)
                if Model ~= ShownTarget then
                    ShownTarget = Model
                    pcall(function()
                        GuardStatus:Set("guarding: " .. (Model and Model.Name or "none"))
                    end)
                end
            end

            local function StopGuard()
                ShowTarget(nil)
                if Guarding  then Guarding  = false; Fire(Remotes.HoldG, { HoldingG = false }) end
                if Sprinting then Sprinting = false; Fire(Remotes.Sprint, false) end
            end

            local function FindGuardTarget(Character, Root)
                local Closest, CD = nil, Aural.Defense.GuardRange
                for _, Other in GetOthers(Character) do
                    if IsOpponent(Other.Model, Character, Aural.Defense.TeamCheck)
                        and (not Aural.Defense.BallHandlerOnly or HasBall(Other.Model)) then
                        local D = (Other.Root.Position - Root.Position).Magnitude
                        if D < CD then Closest, CD = Other, D end
                    end
                end
                return Closest
            end

            Connect(RunService.Stepped, function(_, DeltaTime)
                local Character = GetCharacter()
                local Root      = GetRoot(Character)
                local Proxy, Velocity, Gyro = GetProxy()
                if not Root or not Proxy then StopGuard(); return end

                local Action  = Character:GetAttribute("Action")
                local Current = Velocity.Velocity
                local CanMove = Character:GetAttribute("CanMove")

                if Aural.Player.InfiniteStamina then
                    Character:SetAttribute("Stamina", Character:GetAttribute("MaxStamina") or 100)
                end

                local Target = Aural.Defense.AutoGuard and CanMove
                    and not HasBall(Character) and FindGuardTarget(Character, Root)

                if Target then
                    local Goal   = GetGoal(Target.Model) or Root.Position
                    local ToGoal = Flat(Goal - Target.Root.Position)
                    ToGoal       = ToGoal.Magnitude > 0.01 and ToGoal.Unit or Vector3.zero
                    local Offset = Flat(Target.Root.Position
                        + ToGoal * Aural.Defense.GuardDistance - Proxy.Position)
                    local Limit  = Aural.Defense.GuardSprint and 17.35 or 14
                    local Speed  = math.min(Offset.Magnitude * Aural.Defense.GuardStrength / 10, Limit)
                    Velocity.Velocity = (Offset.Magnitude > 0.25 and Offset.Unit * Speed or Vector3.zero)
                        + Vector3.new(0, Current.Y, 0)
                    if Gyro then
                        Gyro.CFrame = CFrame.lookAt(Proxy.Position,
                            Vector3.new(Target.Root.Position.X, Proxy.Position.Y, Target.Root.Position.Z))
                    end
                    if not Guarding then Guarding = true; Fire(Remotes.HoldG, { HoldingG = true }) end
                    if Aural.Defense.GuardSprint ~= Sprinting then
                        Sprinting = Aural.Defense.GuardSprint
                        Fire(Remotes.Sprint, Sprinting)
                    end
                    ShowTarget(Target.Model)
                    LastGuard = os.clock()
                    return
                end
                if os.clock() - LastGuard > 0.4 then StopGuard() end

                if Aural.Dribbling.DribbleGlide and Action == "Dribbling" then
                    local Moving = Flat(Proxy.AssemblyLinearVelocity)
                    if Moving.Magnitude > 1 then
                        Proxy.CFrame += Moving.Unit * (Aural.Dribbling.GlideSpeed / 100 * 16) * DeltaTime
                    end
                    return
                end

                if Aural.Player.CframeSpeed and CanMove then
                    local Direction = GetMoveDirection()
                    if Direction.Magnitude > 0 then
                        Proxy.CFrame += Direction * Aural.Player.CframeSpeedValue * DeltaTime
                    end
                end
            end)

            table.insert(Connections, { Disconnect = StopGuard })
        end

        -- ── AUTO SPRINT ────────────────────────────────
        do
            local AutoSprinting = false
            local LastSprint    = 0

            Connect(RunService.Heartbeat, function()
                local Character = GetCharacter()
                if not Aural.Player.AutoSprint or not Character then
                    if AutoSprinting then AutoSprinting = false; Fire(Remotes.Sprint, false) end
                    return
                end
                local Moving = GetMoveDirection().Magnitude > 0
                if Moving and not Character:GetAttribute("Sprinting")
                    and os.clock() - LastSprint > 0.3 then
                    LastSprint = os.clock(); AutoSprinting = true; Fire(Remotes.Sprint, true)
                elseif not Moving and AutoSprinting
                    and not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    AutoSprinting = false; Fire(Remotes.Sprint, false)
                end
            end)
        end

        -- ── GOAL EFFECT ────────────────────────────────
        do
            local Swapped = {}

            local function Restore()
                for i = #Swapped, 1, -1 do
                    local E = Swapped[i]; E.Copy:Destroy()
                    if E.Original then E.Original.Parent = E.Folder end
                end
                table.clear(Swapped)
            end

            local function Swap(Kind, Choice)
                if not EffectAssets then return end
                local Folder = EffectAssets:FindFirstChild(Kind)
                local Source = Folder and Folder:FindFirstChild(Choice)
                if not Source then return end
                for _, Entry in Folder:GetChildren() do
                    if Entry ~= Source then
                        local Copy = Source:Clone()
                        Copy.Name = Entry.Name; Entry.Parent = nil; Copy.Parent = Folder
                        table.insert(Swapped, { Folder = Folder, Original = Entry, Copy = Copy })
                    end
                end
            end

            ApplyEffects = function()
                Restore()
                if not Aural.Effects.GoalEffect then return end
                Swap("Goal", Aural.Effects.GoalEffectName)
                if Aural.Effects.IncludeTrail then Swap("Trail", Aural.Effects.GoalEffectName) end
            end

            Connect(Remotes.RunGreenEffect.OnClientEvent, function(_, _, _, _, Name)
                if not Aural.Effects.GoalEffect or type(Name) ~= "string" or not EffectAssets then return end
                for _, Kind in { "Goal", "Trail" } do
                    local Folder = EffectAssets:FindFirstChild(Kind)
                    local Source = Folder and Folder:FindFirstChild(Aural.Effects.GoalEffectName)
                    if Source and not Folder:FindFirstChild(Name)
                        and (Kind == "Goal" or Aural.Effects.IncludeTrail) then
                        local Copy = Source:Clone(); Copy.Name = Name; Copy.Parent = Folder
                        table.insert(Swapped, { Folder = Folder, Copy = Copy })
                    end
                end
            end)

            table.insert(Connections, { Disconnect = Restore })
        end

        Notify("Byte.WTF", "Ready. Press F5 to toggle.")
    end)

    local function practicalCleanup()
        Running = false
        for _, C in Connections do pcall(function() C:Disconnect() end) end
    end
    LocalPlayer.AncestryChanged:Connect(function()
        if not LocalPlayer.Parent then practicalCleanup() end
    end)
