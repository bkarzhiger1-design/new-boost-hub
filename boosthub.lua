-- =============================================================
--                     BOOST HUB - WIND UI TEMPLATE
-- =============================================================

-- 1. SAFE LOAD WIND UI LIBRARY
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    warn("Failed to load WindUI! Check your executor or internet connection.")
    return
end

-- GAME CHECK VERIFICATION
local TARGET_PLACE_ID = 12069083555
if game.PlaceId ~= TARGET_PLACE_ID then
    WindUI:Notify({
        Title = "Wrong Game!",
        Content = "Wrong Game! Are you sure that you are playing PLS WAIT? ",
        Duration = 10
    })
    return
end

-- Global Config Storage Table (For Saving / Loading Settings)
getgenv().BoostHubConfig = getgenv().BoostHubConfig or {
    AutoCatClick = false,
    AutoRNG = false,
    AutoGoal = false,
    AutoCollectOrbs = false,
    AutoBeg = false,
    AntiBanEnabled = true,
    AutoChatSpam = false,
    CatClickDelay = 100,
    RNGDelay = 15,
    AutoExecuteEnabled = false
}

-- Global Delay Settings (In Seconds)
getgenv().CatClickDelay = getgenv().BoostHubConfig.CatClickDelay / 1000
getgenv().RNGDelay = getgenv().BoostHubConfig.RNGDelay
getgenv().AntiBanEnabled = getgenv().BoostHubConfig.AntiBanEnabled

-- Text Generator State Variables
local textGenText = "testing"
local textGenFont = "FredokaOne"
local textGenColor = "#ff0000"
local textGenStrokeColor = "#000000"
local textGenThickness = 1

-- Client Audio Player & Morph Variables
local customAudioId = ""
local activeCustomSound = nil
local originalVolumes = {}
local morphTargetName = ""

-- Adjustable Auto Chat Spammer Messages List (5 Custom Fields)
local autoChatMessages = {
    "Every robux is appreciated!",
    "Thank for your donations! Goal is 5k",
    "Any given amount will be appreciated!",
    "My goal is to reach 5k and buy a new avatar!",
    "Currently afk. Any given amount will be appreciated!"
}

-- 2. CREATE MAIN WINDOW (WITH DUAL-KEY SUPPORT)
local Window = WindUI:CreateWindow({
    Title = "Boost Hub",
    SubTitle = "v1.0.0 | made by xeavz",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 520),
    Theme = "Dark",
    Transparent = true,
    HideSearchBar = false, -- Enables Search Bar above tabs
    User = {
        Enabled = true,
        Anonymous = false, -- Displays your real Username & Profile Icon
        Callback = function()
            WindUI:Notify({ Title = "Profile", Content = "Logged in as " .. game.Players.LocalPlayer.DisplayName, Duration = 3 })
        end,
    },
    KeySystem = {
        Key = { "KEY_383783828299263", "KEY_PREMIUM_ONLY_12982" }, 
        Note = "Get your key from Linkvertise or use testing keys!",
        URL = "https://linkvertise.com/10198436/EQPCQ263XIi1", 
        SaveKey = true,
    }
})

-- 3. CREATE TABS
local MainTab = Window:Tab({ Title = "Main", Icon = "house" })
local FarmTab = Window:Tab({ Title = "Farm", Icon = "zap" })
local EventsTab = Window:Tab({ Title = "Events", Icon = "sparkles" })
local ClientTab = Window:Tab({ Title = "Client", Icon = "user" })
local AutomationTab = Window:Tab({ Title = "Automation", Icon = "bot" })
local HopTab = Window:Tab({ Title = "Hop", Icon = "refresh-cw" })
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local VisualTab = Window:Tab({ Title = "Visual", Icon = "eye" })
local ConfigureTab = Window:Tab({ Title = "Configure", Icon = "palette" })
local OtherTab = Window:Tab({ Title = "Other", Icon = "folder" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- Helper Services for Server Hopping & Client Features
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Helper Function to Attempt Teleporting to a Player's Server
local function TryTeleportToPlayer(username, roleName)
    local targetUserId
    local successId = pcall(function()
        targetUserId = Players:GetUserIdFromNameAsync(username)
    end)

    if not successId or not targetUserId then
        return false
    end

    local isPlaying, currentInstErr, placeId, jobId
    local successLookup = pcall(function()
        isPlaying, currentInstErr, placeId, jobId = TeleportService:GetPlayerPlaceInstanceAsync(targetUserId)
    end)

    if successLookup and placeId and jobId then
        WindUI:Notify({ Title = roleName, Content = "Found " .. username .. "! Teleporting...", Duration = 3 })
        
        local initialJobId = game.JobId
        pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
        end)

        task.spawn(function()
            task.wait(10)
            if game.JobId == initialJobId then
                WindUI:Notify({ 
                    Title = "Teleport Warning", 
                    Content = 'Please Check That Your "Disable Teleports" Is Off Because You Can\'t Teleport With This On', 
                    Duration = 7 
                })
            end
        end)
        return true
    end

    return false
end

-- Helper Function for Chat Messages (Supports Modern & Legacy Chat)
local function SendChatMessage(msg)
    local TextChatService = game:GetService("TextChatService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local generalChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if generalChannel then
            generalChannel:SendAsync(msg)
        end
    else
        local legacyRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if legacyRemote and legacyRemote:FindFirstChild("SayMessageRequest") then
            legacyRemote.SayMessageRequest:FireServer(msg, "All")
        end
    end
end

-- =============================================================
--                        1. MAIN TAB
-- =============================================================
MainTab:Section({ Title = "Hub Updates" })

MainTab:Button({
    Title = "View Update Log",
    Desc = "Displays recent hub changes and bug fixes",
    Callback = function()
        WindUI:Notify({
            Title = "Boost Hub - Update Log",
            Content = "[-] Added tool loading buffer delay after character respawn for Auto Beg\n[-] All tabs and features fully loaded",
            Duration = 8
        })
    end,
})

MainTab:Section({ Title = "Player Stats" })

MainTab:Slider({
    Title = "Walk Speed",
    Value = { Min = 16, Max = 300, Default = 16 },
    Callback = function(speed)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = speed
        end
        if speed > 16 and not getgenv().AntiBanEnabled then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 3 })
        end
    end,
})

MainTab:Slider({
    Title = "Jump Power",
    Value = { Min = 50, Max = 400, Default = 50 },
    Callback = function(power)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.UseJumpPower = true
            char.Humanoid.JumpPower = power
        end
        if power > 50 and not getgenv().AntiBanEnabled then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 3 })
        end
    end,
})

MainTab:Section({ Title = "Performance Settings" })

MainTab:Toggle({
    Title = "Disable 3D Render",
    Desc = "Pauses 3D rendering completely for max performance/FPS while AFK",
    Value = false,
    Callback = function(state)
        local runService = game:GetService("RunService")
        if runService.Set3dRenderingEnabled then
            runService:Set3dRenderingEnabled(not state)
            WindUI:Notify({ Title = "3D Render", Content = state and "3D Rendering Disabled!" or "3D Rendering Enabled!", Duration = 3 })
        else
            WindUI:Notify({ Title = "Error", Content = "Your executor does not support Set3dRenderingEnabled!", Duration = 3 })
        end
    end,
})

MainTab:Section({ Title = "Movement Abilities" })

local flying = false
local flySpeed = 50
local bodyVel, bodyGyro
local flyConnection

MainTab:Toggle({
    Title = "Fly",
    Desc = "Allows floating and flying freely (PC & Mobile)",
    Value = false,
    Callback = function(state)
        flying = state
        if state and not getgenv().AntiBanEnabled then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
        end
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end

        local hrp = char.HumanoidRootPart
        local humanoid = char.Humanoid

        if flying then
            bodyVel = Instance.new("BodyVelocity")
            bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bodyVel.Velocity = Vector3.zero
            bodyVel.Parent = hrp

            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            bodyGyro.CFrame = hrp.CFrame
            bodyGyro.Parent = hrp

            humanoid.PlatformStand = true

            flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if not flying or not hrp or not humanoid then 
                    if flyConnection then flyConnection:Disconnect() end
                    return 
                end

                local cam = workspace.CurrentCamera
                local moveDir = Vector3.zero
                local uis = game:GetService("UserInputService")

                if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                if moveDir.Magnitude == 0 then
                    local joyDir = humanoid.MoveDirection
                    if joyDir.Magnitude > 0 then
                        moveDir = joyDir
                    end
                    if humanoid.Jump then
                        moveDir = moveDir + Vector3.new(0, 1, 0)
                    end
                end

                bodyVel.Velocity = moveDir * flySpeed
                bodyGyro.CFrame = cam.CFrame
            end)
        else
            if flyConnection then flyConnection:Disconnect() end
            if bodyVel then bodyVel:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            if char:FindFirstChildOfClass("Humanoid") then
                char.Humanoid.PlatformStand = false
            end
        end
    end,
})

local infiniteJump = false
MainTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump continuously in mid-air",
    Value = false,
    Callback = function(state)
        infiniteJump = state
        if state and not getgenv().AntiBanEnabled then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 3 })
        end
    end,
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJump then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local noclip = false
MainTab:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls and obstacles",
    Value = false,
    Callback = function(state)
        noclip = state
        if state and not getgenv().AntiBanEnabled then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 3 })
        end
    end,
})

game:GetService("RunService").Stepped:Connect(function()
    if noclip then
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

MainTab:Toggle({
    Title = "Anchor Character",
    Desc = "Freezes your character in place",
    Value = false,
    Callback = function(state)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Anchored = state
        end
    end,
})

local invisSavedTransparencies = {}
MainTab:Toggle({
    Title = "Invisible",
    Desc = "Makes your character completely invisible",
    Value = false,
    Callback = function(state)
        local char = game.Players.LocalPlayer.Character
        if not char then return end

        if state then
            if not getgenv().AntiBanEnabled then
                WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 3 })
            end
            invisSavedTransparencies = {}
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    invisSavedTransparencies[v] = v.Transparency
                    v.Transparency = 1
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    invisSavedTransparencies[v] = v.Transparency
                    v.Transparency = 1
                end
            end
        else
            for v, trans in pairs(invisSavedTransparencies) do
                if v and v.Parent then
                    v.Transparency = trans
                end
            end
            invisSavedTransparencies = {}
        end
    end,
})

MainTab:Section({ Title = "Protection & Player Tools" })

local antiAfkConnection
MainTab:Toggle({
    Title = "Anti AFK",
    Desc = "Prevents getting kicked for idle",
    Value = true,
    Callback = function(state)
        getgenv().AntiAfk = state
        if state then
            local VirtualUser = game:GetService("VirtualUser")
            antiAfkConnection = game.Players.LocalPlayer.Idled:Connect(function()
                if getgenv().AntiAfk then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                    WindUI:Notify({ Title = "Anti AFK", Content = "Prevented AFK Kick!", Duration = 2 })
                end
            end)
        else
            if antiAfkConnection then antiAfkConnection:Disconnect() end
        end
    end,
})

local antiFlingConnection
MainTab:Toggle({
    Title = "Anti Fling",
    Desc = "Disables player collision to prevent flinging",
    Value = false,
    Callback = function(state)
        getgenv().AntiFling = state
        if state then
            antiFlingConnection = game:GetService("RunService").Stepped:Connect(function()
                if not getgenv().AntiFling then return end
                for _, player in pairs(game.Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer and player.Character then
                        for _, part in pairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        else
            if antiFlingConnection then antiFlingConnection:Disconnect() end
        end
    end,
})

local targetPlayerName = ""
MainTab:Input({
    Title = "Target Player",
    Desc = "Enter username or display name",
    Placeholder = "Player Name...",
    Callback = function(text)
        targetPlayerName = text
    end,
})

MainTab:Button({
    Title = "Teleport To Player",
    Desc = "Teleports you directly to selected player",
    Callback = function()
        if targetPlayerName == "" then
            WindUI:Notify({ Title = "Error", Content = "Please enter a player name first!", Duration = 3 })
            return
        end

        if not getgenv().AntiBanEnabled then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
        end

        local targetPlayer
        for _, p in pairs(game.Players:GetPlayers()) do
            if string.find(string.lower(p.Name), string.lower(targetPlayerName)) or 
               string.find(string.lower(p.DisplayName), string.lower(targetPlayerName)) then
                targetPlayer = p
                break
            end
        end

        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myChar = game.Players.LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                myChar.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                WindUI:Notify({ Title = "Teleported", Content = "Teleported to " .. targetPlayer.DisplayName, Duration = 3 })
            end
        else
            WindUI:Notify({ Title = "Error", Content = "Player not found or character missing!", Duration = 3 })
        end
    end,
})

-- =============================================================
--                        2. FARM TAB
-- =============================================================
FarmTab:Section({ Title = "Automation Delays" })

FarmTab:Slider({
    Title = "Adjust Delay Of Click (Ms)",
    Value = { Min = 100, Max = 10000, Default = getgenv().BoostHubConfig.CatClickDelay },
    Callback = function(ms)
        getgenv().CatClickDelay = ms / 1000
        getgenv().BoostHubConfig.CatClickDelay = ms
    end,
})

FarmTab:Slider({
    Title = "Adjust Delay For Auto RNG (Sec)",
    Value = { Min = 5, Max = 50, Default = getgenv().BoostHubConfig.RNGDelay },
    Callback = function(sec)
        getgenv().RNGDelay = sec
        getgenv().BoostHubConfig.RNGDelay = sec
    end,
})

FarmTab:Section({ Title = "Automation Toggles" })

local gato = nil
local function acharGato()
    if gato and gato.Parent then return gato end
    for _, o in pairs(workspace:GetDescendants()) do
        if o:IsA("ClickDetector") then
            local n = string.lower(o.Parent.Name)
            if string.find(n,"cat") or string.find(n,"gato") or string.find(n,"leader") or string.find(n,"clic") then
                gato = o
                return o
            end
        end
    end
    return nil
end

local function loop(alvo)
    local cx = (getconnections and getconnections(alvo.MouseClick)) or {}
    while getgenv().AutoCatClick and alvo and alvo.Parent do
        if #cx > 0 then
            for _, c in pairs(cx) do c:Fire() end
        else
            fireclickdetector(alvo)
        end
        
        local delayVal = getgenv().CatClickDelay or 0.1
        if getgenv().AntiBanEnabled then
            delayVal = delayVal + math.random(1, 10) / 100
        end
        task.wait(delayVal)
    end
end

FarmTab:Toggle({
    Title = "Auto Cat Click",
    Desc = "Automatically searches and clicks targets using ClickDetector scanner",
    Value = getgenv().BoostHubConfig.AutoCatClick,
    Callback = function(state)
        getgenv().AutoCatClick = state
        getgenv().BoostHubConfig.AutoCatClick = state
        if state then
            if not getgenv().AntiBanEnabled then
                WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
            end
            local tgt = acharGato()
            if tgt then
                WindUI:Notify({ Title = "Auto Cat Click", Content = "Status: Successfully clicking! 🔥", Duration = 3 })
                task.spawn(loop, tgt)
                task.spawn(loop, tgt)
            else
                WindUI:Notify({ Title = "Auto Cat Click", Content = "Status: Cat target not found.", Duration = 3 })
                getgenv().AutoCatClick = false
            end
        else
            gato = nil
        end
    end,
})

FarmTab:Toggle({
    Title = "Auto RNG",
    Desc = "Teleports to 'RNGButton' based on set delay",
    Value = getgenv().BoostHubConfig.AutoRNG,
    Callback = function(state)
        if state and getgenv().AutoGoal then
            WindUI:Notify({ 
                Title = "Conflict Warning", 
                Content = "WARNING! Auto RNG and Auto Goal can't be activated at the same time!", 
                Duration = 5 
            })
            getgenv().AutoRNG = false
            getgenv().BoostHubConfig.AutoRNG = false
            return
        end

        getgenv().AutoRNG = state
        getgenv().BoostHubConfig.AutoRNG = state
        if state then
            if not getgenv().AntiBanEnabled then
                WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
            end
            task.spawn(function()
                while getgenv().AutoRNG do
                    local rngPart = workspace:FindFirstChild("RNGButton", true)
                    local char = game.Players.LocalPlayer.Character
                    
                    if rngPart and char and char:FindFirstChild("HumanoidRootPart") then
                        if rngPart:IsA("Model") then
                            char.HumanoidRootPart.CFrame = rngPart:GetPivot() + Vector3.new(0, 3, 0)
                        elseif rngPart:IsA("BasePart") then
                            char.HumanoidRootPart.CFrame = rngPart.CFrame + Vector3.new(0, 3, 0)
                        end
                    end
                    
                    local delaySec = getgenv().RNGDelay or 15
                    if getgenv().AntiBanEnabled then
                        delaySec = delaySec + math.random(1, 4)
                    end
                    local elapsed = 0
                    while elapsed < delaySec and getgenv().AutoRNG do
                        task.wait(0.5)
                        elapsed = elapsed + 0.5
                    end
                end
            end)
        end
    end,
})

FarmTab:Toggle({
    Title = "Auto Goal",
    Desc = "Teleports to SoccerBall and pushes it towards the goal every 3-4 seconds",
    Value = getgenv().BoostHubConfig.AutoGoal,
    Callback = function(state)
        if state and getgenv().AutoRNG then
            WindUI:Notify({ 
                Title = "Conflict Warning", 
                Content = "WARNING! Auto RNG and Auto Goal can't be activated at the same time!", 
                Duration = 5 
            })
            getgenv().AutoGoal = false
            getgenv().BoostHubConfig.AutoGoal = false
            return
        end

        getgenv().AutoGoal = state
        getgenv().BoostHubConfig.AutoGoal = state

        if not state then
            return
        end

        if not getgenv().AntiBanEnabled then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
        end
        
        task.spawn(function()
            while getgenv().AutoGoal do
                local currentChar = game.Players.LocalPlayer.Character
                local soccerBall = workspace:FindFirstChild("SoccerBall", true)
                
                if soccerBall and currentChar and currentChar:FindFirstChild("HumanoidRootPart") then
                    local hrp = currentChar.HumanoidRootPart
                    local ballPart = soccerBall:IsA("BasePart") and soccerBall or soccerBall:FindFirstChildWhichIsA("BasePart", true)
                    
                    if ballPart then
                        hrp.CFrame = ballPart.CFrame + Vector3.new(0, 2, -3)
                        
                        if ballPart:IsA("BasePart") then
                            ballPart.AssemblyLinearVelocity = Vector3.new(0, 5, 35)
                        end
                    end
                end
                
                local waitTime = math.random(30, 40) / 10
                task.wait(waitTime)
            end
        end)
        
        WindUI:Notify({ Title = "Auto Goal", Content = "Auto Goal activated (Pushing every 3-4s without anchor)!", Duration = 3 })
    end,
})

-- =============================================================
--                        3. EVENTS TAB
-- =============================================================
EventsTab:Section({ Title = "Special Events" })

EventsTab:Toggle({
    Title = "Auto Collect Orbs [NEW]",
    Desc = "Automatically teleports to DiscoOrb parts and stops when no orbs are left",
    Value = getgenv().BoostHubConfig.AutoCollectOrbs,
    Callback = function(state)
        getgenv().AutoCollectOrbs = state
        getgenv().BoostHubConfig.AutoCollectOrbs = state
        
        if state then
            if not getgenv().AntiBanEnabled then
                WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
            end
            
            WindUI:Notify({ Title = "Auto Collect Orbs", Content = "Started collecting DiscoOrbs!", Duration = 3 })
            
            task.spawn(function()
                while getgenv().AutoCollectOrbs do
                    local char = game.Players.LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    
                    local orb = workspace:FindFirstChild("DiscoOrb", true)
                    
                    if orb and hrp then
                        if orb:IsA("Model") then
                            hrp.CFrame = orb:GetPivot() + Vector3.new(0, 3, 0)
                        elseif orb:IsA("BasePart") then
                            hrp.CFrame = orb.CFrame + Vector3.new(0, 3, 0)
                        end
                    else
                        WindUI:Notify({ Title = "Auto Collect Orbs", Content = "No more orbs found! Auto Collect stopped.", Duration = 4 })
                        getgenv().AutoCollectOrbs = false
                        getgenv().BoostHubConfig.AutoCollectOrbs = false
                        break
                    end
                    
                    task.wait(0.3)
                end
            end)
        end
    end,
})

-- =============================================================
--                        4. CLIENT TAB
-- =============================================================
ClientTab:Section({ Title = "Custom Audio Player" })

ClientTab:Input({
    Title = "Audio ID",
    Desc = "Enter Roblox Audio ID numbers",
    Placeholder = "18483545",
    Callback = function(text)
        customAudioId = text
    end,
})

ClientTab:Button({
    Title = "Play Custom Audio",
    Desc = "Plays audio locally and mutes all game music",
    Callback = function()
        if customAudioId == "" then
            WindUI:Notify({ Title = "Error", Content = "Please enter an Audio ID first!", Duration = 3 })
            return
        end

        if activeCustomSound then
            activeCustomSound:Stop()
            activeCustomSound:Destroy()
            activeCustomSound = nil
        end

        originalVolumes = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Sound") then
                originalVolumes[obj] = obj.Volume
                obj.Volume = 0
            end
        end
        for _, obj in pairs(game:GetService("SoundService"):GetDescendants()) do
            if obj:IsA("Sound") then
                originalVolumes[obj] = obj.Volume
                obj.Volume = 0
            end
        end

        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. customAudioId
        sound.Volume = 1
        sound.Looped = true
        sound.Parent = game:GetService("SoundService")
        sound:Play()
        activeCustomSound = sound

        WindUI:Notify({ Title = "Audio Playing", Content = "Custom audio playing locally. Game music muted.", Duration = 4 })
    end,
})

ClientTab:Button({
    Title = "Stop Custom Audio & Restore Game Music",
    Desc = "Stops custom audio and restores original game sound",
    Callback = function()
        if activeCustomSound then
            activeCustomSound:Stop()
            activeCustomSound:Destroy()
            activeCustomSound = nil
        end

        for sound, vol in pairs(originalVolumes) do
            if sound and sound.Parent then
                sound.Volume = vol
            end
        end
        originalVolumes = {}

        WindUI:Notify({ Title = "Audio Stopped", Content = "Custom audio stopped and game music restored.", Duration = 3 })
    end,
})

ClientTab:Section({ Title = "Client-Side Morph" })

ClientTab:Input({
    Title = "Target Username",
    Desc = "Enter player username to morph into locally",
    Placeholder = "Username...",
    Callback = function(text)
        morphTargetName = text
    end,
})

ClientTab:Button({
    Title = "Morph into Player",
    Desc = "Locally changes your appearance (only visible to you)",
    Callback = function()
        if morphTargetName == "" then
            WindUI:Notify({ Title = "Error", Content = "Please enter a username first!", Duration = 3 })
            return
        end

        task.spawn(function()
            local targetPlayer = nil
            for _, p in pairs(Players:GetPlayers()) do
                if string.lower(p.Name) == string.lower(morphTargetName) or string.lower(p.DisplayName) == string.lower(morphTargetName) then
                    targetPlayer = p
                    break
                end
            end

            local localChar = Players.LocalPlayer.Character
            if not localChar or not localChar:FindFirstChildOfClass("Humanoid") then
                WindUI:Notify({ Title = "Morph Error", Content = "Your character is missing!", Duration = 4 })
                return
            end

            if targetPlayer and targetPlayer.Character then
                local targetChar = targetPlayer.Character
                for _, v in pairs(localChar:GetChildren()) do
                    if v:IsA("Accessory") or v:IsA("Clothing") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") then
                        v:Destroy()
                    end
                end

                for _, v in pairs(targetChar:GetChildren()) do
                    if v:IsA("Accessory") or v:IsA("Clothing") or v:IsA("ShirtGraphic") or v:IsA("BodyColors") then
                        v:Clone().Parent = localChar
                    end
                end

                local targetHead = targetChar:FindFirstChild("Head")
                local localHead = localChar:FindFirstChild("Head")
                if targetHead and localHead then
                    local targetFace = targetHead:FindFirstChildOfClass("Decal")
                    local localFace = localHead:FindFirstChildOfClass("Decal")
                    if targetFace then
                        if localFace then
                            localFace.Texture = targetFace.Texture
                        else
                            targetFace:Clone().Parent = localHead
                        end
                    end
                end

                WindUI:Notify({ Title = "Morph Success", Content = "Locally morphed into " .. targetPlayer.DisplayName .. "!", Duration = 4 })
            else
                local successId, targetUserId = pcall(function()
                    return Players:GetUserIdFromNameAsync(morphTargetName)
                end)

                if not successId or not targetUserId then
                    WindUI:Notify({ Title = "Morph Error", Content = "Could not find user: " .. morphTargetName, Duration = 4 })
                    return
                end

                local successDesc, humanoidDesc = pcall(function()
                    return Players:GetHumanoidDescriptionFromUserId(targetUserId)
                end)

                if not successDesc or not humanoidDesc then
                    WindUI:Notify({ Title = "Morph Error", Content = "Failed to load appearance (restricted items).", Duration = 4 })
                    return
                end

                local humanoid = localChar:FindFirstChildOfClass("Humanoid")
                local successApply = pcall(function()
                    humanoid:ApplyDescription(humanoidDesc)
                end)

                if successApply then
                    WindUI:Notify({ Title = "Morph Success", Content = "Locally morphed into " .. morphTargetName .. "!", Duration = 4 })
                else
                    WindUI:Notify({ Title = "Morph Error", Content = "Failed to apply description locally.", Duration = 4 })
                end
            end
        end)
    end,
})

-- =============================================================
--                     5. AUTOMATION TAB
-- =============================================================
AutomationTab:Section({ Title = "Anti-Ban Protection" })

AutomationTab:Toggle({
    Title = "Anti-Ban Safe Mode",
    Desc = "Randomizes action timings (jitter) to prevent anti-cheat detection",
    Value = getgenv().BoostHubConfig.AntiBanEnabled,
    Callback = function(state)
        getgenv().AntiBanEnabled = state
        getgenv().BoostHubConfig.AntiBanEnabled = state
        WindUI:Notify({ Title = "Anti-Ban", Content = state and "Anti-Ban Safe Mode Enabled!" or "Anti-Ban Safe Mode Disabled!", Duration = 3 })
    end,
})

AutomationTab:Section({ Title = "Stand & Begging Tasks" })

local instantPromptConn = nil
AutomationTab:Toggle({
    Title = "Instant Proximity Prompts",
    Desc = "Sets all ProximityPrompt HoldDuration to 0 for instant triggering",
    Value = false,
    Callback = function(state)
        if state then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    obj.HoldDuration = 0
                end
            end
            instantPromptConn = workspace.DescendantAdded:Connect(function(child)
                if child:IsA("ProximityPrompt") then
                    child.HoldDuration = 0
                end
            end)
            WindUI:Notify({ Title = "Instant Prompts", Content = "Proximity Prompts are now instant!", Duration = 3 })
        else
            if instantPromptConn then
                instantPromptConn:Disconnect()
                instantPromptConn = nil
            end
            WindUI:Notify({ Title = "Instant Prompts", Content = "Instant Prompts disabled.", Duration = 3 })
        end
    end,
})

AutomationTab:Button({
    Title = "Claim Stand",
    Desc = "Scans all ProximityPrompts, teleports to stand, and stays for 2 seconds",
    Callback = function()
        if not getgenv().AntiBanEnabled then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
        end

        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        local hrp = char.HumanoidRootPart
        local originalCFrame = hrp.CFrame

        local prompts = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local actionText = string.lower(obj.ActionText or "")
                local objectText = string.lower(obj.ObjectText or "")
                if string.find(actionText, "claim") or string.find(objectText, "claim") or string.find(actionText, "stand") or string.find(objectText, "stand") then
                    table.insert(prompts, obj)
                end
            end
        end

        if #prompts == 0 then
            WindUI:Notify({ Title = "Claim Stand", Content = "No claimable stand prompts found in workspace!", Duration = 4 })
            return
        end

        for i = #prompts, 2, -1 do
            local j = math.random(1, i)
            prompts[i], prompts[j] = prompts[j], prompts[i]
        end

        local claimed = false
        for _, prompt in ipairs(prompts) do
            if prompt and prompt.Parent then
                local targetPart = nil
                if prompt.Parent:IsA("BasePart") then
                    targetPart = prompt.Parent
                elseif prompt.Parent:IsA("Model") then
                    targetPart = prompt.Parent.PrimaryPart or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                end

                if targetPart then
                    hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
                    task.wait(0.5)

                    WindUI:Notify({ Title = "Claim Stand", Content = "Claiming stand! Holding position for 2 seconds...", Duration = 3 })

                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    else
                        prompt:InputHoldBegin()
                        task.wait(0.1)
                        prompt:InputHoldEnd()
                    end

                    local startTime = tick()
                    while tick() - startTime < 2 do
                        if hrp and targetPart then
                            hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
                        end
                        task.wait(0.2)
                    end

                    claimed = true
                    break
                end
            end
        end

        hrp.CFrame = originalCFrame

        if claimed then
            WindUI:Notify({ Title = "Claim Stand", Content = "Successfully claimed stand and returned!", Duration = 3 })
        else
            WindUI:Notify({ Title = "Claim Stand", Content = "Could not locate a physical part to teleport to!", Duration = 4 })
        end
    end,
})

-- AUTO BEG TOGGLE (PATHFINDING WALKING MODE + TOOL BUFFER FIX)
AutomationTab:Toggle({
    Title = "Auto Beg",
    Desc = "Pathfinds and walks to players with paid items, stopping 5-7 studs in front",
    Value = getgenv().BoostHubConfig.AutoBeg,
    Callback = function(state)
        getgenv().AutoBeg = state
        getgenv().BoostHubConfig.AutoBeg = state

        if state then
            if not getgenv().AntiBanEnabled then
                WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
            end

            WindUI:Notify({ Title = "Auto Beg", Content = "Auto Beg pathfinding started!", Duration = 3 })

            task.spawn(function()
                local PathfindingService = game:GetService("PathfindingService")

                -- Buffer delay on startup/respawn to let inventory load the tool
                task.wait(2.5)

                while getgenv().AutoBeg do
                    local player = game.Players.LocalPlayer
                    local char = player.Character
                    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then
                        task.wait(1)
                        continue
                    end

                    local hrp = char.HumanoidRootPart
                    local humanoid = char.Humanoid

                    -- 1. Check if holding a tool (with backpack fallback and retry buffer)
                    local equippedTool = char:FindFirstChildOfClass("Tool")
                    if not equippedTool then
                        task.wait(1) -- Extra second to ensure backpack items loaded after reset
                        local backpackTool = player.Backpack and player.Backpack:FindFirstChildOfClass("Tool")
                        if backpackTool then
                            humanoid:EquipTool(backpackTool)
                            task.wait(0.8)
                            equippedTool = char:FindFirstChildOfClass("Tool")
                        end
                    end

                    if not equippedTool then
                        WindUI:Notify({ Title = "Auto Beg", Content = "Buy a Sign in a shop for this to work!", Duration = 6 })
                        getgenv().AutoBeg = false
                        getgenv().BoostHubConfig.AutoBeg = false
                        break
                    end

                    -- 2. Scan players for paid items
                    local targetPlayer = nil
                    for _, p in ipairs(game.Players:GetPlayers()) do
                        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local hasPaidItem = false
                            for _, desc in ipairs(p.Character:GetDescendants()) do
                                if desc:IsA("Accessory") or desc:IsA("Clothing") or desc:IsA("ShirtGraphic") or desc:IsA("BodyColors") then
                                    hasPaidItem = true
                                    break
                                end
                            end
                            if hasPaidItem then
                                targetPlayer = p
                                break
                            end
                        end
                    end

                    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHrp = targetPlayer.Character.HumanoidRootPart
                        local randomStuds = math.random(5, 7)
                        local destination = targetHrp.Position + (targetHrp.CFrame.LookVector * randomStuds)

                        -- Pathfinding Walk Route
                        local path = PathfindingService:CreatePath({
                            AgentRadius = 2,
                            AgentHeight = 5,
                            AgentCanJump = true
                        })

                        local success = pcall(function()
                            path:ComputeAsync(hrp.Position, destination)
                        end)

                        if success and path.Status == Enum.PathStatus.Success then
                            local waypoints = path:GetWaypoints()
                            for _, waypoint in ipairs(waypoints) do
                                if not getgenv().AutoBeg then break end
                                humanoid:MoveTo(waypoint.Position)
                                if waypoint.Action == Enum.PathWaypointAction.Jump then
                                    humanoid.Jump = true
                                end
                                
                                local reached = false
                                local conn
                                conn = humanoid.MoveToFinished:Connect(function()
                                    reached = true
                                    if conn then conn:Disconnect() end
                                end)

                                local startWait = tick()
                                while not reached and tick() - startWait < 1.5 and getgenv().AutoBeg do
                                    task.wait(0.1)
                                end
                                if conn then conn:Disconnect() end
                            end
                        else
                            -- Fallback direct move if pathfinding fails
                            humanoid:MoveTo(destination)
                        end
                    else
                        -- No players with items found: walk to SpawnLocation and wait
                        local spawnLoc = workspace:FindFirstChild("SpawnLocation", true)
                        if spawnLoc then
                            local spawnPos = spawnLoc:IsA("Model") and spawnLoc:GetPivot().Position or spawnLoc.Position
                            humanoid:MoveTo(spawnPos)
                        end
                    end

                    -- Wait for 15 seconds, then reset character to search for another player
                    local elapsed = 0
                    while elapsed < 15 and getgenv().AutoBeg do
                        task.wait(0.5)
                        elapsed = elapsed + 0.5
                    end

                    if getgenv().AutoBeg and char and char:FindFirstChildOfClass("Humanoid") then
                        char.Humanoid.Health = 0 -- Reset character
                        task.wait(2.5) -- Wait for respawn and tool loading buffer
                    end
                end
            end)
        end
    end,
})

AutomationTab:Section({ Title = "Advanced Automation & Chat" })

local autoEquipSign = false
local charAddedConn
AutomationTab:Toggle({
    Title = "Auto Equip Sign on Spawn",
    Desc = "Automatically equips your sign tool when you respawn",
    Value = false,
    Callback = function(state)
        autoEquipSign = state
        if state and not getgenv().AntiBanEnabled then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 3 })
        end
        local player = game.Players.LocalPlayer
        if state then
            charAddedConn = player.CharacterAdded:Connect(function(char)
                if not autoEquipSign then return end
                task.wait(1.5)
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    for _, tool in pairs(player.Backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            humanoid:EquipTool(tool)
                            break
                        end
                    end
                end
            end)
            WindUI:Notify({ Title = "Auto Equip", Content = "Auto Equip Sign enabled!", Duration = 3 })
        else
            if charAddedConn then charAddedConn:Disconnect() end
        end
    end,
})

local autoRejoin = false
local rejoinConn
AutomationTab:Toggle({
    Title = "Auto Rejoin on Kick",
    Desc = "Automatically rejoins the game if disconnected or kicked",
    Value = false,
    Callback = function(state)
        autoRejoin = state
        if state then
            rejoinConn = game:GetService("CoreGui").ChildAdded:Connect(function(child)
                if autoRejoin and (child.Name == "RobloxPromptGui" or child.Name == "ErrorPrompt") then
                    task.wait(2)
                    game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
                end
            end)
            WindUI:Notify({ Title = "Auto Rejoin", Content = "Auto Rejoin enabled!", Duration = 3 })
        else
            if rejoinConn then rejoinConn:Disconnect() end
        end
    end,
})

AutomationTab:Section({ Title = "Custom Auto Spam Messages" })

AutomationTab:Input({
    Title = "Spam Message 1",
    Desc = "Edit spam message #1",
    Placeholder = "Enter message...",
    Value = autoChatMessages[1],
    Callback = function(text)
        if text ~= "" then autoChatMessages[1] = text end
    end,
})

AutomationTab:Input({
    Title = "Spam Message 2",
    Desc = "Edit spam message #2",
    Placeholder = "Enter message...",
    Value = autoChatMessages[2],
    Callback = function(text)
        if text ~= "" then autoChatMessages[2] = text end
    end,
})

AutomationTab:Input({
    Title = "Spam Message 3",
    Desc = "Edit spam message #3",
    Placeholder = "Enter message...",
    Value = autoChatMessages[3],
    Callback = function(text)
        if text ~= "" then autoChatMessages[3] = text end
    end,
})

AutomationTab:Input({
    Title = "Spam Message 4",
    Desc = "Edit spam message #4",
    Placeholder = "Enter message...",
    Value = autoChatMessages[4],
    Callback = function(text)
        if text ~= "" then autoChatMessages[4] = text end
    end,
})

AutomationTab:Input({
    Title = "Spam Message 5",
    Desc = "Edit spam message #5",
    Placeholder = "Enter message...",
    Value = autoChatMessages[5],
    Callback = function(text)
        if text ~= "" then autoChatMessages[5] = text end
    end,
})

AutomationTab:Toggle({
    Title = "Auto Chat Spammer",
    Desc = "Sends a random custom message from your 5 fields every 15 seconds",
    Value = getgenv().BoostHubConfig.AutoChatSpam,
    Callback = function(state)
        getgenv().AutoChatSpam = state
        getgenv().BoostHubConfig.AutoChatSpam = state
        if state then
            if not getgenv().AntiBanEnabled then
                WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
            end
            task.spawn(function()
                while getgenv().AutoChatSpam do
                    local activeMessages = {}
                    for _, msg in ipairs(autoChatMessages) do
                        if msg and msg ~= "" then
                            table.insert(activeMessages, msg)
                        end
                    end
                    
                    if #activeMessages > 0 then
                        local randomIndex = math.random(1, #activeMessages)
                        SendChatMessage(activeMessages[randomIndex])
                    end
                    
                    local waitTime = 15
                    if getgenv().AntiBanEnabled then
                        waitTime = waitTime + math.random(-3, 4)
                    end
                    
                    local elapsed = 0
                    while elapsed < waitTime and getgenv().AutoChatSpam do
                        task.wait(0.5)
                        elapsed = elapsed + 0.5
                    end
                end
            end)
            WindUI:Notify({ Title = "Auto Chat", Content = "Auto Chat Spammer enabled!", Duration = 3 })
        end
    end,
})

-- =============================================================
--                        6. HOP TAB
-- =============================================================
HopTab:Section({ Title = "Server Hopping Tasks" })

HopTab:Button({
    Title = "Normal Server Hop",
    Desc = "Teleports to a random available server in this game",
    Callback = function()
        WindUI:Notify({ Title = "Server Hop", Content = "Searching for a new server...", Duration = 3 })
        task.spawn(function()
            local placeId = game.PlaceId
            local servers = {}
            local req = (syn and syn.request) or (http and http.request) or http_request or request
            if req then
                local raw = req({ Url = string.format("https://games.roblox.com/v1/games/%d/servers/0?sortOrder=Desc&limit=100", placeId) })
                if raw and raw.Body then
                    local data = HttpService:JSONDecode(raw.Body)
                    if data and data.data then
                        for _, server in ipairs(data.data) do
                            if type(server) == "table" and server.id ~= game.JobId and server.playing < server.maxPlayers then
                                table.insert(servers, server.id)
                            end
                        end
                    end
                end
            end

            if #servers > 0 then
                local targetJob = servers[math.random(1, #servers)]
                TeleportService:TeleportToPlaceInstance(placeId, targetJob, Players.LocalPlayer)
            else
                TeleportService:Teleport(placeId, Players.LocalPlayer)
            end
        end)
    end,
})

HopTab:Button({
    Title = "Small Server Hop",
    Desc = "Teleports to a server with a low player count",
    Callback = function()
        WindUI:Notify({ Title = "Small Server Hop", Content = "Searching for low-player servers...", Duration = 3 })
        task.spawn(function()
            local placeId = game.PlaceId
            local req = (syn and syn.request) or (http and http.request) or http_request or request
            if not req then
                WindUI:Notify({ Title = "Error", Content = "Your executor does not support HTTP requests!", Duration = 4 })
                return
            end

            local cursor = ""
            local foundTarget = false

            for i = 1, 5 do
                local url = string.format("https://games.roblox.com/v1/games/%d/servers/0?sortOrder=Asc&limit=100", placeId)
                if cursor ~= "" then
                    url = url .. "&cursor=" .. cursor
                end

                local raw = req({ Url = url })
                if raw and raw.Body then
                    local data = HttpService:JSONDecode(raw.Body)
                    if data and data.data then
                        for _, server in ipairs(data.data) do
                            if type(server) == "table" and server.id ~= game.JobId and server.playing > 0 and server.playing < server.maxPlayers then
                                WindUI:Notify({ Title = "Small Server Hop", Content = "Found server with " .. tostring(server.playing) .. " players! Teleporting...", Duration = 3 })
                                TeleportService:TeleportToPlaceInstance(placeId, server.id, Players.LocalPlayer)
                                foundTarget = true
                                break
                            end
                        end
                        if foundTarget then break end
                        cursor = data.nextPageCursor or ""
                        if cursor == "" then break end
                    end
                end
            end

            if not foundTarget then
                WindUI:Notify({ Title = "Server Hop Failed", Content = "Could not find a smaller server right now.", Duration = 4 })
            end
        end)
    end,
})

HopTab:Button({
    Title = "Join Owner Server",
    Desc = "Teleports to owner 'bvetterdays' if currently playing",
    Callback = function()
        local joined = TryTeleportToPlayer("bvetterdays", "Owner Server")
        if not joined then
            WindUI:Notify({ Title = "Owner Server", Content = "Owner (bvetterdays) is currently offline or not in a game!", Duration = 4 })
        end
    end,
})

HopTab:Button({
    Title = "Join Rich Server",
    Desc = "Joins valchuuz -> ZephyReveries -> angel019999",
    Callback = function()
        WindUI:Notify({ Title = "Rich Server", Content = "Searching for available Rich Servers...", Duration = 3 })

        if TryTeleportToPlayer("valchuuz", "Rich Server (valchuuz)") then return end
        if TryTeleportToPlayer("ZephyReveries", "Rich Server (ZephyReveries)") then return end
        if TryTeleportToPlayer("angel019999", "Rich Server (angel019999)") then return end

        WindUI:Notify({ Title = "Hop Failed", Content = "No Rich Servers Were Found", Duration = 5 })
    end,
})

-- =============================================================
--                        7. TELEPORT TAB
-- =============================================================
TeleportTab:Section({ Title = "Location Teleports" })

local function TeleportToTarget(targetObj, displayName)
    if not getgenv().AntiBanEnabled then
        WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
    end
    local char = game.Players.LocalPlayer.Character
    if targetObj and char and char:FindFirstChild("HumanoidRootPart") then
        if targetObj:IsA("Model") then
            char.HumanoidRootPart.CFrame = targetObj:GetPivot() + Vector3.new(0, 3, 0)
        elseif targetObj:IsA("BasePart") then
            char.HumanoidRootPart.CFrame = targetObj.CFrame + Vector3.new(0, 3, 0)
        end
        WindUI:Notify({ Title = "Teleported", Content = "Teleported to " .. displayName, Duration = 3 })
    else
        WindUI:Notify({ Title = "Error", Content = displayName .. " target not found!", Duration = 3 })
    end
end

TeleportTab:Button({
    Title = "Teleport To RNG",
    Desc = "Teleports directly to RNGButton",
    Callback = function()
        TeleportToTarget(workspace:FindFirstChild("RNGButton", true), "RNGButton")
    end,
})

TeleportTab:Button({
    Title = "Teleport To SoccerBall",
    Desc = "Teleports directly to SoccerBall",
    Callback = function()
        TeleportToTarget(workspace:FindFirstChild("SoccerBall", true), "SoccerBall")
    end,
})

-- =============================================================
--                      8. VISUAL TAB
-- =============================================================
VisualTab:Section({ Title = "Performance & Graphics" })

VisualTab:Toggle({
    Title = "Anti Lag / FPS Boost",
    Desc = "Optimizes graphics and clears rendering heavy effects for maximum FPS",
    Value = false,
    Callback = function(state)
        if state then
            local lighting = game:GetService("Lighting")
            lighting.GlobalShadows = false
            lighting.FogEnd = 9e9
            
            for _, v in pairs(lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") then
                    v.Enabled = false
                end
            end
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Texture = ""
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                end
            end
            WindUI:Notify({ Title = "FPS Boost", Content = "Anti Lag applied successfully!", Duration = 3 })
        else
            WindUI:Notify({ Title = "FPS Boost", Content = "Rejoin the game to restore default graphics.", Duration = 3 })
        end
    end,
})

local fullBright = false
local origBrightness, origClock, origShadows
VisualTab:Toggle({
    Title = "Full Bright",
    Desc = "Removes darkness and shadows across the map",
    Value = false,
    Callback = function(state)
        fullBright = state
        local lighting = game:GetService("Lighting")
        if state then
            origBrightness = lighting.Brightness
            origClock = lighting.ClockTime
            origShadows = lighting.GlobalShadows
            
            lighting.Brightness = 2
            lighting.ClockTime = 14
            lighting.GlobalShadows = false
            WindUI:Notify({ Title = "Full Bright", Content = "Full Bright enabled!", Duration = 3 })
        else
            if origBrightness then lighting.Brightness = origBrightness end
            if origClock then lighting.ClockTime = origClock end
            if origShadows ~= nil then lighting.GlobalShadows = origShadows end
        end
    end,
})

local fpsPingDisplay = false
VisualTab:Toggle({
    Title = "FPS & Ping Display",
    Desc = "Shows real-time FPS and Ping notification ticker",
    Value = false,
    Callback = function(state)
        fpsPingDisplay = state
        if state then
            task.spawn(function()
                while fpsPingDisplay do
                    local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
                    local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
                    WindUI:Notify({ Title = "Performance Stats", Content = string.format("FPS: %d | Ping: %d ms", fps, ping), Duration = 2 })
                    task.wait(6)
                end
            end)
            WindUI:Notify({ Title = "Stats", Content = "FPS & Ping Tracker started!", Duration = 3 })
        end
    end,
})

VisualTab:Section({ Title = "Player Visibility" })

VisualTab:Toggle({
    Title = "Hide Other Players",
    Desc = "Makes all other players' characters completely invisible",
    Value = false,
    Callback = function(state)
        local function togglePlayer(plr, hide)
            if plr ~= game.Players.LocalPlayer and plr.Character then
                for _, part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        part.Transparency = hide and 1 or 0
                    end
                end
            end
        end

        for _, p in pairs(game.Players:GetPlayers()) do
            togglePlayer(p, state)
            if state then
                p.CharacterAdded:Connect(function(char)
                    task.wait(1)
                    if getgenv().HideOthers then
                        togglePlayer(p, true)
                    end
                end)
            end
        end
        getgenv().HideOthers = state
        WindUI:Notify({ Title = "Hide Players", Content = state and "Hidden other players!" or "Showed other players!", Duration = 3 })
    end,
})

VisualTab:Section({ Title = "RichText Formatting Generator" })

VisualTab:Input({
    Title = "Type Text",
    Desc = "Enter the text to format",
    Placeholder = "testing",
    Callback = function(text)
        if text ~= "" then
            textGenText = text
        end
    end,
})

VisualTab:Input({
    Title = "Choose Font",
    Desc = "e.g., FredokaOne, SourceSans, GothamBold, Arcade",
    Placeholder = "FredokaOne",
    Callback = function(font)
        if font ~= "" then
            textGenFont = font
        end
    end,
})

VisualTab:Input({
    Title = "Choose Text Color (HEX)",
    Desc = "e.g., #ff0000 (Red), #00ff00 (Green), #0000ff (Blue)",
    Placeholder = "#ff0000",
    Callback = function(color)
        if color ~= "" then
            textGenColor = color
        end
    end,
})

VisualTab:Slider({
    Title = "Stroke Thickness",
    Value = { Min = 1, Max = 5, Default = 1 },
    Callback = function(thickness)
        textGenThickness = thickness
    end,
})

VisualTab:Button({
    Title = "Copy Formatted RichText",
    Desc = "Generates and copies RichText code to clipboard",
    Callback = function()
        local formattedResult = string.format(
            '<font color="%s" face="%s"><stroke color="%s" thickness="%d">%s</stroke></font>',
            textGenColor,
            textGenFont,
            textGenStrokeColor,
            textGenThickness,
            textGenText
        )

        if setclipboard then
            setclipboard(formattedResult)
            WindUI:Notify({ 
                Title = "RichText Copied!", 
                Content = "Result: " .. formattedResult, 
                Duration = 4 
            })
        else
            WindUI:Notify({ 
                Title = "Error", 
                Content = "Your executor does not support setclipboard!", 
                Duration = 3 
            })
        end
    end,
})

-- =============================================================
--                    9. CONFIGURE TAB
-- =============================================================
ConfigureTab:Section({ Title = "Saved Configurations & Auto Execute" })

ConfigureTab:Toggle({
    Title = "Auto Execute",
    Desc = "Automatically re-executes Boost Hub on server hop or reconnect",
    Value = getgenv().BoostHubConfig.AutoExecuteEnabled,
    Callback = function(state)
        getgenv().BoostHubConfig.AutoExecuteEnabled = state
        if state and (queue_on_teleport or syn and syn.queue_on_teleport) then
            local queueFunction = queue_on_teleport or syn.queue_on_teleport
            queueFunction([[
                task.wait(2)
                loadstring(game:HttpGet("YOUR_SCRIPT_URL_HERE"))()
            ]])
            WindUI:Notify({ Title = "Auto Execute", Content = "Auto Execute enabled successfully!", Duration = 3 })
        else
            WindUI:Notify({ Title = "Auto Execute", Content = state and "Executor doesn't support queue_on_teleport!" or "Auto Execute disabled.", Duration = 4 })
        end
    end,
})

ConfigureTab:Button({
    Title = "Save Current Configuration",
    Desc = "Saves your active settings (Auto Cat Click, Delays, etc.)",
    Callback = function()
        if writefile then
            local successSave, err = pcall(function()
                local httpService = game:GetService("HttpService")
                local encoded = httpService:JSONEncode(getgenv().BoostHubConfig)
                writefile("BoostHubConfig.json", encoded)
            end)
            if successSave then
                WindUI:Notify({ Title = "Config Saved", Content = "Successfully saved your settings!", Duration = 3 })
            else
                WindUI:Notify({ Title = "Error", Content = "Failed to write config file.", Duration = 3 })
            end
        else
            WindUI:Notify({ Title = "Error", Content = "Your executor does not support writefile!", Duration = 3 })
        end
    end,
})

ConfigureTab:Section({ Title = "UI Theme Settings" })

ConfigureTab:Dropdown({
    Title = "UI Theme",
    Desc = "Select your preferred WindUI color theme",
    Values = { "Dark", "Light", "Rose", "Emerald", "Midnight", "Red", "Aquamarine", "Amethyst" },
    Default = "Dark",
    Callback = function(selectedTheme)
        pcall(function()
            if Window and Window.SetTheme then
                Window:SetTheme(selectedTheme)
            elseif WindUI and WindUI.SetTheme then
                WindUI:SetTheme(selectedTheme)
            end
        end)
        WindUI:Notify({ Title = "Theme Changed", Content = "UI theme updated to " .. selectedTheme, Duration = 3 })
    end,
})

ConfigureTab:Toggle({
    Title = "Window Transparency",
    Desc = "Enable glass/blur transparency effect on window",
    Value = true,
    Callback = function(state)
        if Window and Window.SetTransparent then
            Window:SetTransparent(state)
        end
    end,
})

-- =============================================================
--                        10. OTHER TAB
-- =============================================================
OtherTab:Section({ Title = "External Hubs & Scripts" })

OtherTab:Button({
    Title = "Prixy Hub",
    Desc = "by ajoapaulo2409",
    Callback = function()
        loadstring(game:HttpGet("https://scriptblox.com/raw/FIXED-DONATIONS-PLS-WAIT-Prixy-Hub-auto-Cat-237080"))()
        WindUI:Notify({ Title = "Prixy Hub", Content = "Loaded Prixy Hub successfully!", Duration = 3 })
    end,
})

-- =============================================================
--                      11. SETTINGS TAB
-- =============================================================
SettingsTab:Section({ Title = "Developer Info" })

SettingsTab:Button({
    Title = '<font color="#00ff00">Was Made By Xeavz</font>',
    Desc = "Script Maker | UI Developer",
    Callback = function()
        WindUI:Notify({ Title = "Boost Hub", Content = "Thanks for using Boost Hub by Xeavz!", Duration = 3 })
    end,
})

SettingsTab:Section({ Title = "Community & Links" })

local DiscordInvite = "https://discord.gg/v2BxRgTEP"
local ScriptBloxLink = "https://scriptblox.com/u/guyy"

SettingsTab:Button({
    Title = "Join Discord Server",
    Desc = "Copy Discord server link to clipboard",
    Callback = function()
        if setclipboard then
            setclipboard(DiscordInvite)
            WindUI:Notify({ Title = "Discord Link", Content = "Discord invite copied to clipboard!", Duration = 3 })
        else
            WindUI:Notify({ Title = "Error", Content = "Failed to copy link.", Duration = 3 })
        end
    end,
})

SettingsTab:Button({
    Title = "ScriptBlox Channel Link",
    Desc = "Copy ScriptBlox channel link to clipboard",
    Callback = function()
        if setclipboard then
            setclipboard(ScriptBloxLink)
            WindUI:Notify({ Title = "ScriptBlox Link", Content = "ScriptBlox link copied to clipboard!", Duration = 3 })
        else
            WindUI:Notify({ Title = "Error", Content = "Failed to copy link.", Duration = 3 })
        end
    end,
})

SettingsTab:Section({ Title = "Keybinds" })

SettingsTab:Keybind({
    Title = "Toggle Key UI",
    Value = Enum.KeyCode.RightControl,
    Callback = function(key)
        Window:ToggleKey(key)
    end,
})

-- Send Loaded Toast Notification
WindUI:Notify({
    Title = "Boost Hub Loaded",
    Content = "Welcome to Boost Hub!",
    Duration = 4,
})
