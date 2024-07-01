(getgenv()).Config = {
    ["FastAttack"] = true,
    ["ClickAttack"] = true
}

-- Флаг для остановки всех процессов
local isToggling = false

-- Основной цикл для быстрой атаки
local function startFastAttack()
    coroutine.wrap(function()
        for _, func in pairs(getreg()) do
            if typeof(func) == "function" and getfenv(func).script == game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework then
                for _, upvalue in pairs(debug.getupvalues(func)) do
                    if typeof(upvalue) == "table" then
                        spawn(function()
                            game:GetService("RunService").RenderStepped:Connect(function()
                                if isToggling and getgenv().Config['FastAttack'] then
                                    pcall(function()
                                        upvalue.activeController.timeToNextAttack = 0 -- Быстрая атака
                                        upvalue.activeController.attacking = false
                                        upvalue.activeController.increment = 4
                                        upvalue.activeController.blocking = false
                                        upvalue.activeController.humanoid.AutoRotate = true
                                        upvalue.activeController.focusStart = 0
                                        upvalue.activeController.currentAttackTrack = 0
                                        sethiddenproperty(game:GetService("Players").LocalPlayer, "SimulationRadius", math.huge)
                                    end)
                                end
                            end)
                        end)
                    end
                end
            end
        end
    end)()
end

-- Основной цикл для автокликера
-- Основной цикл для автокликера
local function startAutoClicker()
    spawn(function()
        game:GetService("RunService").RenderStepped:Connect(function()
            if isToggling and getgenv().Config['ClickAttack'] then
                pcall(function()
                    local vu = game:GetService('VirtualUser')
                    vu:CaptureController()
                    vu:Button1Down(Vector2.new(0.5, 0.5)) -- Установлен центр экрана
                    wait(0.1)  -- Дайте время для выполнения клика
                    vu:Button1Up(Vector2.new(0.5, 0.5)) -- Отпустите кнопку
                end)
            end
        end)
    end)
end

-- Change the size of HumanoidRootPart
local function changeHumanoidRootPartSize(size)
    local character = game.Players.LocalPlayer.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.Size = size
        end
    end
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local GothVers = "1.0.0"

local Window = Fluent:CreateWindow({
    Title = "Blox Fruits AutoFarm : " .. GothVers,
    SubTitle = "by GothSlayer",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 350),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "lock" }),
}

local Options = Fluent.Options

-- Function to find all enemies of a specific type within a certain range
local function findEnemies(enemyType)
    local enemies = {}
    for _, enemy in ipairs(game.Workspace.Enemies:GetChildren()) do
        if enemy.Name == enemyType then
            table.insert(enemies, enemy)
        end
    end
    return enemies
end

-- Function to calculate the average position of enemies
local function calculateAveragePosition(enemyType)
    local enemies = findEnemies(enemyType)
    local totalPosition = Vector3.new()
    local count = 0

    for _, enemy in ipairs(enemies) do
        local part = enemy.PrimaryPart or enemy:FindFirstChild("HumanoidRootPart")
        if part then
            totalPosition = totalPosition + part.Position
            count = count + 1
        end
    end

    if count > 0 then
        local averagePosition = totalPosition / count
        return averagePosition
    else
        return nil
    end
end

-- Function to tween to a specified position
local function tweenToPosition(position)
    local hoverHeight = 10 -- Adjust this value as needed
    local hoverPosition = position + Vector3.new(0, hoverHeight, 0)

    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(game.Players.LocalPlayer.Character.HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(hoverPosition)})
    tween:Play()
    tween.Completed:Wait()
end

-- Function to gather enemies towards the player
local function gatherEnemies(enemyType)
    local enemies = findEnemies(enemyType)
    local playerPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.Position

    local hoverHeight = 10 -- Adjust this value as needed
    local hoverPosition = playerPosition + Vector3.new(0, hoverHeight, 0)
    
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

    for _, enemy in ipairs(enemies) do
        local part = enemy.PrimaryPart or enemy:FindFirstChild("HumanoidRootPart")
        if part then
            local enemyTween = game:GetService("TweenService"):Create(part, tweenInfo, {CFrame = CFrame.new(hoverPosition)})
            enemyTween:Play()
        end
    end
end

-- Function to attack enemies
local function attackEnemies(enemyType)
    local enemies = findEnemies(enemyType)
    for _, enemy in ipairs(enemies) do
        local sword = game.Players.LocalPlayer.Backpack:FindFirstChild("Sword") or game.Players.LocalPlayer.Character:FindFirstChild("Sword")
        if sword and enemy:FindFirstChild("Humanoid") then
            if not game.Players.LocalPlayer.Character:FindFirstChild("Sword") then
                sword.Parent = game.Players.LocalPlayer.Character
            end
            enemy.Humanoid:TakeDamage(50)  -- Adjust the damage value as needed
            print("Attacked enemy: " .. enemy.Name) -- Отладочное сообщение
        else
            print("Failed to attack enemy: " .. enemy.Name) -- Отладочное сообщение
        end
    end
end

-- Main farming sequence
-- Main farming sequence
local function farmSequence()
    local npcTypes = {"Reborn Skeleton", "Demonic Soul", "Possessed Mummy", "Living Zombie"}

    while isToggling do
        for _, npcType in ipairs(npcTypes) do
            print("Farming: " .. npcType) -- Отладочное сообщение
            local enemies = findEnemies(npcType)
            for _, enemy in ipairs(enemies) do
                local averagePosition = calculateAveragePosition(npcType)
                if averagePosition then
                    tweenToPosition(averagePosition)
                    gatherEnemies(npcType)
                    attackEnemies(enemy)
                else
                    print("No enemies found for: " .. npcType) -- Отладочное сообщение
                end
            end
            wait(2)  -- Adjust the wait time as needed
        end
    end
end

-- Toggle functionality
local Toggle = Tabs.Main:AddToggle("MyToggle", {Title = "Toggle", Default = false })

Toggle:OnChanged(function(state)
    if state then
        isToggling = true
        
        changeHumanoidRootPartSize(Vector3.new(4, 20, 4)) -- Adjust the size as needed

        -- Start fast attack and auto clicker
        startFastAttack()
        startAutoClicker()
        Config["FastAttack"] = true
        Config["ClickAttack"] = true
        -- Start farming sequence
        spawn(farmSequence)
    else
        isToggling = false

        changeHumanoidRootPartSize(Vector3.new(2, 2, 1)) -- Reset to the default size

        -- Stop all processes
        Config["FastAttack"] = false
        Config["ClickAttack"] = false
    end
end)

Options.MyToggle:SetValue(false)

-- Notification that the script has loaded
Fluent:Notify({
    Title = "Notification",
    Content = "Blox Fruits AutoFarm script has loaded",
    SubContent = "Enjoy!",
    Duration = 5
})

Window:SelectTab(1)
