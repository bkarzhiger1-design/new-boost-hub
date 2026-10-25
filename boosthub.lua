-- =================================================================
--                     BOOST HUB - WIND UI TEMPLATE
-- =================================================================

-- 1. SAFE LOAD WIND UI LIBRARY
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    warn("Failed to load WindUI! Check your executor or internet connection.")
    return
end

-- Global Config Storage Table (For Saving / Loading Settings)
getgenv().BoostHubConfig = getgenv().BoostHubConfig or {
    AutoCatClick = false,
    AutoRNG = false,
    AutoGoal = false,
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

-- Auto Chat Spammer Messages List
local autoChatMessages = {
    "Every robux is appreciated!",
    "Thank for your donations! Goal is 5k",
    "Any given amount will be appreciated!",
    "My goal is to reach 5k and buy a new avatar!",
    "Currently afk. Any given amount will be appreciated!"
}

-- 2. CREATE MAIN WINDOW WITH SEARCH BAR AND USER PROFILE WIDGET
local Window = WindUI:CreateWindow({
    Title = "Boost Hub",
    SubTitle = "v1.0.0 | made by xeavz",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
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
        Key = "KEY_383783828299263", 
        Note = "Get your key from Linkvertise below!",
        URL = "https://link-target.net/10198436/EQPCQ263XIi1", 
        SaveKey = true,
    }
})

-- 3. CREATE TABS
local MainTab = Window:Tab({ Title = "Main", Icon = "house" })
local FarmTab = Window:Tab({ Title = "Farm", Icon = "zap" })
local AutomationTab = Window:Tab({ Title = "Automation", Icon = "bot" })
local HopTab = Window:Tab({ Title = "Hop", Icon = "refresh-cw" })
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local VisualTab = Window:Tab({ Title = "Visual", Icon = "eye" })
local ConfigureTab = Window:Tab({ Title = "Configure", Icon = "palette" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- Helper Services for Server Hopping
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

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
MainTab:Section({ Title = "Player Stats" })

-- WalkSpeed Slider
MainTab:Slider({
    Title = "Walk Speed",
    Value = { Min = 16, Max = 300, Default = 16 },
    Callback = function(speed)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = speed
        end
        if speed > 16 then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 3 })
        end
    end,
})

-- JumpPower Slider
MainTab:Slider({
    Title = "Jump Power",
    Value = { Min = 50, Max = 400, Default = 50 },
    Callback = function(power)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.UseJumpPower = true
            char.Humanoid.JumpPower = power
        end
        if power > 50 then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 3 })
        end
    end,
})

MainTab:Section({ Title = "Performance Settings" })

-- Disable 3D Render Toggle
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

-- Universal Fly Toggle (PC & Mobile Compatible)
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
        if state then
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

-- Infinite Jump Toggle
local infiniteJump = false
MainTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump continuously in mid-air",
    Value = false,
    Callback = function(state)
        infiniteJump = state
        if state then
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

-- Noclip Toggle
local noclip = false
MainTab:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls and obstacles",
    Value = false,
    Callback = function(state)
        noclip = state
        if state then
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

-- Anchor Character Toggle
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

-- Invisible Toggle
local invisSavedTransparencies = {}
MainTab:Toggle({
    Title = "Invisible",
    Desc = "Makes your character completely invisible",
    Value = false,
    Callback = function(state)
        local char = game.Players.LocalPlayer.Character
        if not char then return end

        if state then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 3 })
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

-- Anti AFK
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

-- Anti Fling
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

-- Teleport To Player
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

        WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })

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

-- Adjust Delay Of Click (100 ms to 10000 ms)
FarmTab:Slider({
    Title = "Adjust Delay Of Click (Ms)",
    Value = { Min = 100, Max = 10000, Default = getgenv().BoostHubConfig.CatClickDelay },
    Callback = function(ms)
        getgenv().CatClickDelay = ms / 1000
        getgenv().BoostHubConfig.CatClickDelay = ms
    end,
})

-- Adjust Delay For Auto RNG (5 Seconds to 50 Seconds)
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

-- Auto Cat Click Toggle
FarmTab:Toggle({
    Title = "Auto Cat Click",
    Desc = "Automatically searches and clicks targets using ClickDetector scanner",
    Value = getgenv().BoostHubConfig.AutoCatClick,
    Callback = function(state)
        getgenv().AutoCatClick = state
        getgenv().BoostHubConfig.AutoCatClick = state
        if state then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
            local tgt = acharGato()
            if tgt then
                WindUI:Notify({ Title = "Auto Cat Click", Content = "Status: Metralhando com sucesso! 🔥", Duration = 3 })
                task.spawn(loop, tgt)
                task.spawn(loop, tgt)
            else
                WindUI:Notify({ Title = "Auto Cat Click", Content = "Status: Gato não encontrado.", Duration = 3 })
                getgenv().AutoCatClick = false
            end
        else
            gato = nil
        end
    end,
})

-- Auto RNG Toggle
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
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
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

-- Auto Goal Toggle
FarmTab:Toggle({
    Title = "Auto Goal",
    Desc = "Gently pushes SoccerBall strictly in one straight direction towards the goal",
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
        if state then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
            task.spawn(function()
                while getgenv().AutoGoal do
                    local soccerBall = workspace:FindFirstChild("SoccerBall", true)
                    local char = game.Players.LocalPlayer.Character
                    
                    if soccerBall and char and char:FindFirstChild("HumanoidRootPart") then
                        local ballPart = soccerBall:IsA("BasePart") and soccerBall or soccerBall:FindFirstChildWhichIsA("BasePart", true)
                        if ballPart then
                            char.HumanoidRootPart.CFrame = ballPart.CFrame + Vector3.new(0, 2, -3)
                            if ballPart:IsA("BasePart") then
                                ballPart.AssemblyLinearVelocity = Vector3.new(0, 5, 35)
                            end
                        end
                    end
                    
                    local waitTime = 1.2
                    if getgenv().AntiBanEnabled then
                        waitTime = waitTime + (math.random(1, 5) / 10)
                    end
                    task.wait(waitTime)
                end
            end)
            WindUI:Notify({ Title = "Auto Goal", Content = "Auto Goal linear pusher activated!", Duration = 3 })
        end
    end,
})

-- =============================================================
--                     3. AUTOMATION TAB
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

AutomationTab:Button({
    Title = "Auto Claim Stand",
    Desc = "Teleports to nearest unclaimed Stand, claims it, and teleports back",
    Callback = function()
        WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
        
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        local hrp = char.HumanoidRootPart
        local originalCFrame = hrp.CFrame

        local searchContainer = workspace:FindFirstChild("Stands") or workspace
        local nearestStandPrompt = nil
        local shortestDist = math.huge

        for _, obj in pairs(searchContainer:GetDescendants()) do
            if obj.Name == "Stand" or (obj.Parent and obj.Parent.Name == "Stand") then
                local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                    if targetPart then
                        local dist = (hrp.Position - targetPart.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            nearestStandPrompt = prompt
                        end
                    end
                end
            end
        end

        if nearestStandPrompt then
            local targetObj = nearestStandPrompt.Parent
            if targetObj:IsA("BasePart") then
                hrp.CFrame = targetObj.CFrame + Vector3.new(0, 3, 0)
            elseif targetObj:IsA("Model") then
                hrp.CFrame = targetObj:GetPivot() + Vector3.new(0, 3, 0)
            end

            task.wait(0.3)
            if fireproximityprompt then
                fireproximityprompt(nearestStandPrompt)
            end

            task.wait(0.5)
            hrp.CFrame = originalCFrame
            WindUI:Notify({ Title = "Auto Claim Stand", Content = "Successfully claimed Stand and returned!", Duration = 3 })
        else
            WindUI:Notify({ Title = "Auto Claim Stand", Content = "No unclaimed Stand found!", Duration = 3 })
        end
    end,
})

AutomationTab:Button({
    Title = "Auto Beg",
    Desc = "Teleports to SpawnLocation and equips begging tool",
    Callback = function()
        WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })

        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end

        local spawnLoc = workspace:FindFirstChild("SpawnLocation", true)
        if spawnLoc then
            if spawnLoc:IsA("Model") then
                char.HumanoidRootPart.CFrame = spawnLoc:GetPivot() + Vector3.new(0, 3, 0)
            elseif spawnLoc:IsA("BasePart") then
                char.HumanoidRootPart.CFrame = spawnLoc.CFrame + Vector3.new(0, 3, 0)
            end
        end

        local toolToEquip = nil
        if player:FindFirstChild("Backpack") then
            for _, item in pairs(player.Backpack:GetChildren()) do
                if item:IsA("Tool") then
                    toolToEquip = item
                    break
                end
            end
        end

        if not toolToEquip then
            for _, item in pairs(char:GetChildren()) do
                if item:IsA("Tool") then
                    toolToEquip = item
                    break
                end
            end
        end

        if toolToEquip then
            if toolToEquip.Parent == player.Backpack then
                char.Humanoid:EquipTool(toolToEquip)
            end
            WindUI:Notify({ Title = "Auto Beg", Content = "Successfully started Auto Begging.", Duration = 4 })
        else
            WindUI:Notify({ Title = "Auto Beg", Content = "Buy a sign in a shop first!", Duration = 4 })
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
        if state then
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

AutomationTab:Toggle({
    Title = "Auto Chat Spammer",
    Desc = "Sends a random begging message in game chat every 15 seconds",
    Value = getgenv().BoostHubConfig.AutoChatSpam,
    Callback = function(state)
        getgenv().AutoChatSpam = state
        getgenv().BoostHubConfig.AutoChatSpam = state
        if state then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
            task.spawn(function()
                while getgenv().AutoChatSpam do
                    local randomIndex = math.random(1, #autoChatMessages)
                    local selectedMsg = autoChatMessages[randomIndex]
                    SendChatMessage(selectedMsg)
                    
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
--                        4. HOP TAB
-- =============================================================
HopTab:Section({ Title = "Server Hopping Tasks" })

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
--                        5. TELEPORT TAB
-- =============================================================
TeleportTab:Section({ Title = "Location Teleports" })

local function TeleportToTarget(targetObj, displayName)
    WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
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

-- Teleport To RNG Button
TeleportTab:Button({
    Title = "Teleport To RNG",
    Desc = "Teleports directly to RNGButton",
    Callback = function()
        TeleportToTarget(workspace:FindFirstChild("RNGButton", true), "RNGButton")
    end,
})

-- Teleport To SoccerBall Button
TeleportTab:Button({
    Title = "Teleport To SoccerBall",
    Desc = "Teleports directly to SoccerBall",
    Callback = function()
        TeleportToTarget(workspace:FindFirstChild("SoccerBall", true), "SoccerBall")
    end,
})

-- =============================================================
--                      6. VISUAL TAB
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
--                    7. CONFIGURE TAB
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

ConfigureTab:Section({ Title = "Server Leaderboard Stats" })

ConfigureTab:Button({
    Title = "Who Is The Richest On Server?",
    Desc = "Scans server leaderboard stats to find the player with the highest raised stats",
    Callback = function()
        local richestPlayerName = nil
        local highestScore = -1

        for _, plr in pairs(game.Players:GetPlayers()) do
            local leaderstats = plr:FindFirstChild("leaderstats")
            if leaderstats then
                for _, stat in pairs(leaderstats:GetChildren()) do
                    local statName = string.lower(stat.Name)
                    if statName:find("raised") or statName:find("donated") or statName:find("robux") then
                        if stat:IsA("NumberValue") or stat:IsA("IntValue") then
                            if stat.Value > highestScore then
                                highestScore = stat.Value
                                richestPlayerName = plr.DisplayName .. " (@" .. plr.Name .. ")"
                            end
                        end
                    end
                end
            end
        end

        if richestPlayerName then
            WindUI:Notify({ 
                Title = "Richest Player Found!", 
                Content = string.format("🏆 Richest: %s (Raised: %d)", richestPlayerName, highestScore), 
                Duration = 6 
            })
        else
            WindUI:Notify({ 
                Title = "Richest Player", 
                Content = "Could not find any 'Raised' leaderstats values in this server.", 
                Duration = 5 
            })
        end
    end,
})

ConfigureTab:Section({ Title = "UI Theme Settings" })

ConfigureTab:Dropdown({
    Title = "UI Theme",
    Desc = "Select your preferred WindUI color theme",
    Values = { "Dark", "DarkRed", "Light", "Rose", "Aqua", "Amethyst", "Emerald", "Midnight" },
    Default = "Dark",
    Callback = function(selectedTheme)
        if WindUI and WindUI.SetTheme then
            WindUI:SetTheme(selectedTheme)
            WindUI:Notify({ Title = "Theme Changed", Content = "UI theme updated to " .. selectedTheme, Duration = 3 })
        end
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
--                      8. SETTINGS TAB
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

SettingsTab:Section({ Title = "Support Developer" })

SettingsTab:Button({
    Title = "Donate 5 Robux",
    Desc = "Opens donation purchase prompt",
    Callback = function()
        local DeveloperGamepassID = 00000000
        game:GetService("MarketplaceService"):PromptGamePassPurchase(game.Players.LocalPlayer, DeveloperGamepassID)
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
