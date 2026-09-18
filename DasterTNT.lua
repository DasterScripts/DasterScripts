--[[
    ⚔ DASTER SCRIPTS — +1 ДОБЫЧА ТНТ EDITION ⚔
    Version: 1.0
    Author: Daster
    NOTE: Money/DMG is server-side. Auto-Farm only.
]]

--============================================================
-- SERVICES
--============================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local HttpService       = game:GetService("HttpService")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser       = game:GetService("VirtualUser")
local LocalPlayer       = Players.LocalPlayer

--============================================================
-- CONFIG
--============================================================
local Theme = {
    Primary   = Color3.fromRGB(220, 60, 0),
    Secondary = Color3.fromRGB(150, 40, 0),
    Dark      = Color3.fromRGB(25, 10, 5),
    Darker    = Color3.fromRGB(15, 5, 0),
    Accent    = Color3.fromRGB(255, 100, 0),
    Accent2   = Color3.fromRGB(255, 200, 0),
    Text      = Color3.fromRGB(255, 235, 220),
    TextDim   = Color3.fromRGB(255, 180, 140),
    Success   = Color3.fromRGB(80, 220, 50),
    Error     = Color3.fromRGB(255, 60, 60),
    TNT       = Color3.fromRGB(255, 50, 50),
    Gold      = Color3.fromRGB(255, 200, 50),
}

local ToggleKey = Enum.KeyCode.RightShift
local BG_IMAGE = "rbxassetid://13132981571"
local FARM_SPEED = 0.15

--============================================================
-- STATE
--============================================================
local State = {
    AutoFarmTNT   = false,
    AutoExplode   = false,
    AutoCollect   = false,
    AutoUpgrade   = false,
    AutoRebirth   = false,
    KillAura      = false,
    GodMode       = false,
    Noclip        = false,
    Fly           = false,
    ESPTNT        = false,
    ESPOre        = false,
    ESPPlayers    = false,
}

--============================================================
-- UTILS
--============================================================
local U = {}

function U.Create(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do
        pcall(function() o[k] = v end)
    end
    return o
end

function U.Corner(p, r) return U.Create("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = p}) end

function U.Stroke(p, c, t, tr)
    return U.Create("UIStroke", {Color = c or Theme.Accent, Thickness = t or 1.5, Transparency = tr or 0, Parent = p})
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

-- ANTI-AFK
LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

--============================================================
-- NOTIFICATION
--============================================================
function U.Notify(text, duration, color)
    local sg = game.CoreGui:FindFirstChild("DasterTNT")
    if not sg then return end
    local main = sg:FindFirstChild("MainFrame")
    if not main then return end

    duration = duration or 3
    color = color or Theme.Primary

    local notify = U.Create("Frame", {
        Size = UDim2.new(0, 300, 0, 50),
        Position = UDim2.new(1, -320, 0, 60),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ZIndex = 50,
        Parent = main,
    })
    U.Corner(notify, 8)
    U.Stroke(notify, Color3.fromRGB(255, 255, 255), 1, 0.7)
    U.Gradient(notify, color, Color3.fromRGB(0, 0, 0))

    U.Create("TextLabel", {
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

    task.delay(duration, function()
        if notify and notify.Parent then
            pcall(function()
                TweenService:Create(notify, TweenInfo.new(0.3), {
                    Position = UDim2.new(1, 0, 0, 60),
                    BackgroundTransparency = 1
                }):Play()
            end)
            task.wait(0.3)
            if notify and notify.Parent then notify:Destroy() end
        end
    end)
end

--============================================================
-- УДАЛЯЕМ СТАРЫЙ GUI
--============================================================
pcall(function()
    if game.CoreGui:FindFirstChild("DasterTNT") then
        game.CoreGui.DasterTNT:Destroy()
    end
end)

--============================================================
-- SCREEN GUI
--============================================================
local ScreenGui = U.Create("ScreenGui", {
    Name = "DasterTNT",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    Parent = game.CoreGui,
})

--============================================================
-- MAIN FRAME
--============================================================
local MainFrame = U.Create("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 680, 0, 470),
    Position = UDim2.new(0.5, -340, 0.5, -235),
    BackgroundColor3 = Theme.Dark,
    BorderSizePixel = 0,
    Active = true,
    Draggable = true,
    ClipsDescendants = true,
    Parent = ScreenGui,
})
U.Corner(MainFrame, 14)
U.Stroke(MainFrame, Theme.Accent, 2, 0)
U.Gradient(MainFrame, Theme.Darker, Theme.Dark, 90)

pcall(function()
    local bg = U.Create("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = BG_IMAGE,
        ImageTransparency = 0.55,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 0,
        Parent = MainFrame,
    })
    U.Corner(bg, 14)
end)

local Overlay = U.Create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Theme.Primary,
    BackgroundTransparency = 0.82,
    BorderSizePixel = 0,
    ZIndex = 1,
    Parent = MainFrame,
})
U.Corner(Overlay, 14)
U.Gradient(Overlay, Color3.fromRGB(80, 20, 0), Color3.fromRGB(0, 0, 0), 120)

--============================================================
-- TITLE BAR
--============================================================
local TitleBar = U.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = Theme.Secondary,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = MainFrame,
})
U.Corner(TitleBar, 14)
U.Gradient(TitleBar, Theme.Accent, Color3.fromRGB(50, 10, 0), 0)

U.Create("TextLabel", {
    Size = UDim2.new(1, -170, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "🧨  D A S T E R   •   T N T  🧨",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextStrokeTransparency = 0.5,
    TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
    Font = Enum.Font.GothamBlack,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
    Parent = TitleBar,
})

local MinBtn = U.Create("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -70, 0.5, -15),
    BackgroundColor3 = Color3.fromRGB(90, 20, 0),
    Text = "—",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    ZIndex = 3,
    Parent = TitleBar,
})
U.Corner(MinBtn, 8)
U.Stroke(MinBtn, Color3.fromRGB(255, 150, 100), 1, 0.5)

local CloseBtn = U.Create("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -36, 0.5, -15),
    BackgroundColor3 = Color3.fromRGB(180, 40, 0),
    Text = "✕",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    ZIndex = 3,
    Parent = TitleBar,
})
U.Corner(CloseBtn, 8)
U.Stroke(CloseBtn, Color3.fromRGB(255, 150, 100), 1, 0.5)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local target = minimized and UDim2.new(0, 680, 0, 50) or UDim2.new(0, 680, 0, 470)
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = target}):Play()
    MinBtn.Text = minimized and "+" or "—"
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

--============================================================
-- TAB BAR
--============================================================
local TabBar = U.Create("Frame", {
    Size = UDim2.new(0, 155, 1, -60),
    Position = UDim2.new(0, 8, 0, 54),
    BackgroundColor3 = Theme.Darker,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = MainFrame,
})
U.Corner(TabBar, 10)
U.Stroke(TabBar, Theme.Accent, 1, 0.6)

local TabScroll = U.Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ZIndex = 2,
    Parent = TabBar,
})
U.Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), Parent = TabScroll})
U.Padding(TabScroll, 8, 8, 8, 8)

--============================================================
-- PAGE CONTAINER
--============================================================
local PageContainer = U.Create("Frame", {
    Size = UDim2.new(1, -180, 1, -60),
    Position = UDim2.new(0, 170, 0, 54),
    BackgroundColor3 = Theme.Darker,
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = MainFrame,
})
U.Corner(PageContainer, 10)
U.Stroke(PageContainer, Theme.Accent, 1, 0.6)

--============================================================
-- BUILDER
--============================================================
local Tabs = {}
local Pages = {}

local function CreateTab(name, icon, order)
    local Tab = U.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Color3.fromRGB(80, 20, 0),
        Text = "   " .. (icon or "") .. "  " .. name,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order,
        ZIndex = 3,
        Parent = TabScroll,
    })
    U.Corner(Tab, 7)
    U.Stroke(Tab, Theme.Accent, 1, 0.85)

    local Page = U.Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 3,
        Parent = PageContainer,
    })
    U.Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = Page})
    U.Padding(Page, 10, 10, 10, 10)

    Tabs[name] = Tab
    Pages[name] = Page

    Tab.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, t in pairs(Tabs) do
            TweenService:Create(t, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(80, 20, 0), TextColor3 = Theme.TextDim
            }):Play()
        end
        Page.Visible = true
        TweenService:Create(Tab, TweenInfo.new(0.15), {
            BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)

    return Page
end

local function Section(parent, title)
    local s = U.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0, ZIndex = 3, Parent = parent,
    })
    U.Corner(s, 6)
    U.Stroke(s, Theme.Accent, 1, 0.5)
    U.Gradient(s, Theme.Accent, Color3.fromRGB(50, 10, 0), 0)
    U.Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1, Text = "◆ " .. title,
        TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = s,
    })
end

local function Button(parent, text, callback, color)
    local b = U.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = color or Color3.fromRGB(120, 40, 0),
        Text = text, TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold, TextSize = 13,
        ZIndex = 3, Parent = parent,
    })
    U.Corner(b, 7)
    U.Stroke(b, Theme.Accent, 1, 0.7)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = color or Color3.fromRGB(120, 40, 0)}):Play()
    end)
    b.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then
            warn("[DasterTNT] " .. tostring(err))
            U.Notify("Ошибка: " .. tostring(err), 3, Theme.Error)
        end
    end)
    return b
end

local function Toggle(parent, text, callback)
    local state = false
    local btn = U.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(80, 20, 0),
        Text = "", ZIndex = 3, Parent = parent,
    })
    U.Corner(btn, 7)
    U.Stroke(btn, Theme.Accent, 1, 0.7)

    U.Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = btn,
    })

    local dot = U.Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -22, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60), BorderSizePixel = 0,
        ZIndex = 4, Parent = btn,
    })
    U.Corner(dot, 7)
    U.Stroke(dot, Color3.fromRGB(120, 120, 120), 1, 0)

    btn.MouseButton1Click:Connect(function()
        state = not state
        local ok, err = pcall(callback, state)
        if not ok then
            state = not state
            warn("[DasterTNT] " .. tostring(err))
            U.Notify("Ошибка: " .. tostring(err), 3, Theme.Error)
            return
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(80, 20, 0)
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(60, 60, 60)
        }):Play()
    end)
end

local function TextBox(parent, placeholder, callback)
    local tb = U.Create("TextBox", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(80, 20, 0),
        Text = "", PlaceholderText = placeholder,
        PlaceholderColor3 = Theme.TextDim, TextColor3 = Theme.Text,
        Font = Enum.Font.Gotham, TextSize = 12,
        ZIndex = 3, Parent = parent,
    })
    U.Corner(tb, 7)
    U.Stroke(tb, Theme.Accent, 1, 0.7)
    tb.FocusLost:Connect(function(enter)
        if enter and tb.Text ~= "" then
            local ok, err = pcall(callback, tb.Text)
            if not ok then U.Notify("Ошибка: " .. tostring(err), 3, Theme.Error) end
        end
    end)
    return tb
end

local function Label(parent, text, color)
    return U.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1, Text = text,
        TextColor3 = color or Theme.TextDim,
        Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, ZIndex = 3, Parent = parent,
    })
end

--============================================================
-- SCANNER: TNT, ORE, MONEY
--============================================================
local TNT_KW   = {"tnt", "bomb", "explosive", "dynamite", "crate"}
local ORE_KW   = {"ore", "gold", "diamond", "crystal", "gem", "coal", "iron", "stone"}
local MONEY_KW = {"money", "cash", "coin", "drop", "reward", "gem", "gold"}

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

--============================================================
-- REMOTE SCANNER
--============================================================
local Remotes = {}
local function ScanRemotes()
    Remotes = {All = {}, TNT = {}, Money = {}, Upgrade = {}, Rebirth = {}}
    local kw = {
        TNT = {"tnt", "bomb", "explode", "place", "detonate"},
        Money = {"money", "cash", "reward", "add", "coin"},
        Upgrade = {"upgrade", "buy", "purchase", "boost"},
        Rebirth = {"rebirth", "prestige", "reset", "ascend"},
    }
    for _, target in ipairs({ReplicatedStorage, Workspace}) do
        for _, obj in ipairs(target:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(Remotes.All, obj)
                local n = string.lower(obj.Name)
                for cat, kws in pairs(kw) do
                    for _, k in ipairs(kws) do
                        if string.find(n, k) then
                            table.insert(Remotes[cat], obj)
                            break
                        end
                    end
                end
            end
        end
    end
    return Remotes
end

--============================================================
-- AUTO-FARM: АВТО-УСТАНОВКА TNT + ВЗРЫВ
--============================================================
local function AutoPlaceTNT()
    -- Ищем TNT в инвентаре (Backpack) и активируем
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local n = string.lower(tool.Name)
                if string.find(n, "tnt") or string.find(n, "bomb") or string.find(n, "dynamite") then
                    pcall(function()
                        tool.Parent = LocalPlayer.Character
                        tool:Activate()
                    end)
                end
            end
        end
    end
    
    -- Также пробуем через Remote (если есть)
    for _, r in ipairs(Remotes.TNT or {}) do
        pcall(function()
            if r:IsA("RemoteEvent") then r:FireServer() end
        end)
    end
end

local function AutoCollectDrops()
    for _, kw in ipairs({MONEY_KW, ORE_KW}) do
        for _, item in ipairs(FindByNames(kw)) do
            BringTo(item, 3)
        end
    end
end

--============================================================
-- ВКЛАДКА 1: AUTO-FARM
--============================================================
local FarmPage = CreateTab("AutoFarm", "🤖", 1)

Section(FarmPage, "🧨 МЕГА-ФАРМ ТНТ")
Label(FarmPage, "Авто: ставит ТНТ → взрывает → собирает лут", Color3.fromRGB(255, 200, 100))

Button(FarmPage, "▶ ЗАПУСТИТЬ ВСЁ (BOMBEZNO)", function()
    State.AutoFarmTNT = true
    State.AutoExplode = true
    State.AutoCollect = true
    U.Notify("🔥 МЕГА-ФАРМ ЗАПУЩЕН!", 4, Theme.Success)
    task.spawn(function()
        while State.AutoFarmTNT do
            pcall(function()
                if State.AutoExplode then AutoPlaceTNT() end
                if State.AutoCollect then AutoCollectDrops() end
            end)
            task.wait(FARM_SPEED)
        end
    end)
end)

Button(FarmPage, "⏹ ОСТАНОВИТЬ ВСЁ", function()
    State.AutoFarmTNT = false
    State.AutoExplode = false
    State.AutoCollect = false
    U.Notify("⏹ Фарм остановлен", 3, Theme.Error)
end, Color3.fromRGB(150, 30, 0))

Section(FarmPage, "🧨 ТНТ")
Toggle(FarmPage, "Авто-установка TNT", function(s)
    State.AutoFarmTNT = s
    if s then
        task.spawn(function()
            while State.AutoFarmTNT do
                pcall(AutoPlaceTNT)
                task.wait(0.3)
            end
        end)
    end
end)

Toggle(FarmPage, "Авто-взрыв (активировать TNT)", function(s)
    State.AutoExplode = s
    if s then
        task.spawn(function()
            while State.AutoExplode do
                pcall(function()
                    local char = U.GetChar()
                    if char then
                        for _, tool in ipairs(char:GetChildren()) do
                            if tool:IsA("Tool") and string.find(string.lower(tool.Name), "tnt") then
                                tool:Activate()
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

Section(FarmPage, "💰 Лут")
Toggle(FarmPage, "Авто-сбор денег/руды", function(s)
    State.AutoCollect = s
    if s then
        task.spawn(function()
            while State.AutoCollect do
                pcall(AutoCollectDrops)
                task.wait(0.2)
            end
        end)
    end
end)

Button(FarmPage, "💵 Притянуть ВСЁ (разово)", function()
    local money = FindByNames(MONEY_KW)
    local ore = FindByNames(ORE_KW)
    for _, m in ipairs(money) do BringTo(m, 3) end
    for _, o in ipairs(ore) do BringTo(o, 3) end
    U.Notify("Притянуто: 💰 " .. #money .. " | ⛏ " .. #ore, 3)
end)

Section(FarmPage, "⚡ Авто-апгрейды")
Toggle(FarmPage, "Авто-покупка апгрейдов", function(s)
    State.AutoUpgrade = s
    if s then
        task.spawn(function()
            while State.AutoUpgrade do
                for _, r in ipairs(Remotes.Upgrade or {}) do
                    pcall(function()
                        if r:IsA("RemoteEvent") then r:FireServer("buy") end
                    end)
                end
                task.wait(2)
            end
        end)
    end
end)

Toggle(FarmPage, "Auto-Rebirth (авто-перерождение)", function(s)
    State.AutoRebirth = s
    if s then
        task.spawn(function()
            while State.AutoRebirth do
                for _, r in ipairs(Remotes.Rebirth or {}) do
                    pcall(function()
                        if r:IsA("RemoteEvent") then r:FireServer() end
                    end)
                end
                task.wait(5)
            end
        end)
    end
end)

Section(FarmPage, "📊 Статистика")
local statLbl = Label(FarmPage, "🧨 TNT: 0 | ⛏ Руда: 0 | 💰 Деньги: 0", Theme.Gold)
task.spawn(function()
    while statLbl.Parent do
        pcall(function()
            local tnt = #FindByNames(TNT_KW)
            local ore = #FindByNames(ORE_KW)
            local money = #FindByNames(MONEY_KW)
            statLbl.Text = "🧨 TNT: " .. tnt .. " | ⛏ Руда: " .. ore .. " | 💰 Деньги: " .. money
        end)
        task.wait(2)
    end
end)

--============================================================
-- ВКЛАДКА 2: PLAYER
--============================================================
local PlayerPage = CreateTab("Player", "🏃", 2)

Section(PlayerPage, "⚡ Скорость")
Button(PlayerPage, "⚡ Speed 100", function()
    local _, _, hum = U.GetChar()
    if hum then hum.WalkSpeed = 100 end
end)
Button(PlayerPage, "⚡ Speed 200", function()
    local _, _, hum = U.GetChar()
    if hum then hum.WalkSpeed = 200 end
end)
Button(PlayerPage, "🐢 Speed 16", function()
    local _, _, hum = U.GetChar()
    if hum then hum.WalkSpeed = 16 end
end)
Button(PlayerPage, "🦘 Jump 200", function()
    local _, _, hum = U.GetChar()
    if hum then hum.UseJumpPower = true; hum.JumpPower = 200 end
end)

Section(PlayerPage, "🕊 Fly / Noclip")
Toggle(PlayerPage, "Fly (WASD + Space/Ctrl)", function(state)
    State.Fly = state
    local _, hrp = U.GetChar()
    if not hrp then return end
    if state then
        local bv = U.Create("BodyVelocity", {MaxForce = Vector3.new(1e5,1e5,1e5), Velocity = Vector3.zero, Parent = hrp})
        local bg = U.Create("BodyGyro", {MaxTorque = Vector3.new(1e5,1e5,1e5), P = 10000, Parent = hrp})
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

Toggle(PlayerPage, "Infinite Jump", function(state)
    if state then
        _G.DasterInfJumpConn = UserInputService.JumpRequest:Connect(function()
            local _, _, hum = U.GetChar()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if _G.DasterInfJumpConn then _G.DasterInfJumpConn:Disconnect() end
    end
end)

--============================================================
-- ВКЛАДКА 3: COMBAT
--============================================================
local CombatPage = CreateTab("Combat", "⚔", 3)

Section(CombatPage, "💀 Атака")
Toggle(CombatPage, "Kill Aura (радиус 25)", function(state)
    State.KillAura = state
    if state then
        _G.DasterKillAuraConn = RunService.Heartbeat:Connect(function()
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
        if _G.DasterKillAuraConn then _G.DasterKillAuraConn:Disconnect() end
    end
end)

--============================================================
-- ВКЛАДКА 4: VISUALS
--============================================================
local VisPage = CreateTab("Visuals", "👁", 4)

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

Section(VisPage, "🎯 ESP")
Toggle(VisPage, "ESP на TNT (красный)", function(state)
    State.ESPTNT = state
    if state then
        task.spawn(function()
            while State.ESPTNT do
                pcall(function()
                    for _, t in ipairs(FindByNames(TNT_KW)) do
                        local part = t:IsA("Model") and (t.PrimaryPart or t:FindFirstChildWhichIsA("BasePart")) or t
                        if part and not part:FindFirstChild("DasterTNTESP") then
                            U.Create("Highlight", {
                                Name = "DasterTNTESP",
                                FillColor = Theme.TNT, OutlineColor = Color3.fromRGB(255,255,255),
                                FillTransparency = 0.4, Parent = part,
                            })
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    else
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "DasterTNTESP" then obj:Destroy() end
        end
    end
end)

Toggle(VisPage, "ESP на руду (золотой)", function(state)
    State.ESPOre = state
    if state then
        task.spawn(function()
            while State.ESPOre do
                pcall(function()
                    for _, o in ipairs(FindByNames(ORE_KW)) do
                        local part = o:IsA("Model") and (o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")) or o
                        if part and not part:FindFirstChild("DasterOreESP") then
                            U.Create("Highlight", {
                                Name = "DasterOreESP",
                                FillColor = Theme.Gold, OutlineColor = Color3.fromRGB(255,255,255),
                                FillTransparency = 0.4, Parent = part,
                            })
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    else
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "DasterOreESP" then obj:Destroy() end
        end
    end
end)

--============================================================
-- ВКЛАДКА 5: REMOTES
--============================================================
local RemPage = CreateTab("Remotes", "🔧", 5)

Section(RemPage, "🔍 Сканер")
Button(RemPage, "🔍 Сканировать всё", function()
    ScanRemotes()
    U.Notify("Всего: " .. #Remotes.All .. " | 🧨 " .. #Remotes.TNT .. " | 💰 " .. #Remotes.Money 
        .. " | ⬆ " .. #Remotes.Upgrade, 5)
end)

Button(RemPage, "📋 Вывести все в консоль (F9)", function()
    if #Remotes.All == 0 then ScanRemotes() end
    for _, r in ipairs(Remotes.All) do
        print("[TNT Remote] " .. r:GetFullName())
    end
    U.Notify("Список в консоли (F9)", 3)
end)

Section(RemPage, "💥 Триггер")
Button(RemPage, "🚀 Fire ALL TNT Remotes", function()
    if #Remotes.TNT == 0 then ScanRemotes() end
    for _, r in ipairs(Remotes.TNT) do
        pcall(function()
            if r:IsA("RemoteEvent") then r:FireServer() end
        end)
    end
    U.Notify("Отправлено: " .. #Remotes.TNT, 3)
end)

Button(RemPage, "💰 Fire ALL Money Remotes", function()
    if #Remotes.Money == 0 then ScanRemotes() end
    for _, r in ipairs(Remotes.Money) do
        pcall(function()
            if r:IsA("RemoteEvent") then
                r:FireServer(999999)
                r:FireServer("add", 999999)
            end
        end)
    end
    U.Notify("Отправлено: " .. #Remotes.Money, 3)
end)

--============================================================
-- ВКЛАДКА 6: SETTINGS
--============================================================
local SetPage = CreateTab("Settings", "⚙", 6)

Section(SetPage, "ℹ Информация")
Label(SetPage, "Версия: v1.0")
Label(SetPage, "Toggle UI: " .. ToggleKey.Name)
Label(SetPage, "Автор: Daster")

Section(SetPage, "🚨 Опасная зона")
Button(SetPage, "🗑 Отключить ВСЁ", function()
    for k in pairs(State) do State[k] = false end
    for _, conn in pairs({_G.DasterFlyConn, _G.DasterGodConn, _G.DasterInfJumpConn, _G.DasterNoclipConn, _G.DasterKillAuraConn}) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "DasterTNTESP" or obj.Name == "DasterOreESP" then obj:Destroy() end
    end
    U.Notify("Всё отключено", 3, Theme.Success)
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
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement 
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--============================================================
-- TOGGLE KEY
--============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == ToggleKey then MainFrame.Visible = not MainFrame.Visible end
end)

--============================================================
-- ЗАГРУЗКА
--============================================================
Tabs["AutoFarm"].BackgroundColor3 = Theme.Accent
Tabs["AutoFarm"].TextColor3 = Color3.fromRGB(255, 255, 255)
Pages["AutoFarm"].Visible = true

task.wait(0.3)
U.Notify("🧨 Daster TNT Script загружен!", 4, Theme.Accent)
task.wait(0.5)
U.Notify("✅ Меню открыто! Вкладок: 6", 4, Theme.Success)

print("[Daster TNT] ✅ Скрипт загружен!")
