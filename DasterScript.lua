--============================================================
-- 🏁 RACES (Автогонки)
--============================================================
local RacesPage = CreateTab("Races", "🏁", 8)

--============================================================
-- СКАНЕР ГОНОК
--============================================================
local RaceSystem = {
    ActiveRace  = nil,
    RaceActive  = false,
    Races       = {},
    Waypoints   = {},
    CurrentWp   = 1,
    Speed       = 150,
}

local function ScanRaces()
    local found = {}
    local keywords = {"race", "track", "circuit", "sprint", "cup", "championship", "tournament"}
    
    -- Ищем в Workspace и ReplicatedStorage объекты с "race" в имени
    for _, target in ipairs({Workspace, ReplicatedStorage}) do
        for _, obj in ipairs(target:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("RemoteEvent") 
            or obj:IsA("StringValue") or obj:IsA("ObjectValue") then
                local n = string.lower(obj.Name)
                for _, kw in ipairs(keywords) do
                    if string.find(n, kw) then
                        -- Избегаем дубликатов
                        local dup = false
                        for _, r in ipairs(found) do
                            if r.Name == obj.Name then dup = true; break end
                        end
                        if not dup then
                            table.insert(found, obj)
                        end
                        break
                    end
                end
            end
        end
    end
    return found
end

--============================================================
-- ПОИСК ЧЕКПОИНТОВ
--============================================================
local function FindWaypoints()
    local wps = {}
    local wpKeywords = {"checkpoint", "waypoint", "gate", "node", "marker", "flag", "ring"}
    
    -- Ищем в Workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local n = string.lower(obj.Name)
            for _, kw in ipairs(wpKeywords) do
                if string.find(n, kw) then
                    local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                    if part then
                        table.insert(wps, {
                            obj = obj,
                            part = part,
                            pos = part.Position,
                            name = obj.Name,
                        })
                    end
                    break
                end
            end
        end
    end
    
    -- Сортируем по расстоянию от старта (первого найденного)
    if #wps > 0 then
        table.sort(wps, function(a, b)
            return a.name < b.name -- по алфавиту (обычно CP1, CP2, CP3...)
        end)
    end
    return wps
end

--============================================================
-- АВТО-ВОЖДЕНИЕ К ЧЕКПОИНТУ
--============================================================
local function DriveTo(targetPos)
    local char = Utils.GetChar()
    if not char then return false end
    
    local veh = char:FindFirstChildWhichIsA("VehicleSeat")
    if not veh or not veh.Parent then return false end
    
    local carModel = veh.Parent
    local chassis = carModel:FindFirstChildWhichIsA("BasePart")
    if not chassis then
        for _, p in ipairs(carModel:GetDescendants()) do
            if p:IsA("BasePart") and p.Name:lower():find("chassis") 
            or p.Name:lower():find("body") or p.Name:lower():find("root") then
                chassis = p
                break
            end
        end
    end
    if not chassis then return false end
    
    -- Направление к цели
    local dir = (targetPos - chassis.Position)
    local dist = dir.Magnitude
    dir = dir.Unit
    
    -- Управление через VehicleSeat (Throttle/Steer)
    local forward = chassis.CFrame.LookVector
    local right = chassis.CFrame.RightVector
    
    local dotForward = forward:Dot(dir)
    local dotRight = right:Dot(dir)
    
    -- Throttle (газ)
    local throttle = 1
    if dist < 10 then throttle = 0
    elseif dotForward < 0 then throttle = 1 -- разворот
    else throttle = math.clamp(dotForward * 2, -1, 1) end
    
    -- Steer (поворот)
    local steer = math.clamp(dotRight * 2, -1, 1)
    
    pcall(function()
        veh.ThrottleFloat = throttle
        veh.SteerFloat = steer
    end)
    
    return dist < 15 -- достигли чекпоинта
end

--============================================================
-- ОСНОВНОЙ ЦИКЛ ГОНКИ
--============================================================
local function StartRace(raceName)
    RaceSystem.RaceActive = true
    RaceSystem.ActiveRace = raceName
    RaceSystem.Waypoints = FindWaypoints()
    RaceSystem.CurrentWp = 1
    
    if #RaceSystem.Waypoints == 0 then
        Utils.Notify("⚠ Чекпоинты не найдены! Гонка не запущена.", 4, Config.Theme.Error)
        RaceSystem.RaceActive = false
        return
    end
    
    Utils.Notify("🏁 Гонка '" .. raceName .. "' запущена! Чекпоинтов: " .. #RaceSystem.Waypoints, 4, Config.Theme.Success)
    
    -- Проверяем что игрок в машине
    local char = Utils.GetChar()
    local veh = char and char:FindFirstChildWhichIsA("VehicleSeat")
    if not veh then
        Utils.Notify("⚠ Сядь в машину перед гонкой!", 4, Config.Theme.Error)
        RaceSystem.RaceActive = false
        return
    end
    
    -- Основной цикл вождения
    task.spawn(function()
        while RaceSystem.RaceActive do
            local wp = RaceSystem.Waypoints[RaceSystem.CurrentWp]
            if not wp or not wp.part or not wp.part.Parent then
                -- Все чекпоинты пройдены
                Utils.Notify("🏆 ФИНИШ! Гонка завершена!", 5, Config.Theme.Success)
                RaceSystem.RaceActive = false
                break
            end
            
            local reached = DriveTo(wp.pos)
            
            if reached then
                Utils.Notify("✅ Чекпоинт " .. RaceSystem.CurrentWp .. "/" .. #RaceSystem.Waypoints, 1.5, Config.Theme.Money)
                RaceSystem.CurrentWp = RaceSystem.CurrentWp + 1
            end
            
            task.wait(0.05)
        end
    end)
end

local function StopRace()
    RaceSystem.RaceActive = false
    RaceSystem.ActiveRace = nil
    
    -- Останавливаем машину
    local char = Utils.GetChar()
    if char then
        local veh = char:FindFirstChildWhichIsA("VehicleSeat")
        if veh then
            pcall(function()
                veh.ThrottleFloat = 0
                veh.SteerFloat = 0
            end)
        end
    end
    
    Utils.Notify("⏹ Гонка остановлена", 3, Config.Theme.Error)
end

--============================================================
-- UI ВКЛАДКИ
--============================================================
CreateSection(RacesPage, "🏁 Список гонок")
CreateLabel(RacesPage, "Нажми 'Обновить', чтобы найти все гонки на карте", Color3.fromRGB(255, 200, 100))

local raceListFrame = Utils.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 180),
    BackgroundColor3 = Color3.fromRGB(30, 0, 0),
    BorderSizePixel = 0, ZIndex = 3, Parent = RacesPage,
})
Utils.Corner(raceListFrame, 7)
Utils.Stroke(raceListFrame, Config.Theme.Accent, 1, 0.7)

local raceScroll = Utils.Create("ScrollingFrame", {
    Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5),
    BackgroundTransparency = 1, BorderSizePixel = 0,
    ScrollBarThickness = 4, ScrollBarImageColor3 = Config.Theme.Accent,
    CanvasSize = UDim2.new(0, 0, 0, 0), ZIndex = 4, Parent = raceListFrame,
})
Utils.Create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 4), Parent = raceScroll,
})

-- Обновление списка
local function RefreshRaceList()
    -- Очистка
    for _, c in ipairs(raceScroll:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    
    local races = ScanRaces()
    RaceSystem.Races = races
    
    if #races == 0 then
        Utils.Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Text = "Гонки не найдены. Возможно, они в другом месте.",
            TextColor3 = Config.Theme.TextDim,
            Font = Enum.Font.Gotham, TextSize = 11,
            TextWrapped = true, LayoutOrder = 1,
            ZIndex = 5, Parent = raceScroll,
        })
        return
    end
    
    for i, race in ipairs(races) do
        local row = Utils.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Color3.fromRGB(60, 0, 0),
            BorderSizePixel = 0, LayoutOrder = i,
            ZIndex = 5, Parent = raceScroll,
        })
        Utils.Corner(row, 6)
        Utils.Stroke(row, Config.Theme.Accent, 1, 0.7)
        
        Utils.Create("TextLabel", {
            Size = UDim2.new(1, -110, 1, 0), Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1, Text = race.Name,
            TextColor3 = Config.Theme.Text, Font = Enum.Font.GothamSemibold,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 6, Parent = row,
        })
        
        local startBtn = Utils.Create("TextButton", {
            Size = UDim2.new(0, 90, 0, 24), Position = UDim2.new(1, -95, 0.5, -12),
            BackgroundColor3 = Config.Theme.Accent,
            Text = "▶ Включить",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold, TextSize = 11,
            ZIndex = 6, Parent = row,
        })
        Utils.Corner(startBtn, 6)
        Utils.Stroke(startBtn, Color3.fromRGB(255, 100, 100), 1, 0.5)
        
        startBtn.MouseButton1Click:Connect(function()
            StartRace(race.Name)
        end)
    end
end

CreateButton(RacesPage, "🔄 Обновить список гонок", function()
    RefreshRaceList()
    Utils.Notify("Найдено гонок: " .. #RaceSystem.Races, 3)
end)

CreateButton(RacesPage, "🔍 Найти все чекпоинты (Waypoints)", function()
    local wps = FindWaypoints()
    RaceSystem.Waypoints = wps
    Utils.Notify("Найдено чекпоинтов: " .. #wps, 4)
    for i, wp in ipairs(wps) do
        if i > 10 then break end
        print("[DasterRace] WP " .. i .. ": " .. wp.name .. " @ " .. tostring(wp.pos))
    end
end)

CreateSection(RacesPage, "🎮 Управление")
CreateToggle(RacesPage, "🏁 АВТО-ГОНКА (включить)", function(state)
    if state then
        if not RaceSystem.ActiveRace then
            -- Если гонка не выбрана — берём первую
            if #RaceSystem.Races > 0 then
                StartRace(RaceSystem.Races[1].Name)
            else
                Utils.Notify("Сначала выбери гонку в списке!", 3, Config.Theme.Error)
            end
        else
            StartRace(RaceSystem.ActiveRace)
        end
    else
        StopRace()
    end
end)

CreateButton(RacesPage, "⏹ Стоп гонка", function()
    StopRace()
end, Color3.fromRGB(150, 0, 0))

CreateSection(RacesPage, "⚙ Настройки гонки")

-- Скорость
local speedFrame = Utils.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 46),
    BackgroundColor3 = Color3.fromRGB(60, 0, 0),
    BorderSizePixel = 0, ZIndex = 3, Parent = RacesPage,
})
Utils.Corner(speedFrame, 7)
Utils.Stroke(speedFrame, Config.Theme.Accent, 1, 0.7)

Utils.Create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 3),
    BackgroundTransparency = 1, Text = "⚡ Скорость машины (Throttle)",
    TextColor3 = Config.Theme.Text, Font = Enum.Font.GothamSemibold,
    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4, Parent = speedFrame,
})

local speedValLbl = Utils.Create("TextLabel", {
    Size = UDim2.new(0, 60, 0, 20), Position = UDim2.new(1, -70, 0, 3),
    BackgroundTransparency = 1, Text = "1.0",
    TextColor3 = Config.Theme.AccentGlow, Font = Enum.Font.GothamBold,
    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = 4, Parent = speedFrame,
})

local speedBar = Utils.Create("Frame", {
    Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 28),
    BackgroundColor3 = Color3.fromRGB(30, 0, 0), BorderSizePixel = 0,
    ZIndex = 4, Parent = speedFrame,
})
Utils.Corner(speedBar, 3)

local speedFill = Utils.Create("Frame", {
    Size = UDim2.new(0.5, 0, 1, 0), BackgroundColor3 = Config.Theme.Accent,
    BorderSizePixel = 0, ZIndex = 5, Parent = speedBar,
})
Utils.Corner(speedFill, 3)

local speedDrag = false
speedBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then speedDrag = true end
end)
speedBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then speedDrag = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if speedDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local rel = math.clamp((input.Position.X - speedBar.AbsolutePosition.X) / speedBar.AbsoluteSize.X, 0, 1)
        local val = math.floor(rel * 300)
        speedFill.Size = UDim2.new(rel, 0, 1, 0)
        speedValLbl.Text = tostring(val)
        RaceSystem.Speed = val / 100
    end
end)

-- Телепорт к старту
CreateSection(RacesPage, "🚗 Авто-посадка в машину")
CreateButton(RacesPage, "🚗 Найти машину рядом и сесть", function()
    local _, hrp = Utils.GetChar()
    if not hrp then return end
    local closest, dist = nil, 30
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") and obj.Parent then
            local d = (obj.Position - hrp.Position).Magnitude
            if d < dist then dist = d; closest = obj end
        end
    end
    if closest then
        local _, _, hum = Utils.GetChar()
        if hum then
            closest:Sit(hum)
            Utils.Notify("Сел в машину: " .. closest.Parent.Name, 2)
        end
    else
        Utils.Notify("Машина поблизости не найдена", 2, Config.Theme.Error)
    end
end)

CreateButton(RacesPage, "🚗 Притянуть ближайшую машину + сесть", function()
    local _, hrp = Utils.GetChar()
    if not hrp then return end
    local closest, dist = nil, 100
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") and obj.Parent then
            local d = (obj.Position - hrp.Position).Magnitude
            if d < dist then dist = d; closest = obj end
        end
    end
    if closest then
        pcall(function()
            local model = closest.Parent
            local pp = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            if pp then model:PivotTo(hrp.CFrame + Vector3.new(0, 3, 0)) end
        end)
        task.wait(0.3)
        local _, _, hum = Utils.GetChar()
        if hum then closest:Sit(hum) end
        Utils.Notify("Машина притянута и ты сел", 2)
    end
end)

--============================================================
-- СТАТУС ГОНКИ
--============================================================
CreateSection(RacesPage, "📊 Статус")
local raceStatus = CreateLabel(RacesPage, "🏁 Гонка: не активна", Config.Theme.TextDim)
local wpStatus = CreateLabel(RacesPage, "📍 Чекпоинт: -/-", Config.Theme.TextDim)
task.spawn(function()
    while raceStatus.Parent do
        pcall(function()
            if RaceSystem.RaceActive then
                raceStatus.Text = "🏁 Гонка: " .. (RaceSystem.ActiveRace or "?") .. " (АКТИВНА)"
                raceStatus.TextColor3 = Config.Theme.Success
            else
                raceStatus.Text = "🏁 Гонка: не активна"
                raceStatus.TextColor3 = Config.Theme.TextDim
            end
            wpStatus.Text = "📍 Чекпоинт: " .. RaceSystem.CurrentWp .. "/" .. #RaceSystem.Waypoints
        end)
        task.wait(0.5)
    end
end)
