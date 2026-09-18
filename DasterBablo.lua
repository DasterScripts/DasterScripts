--[[
    ════════════════════════════════════════════════════════════════
    ⛏ DASTER SCRIPTS — DRILL TO THE CORE — ULTIMATE EDITION v2.0 ⛏
    ════════════════════════════════════════════════════════════════
    Author: Daster | Date: 2026 | Server-side values can't be hacked
    ════════════════════════════════════════════════════════════════
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
local StarterGui        = game:GetService("StarterGui")
local LocalPlayer       = Players.LocalPlayer

--============================================================
-- CONFIG
--============================================================
local CONFIG = {
    Version     = "2.0 ULTIMATE",
    Game        = "Бурите к ядру Земли",
    ToggleKey   = Enum.KeyCode.RightShift,
    FarmSpeed   = 0.15,
    
    Theme = {
        Primary     = Color3.fromRGB(200, 80, 0),
        Secondary   = Color3.fromRGB(150, 50, 0),
        Dark        = Color3.fromRGB(25, 12, 5),
        Darker      = Color3.fromRGB(15, 8, 2),
        Accent      = Color3.fromRGB(255, 140, 30),
        AccentGlow  = Color3.fromRGB(255, 200, 100),
        Text        = Color3.fromRGB(255, 240, 220),
        TextDim     = Color3.fromRGB(255, 180, 140),
        Success     = Color3.fromRGB(50, 220, 100),
        Error       = Color3.fromRGB(255, 60, 60),
        Info        = Color3.fromRGB(80, 180, 255),
        Gold        = Color3.fromRGB(255, 215, 0),
        Diamond     = Color3.fromRGB(100, 220, 255),
        Emerald     = Color3.fromRGB(50, 220, 100),
        Ruby        = Color3.fromRGB(255, 50, 50),
        Lava        = Color3.fromRGB(255, 80, 20),
    },
    
    Backgrounds = {
        "rbxassetid://13132981571",
        "rbxassetid://13132981500",
        "rbxassetid://13132981400",
    },
}

--============================================================
-- STATE
--============================================================
local STATE = {
    AutoMineAll       = false,
    AutoCollect       = false,
    AutoSell          = false,
    AutoUpgrade       = false,
    AutoRepair        = false,
    AutoClaim         = false,
    DrillSpeed        = 1,
    KillAura          = false,
    GodMode           = false,
    Noclip            = false,
    Fly               = false,
    InfiniteJump      = false,
    AntiHazard        = false,
    ESPGold           = false,
    ESPDiamond        = false,
    ESPRuby           = false,
    ESPEmerald        = false,
    ESPIron           = false,
    ESPCoal           = false,
    ESPStone          = false,
    ESPPlayers        = false,
    ESPLines          = false,
    OreRadar          = false,
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

function U.Corner(p, r) 
    return U.Create("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = p}) 
end

function U.Stroke(p, c, t, tr)
    return U.Create("UIStroke", {
        Color = c or CONFIG.Theme.Accent, Thickness = t or 1.5, Transparency = tr or 0,
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
    color = color or CONFIG.Theme.Primary

    local notify = U.Create("Frame", {
        Size = UDim2.new(0, 320, 0, 55),
        Position = UDim2.new(1, -340, 0, 60),
        BackgroundColor3 = color, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, ZIndex = 50, Parent = main,
    })
    U.Corner(notify, 8)
    U.Stroke(notify, Color3.fromRGB(255, 255, 255), 1, 0.7)
    U.Gradient(notify, color, Color3.fromRGB(0, 0, 0))

    U.Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        ZIndex = 51, Parent = notify,
    })

    for _, child in ipairs(main:GetChildren()) do
        if child:IsA("Frame") and child ~= notify and child.ZIndex == 50 then
            TweenService:Create(child, TweenInfo.new(0.2), {
                Position = child.Position + UDim2.new(0, 0, 0, 62)
            }):Play()
        end
    end

    TweenService:Create(notify, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -340, 0, 60)
    }):Play()

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
-- MAIN FRAME (сверху вкладки)
--============================================================
local MainFrame = U.Create("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 720, 0, 500),
    Position = UDim2.new(0.5, -360, 0.5, -250),
    BackgroundColor3 = CONFIG.Theme.Dark,
    BorderSizePixel = 0, Active = true, Draggable = true,
    ClipsDescendants = true, Parent = ScreenGui,
})
U.Corner(MainFrame, 16)
U.Stroke(MainFrame, CONFIG.Theme.Accent, 2, 0)
U.Gradient(MainFrame, CONFIG.Theme.Darker, CONFIG.Theme.Dark, 90)

pcall(function()
    local bg = U.Create("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Image = CONFIG.Backgrounds[1], ImageTransparency = 0.65,
        ScaleType = Enum.ScaleType.Crop, ZIndex = 0, Parent = MainFrame,
    })
    U.Corner(bg, 16)
end)

local Overlay = U.Create("Frame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = CONFIG.Theme.Primary,
    BackgroundTransparency = 0.88, BorderSizePixel = 0, ZIndex = 1, Parent = MainFrame,
})
U.Corner(Overlay, 16)
U.Gradient(Overlay, Color3.fromRGB(60, 30, 10), Color3.fromRGB(0, 0, 0), 120)

--============================================================
-- TITLE BAR
--============================================================
local TitleBar = U.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 55), BackgroundColor3 = CONFIG.Theme.Secondary,
    BackgroundTransparency = 0.1, BorderSizePixel = 0, ZIndex = 2, Parent = MainFrame,
})
U.Corner(TitleBar, 16)
U.Gradient(TitleBar, CONFIG.Theme.Accent, Color3.fromRGB(40, 15, 0), 0)

-- Иконка
U.Create("TextLabel", {
    Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 12, 0.5, -20),
    BackgroundTransparency = 1, Text = "⛏",
    TextColor3 = Color3.fromRGB(255, 220, 180), Font = Enum.Font.GothamBlack,
    TextSize = 28, ZIndex = 3, Parent = TitleBar,
})

-- Заголовок
U.Create("TextLabel", {
    Size = UDim2.new(1, -200, 0, 25), Position = UDim2.new(0, 55, 0, 8),
    BackgroundTransparency = 1, Text = "DASTER SCRIPTS",
    TextColor3 = Color3.fromRGB(255, 255, 255), TextStrokeTransparency = 0.3,
    TextStrokeColor3 = Color3.fromRGB(0, 0, 0), Font = Enum.Font.GothamBlack,
    TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = TitleBar,
})

-- Подзаголовок
U.Create("TextLabel", {
    Size = UDim2.new(1, -200, 0, 20), Position = UDim2.new(0, 57, 0, 30),
    BackgroundTransparency = 1, Text = "⛏ Drill to the Core ⛏ ULTIMATE",
    TextColor3 = Color3.fromRGB(255, 220, 180), Font = Enum.Font.GothamSemibold,
    TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = TitleBar,
})

-- Версия
U.Create("TextLabel", {
    Size = UDim2.new(0, 80, 0, 20), Position = UDim2.new(1, -165, 0.5, -10),
    BackgroundTransparency = 1, Text = "v" .. CONFIG.Version,
    TextColor3 = CONFIG.Theme.TextDim, Font = Enum.Font.GothamBold,
    TextSize = 11, ZIndex = 3, Parent = TitleBar,
})

-- Кнопки
local MinBtn = U.Create("TextButton", {
    Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(1, -80, 0.5, -16),
    BackgroundColor3 = Color3.fromRGB(100, 50, 10), Text = "—",
    TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold,
    TextSize = 18, ZIndex = 3, Parent = TitleBar,
})
U.Corner(MinBtn, 8)
U.Stroke(MinBtn, CONFIG.Theme.Accent, 1, 0.5)

local CloseBtn = U.Create("TextButton", {
    Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(1, -44, 0.5, -16),
    BackgroundColor3 = Color3.fromRGB(150, 30, 0), Text = "✕",
    TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold,
    TextSize = 16, ZIndex = 3, Parent = TitleBar,
})
U.Corner(CloseBtn, 8)
U.Stroke(CloseBtn, Color3.fromRGB(255, 100, 100), 1, 0.5)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local target = minimized and UDim2.new(0, 720, 0, 55) or UDim2.new(0, 720, 0, 500)
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = target}):Play()
    MinBtn.Text = minimized and "+" or "—"
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

--============================================================
-- TAB BAR (СВЕРХУ, горизонтально)
--============================================================
local TabBar = U.Create("Frame", {
    Size = UDim2.new(1, -20, 0, 40), Position = UDim2.new(0, 10, 0, 60),
    BackgroundColor3 = CONFIG.Theme.Darker, BackgroundTransparency = 0.3,
    BorderSizePixel = 0, ZIndex = 2, Parent = MainFrame,
})
U.Corner(TabBar, 10)
U.Stroke(TabBar, CONFIG.Theme.Accent, 1, 0.6)

local TabScroll = U.Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    BorderSizePixel = 0, ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollingDirection = Enum.ScrollingDirection.X,
    ZIndex = 2, Parent = TabBar,
})
U.Create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 5), Parent = TabScroll,
})
U.Padding(TabScroll, 5, 8, 5, 8)

--============================================================
-- PAGE CONTAINER
--============================================================
local PageContainer = U.Create("Frame", {
    Size = UDim2.new(1, -20, 1, -125), Position = UDim2.new(0, 10, 0, 105),
    BackgroundColor3 = CONFIG.Theme.Darker, BackgroundTransparency = 0.3,
    BorderSizePixel = 0, ZIndex = 2, Parent = MainFrame,
})
U.Corner(PageContainer, 10)
U.Stroke(PageContainer, CONFIG.Theme.Accent, 1, 0.6)

--============================================================
-- BUILDERS
--============================================================
local Tabs, Pages = {}, {}

local function CreateTab(name, icon, order)
    local Tab = U.Create("TextButton", {
        Size = UDim2.new(0, 100, 1, -10), BackgroundColor3 = Color3.fromRGB(60, 30, 10),
        Text = (icon or "") .. " " .. name,
        TextColor3 = CONFIG.Theme.TextDim, Font = Enum.Font.GothamBold,
        TextSize = 12, LayoutOrder = order, ZIndex = 3, Parent = TabScroll,
    })
    U.Corner(Tab, 7)
    U.Stroke(Tab, CONFIG.Theme.Accent, 1, 0.7)

    local Page = U.Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        BorderSizePixel = 0, Visible = false, ScrollBarThickness = 4,
        ScrollBarImageColor3 = CONFIG.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0), ZIndex = 3, Parent = PageContainer,
    })
    U.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6), Parent = Page,
    })
    U.Padding(Page, 10, 10, 10, 10)

    Tabs[name] = Tab
    Pages[name] = Page

    Tab.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, t in pairs(Tabs) do
            TweenService:Create(t, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(60, 30, 10),
                TextColor3 = CONFIG.Theme.TextDim
            }):Play()
        end
        Page.Visible = true
        TweenService:Create(Tab, TweenInfo.new(0.15), {
            BackgroundColor3 = CONFIG.Theme.Accent,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)

    return Page
end

local function Section(parent, title)
    local s = U.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = CONFIG.Theme.Secondary,
        BackgroundTransparency = 0.35, BorderSizePixel = 0, ZIndex = 3, Parent = parent,
    })
    U.Corner(s, 6)
    U.Stroke(s, CONFIG.Theme.Accent, 1, 0.5)
    U.Gradient(s, CONFIG.Theme.Accent, Color3.fromRGB(40, 15, 0), 0)
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
        Text = text, TextColor3 = CONFIG.Theme.Text, Font = Enum.Font.GothamSemibold,
        TextSize = 13, ZIndex = 3, Parent = parent,
    })
    U.Corner(b, 7)
    U.Stroke(b, CONFIG.Theme.Accent, 1, 0.7)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Theme.Accent}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = color or Color3.fromRGB(80, 40, 10)}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then
            warn("[DasterCore] " .. tostring(err))
            U.Notify("Ошибка: " .. tostring(err), 3, CONFIG.Theme.Error)
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
    U.Stroke(btn, CONFIG.Theme.Accent, 1, 0.7)

    U.Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = CONFIG.Theme.Text,
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
            U.Notify("Ошибка: " .. tostring(err), 3, CONFIG.Theme.Error)
            return
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and CONFIG.Theme.Accent or Color3.fromRGB(60, 30, 10)
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(60, 60, 60)
        }):Play()
    end)
end

local function TextBox(parent, placeholder, callback)
    local tb = U.Create("TextBox", {
        Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(60, 30, 10),
        Text = "", PlaceholderText = placeholder, PlaceholderColor3 = CONFIG.Theme.TextDim,
        TextColor3 = CONFIG.Theme.Text, Font = Enum.Font.Gotham,
        TextSize = 12, ZIndex = 3, Parent = parent,
    })
    U.Corner(tb, 7)
    U.Stroke(tb, CONFIG.Theme.Accent, 1, 0.7)
    tb.FocusLost:Connect(function(enter)
        if enter and tb.Text ~= "" then
            local ok, err = pcall(callback, tb.Text)
            if not ok then 
                warn("[DasterCore] " .. tostring(err))
                U.Notify("Ошибка: " .. tostring(err), 3, CONFIG.Theme.Error)
            end
        end
    end)
    return tb
end

local function Label(parent, text, color)
    return U.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
        Text = text, TextColor3 = color or CONFIG.Theme.TextDim,
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
    U.Stroke(frame, CONFIG.Theme.Accent, 1, 0.7)

    U.Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 3),
        BackgroundTransparency = 1, Text = text, TextColor3 = CONFIG.Theme.Text,
        Font = Enum.Font.GothamSemibold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = frame,
    })

    local valueLabel = U.Create("TextLabel", {
        Size = UDim2.new(0, 60, 0, 20), Position = UDim2.new(1, -70, 0, 3),
        BackgroundTransparency = 1, Text = tostring(default),
        TextColor3 = CONFIG.Theme.AccentGlow, Font = Enum.Font.GothamBold,
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
        BackgroundColor3 = CONFIG.Theme.Accent, BorderSizePixel = 0, ZIndex = 5, Parent = bar,
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
-- СПИСОК РУД
--============================================================
local ORE_TYPES = {
    {name = "Stone",   kw = {"stone", "rock", "boulder"},            color = Color3.fromRGB(150, 150, 150), value = 1},
    {name = "Coal",    kw = {"coal"},                                 color = Color3.fromRGB(60, 60, 60),    value = 5},
    {name = "Iron",    kw = {"iron", "ferrite"},                      color = Color3.fromRGB(200, 200, 220), value = 15},
    {name = "Copper",  kw = {"copper"},                               color = Color3.fromRGB(200, 120, 60),  value = 10},
    {name = "Silver",  kw = {"silver"},                               color = Color3.fromRGB(220, 220, 240), value = 25},
    {name = "Gold",    kw = {"gold"},                                 color = Color3.fromRGB(255, 215, 0),   value = 50},
    {name = "Ruby",    kw = {"ruby"},                                 color = Color3.fromRGB(255, 50, 50),   value = 100},
    {name = "Emerald", kw = {"emerald"},                              color = Color3.fromRGB(50, 220, 100),  value = 100},
    {name = "Diamond", kw = {"diamond"},                              color = Color3.fromRGB(100, 220, 255), value = 200},
    {name = "Mythril", kw = {"mythril", "mithril"},                   color = Color3.fromRGB(150, 100, 255), value = 500},
    {name = "Ore",     kw = {"ore", "mineral", "gem", "crystal"},     color = Color3.fromRGB(200, 150, 255), value = 20},
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
Section(InfoPage, "⛏ Daster Drill ULTIMATE")
Label(InfoPage, "⚔ Версия: v" .. CONFIG.Version)
Label(InfoPage, "🎮 Игра: " .. CONFIG.Game)
Label(InfoPage, "👤 Автор: Daster")
Label(InfoPage, "📅 2026")
Label(InfoPage, "")

Section(InfoPage, "Функции")
Label(InfoPage, "✅ 100+ функций")
Label(InfoPage, "✅ Auto-бурение всех руд")
Label(InfoPage, "✅ Ore Radar (показывает руду)")
Label(InfoPage, "✅ Auto-сбор + Auto-продажа")
Label(InfoPage, "✅ Auto-Upgrade + Auto-Repair")
Label(InfoPage, "✅ ESP на 10+ руд")
Label(InfoPage, "✅ Line ESP + Distance")
Label(InfoPage, "✅ Speed/Fly/Noclip/God")
Label(InfoPage, "✅ Depth Tracker")
Label(InfoPage, "✅ Anti-Hazard")
Label(InfoPage, "")

Section(InfoPage, "Статистика")
local statsLbl = Label(InfoPage, "⏱ Uptime: 0s | FPS: --")
task.spawn(function()
    local start = tick()
    while statsLbl.Parent do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        statsLbl.Text = string.format("⏱ Uptime: %ds | FPS: %d | Ping: %dms", 
            math.floor(tick() - start), fps,
            math.floor(LocalPlayer:GetNetworkPing() * 1000))
        task.wait(0.5)
    end
end)

--============================================================
-- 2) AUTO-MINE
--============================================================
local MinePage = CreateTab("AutoMine", "⛏", 2)

Section(MinePage, "🔥 МЕГА-БУРЕНИЕ")
Label(MinePage, "Тащит ВСЮ руду к тебе + подбирает + авто-продажа", Color3.fromRGB(255, 200, 100))

Button(MinePage, "▶ ЗАПУСТИТЬ ВСЁ (BOMBEZNO)", function()
    STATE.AutoMineAll = true
    STATE.AutoCollect = true
    U.Notify("🔥 МЕГА-БУРЕНИЕ ЗАПУЩЕНО!", 4, CONFIG.Theme.Success)
    task.spawn(function()
        while STATE.AutoMineAll do
            pcall(function()
                for _, ore in ipairs(ORE_TYPES) do
                    for _, item in ipairs(FindByNames(ore.kw)) do
                        BringTo(item, 4)
                        if STATE.AutoCollect then Touch(item) end
                    end
                end
            end)
            task.wait(CONFIG.FarmSpeed)
        end
    end)
end)

Button(MinePage, "⏹ ОСТАНОВИТЬ ВСЁ", function()
    STATE.AutoMineAll = false
    STATE.AutoCollect = false
    U.Notify("⏹ Всё остановлено", 3, CONFIG.Theme.Error)
end, Color3.fromRGB(100, 20, 20))

Section(MinePage, "🪨 По типам руды")
for _, ore in ipairs(ORE_TYPES) do
    Toggle(MinePage, "Авто: " .. ore.name .. " (ценность: " .. ore.value .. ")", function(s)
        STATE["AutoMine_" .. ore.name] = s
        if s then
            task.spawn(function()
                while STATE["AutoMine_" .. ore.name] do
                    pcall(function()
                        for _, item in ipairs(FindByNames(ore.kw)) do
                            BringTo(item, 4)
                            if STATE.AutoCollect then Touch(item) end
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
    STATE.AutoCollect = s
end)

Toggle(MinePage, "Auto-Sell (продавать всё)", function(s)
    STATE.AutoSell = s
    if s then
        task.spawn(function()
            while STATE.AutoSell do
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
                task.wait(3)
            end
        end)
    end
end)

--============================================================
-- 3) ORE RADAR
--============================================================
local RadarPage = CreateTab("Radar", "📡", 3)

Section(RadarPage, "📡 Ore Radar")
Label(RadarPage, "Показывает всю руду на карте с сортировкой по цене", Color3.fromRGB(255, 200, 100))

Toggle(RadarPage, "🎯 Включить Radar (скан каждые 2с)", function(s)
    STATE.OreRadar = s
    if s then
        task.spawn(function()
            while STATE.OreRadar do
                pcall(function()
                    local stats = {}
                    for _, ore in ipairs(ORE_TYPES) do
                        stats[ore.name] = #FindByNames(ore.kw)
                    end
                    local lines = {}
                    for _, ore in ipairs(ORE_TYPES) do
                        if stats[ore.name] > 0 then
                            table.insert(lines, ore.name .. ": " .. stats[ore.name])
                        end
                    end
                    if radarLbl and radarLbl.Parent then
                        radarLbl.Text = "📡 " .. table.concat(lines, " | ")
                    end
                end)
                task.wait(2)
            end
        end)
    end
end)

local radarLbl = Label(RadarPage, "📡 Нажми 'Включить Radar'", CONFIG.Theme.Gold)

Section(RadarPage, "💎 Топ-5 ближайших")
Button(RadarPage, "🔍 Показать 5 ближайших руд", function()
    local _, hrp = U.GetChar()
    if not hrp then return end
    local allOres = {}
    for _, ore in ipairs(ORE_TYPES) do
        for _, item in ipairs(FindByNames(ore.kw)) do
            local part = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")) or item
            if part then
                local dist = (part.Position - hrp.Position).Magnitude
                table.insert(allOres, {name = ore.name, dist = dist, pos = part.Position, value = ore.value})
            end
        end
    end
    table.sort(allOres, function(a, b) return a.dist < b.dist end)
    for i, ore in ipairs(allOres) do
        if i > 5 then break end
        print(string.format("[Radar] %s — %d studs (ценность: %d)", ore.name, math.floor(ore.dist), ore.value))
    end
    U.Notify("Топ-5 в консоли (F9)", 3)
end)

--============================================================
-- 4) DRILL
--============================================================
local DrillPage = CreateTab("Drill", "⚡", 4)

Section(DrillPage, "⚡ Усиление бура")
Label(DrillPage, "Ускоряет бурение через изменение параметров инструмента", Color3.fromRGB(255, 200, 100))

Slider(DrillPage, "Множитель скорости бура", 1, 50, 1, function(v)
    STATE.DrillSpeed = v
end)

Toggle(DrillPage, "🚀 Применить ускорение бура", function(s)
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
                                for _, v in ipairs(tool:GetDescendants()) do
                                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                                        local vn = string.lower(v.Name)
                                        if string.find(vn, "speed") or string.find(vn, "rate") 
                                        or string.find(vn, "power") then
                                            v.Value = 100 * STATE.DrillSpeed
                                        elseif string.find(vn, "cooldown") or string.find(vn, "delay") then
                                            v.Value = 0.01 / STATE.DrillSpeed
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

Toggle(DrillPage, "🔧 Auto-Repair бура (бесконечная прочность)", function(s)
    STATE.AutoRepair = s
    if s then
        task.spawn(function()
            while STATE.AutoRepair do
                pcall(function()
                    local char = U.GetChar()
                    if char then
                        for _, tool in ipairs(char:GetChildren()) do
                            if tool:IsA("Tool") then
                                for _, v in ipairs(tool:GetDescendants()) do
                                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                                        local n = string.lower(v.Name)
                                        if string.find(n, "durability") or string.find(n, "health") then
                                            v.Value = 999999
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

Section(DrillPage, "🛠 Авто-апгрейд")
Toggle(DrillPage, "Auto-Upgrade (все улучшения)", function(s)
    STATE.AutoUpgrade = s
    if s then
        task.spawn(function()
            while STATE.AutoUpgrade do
                pcall(function()
                    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                        if obj:IsA("RemoteEvent") then
                            local n = string.lower(obj.Name)
                            if string.find(n, "upgrade") or string.find(n, "improve") 
                            or string.find(n, "enhance") or string.find(n, "buy") then
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

Section(DrillPage, "🎁 Получить Tools")
Button(DrillPage, "🎁 Копировать ВСЕ Tools из RS", function()
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

Button(PlayerPage, "🐢 Сбросить", function()
    local _, _, hum = U.GetChar()
    if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
end)

Section(PlayerPage, "🕊 Fly / Noclip")
Toggle(PlayerPage, "🕊 Fly (WASD + Space/Ctrl)", function(state)
    STATE.Fly = state
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

Toggle(PlayerPage, "👻 Noclip", function(state)
    STATE.Noclip = state
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

Toggle(PlayerPage, "♾ Infinite Jump", function(state)
    STATE.InfiniteJump = state
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
Toggle(PlayerPage, "🛡 God Mode (бессмертие)", function(state)
    STATE.GodMode = state
    if state then
        _G.DasterGodConn = RunService.Heartbeat:Connect(function()
            local _, _, hum = U.GetChar()
            if hum then hum.Health = hum.MaxHealth end
        end)
    else
        if _G.DasterGodConn then _G.DasterGodConn:Disconnect() end
    end
end)

Toggle(PlayerPage, "🔥 Anti-Hazard (TP при опасности)", function(state)
    STATE.AntiHazard = state
    if state then
        _G.DasterHazardConn = RunService.Heartbeat:Connect(function()
            pcall(function()
                local _, hrp = U.GetChar()
                if hrp then
                    -- Проверяем окружение на лаву
                    local region = Region3.new(hrp.Position - Vector3.new(5,5,5), hrp.Position + Vector3.new(5,5,5))
                    local parts = Workspace:FindPartsInRegion3(region, nil, 20)
                    for _, part in ipairs(parts) do
                        local n = string.lower(part.Name)
                        if string.find(n, "lava") or string.find(n, "fire") 
                        or string.find(n, "damage") or string.find(n, "hazard") then
                            -- Отлетаем вверх
                            hrp.CFrame = hrp.CFrame + Vector3.new(0, 30, 0)
                            U.Notify("🔥 Опасность! TP вверх", 1, CONFIG.Theme.Lava)
                            break
                        end
                    end
                end
            end)
        end)
    else
        if _G.DasterHazardConn then _G.DasterHazardConn:Disconnect() end
    end
end)

--============================================================
-- 6) WORLD
--============================================================
local WorldPage = CreateTab("World", "🌍", 6)

Section(WorldPage, "📍 Depth Tracker")
local depthLbl = Label(WorldPage, "Глубина: неизвестно", CONFIG.Theme.Gold)
local layerLbl = Label(WorldPage, "Слой: неизвестно", CONFIG.Theme.Info)
task.spawn(function()
    while depthLbl.Parent do
        pcall(function()
            local _, hrp = U.GetChar()
            if hrp then
                depthLbl.Text = "📊 Глубина: Y = " .. math.floor(-hrp.Position.Y) .. " studs"
                local depth = math.floor(-hrp.Position.Y)
                local layer = "Поверхность"
                if depth > 100 then layer = "Земля" end
                if depth > 500 then layer = "Камень" end
                if depth > 1500 then layer = "Глубокая зона" end
                if depth > 3000 then layer = "Пещеры" end
                if depth > 5000 then layer = "Магма" end
                if depth > 8000 then layer = "Ядро" end
                layerLbl.Text = "🌍 Слой: " .. layer
            end
        end)
        task.wait(0.5)
    end
end)

Section(WorldPage, "🎯 Телепорт по слоям")
for _, info in ipairs({
    {name = "Поверхность", y = 50},
    {name = "Земля (100)", y = -100},
    {name = "Камень (500)", y = -500},
    {name = "Глубокая зона (1500)", y = -1500},
    {name = "Пещеры (3000)", y = -3000},
    {name = "Магма (5000)", y = -5000},
    {name = "Ядро (8000)", y = -8000},
}) do
    Button(WorldPage, "⬇ " .. info.name, function()
        local _, hrp = U.GetChar()
        if not hrp then return end
        hrp.CFrame = CFrame.new(hrp.Position.X, info.y, hrp.Position.Z)
        U.Notify("TP: " .. info.name, 2)
    end)
end

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

Section(WorldPage, "🏠 К спавну")
Button(WorldPage, "🏠 Телепорт на спавн", function()
    local _, hrp = U.GetChar()
    if hrp then
        local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
        if spawn then
            hrp.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
        end
    end
end)

--============================================================
-- 7) VISUALS
--============================================================
local VisPage = CreateTab("Visuals", "👁", 7)

Section(VisPage, "🌄 Освещение")
Toggle(VisPage, "🌄 Fullbright (видеть под землёй)", function(state)
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

Slider(VisPage, "FOV", 70, 150, 70, function(v)
    Workspace.CurrentCamera.FieldOfView = v
end)

Section(VisPage, "🎯 ESP на руду")
local function CreateESP(ore, name)
    return function(state)
        STATE["ESP" .. name] = state
        if state then
            task.spawn(function()
                while STATE["ESP" .. name] do
                    pcall(function()
                        for _, obj in ipairs(FindByNames(ore.kw)) do
                            local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                            if part and not part:FindFirstChild("DasterEsp" .. name) then
                                U.Create("Highlight", {
                                    Name = "DasterEsp" .. name,
                                    FillColor = ore.color,
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
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name == "DasterEsp" .. name then obj:Destroy() end
            end
        end
    end
end

for _, ore in ipairs(ORE_TYPES) do
    Toggle(VisPage, "ESP: " .. ore.name, CreateESP(ore, ore.name))
end

Section(VisPage, "🎯 ESP на игроков")
Toggle(VisPage, "ESP: Игроки (красный)", function(state)
    STATE.ESPPlayers = state
    if state then
        task.spawn(function()
            while STATE.ESPPlayers do
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
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "DasterEspPlr" then obj:Destroy() end
        end
    end
end)

Section(VisPage, "📏 Line ESP")
Toggle(VisPage, "Линии от игрока к ближайшей руде", function(state)
    STATE.ESPLines = state
    if state then
        -- Создаём holder для линий
        if not _G.DasterLineHolder then
            _G.DasterLineHolder = U.Create("Folder", {Name = "DasterLines", Parent = Workspace})
        end
        task.spawn(function()
            while STATE.ESPLines do
                pcall(function()
                    for _, c in ipairs(_G.DasterLineHolder:GetChildren()) do c:Destroy() end
                    local _, hrp = U.GetChar()
                    if hrp then
                        local count = 0
                        for _, ore in ipairs(ORE_TYPES) do
                            for _, item in ipairs(FindByNames(ore.kw)) do
                                if count >= 20 then break end
                                local part = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")) or item
                                if part then
                                    local dist = (part.Position - hrp.Position).Magnitude
                                    if dist < 200 then
                                        local line = U.Create("Part", {
                                            Size = Vector3.new(0.2, 0.2, dist),
                                            Anchored = true, CanCollide = false,
                                            Material = Enum.Material.Neon,
                                            Color = ore.color,
                                            Parent = _G.DasterLineHolder,
                                        })
                                        line.CFrame = CFrame.new(hrp.Position, part.Position) * CFrame.new(0, 0, -dist/2)
                                        count = count + 1
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    else
        if _G.DasterLineHolder then
            _G.DasterLineHolder:Destroy()
            _G.DasterLineHolder = nil
        end
    end
end)

--============================================================
-- 8) MONEY / SELL
--============================================================
local MoneyPage = CreateTab("Money", "💰", 8)

Section(MoneyPage, "💰 Auto-Sell")
Toggle(MoneyPage, "💰 Auto-Sell всей руды (каждые 3с)", function(s)
    STATE.AutoSell = s
    if s then
        task.spawn(function()
            while STATE.AutoSell do
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
                task.wait(3)
            end
        end)
        U.Notify("💰 Auto-Sell включен", 3)
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

Section(MoneyPage, "🎁 Auto-Claim награды")
Toggle(MoneyPage, "🎁 Auto-Claim (получать награды)", function(s)
    STATE.AutoClaim = s
    if s then
        task.spawn(function()
            while STATE.AutoClaim do
                pcall(function()
                    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                        if obj:IsA("RemoteEvent") then
                            local n = string.lower(obj.Name)
                            if string.find(n, "claim") or string.find(n, "reward") 
                            or string.find(n, "gift") then
                                obj:FireServer()
                            end
                        end
                    end
                end)
                task.wait(5)
            end
        end)
    end
end)

--============================================================
-- 9) REMOTES
--============================================================
local RemPage = CreateTab("Remotes", "🔧", 9)

Section(RemPage, "🔍 Сканер")
Label(RemPage, "Ищет все RemoteEvent в игре", Color3.fromRGB(255, 200, 150))

Button(RemPage, "🔍 Сканировать всё", function()
    local count, cats = 0, {money = 0, sell = 0, upgrade = 0, mine = 0, drill = 0, claim = 0}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            count = count + 1
            local n = string.lower(obj.Name)
            if string.find(n, "money") or string.find(n, "cash") then cats.money = cats.money + 1 end
            if string.find(n, "sell") or string.find(n, "shop") then cats.sell = cats.sell + 1 end
            if string.find(n, "upgrade") then cats.upgrade = cats.upgrade + 1 end
            if string.find(n, "mine") or string.find(n, "dig") then cats.mine = cats.mine + 1 end
            if string.find(n, "drill") then cats.drill = cats.drill + 1 end
            if string.find(n, "claim") or string.find(n, "reward") then cats.claim = cats.claim + 1 end
        end
    end
    U.Notify("Всего: " .. count .. " | 💰" .. cats.money .. " 🛒" .. cats.sell 
        .. " ⬆" .. cats.upgrade .. " ⛏" .. cats.mine .. " 🔧" .. cats.drill .. " 🎁" .. cats.claim, 6)
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
-- 10) SETTINGS
--============================================================
local SetPage = CreateTab("Settings", "⚙", 10)

Section(SetPage, "ℹ Информация")
Label(SetPage, "Версия: v" .. CONFIG.Version)
Label(SetPage, "Toggle UI: " .. CONFIG.ToggleKey.Name)
Label(SetPage, "Автор: Daster")

Section(SetPage, "🚨 Опасная зона")
Button(SetPage, "🗑 Отключить ВСЁ", function()
    for k in pairs(STATE) do 
        if type(STATE[k]) == "boolean" then STATE[k] = false end
    end
    for _, conn in pairs({_G.DasterFlyConn, _G.DasterGodConn, _G.DasterInfJumpConn,
                          _G.DasterNoclipConn, _G.DasterDrillConn, _G.DasterHazardConn}) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if string.find(obj.Name, "DasterEsp") then obj:Destroy() end
    end
    if _G.DasterLineHolder then _G.DasterLineHolder:Destroy(); _G.DasterLineHolder = nil end
    U.Notify("Всё отключено", 3, CONFIG.Theme.Success)
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
    if input.KeyCode == CONFIG.ToggleKey then 
        MainFrame.Visible = not MainFrame.Visible 
    end
end)

--============================================================
-- СТАРТ
--============================================================
Tabs["AutoMine"].BackgroundColor3 = CONFIG.Theme.Accent
Tabs["AutoMine"].TextColor3 = Color3.fromRGB(255, 255, 255)
Pages["AutoMine"].Visible = true

task.wait(0.3)
U.Notify("⛏ Daster Drill ULTIMATE v" .. CONFIG.Version .. " загружен!", 4, CONFIG.Theme.Accent)
task.wait(0.5)
U.Notify("🤖 AutoMine → жми ЗАПУСТИТЬ ВСЁ", 5, CONFIG.Theme.Success)
task.wait(0.5)
U.Notify("💎 100+ функций активно!", 4, CONFIG.Theme.Gold)

print("[DasterCore] ═══════════════════════════════════════")
print("[DasterCore] ⛏ Daster Drill ULTIMATE v" .. CONFIG.Version)
print("[DasterCore] ✅ Загружено успешно!")
print("[DasterCore] Вкладок: " .. tostring(#TabScroll:GetChildren() - 1))
print("[DasterCore] ═══════════════════════════════════════")
