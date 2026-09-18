--[[
    ================================================================
    ⚔ DASTER SCRIPTS v3.0 — BOMBEZNO EDITION ⚔
    Game: 99 Nights in the Forest
    Author: Daster
    NOTE: Server values CANNOT be changed from client.
    This script AUTO-FARMS everything legally + tries remotes.
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
    Version     = "3.0",
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
        Gem         = Color3.fromRGB(100, 200, 255),
        Gold        = Color3.fromRGB(255, 200, 50),
    },
    Backgrounds = {
        "rbxassetid://13132981571",
        "rbxassetid://13132981500",
        "rbxassetid://13132981400",
    },
    ToggleKey   = Enum.KeyCode.RightShift,
    FarmSpeed   = 0.15, -- скорость авто-фарма (сек)
}

--============================================================
-- STATE (все включенные функции)
--============================================================
local State = {
    AutoFarmAll      = false,
    AutoFarmGems     = false,
    AutoFarmResources= false,
    AutoCollect      = false,
    AutoSkipNights   = false,
    AutoClass        = false,
    KillAura         = false,
    GodMode          = false,
    Noclip           = false,
    Fly              = false,
    ESPGems          = false,
    ESPPlayers       = false,
}

--============================================================
-- UTILS
--============================================================
local Utils = {}

function Utils.Create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
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
        Size = UDim2.new(0, 300, 0, 50),
        Position = UDim2.new(1, -320, 0, 60),
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
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 51,
        Parent = notify,
    })

    for _, child in ipairs(main:GetChildren()) do
        if child:IsA("Frame") and child ~= notify and child.ZIndex == 50 then
            TweenService:Create(child, TweenInfo.new(0.2), {
                Position = child.Position + UDim2.new(0, 0, 0, 58)
            }):Play()
        end
    end

    TweenService:Create(notify, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -320, 0, 60)
    }):Play()

    task.delay(duration, function()
        if notify and notify.Parent then
            TweenService:Create(notify, TweenInfo.new(0.3), {
                Position = UDim2.new(1, 0, 0, 60),
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.3)
            notify:Destroy()
        end
    end)
end

function Utils.GetChar()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    return char, char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
end

--============================================================
-- REMOTE EVENT DETECTOR (находит все интересные remotes)
--============================================================
local RemoteScanner = {}

function RemoteScanner.Scan()
    local found = {
        Gems = {},
        Days = {},
        Classes = {},
        All = {},
    }
    local keywords = {
        Gems = {"gem", "diamond", "crystal", "currency", "coin", "reward", "addgem"},
        Days = {"day", "night", "wave", "skip", "advance", "progress"},
        Classes = {"class", "kit", "ability", "role", "character", "select", "choose", "pick"},
    }

    local scanTargets = {ReplicatedStorage}
    for _, plr in ipairs(Players:GetPlayers()) do
        table.insert(scanTargets, plr)
    end

    for _, target in ipairs(scanTargets) do
        for _, obj in ipairs(target:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(found.All, obj)
                local n = string.lower(obj.Name)
                for category, kws in pairs(keywords) do
                    for _, k in ipairs(kws) do
                        if string.find(n, k) then
                            table.insert(found[category], obj)
                            break
                        end
                    end
                end
            end
        end
    end
    return found
end

-- Сохранённые remotes
local Remotes = nil

function RemoteScanner.Get()
    if not Remotes then
        Remotes = RemoteScanner.Scan()
    end
    return Remotes
end

--============================================================
-- GEM FARMING (реально фармит)
--============================================================
local Farm = {}

local GEM_KEYWORDS = {"gem", "diamond", "crystal", "shard", "coin", "orb", "pickup"}
local RESOURCE_KEYWORDS = {
    Log = {"log", "wood", "tree", "trunk"},
    Stone = {"stone", "rock", "boulder"},
    Food = {"berry", "food", "apple", "mushroom", "eat"},
    Meat = {"meat", "raw"},
    Stick = {"stick", "branch"},
    Coal = {"coal"},
    Iron = {"iron", "ore"},
}

function Farm.FindByName(keywords)
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

function Farm.FindGems()
    return Farm.FindByName(GEM_KEYWORDS)
end

function Farm.TeleportToPlayer(obj)
    local _, hrp = Utils.GetChar()
    if not hrp or not obj or not obj.Parent then return false end
    local ok = pcall(function()
        if obj:IsA("BasePart") then
            obj.CFrame = hrp.CFrame + Vector3.new(0, 4, 0)
        elseif obj:IsA("Model") then
            local pp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if pp then obj:PivotTo(hrp.CFrame + Vector3.new(0, 4, 0)) end
        end
    end)
    return ok
end

function Farm.TouchGem(gem)
    -- Попытка вызвать Touched вручную (иногда помогает "подобрать")
    local _, hrp = Utils.GetChar()
    if not hrp then return end
    local part = gem:IsA("Model") and (gem.PrimaryPart or gem:FindFirstChildWhichIsA("BasePart")) or gem
    if part then
        pcall(function()
            hrp.CFrame = part.CFrame + Vector3.new(0, 2, 0)
        end)
        -- Триггерим Touched на всех частях персонажа
        pcall(function()
            for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") and part.Touched then
                    firetouchinterest(p, part, 0)
                    firetouchinterest(p, part, 1)
                end
            end
        end)
    end
end

--============================================================
-- AUTO-SKIP NIGHTS (агрессивный)
--============================================================
function Farm.SkipNights()
    -- 1. Клиентский сдвиг времени
    if Lighting.ClockTime < 18 and Lighting.ClockTime > 6 then
        Lighting.ClockTime = 20
    end
    
    -- 2. Триггерим все NumberValue с day/night
    for _, obj in ipairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                local n = string.lower(obj.Name)
                if string.find(n, "day") or string.find(n, "night") 
                or string.find(n, "wave") or string.find(n, "progress") then
                    obj.Value = obj.Value + 1
                end
            end
        end)
    end
    
    -- 3. Fire все Day remotes с +1
    local r = RemoteScanner.Get()
    for _, remote in ipairs(r.Days) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(1)
                remote:FireServer()
                remote:FireServer("skip")
            else
                remote:InvokeServer(1)
            end
        end)
    end
end

--============================================================
-- CLASS GIVER (попытка через remotes)
--============================================================
function Farm.TryGiveClass(className)
    local r = RemoteScanner.Get()
    local fired = 0
    for _, remote in ipairs(r.Classes) do
        pcall(function()
            -- Пробуем разные варианты аргументов
            if remote:IsA("RemoteEvent") then
                remote:FireServer(className)
                remote:FireServer("equip", className)
                remote:FireServer({class = className})
            else
                remote:InvokeServer(className)
                remote:InvokeServer("equip", className)
            end
            fired = fired + 1
        end)
    end
    return fired
end

function Farm.TryGiveGem(amount)
    local r = RemoteScanner.Get()
    for _, remote in ipairs(r.Gems) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(amount)
                remote:FireServer("add", amount)
                remote:FireServer("gem", amount)
            else
                remote:InvokeServer(amount)
                remote:InvokeServer("add", amount)
            end
        end)
    end
end

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
    Size = UDim2.new(0, 660, 0, 460),
    Position = UDim2.new(0.5, -330, 0.5, -230),
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

Utils.Create("ImageLabel", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(0, 12, 0.5, -15),
    BackgroundTransparency = 1,
    Image = "rbxassetid://7822373523",
    ImageColor3 = Color3.fromRGB(255, 200, 200),
    ZIndex = 3,
    Parent = TitleBar,
})

Utils.Create("TextLabel", {
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

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local target = minimized and UDim2.new(0, 660, 0, 50) or UDim2.new(0, 660, 0, 460)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = target}):Play()
    MinBtn.Text = minimized and "+" or "—"
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

--============================================================
-- TAB BAR
--============================================================
local TabBar = Utils.Create("Frame", {
    Size = UDim2.new(0, 155, 1, -60),
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

Utils.Create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 5),
    Parent = TabScroll,
})
Utils.Padding(TabScroll, 8, 8, 8, 8)

--============================================================
-- PAGE CONTAINER
--============================================================
local PageContainer = Utils.Create("Frame", {
    Size = UDim2.new(1, -180, 1, -60),
    Position = UDim2.new(0, 170, 0, 54),
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

    Utils.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = Page,
    })
    Utils.Padding(Page, 10, 10, 10, 10)

    Tabs[name] = Tab
    Pages[name] = Page

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
-- UI ELEMENTS
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
end

local function CreateButton(parent, text, callback, customColor)
    local btn = Utils.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = customColor or Color3.fromRGB(90, 0, 0),
        Text = text,
        TextColor3 = Config.Theme.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        ZIndex = 3,
        Parent = parent,
    })
    Utils.Corner(btn, 7)
    Utils.Stroke(btn, Config.Theme.Accent, 1, 0.7)
    if not customColor then
        Utils.Gradient(btn, Color3.fromRGB(130, 0, 0), Color3.fromRGB(60, 0, 0), 45)
    end

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Config.Theme.Accent
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = customColor or Color3.fromRGB(90, 0, 0)
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
-- 1) AUTO-FARM (главная вкладка)
--============================================================
local FarmPage = CreateTab("AutoFarm", "🤖", 1)

CreateSection(FarmPage, "🔥 МЕГА-ФАРМ (всё сразу)")
CreateLabel(FarmPage, "Включает ВСЁ: алмазы + ресурсы + авто-сбор + ночи", Color3.fromRGB(255, 200, 100))
CreateButton(FarmPage, "▶ ЗАПУСТИТЬ ВСЁ (BOMBEZNO)", function()
    State.AutoFarmAll = true
    State.AutoFarmGems = true
    State.AutoFarmResources = true
    State.AutoCollect = true
    State.AutoSkipNights = true
    Utils.Notify("🔥 МЕГА-ФАРМ ЗАПУЩЕН!", 4, Config.Theme.Success)
    
    -- Основной цикл фарма
    task.spawn(function()
        while State.AutoFarmAll do
            -- 1. Тащим алмазы
            if State.AutoFarmGems then
                for _, gem in ipairs(Farm.FindGems()) do
                    Farm.TeleportToPlayer(gem)
                    Farm.TouchGem(gem)
                end
            end
            
            -- 2. Тащим ресурсы
            if State.AutoFarmResources then
                for _, kws in pairs(RESOURCE_KEYWORDS) do
                    for _, item in ipairs(Farm.FindByName(kws)) do
                        Farm.TeleportToPlayer(item)
                    end
                end
            end
            
            -- 3. Скипаем ночи
            if State.AutoSkipNights then
                Farm.SkipNights()
            end
            
            task.wait(Config.FarmSpeed)
        end
    end)
end)

CreateButton(FarmPage, "⏹ ОСТАНОВИТЬ ВСЁ", function()
    State.AutoFarmAll = false
    State.AutoFarmGems = false
    State.AutoFarmResources = false
    State.AutoCollect = false
    State.AutoSkipNights = false
    Utils.Notify("⏹ Фарм остановлен", 3, Config.Theme.Error)
end, Color3.fromRGB(150, 0, 0))

CreateSection(FarmPage, "💎 Алмазы")
CreateToggle(FarmPage, "Авто-притягивание алмазов", function(s)
    State.AutoFarmGems = s
    if s then
        task.spawn(function()
            while State.AutoFarmGems do
                for _, gem in ipairs(Farm.FindGems()) do
                    Farm.TeleportToPlayer(gem)
                end
                task.wait(0.2)
            end
        end)
    end
end)
CreateToggle(FarmPage, "🧲 Авто-сбор (firetouchinterest)", function(s)
    State.AutoCollect = s
    if s then
        task.spawn(function()
            while State.AutoCollect do
                for _, gem in ipairs(Farm.FindGems()) do
                    Farm.TouchGem(gem)
                end
                task.wait(0.1)
            end
        end)
    end
end)
CreateButton(FarmPage, "💎 Притянуть ВСЕ алмазы (разово)", function()
    local gems = Farm.FindGems()
    for _, g in ipairs(gems) do
        Farm.TeleportToPlayer(g)
        Farm.TouchGem(g)
    end
    Utils.Notify("Притянуто алмазов: " .. #gems, 2)
end)

CreateSection(FarmPage, "🪵 Ресурсы")
CreateToggle(FarmPage, "Авто-притягивание ВСЕХ ресурсов", function(s)
    State.AutoFarmResources = s
    if s then
        task.spawn(function()
            while State.AutoFarmResources do
                for _, kws in pairs(RESOURCE_KEYWORDS) do
                    for _, item in ipairs(Farm.FindByName(kws)) do
                        Farm.TeleportToPlayer(item)
                    end
                end
                task.wait(0.3)
            end
        end)
    end
end)

CreateSection(FarmPage, "📊 Статистика")
local gemStats = CreateLabel(FarmPage, "💎 Алмазов найдено: 0", Config.Theme.Gem)
local resStats = CreateLabel(FarmPage, "📦 Ресурсов найдено: 0", Config.Theme.Gold)
task.spawn(function()
    while gemStats.Parent do
        pcall(function()
            gemStats.Text = "💎 Алмазов найдено: " .. #Farm.FindGems()
            local totalRes = 0
            for _, kws in pairs(RESOURCE_KEYWORDS) do
                totalRes = totalRes + #Farm.FindByName(kws)
            end
            resStats.Text = "📦 Ресурсов найдено: " .. totalRes
        end)
        task.wait(2)
    end
end)

--============================================================
-- 2) 💎 GEMS (Server-side attempt)
--============================================================
local GemsPage = CreateTab("Gems", "💎", 2)

CreateSection(GemsPage, "⚠ ВАЖНО")
CreateLabel(GemsPage, "Алмазы хранятся на СЕРВЕРЕ. Клиент не может их менять напрямую.", Color3.fromRGB(255, 200, 100))
CreateLabel(GemsPage, "Ниже — попытки через RemoteEvent. Может не сработать.", Color3.fromRGB(255, 200, 100))

CreateSection(GemsPage, "🎯 Remote-атака (экспериментально)")
CreateTextBox(GemsPage, "Введи количество (например 999999)", function(text)
    local num = tonumber(text)
    if not num then
        Utils.Notify("Введи число!", 2, Config.Theme.Error)
        return
    end
    Farm.TryGiveGem(num)
    Utils.Notify("Отправлено remote-запросов на " .. num .. " алмазов", 3)
end)
CreateButton(GemsPage, "🚀 Попробовать +999999 алмазов", function()
    Farm.TryGiveGem(999999)
end)
CreateButton(GemsPage, "🚀 Попробовать +1000 алмазов", function()
    Farm.TryGiveGem(1000)
end)
CreateButton(GemsPage, "🔍 Сканировать все RemoteEvent", function()
    Remotes = RemoteScanner.Scan()
    Utils.Notify("Всего remotes: " .. #Remotes.All, 3)
    Utils.Notify("💎 Gem remotes: " .. #Remotes.Gems, 3)
    Utils.Notify("🌙 Day remotes: " .. #Remotes.Days, 3)
    Utils.Notify("🎒 Class remotes: " .. #Remotes.Classes, 3)
end)

CreateSection(GemsPage, "👁 Визуально (только отображение)")
CreateTextBox(GemsPage, "Показать число (не реально)", function(text)
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return end
    local changed = 0
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("TextLabel") then
            local n = string.lower(gui.Name)
            if string.find(n, "gem") or string.find(n, "diamond") or string.find(n, "currency") then
                pcall(function() gui.Text = text end)
                changed = changed + 1
            end
        end
    end
    Utils.Notify("Изменено меток: " .. changed .. " (только визуально)", 3)
end)

--============================================================
-- 3) 🌙 DAYS (Server-side attempt)
--============================================================
local DaysPage = CreateTab("Days", "🌙", 3)

CreateSection(DaysPage, "⚠ ВАЖНО")
CreateLabel(DaysPage, "Дни считает СЕРВЕР. Клиент может только ускорить визуально.", Color3.fromRGB(255, 200, 100))

CreateSection(DaysPage, "⏩ Ускорение")
CreateToggle(DaysPage, "Auto-Skip Nights (агрессивно)", function(s)
    State.AutoSkipNights = s
    if s then
        task.spawn(function()
            while State.AutoSkipNights do
                Farm.SkipNights()
                task.wait(0.5)
            end
        end)
    end
end)
CreateToggle(DaysPage, "⚡ Ускорить время (ClockTime x20)", function(s)
    if s then
        task.spawn(function()
            while _G.DasterSpeedTime2 ~= false do
                Lighting.ClockTime = Lighting.ClockTime + 1
                if Lighting.ClockTime > 24 then Lighting.ClockTime = 0 end
                task.wait(0.05)
            end
        end)
        _G.DasterSpeedTime2 = true
    else
        _G.DasterSpeedTime2 = false
    end
end)

CreateSection(DaysPage, "🎯 Remote-атака")
CreateTextBox(DaysPage, "Введи номер дня (например 999)", function(text)
    local num = tonumber(text)
    if not num then
        Utils.Notify("Введи число!", 2, Config.Theme.Error)
        return
    end
    local r = RemoteScanner.Get()
    for _, remote in ipairs(r.Days) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(num)
                remote:FireServer("set", num)
            else
                remote:InvokeServer(num)
            end
        end)
    end
    Utils.Notify("Отправлено запросов на Day " .. num, 3)
end)
CreateButton(DaysPage, "🚀 Day 999 (remote)", function()
    local r = RemoteScanner.Get()
    for _, remote in ipairs(r.Days) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(999)
            else
                remote:InvokeServer(999)
            end
        end)
    end
end)
CreateButton(DaysPage, "🌅 Утро (6:00) локально", function()
    Lighting.ClockTime = 6
end)
CreateButton(DaysPage, "🌙 Ночь (20:00) локально", function()
    Lighting.ClockTime = 20
end)

--============================================================
-- 4) 🎒 CLASSES (выдача классов)
--============================================================
local ClassesPage = CreateTab("Classes", "🎒", 4)

CreateSection(ClassesPage, "⚠ ВАЖНО")
CreateLabel(ClassesPage, "Классы выдаёт СЕРВЕР. Ниже — попытки через RemoteEvent.", Color3.fromRGB(255, 200, 100))
CreateLabel(ClassesPage, "Если не сработает — значит сервер защищён.", Color3.fromRGB(255, 200, 100))

CreateSection(ClassesPage, "🎒 Популярные классы")
local popularClasses = {
    "Warrior", "Mage", "Archer", "Knight", "Assassin", "Healer", "Tank", "Rogue",
    "Воин", "Маг", "Лучник", "Рыцарь", "Убийца", "Лекарь", "Танк", "Разбойник",
}
for _, cls in ipairs(popularClasses) do
    CreateButton(ClassesPage, "🎯 Получить класс: " .. cls, function()
        local fired = Farm.TryGiveClass(cls)
        Utils.Notify("Отправлено remote-запросов: " .. fired .. " → " .. cls, 3)
    end)
end

CreateSection(ClassesPage, "✏ Свой класс")
CreateTextBox(ClassesPage, "Введи название класса", function(text)
    local fired = Farm.TryGiveClass(text)
    Utils.Notify("Попытка выдать: " .. text .. " (" .. fired .. " remotes)", 3)
end)
CreateButton(ClassesPage, "🚀 Выдать ВСЕ классы сразу", function()
    local r = RemoteScanner.Get()
    for _, cls in ipairs(popularClasses) do
        Farm.TryGiveClass(cls)
    end
    Utils.Notify("Отправлены все классы!", 3)
end)

CreateSection(ClassesPage, "🔍 Скан существующих классов")
CreateButton(ClassesPage, "Найти все Tools у игроков", function()
    local tools = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, tool in ipairs(p.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    table.insert(tools, tool.Name)
                end
            end
        end
    end
    if #tools > 0 then
        Utils.Notify("Найдено: " .. table.concat(tools, ", "), 5)
    else
        Utils.Notify("Tools не найдены", 2)
    end
end)
CreateButton(ClassesPage, "🎁 Копировать все Tools из ReplicatedStorage", function()
    local count = 0
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Tool") then
            pcall(function()
                local clone = obj:Clone()
                clone.Parent = LocalPlayer.Backpack
                count = count + 1
            end)
        end
    end
    Utils.Notify("Скопировано Tools: " .. count, 3)
end)

--============================================================
-- 5) PLAYER
--============================================================
local PlayerPage = CreateTab("Player", "🏃", 5)

CreateSection(PlayerPage, "⚡ Скорость и прыжок")
CreateButton(PlayerPage, "⚡ Speed 100", function()
    local _, _, hum = Utils.GetChar()
    if hum then hum.WalkSpeed = 100 end
end)
CreateButton(PlayerPage, "⚡ Speed 200", function()
    local _, _, hum = Utils.GetChar()
    if hum then hum.WalkSpeed = 200 end
end)
CreateButton(PlayerPage, "🐢 Speed 16", function()
    local _, _, hum = Utils.GetChar()
    if hum then hum.WalkSpeed = 16 end
end)
CreateButton(PlayerPage, "🦘 JumpPower 200", function()
    local _, _, hum = Utils.GetChar()
    if hum then hum.UseJumpPower = true; hum.JumpPower = 200 end
end)

CreateSection(PlayerPage, "🕊 Летать / Noclip")
CreateToggle(PlayerPage, "Fly (WASD + Space/Ctrl)", function(state)
    State.Fly = state
    local _, hrp = Utils.GetChar()
    if not hrp then return end
    if state then
        local bv = Utils.Create("BodyVelocity", {
            MaxForce = Vector3.new(1e5, 1e5, 1e5), Velocity = Vector3.zero, Parent = hrp,
        })
        local bg = Utils.Create("BodyGyro", {
            MaxTorque = Vector3.new(1e5, 1e5, 1e5), P = 10000, Parent = hrp,
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
CreateToggle(PlayerPage, "Noclip", function(state)
    State.Noclip = state
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

CreateSection(PlayerPage, "🛡 Защита")
CreateToggle(PlayerPage, "God Mode (бессмертие)", function(state)
    State.GodMode = state
    if state then
        _G.DasterGodConn = RunService.Heartbeat:Connect(function()
            local _, _, hum = Utils.GetChar()
            if hum then hum.Health = hum.MaxHealth end
        end)
    else
        if _G.DasterGodConn then _G.DasterGodConn:Disconnect() end
    end
end)
CreateToggle(PlayerPage, "Infinite Jump", function(state)
    if state then
        _G.DasterInfJumpConn = UserInputService.JumpRequest:Connect(function()
            local _, _, hum = Utils.GetChar()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if _G.DasterInfJumpConn then _G.DasterInfJumpConn:Disconnect() end
    end
end)

--============================================================
-- 6) COMBAT
--============================================================
local CombatPage = CreateTab("Combat", "⚔", 6)

CreateSection(CombatPage, "💀 Атака")
CreateToggle(CombatPage, "Kill Aura (25 studs)", function(state)
    State.KillAura = state
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
CreateToggle(CombatPage, "Touch Kill", function(state)
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

--============================================================
-- 7) VISUALS
--============================================================
local VisualPage = CreateTab("Visuals", "👁", 7)

CreateSection(VisualPage, "🌄 Освещение")
CreateToggle(VisualPage, "Fullbright", function(state)
    if state then
        _G.DasterOrigLight = {
            Ambient = Lighting.Ambient, Brightness = Lighting.Brightness,
            OutdoorAmbient = Lighting.OutdoorAmbient, GlobalShadows = Lighting.GlobalShadows,
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
CreateToggle(VisualPage, "🎯 ESP на алмазы", function(state)
    State.ESPGems = state
    if state then
        _G.DasterGemEsp = task.spawn(function()
            while State.ESPGems do
                for _, gem in ipairs(Farm.FindGems()) do
                    pcall(function()
                        local part = gem:IsA("Model") and (gem.PrimaryPart or gem:FindFirstChildWhichIsA("BasePart")) or gem
                        if part and not part:FindFirstChild("DasterEsp") then
                            Utils.Create("Highlight", {
                                Name = "DasterEsp",
                                FillColor = Color3.fromRGB(0, 200, 255),
                                OutlineColor = Color3.fromRGB(255, 255, 255),
                                FillTransparency = 0.5,
                                Parent = part,
                            })
                        end
                    end)
                end
                task.wait(1)
            end
        end)
    else
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "DasterEsp" then obj:Destroy() end
        end
    end
end)

--============================================================
-- 8) REMOTE EXPLORER
--============================================================
local RemotePage = CreateTab("Remotes", "🔧", 8)

CreateSection(RemotePage, "🔍 Сканер")
CreateLabel(RemotePage, "Ищет все RemoteEvent в игре — может помочь найти выдачу наград", Color3.fromRGB(200, 200, 255))

CreateButton(RemotePage, "🔍 Сканировать всё", function()
    Remotes = RemoteScanner.Scan()
    Utils.Notify("Всего: " .. #Remotes.All .. " | Gems: " .. #Remotes.Gems 
        .. " | Days: " .. #Remotes.Days .. " | Classes: " .. #Remotes.Classes, 5)
end)

local remoteListFrame = Utils.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 200),
    BackgroundColor3 = Color3.fromRGB(30, 0, 0),
    BorderSizePixel = 0,
    ZIndex = 3,
    Parent = RemotePage,
})
Utils.Corner(remoteListFrame, 7)
Utils.Stroke(remoteListFrame, Config.Theme.Accent, 1, 0.7)

local remoteScroll = Utils.Create("ScrollingFrame", {
    Size = UDim2.new(1, -10, 1, -10),
    Position = UDim2.new(0, 5, 0, 5),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Config.Theme.Accent,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ZIndex = 4,
    Parent = remoteListFrame,
})
Utils.Create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 3),
    Parent = remoteScroll,
})

CreateButton(RemotePage, "📋 Показать все remotes в списке", function()
    for _, c in ipairs(remoteScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local r = RemoteScanner.Get()
    for i, remote in ipairs(r.All) do
        Utils.Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundColor3 = Color3.fromRGB(80, 0, 0),
            Text = remote:GetFullName(),
            TextColor3 = Config.Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = i,
            ZIndex = 5,
            Parent = remoteScroll,
        })
    end
    Utils.Notify("Показано remotes: " .. #r.All, 3)
end)

--============================================================
-- 9) SETTINGS
--============================================================
local SettingsPage = CreateTab("Settings", "⚙", 9)

CreateSection(SettingsPage, "ℹ Информация")
CreateLabel(SettingsPage, "Версия: v" .. Config.Version)
CreateLabel(SettingsPage, "Toggle UI: " .. Config.ToggleKey.Name)
CreateLabel(SettingsPage, "Автор: Daster")

CreateSection(SettingsPage, "🚨 Опасная зона")
CreateButton(SettingsPage, "🗑 Отключить ВСЁ", function()
    for k in pairs(State) do State[k] = false end
    _G.DasterSpeedTime2 = false
    for _, conn in pairs({_G.DasterFlyConn, _G.DasterKillAuraConn, _G.DasterGodConn,
                          _G.DasterInfJumpConn, _G.DasterNoclipConn, _G.DasterTouchKillConn}) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "DasterEsp" then obj:Destroy() end
    end
    Utils.Notify("Всё отключено", 3, Config.Theme.Success)
end)
CreateButton(SettingsPage, "❌ Выгрузить скрипт", function()
    ScreenGui:Destroy()
end)

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
    if input.KeyCode == Config.ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

--============================================================
-- ЗАГРУЗКА
--============================================================
Tabs["AutoFarm"].BackgroundColor3 = Config.Theme.Accent
Tabs["AutoFarm"].TextColor3 = Color3.fromRGB(255, 255, 255)
Pages["AutoFarm"].Visible = true

task.wait(0.3)
Utils.Notify("⚔ Daster Scripts v" .. Config.Version .. " загружен!", 4, Config.Theme.Accent)
task.wait(0.6)
Utils.Notify("🤖 Вкладка AutoFarm → жми ЗАПУСТИТЬ ВСЁ", 5, Config.Theme.Success)
task.wait(0.6)
Utils.Notify("⚠ Алмазы/дни реально выдаются только авто-фармом!", 6, Config.Theme.Gold)
