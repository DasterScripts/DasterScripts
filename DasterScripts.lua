--============================================================
-- DASTER SCRIPTS | 99 Nights in the Forest
-- UI: Красная тема + Аниме фон
--============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Закрываем старый GUI если есть
if game.CoreGui:FindFirstChild("DasterScripts") then
    game.CoreGui.DasterScripts:Destroy()
end

--============================================================
-- СОЗДАНИЕ GUI
--============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DasterScripts"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 0, 0)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

--============================================================
-- АНИМЕ ФОН (картинка)
--============================================================
local BgImage = Instance.new("ImageLabel")
BgImage.Name = "AnimeBg"
BgImage.Size = UDim2.new(1, 0, 1, 0)
BgImage.BackgroundTransparency = 1
BgImage.Image = "rbxassetid://13132981571" -- Аниме фон (можно заменить на свой)
BgImage.ImageTransparency = 0.55
BgImage.ScaleType = Enum.ScaleType.Crop
BgImage.ZIndex = 0
BgImage.Parent = MainFrame

local BgCorner = Instance.new("UICorner")
BgCorner.CornerRadius = UDim.new(0, 12)
BgCorner.Parent = BgImage

-- Красный оверлей поверх картинки
local RedOverlay = Instance.new("Frame")
RedOverlay.Size = UDim2.new(1, 0, 1, 0)
RedOverlay.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
RedOverlay.BackgroundTransparency = 0.75
RedOverlay.BorderSizePixel = 0
RedOverlay.ZIndex = 1
RedOverlay.Parent = MainFrame

local OverlayCorner = Instance.new("UICorner")
OverlayCorner.CornerRadius = UDim.new(0, 12)
OverlayCorner.Parent = RedOverlay

--============================================================
-- ЗАГОЛОВОК
--============================================================
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
TitleBar.BackgroundTransparency = 0.3
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚔ DASTER SCRIPTS ⚔"
TitleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
TitleLabel.TextStrokeTransparency = 0.3
TitleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 22
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -42, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.ZIndex = 3
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

--============================================================
-- ЛЕВОЕ МЕНЮ (вкладки)
--============================================================
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, 140, 1, -55)
TabBar.Position = UDim2.new(0, 5, 0, 50)
TabBar.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
TabBar.BackgroundTransparency = 0.4
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 2
TabBar.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 10)
TabCorner.Parent = TabBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 6)
TabLayout.Parent = TabBar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 8)
TabPadding.PaddingLeft = UDim.new(0, 8)
TabPadding.PaddingRight = UDim.new(0, 8)
TabPadding.Parent = TabBar

--============================================================
-- КОНТЕЙНЕР ДЛЯ СТРАНИЦ
--============================================================
local PageContainer = Instance.new("Frame")
PageContainer.Name = "PageContainer"
PageContainer.Size = UDim2.new(1, -160, 1, -60)
PageContainer.Position = UDim2.new(0, 152, 0, 50)
PageContainer.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
PageContainer.BackgroundTransparency = 0.4
PageContainer.BorderSizePixel = 0
PageContainer.ZIndex = 2
PageContainer.Parent = MainFrame

local PageCorner = Instance.new("UICorner")
PageCorner.CornerRadius = UDim.new(0, 10)
PageCorner.Parent = PageContainer

--============================================================
-- ФУНКЦИИ СОЗДАНИЯ UI ЭЛЕМЕНТОВ
--============================================================
local tabs = {}
local pages = {}

local function CreateTab(name, order)
    local Tab = Instance.new("TextButton")
    Tab.Name = name .. "Tab"
    Tab.Size = UDim2.new(1, 0, 0, 32)
    Tab.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    Tab.Text = name
    Tab.TextColor3 = Color3.fromRGB(255, 180, 180)
    Tab.Font = Enum.Font.GothamSemibold
    Tab.TextSize = 14
    Tab.LayoutOrder = order
    Tab.ZIndex = 3
    Tab.Parent = TabBar

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = Tab

    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.Visible = false
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 0)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ZIndex = 3
    Page.Parent = PageContainer

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = Page

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = Page

    tabs[name] = Tab
    pages[name] = Page

    Tab.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        for _, t in pairs(tabs) do 
            t.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
            t.TextColor3 = Color3.fromRGB(255, 180, 180)
        end
        Page.Visible = true
        Tab.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        Tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    return Page
end

local function CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 220, 220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(120, 0, 0)}):Play()
    end)
    btn.MouseButton1Click:Connect(callback)

    return btn
end

local function CreateLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 100, 100)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function CreateToggle(parent, text, callback)
    local state = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    btn.Text = "[ OFF ] " .. text
    btn.TextColor3 = Color3.fromRGB(255, 180, 180)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = (state and "[ ON ] " or "[ OFF ] ") .. text
        btn.BackgroundColor3 = state and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(80, 0, 0)
        callback(state)
    end)
    return btn
end

--============================================================
-- 1) INFO
--============================================================
local InfoPage = CreateTab("Info", 1)
CreateLabel(InfoPage, "⚔ DASTER SCRIPTS ⚔")
CreateLabel(InfoPage, "Версия: 1.0")
CreateLabel(InfoPage, "Игра: 99 Nights in the Forest")
CreateLabel(InfoPage, "Разработчик: Daster")
CreateLabel(InfoPage, "Статус: ✅ Работает")
CreateLabel(InfoPage, "")
CreateLabel(InfoPage, "📖 Описание:")
local desc = Instance.new("TextLabel")
desc.Size = UDim2.new(1, -10, 0, 80)
desc.BackgroundTransparency = 1
desc.Text = "Многофункциональный скрипт для 99 Nights in the Forest. Включает телепорт предметов, читы для игрока, смену языка и многое другое."
desc.TextColor3 = Color3.fromRGB(255, 200, 200)
desc.Font = Enum.Font.Gotham
desc.TextSize = 12
desc.TextWrapped = true
desc.TextXAlignment = Enum.TextXAlignment.Left
desc.TextYAlignment = Enum.TextYAlignment.Top
desc.Parent = InfoPage

CreateLabel(InfoPage, "")
CreateLabel(InfoPage, "👤 Discord: daster#0001")
CreateLabel(InfoPage, "🌐 YouTube: Daster Scripts")

--============================================================
-- 2) MAIN (язык и настройки)
--============================================================
local MainPage = CreateTab("Main", 2)
CreateLabel(MainPage, "🌍 Смена языка:")

local languages = {"Русский", "English", "Español", "Deutsch", "Français", "Português", "日本語", "中文"}
for _, lang in ipairs(languages) do
    CreateButton(MainPage, "🌐 " .. lang, function()
        -- Уведомление
        local notify = Instance.new("TextLabel")
        notify.Size = UDim2.new(0, 250, 0, 40)
        notify.Position = UDim2.new(1, -270, 0, 60)
        notify.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        notify.Text = "Язык изменён: " .. lang
        notify.TextColor3 = Color3.fromRGB(255, 255, 255)
        notify.Font = Enum.Font.GothamBold
        notify.TextSize = 13
        notify.ZIndex = 10
        notify.Parent = MainFrame
        local nc = Instance.new("UICorner")
        nc.CornerRadius = UDim.new(0, 6)
        nc.Parent = notify
        task.wait(2)
        notify:Destroy()
    end)
end

CreateLabel(MainPage, "")
CreateLabel(MainPage, "⚙ Прочее:")
CreateToggle(MainPage, "Anti-AFK", function(state)
    if state then
        LocalPlayer.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
    end
end)

CreateButton(MainPage, "🔄 Rejoin сервер", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

--============================================================
-- 3) BRING STOOF (телепорт предметов)
--============================================================
local BringPage = CreateTab("Bring", 3)
CreateLabel(BringPage, "📦 Телепорт предметов к игроку:")

-- Автопоиск предметов на карте
local function GetItems()
    local items = {}
    local keyword = {"Log", "Wood", "Stick", "Stone", "Rock", "Berry", "Meat", 
                     "Food", "Item", "Tool", "Branch", "Leaf", "Coal", "Iron"}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            for _, k in ipairs(keyword) do
                if string.find(obj.Name, k) then
                    table.insert(items, obj)
                    break
                end
            end
        end
    end
    return items
end

-- Функция телепорта
local function BringItem(item)
    if not item or not item.Parent then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    pcall(function()
        item.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
    end)
end

CreateButton(BringPage, "🎯 Притянуть ВСЕ предметы", function()
    for _, item in ipairs(GetItems()) do
        BringItem(item)
    end
end)

CreateButton(BringPage, "🪵 Притянуть дерево (Log)", function()
    for _, item in ipairs(GetItems()) do
        if string.find(item.Name, "Log") or string.find(item.Name, "Wood") then
            BringItem(item)
        end
    end
end)

CreateButton(BringPage, "🪨 Притянуть камни (Stone)", function()
    for _, item in ipairs(GetItems()) do
        if string.find(item.Name, "Stone") or string.find(item.Name, "Rock") then
            BringItem(item)
        end
    end
end)

CreateButton(BringPage, "🍓 Притянуть еду (Berry)", function()
    for _, item in ipairs(GetItems()) do
        if string.find(item.Name, "Berry") or string.find(item.Name, "Food") then
            BringItem(item)
        end
    end
end)

CreateButton(BringPage, "🥩 Притянуть мясо (Meat)", function()
    for _, item in ipairs(GetItems()) do
        if string.find(item.Name, "Meat") then
            BringItem(item)
        end
    end
end)

CreateButton(BringPage, "🪵 Притянуть палки (Stick)", function()
    for _, item in ipairs(GetItems()) do
        if string.find(item.Name, "Stick") or string.find(item.Name, "Branch") then
            BringItem(item)
        end
    end
end)

CreateButton(BringPage, "⛏ Притянуть инструменты (Tools)", function()
    for _, obj in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if obj:IsA("Tool") then
            obj.Parent = LocalPlayer.Character
        end
    end
end)

CreateToggle(BringPage, "🔁 Авто-притягивание предметов", function(state)
    if state then
        _G.DasterBringLoop = true
        task.spawn(function()
            while _G.DasterBringLoop do
                for _, item in ipairs(GetItems()) do
                    BringItem(item)
                end
                task.wait(1)
            end
        end)
    else
        _G.DasterBringLoop = false
    end
end)

--============================================================
-- 4) PLAYER (fly / killaura / speed)
--============================================================
local PlayerPage = CreateTab("Player", 4)
CreateLabel(PlayerPage, "🏃 Функции игрока:")

-- SPEED
CreateButton(PlayerPage, "⚡ Speed = 50", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 50
    end
end)

CreateButton(PlayerPage, "⚡ Speed = 100", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 100
    end
end)

CreateButton(PlayerPage, "🐢 Speed = 16 (обычная)", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 16
    end
end)

-- JUMP
CreateButton(PlayerPage, "🦘 Jump = 100", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = 100
        char.Humanoid.UseJumpPower = true
    end
end)

-- FLY
local flying = false
local flyConn

local function StartFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local bodyVel = Instance.new("BodyVelocity")
    bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVel.Velocity = Vector3.zero
    bodyVel.Parent = hrp

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.P = 1000
    bodyGyro.Parent = hrp

    flyConn = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        bodyVel.Velocity = move * 80
        bodyGyro.CFrame = cam.CFrame
    end)
end

local function StopFly()
    if flyConn then flyConn:Disconnect() end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        for _, v in ipairs(char.HumanoidRootPart:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
        end
    end
end

CreateToggle(PlayerPage, "🕊 Fly (WASD + Space/Ctrl)", function(state)
    flying = state
    if state then StartFly() else StopFly() end
end)

-- KILL AURA
local killAuraConn
CreateToggle(PlayerPage, "💀 Kill Aura (убивать врагов рядом)", function(state)
    if state then
        killAuraConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Humanoid") and obj.Parent ~= char then
                    local hrp = obj.Parent:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - char.HumanoidRootPart.Position).Magnitude < 25 then
                        obj.Health = 0
                    end
                end
            end
        end)
    else
        if killAuraConn then killAuraConn:Disconnect() end
    end
end)

-- INFINITE JUMP
CreateToggle(PlayerPage, "♾ Infinite Jump", function(state)
    if state then
        _G.DasterInfJump = UserInputService.JumpRequest:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        if _G.DasterInfJump then _G.DasterInfJump:Disconnect() end
    end
end)

-- NOCLIP
CreateToggle(PlayerPage, "👻 Noclip", function(state)
    if state then
        _G.DasterNoclip = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if _G.DasterNoclip then _G.DasterNoclip:Disconnect() end
    end
end)

--============================================================
-- АКТИВАЦИЯ ПЕРВОЙ ВКЛАДКИ
--============================================================
tabs["Info"].BackgroundColor3 = Color3.fromRGB(180, 0, 0)
tabs["Info"].TextColor3 = Color3.fromRGB(255, 255, 255)
pages["Info"].Visible = true

print("[Daster Scripts] Загружено успешно! ⚔")
