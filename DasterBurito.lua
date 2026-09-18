--[[
    ================================================================
    ⚔ DASTER SCRIPTS — DRILL TO THE CORE EDITION ⚔
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
        Primary   = Color3.fromRGB(120, 60, 20),    -- земляной коричневый
        Secondary = Color3.fromRGB(80, 40, 10),
        Dark      = Color3.fromRGB(30, 15, 5),
        Darker    = Color3.fromRGB(15, 8, 2),
        Accent    = Color3.fromRGB(255, 140, 30),   -- оранжевый (лава)
        AccentGlow= Color3.fromRGB(255, 200, 80),
        Text      = Color3.fromRGB(255, 240, 220),
        TextDim   = Color3.fromRGB(255, 200, 150),
        Success   = Color3.fromRGB(50, 220, 100),
        Error     = Color3.fromRGB(255, 60, 60),
        Gold      = Color3.fromRGB(255, 215, 0),
        Diamond   = Color3.fromRGB(100, 220, 255),
        Lava      = Color3.fromRGB(255, 80, 20),
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
    AutoMineAll      = false,
    AutoMineOre      = false,
    AutoSell         = false,
    AutoUpgrade      = false,
    AutoRepair       = false,
    AutoCollect      = false,
    DrillSpeedBoost  = false,
    KillAura         = false,
    GodMode          = false,
    Noclip           = false,
    Fly              = false,
    InfiniteJump     = false,
    InfiniteOre      = false,
    ESPOre           = false,
    ESPPlayers       = false,
    ESPLayers        = false,
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
    local sg = game.CoreGui:FindFirstChild("DasterCore")
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
-- ОЧИСТКА
--============================================================
pcall(function()
    if game.CoreGui:FindFirstChild("DasterCore") then game.CoreGui.DasterCore:Destroy() end
end)

--============================================================
-- SCREEN GUI
--============================================================
local ScreenGui = U.Create("ScreenGui", {
    Name = "DasterCore", ResetOnSpawn = false,
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
U.Gradient(Overlay, Color3.fromRGB(60, 30, 10), Color3.fromRGB(0, 0, 0), 120)

--============================================================
-- TITLE BAR
--============================================================
local TitleBar = U.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Config.Theme.Secondary,
    BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 2, Parent = MainFrame,
})
U.Corner(TitleBar, 14)
U.Gradient(TitleBar, Config.Theme.Accent, Color3.fromRGB(40, 15, 0), 0)

U.Create("TextLabel", {
    Size = UDim2.new(1, -170, 1, 0), Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1, Text = "⛏  D A S T E R  •  D R I L L   C O R E  ⛏",
    TextColor3 = Color3.fromRGB(255, 255, 255), TextStrokeTransparency = 0.5,
    TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Font = Enum.Font.GothamBlack,
    TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = TitleBar,
})

local MinBtn = U.Create("TextButton", {
    Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -70, 0.5, -15),
    BackgroundColor3 = Color3.fromRGB(80, 40, 10), Text = "—",
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
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Color3.fromRGB(60, 30, 10),
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
                BackgroundColor3 = Color3.fromRGB(60, 30, 10), TextColor3 = Config.Theme.TextDim
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
    U.Gradient(s, Config.Theme.Accent, Color3.fromRGB(40, 15, 0), 0)
    U.Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1, Text = "◆ " .. title,
        TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = s,
    })
end

local function Button(parent, text, callback, color)
    local b = U.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = color or Color3.fromRGB(80, 40, 10),
        Text = text, TextColor3 = Config.Theme.Text, Font = Enum.Font.GothamSemibold,
        TextSize = 13, ZIndex = 3, Parent = parent,
    })
    U.Corner(b, 7)
    U.Stroke(b, Config.Theme.Accent, 1, 0.7)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Config.Theme.Accent}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = color or Color3.fromRGB(80, 40, 10)}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then
            warn("[DasterCore] " .. tostring(err))
            U.Notify("Ошибка: " .. tostring(err), 3, Config.Theme.Error)
        end
    end)
    return b
end

local function Toggle(parent, text, callback)
    local state = false
    local btn = U.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Color3.fromRGB(60, 30, 10),
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
            warn("[DasterCore] " .. tostring(err))
            U.Notify("Ошибка: " .. tostring(err), 3, Config.Theme.Error)
            return
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Config.Theme.Accent or Color3.fromRGB(60, 30, 10)
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(60, 60, 60)
        }):Play()
    end)
end

local function TextBox(parent, placeholder, callback)
    local tb = U.Create("TextBox", {
        Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(60, 30, 10),
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
                warn("[DasterCore] " .. tostring(err))
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
        Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = Color3.fromRGB(60, 30, 10),
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
        TextColor3 = Config.Theme.AccentGlow, Font = Enum.Font.GothamBold,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 4, Parent = frame,
    })

    local bar = U.Create("Frame", {
        Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 28),
        BackgroundColor3 = Color3.fromRGB(20, 10, 0), BorderSizePixel = 0,
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
-- ПОИСК ОБЪЕКТОВ (Руда)
--============================================================
local ORE_KW = {
    Stone   = {"stone", "rock", "boulder"},
    Coal    = {"coal"},
    Iron    = {"iron", "ore_iron"},
    Gold    = {"gold", "ore_gold"},
    Diamond = {"diamond", "crystal"},
    Ruby    = {"ruby", "red"},
    Emerald = {"emerald", "green"},
    Ore     = {"ore", "mineral", "gem", "crystal"},
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
            obj.CFrame = hrp.CFrame + Vector3.new(0, offY or 4, 0)
        elseif obj:IsA("Model") then
            local pp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if pp then obj:PivotTo(hrp.CFrame + Vector3.new(0, offY or 4, 0)) end
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
Section(InfoPage, "⛏ Daster Drill Script")
Label(InfoPage, "⚔ Версия: v" .. Config.Version)
Label(InfoPage, "🎮 Игра: Бурите к ядру Земли")
Label(InfoPage, "👤 Автор: Daster")
Label(InfoPage, "📅 2026")
Label(InfoPage, "")

Section(InfoPage, "Функции")
Label(InfoPage, "✅ 70+ функций")
Label(InfoPage, "✅ Auto-бурение")
Label(InfoPage, "✅ Auto-сбор руды")
Label(InfoPage, "✅ Auto-продажа")
Label(InfoPage, "✅ Auto-апгрейд")
Label(InfoPage, "✅ ESP на руду")
Label(InfoPage, "✅ Speed / Fly / Noclip")
Label(InfoPage, "")

Section(InfoPage, "Статистика")
local statsLbl = Label(InfoPage, "⏱ Uptime: 0s | FPS: --")
task.spawn(function()
    local start = tick()
    while statsLbl.Parent do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        statsLbl.Text = string.format("⏱ Uptime: %ds | FPS: %d", math.floor(tick() - start), fps)
        task.wait(0.5)
    end
end)

--============================================================
-- 2) AUTO-MINE (ГЛАВНАЯ)
--============================================================
local MinePage = CreateTab("AutoMine", "⛏", 2)

Section(MinePage, "🔥 МЕГА-БУРЕНИЕ")
Label(MinePage, "Тащит ВСЮ руду к тебе + подбирает + авто-продажа", Color3.fromRGB(255, 200, 100))

Button(MinePage, "▶ ЗАПУСТИТЬ ВСЁ (BOMBEZNO)", function()
    for k in pairs(ORE_KW) do State["AutoMine" .. k] = true end
    State.AutoMineAll = true
    State.AutoCollect = true
    State.AutoSell = true
    U.Notify("🔥 МЕГА-БУРЕНИЕ ЗАПУЩЕНО!", 4, Config.Theme.Success)
    task.spawn(function()
        while State.AutoMineAll do
            pcall(function()
                for _, kws in pairs(ORE_KW) do
                    for _, item in ipairs(FindByNames(kws)) do
                        BringTo(item, 4)
                        if State.AutoCollect then Touch(item) end
                    end
                end
            end)
            task.wait(Config.FarmSpeed)
        end
    end)
end)

Button(MinePage, "⏹ ОСТАНОВИТЬ ВСЁ", function()
    State.AutoMineAll = false
    for k in pairs(ORE_KW) do State["AutoMine" .. k] = false end
    State.AutoCollect = false
    State.AutoSell = false
    U.Notify("⏹ Всё остановлено", 3, Config.Theme.Error)
end, Color3.fromRGB(100, 20, 20))

Section(MinePage, "🪨 По типам руды")

-- Кнопки и тумблеры для каждого типа
local oreColors = {
    Stone   = Color3.fromRGB(150, 150, 150),
    Coal    = Color3.fromRGB(50, 50, 50),
    Iron    = Color3.fromRGB(180, 180, 200),
    Gold    = Color3.fromRGB(255, 215, 0),
    Diamond = Color3.fromRGB(100, 220, 255),
    Ruby    = Color3.fromRGB(255, 50, 50),
    Emerald = Color3.fromRGB(50, 220, 100),
    Ore     = Color3.fromRGB(200, 150, 255),
}

for oreType, kws in pairs(ORE_KW) do
    Toggle(MinePage, "Авто: " .. oreType, function(s)
        State["AutoMine" .. oreType] = s
        if s then
            task.spawn(function()
                while State["AutoMine" .. oreType] do
                    pcall(function()
                        for _, item in ipairs(FindByNames(kws)) do
                            BringTo(item, 4)
                            if State.AutoCollect then Touch(item) end
                        end
                    end)
                    task.wait(0.3)
                end
            end)
        end
    end)
end

Section(MinePage, "🎒 Общее")
Toggle(MinePage, "Auto-Pickup (firetouchinterest)", function(s)
    State.AutoCollect = s
end)

Section(MinePage, "📊 Статистика")
local oreStats = Label(MinePage, "Загрузка...", Config.Theme.Gold)
task.spawn(function()
    while oreStats.Parent do
        pcall(function()
            local total = 0
            local text = ""
            for oreType, kws in pairs(ORE_KW) do
                local count = #FindByNames(kws)
                total = total + count
                text = text .. oreType .. ": " .. count .. " | "
            end
            oreStats.Text = "Всего: " .. total .. "\n" .. text
        end)
        task.wait(2)
    end
end)

--============================================================
-- 3) DRILL (Управление буром)
--============================================================
local DrillPage = CreateTab("Drill", "⚡", 3)

Section(DrillPage, "⚡ Усиление бура")
Label(DrillPage, "Ускоряет бурение через изменение параметров инструмента", Color3.fromRGB(255, 200, 100))

Toggle(DrillPage, "🚀 Ускорить бур (x2 к скорости копания)", function(s)
    State.DrillSpeedBoost = s
    if s then
        _G.DasterDrillConn = RunService.Heartbeat:Connect(function()
            pcall(function()
                local char = U.GetChar()
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            local n = string.lower(tool.Name)
                            if string.find(n, "drill") or string.find(n, "pick") 
                            or string.find(n, "mine") or string.find(n, "shovel") then
                                -- Ускоряем анимации
                                for _, v in ipairs(tool:GetDescendants()) do
                                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                                        local vn = string.lower(v.Name)
                                        if string.find(vn, "speed") or string.find(vn, "rate") 
                                        or string.find(vn, "power") or string.find(vn, "cooldown") then
                                            v.Value = v.Value * 2
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end)
    else
        if _G.DasterDrillConn then _G.DasterDrillConn:Disconnect() end
    end
end)

Toggle(DrillPage, "🔧 Auto-Repair бура", function(s)
    State.AutoRepair = s
    if s then
        task.spawn(function()
            while State.AutoRepair do
                pcall(function()
                    local char = U.GetChar()
                    if char then
                        for _, tool in ipairs(char:GetChildren()) do
                            if tool:IsA("Tool") then
                                for _, v in ipairs(tool:GetDescendants()) do
                                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                                        local n = string.lower(v.Name)
                                        if string.find(n, "durability") or string.find(n, "health") then
                                            v.Value = 9999
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

Section(DrillPage, "🛠 Авто-апгрейд бура")
Toggle(DrillPage, "Auto-Upgrade (все апгрейды)", function(s)
    State.AutoUpgrade = s
    if s then
        task.spawn(function()
            while State.AutoUpgrade do
                pcall(function()
                    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                        if obj:IsA("RemoteEvent") then
                            local n = string.lower(obj.Name)
                            if string.find(n, "upgrade") or string.find(n, "improve") 
                            or string.find(n, "enhance") then
                                obj:FireServer()
                            end
                        end
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)

Section(DrillPage, "🎁 Получить лучший бур")
Button(DrillPage, "🎁 Копировать все Tools из RS", function()
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
-- 4) MONEY / SELL
--============================================================
local MoneyPage = CreateTab("Money", "💰", 4)

Section(MoneyPage, "💰 Авто-продажа")
Toggle(MoneyPage, "Auto-Sell всей руды", function(s)
    State.AutoSell = s
    if s then
        task.spawn(function()
            while State.AutoSell do
                pcall(function()
                    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                        if obj:IsA("RemoteEvent") then
                            local n = string.lower(obj.Name)
                            if string.find(n, "sell") or string.find(n, "trade") 
                            or string.find(n, "shop") then
                                obj:FireServer()
                            end
                        end
                    end
                end)
                task.wait(2)
            end
        end)
        U.Notify("Auto-Sell запущен", 3)
    end
end)

Button(MoneyPage, "💰 Продать ВСЁ сейчас", function()
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local n = string.lower(obj.Name)
            if string.find(n, "sell") or string.find(n, "trade") 
            or string.find(n, "shop") then
                pcall(function() obj:FireServer() end)
            end
        end
    end
    U.Notify("Продажа отправлена", 2)
end)

Section(MoneyPage, "🎯 Remote-атака на деньги")
TextBox(MoneyPage, "Сколько денег добавить?", function(text)
    local num = tonumber(text)
    if not num then U.Notify("Введи число!", 2, Config.Theme.Error); return end
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local n = string.lower(obj.Name)
            if string.find(n, "money") or string.find(n, "cash") 
            or string.find(n, "reward") or string.find(n, "add") then
                pcall(function() obj:FireServer(num) end)
            end
        end
    end
    U.Notify("Отправлено на " .. num, 3)
end)

Button(MoneyPage, "🔍 Сканировать remotes", function()
    local money, sell, upgrade = 0, 0, 0
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local n = string.lower(obj.Name)
            if string.find(n, "money") or string.find(n, "cash") then money = money + 1 end
            if string.find(n, "sell") or string.find(n, "shop") then sell = sell + 1 end
            if string.find(n, "upgrade") or string.find(n, "improve") then upgrade = upgrade + 1 end
        end
    end
    U.Notify("💰" .. money .. " | 🛒" .. sell .. " | ⬆" .. upgrade, 5)
end)

--============================================================
-- 5) PLAYER
--============================================================
local PlayerPage = CreateTab("Player", "🏃", 5)

Section(PlayerPage, "⚡ Скорость")
Slider(PlayerPage, "WalkSpeed", 16, 500, 16, function(v)
    local _, _, hum = U.GetChar()
    if hum then hum.WalkSpeed = v end
end)

Slider(PlayerPage, "JumpPower", 50, 500, 50, function(v)
    local _, _, hum = U.GetChar()
    if hum then hum.UseJumpPower = true; hum.JumpPower = v end
end)

Button(PlayerPage, "🐢 Сбросить (Speed 16, Jump 50)", function()
    local _, _, hum = U.GetChar()
    if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
end)

Section(PlayerPage, "🕊 Fly / Noclip")
Toggle(PlayerPage, "Fly (WASD + Space/Ctrl)", function(state)
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

Toggle(PlayerPage, "Noclip", function(state)
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

Toggle(PlayerPage, "Infinite Jump", function(state)
    State.InfiniteJump = state
    if state then
        _G.DasterInfJumpConn = UserInputService.JumpRequest:Connect(function()
            local _, _, hum = U.GetChar()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if _G.DasterInfJumpConn then _G.DasterInfJumpConn:Disconnect() end
    end
end)

Section(PlayerPage, "🛡 Защита")
Toggle(PlayerPage, "God Mode", function(state)
    State.GodMode = state
    if state then
        _G.DasterGodConn = RunService.Heartbeat:Connect(function()
            local _, _, hum = U.GetChar()
            if hum then hum.Health = hum.MaxHealth end
        end)
    else
        if _G.DasterGodConn then _G.DasterGodConn:Disconnect() end
    end
end)

--============================================================
-- 6) WORLD (Teleport)
--============================================================
local WorldPage = CreateTab("World", "🌍", 6)

Section(WorldPage, "📍 Информация")
local depthLbl = Label(WorldPage, "Глубина: неизвестно", Config.Theme.Gold)
task.spawn(function()
    while depthLbl.Parent do
        pcall(function()
            local _, hrp = U.GetChar()
            if hrp then
                depthLbl.Text = "Глубина: Y = " .. math.floor(-hrp.Position.Y) .. " studs"
            end
        end)
        task.wait(0.5)
    end
end)

Section(WorldPage, "🎯 Телепорт по слоям")
for _, depth in ipairs({100, 500, 1000, 2000, 5000, 10000}) do
    Button(WorldPage, "⬇ Глубина " .. depth, function()
        local char, hrp = U.GetChar()
        if not hrp then return end
        hrp.CFrame = CFrame.new(hrp.Position.X, -depth, hrp.Position.Z)
        U.Notify("Телепорт на глубину " .. depth, 2)
    end)
end

Button(WorldPage, "⬆ На поверхность (Y = 50)", function()
    local _, hrp = U.GetChar()
    if not hrp then return end
    hrp.CFrame = CFrame.new(hrp.Position.X, 50, hrp.Position.Z)
    U.Notify("Телепорт на поверхность", 2)
end)

Section(WorldPage, "🎯 Телепорт к игрокам")
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        Button(WorldPage, "➡ К " .. p.Name, function()
            local _, hrp = U.GetChar()
            local tc = p.Character
            if hrp and tc and tc:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = tc.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end)
    end
end

--============================================================
-- 7) VISUALS
--============================================================
local VisPage = CreateTab("Visuals", "👁", 7)

Section(VisPage, "🌄 Освещение")
Toggle(VisPage, "Fullbright (видеть под землёй)", function(state)
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

Toggle(VisPage, "ESP на ЗОЛОТО (жёлтый)", CreateESP(
    function() return FindByNames(ORE_KW.Gold) end,
    Color3.fromRGB(255, 215, 0), "Gold"
))

Toggle(VisPage, "ESP на АЛМАЗЫ (голубой)", CreateESP(
    function() return FindByNames(ORE_KW.Diamond) end,
    Color3.fromRGB(100, 220, 255), "Diamond"
))

Toggle(VisPage, "ESP на РУБИНЫ (красный)", CreateESP(
    function() return FindByNames(ORE_KW.Ruby) end,
    Color3.fromRGB(255, 50, 50), "Ruby"
))

Toggle(VisPage, "ESP на ИЗУМРУДЫ (зелёный)", CreateESP(
    function() return FindByNames(ORE_KW.Emerald) end,
    Color3.fromRGB(50, 220, 100), "Emerald"
))

Toggle(VisPage, "ESP на ЖЕЛЕЗО (серый)", CreateESP(
    function() return FindByNames(ORE_KW.Iron) end,
    Color3.fromRGB(200, 200, 220), "Iron"
))

Toggle(VisPage, "ESP на ИГРОКОВ (красный)", function(state)
    State.ESPPlayers = state
    if state then
        _G.DasterEspPlr = task.spawn(function()
            while _G.DasterEspPlr do
                pcall(function()
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character then
                            for _, obj in ipairs(plr.Character:GetChildren()) do
                                if obj:IsA("BasePart") and not obj:FindFirstChild("DasterEspP") then
                                    U.Create("Highlight", {
                                        Name = "DasterEspP",
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
        if type(_G.DasterEspPlr) == "thread" then 
            pcall(function() task.cancel(_G.DasterEspPlr) end) 
        end
        _G.DasterEspPlr = nil
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "DasterEspP" then obj:Destroy() end
        end
    end
end)

--============================================================
-- 8) REMOTES
--============================================================
local RemPage = CreateTab("Remotes", "🔧", 8)

Section(RemPage, "🔍 Сканер")
Label(RemPage, "Ищет все RemoteEvent — деньги, продажа, апгрейды", Color3.fromRGB(255, 200, 150))

Button(RemPage, "🔍 Сканировать всё", function()
    local count, cats = 0, {money = 0, sell = 0, upgrade = 0, mine = 0, drill = 0}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            count = count + 1
            local n = string.lower(obj.Name)
            if string.find(n, "money") or string.find(n, "cash") then cats.money = cats.money + 1 end
            if string.find(n, "sell") or string.find(n, "shop") then cats.sell = cats.sell + 1 end
            if string.find(n, "upgrade") or string.find(n, "improve") then cats.upgrade = cats.upgrade + 1 end
            if string.find(n, "mine") or string.find(n, "dig") or string.find(n, "break") then cats.mine = cats.mine + 1 end
            if string.find(n, "drill") or string.find(n, "tool") then cats.drill = cats.drill + 1 end
        end
    end
    U.Notify("Всего: " .. count .. " | 💰" .. cats.money .. " 🛒" .. cats.sell 
        .. " ⬆" .. cats.upgrade .. " ⛏" .. cats.mine .. " 🔧" .. cats.drill, 6)
end)

Button(RemPage, "📋 Все remotes в консоль (F9)", function()
    local count = 0
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            count = count + 1
            print("[DasterCore Remote] " .. obj:GetFullName())
        end
    end
    U.Notify("Всего в консоли: " .. count, 3)
end)

--============================================================
-- 9) SETTINGS
--============================================================
local SetPage = CreateTab("Settings", "⚙", 9)

Section(SetPage, "ℹ Информация")
Label(SetPage, "Версия: v" .. Config.Version)
Label(SetPage, "Toggle UI: " .. Config.ToggleKey.Name)
Label(SetPage, "Автор: Daster")

Section(SetPage, "🚨 Опасная зона")
Button(SetPage, "🗑 Отключить ВСЁ", function()
    for k in pairs(State) do State[k] = false end
    for _, conn in pairs({_G.DasterFlyConn, _G.DasterGodConn, _G.DasterInfJumpConn,
                          _G.DasterNoclipConn, _G.DasterDrillConn}) do
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
Tabs["AutoMine"].BackgroundColor3 = Config.Theme.Accent
Tabs["AutoMine"].TextColor3 = Color3.fromRGB(255, 255, 255)
Pages["AutoMine"].Visible = true

task.wait(0.3)
U.Notify("⛏ Daster Drill Script v" .. Config.Version .. " загружен!", 4, Config.Theme.Accent)
task.wait(0.5)
U.Notify("⛏ AutoMine → жми ЗАПУСТИТЬ ВСЁ", 5, Config.Theme.Success)

print("[DasterCore] ✅ Скрипт загружен!")
print("[DasterCore] Вкладок: " .. tostring(#TabScroll:GetChildren() - 1))
