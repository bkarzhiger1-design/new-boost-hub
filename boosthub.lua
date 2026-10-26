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

-- Global Config Storage Table
getgenv().BoostHubConfig = getgenv().BoostHubConfig or {
    AutoCatClick = false,
    AutoRNG = false,
    AutoGoal = false,
    AutoCollectOrbs = false,
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

-- Text Generator & Audio Variables
local textGenText, textGenFont, textGenColor, textGenStrokeColor, textGenThickness = "testing", "FredokaOne", "#ff0000", "#000000", 1
local customAudioId, activeCustomSound, originalVolumes, morphTargetName = "", nil, {}, ""

local autoChatMessages = {
    "Every robux is appreciated!",
    "Thank for your donations! Goal is 5k",
    "Any given amount will be appreciated!",
    "My goal is to reach 5k and buy a new avatar!",
    "Currently afk. Any given amount will be appreciated!"
}

-- 2. CREATE MAIN WINDOW (WITH WINDUI CONFIG MANAGER & DUAL-KEY SUPPORT)
local Window = WindUI:CreateWindow({
    Title = "Boost Hub",
    SubTitle = "v1.0.0 | made by xeavz",
    Folder = "BoostHubData", -- Enables WindUI Built-In Config Manager
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 520),
    Theme = "Dark",
    Transparent = true,
    HideSearchBar = false,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            WindUI:Notify({ Title = "Profile", Content = "Logged in as " .. game.Players.LocalPlayer.DisplayName, Duration = 3 })
        end,
    },
    KeySystem = {
        Key = { "KEY_383783828299263", "KEY_PREMIUM_ONLY_12982" }, 
        Note = "Get your key from Linkvertise or use testing keys!",
        URL = "https://link-target.net/10198436/EQPCQ263XIi1", 
        SaveKey = true,
    }
})

-- Initialize Config Manager
local ConfigManager = Window.ConfigManager

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

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local function TryTeleportToPlayer(username, roleName)
    local targetUserId
    pcall(function() targetUserId = Players:GetUserIdFromNameAsync(username) end)
    if not targetUserId then return false end

    local isPlaying, currentInstErr, placeId, jobId
    pcall(function() isPlaying, currentInstErr, placeId, jobId = TeleportService:GetPlayerPlaceInstanceAsync(targetUserId) end)

    if placeId and jobId then
        WindUI:Notify({ Title = roleName, Content = "Found " .. username .. "! Teleporting...", Duration = 3 })
        TeleportService:TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
        return true
    end
    return false
end

local function SendChatMessage(msg)
    local TextChatService = game:GetService("TextChatService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local generalChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if generalChannel then generalChannel:SendAsync(msg) end
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
            Content = "[-] Built-in WindUI Config Manager added to Configure Tab\n[-] Auto Execute / Rejoin script hook fixed\n[-] Renamed Auto Claim Stand to Claim Stand",
            Duration = 8
        })
    end,
})

MainTab:Section({ Title = "Player Stats" })
MainTab:Slider({
    Title = "Walk Speed", Value = { Min = 16, Max = 300, Default = 16 },
    Callback = function(speed)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = speed end
        if speed > 16 and not getgenv().AntiBanEnabled then WindUI:Notify({ Title = "Ban Warning", Content = "Warning! High speed can trigger anti-cheat", Duration = 3 }) end
    end,
})

MainTab:Slider({
    Title = "Jump Power", Value = { Min = 50, Max = 400, Default = 50 },
    Callback = function(power)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.UseJumpPower = true
            char.Humanoid.JumpPower = power
        end
        if power > 50 and not getgenv().AntiBanEnabled then WindUI:Notify({ Title = "Ban Warning", Content = "Warning! High jump can trigger anti-cheat", Duration = 3 }) end
    end,
})

MainTab:Section({ Title = "Performance Settings" })
MainTab:Toggle({
    Title = "Disable 3D Render", Desc = "Pauses 3D rendering completely for max performance/FPS while AFK", Value = false,
    Callback = function(state)
        local runService = game:GetService("RunService")
        if runService.Set3dRenderingEnabled then runService:Set3dRenderingEnabled(not state) end
    end,
})

MainTab:Section({ Title = "Movement Abilities" })
local flying, flySpeed, bodyVel, bodyGyro, flyConnection = false, 50, nil, nil, nil
MainTab:Toggle({
    Title = "Fly", Desc = "Allows floating and flying freely", Value = false,
    Callback = function(state)
        flying = state
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp, humanoid = char.HumanoidRootPart, char.Humanoid

        if flying then
            bodyVel = Instance.new("BodyVelocity", hrp)
            bodyVel.MaxForce, bodyVel.Velocity = Vector3.new(1e9, 1e9, 1e9), Vector3.zero
            bodyGyro = Instance.new("BodyGyro", hrp)
            bodyGyro.MaxTorque, bodyGyro.CFrame = Vector3.new(1e9, 1e9, 1e9), hrp.CFrame
            humanoid.PlatformStand = true

            flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
                if not flying then if flyConnection then flyConnection:Disconnect() end return end
                local cam = workspace.CurrentCamera
                local moveDir = Vector3.zero
                local uis = game:GetService("UserInputService")
                if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                bodyVel.Velocity = moveDir * flySpeed
                bodyGyro.CFrame = cam.CFrame
            end)
        else
            if flyConnection then flyConnection:Disconnect() end
            if bodyVel then bodyVel:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            if humanoid then humanoid.PlatformStand = false end
        end
    end,
})

local infiniteJump = false
MainTab:Toggle({ Title = "Infinite Jump", Desc = "Jump continuously in mid-air", Value = false, Callback = function(s) infiniteJump = s end })
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJump then
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local noclip = false
MainTab:Toggle({ Title = "Noclip", Desc = "Walk through walls and obstacles", Value = false, Callback = function(s) noclip = s end })
game:GetService("RunService").Stepped:Connect(function()
    if noclip then
        local char = game.Players.LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)

MainTab:Toggle({
    Title = "Anchor Character", Value = false,
    Callback = function(s)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.Anchored = s end
    end
})

local invisSavedTransparencies = {}
MainTab:Toggle({
    Title = "Invisible", Value = false,
    Callback = function(state)
        local char = game.Players.LocalPlayer.Character
        if not char then return end
        if state then
            invisSavedTransparencies = {}
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Decal") then
                    invisSavedTransparencies[v] = v.Transparency
                    v.Transparency = 1
                end
            end
        else
            for v, trans in pairs(invisSavedTransparencies) do
                if v and v.Parent then v.Transparency = trans end
            end
            invisSavedTransparencies = {}
        end
    end
})

MainTab:Section({ Title = "Protection & Player Tools" })
local antiAfkConnection
MainTab:Toggle({
    Title = "Anti AFK", Value = true,
    Callback = function(s)
        getgenv().AntiAfk = s
        if s then
            local VirtualUser = game:GetService("VirtualUser")
            antiAfkConnection = game.Players.LocalPlayer.Idled:Connect(function()
                if getgenv().AntiAfk then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end
            end)
        else
            if antiAfkConnection then antiAfkConnection:Disconnect() end
        end
    end
})

local antiFlingConnection
MainTab:Toggle({
    Title = "Anti Fling", Value = false,
    Callback = function(s)
        getgenv().AntiFling = s
        if s then
            antiFlingConnection = game:GetService("RunService").Stepped:Connect(function()
                if not getgenv().AntiFling then return end
                for _, player in pairs(game.Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer and player.Character then
                        for _, part in pairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end
                end
            end)
        else
            if antiFlingConnection then antiFlingConnection:Disconnect() end
        end
    end
})

local targetPlayerName = ""
MainTab:Input({ Title = "Target Player", Placeholder = "Player Name...", Callback = function(text) targetPlayerName = text end })
MainTab:Button({
    Title = "Teleport To Player",
    Callback = function()
        if targetPlayerName == "" then return end
        local targetPlayer
        for _, p in pairs(game.Players:GetPlayers()) do
            if string.find(string.lower(p.Name), string.lower(targetPlayerName)) or string.find(string.lower(p.DisplayName), string.lower(targetPlayerName)) then
                targetPlayer = p
                break
            end
        end
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myChar = game.Players.LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                myChar.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
})

-- =============================================================
--                        2. FARM TAB
-- =============================================================
FarmTab:Section({ Title = "Automation Delays" })
FarmTab:Slider({ Title = "Adjust Delay Of Click (Ms)", Value = { Min = 100, Max = 10000, Default = getgenv().BoostHubConfig.CatClickDelay }, Callback = function(ms) getgenv().CatClickDelay = ms / 1000 end })
FarmTab:Slider({ Title = "Adjust Delay For Auto RNG (Sec)", Value = { Min = 5, Max = 50, Default = getgenv().BoostHubConfig.RNGDelay }, Callback = function(sec) getgenv().RNGDelay = sec end })

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
        if #cx > 0 then for _, c in pairs(cx) do c:Fire() end else fireclickdetector(alvo) end
        local delayVal = getgenv().CatClickDelay or 0.1
        if getgenv().AntiBanEnabled then delayVal = delayVal + math.random(1, 10) / 100 end
        task.wait(delayVal)
    end
end

FarmTab:Toggle({
    Title = "Auto Cat Click", Value = getgenv().BoostHubConfig.AutoCatClick,
    Callback = function(state)
        getgenv().AutoCatClick = state
        if state then
            local tgt = acharGato()
            if tgt then
                WindUI:Notify({ Title = "Auto Cat Click", Content = "Status: Successfully clicking! 🔥", Duration = 3 })
                task.spawn(loop, tgt)
            else
                WindUI:Notify({ Title = "Auto Cat Click", Content = "Status: Cat target not found.", Duration = 3 })
                getgenv().AutoCatClick = false
            end
        else gato = nil end
    end
})

FarmTab:Toggle({
    Title = "Auto RNG", Value = getgenv().BoostHubConfig.AutoRNG,
    Callback = function(state)
        getgenv().AutoRNG = state
        if state then
            task.spawn(function()
                while getgenv().AutoRNG do
                    local rngPart = workspace:FindFirstChild("RNGButton", true)
                    local char = game.Players.LocalPlayer.Character
                    if rngPart and char and char:FindFirstChild("HumanoidRootPart") then
                        if rngPart:IsA("Model") then char.HumanoidRootPart.CFrame = rngPart:GetPivot() + Vector3.new(0, 3, 0)
                        elseif rngPart:IsA("BasePart") then char.HumanoidRootPart.CFrame = rngPart.CFrame + Vector3.new(0, 3, 0) end
                    end
                    task.wait(getgenv().RNGDelay or 15)
                end
            end)
        end
    end
})

FarmTab:Toggle({
    Title = "Auto Goal", Value = getgenv().BoostHubConfig.AutoGoal,
    Callback = function(state)
        getgenv().AutoGoal = state
        local char = game.Players.LocalPlayer.Character
        if not state then
            if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.Anchored = false end
            return
        end
        task.spawn(function()
            while getgenv().AutoGoal do
                local currentChar = game.Players.LocalPlayer.Character
                local soccerBall = workspace:FindFirstChild("SoccerBall", true)
                if soccerBall and currentChar and currentChar:FindFirstChild("HumanoidRootPart") then
                    local hrp = currentChar.HumanoidRootPart
                    local ballPart = soccerBall:IsA("BasePart") and soccerBall or soccerBall:FindFirstChildWhichIsA("BasePart", true)
                    if ballPart then
                        hrp.Anchored = true
                        hrp.CFrame = ballPart.CFrame + Vector3.new(0, 2, -3)
                        if ballPart:IsA("BasePart") then ballPart.AssemblyLinearVelocity = Vector3.new(0, 5, 35) end
                    end
                end
                task.wait(1.2)
            end
            local finalChar = game.Players.LocalPlayer.Character
            if finalChar and finalChar:FindFirstChild("HumanoidRootPart") then finalChar.HumanoidRootPart.Anchored = false end
        end)
    end
})

-- =============================================================
--                        3. EVENTS TAB
-- =============================================================
EventsTab:Section({ Title = "Special Events" })
EventsTab:Toggle({
    Title = "Auto Collect Orbs [NEW]", Value = getgenv().BoostHubConfig.AutoCollectOrbs,
    Callback = function(state)
        getgenv().AutoCollectOrbs = state
        if state then
            task.spawn(function()
                while getgenv().AutoCollectOrbs do
                    local char = game.Players.LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local orb = workspace:FindFirstChild("DiscoOrb", true)
                    if orb and hrp then
                        if orb:IsA("Model") then hrp.CFrame = orb:GetPivot() + Vector3.new(0, 3, 0)
                        elseif orb:IsA("BasePart") then hrp.CFrame = orb.CFrame + Vector3.new(0, 3, 0) end
                    else
                        WindUI:Notify({ Title = "Auto Collect Orbs", Content = "No more orbs found! Stopped.", Duration = 4 })
                        getgenv().AutoCollectOrbs = false
                        break
                    end
                    task.wait(0.3)
                end
            end)
        end
    end
})

-- =============================================================
--                        4. CLIENT TAB
-- =============================================================
ClientTab:Section({ Title = "Custom Audio Player" })
ClientTab:Input({ Title = "Audio ID", Placeholder = "18483545", Callback = function(t) customAudioId = t end })
ClientTab:Button({
    Title = "Play Custom Audio",
    Callback = function()
        if customAudioId == "" then return end
        if activeCustomSound then activeCustomSound:Stop() activeCustomSound:Destroy() end
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. customAudioId
        sound.Volume, sound.Looped, sound.Parent = 1, true, game:GetService("SoundService")
        sound:Play()
        activeCustomSound = sound
    end
})

ClientTab:Section({ Title = "Client-Side Morph" })
ClientTab:Input({ Title = "Target Username", Placeholder = "Username...", Callback = function(t) morphTargetName = t end })

-- =============================================================
--                     5. AUTOMATION TAB
-- =============================================================
AutomationTab:Section({ Title = "Anti-Ban Protection" })
AutomationTab:Toggle({
    Title = "Anti-Ban Safe Mode", Value = getgenv().BoostHubConfig.AntiBanEnabled,
    Callback = function(s) getgenv().AntiBanEnabled = s end
})

AutomationTab:Section({ Title = "Stand & Begging Tasks" })
AutomationTab:Button({
    Title = "Claim Stand",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local hrp = char.HumanoidRootPart
        local originalCFrame = hrp.CFrame
        local prompts = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then table.insert(prompts, obj) end
        end
        if #prompts == 0 then return end
        for _, prompt in ipairs(prompts) do
            local targetPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
                if fireproximityprompt then fireproximityprompt(prompt) end
                task.wait(2)
                break
            end
        end
        hrp.CFrame = originalCFrame
    end
})

AutomationTab:Section({ Title = "Custom Auto Spam Messages" })
for i = 1, 5 do
    AutomationTab:Input({
        Title = "Spam Message " .. i, Placeholder = "Enter message...", Value = autoChatMessages[i],
        Callback = function(text) if text ~= "" then autoChatMessages[i] = text end end
    })
end

AutomationTab:Toggle({
    Title = "Auto Chat Spammer", Value = getgenv().BoostHubConfig.AutoChatSpam,
    Callback = function(state)
        getgenv().AutoChatSpam = state
        if state then
            task.spawn(function()
                while getgenv().AutoChatSpam do
                    local msg = autoChatMessages[math.random(1, #autoChatMessages)]
                    if msg and msg ~= "" then SendChatMessage(msg) end
                    task.wait(15)
                end
            end)
        end
    end
})

-- =============================================================
--                        6. HOP TAB
-- =============================================================
HopTab:Section({ Title = "Server Hopping Tasks" })
HopTab:Button({
    Title = "Normal Server Hop",
    Callback = function() TeleportService:Teleport(game.PlaceId, Players.LocalPlayer) end
})

-- =============================================================
--                        7. TELEPORT TAB
-- =============================================================
TeleportTab:Section({ Title = "Location Teleports" })

-- =============================================================
--                      8. VISUAL TAB
-- =============================================================
VisualTab:Section({ Title = "Performance & Graphics" })

-- =============================================================
--                    9. CONFIGURE TAB (FIXED CONFIG & REJOIN)
-- =============================================================
ConfigureTab:Section({ Title = "Configuration Manager" })

-- Renders the official WindUI Configuration Manager (Dropdown, Save, Load, Delete, Auto-Load)
if ConfigManager then
    ConfigManager:BuildConfigSection(ConfigureTab)
end

ConfigureTab:Section({ Title = "Auto Rejoin & Execute Settings" })

local autoExecuteScriptURL = "https://raw.githubusercontent.com/YourUsername/YourRepo/main/script.lua" -- Put your loadstring URL here

ConfigureTab:Toggle({
    Title = "Auto Re-Execute on Rejoin / Hop",
    Desc = "Automatically queues Boost Hub script execution whenever you switch servers or rejoin",
    Value = getgenv().BoostHubConfig.AutoExecuteEnabled,
    Callback = function(state)
        getgenv().BoostHubConfig.AutoExecuteEnabled = state
        local queueFunction = queue_on_teleport or (syn and syn.queue_on_teleport)
        if state and queueFunction then
            queueFunction([[
                task.wait(2)
                loadstring(game:HttpGet("]] .. autoExecuteScriptURL .. [["))()
            ]])
            WindUI:Notify({ Title = "Auto Re-Execute", Content = "Queue set for next teleport/rejoin!", Duration = 3 })
        end
    end,
})

ConfigureTab:Section({ Title = "UI Appearance" })
ConfigureTab:Dropdown({
    Title = "UI Theme", Values = { "Dark", "Light", "Rose", "Emerald", "Midnight", "Red", "Aquamarine", "Amethyst" }, Default = "Dark",
    Callback = function(selectedTheme) Window:SetTheme(selectedTheme) end
})

-- =============================================================
--                        10. OTHER TAB
-- =============================================================
OtherTab:Section({ Title = "External Hubs & Scripts" })
OtherTab:Button({
    Title = "Prixy Hub",
    Callback = function() loadstring(game:HttpGet("https://scriptblox.com/raw/FIXED-DONATIONS-PLS-WAIT-Prixy-Hub-auto-Cat-237080"))() end
})

-- =============================================================
--                      11. SETTINGS TAB
-- =============================================================
SettingsTab:Section({ Title = "Developer Info" })
SettingsTab:Button({ Title = '<font color="#00ff00">Was Made By Xeavz</font>' })

WindUI:Notify({ Title = "Boost Hub Loaded", Content = "Welcome to Boost Hub!", Duration = 4 })
