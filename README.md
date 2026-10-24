-- =================================================================
--                     BOOST HUB - WIND UI TEMPLATE
-- =================================================================

-- 1. LOAD WIND UI LIBRARY
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Global Delay Settings (In Seconds)
getgenv().CatClickDelay = 0.1 -- Default 100 ms
getgenv().RNGDelay = 15       -- Default 15 seconds

-- Text Generator State Variables
local textGenText = "testing"
local textGenFont = "FredokaOne"
local textGenColor = "#ff0000"
local textGenStrokeColor = "#000000"
local textGenThickness = 1

-- 2. CREATE MAIN WINDOW WITH NATIVE KEY SYSTEM
local Window = WindUI:CreateWindow({
    Title = "Boost Hub",
    SubTitle = "v1.0.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Theme = "Dark",
    Transparent = true,
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
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
local VisualTab = Window:Tab({ Title = "Visual", Icon = "eye" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

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

                -- PC Keyboard controls
                if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                -- Mobile Joystick & Jump controls
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

-- Noclip Toggle
local noclip = false
MainTab:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls and obstacles",
    Value = false,
    Callback = function(state)
        noclip = state
    end,
})

-- Noclip Loop Connection
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
    Value = { Min = 100, Max = 10000, Default = 100 },
    Callback = function(ms)
        getgenv().CatClickDelay = ms / 1000
    end,
})

-- Adjust Delay For Auto RNG (5 Seconds to 50 Seconds)
FarmTab:Slider({
    Title = "Adjust Delay For Auto RNG (Sec)",
    Value = { Min = 5, Max = 50, Default = 15 },
    Callback = function(sec)
        getgenv().RNGDelay = sec
    end,
})

FarmTab:Section({ Title = "Automation Toggles" })

-- Auto Cat Click Toggle (Strictly workspace.Cat)
FarmTab:Toggle({
    Title = "Auto Cat Click",
    Desc = "Automatically clicks the 'Cat' part",
    Value = false,
    Callback = function(state)
        getgenv().AutoCatClick = state
        if state then
            task.spawn(function()
                while getgenv().AutoCatClick do
                    local catPart = workspace:FindFirstChild("Cat")
                    local char = game.Players.LocalPlayer.Character
                    
                    if catPart then
                        local cd = catPart:FindFirstChildOfClass("ClickDetector") or catPart:FindFirstChildWhichIsA("ClickDetector", true)
                        if cd and fireclickdetector then
                            fireclickdetector(cd)
                        end
                        
                        local prompt = catPart:FindFirstChildOfClass("ProximityPrompt") or catPart:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and fireproximityprompt then
                            fireproximityprompt(prompt)
                        end
                        
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local touchPart = catPart:IsA("BasePart") and catPart or catPart:FindFirstChildWhichIsA("BasePart", true)
                            if touchPart then
                                firetouchinterest(char.HumanoidRootPart, touchPart, 0)
                                task.wait(0.02)
                                firetouchinterest(char.HumanoidRootPart, touchPart, 1)
                            end
                        end
                    end
                    task.wait(getgenv().CatClickDelay or 0.1)
                end
            end)
        end
    end,
})

-- Auto RNG Toggle (Strictly workspace.RNGButton)
FarmTab:Toggle({
    Title = "Auto RNG",
    Desc = "Teleports to 'RNGButton' based on set delay",
    Value = false,
    Callback = function(state)
        getgenv().AutoRNG = state
        if state then
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

-- Auto Goal Toggle (Placeholder)
FarmTab:Toggle({
    Title = "Auto Goal",
    Desc = "Automatically completes goal objectives",
    Value = false,
    Callback = function(state)
        getgenv().AutoGoal = state
        print("Auto Goal set to:", state)
    end,
})

-- =============================================================
--                     3. AUTOMATION TAB
-- =============================================================
AutomationTab:Section({ Title = "Stand & Begging Tasks" })

-- Auto Claim Stand (Checks parts named "Stand")
AutomationTab:Button({
    Title = "Auto Claim Stand",
    Desc = "Teleports to nearest unclaimed Stand, claims it, and teleports back",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        local hrp = char.HumanoidRootPart
        local originalCFrame = hrp.CFrame

        -- Search through workspace or workspace.Stands for parts named "Stand"
        local searchContainer = workspace:FindFirstChild("Stands") or workspace
        local nearestStandPrompt = nil
        local shortestDist = math.huge

        for _, obj in pairs(searchContainer:GetDescendants()) do
            if obj.Name == "Stand" or obj.Parent and obj.Parent.Name == "Stand" then
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

-- Auto Beg (Teleports to SpawnLocation, equips tool from inventory)
AutomationTab:Button({
    Title = "Auto Beg",
    Desc = "Teleports to SpawnLocation and equips begging tool",
    Callback = function()
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

        -- Check Backpack for a tool
        if player:FindFirstChild("Backpack") then
            for _, item in pairs(player.Backpack:GetChildren()) do
                if item:IsA("Tool") then
                    toolToEquip = item
                    break
                end
            end
        end

        -- Check if tool is already in Character
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

-- =============================================================
--                     4. TELEPORT TAB
-- =============================================================
TeleportTab:Section({ Title = "Location Teleports" })

local function TeleportToInstance(instanceObj, displayName)
    local char = game.Players.LocalPlayer.Character
    if instanceObj and char and char:FindFirstChild("HumanoidRootPart") then
        if instanceObj:IsA("Model") then
            char.HumanoidRootPart.CFrame = instanceObj:GetPivot() + Vector3.new(0, 3, 0)
        elseif instanceObj:IsA("BasePart") then
            char.HumanoidRootPart.CFrame = instanceObj.CFrame + Vector3.new(0, 3, 0)
        end
        WindUI:Notify({ Title = "Teleport", Content = "Teleported to " .. displayName, Duration = 3 })
    else
        WindUI:Notify({ Title = "Error", Content = displayName .. " target not found!", Duration = 3 })
    end
end

-- TP to Cat (workspace.Cat)
TeleportTab:Button({
    Title = "TP to Cat",
    Desc = "Teleport to Cat",
    Callback = function()
        TeleportToInstance(workspace:FindFirstChild("Cat"), "Cat")
    end,
})

-- TP to RNG (workspace.RNGButton)
TeleportTab:Button({
    Title = "TP to RNG",
    Desc = "Teleport to RNGButton",
    Callback = function()
        TeleportToInstance(workspace:FindFirstChild("RNGButton"), "RNGButton")
    end,
})

-- TP to Leaderboard (workspace.Leaderboards["Most Points"])
TeleportTab:Button({
    Title = "TP to Leaderboard",
    Desc = "Teleport to Leaderboards -> Most Points",
    Callback = function()
        local leaderboards = workspace:FindFirstChild("Leaderboards")
        local target = leaderboards and leaderboards:FindFirstChild("Most Points")
        TeleportToInstance(target, "Leaderboards -> Most Points")
    end,
})

-- TP to Soccerball (workspace.FootBall.Model)
TeleportTab:Button({
    Title = "TP to Soccerball",
    Desc = "Teleport to FootBall -> Model",
    Callback = function()
        local football = workspace:FindFirstChild("FootBall")
        local target = football and football:FindFirstChild("Model")
        TeleportToInstance(target, "FootBall -> Model")
    end,
})

-- TP to AfkTower (workspace.AfkTower.Model)
TeleportTab:Button({
    Title = "TP to AfkTower",
    Desc = "Teleport to AfkTower -> Model",
    Callback = function()
        local afkTower = workspace:FindFirstChild("AfkTower")
        local target = afkTower and afkTower:FindFirstChild("Model")
        TeleportToInstance(target, "AfkTower -> Model")
    end,
})

-- TP to Shop (workspace.Stands.Bookshelf)
TeleportTab:Button({
    Title = "TP to Shop",
    Desc = "Teleport to Stands -> Bookshelf",
    Callback = function()
        local stands = workspace:FindFirstChild("Stands")
        local target = stands and stands:FindFirstChild("Bookshelf")
        TeleportToInstance(target, "Stands -> Bookshelf")
    end,
})

-- =============================================================
--                      5. VISUAL TAB
-- =============================================================
VisualTab:Section({ Title = "Performance & Graphics" })

-- Anti Lag / FPS Boost Toggle
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

VisualTab:Section({ Title = "RichText Formatting Generator" })

-- Text Input
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

-- Font Input
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

-- Color Input
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

-- Stroke Thickness Slider (1 to 5)
VisualTab:Slider({
    Title = "Stroke Thickness",
    Value = { Min = 1, Max = 5, Default = 1 },
    Callback = function(thickness)
        textGenThickness = thickness
    end,
})

-- Copy Formatted RichText Result Button
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
--                      6. SETTINGS TAB
-- =============================================================
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
