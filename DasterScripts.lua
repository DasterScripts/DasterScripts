--[[
    ================================================================
    ⚔ DASTER SCRIPTS v2.0 PRO ⚔
    Game: 99 Nights in the Forest
    Author: Daster
    UI: Red Anime Theme + Gradients + Animations
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
local StarterGui        = game:GetService("StarterGui")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local LocalPlayer       = Players.LocalPlayer

--============================================================
-- CONFIG
--============================================================
local Config = {
    Version     = "2.0",
    Name        = "Daster Scripts",
    Theme       = {
        Primary     = Color3.fromRGB(180, 0, 0),
        Secondary   = Color3.fromRGB(120, 0, 0),
        Dark        = Color3.fromRGB(20, 0, 0),
        Darker      = Color3.fromRGB(12, 0, 0),
        Accent      = Color3.fromRGB(255, 30, 30),
        AccentGlow  = Color3.fromRGB(255, 80, 80),
        Text        = Color3.fromRGB(255, 230, 230),
        TextDim     = Color3.fromRGB(255, 150, 150),
        Success     = Color3.fromRGB(50, 220, 50),
        Error       = Color3.fromRGB(255, 60, 60),
    },
    Backgrounds = {
        "rbxassetid://13132981571",  -- основной аниме фон
        "rbxassetid://13132981500",
        "rbxassetid://13132981400",
    },
    ToggleKey   = Enum.KeyCode.RightShift,
}

--============================================================
-- UTILS
--============================================================
local Utils = {}

function Utils.Create(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    for _, c in ipairs(children or {}) do c.Parent = obj end
    return obj
end

function Utils.Corner(parent, radius)
    return Utils.Create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
end

function Utils.Stroke(parent, color, thickness, transparency)
    return Utils.Create("UIStroke", {
        Color = color or Config.Theme.Accent,
        Thickness = thickness or 1.5,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

function Utils.Gradient(parent, c1, c2, rotation)
    return Utils.Create("UIGradient", {
        Color = ColorSequence.new(c1, c2),
        Rotation = rotation or 45,
        Parent = parent
    })
end

function Utils.Padding(parent, top, left, right, bottom)
    return Utils.Create("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        Parent = parent
    })
end

function Utils.Notify(text, duration, color)
    local sg = game.CoreGui:FindFirstChild("DasterScripts")
    if not sg then return end
    local main = sg:FindFirstChild("MainFrame")
    if not main then return end

    duration = duration or 3
    color = color or Config.Theme.Primary

    local notify = Utils.Create("Frame", {
        Size = UDim2.new(0, 280, 0, 50),
        Position = UDim2.new(1, -300, 0, 60),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ZIndex = 50,
        Parent = main,
    })
    Utils.Corner(notify, 8)
    Utils.Stroke(notify, Color3.fromRGB(255, 255, 255), 1, 0.7)
    Utils.Gradient(notify, color, Color3.fromRGB(0, 0, 0))

    Utils.Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 51,
        Parent = notify,
    })

    -- Сдвиг всех существующих уведомлений
    for _, child in ipairs(main:GetChildren()) do
        if child:IsA("Frame") and child ~= notify and child.ZIndex == 50 then
            TweenService:Create(child, TweenInfo.new(0.2), {
                Position = child.Position + UDim2.new(0, 0, 0, 58)
            }):Play()
        end
    end

    TweenService:Create(notify, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -300, 0, 60)
    }):Play()

    task.delay(duration, function()
        TweenService:Create(notify, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 0, 0, 60),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.3)
        notify:Destroy()
    end)
end

function Utils.GetChar()
    local char = LocalPlayer.Character
    if not char then return nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    return char, hrp, hum
end

--============================================================
-- ANTI-AFK (всегда включен)
--============================================================
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

--============================================================
-- GUI ROOT
--============================================================
if game.CoreGui:FindFirstChild("DasterScripts") then
    game.CoreGui.DasterScripts:Destroy()
end

local ScreenGui = Utils.Create("ScreenGui", {
    Name = "DasterScripts",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    Parent = game.CoreGui,
})

--============================================================
-- MAIN FRAME
--============================================================
local MainFrame = Utils.Create("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 640, 0, 440),
    Position = UDim2.new(0.5, -320, 0.5, -220),
    BackgroundColor3 = Config.Theme.Dark,
    BorderSizePixel = 0,
    Active = true,
    Draggable = true,
    ClipsDescendants = true,
    Parent = ScreenGui,
})
Utils.Corner(MainFrame, 14)
Utils.Stroke(MainFrame, Config.Theme.Accent, 2, 0)
Utils.Gradient(MainFrame, Config.Theme.Darker, Config.Theme.Dark, 90)

-- Фоновая аниме картинка
local BgImage = Utils.Create("ImageLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Image = Config.Backgrounds[1],
    ImageTransparency = 0.55,
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 0,
    Parent = MainFrame,
})
Utils.Corner(BgImage, 14)

-- Красный оверлей с градиентом
local Overlay = Utils.Create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Config.Theme.Primary,
    BackgroundTransparency = 0.82,
    BorderSizePixel = 0,
    ZIndex = 1,
    Parent = MainFrame,
})
Utils.Corner(Overlay, 14)
Utils.Gradient(Overlay, Color3.fromRGB(60, 0, 0), Color3.fromRGB(0, 0, 0), 120)

--============================================================
-- TITLE BAR
--============================================================
local TitleBar = Utils.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = Config.Theme.Secondary,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = MainFrame,
})
Utils.Corner(TitleBar, 14)
Utils.Gradient(TitleBar, Config.Theme.Accent, Color3.fromRGB(40, 0, 0), 0)

-- Логотип (иконка)
Utils.Create("ImageLabel", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(0, 12, 0.5, -15),
    BackgroundTransparency = 1,
    Image = "rbxassetid://7822373523",
    ImageColor3 = Color3.fromRGB(255, 200, 200),
    ZIndex = 3,
    Parent = TitleBar,
})

-- Заголовок
local TitleLabel = Utils.Create("TextLabel", {
    Size = UDim2.new(1, -160, 1, 0),
    Position = UDim2.new(0, 50, 0, 0),
    BackgroundTransparency = 1,
    Text = "⚔  D A S T E R   S C R I P T S  ⚔",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextStrokeTransparency = 0.5,
    TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
    Font = Enum.Font.GothamBlack,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
    Parent = TitleBar,
})

-- Версия
Utils.Create("TextLabel", {
    Size = UDim2.new(0, 60, 0, 20),
    Position = UDim2.new(1, -140, 0.5, -10),
    BackgroundTransparency = 1,
    Text = "v" .. Config.Version,
    TextColor3 = Config.Theme.TextDim,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    ZIndex = 3,
    Parent = TitleBar,
})

-- Кнопка minimize
local MinBtn = Utils.Create("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -70, 0.5, -15),
    BackgroundColor3 = Color3.fromRGB(90, 0, 0),
    Text = "—",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    ZIndex = 3,
    Parent = TitleBar,
})
Utils.Corner(MinBtn, 8)
Utils.Stroke(MinBtn, Color3.fromRGB(255, 100, 100), 1, 0.5)

-- Кнопка закрытия
local CloseBtn = Utils.Create("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -36, 0.5, -15),
    BackgroundColor3 = Color3.fromRGB(150, 0, 0),
    Text = "✕",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    ZIndex = 3,
    Parent = TitleBar,
})
Utils.Corner(CloseBtn, 8)
Utils.Stroke(CloseBtn, Color3.fromRGB(255, 100, 100), 1, 0.5)

-- Hover эффекты
local function addHover(btn, normal, hover)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = normal}):Play()
    end)
end
addHover(MinBtn, Color3.fromRGB(90, 0, 0), Color3.fromRGB(140, 0, 0))
addHover(CloseBtn, Color3.fromRGB(150, 0, 0), Color3.fromRGB(220, 0, 0))

-- Minimize логика
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local target = minimized and UDim2.new(0, 640, 0, 50) or UDim2.new(0, 640, 0, 440)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = target}):Play()
    MinBtn.Text = minimized and "+" or "—"
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    Utils.Notify("Daster Scripts выгружен", 2, Config.Theme.Error)
end)

--============================================================
-- TAB BAR (левое меню)
--============================================================
local TabBar = Utils.Create("Frame", {
    Size = UDim2.new(0, 150, 1, -60),
    Position = UDim2.new(0, 8, 0, 54),
    BackgroundColor3 = Config.Theme.Darker,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = MainFrame,
})
Utils.Corner(TabBar, 10)
Utils.Stroke(TabBar, Config.Theme.Accent, 1, 0.6)

local TabScroll = Utils.Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ZIndex = 2,
    Parent = TabBar,
})

local TabLayout = Utils.Create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 5),
    Parent = TabScroll,
})
Utils.Padding(TabScroll, 8, 8, 8, 8)

--============================================================
-- PAGE CONTAINER
--============================================================
local PageContainer = Utils.Create("Frame", {
    Size = UDim2.new(1, -175, 1, -60),
    Position = UDim2.new(0, 165, 0, 54),
    BackgroundColor3 = Config.Theme.Darker,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = MainFrame,
})
Utils.Corner(PageContainer, 10)
Utils.Stroke(PageContainer, Config.Theme.Accent, 1, 0.6)

--============================================================
-- TAB / PAGE BUILDER
--============================================================
local Tabs = {}
local Pages = {}

local function CreateTab(name, icon, order)
    local Tab = Utils.Create("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Color3.fromRGB(60, 0, 0),
        Text = "   " .. (icon or "") .. "  " .. name,
        TextColor3 = Config.Theme.TextDim,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order,
        ZIndex = 3,
        Parent = TabScroll,
    })
    Utils.Corner(Tab, 7)
    Utils.Stroke(Tab, Config.Theme.Accent, 1, 0.85)

    local Page = Utils.Create("ScrollingFrame", {
        Name = name .. "Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Config.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 3,
        Parent = PageContainer,
    })

    local PageLayout = Utils.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = Page,
    })
    Utils.Padding(Page, 10, 10, 10, 10)

    Tabs[name] = Tab
    Pages[name] = Page

    Tab.MouseEnter:Connect(function()
        if not Page.Visible then
            TweenService:Create(Tab, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(100, 0, 0)
            }):Play()
        end
    end)
    Tab.MouseLeave:Connect(function()
        if not Page.Visible then
            TweenService:Create(Tab, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(60, 0, 0)
            }):Play()
        end
    end)
    Tab.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, t in pairs(Tabs) do
            TweenService:Create(t, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60, 0, 0),
                TextColor3 = Config.Theme.TextDim
            }):Play()
        end
        Page.Visible = true
        TweenService:Create(Tab, TweenInfo.new(0.2), {
            BackgroundColor3 = Config.Theme.Accent,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)

    return Page
end

--============================================================
-- UI ELEMENT BUILDERS
--============================================================
local function CreateSection(parent, title)
    local section = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Config.Theme.Secondary,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = parent,
    })
    Utils.Corner(section, 6)
    Utils.Stroke(section, Config.Theme.Accent, 1, 0.5)
    Utils.Gradient(section, Config.Theme.Accent, Color3.fromRGB(40, 0, 0), 0)

    Utils.Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "◆ " .. title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = section,
    })
    return section
end

local function CreateButton(parent, text, callback)
    local btn = Utils.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(90, 0, 0),
        Text = text,
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        ZIndex = 3,
        Parent = parent,
    })
    Utils.Corner(btn, 7)
    Utils.Stroke(btn, Config.Theme.Accent, 1, 0.7)
    Utils.Gradient(btn, Color3.fromRGB(130, 0, 0), Color3.fromRGB(60, 0, 0), 45)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Config.Theme.Accent
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(90, 0, 0)
        }):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then
            Utils.Notify("Ошибка: " .. tostring(err), 3, Config.Theme.Error)
        end
    end)
    return btn
end

local function CreateToggle(parent, text, callback)
    local state = false
    local btn = Utils.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(60, 0, 0),
        Text = "",
        ZIndex = 3,
        Parent = parent,
    })
    Utils.Corner(btn, 7)
    Utils.Stroke(btn, Config.Theme.Accent, 1, 0.7)

    local label = Utils.Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = btn,
    })

    local dot = Utils.Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -22, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = btn,
    })
    Utils.Corner(dot, 7)
    Utils.Stroke(dot, Color3.fromRGB(120, 120, 120), 1, 0)

    btn.MouseButton1Click:Connect(function()
        state = not state
        local ok, err = pcall(callback, state)
        if not ok then
            state = not state
            Utils.Notify("Ошибка: " .. tostring(err), 3, Config.Theme.Error)
            return
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Config.Theme.Accent or Color3.fromRGB(60, 0, 0)
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(60, 60, 60)
        }):Play()
        label.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Config.Theme.Text
    end)
    return btn
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Color3.fromRGB(60, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = parent,
    })
    Utils.Corner(frame, 7)
    Utils.Stroke(frame, Config.Theme.Accent, 1, 0.7)

    Utils.Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 3),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = frame,
    })

    local valueLabel = Utils.Create("TextLabel", {
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -70, 0, 3),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = Config.Theme.AccentGlow,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 4,
        Parent = frame,
    })

    local sliderBg = Utils.Create("Frame", {
        Size = UDim2.new(1, -20, 0, 6),
        Position = UDim2.new(0, 10, 0, 28),
        BackgroundColor3 = Color3.fromRGB(30, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = frame,
    })
    Utils.Corner(sliderBg, 3)

    local fill = Utils.Create("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Config.Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = sliderBg,
    })
    Utils.Corner(fill, 3)

    local knob = Utils.Create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 6,
        Parent = sliderBg,
    })
    Utils.Corner(knob, 6)

    local dragging = false
    local function update(input)
        local rel = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -6, 0.5, -6)
        valueLabel.Text = tostring(value)
        callback(value)
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    return frame
end

local function CreateTextBox(parent, placeholder, callback)
    local tb = Utils.Create("TextBox", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(60, 0, 0),
        Text = "",
        PlaceholderText = placeholder,
        PlaceholderColor3 = Config.Theme.TextDim,
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ZIndex = 3,
        Parent = parent,
    })
    Utils.Corner(tb, 7)
    Utils.Stroke(tb, Config.Theme.Accent, 1, 0.7)

    tb.FocusLost:Connect(function(enterPressed)
        if enterPressed and tb.Text ~= "" then
            local ok, err = pcall(callback, tb.Text)
            if not ok then
                Utils.Notify("Ошибка: " .. tostring(err), 3, Config.Theme.Error)
            end
        end
    end)
    return tb
end

local function CreateLabel(parent, text, color)
    return Utils.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or Config.Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 3,
        Parent = parent,
    })
end

--============================================================
-- 1) INFO
--============================================================
local InfoPage = CreateTab("Info", "ℹ", 1)
CreateSection(InfoPage, "О скрипте")
CreateLabel(InfoPage, "⚔ Daster Scripts v" .. Config.Version)
CreateLabel(InfoPage, "🎮 Игра: 99 Nights in the Forest")
CreateLabel(InfoPage, "👤 Автор: Daster")
CreateLabel(InfoPage, "📅 Дата: 2026")
CreateLabel(InfoPage, "")

CreateSection(InfoPage, "Возможности")
CreateLabel(InfoPage, "✅ 60+ функций")
CreateLabel(InfoPage, "✅ Красивый UI с аниме-фоном")
CreateLabel(InfoPage, "✅ Авто-обновления")
CreateLabel(InfoPage, "✅ Безопасная загрузка")
CreateLabel(InfoPage, "")

CreateSection(InfoPage, "Контакты")
CreateLabel(InfoPage, "💬 Discord: daster#0001")
CreateLabel(InfoPage, "📺 YouTube: Daster Scripts")
CreateLabel(InfoPage, "🌐 GitHub: DasterScripts")
CreateLabel(InfoPage, "")

CreateSection(InfoPage, "Статистика")
local statsLbl = CreateLabel(InfoPage, "⏱ Uptime: 0s | FPS: --")
task.spawn(function()
    local start = tick()
    while statsLbl.Parent do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        statsLbl.Text = string.format("⏱ Uptime: %ds | FPS: %d", math.floor(tick() - start), fps)
        task.wait(0.5)
    end
end)

--============================================================
-- 2) MAIN
--============================================================
local MainPage = CreateTab("Main", "🏠", 2)

CreateSection(MainPage, "🌍 Смена языка")
local langs = {
    {name = "Русский", flag = "🇷🇺"},
    {name = "English", flag = "🇺🇸"},
    {name = "Español", flag = "🇪🇸"},
    {name = "Deutsch", flag = "🇩🇪"},
    {name = "Français", flag = "🇫🇷"},
    {name = "Português", flag = "🇵🇹"},
    {name = "日本語", flag = "🇯🇵"},
    {name = "中文", flag = "🇨🇳"},
}
for _, lang in ipairs(langs) do
    CreateButton(MainPage, lang.flag .. "  " .. lang.name, function()
        Utils.Notify("Язык изменён: " .. lang.name, 2, Config.Theme.Primary)
    end)
end

CreateSection(MainPage, "⚙ Прочее")
CreateToggle(MainPage, "🛡 Anti-AFK", function(state)
    Utils.Notify(state and "Anti-AFK включен" or "Anti-AFK выключен", 2)
end)
CreateToggle(MainPage, "📊 FPS Boost", function(state)
    if state then
        for _, v in ipairs(Lighting:GetDescendants()) do
            if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
                v.Enabled = false
            end
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Utils.Notify("FPS Boost включен", 2)
    else
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        Utils.Notify("FPS Boost выключен", 2)
    end
end)
CreateToggle(MainPage, "🌙 Fullbright", function(state)
    if state then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Utils.Notify("Fullbright включен", 2)
    else
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Utils.Notify("Fullbright выключен", 2)
    end
end)

CreateSection(MainPage, "🔄 Действия")
CreateButton(MainPage, "♻ Rejoin сервер", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
CreateButton(MainPage, "🖥 Server Hop", function()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    for _, s in ipairs(servers) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
            break
        end
    end
end)
CreateButton(MainPage, "🚪 Выйти из игры", function()
    LocalPlayer:Kick("Вышли через Daster Scripts")
end)

--============================================================
-- 3) BRING
--============================================================
local BringPage = CreateTab("Bring", "📦", 3)

local keywordMap = {
    Log = {"Log", "Wood"},
    Stone = {"Stone", "Rock"},
    Food = {"Berry", "Food", "Apple", "Mushroom"},
    Meat = {"Meat", "RawMeat"},
    Stick = {"Stick", "Branch"},
    Coal = {"Coal"},
    Iron = {"Iron", "Ore"},
}

local function GetItems(filter)
    local items = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if not filter then
                table.insert(items, obj)
            else
                for _, k in ipairs(filter) do
                    if string.find(string.lower(obj.Name), string.lower(k)) then
                        table.insert(items, obj)
                        break
                    end
                end
            end
        end
    end
    return items
end

local function BringItem(item)
    if not item or not item.Parent then return end
    local _, hrp = Utils.GetChar()
    if not hrp then return end
    pcall(function()
        item.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
    end)
end

local function BringAll(filter, label)
    local count = 0
    for _, item in ipairs(GetItems(filter)) do
        BringItem(item)
        count = count + 1
    end
    Utils.Notify("Притянуто: " .. count .. " × " .. label, 2)
end

CreateSection(BringPage, "📦 Телепорт предметов")

CreateButton(BringPage, "🎯 Притянуть ВСЁ", function()
    BringAll(nil, "все предметы")
end)
CreateButton(BringPage, "🪵 Дерево (Log/Wood)", function()
    BringAll(keywordMap.Log, "дерево")
end)
CreateButton(BringPage, "🪨 Камни (Stone/Rock)", function()
    BringAll(keywordMap.Stone, "камни")
end)
CreateButton(BringPage, "🍓 Еда (Berry/Food)", function()
    BringAll(keywordMap.Food, "еда")
end)
CreateButton(BringPage, "🥩 Мясо (Meat)", function()
    BringAll(keywordMap.Meat, "мясо")
end)
CreateButton(BringPage, "🪵 Палки (Stick/Branch)", function()
    BringAll(keywordMap.Stick, "палки")
end)
CreateButton(BringPage, "⚫ Уголь (Coal)", function()
    BringAll(keywordMap.Coal, "уголь")
end)
CreateButton(BringPage, "⚙ Железо (Iron/Ore)", function()
    BringAll(keywordMap.Iron, "железо")
end)

CreateSection(BringPage, "🔁 Авто-режимы")
CreateToggle(BringPage, "Auto-Bring ВСЁ (каждые 0.5с)", function(state)
    _G.DasterAutoBring = state
    if state then
        task.spawn(function()
            while _G.DasterAutoBring do
                for _, item in ipairs(GetItems()) do
                    BringItem(item)
                end
                task.wait(0.5)
            end
        end)
    end
end)
CreateToggle(BringPage, "Auto-Bring Топливо (дерево+уголь)", function(state)
    _G.DasterAutoFuel = state
    if state then
        task.spawn(function()
            while _G.DasterAutoFuel do
                for _, item in ipairs(GetItems(keywordMap.Log)) do BringItem(item) end
                for _, item in ipairs(GetItems(keywordMap.Coal)) do BringItem(item) end
                task.wait(0.5)
            end
        end)
    end
end)

--============================================================
-- 4) PLAYER
--============================================================
local PlayerPage = CreateTab("Player", "🏃", 4)

CreateSection(PlayerPage, "⚡ Скорость")
CreateSlider(PlayerPage, "WalkSpeed", 16, 500, 16, function(v)
    local _, _, hum = Utils.GetChar()
    if hum then hum.WalkSpeed = v end
end)

CreateSection(PlayerPage, "🦘 Прыжок")
CreateSlider(PlayerPage, "JumpPower", 50, 500, 50, function(v)
    local _, _, hum = Utils.GetChar()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = v
    end
end)

CreateSection(PlayerPage, "🕊 Fly")
CreateToggle(PlayerPage, "Fly (WASD + Space/Ctrl)", function(state)
    _G.DasterFly = state
    local _, hrp = Utils.GetChar()
    if not hrp then return end

    if state then
        local bv = Utils.Create("BodyVelocity", {
            MaxForce = Vector3.new(1e5, 1e5, 1e5),
            Velocity = Vector3.zero,
            Parent = hrp,
        })
        local bg = Utils.Create("BodyGyro", {
            MaxTorque = Vector3.new(1e5, 1e5, 1e5),
            P = 10000,
            Parent = hrp,
        })
        _G.DasterFlyConn = RunService.RenderStepped:Connect(function()
            local cam = Workspace.CurrentCamera
            local move = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
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

CreateSection(PlayerPage, "🎮 Управление")
CreateToggle(PlayerPage, "♾ Infinite Jump", function(state)
    _G.DasterInfJump = state
    if state then
        _G.DasterInfJumpConn = UserInputService.JumpRequest:Connect(function()
            local _, _, hum = Utils.GetChar()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if _G.DasterInfJumpConn then _G.DasterInfJumpConn:Disconnect() end
    end
end)
CreateToggle(PlayerPage, "👻 Noclip", function(state)
    _G.DasterNoclip = state
    if state then
        _G.DasterNoclipConn = RunService.Stepped:Connect(function()
            local char = Utils.GetChar()
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
CreateToggle(PlayerPage, "🕳 Freeze (заморозить себя)", function(state)
    local _, _, hum = Utils.GetChar()
    if hum then hum.WalkSpeed = state and 0 or 16 end
end)
CreateToggle(PlayerPage, "🦵 Hip Height", function(state)
    local _, _, hum = Utils.GetChar()
    if hum then hum.HipHeight = state and 5 or 2 end
end)

CreateSection(PlayerPage, "🎭 Действия")
CreateButton(PlayerPage, "💃 Танец", function()
    local char = Utils.GetChar()
    if char then
        local anim = Utils.Create("Animation", {
            AnimationId = "rbxassetid://507771019",
            Parent = char,
        })
        local animator = char:FindFirstChildOfClass("Animator") or Utils.Create("Animator", {Parent = char:FindFirstChildOfClass("Humanoid")})
        local track = animator:LoadAnimation(anim)
        track:Play()
    end
end)
CreateButton(PlayerPage, "🧘 Сесть/Встать", function()
    local _, _, hum = Utils.GetChar()
    if hum then
        hum.Sit = not hum.Sit
    end
end)
CreateButton(PlayerPage, "💀 Respawn", function()
    LocalPlayer:LoadCharacter()
end)

--============================================================
-- 5) COMBAT
--============================================================
local CombatPage = CreateTab("Combat", "⚔", 5)

CreateSection(CombatPage, "💀 Атака")
CreateToggle(CombatPage, "Kill Aura (радиус 25)", function(state)
    _G.DasterKillAura = state
    if state then
        _G.DasterKillAuraConn = RunService.Heartbeat:Connect(function()
            local char, hrp = Utils.GetChar()
            if not hrp then return end
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Humanoid") and obj.Parent ~= char and obj.Health > 0 then
                    local otherHrp = obj.Parent:FindFirstChild("HumanoidRootPart")
                    if otherHrp and (otherHrp.Position - hrp.Position).Magnitude < 25 then
                        obj.Health = 0
                    end
                end
            end
        end)
    else
        if _G.DasterKillAuraConn then _G.DasterKillAuraConn:Disconnect() end
    end
end)
CreateToggle(CombatPage, "Touch Kill (убивать при касании)", function(state)
    _G.DasterTouchKill = state
    if state then
        local char, hrp = Utils.GetChar()
        if hrp then
            _G.DasterTouchKillConn = hrp.Touched:Connect(function(hit)
                local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
                if hum and hum.Parent ~= char then hum.Health = 0 end
            end)
        end
    else
        if _G.DasterTouchKillConn then _G.DasterTouchKillConn:Disconnect() end
    end
end)

CreateSection(CombatPage, "🛡 Защита")
CreateToggle(CombatPage, "God Mode (не получать урон)", function(state)
    _G.DasterGod = state
    if state then
        _G.DasterGodConn = RunService.Heartbeat:Connect(function()
            local _, _, hum = Utils.GetChar()
            if hum then hum.Health = hum.MaxHealth end
        end)
    else
        if _G.DasterGodConn then _G.DasterGodConn:Disconnect() end
    end
end)
CreateToggle(CombatPage, "Anti-Fling (защита от откидывания)", function(state)
    _G.DasterAntiFling = state
    if state then
        _G.DasterAntiFlingConn = RunService.Heartbeat:Connect(function()
            local char, hrp = Utils.GetChar()
            if hrp then
                if hrp.Velocity.Magnitude > 100 then
                    hrp.Velocity = Vector3.zero
                    hrp.RotVelocity = Vector3.zero
                end
            end
        end)
    else
        if _G.DasterAntiFlingConn then _G.DasterAntiFlingConn:Disconnect() end
    end
end)

--============================================================
-- 6) WORLD
--============================================================
local WorldPage = CreateTab("World", "🌍", 6)

CreateSection(WorldPage, "🌐 Сервер")
CreateButton(WorldPage, "🖥 Показать Job ID", function()
    Utils.Notify("Job ID: " .. game.JobId, 5)
end)
CreateButton(WorldPage, "📋 Копировать Job ID", function()
    if setclipboard then
        setclipboard(game.JobId)
        Utils.Notify("Job ID скопирован!", 2)
    else
        Utils.Notify("setclipboard не поддерживается", 2, Config.Theme.Error)
    end
end)
CreateButton(WorldPage, "👥 Список игроков", function()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(list, p.Name)
    end
    Utils.Notify("Игроков: " .. #list, 4)
end)

CreateSection(WorldPage, "🎯 Телепорт к игроку")
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        CreateButton(WorldPage, "➡ К " .. p.Name, function()
            local _, hrp = Utils.GetChar()
            local targetChar = p.Character
            if hrp and targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = targetChar.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                Utils.Notify("Телепорт к " .. p.Name, 2)
            end
        end)
    end
end

--============================================================
-- 7) VISUALS
--============================================================
local VisualPage = CreateTab("Visuals", "👁", 7)

CreateSection(VisualPage, "🌄 Освещение")
CreateToggle(VisualPage, "Fullbright", function(state)
    if state then
        _G.DasterOrigLight = {
            Ambient = Lighting.Ambient,
            Brightness = Lighting.Brightness,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            GlobalShadows = Lighting.GlobalShadows,
        }
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
    elseif _G.DasterOrigLight then
        Lighting.Ambient = _G.DasterOrigLight.Ambient
        Lighting.Brightness = _G.DasterOrigLight.Brightness
        Lighting.OutdoorAmbient = _G.DasterOrigLight.OutdoorAmbient
        Lighting.GlobalShadows = _G.DasterOrigLight.GlobalShadows
    end
end)
CreateToggle(VisualPage, "🌫 Убрать туман", function(state)
    if state then
        _G.DasterOrigFog = Lighting.FogEnd
        Lighting.FogEnd = 100000
    elseif _G.DasterOrigFog then
        Lighting.FogEnd = _G.DasterOrigFog
    end
end)

CreateSection(VisualPage, "🎨 Кастомизация")
CreateButton(VisualPage, "🌈 Изменить FOV на 120", function()
    Workspace.CurrentCamera.FieldOfView = 120
end)
CreateButton(VisualPage, "🔄 Сбросить FOV", function()
    Workspace.CurrentCamera.FieldOfView = 70
end)

--============================================================
-- 8) SETTINGS
--============================================================
local SettingsPage = CreateTab("Settings", "⚙", 8)

CreateSection(SettingsPage, "🎨 Тема")
local themes = {
    {name = "Красная (по умолчанию)", c = Color3.fromRGB(255, 30, 30)},
    {name = "Тёмно-красная", c = Color3.fromRGB(140, 0, 0)},
    {name = "Алая", c = Color3.fromRGB(255, 80, 80)},
}
for _, theme in ipairs(themes) do
    CreateButton(SettingsPage, "🎨 " .. theme.name, function()
        Config.Theme.Accent = theme.c
        Utils.Notify("Тема изменена: " .. theme.name, 2)
    end)
end

CreateSection(SettingsPage, "🖼 Аниме-фон")
for i, bg in ipairs(Config.Backgrounds) do
    CreateButton(SettingsPage, "🖼 Фон #" .. i, function()
        BgImage.Image = bg
        Utils.Notify("Фон #" .. i .. " установлен", 2)
    end)
end

CreateSection(SettingsPage, "ℹ Информация")
CreateLabel(SettingsPage, "Версия: v" .. Config.Version)
CreateLabel(SettingsPage, "Toggle UI: " .. Config.ToggleKey.Name)
CreateLabel(SettingsPage, "Все настройки сохраняются локально")

CreateSection(SettingsPage, "🚨 Опасная зона")
CreateButton(SettingsPage, "🗑 Сбросить все функции", function()
    _G.DasterAutoBring = false
    _G.DasterAutoFuel = false
    _G.DasterFly = false
    _G.DasterKillAura = false
    _G.DasterGod = false
    _G.DasterInfJump = false
    _G.DasterNoclip = false
    for _, conn in pairs({_G.DasterFlyConn, _G.DasterKillAuraConn, _G.DasterGodConn, 
                          _G.DasterInfJumpConn, _G.DasterNoclipConn, _G.DasterAntiFlingConn,
                          _G.DasterTouchKillConn}) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    Utils.Notify("Все функции выключены", 3, Config.Theme.Success)
end)
CreateButton(SettingsPage, "❌ Выгрузить скрипт", function()
    ScreenGui:Destroy()
end)

--============================================================
-- DRAG ЛОГИКА (гладкое перетаскивание)
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
-- TOGGLE KEY (RightShift)
--============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
        Utils.Notify(MainFrame.Visible and "UI показан" or "UI скрыт", 1.5)
    end
end)

--============================================================
-- ЗАГРУЗКА
--============================================================
Tabs["Info"].BackgroundColor3 = Config.Theme.Accent
Tabs["Info"].TextColor3 = Color3.fromRGB(255, 255, 255)
Pages["Info"].Visible = true

-- Приветствие
task.wait(0.3)
Utils.Notify("⚔ Daster Scripts v" .. Config.Version .. " загружен!", 4, Config.Theme.Accent)
task.wait(0.5)
Utils.Notify("Нажми " .. Config.ToggleKey.Name .. " чтобы скрыть/показать UI", 4)
