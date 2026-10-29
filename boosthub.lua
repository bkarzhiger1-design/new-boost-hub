-- =============================================================
--                     BOOST HUB - WIND UI TEMPLATE
-- =============================================================

-- SAFE LOAD WIND UI LIBRARY
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    local gui = Instance.new("ScreenGui", game.CoreGui)
    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(1, 0, 0, 50)
    label.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 18
    label.Text = "ERROR: Your executor cannot load WindUI! Try a different executor."
    task.wait(10)
    gui:Destroy()
    return
end

-- GAME CHECK VERIFICATION
local TARGET_PLACE_ID = 12069083555
if game.PlaceId ~= TARGET_PLACE_ID then
    WindUI:Notify({
        Title = "Wrong Game!",
        Content = "Wrong Game! Are you sure that you are playing PLS WAIT?",
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
    AutoClaimStand = false,
    AntiBanEnabled = true,
    AutoChatSpam = false,
    Disable3DRender = false,
    WalkSpeed = 16,
    JumpPower = 50,
    CatClickDelay = 100,
    RNGDelay = 15,
    AutoExecuteEnabled = false
}

-- Global Delay Settings (In Seconds)
getgenv().CatClickDelay = getgenv().BoostHubConfig.CatClickDelay / 1000
getgenv().RNGDelay = getgenv().BoostHubConfig.RNGDelay
getgenv().AntiBanEnabled = getgenv().BoostHubConfig.AntiBanEnabled

-- Text Generator State Variables
local textGenText = "Type Something Here"
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

-- Auto Beg Custom Greeting & Toggle State
local autoBegSayEnabled = true
local autoBegMessageTemplate = "Hello %s, would you like to donate me? Any donation is highly appreciated :D"

-- Configuration System Variables
local configInputName = "DefaultConfig"
local selectedConfigDropdown = "DefaultConfig"
local autoLoadConfigName = ""

-- Helper Services
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- ADMIN / STAFF WATCHLIST & AUTO HOP PROTECTION SYSTEM
local adminList = { "valchuuz", "angel019999", "bvetterdays", "HayyanPro167", "HayyanProRBX" }

local function checkAndHopForAdmins(player)
    if player == Players.LocalPlayer then return end
    for _, adminName in ipairs(adminList) do
        if string.lower(player.Name) == string.lower(adminName) or string.lower(player.DisplayName) == string.lower(adminName) then
            WindUI:Notify({
                Title = "Admin Detected!",
                Content = "Admins joined the server. We hopped/kicked you from this server so they can't ban you",
                Duration = 10
            })
            task.wait(1.5)
            
            local placeId = game.PlaceId
            local servers = {}
            local req = (syn and syn.request) or (http and http.request) or http_request or request
            if req then
                local success, raw = pcall(function()
                    return req({ Url = string.format("https://games.roblox.com/v1/games/%d/servers/0?sortOrder=Desc&limit=100", placeId) })
                end)
                if success and raw and raw.Body then
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
            return true
        end
    end
    return false
end

for _, p in ipairs(Players:GetPlayers()) do
    checkAndHopForAdmins(p)
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        checkAndHopForAdmins(p)
    end)
    checkAndHopForAdmins(p)
end)

-- FORWARD DECLARATIONS FOR UI CALLBACKS & HANDLERS
local updateTogglesAndSettings
local applyAutoCatClick, applyAutoRNG, applyAutoGoal, applyAutoCollectOrbs, applyAutoClaimStand, applyAutoBeg, applyAutoChatSpam, applyDisable3DRender

-- CONFIGURATION SYSTEM FUNCTIONS
local function getSavedConfigsList()
    local list = { "DefaultConfig" }
    pcall(function()
        if makefolder then
            pcall(function() makefolder("BoostHubConfigs") end)
        end
        if listfiles then
            local files = listfiles("BoostHubConfigs")
            for _, file in ipairs(files) do
                local name = file:match("([^/]+)$")
                if name then
                    name = name:match("([^\]+)$") or name
                    if name and name:sub(-5) == ".json" then
                        local configName = name:sub(1, -6)
                        table.insert(list, configName)
                    end
                end
            end
        end
    end)
    return list
end

local function saveConfiguration(configName)
    if not writefile then
        WindUI:Notify({ Title = "Error", Content = "Your executor does not support writefile!", Duration = 5 })
        return
    end
    local success, err = pcall(function()
        if makefolder then
            pcall(function() makefolder("BoostHubConfigs") end)
        end
        local configData = {
            AutoCatClick = getgenv().BoostHubConfig.AutoCatClick,
            AutoRNG = getgenv().BoostHubConfig.AutoRNG,
            AutoGoal = getgenv().BoostHubConfig.AutoGoal,
            AutoCollectOrbs = getgenv().BoostHubConfig.AutoCollectOrbs,
            AutoBeg = getgenv().BoostHubConfig.AutoBeg,
            AutoClaimStand = getgenv().BoostHubConfig.AutoClaimStand,
            AntiBanEnabled = getgenv().AntiBanEnabled,
            AutoChatSpam = getgenv().BoostHubConfig.AutoChatSpam,
            Disable3DRender = getgenv().BoostHubConfig.Disable3DRender,
            WalkSpeed = getgenv().BoostHubConfig.WalkSpeed,
            JumpPower = getgenv().BoostHubConfig.JumpPower,
            CatClickDelay = getgenv().BoostHubConfig.CatClickDelay,
            RNGDelay = getgenv().BoostHubConfig.RNGDelay,
            AutoBegSay = autoBegSayEnabled,
            AutoBegMessage = autoBegMessageTemplate,
            AutoExecuteEnabled = getgenv().BoostHubConfig.AutoExecuteEnabled
        }
        local encoded = HttpService:JSONEncode(configData)
        writefile("BoostHubConfigs/" .. configName .. ".json", encoded)
    end)

    if success then
        WindUI:Notify({ Title = "Configuration Saved", Content = "Successfully saved configuration: " .. configName, Duration = 3 })
    else
        WindUI:Notify({ Title = "Save Error", Content = tostring(err), Duration = 6 })
    end
end

local function loadConfiguration(configName)
    if not readfile then
        WindUI:Notify({ Title = "Error", Content = "Your executor does not support readfile!", Duration = 5 })
        return
    end
    local success, content = pcall(function()
        return readfile("BoostHubConfigs/" .. configName .. ".json")
    end)
    if success and content then
        local successDecode, data = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if successDecode and type(data) == "table" then
            applyAutoCatClick(data.AutoCatClick or false)
            applyAutoRNG(data.AutoRNG or false)
            applyAutoGoal(data.AutoGoal or false)
            applyAutoCollectOrbs(data.AutoCollectOrbs or false)
            applyAutoClaimStand(data.AutoClaimStand or false)
            applyAutoBeg(data.AutoBeg or false)
            applyAutoChatSpam(data.AutoChatSpam or false)
            applyDisable3DRender(data.Disable3DRender or false)

            getgenv().AntiBanEnabled = data.AntiBanEnabled ~= false
            getgenv().BoostHubConfig.AntiBanEnabled = getgenv().AntiBanEnabled
            getgenv().BoostHubConfig.WalkSpeed = data.WalkSpeed or 16
            getgenv().BoostHubConfig.JumpPower = data.JumpPower or 50
            getgenv().BoostHubConfig.CatClickDelay = data.CatClickDelay or 100
            getgenv().CatClickDelay = getgenv().BoostHubConfig.CatClickDelay / 1000
            getgenv().BoostHubConfig.RNGDelay = data.RNGDelay or 15
            getgenv().RNGDelay = getgenv().BoostHubConfig.RNGDelay
            autoBegSayEnabled = data.AutoBegSay ~= false
            if data.AutoBegMessage then
                autoBegMessageTemplate = data.AutoBegMessage
            end
            getgenv().BoostHubConfig.AutoExecuteEnabled = data.AutoExecuteEnabled or false

            pcall(function()
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = getgenv().BoostHubConfig.WalkSpeed
                    char.Humanoid.UseJumpPower = true
                    char.Humanoid.JumpPower = getgenv().BoostHubConfig.JumpPower
                end
            end)
            
            if updateTogglesAndSettings then
                updateTogglesAndSettings()
            end

            WindUI:Notify({ Title = "Configuration Loaded", Content = "Loaded configuration: " .. configName, Duration = 3 })
        else
            WindUI:Notify({ Title = "Load Error", Content = "Failed to parse JSON configuration file.", Duration = 4 })
        end
    else
        WindUI:Notify({ Title = "Load Error", Content = "Config file '" .. configName .. "' not found!", Duration = 4 })
    end
end

pcall(function()
    if readfile then
        local success, autoName = pcall(function()
            return readfile("BoostHubConfigs/AutoLoadConfig.json")
        end)
        if success and autoName and autoName ~= "" then
            loadConfiguration(autoName)
        end
    end
end)

-- CREATE MAIN WINDOW
local Window = WindUI:CreateWindow({
    Title = "Boost Hub",
    SubTitle = "v1.0.0 | made by xeavz",
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
        Key = { "KEY_383783828299263" }, 
        Note = "Get your key from Work.Ink",
        URL = "https://work.ink/2Htv/f5f58eb7-e3fb-4304-95f2-9009d83ea701", 
        SaveKey = true,
    }
})

-- CREATE TABS
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

-- HELPER FUNCTION TO STRICTLY CHECK REAL PLAYER STANDS (EXCLUDING SHOPS)
local function HasClaimedStand()
    local localPlayer = Players.LocalPlayer
    local manualName = string.lower(localPlayer.DisplayName)

    for _, obj in pairs(workspace:GetDescendants()) do
        if not obj:IsDescendantOf(localPlayer.Character or instance) and 
           not obj:IsDescendantOf(game:GetService("CoreGui")) and 
           not obj:IsA("Tool") then

            if obj:IsA("TextLabel") or obj:IsA("TextBox") then
                local text = string.lower(obj.Text or "")
                if string.find(text, manualName) then
                    local parentName = string.lower(obj.Parent.Name)
                    local grandParentName = obj.Parent.Parent and string.lower(obj.Parent.Parent.Name) or ""
                    
                    if (string.find(parentName, "stand") or string.find(grandParentName, "stand") or string.find(text, "stand")) and
                       not string.find(parentName, "shop") and not string.find(grandParentName, "shop") then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function AttemptClaimStand()
    if HasClaimedStand() then
        return false
    end

    local player = Players.LocalPlayer
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end

    local hrp = char.HumanoidRootPart
    local originalCFrame = hrp.CFrame

    local emitters = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "baseemitter") or string.find(nameLower, "stand") then
                if not string.find(nameLower, "shop") then
                    table.insert(emitters, obj)
                end
            end
        end
    end

    if #emitters == 0 then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(char) then
                local nameLower = string.lower(obj.Name)
                if not string.find(nameLower, "shop") then
                    table.insert(emitters, obj)
                end
            end
        end
    end

    if #emitters == 0 then
        return false
    end

    for i = #emitters, 2, -1 do
        local j = math.random(1, i)
        emitters[i], emitters[j] = emitters[j], emitters[i]
    end

    local claimed = false
    for _, targetPart in ipairs(emitters) do
        if targetPart and targetPart.Parent then
            hrp.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
            task.wait(0.4)

            local prompt = nil
            for _, desc in pairs(targetPart.Parent:GetDescendants()) do
                if desc:IsA("ProximityPrompt") and desc.Enabled then
                    prompt = desc
                    break
                end
            end
            if not prompt then
                for _, desc in pairs(workspace:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Enabled then
                        local pPart = desc.Parent
                        if pPart and pPart:IsA("BasePart") and (pPart.Position - targetPart.Position).Magnitude < 15 then
                            prompt = desc
                            break
                        end
                    end
                end
            end

            if prompt then
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

                task.wait(1)
                if HasClaimedStand() then
                    claimed = true
                    break
                end
            end
        end
    end

    hrp.CFrame = originalCFrame
    return claimed
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
            Content = "[-] Added persistent begged players tracking so you never beg the same person twice\n[-] Added 40s automatic teleport fallback if pathfinding can't reach a player\n[-] Improved configuration saving/loading reliability on mobile executors",
            Duration = 8
        })
    end,
})

MainTab:Section({ Title = "Player Stats" })

local walkSpeedSlider = MainTab:Slider({
    Title = "Walk Speed",
    Value = { Min = 16, Max = 300, Default = getgenv().BoostHubConfig.WalkSpeed },
    Callback = function(speed)
        getgenv().BoostHubConfig.WalkSpeed = speed
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = speed
        end
        if speed > 16 and not getgenv().AntiBanEnabled then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 3 })
        end
    end,
})

local jumpPowerSlider = MainTab:Slider({
    Title = "Jump Power",
    Value = { Min = 50, Max = 400, Default = getgenv().BoostHubConfig.JumpPower },
    Callback = function(power)
        getgenv().BoostHubConfig.JumpPower = power
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

applyDisable3DRender = function(state)
    getgenv().BoostHubConfig.Disable3DRender = state
    local runService = game:GetService("RunService")
    if runService.Set3dRenderingEnabled then
        runService:Set3dRenderingEnabled(not state)
    end
end

local renderToggle = MainTab:Toggle({
    Title = "Disable 3D Render",
    Desc = "Pauses 3D rendering completely for max performance/FPS while AFK",
    Value = getgenv().BoostHubConfig.Disable3DRender,
    Callback = function(state)
        applyDisable3DRender(state)
        WindUI:Notify({ Title = "3D Render", Content = state and "3D Rendering Disabled!" or "3D Rendering Enabled!", Duration = 3 })
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

applyAutoCatClick = function(state)
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
            getgenv().BoostHubConfig.AutoCatClick = false
        end
    else
        gato = nil
    end
end

local catClickToggle = FarmTab:Toggle({
    Title = "Auto Cat Click",
    Desc = "Automatically searches and clicks targets using ClickDetector scanner",
    Value = getgenv().BoostHubConfig.AutoCatClick,
    Callback = function(state)
        applyAutoCatClick(state)
    end,
})

applyAutoRNG = function(state)
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
end

local rngToggle = FarmTab:Toggle({
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
        applyAutoRNG(state)
    end,
})

applyAutoGoal = function(state)
    getgenv().AutoGoal = state
    getgenv().BoostHubConfig.AutoGoal = state

    if not state then return end

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
end

local goalToggle = FarmTab:Toggle({
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
        applyAutoGoal(state)
    end,
})

-- =============================================================
--                        3. EVENTS TAB
-- =============================================================
EventsTab:Section({ Title = "Special Events" })

applyAutoCollectOrbs = function(state)
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
end

local orbsToggle = EventsTab:Toggle({
    Title = "Auto Collect Orbs [NEW]",
    Desc = "Automatically teleports to DiscoOrb parts and stops when no orbs are left",
    Value = getgenv().BoostHubConfig.AutoCollectOrbs,
    Callback = function(state)
        applyAutoCollectOrbs(state)
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

local function applyAntiBan(state)
    getgenv().AntiBanEnabled = state
    getgenv().BoostHubConfig.AntiBanEnabled = state
end

local antiBanToggle = AutomationTab:Toggle({
    Title = "Anti-Ban Safe Mode",
    Desc = "Randomizes action timings (jitter) to prevent anti-cheat detection",
    Value = getgenv().BoostHubConfig.AntiBanEnabled,
    Callback = function(state)
        applyAntiBan(state)
        WindUI:Notify({ Title = "Anti-Ban", Content = state and "Anti-Ban Safe Mode Enabled!" or "Anti-Ban Safe Mode Disabled!", Duration = 3 })
    end,
})

AutomationTab:Section({ Title = "Stand & Begging Tasks" })

AutomationTab:Button({
    Title = "Claim Stand",
    Desc = "Teleports to BaseEmitter/Stand, checks for ProximityPrompt, and claims it",
    Callback = function()
        if not getgenv().AntiBanEnabled then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
        end

        local successClaim = AttemptClaimStand()
        if successClaim then
            WindUI:Notify({ Title = "Claim Stand", Content = "Successfully claimed stand and returned!", Duration = 3 })
        else
            if HasClaimedStand() then
                WindUI:Notify({ Title = "Claim Stand", Content = "You already own a valid player stand!", Duration = 4 })
            else
                WindUI:Notify({ Title = "Claim Stand", Content = "Could not locate a claimable stand!", Duration = 4 })
            end
        end
    end,
})

applyAutoClaimStand = function(state)
    getgenv().BoostHubConfig.AutoClaimStand = state

    if state then
        if not getgenv().AntiBanEnabled then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
        end

        WindUI:Notify({ Title = "Auto Claim Stand", Content = "Auto Claim Stand enabled! Checking stand status...", Duration = 3 })

        task.spawn(function()
            while getgenv().BoostHubConfig.AutoClaimStand do
                if not HasClaimedStand() then
                    AttemptClaimStand()
                end
                task.wait(5)
            end
        end)
    else
        WindUI:Notify({ Title = "Auto Claim Stand", Content = "Auto Claim Stand disabled.", Duration = 3 })
    end
end

local autoClaimStandToggle = AutomationTab:Toggle({
    Title = "Auto Claim Stand",
    Desc = "Automatically checks if you own a stand (by Display Name) and claims one if you don't",
    Value = getgenv().BoostHubConfig.AutoClaimStand,
    Callback = function(state)
        applyAutoClaimStand(state)
    end,
})

AutomationTab:Toggle({
    Title = "Auto Beg Say Toggle",
    Desc = "Enables or disables greeting targeted players in chat automatically",
    Value = autoBegSayEnabled,
    Callback = function(state)
        autoBegSayEnabled = state
        WindUI:Notify({ Title = "Auto Beg Say", Content = state and "Target greeting enabled!" or "Target greeting disabled.", Duration = 3 })
    end,
})

AutomationTab:Input({
    Title = "Auto Beg Greeting Message",
    Desc = "Use %s where the player's username should appear",
    Placeholder = "Hello %s, donate please!",
    Value = autoBegMessageTemplate,
    Callback = function(text)
        if text ~= "" then
            autoBegMessageTemplate = text
        end
    end,
})

applyAutoBeg = function(state)
    getgenv().BoostHubConfig.AutoBeg = state
    getgenv().BoostHubConfig.AutoBeg = state

    if state then
        if not getgenv().AntiBanEnabled then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
        end

        WindUI:Notify({ Title = "Auto Beg", Content = "Auto Beg pathfinding started (Speed 23, 40s timeout teleport, persistent filtering)!", Duration = 3 })

        task.spawn(function()
            local PathfindingService = game:GetService("PathfindingService")
            local beggedPlayers = {} 
            local playerTrackers = {} 

            task.wait(2.5)

            while getgenv().BoostHubConfig.AutoBeg do
                local player = game.Players.LocalPlayer
                local char = player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then
                    task.wait(1)
                    continue
                end

                local hrp = char.HumanoidRootPart
                local humanoid = char.Humanoid

                humanoid.WalkSpeed = 23

                local equippedTool = char:FindFirstChild("DonationSign")
                if not equippedTool then
                    task.wait(1)
                    local backpackTool = player.Backpack and player.Backpack:FindFirstChild("DonationSign")
                    if backpackTool then
                        humanoid:EquipTool(backpackTool)
                        task.wait(0.8)
                        equippedTool = char:FindFirstChild("DonationSign")
                    end
                end

                if not equippedTool then
                    WindUI:Notify({ Title = "Auto Beg", Content = "Buy a Sign in a shop for this to work!", Duration = 6 })
                    getgenv().BoostHubConfig.AutoBeg = false
                    getgenv().BoostHubConfig.AutoBeg = false
                    humanoid.WalkSpeed = 16
                    break
                end

                local currentTime = tick()
                for _, p in ipairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local pPos = p.Character.HumanoidRootPart.Position
                        if not playerTrackers[p.UserId] then
                            playerTrackers[p.UserId] = { pos = pPos, time = currentTime }
                        else
                            local data = playerTrackers[p.UserId]
                            if (pPos - data.pos).Magnitude > 3 then 
                                data.pos = pPos
                                data.time = currentTime
                            end
                        end
                    end
                end

                -- Find valid target who hasn't been begged yet
                local targetPlayer = nil
                local validPlayerCount = 0

                for _, p in ipairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local tracker = playerTrackers[p.UserId]
                        local isAfk = false
                        if tracker and (currentTime - tracker.time) >= 180 then
                            isAfk = true
                        end

                        if not isAfk then
                            local hasPaidItem = false
                            for _, desc in ipairs(p.Character:GetDescendants()) do
                                if desc:IsA("Accessory") or desc:IsA("Clothing") or desc:IsA("ShirtGraphic") or desc:IsA("BodyColors") then
                                    hasPaidItem = true
                                    break
                                end
                            end
                            if hasPaidItem then
                                validPlayerCount = validPlayerCount + 1
                                if not beggedPlayers[p.UserId] then
                                    targetPlayer = p
                                    break
                                end
                            end
                        end
                    end
                end

                -- If all valid players have been begged, reset the begged list so it can loop again
                if not targetPlayer and validPlayerCount > 0 then
                    beggedPlayers = {}
                    task.wait(1)
                    continue
                end

                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    beggedPlayers[targetPlayer.UserId] = true 
                    
                    local attemptStartTime = tick()
                    local reachedTarget = false

                    while getgenv().BoostHubConfig.AutoBeg and targetPlayer and targetPlayer.Parent and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") do
                        local targetHrp = targetPlayer.Character.HumanoidRootPart

                        -- IF CAN'T REACH FOR MORE THAN 40 SECONDS -> TELEPORT DIRECTLY TO THEM!
                        if tick() - attemptStartTime >= 40 then
                            hrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
                            task.wait(0.5)
                            reachedTarget = true
                            break
                        end

                        if (hrp.Position - targetHrp.Position).Magnitude <= 8 then
                            reachedTarget = true
                            break
                        end

                        local randomStuds = math.random(5, 7)
                        local destination = targetHrp.Position + (targetHrp.CFrame.LookVector * randomStuds)

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
                            local waypointIndex = 1

                            while waypointIndex <= #waypoints and getgenv().BoostHubConfig.AutoBeg and targetPlayer and targetPlayer.Parent and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") do
                                if tick() - attemptStartTime >= 40 then
                                    hrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                                    task.wait(0.5)
                                    reachedTarget = true
                                    break
                                end

                                local waypoint = waypoints[waypointIndex]
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
                                while not reached and tick() - startWait < 1.2 and getgenv().BoostHubConfig.AutoBeg do
                                    task.wait(0.1)
                                end
                                if conn then conn:Disconnect() end

                                waypointIndex = waypointIndex + 1
                            end
                        else
                            humanoid:MoveTo(destination)
                            task.wait(1)
                        end
                        task.wait(0.2)
                    end

                    if reachedTarget and targetPlayer and targetPlayer.Parent and targetPlayer.Character then
                        if getgenv().BoostHubConfig.AutoBeg and autoBegSayEnabled and targetPlayer and targetPlayer.Name then
                            local greetingMsg = string.format(autoBegMessageTemplate, targetPlayer.Name)
                            SendChatMessage(greetingMsg)
                        end

                        local elapsed = 0
                        while elapsed < 25 and getgenv().BoostHubConfig.AutoBeg do
                            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local targetHrp = targetPlayer.Character.HumanoidRootPart
                                local lookAtPos = Vector3.new(targetHrp.Position.X, hrp.Position.Y, targetHrp.Position.Z)
                                hrp.CFrame = CFrame.lookAt(hrp.Position, lookAtPos)

                                if (hrp.Position - targetHrp.Position).Magnitude > 10 then
                                    humanoid:MoveTo(targetHrp.Position)
                                end
                            else
                                break 
                            end
                            task.wait(0.5)
                            elapsed = elapsed + 0.5
                        end
                    end
                else
                    local spawnLoc = workspace:FindFirstChild("SpawnLocation", true)
                    if spawnLoc then
                        local spawnPos = spawnLoc:IsA("Model") and spawnLoc:GetPivot().Position or spawnLoc.Position
                        humanoid:MoveTo(spawnPos)
                    end
                    task.wait(3)
                end

                task.wait(1)
            end

            local currentLocalChar = game.Players.LocalPlayer.Character
            if currentLocalChar and currentLocalChar:FindFirstChildOfClass("Humanoid") then
                currentLocalChar.Humanoid.WalkSpeed = 16
            end
        end)
    else
        local currentLocalChar = game.Players.LocalPlayer.Character
        if currentLocalChar and currentLocalChar:FindFirstChildOfClass("Humanoid") then
            currentLocalChar.Humanoid.WalkSpeed = 16
        end
    end
end

local autoBegToggle = AutomationTab:Toggle({
    Title = "Auto Beg",
    Desc = "Follows moving players, faces them, waits 25s, and tracks location changes",
    Value = getgenv().BoostHubConfig.AutoBeg,
    Callback = function(state)
        applyAutoBeg(state)
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
                    local signTool = player.Backpack:FindFirstChild("DonationSign") or char:FindFirstChild("DonationSign")
                    if signTool then
                        humanoid:EquipTool(signTool)
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

applyAutoChatSpam = function(state)
    getgenv().AutoChatSpam = state
    getgenv().BoostHubConfig.AutoChatSpam = state
    if state then
        if not getgenv().AntiBanEnabled then
            WindUI:Notify({ Title = "Ban Warning", Content = "Warning! There is a chance that you can get banned", Duration = 4 })
        end
        task.spawn(function()
            while getgenv().BoostHubConfig.AutoChatSpam do
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
                
                local waitTime = 25
                if getgenv().AntiBanEnabled then
                    waitTime = waitTime + math.random(-4, 5)
                end
                
                local elapsed = 0
                while elapsed < waitTime and getgenv().BoostHubConfig.AutoChatSpam do
                    task.wait(0.5)
                    elapsed = elapsed + 0.5
                end
            end
        end)
        WindUI:Notify({ Title = "Auto Chat", Content = "Auto Chat Spammer enabled (25s delay)!", Duration = 3 })
    end
end

local autoChatSpamToggle = AutomationTab:Toggle({
    Title = "Auto Chat Spammer",
    Desc = "Sends a random custom message from your 5 fields every 25 seconds",
    Value = getgenv().BoostHubConfig.AutoChatSpam,
    Callback = function(state)
        applyAutoChatSpam(state)
    end,
})

-- FUNCTION TO FORCE UI CONTROLS TO SYNC WITH LOADED CONFIG VALUES
updateTogglesAndSettings = function()
    pcall(function()
        if walkSpeedSlider and walkSpeedSlider.SetValue then walkSpeedSlider:SetValue(getgenv().BoostHubConfig.WalkSpeed) end
        if jumpPowerSlider and jumpPowerSlider.SetValue then jumpPowerSlider:SetValue(getgenv().BoostHubConfig.JumpPower) end
        if renderToggle and renderToggle.SetValue then renderToggle:SetValue(getgenv().BoostHubConfig.Disable3DRender) end
        if catClickToggle and catClickToggle.SetValue then catClickToggle:SetValue(getgenv().BoostHubConfig.AutoCatClick) end
        if rngToggle and rngToggle.SetValue then rngToggle:SetValue(getgenv().BoostHubConfig.AutoRNG) end
        if goalToggle and goalToggle.SetValue then goalToggle:SetValue(getgenv().BoostHubConfig.AutoGoal) end
        if orbsToggle and orbsToggle.SetValue then orbsToggle:SetValue(getgenv().BoostHubConfig.AutoCollectOrbs) end
        if antiBanToggle and antiBanToggle.SetValue then antiBanToggle:SetValue(getgenv().AntiBanEnabled) end
        if autoClaimStandToggle and autoClaimStandToggle.SetValue then autoClaimStandToggle:SetValue(getgenv().BoostHubConfig.AutoClaimStand) end
        if autoBegToggle and autoBegToggle.SetValue then autoBegToggle:SetValue(getgenv().BoostHubConfig.AutoBeg) end
        if autoChatSpamToggle and autoChatSpamToggle.SetValue then autoChatSpamToggle:SetValue(getgenv().BoostHubConfig.AutoChatSpam) end
    end)
end

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
ConfigureTab:Section({ Title = "Configuration Manager" })

ConfigureTab:Input({
    Title = "Configuration Name",
    Desc = "Type a name for your configuration",
    Placeholder = "MyConfig...",
    Callback = function(text)
        if text ~= "" then
            configInputName = text
        end
    end,
})

ConfigureTab:Button({
    Title = "Save Configuration",
    Desc = "Saves all your currently enabled toggles and settings to the typed name",
    Callback = function()
        saveConfiguration(configInputName)
    end,
})

local configDropdown = ConfigureTab:Dropdown({
    Title = "Select Configuration",
    Desc = "Choose an existing configuration file",
    Values = getSavedConfigsList(),
    Default = "DefaultConfig",
    Callback = function(selected)
        selectedConfigDropdown = selected
    end,
})

ConfigureTab:Button({
    Title = "Refresh Config List",
    Desc = "Refreshes the configuration dropdown list",
    Callback = function()
        pcall(function()
            if configDropdown and configDropdown.Refresh then
                configDropdown:Refresh(getSavedConfigsList())
            end
        end)
        WindUI:Notify({ Title = "Refreshed", Content = "Configuration list updated!", Duration = 2 })
    end,
})

ConfigureTab:Button({
    Title = "Load Selected Configuration",
    Desc = "Loads the settings from the selected configuration dropdown",
    Callback = function()
        loadConfiguration(selectedConfigDropdown)
    end,
})

ConfigureTab:Section({ Title = "Auto Load Configuration Setting" })

ConfigureTab:Input({
    Title = "What Configuration You Need to Auto Load",
    Desc = "Enter the exact configuration name to load automatically on script execution",
    Placeholder = "ConfigName...",
    Callback = function(text)
        autoLoadConfigName = text
    end,
})

ConfigureTab:Button({
    Title = "Set Auto Load Configuration",
    Desc = "Saves this configuration to auto-load every time you run the script",
    Callback = function()
        if writefile then
            pcall(function()
                if makefolder then
                    pcall(function() makefolder("BoostHubConfigs") end)
                end
                writefile("BoostHubConfigs/AutoLoadConfig.json", autoLoadConfigName)
                WindUI:Notify({ Title = "Auto Load Saved", Content = "Will auto-load configuration: " .. autoLoadConfigName, Duration = 3 })
            end)
        else
            WindUI:Notify({ Title = "Error", Content = "Executor does not support writefile!", Duration = 3 })
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
