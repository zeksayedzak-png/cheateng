-- ============================================
-- 📱 ROBLOX MOBILE HACK ENGINE ULTIMATE
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer
local Mouse = localPlayer:GetMouse()

-- تمكين الثغرات
local function HookMetaTable()
    local mt = getrawmetatable(game)
    local old = mt.__namecall
    
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- تجاوز الحماية
        if method == "Kick" or method == "kick" then
            warn("🚫 Blocked kick attempt!")
            return nil
        end
        
        return old(self, unpack(args))
    end)
    setreadonly(mt, true)
end

-- البحث القصري
local function ForceSearch(value)
    local results = {}
    local function deepSearch(parent)
        for _, child in pairs(parent:GetChildren()) do
            pcall(function()
                -- البحث في الخصائص
                for prop, val in pairs(getproperties(child)) do
                    if tostring(val):lower():find(tostring(value):lower()) then
                        table.insert(results, {
                            Object = child,
                            Property = prop,
                            Value = val,
                            Path = child:GetFullName()
                        })
                    end
                end
            end)
            deepSearch(child)
        end
    end
    deepSearch(game)
    return results
end

-- حقن سكريبت تنفيذي
local function InjectScript(scriptCode)
    local env = getfenv()
    local fn, err = loadstring(scriptCode)
    if fn then
        setfenv(fn, setmetatable({}, {
            __index = function(t, k)
                return env[k] or _G[k]
            end
        }))
        pcall(fn)
        return true
    else
        return false, err
    end
end

-- تنفيذ قسري
local function ForceExecute(target, command)
    if target == "All" then
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    if command == "Kill" then
                        humanoid.Health = 0
                    elseif command == "Freeze" then
                        humanoid.WalkSpeed = 0
                    elseif command == "Launch" then
                        local root = player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.Velocity = Vector3.new(0, 1000, 0)
                        end
                    end
                end
            end
        end
    end
end

-- المسح الفوري
local function InstantScan()
    local data = {
        Players = {},
        Tools = {},
        Values = {},
        Scripts = {}
    }
    
    -- مسح اللاعبين
    for _, player in pairs(Players:GetPlayers()) do
        table.insert(data.Players, {
            Name = player.Name,
            UserId = player.UserId,
            Character = player.Character and true or false,
            Team = player.Team and player.Team.Name or "None"
        })
    end
    
    -- مسح الأدوات
    if localPlayer.Backpack then
        for _, tool in pairs(localPlayer.Backpack:GetChildren()) do
            table.insert(data.Tools, {
                Name = tool.Name,
                Class = tool.ClassName,
                AssetId = tool:GetAttribute("AssetId") or "N/A"
            })
        end
    end
    
    -- مسح القيم المخفية
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("ValueBase") and obj.Parent and not obj.Parent:IsA("Player") then
            table.insert(data.Values, {
                Name = obj.Name,
                Value = obj.Value,
                Type = obj.ClassName,
                Path = obj:GetFullName():sub(1, 100)
            })
        elseif obj:IsA("BaseScript") then
            table.insert(data.Scripts, {
                Name = obj.Name,
                Disabled = obj.Disabled,
                Path = obj:GetFullName()
            })
        end
    end
    
    return data
end

-- واجهة قابلة للسحب
local gui = Instance.new("ScreenGui")
gui.Name = "MobileHackUltimate"
gui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.85, 0, 0.9, 0)
mainFrame.Position = UDim2.new(0.075, 0, 0.05, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

-- شريط العنوان مع زر الإغلاق
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
titleBar.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Text = "📱 MOBILE HACK ULTIMATE v3.0"
title.Size = UDim2.new(1, -50, 1, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "✕"
closeBtn.Size = UDim2.new(0, 40, 1, 0)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 24
closeBtn.Parent = titleBar

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- علامات التبويب
local tabButtons = {}
local tabFrames = {}

local tabs = {
    {Name = "🔍 SCANNER", Color = Color3.fromRGB(0, 120, 255)},
    {Name = "⚡ HACKS", Color = Color3.fromRGB(255, 80, 0)},
    {Name = "💉 INJECT", Color = Color3.fromRGB(0, 200, 80)},
    {Name = "🎮 TOOLS", Color = Color3.fromRGB(180, 0, 255)}
}

for i, tab in ipairs(tabs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Text = tab.Name
    tabBtn.Size = UDim2.new(1/#tabs, 0, 0, 35)
    tabBtn.Position = UDim2.new((i-1)/#tabs, 0, 0, 40)
    tabBtn.BackgroundColor3 = tab.Color
    tabBtn.TextColor3 = Color3.new(1, 1, 1)
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 14
    tabBtn.Parent = mainFrame
    
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, 0, 1, -75)
    tabFrame.Position = UDim2.new(0, 0, 0, 75)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = (i == 1)
    tabFrame.Parent = mainFrame
    
    tabButtons[i] = tabBtn
    tabFrames[i] = tabFrame
    
    tabBtn.MouseButton1Click:Connect(function()
        for j, frame in ipairs(tabFrames) do
            frame.Visible = (j == i)
            tabButtons[j].BackgroundColor3 = (j == i) and tabs[j].Color or Color3.fromRGB(80, 80, 80)
        end
    end)
end

-- ==================== تبويب السكانر ====================
local scannerFrame = tabFrames[1]

-- زر المسح الفوري
local scanNowBtn = Instance.new("TextButton")
scanNowBtn.Text = "⚡ SCAN NOW"
scanNowBtn.Size = UDim2.new(0.9, 0, 0, 50)
scanNowBtn.Position = UDim2.new(0.05, 0, 0, 10)
scanNowBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
scanNowBtn.TextColor3 = Color3.new(1, 1, 1)
scanNowBtn.Font = Enum.Font.GothamBlack
scanNowBtn.TextSize = 18
scanNowBtn.Parent = scannerFrame

local scannerOutput = Instance.new("ScrollingFrame")
scannerOutput.Size = UDim2.new(0.95, 0, 0, 300)
scannerOutput.Position = UDim2.new(0.025, 0, 0, 70)
scannerOutput.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
scannerOutput.ScrollBarThickness = 6
scannerOutput.Parent = scannerFrame

local searchBox = Instance.new("TextBox")
searchBox.PlaceholderText = "Force Search..."
searchBox.Size = UDim2.new(0.7, 0, 0, 40)
searchBox.Position = UDim2.new(0.15, 0, 0, 380)
searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Font = Enum.Font.Code
searchBox.TextSize = 16
searchBox.Parent = scannerFrame

local forceSearchBtn = Instance.new("TextButton")
forceSearchBtn.Text = "🔍 FORCE"
forceSearchBtn.Size = UDim2.new(0.25, 0, 0, 40)
forceSearchBtn.Position = UDim2.new(0.85, -10, 0, 380)
forceSearchBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
forceSearchBtn.TextColor3 = Color3.new(1, 1, 1)
forceSearchBtn.Font = Enum.Font.GothamBold
forceSearchBtn.TextSize = 16
forceSearchBtn.Parent = scannerFrame

scanNowBtn.MouseButton1Click:Connect(function()
    scanNowBtn.Text = "⏳ SCANNING..."
    
    task.spawn(function()
        local data = InstantScan()
        local result = "📊 INSTANT SCAN RESULTS:\n"
        result = result .. "=" .. string.rep("=", 50) .. "\n\n"
        
        result = result .. "👥 PLAYERS: " .. #data.Players .. "\n"
        for i, player in ipairs(data.Players) do
            result = result .. i .. ". " .. player.Name .. " (Team: " .. player.Team .. ")\n"
        end
        
        result = result .. "\n🛠️ TOOLS: " .. #data.Tools .. "\n"
        for i, tool in ipairs(data.Tools) do
            result = result .. i .. ". " .. tool.Name .. " [" .. tool.Class .. "]\n"
        end
        
        result = result .. "\n💰 VALUES: " .. #data.Values .. "\n"
        for i, value in ipairs(data.Values) do
            if i <= 10 then
                result = result .. i .. ". " .. value.Name .. " = " .. tostring(value.Value) .. "\n"
            end
        end
        
        if #data.Values > 10 then
            result = result .. "... and " .. (#data.Values - 10) .. " more\n"
        end
        
        local outputLabel = Instance.new("TextLabel")
        outputLabel.Size = UDim2.new(1, 0, 0, 0)
        outputLabel.Position = UDim2.new(0, 10, 0, 10)
        outputLabel.BackgroundTransparency = 1
        outputLabel.TextColor3 = Color3.new(1, 1, 1)
        outputLabel.Font = Enum.Font.Code
        outputLabel.TextSize = 11
        outputLabel.TextWrapped = true
        outputLabel.TextXAlignment = Enum.TextXAlignment.Left
        outputLabel.TextYAlignment = Enum.TextYAlignment.Top
        outputLabel.AutomaticSize = Enum.AutomaticSize.Y
        outputLabel.Text = result
        outputLabel.Parent = scannerOutput
        
        scannerOutput:ClearAllChildren()
        scannerOutput.CanvasSize = UDim2.new(0, 0, 0, outputLabel.TextBounds.Y + 20)
        outputLabel.Parent = scannerOutput
        
        scanNowBtn.Text = "✅ SCAN COMPLETE"
        task.wait(2)
        scanNowBtn.Text = "⚡ SCAN NOW"
    end)
end)

forceSearchBtn.MouseButton1Click:Connect(function()
    local searchText = searchBox.Text
    if searchText == "" then return end
    
    forceSearchBtn.Text = "⏳"
    
    task.spawn(function()
        local results = ForceSearch(searchText)
        
        local result = "🔍 FORCE SEARCH RESULTS:\n"
        result = result .. string.rep("=", 50) .. "\n\n"
        result = result .. "Found: " .. #results .. " matches\n\n"
        
        for i, item in ipairs(results) do
            if i <= 20 then
                result = result .. i .. ". " .. item.Path .. "\n"
                result = result .. "   📌 " .. item.Property .. " = " .. tostring(item.Value) .. "\n\n"
            end
        end
        
        if #results > 20 then
            result = result .. "... and " .. (#results - 20) .. " more results\n"
        end
        
        local outputLabel = Instance.new("TextLabel")
        outputLabel.Size = UDim2.new(1, 0, 0, 0)
        outputLabel.Position = UDim2.new(0, 10, 0, 10)
        outputLabel.BackgroundTransparency = 1
        outputLabel.TextColor3 = Color3.new(0, 1, 1)
        outputLabel.Font = Enum.Font.Code
        outputLabel.TextSize = 10
        outputLabel.TextWrapped = true
        outputLabel.TextXAlignment = Enum.TextXAlignment.Left
        outputLabel.TextYAlignment = Enum.TextYAlignment.Top
        outputLabel.AutomaticSize = Enum.AutomaticSize.Y
        outputLabel.Text = result
        outputLabel.Parent = scannerOutput
        
        scannerOutput:ClearAllChildren()
        scannerOutput.CanvasSize = UDim2.new(0, 0, 0, outputLabel.TextBounds.Y + 20)
        outputLabel.Parent = scannerOutput
        
        forceSearchBtn.Text = "🔍 FORCE"
    end)
end)

-- ==================== تبويب الهكر ====================
local hacksFrame = tabFrames[2]

local hacks = {
    {Name = "🚀 FLY", Command = function()
        local flyEnabled = not (localPlayer.Character and localPlayer.Character:FindFirstChild("FlyVelocity"))
        if flyEnabled then
            -- كود الطيران
        else
            -- إيقاف الطيران
        end
    end},
    
    {Name = "👻 NO CLIP", Command = function()
        if localPlayer.Character then
            for _, part in pairs(localPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not part.CanCollide
                end
            end
        end
    end},
    
    {Name = "⚡ SPEED x3", Command = function()
        if localPlayer.Character then
            local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = humanoid.WalkSpeed * 3
            end
        end
    end},
    
    {Name = "💥 KILL ALL", Command = function()
        ForceExecute("All", "Kill")
    end},
    
    {Name = "❄️ FREEZE ALL", Command = function()
        ForceExecute("All", "Freeze")
    end},
    
    {Name = "🚀 LAUNCH ALL", Command = function()
        ForceExecute("All", "Launch")
    end}
}

for i, hack in ipairs(hacks) do
    local hackBtn = Instance.new("TextButton")
    hackBtn.Text = hack.Name
    hackBtn.Size = UDim2.new(0.45, 0, 0, 50)
    hackBtn.Position = UDim2.new(
        (i % 2 == 1) and 0.025 or 0.525,
        0,
        0.1 + math.floor((i-1)/2) * 0.15,
        0
    )
    hackBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    hackBtn.TextColor3 = Color3.new(1, 1, 1)
    hackBtn.Font = Enum.Font.GothamBold
    hackBtn.TextSize = 16
    hackBtn.Parent = hacksFrame
    
    hackBtn.MouseButton1Click:Connect(hack.Command)
end

-- ==================== تبويب الحقن ====================
local injectFrame = tabFrames[3]

local scriptBox = Instance.new("TextBox")
scriptBox.PlaceholderText = "Paste your script here..."
scriptBox.Size = UDim2.new(0.9, 0, 0, 200)
scriptBox.Position = UDim2.new(0.05, 0, 0, 10)
scriptBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
scriptBox.TextColor3 = Color3.new(1, 1, 1)
scriptBox.Font = Enum.Font.Code
scriptBox.TextSize = 12
scriptBox.TextXAlignment = Enum.TextXAlignment.Left
scriptBox.TextYAlignment = Enum.TextYAlignment.Top
scriptBox.TextWrapped = true
scriptBox.ClearTextOnFocus = false
scriptBox.Parent = injectFrame

local injectBtn = Instance.new("TextButton")
injectBtn.Text = "💉 INJECT SCRIPT"
injectBtn.Size = UDim2.new(0.9, 0, 0, 50)
injectBtn.Position = UDim2.new(0.05, 0, 0, 220)
injectBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
injectBtn.TextColor3 = Color3.new(1, 1, 1)
injectBtn.Font = Enum.Font.GothamBlack
injectBtn.TextSize = 18
injectBtn.Parent = injectFrame

local presets = {
    "print('Hello from injected script!')",
    "game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50",
    "for i,v in pairs(game.Players:GetPlayers()) do print(v.Name) end"
}

local presetBox = Instance.new("TextBox")
presetBox.PlaceholderText = "Quick Presets: 1=Print, 2=Speed, 3=ListPlayers"
presetBox.Size = UDim2.new(0.9, 0, 0, 40)
presetBox.Position = UDim2.new(0.05, 0, 0, 280)
presetBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
presetBox.TextColor3 = Color3.new(1, 1, 1)
presetBox.Font = Enum.Font.Code
presetBox.TextSize = 14
presetBox.Parent = injectFrame

injectBtn.MouseButton1Click:Connect(function()
    local script = scriptBox.Text
    if script == "" then
        local presetNum = tonumber(presetBox.Text)
        if presetNum and presetNum >= 1 and presetNum <= #presets then
            script = presets[presetNum]
        end
    end
    
    if script ~= "" then
        injectBtn.Text = "⏳ INJECTING..."
        local success, err = InjectScript(script)
        if success then
            injectBtn.Text = "✅ INJECTED!"
            injectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else
            injectBtn.Text = "❌ ERROR!"
            injectBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            warn("Injection Error: " .. tostring(err))
        end
        task.wait(1.5)
        injectBtn.Text = "💉 INJECT SCRIPT"
        injectBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
    end
end)

-- ==================== تبويب الأدوات ====================
local toolsFrame = tabFrames[4]

local tools = {
    {Name = "📸 ESP BOXES", Command = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.Parent = player.Character
            end
        end
    end},
    
    {Name = "🎯 AIMBOT", Command = function()
        -- كود الأيمبوت المبسط
        Mouse.Button1Down:Connect(function()
            local closest = nil
            local closestDist = math.huge
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        local dist = (head.Position - Mouse.Origin.Position).Magnitude
                        if dist < closestDist then
                            closest = head
                            closestDist = dist
                        end
                    end
                end
            end
            
            if closest then
                Mouse.Target = closest
            end
        end)
    end},
    
    {Name = "🔧 TP TOOLS", Command = function()
        if localPlayer.Character then
            local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 5, 0))
            end
        end
    end},
    
    {Name = "🛡️ ANTI-AFK", Command = function()
        local vu = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:connect(function()
            vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)
    end}
}

for i, tool in ipairs(tools) do
    local toolBtn = Instance.new("TextButton")
    toolBtn.Text = tool.Name
    toolBtn.Size = UDim2.new(0.45, 0, 0, 50)
    toolBtn.Position = UDim2.new(
        (i % 2 == 1) and 0.025 or 0.525,
        0,
        0.1 + math.floor((i-1)/2) * 0.15,
        0
    )
    toolBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
    toolBtn.TextColor3 = Color3.new(1, 1, 1)
    toolBtn.Font = Enum.Font.GothamBold
    toolBtn.TextSize = 16
    toolBtn.Parent = toolsFrame
    
    toolBtn.MouseButton1Click:Connect(tool.Command)
end

-- تمكين نظام السحب
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X,
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

print("✅ MOBILE HACK ENGINE ULTIMATE LOADED!")
print("🔥 Features: Force Search, Instant Scan, Script Injection, Hacks, Draggable UI")
print("📱 Touch and drag the top bar to move!")
