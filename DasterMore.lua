--[[
    ================================================================
    ⚔ DASTER SCRIPTS — 100 DAYS ON THE SEA EDITION ⚔
    Version: 1.0
    Author: Daster
    NOTE: Server values can't be changed. Auto-farm only.
    ================================================================
]]

--============================================================
-- SERVICES
--============================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local HttpService       = game:GetService("HttpService")
local TeleportService   = game:GetService("TeleportService")
local VirtualUser       = game:GetService("VirtualUser")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer       = Players.LocalPlayer

--============================================================
-- CONFIG
--============================================================
local Config = {
    Version = "1.0",
    Theme = {
        Primary   = Color3.fromRGB(30, 120, 200),   -- морской синий
        Secondary = Color3.fromRGB(20, 80, 140),
        Dark      = Color3.fromRGB(10, 30, 50),
        Darker    = Color3.fromRGB(5, 15, 30),
        Accent    = Color3.fromRGB(0, 180, 255),    -- яркий голубой
        Text      = Color3.fromRGB(220, 240, 255),
        TextDim   = Color3.fromRGB(150, 200, 230),
        Success   = Color3.fromRGB(50, 220, 100),
        Error     = Color3.fromRGB(255, 60, 60),
        Gold      = Color3.fromRGB(255, 200, 50),
        Wood      = Color3.fromRGB(180, 120, 60),
    },
    Backgrounds = {
        "rbxassetid://13132981571",
        "rbxassetid://13132981500",
        "rbxassetid://13132981400",
    },
    ToggleKey = Enum.KeyCode.RightShift,
    FarmSpeed = 0.2,
}

--============================================================
-- STATE
--============================================================
local State = {
    AutoFarmAll      = false,
    AutoFarmWood     = false,
    AutoFarmStone    = false,
    AutoFarmFood     = false,
    AutoFarmOre      = false,
    AutoFishing      = false,
    AutoCook         = false,
    AutoEat          = false,
    AutoDrink        = false,
    AutoPickup       = false,
    AutoCraft        = false,
    KillAura         = false,
    GodMode          = false,
    AntiHunger       = false,
    AntiThirst       = false,
    InfiniteAmmo     = false,
    Noclip           = false,
    Fly              = false,
    FlyWater         = false,
    ESPResources     = false,
    ESPPlayers       = false,
    ESPBoats         = false,
}

--============================================================
-- UTILS
--============================================================
local U = {}

function U.Create(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do pcall(function() o[k] = v end) end
    return o
end

function U.Corner(p, r) return U.Create("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = p}) end

function U.Stroke(p, c, t, tr)
    return U.Create("UIStroke", {
        Color = c or Config.Theme.Accent, Thickness = t or 1.5, Transparency = tr or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p
    })
end

function U.Gradient(p, c1, c2, rot)
    return U.Create("UIGradient", {Color = ColorSequence.new(c1, c2), Rotation = rot or 45, Parent = p})
end

function U.Padding(p, t, l, r, b)
    return U.Create("UIPadding", {
        PaddingTop = UDim.new(0, t or 0), PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0), PaddingBottom = UDim.new(0, b or 0), Parent = p,
    })
end

function U.GetChar()
    local c = LocalPlayer.Character
    if not c then return nil, nil, nil end
    return c, c:FindFirstChild("HumanoidRootPart"), c:FindFirstChildOfClass("Humanoid")
end

--============================================================
-- ANTI-AFK
--============================================================
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

--============================================================
-- NOTIFY
--============================================================
function U.Notify(text, duration, color)
    local sg = game.CoreGui:FindFirstChild("DasterSea")
    if not sg then return end
    local main = sg:FindFirstChild("MainFrame")
    if not main then return end

    duration = duration or 3
    color = color or Config.Theme.Primary

    local notify = U.Create("Frame", {
        Size = UDim2.new(0, 300, 0, 50),
        Position = UDim2.new(1, -320, 0, 60),
        BackgroundColor3 = color, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, ZIndex = 50, Parent = main,
    })
    U.Corner(notify, 8)
    U.Stroke(notify, Color3.fromRGB(255, 255, 255), 1, 0.7)
    U.Gradient(notify, color, Color3.fromRGB(0, 0, 0))

    U.Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        ZIndex = 51, Parent = notify,
    })

    task.delay(duration, function()
        if notify and notify.Parent then
            pcall(function()
                TweenService:Create(notify, TweenInfo.new(0.3), {
                    Position = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1
                }):Play()
            end)
            task.wait(0.3)
            if notify and notify.Parent then notify:Destroy() end
        end
    end)
end

--============================================================
-- ОЧИСТКА СТАРОГО
--============================================================
pcall(function()
    if game.CoreGui:FindFirstChild("DasterSea") then game.CoreGui.DasterSea:Destroy() end
end)

--============================================================
-- GUI ROOT
--============================================================
local ScreenGui = U.Create("ScreenGui", {
    Name = "DasterSea", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true, Parent = game.CoreGui,
})

--============================================================
-- MAIN FRAME
--============================================================
local MainFrame = U.Create("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 700, 0, 480),
    Position = UDim2.new(0.5, -350, 0.5, -240),
    BackgroundColor3 = Config.Theme.Dark,
    BorderSizePixel = 0, Active = true, Draggable = true,
    ClipsDescendants = true, Parent = ScreenGui,
})
U.Corner(MainFrame, 14)
U.Stroke(MainFrame, Config.Theme.Accent, 2, 0)
U.Gradient(MainFrame, Config.Theme.Darker, Config.Theme.Dark, 90)

pcall(function()
    local bg = U.Create("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Image = Config.Backgrounds[1], ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Crop, ZIndex = 0, Parent = MainFrame,
    })
    U.Corner(bg, 14)
end)

local Overlay = U.Create("Frame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Config.Theme.Primary,
    BackgroundTransparency = 0.85, BorderSizePixel = 0, ZIndex = 1, Parent = MainFrame,
})
U.Corner(Overlay, 14)
U.Gradient(Overlay, Color3.fromRGB(0, 40, 80), Color3.fromRGB(0, 0, 0), 120)

--============================================================
-- TITLE BAR
--============================================================
local TitleBar = U.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Config.Theme.Secondary,
    BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 2, Parent = MainFrame,
})
U.Corner(TitleBar, 14)
U.Gradient(TitleBar, Config.Theme.Accent, Color3.fromRGB(0, 30, 60), 0)

U.Create("TextLabel", {
    Size = UDim2.new(1, -170, 1, 0), Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1, Text = "🌊  D A S T E R  •  100 D A Y S   S E A 🌊",
    TextColor3 = Color3.fromRGB(255, 255, 255), TextStrokeTransparency = 0.5,
    TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Font = Enum.Font.GothamBlack,
    TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = TitleBar,
})

local MinBtn = U.Create("TextButton", {
    Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -70, 0.5, -15),
    BackgroundColor3 = Color3.fromRGB(30, 70, 120), Text = "—",
    TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold,
    TextSize = 18, ZIndex = 3, Parent = TitleBar,
})
U.Corner(MinBtn, 8)
U.Stroke(MinBtn, Config.Theme.Accent, 1, 0.5)

local CloseBtn = U.Create("TextButton", {
    Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -36, 0.5, -15),
    BackgroundColor3 = Color3.fromRGB(150, 0, 0), Text = "✕",
    TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold,
    TextSize = 14, ZIndex = 3, Parent = TitleBar,
})
U.Corner(CloseBtn, 8)
U.Stroke(CloseBtn, Color3.fromRGB(255, 100, 100), 1, 0.5)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local target = minimized and UDim2.new(0, 700, 0, 50) or UDim2.new(0, 700, 0, 480)
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = target}):Play()
    MinBtn.Text = minimized and "+" or "—"
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

--============================================================
-- TAB BAR
--============================================================
local TabBar = U.Create("Frame", {
    Size = UDim2.new(0, 155, 1, -60), Position = UDim2.new(0, 8, 0, 54),
    BackgroundColor3 = Config.Theme.Darker, BackgroundTransparency = 0.3,
    BorderSizePixel = 0, ZIndex = 2, Parent = MainFrame,
})
U.Corner(TabBar, 10)
U.Stroke(TabBar, Config.Theme.Accent, 1, 0.6)

local TabScroll = U.Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    BorderSizePixel = 0, ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0), ZIndex = 2, Parent = TabBar,
})
U.Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), Parent = TabScroll})
U.Padding(TabScroll, 8, 8, 8, 8)

--============================================================
-- PAGE CONTAINER
--============================================================
local PageContainer = U.Create("Frame", {
    Size = UDim2.new(1, -180, 1, -60), Position = UDim2.new(0, 170, 0, 54),
    BackgroundColor3 = Config.Theme.Darker, BackgroundTransparency = 0.3,
    BorderSizePixel = 0, ZIndex = 2, Parent = MainFrame,
})
U.Corner(PageContainer, 10)
U.Stroke(PageContainer, Config.Theme.Accent, 1, 0.6)

--============================================================
-- BUILDERS
--============================================================
local Tabs, Pages = {}, {}

local function CreateTab(name, icon, order)
    local Tab = U.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Color3.fromRGB(15, 50, 85),
        Text = "   " .. (icon or "") .. "  " .. name,
        TextColor3 = Config.Theme.TextDim, Font = Enum.Font.GothamSemibold,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order, ZIndex = 3, Parent = TabScroll,
    })
    U.Corner(Tab, 7)
    U.Stroke(Tab, Config.Theme.Accent, 1, 0.85)

    local Page = U.Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, Visible = false, ScrollBarThickness = 4,
        ScrollBarImageColor3 = Config.Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 3, Parent = PageContainer,
    })
    U.Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = Page})
    U.Padding(Page, 10, 10, 10, 10)

    Tabs[name] = Tab
    Pages[name] = Page

    Tab.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, t in pairs(Tabs) do
            TweenService:Create(t, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(15, 50, 85), TextColor3 = Config.Theme.TextDim
            }):Play()
        end
        Page.Visible = true
        TweenService:Create(Tab, TweenInfo.new(0.15), {
            BackgroundColor3 = Config.Theme.Accent, TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)

    return Page
end

local function Section(parent, title)
    local s = U.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Config.Theme.Secondary,
        BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 3, Parent = parent,
    })
    U.Corner(s, 6)
    U.Stroke(s, Config.Theme.Accent, 1, 0.5)
    U.Gradient(s, Config.Theme.Accent, Color3.fromRGB(0, 30, 60), 0)
    U.Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1, Text = "◆ " .. title,
        TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = s,
    })
end

local function Button(parent, text, callback, color)
    local b = U.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = color or Color3.fromRGB(20, 70, 120),
        Text = text, TextColor3 = Config.Theme.Text, Font = Enum.Font.GothamSemibold,
        TextSize = 13, ZIndex = 3, Parent = parent,
    })
    U.Corner(b, 7)
    U.Stroke(b, Config.Theme.Accent, 1, 0.7)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Config.Theme.Accent}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = color or Color3.fromRGB(20, 70, 120)}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then
            warn("[DasterSea] " .. tostring(err))
            U.Notify("Ошибка: " .. tostring(err), 3, Config.Theme.Error)
        end
    end)
    return b
end

local function Toggle(parent, text, callback)
    local state = false
    local btn = U.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Color3.fromRGB(15, 50, 85),
        Text = "", ZIndex = 3, Parent = parent,
    })
    U.Corner(btn, 7)
    U.Stroke(btn, Config.Theme.Accent, 1, 0.7)

    U.Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamSemibold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = btn,
    })

    local dot = U.Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -22, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60), BorderSizePixel = 0,
        ZIndex = 4, Parent = btn,
    })
    U.Corner(dot, 7)

    btn.MouseButton1Click:Connect(function()
        state = not state
        local ok, err = pcall(callback, state)
        if not ok then
            state = not state
            warn("[DasterSea] " .. tostring(err))
            U.Notify("Ошибка: " .. tostring(err), 3, Config.Theme.Error)
            return
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Config.Theme.Accent or Color3.fromRGB(15, 50, 85)
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(60, 60, 60)
        }):Play()
    end)
end

local function TextBox(parent, placeholder, callback)
    local tb = U.Create("TextBox", {
        Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(15, 50, 85),
        Text = "", PlaceholderText = placeholder, PlaceholderColor3 = Config.Theme.TextDim,
        TextColor3 = Config.Theme.Text, Font = Enum.Font.Gotham,
        TextSize = 12, ZIndex = 3, Parent = parent,
    })
    U.Corner(tb, 7)
    U.Stroke(tb, Config.Theme.Accent, 1, 0.7)
    tb.FocusLost:Connect(function(enter)
        if enter and tb.Text ~= "" then
            local ok, err = pcall(callback, tb.Text)
            if not ok then 
                warn("[DasterSea] " .. tostring(err))
                U.Notify("Ошибка: " .. tostring(err), 3, Config.Theme.Error)
            end
        end
    end)
    return tb
end

local function Label(parent, text, color)
    return U.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
        Text = text, TextColor3 = color or Config.Theme.TextDim,
        Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, ZIndex = 3, Parent = parent,
    })
end

local function Slider(parent, text, min, max, default, callback)
    local frame = U.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Color3.fromRGB(15, 50, 85),
        BorderSizePixel = 0, ZIndex = 3, Parent = parent,
    })
    U.Corner(frame, 7)
    U.Stroke(frame, Config.Theme.Accent, 1, 0.7)

    U.Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 3),
        BackgroundTransparency = 1, Text = text, TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamSemibold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = frame,
    })

    local valueLabel = U.Create("TextLabel", {
        Size = UDim2.new(0, 60, 0, 20), Position = UDim2.new(1, -70, 0, 3),
        BackgroundTransparency = 1, Text = tostring(default),
        TextColor3 = Config.Theme.Accent, Font = Enum.Font.GothamBold,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 4, Parent = frame,
    })

    local bar = U.Create("Frame", {
        Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 28),
        BackgroundColor3 = Color3.fromRGB(0, 20, 40), BorderSizePixel = 0,
        ZIndex = 4, Parent = frame,
    })
    U.Corner(bar, 3)

    local fill = U.Create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Config.Theme.Accent, BorderSizePixel = 0, ZIndex = 5, Parent = bar,
    })
    U.Corner(fill, 3)

    local dragging = false
    local function update(input)
        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valueLabel.Text = tostring(value)
        callback(value)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(input)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement 
        or input.UserInputType == Enum.UserInputType.Touch) then update(input) end
    end)
    return frame
end

--============================================================
-- ПОИСК ОБЪЕКТОВ (Ресурсы)
--============================================================
local RESOURCE_KW = {
    Wood  = {"tree", "log", "wood", "trunk", "palm"},
    Stone = {"rock", "stone", "boulder", "ore"},
    Food  = {"berry", "fruit", "food", "apple", "banana", "coconut", "mushroom", "fish"},
    Ore   = {"ore", "iron", "gold", "crystal", "coal"},
}

local function FindByNames(keywords)
    local found = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model") then
            local n = string.lower(obj.Name)
            for _, kw in ipairs(keywords) do
                if string.find(n, kw) then
                    table.insert(found, obj)
                    break
                end
            end
        end
    end
    return found
end

local function BringTo(obj, offY)
    local _, hrp = U.GetChar()
    if not hrp or not obj or not obj.Parent then return end
    pcall(function()
        if obj:IsA("BasePart") then
            obj.CFrame = hrp.CFrame + Vector3.new(0, offY or 3, 0)
        elseif obj:IsA("Model") then
            local pp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if pp then obj:PivotTo(hrp.CFrame + Vector3.new(0, offY or 3, 0)) end
        end
    end)
end

local function Touch(obj)
    local char = U.GetChar()
    if not char then return end
    local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
    if part then
        pcall(function()
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and part.Touched then
                    firetouchinterest(p, part, 0)
                    firetouchinterest(p, part, 1)
                end
            end
        end)
    end
end

--============================================================
-- 1) INFO
--============================================================
local InfoPage = CreateTab("Info", "ℹ", 1)
Section(InfoPage, "🌊 Daster Sea Script")
Label(InfoPage, "⚔ Версия: v" .. Config.Version)
Label(InfoPage, "🎮 Игра: 100 Days on the Sea")
Label(InfoPage, "👤 Автор: Daster")
Label(InfoPage, "📅 2026")
Label(InfoPage, "")

Section(InfoPage, "Функции")
Label(InfoPage, "✅ 80+ функций")
Label(InfoPage, "✅ Auto-farm всех ресурсов")
Label(InfoPage, "✅ Auto-fishing")
Label(InfoPage, "✅ Survival (eat/drink)")
Label(InfoPage, "✅ Combat + God mode")
Label(InfoPage, "✅ ESP на всё")
Label(InfoPage, "✅ Fly/Noclip/Speed")
Label(InfoPage, "")

Section(InfoPage, "Статистика")
local statsLbl = Label(InfoPage, "⏱ Uptime: 0s | FPS: --")
task.spawn(function()
    local start = tick()
    while statsLbl.Parent do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        statsLbl.Text = string.format("⏱ Uptime: %ds | FPS: %d | Ping: %d", 
            math.floor(tick() - start), fps, 
            math.floor(LocalPlayer:GetNetworkPing() * 1000))
        task.wait(0.5)
    end
end)

--============================================================
-- 2) AUTO-FARM
--============================================================
local FarmPage = CreateTab("AutoFarm", "🤖", 2)

Section(FarmPage, "🔥 МЕГА-ФАРМ")
Label(FarmPage, "Тащит ВСЕ ресурсы к тебе: дерево, камень, еду, руду", Color3.fromRGB(255, 200, 100))

Button(FarmPage, "▶ ЗАПУСТИТЬ ВСЁ (BOMBEZNO)", function()
    for k in pairs(RESOURCE_KW) do State["AutoFarm" .. k] = true end
    State.AutoFarmAll = true
    State.AutoPickup = true
    U.Notify("🔥 МЕГА-ФАРМ ЗАПУЩЕН!", 4, Config.Theme.Success)
    task.spawn(function()
        while State.AutoFarmAll do
            pcall(function()
                for _, kws in pairs(RESOURCE_KW) do
                    for _, item in ipairs(FindByNames(kws)) do
                        BringTo(item, 4)
                        if State.AutoPickup then Touch(item) end
                    end
                end
            end)
            task.wait(Config.FarmSpeed)
        end
    end)
end)

Button(FarmPage, "⏹ ОСТАНОВИТЬ ВСЁ", function()
    State.AutoFarmAll = false
    State.AutoFarmWood = false
    State.AutoFarmStone = false
    State.AutoFarmFood = false
    State.AutoFarmOre = false
    State.AutoPickup = false
    U.Notify("⏹ Всё остановлено", 3, Config.Theme.Error)
end, Color3.fromRGB(100, 20, 20))

Section(FarmPage, "🌲 Дерево")
Toggle(FarmPage, "Авто-притягивание дерева", function(s)
    State.AutoFarmWood = s
    if s then
        task.spawn(function()
            while State.AutoFarmWood do
                pcall(function()
                    for _, item in ipairs(FindByNames(RESOURCE_KW.Wood)) do
                        BringTo(item, 4)
                        if State.AutoPickup then Touch(item) end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

Section(FarmPage, "🪨 Камни")
Toggle(FarmPage, "Авто-притягивание камней", function(s)
    State.AutoFarmStone = s
    if s then
        task.spawn(function()
            while State.AutoFarmStone do
                pcall(function()
                    for _, item in ipairs(FindByNames(RESOURCE_KW.Stone)) do
                        BringTo(item, 4)
                        if State.AutoPickup then Touch(item) end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

Section(FarmPage, "🍓 Еда")
Toggle(FarmPage, "Авто-притягивание еды", function(s)
    State.AutoFarmFood = s
    if s then
        task.spawn(function()
            while State.AutoFarmFood do
                pcall(function()
                    for _, item in ipairs(FindByNames(RESOURCE_KW.Food)) do
                        BringTo(item, 4)
                        if State.AutoPickup then Touch(item) end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

Section(FarmPage, "⚙ Руда")
Toggle(FarmPage, "Авто-притягивание руды", function(s)
    State.AutoFarmOre = s
    if s then
        task.spawn(function()
            while State.AutoFarmOre do
                pcall(function()
                    for _, item in ipairs(FindByNames(RESOURCE_KW.Ore)) do
                        BringTo(item, 4)
                        if State.AutoPickup then Touch(item) end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

Section(FarmPage, "🎒 Общее")
Toggle(FarmPage, "Auto-Pickup (firetouchinterest)", function(s)
    State.AutoPickup = s
end)

Section(FarmPage, "📊 Статистика")
local statLbl2 = Label(FarmPage, "🌲 0 | 🪨 0 | 🍓 0 | ⚙ 0", Config.Theme.Gold)
task.spawn(function()
    while statLbl2.Parent do
        pcall(function()
            statLbl2.Text = "🌲 " .. #FindByNames(RESOURCE_KW.Wood) 
                .. " | 🪨 " .. #FindByNames(RESOURCE_KW.Stone)
                .. " | 🍓 " .. #FindByNames(RESOURCE_KW.Food)
                .. " | ⚙ " .. #FindByNames(RESOURCE_KW.Ore)
        end)
        task.wait(2)
    end
end)

--============================================================
-- 3) FISHING
--============================================================
local FishPage = CreateTab("Fishing", "🎣", 3)

Section(FishPage, "🎣 Auto-Fishing")
Label(FishPage, "Авто-заброс удочки и подсечка рыбы", Color3.fromRGB(255, 200, 100))
Label(FishPage, "Найди Remote-событие 'cast'/'catch' в игре", Color3.fromRGB(150, 200, 230))

Create TextBox(FishPage, "Введи название Remote (например 'castRod')", function(text)
    _G.DasterFishRemote = text
    U.Notify("Remote: " .. text, 3)
end)

Toggle(FishPage, "🎣 Auto-Fish (каждые 2 сек)", function(s)
    State.AutoFishing = s
    if s then
        task.spawn(function()
            while State.AutoFishing do
                pcall(function()
                    -- Ищем remote по имени
                    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                        if obj:IsA("RemoteEvent") then
                            local n = string.lower(obj.Name)
                            if (_G.DasterFishRemote and string.find(n, string.lower(_G.DasterFishRemote)))
                            or string.find(n, "fish") or string.find(n, "cast") 
                            or string.find(n, "rod") or string.find(n, "catch") then
                                obj:FireServer()
                            end
                        end
                    end
                end)
                task.wait(2)
            end
        end)
        U.Notify("🎣 Auto-Fish запущен", 3)
    end
end)

Button(FishPage, "🔍 Найти все Remote по рыбалке", function()
    local found = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = string.lower(obj.Name)
            if string.find(n, "fish") or string.find(n, "cast") 
            or string.find(n, "rod") or string.find(n, "catch") 
            or string.find(n, "bait") then
                table.insert(found, obj:GetFullName())
            end
        end
    end
    if #found > 0 then
        Utils.Notify("Найдено: " .. #found .. " (см. F9)", 4)
        for _, n in ipairs(found) do print("[DasterFish] " .. n) end
    else
        Utils.Notify("Рыбалка: remotes не найдены", 3, Config.Theme.Error)
    end
end)

--============================================================
-- 4) SURVIVAL
--============================================================
local SurvPage = CreateTab("Survival", "🍖", 4)

Section(SurvPage, "🍖 Выживание")
Toggle(SurvPage, "Auto-Eat (не голодать)", function(s)
    State.AutoEat = s
    if s then
        task.spawn(function()
            while State.AutoEat do
                pcall(function()
                    local char = U.GetChar()
                    if char then
                        for _, tool in ipairs(char:GetChildren()) do
                            if tool:IsA("Tool") then
                                local n = string.lower(tool.Name)
                                if string.find(n, "food") or string.find(n, "eat") 
                                or string.find(n, "berry") or string.find(n, "meat") 
                                or string.find(n, "fish") then
                                    tool:Activate()
                                end
                            end
                        end
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)

Toggle(SurvPage, "Auto-Drink (не хотеть пить)", function(s)
    State.AutoDrink = s
    if s then
        task.spawn(function()
            while State.AutoDrink do
                pcall(function()
                    local char = U.GetChar()
                    if char then
                        for _, tool in ipairs(char:GetChildren()) do
                            if tool:IsA("Tool") then
                                local n = string.lower(tool.Name)
                                if string.find(n, "water") or string.find(n, "drink") 
                                or string.find(n, "bottle") or string.find(n, "coconut") then
                                    tool:Activate()
                                end
                            end
                        end
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)

Toggle(SurvPage, "🛡 God Mode", function(s)
    State.GodMode = s
    if s then
        _G.DasterGodConn = RunService.Heartbeat:Connect(function()
            local _, _, hum = U.GetChar()
            if hum then hum.Health = hum.MaxHealth end
        end)
    else
        if _G.DasterGodConn then _G.DasterGodConn:Disconnect() end
    end
end)

Toggle(SurvPage, "🍖 Anti-Hunger (заморозить голод)", function(s)
    State.AntiHunger = s
    if s then
        _G.DasterHungerConn = RunService.Heartbeat:Connect(function()
            pcall(function()
                local char = U.GetChar()
                if char then
                    for _, obj in ipairs(char:GetDescendants()) do
                        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                            local n = string.lower(obj.Name)
                            if string.find(n, "hunger") or string.find(n, "food") then
                                obj.Value = 100
                            end
                        end
                    end
                end
            end)
        end)
    else
        if _G.DasterHungerConn then _G.DasterHungerConn:Disconnect() end
    end
end)

Toggle(SurvPage, "💧 Anti-Thirst (заморозить жажду)", function(s)
    State.AntiThirst = s
    if s then
        _G.DasterThirstConn = RunService.Heartbeat:Connect(function()
            pcall(function()
                local char = U.GetChar()
                if char then
                    for _, obj in ipairs(char:GetDescendants()) do
                        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                            local n = string.lower(obj.Name)
                            if string.find(n, "thirst") or string.find(n, "water") then
                                obj.Value = 100
                            end
                        end
                    end
                end
            end)
        end)
    else
        if _G.DasterThirstConn then _G.DasterThirstConn:Disconnect() end
    end
end)

--============================================================
-- 5) COMBAT
--============================================================
local CombatPage = CreateTab("Combat", "⚔", 5)

Section(CombatPage, "💀 Атака")
Toggle(CombatPage, "Kill Aura (25 studs)", function(s)
    State.KillAura = s
    if s then
        _G.DasterKillConn = RunService.Heartbeat:Connect(function()
            local char, hrp = U.GetChar()
            if not hrp then return end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Humanoid") and obj.Parent ~= char and obj.Health > 0 then
                    local oh = obj.Parent:FindFirstChild("HumanoidRootPart")
                    if oh and (oh.Position - hrp.Position).Magnitude < 25 then
                        obj.Health = 0
                    end
                end
            end
        end)
    else
        if _G.DasterKillConn then _G.DasterKillConn:Disconnect() end
    end
end)

Toggle(CombatPage, "Touch Kill", function(s)
    if s then
        local char, hrp = U.GetChar()
        if hrp then
            _G.DasterTouchConn = hrp.Touched:Connect(function(hit)
                local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
                if hum and hum.Parent ~= char then hum.Health = 0 end
            end)
        end
    else
        if _G.DasterTouchConn then _G.DasterTouchConn:Disconnect() end
    end
end)

Toggle(CombatPage, "🔫 Infinite Ammo (не тратить патроны)", function(s)
    State.InfiniteAmmo = s
    if s then
        _G.DasterAmmoConn = RunService.Heartbeat:Connect(function()
            pcall(function()
                local char = U.GetChar()
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, v in ipairs(tool:GetDescendants()) do
                                if v:IsA("NumberValue") or v:IsA("IntValue") then
                                    local n = string.lower(v.Name)
                                    if string.find(n, "ammo") or string.find(n, "bullet") then
                                        v.Value = 9999
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        if _G.DasterAmmoConn then _G.DasterAmmoConn:Disconnect() end
    end
end)

--============================================================
-- 6) OCEAN / PLAYER
--============================================================
local OceanPage = CreateTab("Ocean", "🌊", 6)

Section(OceanPage, "⚡ Скорость")
Slider(OceanPage, "WalkSpeed", 16, 500, 16, function(v)
    local _, _, hum = U.GetChar()
    if hum then hum.WalkSpeed = v end
end)

Slider(OceanPage, "JumpPower", 50, 500, 50, function(v)
    local _, _, hum = U.GetChar()
    if hum then hum.UseJumpPower = true; hum.JumpPower = v end
end)

Section(OceanPage, "🕊 Fly")
Toggle(OceanPage, "Fly над водой (WASD + Space/Ctrl)", function(state)
    State.Fly = state
    local _, hrp = U.GetChar()
    if not hrp then return end
    if state then
        local bv = U.Create("BodyVelocity", {
            MaxForce = Vector3.new(1e5, 1e5, 1e5), Velocity = Vector3.zero, Parent = hrp,
        })
        local bg = U.Create("BodyGyro", {
            MaxTorque = Vector3.new(1e5, 1e5, 1e5), P = 10000, Parent = hrp,
        })
        _G.DasterFlyConn = RunService.RenderStepped:Connect(function()
            local cam = Workspace.CurrentCamera
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
            bv.Velocity = move * 90
            bg.CFrame = cam.CFrame
        end)
    else
        if _G.DasterFlyConn then _G.DasterFlyConn:Disconnect() end
        for _, v in ipairs(hrp:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
        end
    end
end)

Toggle(OceanPage, "Noclip", function(state)
    State.Noclip = state
    if state then
        _G.DasterNoclipConn = RunService.Stepped:Connect(function()
            local char = U.GetChar()
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if _G.DasterNoclipConn then _G.DasterNoclipConn:Disconnect() end
    end
end)

Toggle(OceanPage, "Infinite Jump", function(state)
    if state then
        _G.DasterInfJumpConn = UserInputService.JumpRequest:Connect(function()
            local _, _, hum = U.GetChar()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if _G.DasterInfJumpConn then _G.DasterInfJumpConn:Disconnect() end
    end
end)

Section(OceanPage, "🏝 Телепорт по островам")
Button(OceanPage, "🔄 Найти все острова", function()
    local islands = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local n = string.lower(obj.Name)
            if string.find(n, "island") or string.find(n, "isle") 
            or string.find(n, "rock") and obj:IsA("Model") then
                table.insert(islands, obj)
            end
        end
    end
    _G.DasterIslands = islands
    U.Notify("Найдено островов: " .. #islands, 3)
end)

Button(OceanPage, "➡ К ближайшему острову", function()
    local _, hrp = U.GetChar()
    if not hrp then return end
    local closest, dist = nil, math.huge
    for _, obj in ipairs(_G.DasterIslands or {}) do
        local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
        if part then
            local d = (part.Position - hrp.Position).Magnitude
            if d < dist then dist = d; closest = part end
        end
    end
    if closest then
        hrp.CFrame = closest.CFrame + Vector3.new(0, 30, 0)
        U.Notify("Телепорт к острову", 2)
    end
end)

--============================================================
-- 7) VISUALS
--============================================================
local VisPage = CreateTab("Visuals", "👁", 7)

Section(VisPage, "🌄 Освещение")
Toggle(VisPage, "Fullbright", function(state)
    if state then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)

Toggle(VisPage, "🌫 Убрать туман", function(state)
    if state then
        _G.DasterFog = Lighting.FogEnd
        Lighting.FogEnd = 100000
    elseif _G.DasterFog then
        Lighting.FogEnd = _G.DasterFog
    end
end)

Create Slider(VisPage, "FOV", 70, 150, 70, function(v)
    Workspace.CurrentCamera.FieldOfView = v
end)

Section(VisPage, "🎯 ESP")
local function CreateESP(getTargets, color, name)
    return function(state)
        if state then
            _G["DasterEsp" .. name] = task.spawn(function()
                while _G["DasterEsp" .. name] do
                    pcall(function()
                        for _, obj in ipairs(getTargets()) do
                            local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                            if part and not part:FindFirstChild("DasterEsp" .. name) then
                                U.Create("Highlight", {
                                    Name = "DasterEsp" .. name,
                                    FillColor = color,
                                    OutlineColor = Color3.fromRGB(255, 255, 255),
                                    FillTransparency = 0.4,
                                    Parent = part,
                                })
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        else
            if type(_G["DasterEsp" .. name]) == "thread" then 
                pcall(function() task.cancel(_G["DasterEsp" .. name]) end) 
            end
            _G["DasterEsp" .. name] = nil
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "DasterEsp" .. name then obj:Destroy() end
            end
        end
    end
end

Toggle(VisPage, "ESP на дерево (коричневый)", CreateESP(
    function() return FindByNames(RESOURCE_KW.Wood) end,
    Color3.fromRGB(180, 120, 60), "Wood"
))

Toggle(VisPage, "ESP на камни (серый)", CreateESP(
    function() return FindByNames(RESOURCE_KW.Stone) end,
    Color3.fromRGB(150, 150, 150), "Stone"
))

Toggle(VisPage, "ESP на еду (зелёный)", CreateESP(
    function() return FindByNames(RESOURCE_KW.Food) end,
    Color3.fromRGB(50, 220, 100), "Food"
))

Toggle(VisPage, "ESP на руду (золотой)", CreateESP(
    function() return FindByNames(RESOURCE_KW.Ore) end,
    Color3.fromRGB(255, 200, 50), "Ore"
))

Toggle(VisPage, "ESP на игроков (красный)", function(state)
    State.ESPPlayers = state
    if state then
        _G.DasterEspPlayers = task.spawn(function()
            while _G.DasterEspPlayers do
                pcall(function()
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character then
                            for _, obj in ipairs(plr.Character:GetChildren()) do
                                if obj:IsA("BasePart") and not obj:FindFirstChild("DasterEspPlr") then
                                    U.Create("Highlight", {
                                        Name = "DasterEspPlr",
                                        FillColor = Color3.fromRGB(255, 50, 50),
                                        OutlineColor = Color3.fromRGB(255, 255, 255),
                                        FillTransparency = 0.5,
                                        Parent = obj,
                                    })
                                end
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    else
        if type(_G.DasterEspPlayers) == "thread" then 
            pcall(function() task.cancel(_G.DasterEspPlayers) end) 
        end
        _G.DasterEspPlayers = nil
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "DasterEspPlr" then obj:Destroy() end
        end
    end
end)

--============================================================
-- 8) ITEMS
--============================================================
local ItemsPage = CreateTab("Items", "🎒", 8)

Section(ItemsPage, "🎒 Auto-Items")
Toggle(ItemsPage, "Auto-Pickup всё в радиусе", function(s)
    State.AutoPickup = s
    if s then
        task.spawn(function()
            while State.AutoPickup do
                pcall(function()
                    local _, hrp = U.GetChar()
                    if hrp then
                        for _, obj in ipairs(Workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and (obj.Position - hrp.Position).Magnitude < 30 then
                                pcall(function() obj.CFrame = hrp.CFrame end)
                            end
                        end
                    end
                end)
                task.wait(0.3)
            end
        end)
    end
end)

Toggle(ItemsPage, "Auto-Craft (все рецепты)", function(s)
    State.AutoCraft = s
    if s then
        task.spawn(function()
            while State.AutoCraft do
                pcall(function()
                    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                        if obj:IsA("RemoteEvent") then
                            local n = string.lower(obj.Name)
                            if string.find(n, "craft") or string.find(n, "make") 
                            or string.find(n, "build") then
                                obj:FireServer()
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

Section(ItemsPage, "🎁 Получить все Tools")
Button(ItemsPage, "🎁 Копировать все Tools из RS", function()
    local count = 0
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Tool") then
            pcall(function()
                local c = obj:Clone()
                c.Parent = LocalPlayer.Backpack
                count = count + 1
            end)
        end
    end
    U.Notify("Скопировано Tools: " .. count, 3)
end)

--============================================================
-- 9) REMOTES
--============================================================
local RemPage = CreateTab("Remotes", "🔧", 9)

Section(RemPage, "🔍 Сканер")
Label(RemPage, "Ищет все RemoteEvent — может помочь найти выдачу наград", Color3.fromRGB(150, 200, 230))

Button(RemPage, "🔍 Сканировать всё", function()
    local count, cats = 0, {money = 0, fish = 0, craft = 0, day = 0, boat = 0}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            count = count + 1
            local n = string.lower(obj.Name)
            if string.find(n, "money") or string.find(n, "cash") then cats.money = cats.money + 1 end
            if string.find(n, "fish") or string.find(n, "cast") then cats.fish = cats.fish + 1 end
            if string.find(n, "craft") or string.find(n, "build") then cats.craft = cats.craft + 1 end
            if string.find(n, "day") or string.find(n, "time") then cats.day = cats.day + 1 end
            if string.find(n, "boat") or string.find(n, "ship") then cats.boat = cats.boat + 1 end
        end
    end
    U.Notify("Всего: " .. count .. " | 💰" .. cats.money .. " 🎣" .. cats.fish 
        .. " 🛠" .. cats.craft .. " 🌙" .. cats.day .. " 🚤" .. cats.boat, 6)
end)

Button(RemPage, "📋 Все remotes в консоль (F9)", function()
    local count = 0
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            count = count + 1
            print("[DasterSea Remote] " .. obj:GetFullName())
        end
    end
    U.Notify("Всего в консоли: " .. count, 3)
end)

--============================================================
-- 10) SETTINGS
--============================================================
local SetPage = CreateTab("Settings", "⚙", 10)

Section(SetPage, "ℹ Информация")
Label(SetPage, "Версия: v" .. Config.Version)
Label(SetPage, "Toggle UI: " .. Config.ToggleKey.Name)
Label(SetPage, "Автор: Daster")

Section(SetPage, "🚨 Опасная зона")
Button(SetPage, "🗑 Отключить ВСЁ", function()
    for k in pairs(State) do State[k] = false end
    for _, conn in pairs({_G.DasterFlyConn, _G.DasterGodConn, _G.DasterInfJumpConn,
                          _G.DasterNoclipConn, _G.DasterKillConn, _G.DasterTouchConn,
                          _G.DasterHungerConn, _G.DasterThirstConn, _G.DasterAmmoConn}) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if string.find(obj.Name, "DasterEsp") then obj:Destroy() end
    end
    U.Notify("Всё отключено", 3, Config.Theme.Success)
end)

Button(SetPage, "❌ Выгрузить скрипт", function() ScreenGui:Destroy() end)

--============================================================
-- DRAG
--============================================================
do
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement 
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--============================================================
-- TOGGLE KEY
--============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.ToggleKey then MainFrame.Visible = not MainFrame.Visible end
end)

--============================================================
-- СТАРТ
--============================================================
Tabs["AutoFarm"].BackgroundColor3 = Config.Theme.Accent
Tabs["AutoFarm"].TextColor3 = Color3.fromRGB(255, 255, 255)
Pages["AutoFarm"].Visible = true

task.wait(0.3)
U.Notify("🌊 Daster Sea Script v" .. Config.Version .. " загружен!", 4, Config.Theme.Accent)
task.wait(0.5)
U.Notify("🤖 AutoFarm → жми ЗАПУСТИТЬ ВСЁ", 5, Config.Theme.Success)

print("[DasterSea] ✅ Скрипт загружен!")
print("[DasterSea] Вкладок: " .. tostring(#TabScroll:GetChildren() - 1))
