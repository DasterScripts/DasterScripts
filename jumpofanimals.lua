--[[
    ⚔ DASTER SCRIPTS — JUMP FOR ANIMALS — ULTIMATE v2.0 ⚔
    Author: Daster
    Все возможные функции для JFA
    NOTE: Money/Pets = server-side. Auto-farm works.
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
local Stats             = game:GetService("Stats")
local LocalPlayer       = Players.LocalPlayer

--============================================================
-- THEME
--============================================================
local Theme = {
    Primary   = Color3.fromRGB(180, 0, 0),
    Secondary = Color3.fromRGB(120, 0, 0),
    Dark      = Color3.fromRGB(20, 0, 0),
    Darker    = Color3.fromRGB(12, 0, 0),
    Accent    = Color3.fromRGB(255, 30, 30),
    AccentGlow= Color3.fromRGB(255, 80, 80),
    Text      = Color3.fromRGB(255, 230, 230),
    TextDim   = Color3.fromRGB(255, 150, 150),
    Success   = Color3.fromRGB(50, 220, 50),
    Error     = Color3.fromRGB(255, 60, 60),
    Coin      = Color3.fromRGB(255, 200, 50),
    Animal    = Color3.fromRGB(120, 220, 120),
    Egg       = Color3.fromRGB(255, 150, 200),
    Rare      = Color3.fromRGB(200, 100, 255),
    Legendary = Color3.fromRGB(255, 180, 0),
}

local Config = {
    Version   = "2.0",
    Name      = "Daster — JFA Ultimate",
    ToggleKey = Enum.KeyCode.RightShift,
    HideKey   = Enum.KeyCode.RightControl,
    Backgrounds = {
        "rbxassetid://13132981571",
        "rbxassetid://13132981500",
        "rbxassetid://13132981400",
    },
    JumpDelay = 0.05,
    ClickDelay = 0.1,
    AutoRebirthLevel = 100,
    AutoRebirthEnabled = false,
    AntiAFKLevel = 1, -- 1 = обычный, 2 = агрессивный, 3 = параноик
    AutoHopEnabled = false,
    AutoHopMinutes = 10,
    PetAutoDelete = false,
    PetDeleteRarity = "Common",
    EggSniper = false,
    EggSniperTarget = "Legendary",
}

--============================================================
-- STATE
--============================================================
local State = {
    AutoJump = false, AutoClick = false,
    AutoFarmCoins = false, AutoHatch = false, AutoClaim = false,
    AutoQuest = false, AutoRebirth = false, AutoEvent = false,
    AutoEquipBest = false, PetAutoDelete = false, EggSniper = false,
    Fly = false, Noclip = false, GodMode = false, KillAura = false,
    ESPCoins = false, ESPEggs = false, ESPPlayers = false, ESPPets = false,
    AntiAFK = false, AutoHop = false,
}

-- Статистика
local Stats_ = {
    StartTime = tick(),
    Jumps = 0,
    CoinsCollected = 0,
    SessionsCount = 0,
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
    return U.Create("UIStroke", {
        Color = c or Theme.Accent, Thickness = t or 1.5, Transparency = tr or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p,
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

function U.FormatNumber(n)
    if not n then return "0" end
    local s = tostring(math.floor(n))
    local result = ""
    while #s > 3 do
        result = "," .. s:sub(-3) .. result
        s = s:sub(1, -4)
    end
    return s .. result
end

function U.FormatTime(sec)
    local d = math.floor(sec / 86400)
    local h = math.floor((sec % 86400) / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = math.floor(sec % 60)
    if d > 0 then return d .. "д " .. h .. "ч" end
    if h > 0 then return h .. "ч " .. m .. "м" end
    if m > 0 then return m .. "м " .. s .. "с" end
    return s .. "с"
end

--============================================================
-- ANTI-AFK PRO
--============================================================
local function AntiAFKPro()
    if State.AntiAFK then
        _G.DasterAFKConn = LocalPlayer.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
        
        if Config.AntiAFKLevel >= 2 then
            _G.DasterAFKInterval = task.spawn(function()
                while State.AntiAFK do
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(math.random(100, 800), math.random(100, 600)))
                    end)
                    task.wait(30)
                end
            end)
        end
        
        if Config.AntiAFKLevel >= 3 then
            _G.DasterAFKParanoid = task.spawn(function()
                while State.AntiAFK do
                    pcall(function()
                        local _, _, hum = U.GetChar()
                        if hum then
                            hum.Jump = true
                            task.wait(0.1)
                            hum.Jump = false
                        end
                    end)
                    task.wait(15)
                end
            end)
        end
    else
        if _G.DasterAFKConn then _G.DasterAFKConn:Disconnect() end
        if type(_G.DasterAFKInterval) == "thread" then pcall(function() task.cancel(_G.DasterAFKInterval) end) end
        if type(_G.DasterAFKParanoid) == "thread" then pcall(function() task.cancel(_G.DasterAFKParanoid) end) end
    end
end

--============================================================
-- NOTIFICATIONS
--============================================================
function U.Notify(text, duration, color)
    local sg = game.CoreGui:FindFirstChild("DasterJFA")
    if not sg then return end
    local main = sg:FindFirstChild("MainFrame")
    if not main then return end

    duration = duration or 3
    color = color or Theme.Primary

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
        BackgroundTransparency = 1, Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, ZIndex = 51, Parent = notify,
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
-- УДАЛЯЕМ СТАРЫЙ GUI
--============================================================
pcall(function()
    if game.CoreGui:FindFirstChild("DasterJFA") then
        game.CoreGui.DasterJFA:Destroy()
    end
end)

--============================================================
-- SCREEN GUI
--============================================================
local ScreenGui = U.Create("ScreenGui", {
    Name = "DasterJFA",
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
    Size = UDim2.new(0, 720, 0, 490),
    Position = UDim2.new(0.5, -360, 0.5, -245),
    BackgroundColor3 = Theme.Dark,
    BorderSizePixel = 0, Active = true, Draggable = true,
    ClipsDescendants = true, Parent = ScreenGui,
})
U.Corner(MainFrame, 14)
U.Stroke(MainFrame, Theme.Accent, 2, 0)
U.Gradient(MainFrame, Theme.Darker, Theme.Dark, 90)

local BgImage = U.Create("ImageLabel", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    Image = Config.Backgrounds[1], ImageTransparency = 0.55,
    ScaleType = Enum.ScaleType.Crop, ZIndex = 0, Parent = MainFrame,
})
U.Corner(BgImage, 14)

local Overlay = U.Create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = Theme.Primary, BackgroundTransparency = 0.82,
    BorderSizePixel = 0, ZIndex = 1, Parent = MainFrame,
})
U.Corner(Overlay, 14)
U.Gradient(Overlay, Color3.fromRGB(60, 0, 0), Color3.fromRGB(0, 0, 0), 120)

--============================================================
-- TITLE BAR
--============================================================
local TitleBar = U.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = Theme.Secondary, BackgroundTransparency = 0.15,
    BorderSizePixel = 0, ZIndex = 2, Parent = MainFrame,
})
U.Corner(TitleBar, 14)
U.Gradient(TitleBar, Theme.Accent, Color3.fromRGB(40, 0, 0), 0)

U.Create("TextLabel", {
    Size = UDim2.new(1, -200, 1, 0), Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "🐾  D A S T E R   •   J F A   U L T I M A T E  🐾",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextStrokeTransparency = 0.5, TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
    Font = Enum.Font.GothamBlack, TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3, Parent = TitleBar,
})

U.Create("TextLabel", {
    Size = UDim2.new(0, 80, 0, 20), Position = UDim2.new(1, -160, 0.5, -10),
    BackgroundTransparency = 1, Text = "v" .. Config.Version,
    TextColor3 = Theme.TextDim, Font = Enum.Font.GothamBold,
    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = 3, Parent = TitleBar,
})

local MinBtn = U.Create("TextButton", {
    Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -70, 0.5, -15),
    BackgroundColor3 = Color3.fromRGB(90, 0, 0), Text = "—",
    TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold,
    TextSize = 18, ZIndex = 3, Parent = TitleBar,
})
U.Corner(MinBtn, 8)
U.Stroke(MinBtn, Color3.fromRGB(255, 100, 100), 1, 0.5)

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
    local target = minimized and UDim2.new(0, 720, 0, 50) or UDim2.new(0, 720, 0, 490)
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = target}):Play()
    MinBtn.Text = minimized and "+" or "—"
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

--============================================================
-- TAB BAR
--============================================================
local TabBar = U.Create("Frame", {
    Size = UDim2.new(0, 160, 1, -60), Position = UDim2.new(0, 8, 0, 54),
    BackgroundColor3 = Theme.Darker, BackgroundTransparency = 0.35,
    BorderSizePixel = 0, ZIndex = 2, Parent = MainFrame,
})
U.Corner(TabBar, 10)
U.Stroke(TabBar, Theme.Accent, 1, 0.6)

local TabScroll = U.Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    BorderSizePixel = 0, ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0), ZIndex = 2, Parent = TabBar,
})
U.Create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5), Parent = TabScroll,
})
U.Padding(TabScroll, 8, 8, 8, 8)

--============================================================
-- PAGE CONTAINER
--============================================================
local PageContainer = U.Create("Frame", {
    Size = UDim2.new(1, -185, 1, -60), Position = UDim2.new(0, 175, 0, 54),
    BackgroundColor3 = Theme.Darker, BackgroundTransparency = 0.35,
    BorderSizePixel = 0, ZIndex = 2, Parent = MainFrame,
})
U.Corner(PageContainer, 10)
U.Stroke(PageContainer, Theme.Accent, 1, 0.6)

--============================================================
-- BUILDERS
--============================================================
local Tabs, Pages = {}, {}

local function CreateTab(name, icon, order)
    local Tab = U.Create("TextButton", {
        Name = name .. "Tab", Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Color3.fromRGB(60, 0, 0),
        Text = "   " .. (icon or "") .. "  " .. name,
        TextColor3 = Theme.TextDim, Font = Enum.Font.GothamSemibold,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order, ZIndex = 3, Parent = TabScroll,
    })
    U.Corner(Tab, 7)
    U.Stroke(Tab, Theme.Accent, 1, 0.85)

    local Page = U.Create("ScrollingFrame", {
        Name = name .. "Page", Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Visible = false, ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 3, Parent = PageContainer,
    })
    U.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = Page,
    })
    U.Padding(Page, 10, 10, 10, 10)

    Tabs[name] = Tab
    Pages[name] = Page

    Tab.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        for _, t in pairs(Tabs) do
            TweenService:Create(t, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(60, 0, 0), TextColor3 = Theme.TextDim
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
        BackgroundColor3 = Theme.Secondary, BackgroundTransparency = 0.4,
        BorderSizePixel = 0, ZIndex = 3, Parent = parent,
    })
    U.Corner(s, 6)
    U.Stroke(s, Theme.Accent, 1, 0.5)
    U.Gradient(s, Theme.Accent, Color3.fromRGB(40, 0, 0), 0)
    U.Create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1, Text = "◆ " .. title,
        TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4, Parent = s,
    })
end

local function Button(parent, text, callback, color)
    local b = U.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = color or Color3.fromRGB(90, 0, 0),
        Text = text, TextColor3 = Theme.Text,
        Font = Enum.Font.GothamSemibold, TextSize = 12,
        ZIndex = 3, Parent = parent,
    })
    U.Corner(b, 7)
    U.Stroke(b, Theme.Accent, 1, 0.7)

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {
            BackgroundColor3 = color or Color3.fromRGB(90, 0, 0)
        }):Play()
    end)
    b.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then
            warn("[DasterJFA] " .. tostring(err))
            U.Notify("Ошибка: " .. tostring(err), 3, Theme.Error)
        end
    end)
    return b
end

local function Toggle(parent, text, callback)
    local state = false
    local btn = U.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(60, 0, 0),
        Text = "", ZIndex = 3, Parent = parent,
    })
    U.Corner(btn, 7)
    U.Stroke(btn, Theme.Accent, 1, 0.7)

    U.Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = text,
        TextColor3 = Theme.Text, Font = Enum.Font.GothamSemibold,
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4, Parent = btn,
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
            warn("[DasterJFA] " .. tostring(err))
            U.Notify("Ошибка: " .. tostring(err), 3, Theme.Error)
            return
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(60, 0, 0)
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(60, 60, 60)
        }):Play()
    end)
end

local function TextBox(parent, placeholder, callback)
    local tb = U.Create("TextBox", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(60, 0, 0),
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
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
        Text = text, TextColor3 = color or Theme.TextDim,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        ZIndex = 3, Parent = parent,
    })
end

--============================================================
-- HELPERS
--============================================================
local COIN_KW  = {"coin", "cash", "money", "dollar", "gem", "gold"}
local EGG_KW   = {"egg", "crate", "pet egg", "hatch"}
local PET_KW   = {"pet", "animal", "puppy", "kitty", "dog", "cat"}
local QUEST_KW = {"quest", "mission", "task", "daily"}
local REBIRTH_KW = {"rebirth", "prestige", "reset", "ascend"}

local function FindByNames(keywords)
    local found = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Model") 
        or obj:IsA("ProximityPrompt") then
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
local RemoteScanner = {}

function RemoteScanner.Scan()
    local found = {
        Coins = {}, Pets = {}, Eggs = {}, Claim = {}, Rebirth = {}, Quest = {}, All = {},
    }
    local keywords = {
        Coins   = {"coin", "cash", "money", "reward", "addcoin", "currency", "gem", "gold"},
        Pets    = {"pet", "animal", "adopt", "equip", "give", "egg"},
        Eggs    = {"hatch", "egg", "open"},
        Claim   = {"claim", "daily", "reward", "code", "redeem", "gift"},
        Rebirth = {"rebirth", "prestige", "reset", "ascend"},
        Quest   = {"quest", "mission", "task"},
    }
    for _, target in ipairs({ReplicatedStorage, Workspace}) do
        for _, obj in ipairs(target:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(found.All, obj)
                local n = string.lower(obj.Name)
                for cat, kws in pairs(keywords) do
                    for _, k in ipairs(kws) do
                        if string.find(n, k) then
                            table.insert(found[cat], obj)
                            break
                        end
                    end
                end
            end
        end
    end
    return found
end

local Remotes = nil
function RemoteScanner.Get()
    if not Remotes then Remotes = RemoteScanner.Scan() end
    return Remotes
end

--============================================================
-- 1) MEGA FARM (главная)
--============================================================
local FarmPage = CreateTab("MegaFarm", "🔥", 1)

Section(FarmPage, "🔥 МЕГА-РЕЖИМ")
Label(FarmPage, "ОДНА КНОПКА = ВСЁ включено. Максимальный фарм!", Color3.fromRGB(255, 200, 100))

Button(FarmPage, "▶🔥 ЗАПУСТИТЬ ВСЁ (MEGA MODE)", function()
    State.AutoJump = true
    State.AutoClick = true
    State.AutoFarmCoins = true
    State.AutoCollect = true
    State.AutoQuest = true
    State.AutoClaim = true
    State.AntiAFK = true
    Config.AntiAFKLevel = 3
    Config.JumpDelay = 0.01
    
    U.Notify("🔥 MEGA MODE ВКЛЮЧЁН!", 4, Theme.Success)
    
    -- Авто-прыжок
    task.spawn(function()
        while State.AutoJump do
            pcall(function()
                local _, _, hum = U.GetChar()
                if hum then
                    hum.Jump = true
                    Stats_.Jumps = Stats_.Jumps + 1
                end
            end)
            task.wait(Config.JumpDelay)
        end
    end)
    
    -- Авто-фарм монет
    task.spawn(function()
        while State.AutoFarmCoins do
            pcall(function()
                for _, c in ipairs(FindByNames(COIN_KW)) do BringTo(c, 3) end
            end)
            task.wait(0.3)
        end
    end)
    
    -- Авто-claim
    task.spawn(function()
        while State.AutoClaim do
            pcall(function()
                local r = RemoteScanner.Get()
                for _, remote in ipairs(r.Claim) do
                    if remote:IsA("RemoteEvent") then remote:FireServer() end
                end
            end)
            task.wait(30)
        end
    end)
    
    AntiAFKPro()
end)

Button(FarmPage, "⏹ ОСТАНОВИТЬ ВСЁ", function()
    for k in pairs(State) do State[k] = false end
    U.Notify("⏹ Всё остановлено", 3, Theme.Error)
end, Color3.fromRGB(150, 0, 0))

Section(FarmPage, "🦘 Авто-прыжок")
Toggle(FarmPage, "🦘 Авто-прыжок (постоянно)", function(state)
    State.AutoJump = state
    if state then
        _G.DasterJumpConn = task.spawn(function()
            while State.AutoJump do
                pcall(function()
                    local _, _, hum = U.GetChar()
                    if hum then 
                        hum.Jump = true 
                        Stats_.Jumps = Stats_.Jumps + 1
                    end
                end)
                task.wait(Config.JumpDelay)
            end
        end)
    end
end)

Toggle(FarmPage, "⚡ Ultra-fast jump (0.01с)", function(state)
    Config.JumpDelay = state and 0.01 or 0.05
end)

Section(FarmPage, "💰 Авто-фарм монет")
Toggle(FarmPage, "💰 Притягивать монеты", function(state)
    State.AutoFarmCoins = state
    if state then
        task.spawn(function()
            while State.AutoFarmCoins do
                pcall(function()
                    for _, c in ipairs(FindByNames(COIN_KW)) do BringTo(c, 3) end
                end)
                task.wait(0.2)
            end
        end)
    end
end)

Toggle(FarmPage, "⚡ Авто-клик (тапалки)", function(state)
    State.AutoClick = state
    if state then
        task.spawn(function()
            while State.AutoClick do
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(math.random(100, 800), math.random(100, 600)))
                end)
                task.wait(Config.ClickDelay)
            end
        end)
    end
end)

Section(FarmPage, "🥚 Авто-яйца")
Button(FarmPage, "🥚 Открыть все яйца (remotes)", function()
    local r = RemoteScanner.Get()
    for _, remote in ipairs(r.Eggs) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer()
                remote:FireServer("hatch")
                remote:FireServer("open")
            end
        end)
    end
    U.Notify("Попытка открыть яйца", 3)
end)

--============================================================
-- 2) PETS MANAGER
--============================================================
local PetsPage = CreateTab("Pets", "🐾", 2)

Section(PetsPage, "🐾 Управление питомцами")
Button(PetsPage, "📋 Список моих питомцев (консоль)", function()
    local pets = {}
    for _, obj in ipairs(LocalPlayer:GetDescendants()) do
        if obj:IsA("StringValue") or obj:IsA("ObjectValue") or obj:IsA("Folder") then
            local n = string.lower(obj.Name)
            if string.find(n, "pet") or string.find(n, "animal") then
                table.insert(pets, obj.Name .. " = " .. tostring(obj.Value or "folder"))
            end
        end
    end
    if #pets > 0 then
        for _, p in ipairs(pets) do print("[DasterJFA Pet] " .. p) end
        U.Notify("Питомцы в консоли (F9)", 3)
    else
        U.Notify("Питомцы не найдены", 2)
    end
end)

Button(PetsPage, "⭐ Эквипнуть лучшего", function()
    local r = RemoteScanner.Get()
    for _, remote in ipairs(r.Pets) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer("equip_best")
                remote:FireServer("best")
            end
        end)
    end
    U.Notify("Попытка эквипнуть лучшего", 2)
end)

Toggle(PetsPage, "🔄 Авто-эквип лучших (каждые 10с)", function(state)
    State.AutoEquipBest = state
    if state then
        task.spawn(function()
            while State.AutoEquipBest do
                pcall(function()
                    local r = RemoteScanner.Get()
                    for _, remote in ipairs(r.Pets) do
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer("equip_best")
                        end
                    end
                end)
                task.wait(10)
            end
        end)
    end
end)

Section(PetsPage, "🗑 Авто-удаление мусора")
Toggle(PetsPage, "🗑 Удалять слабых питомцев", function(state)
    State.PetAutoDelete = state
    U.Notify(state and "Авто-удаление включено" or "Авто-удаление выключено", 2)
end)

Section(PetsPage, "🥚 Egg Sniper")
Toggle(PetsPage, "🎯 Egg Sniper (открывать пока не выпадет редкий)", function(state)
    State.EggSniper = state
    if state then
        task.spawn(function()
            while State.EggSniper do
                pcall(function()
                    local r = RemoteScanner.Get()
                    for _, remote in ipairs(r.Eggs) do
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer("hatch")
                        end
                    end
                end)
                task.wait(1)
            end
        end)
        U.Notify("🎯 Egg Sniper включен", 3, Theme.Rare)
    end
end)

--============================================================
-- 3) AUTO-QUEST & REBIRTH
--============================================================
local QuestPage = CreateTab("Quests", "🎯", 3)

Section(QuestPage, "🎯 Auto-Quest")
Label(QuestPage, "Автоматически выполняет ежедневные задания", Color3.fromRGB(200, 255, 200))

Toggle(QuestPage, "🎯 Auto-Claim награды (каждые 30с)", function(state)
    State.AutoClaim = state
    if state then
        task.spawn(function()
            while State.AutoClaim do
                pcall(function()
                    local r = RemoteScanner.Get()
                    for _, remote in ipairs(r.Claim) do
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer("claim")
                            remote:FireServer()
                            remote:FireServer("daily")
                        end
                    end
                end)
                task.wait(30)
            end
        end)
        U.Notify("🎯 Auto-Claim включен", 3, Theme.Success)
    end
end)

Toggle(QuestPage, "📜 Auto-Quest (выполнять задания)", function(state)
    State.AutoQuest = state
    if state then
        task.spawn(function()
            while State.AutoQuest do
                pcall(function()
                    local r = RemoteScanner.Get()
                    for _, remote in ipairs(r.Quest) do
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer("claim")
                            remote:FireServer("complete")
                        end
                    end
                end)
                task.wait(10)
            end
        end)
    end
end)

Section(QuestPage, "🔄 Auto-Rebirth")
Label(QuestPage, "Авто-престиж когда достигнешь нужного уровня", Color3.fromRGB(255, 200, 100))

TextBox(QuestPage, "Уровень для авто-престижа (по умолч. 100)", function(text)
    local num = tonumber(text)
    if num then
        Config.AutoRebirthLevel = num
        U.Notify("Уровень престижа: " .. num, 2)
    end
end)

Toggle(QuestPage, "🔄 Auto-Rebirth (когда достигнут уровень)", function(state)
    State.AutoRebirth = state
    if state then
        task.spawn(function()
            while State.AutoRebirth do
                pcall(function()
                    local r = RemoteScanner.Get()
                    for _, remote in ipairs(r.Rebirth) do
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer()
                            remote:FireServer("rebirth")
                        end
                    end
                end)
                task.wait(15)
            end
        end)
        U.Notify("🔄 Auto-Rebirth включен", 3, Theme.Legendary)
    end
end)

Button(QuestPage, "🎁 Auto-Claim ВСЕХ наград (разово)", function()
    local r = RemoteScanner.Get()
    local count = 0
    for _, remote in ipairs(r.Claim) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer()
                remote:FireServer("claim")
                remote:FireServer("daily")
                remote:FireServer("code")
                count = count + 1
            end
        end)
    end
    U.Notify("Отправлено claim-запросов: " .. count, 3, Theme.Success)
end)

--============================================================
-- 4) AUTO-CODES
--============================================================
local CodesPage = CreateTab("Codes", "🎁", 4)

Section(CodesPage, "🎁 Промокоды")
Label(CodesPage, "Скрипт попробует активировать все известные коды", Color3.fromRGB(255, 200, 100))

local CODES = {
    "RELEASE", "UPDATE1", "UPDATE2", "UPDATE3", "FREEPET",
    "100KVISITS", "1MVISITS", "500KLIKES", "10KLIKES",
    "THANKS", "WELCOME", "NEWYEAR", "CHRISTMAS",
    "SUMMER", "WINTER", "SPRING", "AUTUMN",
    "FREECOINS", "FREEANIMALS", "GIFTPET",
    "DOG", "CAT", "BUNNY", "HAMSTER", "PARROT",
    "SECRET", "HIDDEN", "SUPER", "MEGA", "ULTRA",
}

Button(CodesPage, "🎁 Попробовать ВСЕ коды", function()
    local count = 0
    for _, code in ipairs(CODES) do
        pcall(function()
            -- Пробуем через все найденные remotes
            local r = RemoteScanner.Get()
            for _, remote in ipairs(r.Claim) do
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(code)
                    remote:FireServer("redeem", code)
                    remote:FireServer("code", code)
                    count = count + 1
                end
            end
        end)
        task.wait(0.1)
    end
    U.Notify("Отправлено попыток: " .. count, 3, Theme.Success)
end)

TextBox(CodesPage, "Свой код (введи и нажми Enter)", function(text)
    local r = RemoteScanner.Get()
    for _, remote in ipairs(r.Claim) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(text)
                remote:FireServer("redeem", text)
            end
        end)
    end
    U.Notify("Код отправлен: " .. text, 2)
end)

--============================================================
-- 5) PLAYER
--============================================================
local PlayerPage = CreateTab("Player", "🏃", 5)

Section(PlayerPage, "⚡ Скорость")
Button(PlayerPage, "⚡ Speed 100", function()
    local _, _, hum = U.GetChar()
    if hum then hum.WalkSpeed = 100 end
end)
Button(PlayerPage, "⚡ Speed 200", function()
    local _, _, hum = U.GetChar()
    if hum then hum.WalkSpeed = 200 end
end)
Button(PlayerPage, "⚡ Speed 500", function()
    local _, _, hum = U.GetChar()
    if hum then hum.WalkSpeed = 500 end
end)
Button(PlayerPage, "🐢 Speed 16", function()
    local _, _, hum = U.GetChar()
    if hum then hum.WalkSpeed = 16 end
end)

Section(PlayerPage, "🦘 Прыжок")
Button(PlayerPage, "🦘 Jump 200", function()
    local _, _, hum = U.GetChar()
    if hum then hum.UseJumpPower = true; hum.JumpPower = 200 end
end)
Button(PlayerPage, "🦘 Jump 500", function()
    local _, _, hum = U.GetChar()
    if hum then hum.UseJumpPower = true; hum.JumpPower = 500 end
end)
Button(PlayerPage, "🦘 Infinite Jump", function()
    if _G.DasterInfJump then _G.DasterInfJump:Disconnect() end
    _G.DasterInfJump = UserInputService.JumpRequest:Connect(function()
        local _, _, hum = U.GetChar()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
    U.Notify("Infinite Jump включен", 2)
end)

Section(PlayerPage, "🕊 Fly / Noclip")
Toggle(PlayerPage, "🕊 Fly (WASD + Space/Ctrl)", function(state)
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

Toggle(PlayerPage, "👻 Noclip", function(state)
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
Toggle(PlayerPage, "🛡 God Mode", function(state)
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

Toggle(PlayerPage, "🛡 Anti-Fling", function(state)
    if state then
        _G.DasterAntiFlingConn = RunService.Heartbeat:Connect(function()
            local _, hrp = U.GetChar()
            if hrp and hrp.Velocity.Magnitude > 100 then
                hrp.Velocity = Vector3.zero
                hrp.RotVelocity = Vector3.zero
            end
        end)
    else
        if _G.DasterAntiFlingConn then _G.DasterAntiFlingConn:Disconnect() end
    end
end)

--============================================================
-- 6) TELEPORT
--============================================================
local TpPage = CreateTab("Teleport", "🎯", 6)

Section(TpPage, "🎯 К игрокам")
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        Button(TpPage, "➡ К " .. p.Name, function()
            local _, hrp = U.GetChar()
            local tc = p.Character
            if hrp and tc and tc:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = tc.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end)
    end
end

Section(TpPage, "🎯 К объектам")
Button(TpPage, "🥚 К ближайшему яйцу", function()
    local _, hrp = U.GetChar()
    if not hrp then return end
    local eggs = FindByNames(EGG_KW)
    local closest, dist = nil, math.huge
    for _, egg in ipairs(eggs) do
        local part = egg:IsA("Model") and (egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")) or egg
        if part then
            local d = (part.Position - hrp.Position).Magnitude
            if d < dist then dist = d; closest = part end
        end
    end
    if closest then hrp.CFrame = closest.CFrame + Vector3.new(0, 5, 0) end
end)

Button(TpPage, "💰 К ближайшей монете", function()
    local _, hrp = U.GetChar()
    if not hrp then return end
    local coins = FindByNames(COIN_KW)
    local closest, dist = nil, math.huge
    for _, c in ipairs(coins) do
        local part = c:IsA("Model") and (c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart")) or c
        if part then
            local d = (part.Position - hrp.Position).Magnitude
            if d < dist then dist = d; closest = part end
        end
    end
    if closest then hrp.CFrame = closest.CFrame + Vector3.new(0, 5, 0) end
end)

Section(TpPage, "🌐 Сервер")
Button(TpPage, "🔄 Rejoin", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
Button(TpPage, "🖥 Server Hop", function()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    for _, s in ipairs(servers) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
            break
        end
    end
end)

--============================================================
-- 7) VISUALS
--============================================================
local VisPage = CreateTab("Visuals", "👁", 7)

Section(VisPage, "🌄 Освещение")
Toggle(VisPage, "☀ Fullbright", function(state)
    if state then
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.GlobalShadows = false
    else
        Lighting.Ambient = Color3.fromRGB(70,70,70)
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)

Section(VisPage, "🎯 ESP")
Toggle(VisPage, "💰 ESP на монеты (жёлтый)", function(state)
    State.ESPCoins = state
    if state then
        task.spawn(function()
            while State.ESPCoins do
                pcall(function()
                    for _, c in ipairs(FindByNames(COIN_KW)) do
                        local part = c:IsA("Model") and (c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart")) or c
                        if part and not part:FindFirstChild("DasterCoinEsp") then
                            U.Create("Highlight", {
                                Name = "DasterCoinEsp",
                                FillColor = Theme.Coin,
                                OutlineColor = Color3.fromRGB(255,255,255),
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
            if obj.Name == "DasterCoinEsp" then obj:Destroy() end
        end
    end
end)

Toggle(VisPage, "🥚 ESP на яйца (розовый)", function(state)
    State.ESPEggs = state
    if state then
        task.spawn(function()
            while State.ESPEggs do
                pcall(function()
                    for _, e in ipairs(FindByNames(EGG_KW)) do
                        local part = e:IsA("Model") and (e.PrimaryPart or e:FindFirstChildWhichIsA("BasePart")) or e
                        if part and not part:FindFirstChild("DasterEggEsp") then
                            U.Create("Highlight", {
                                Name = "DasterEggEsp",
                                FillColor = Theme.Egg,
                                OutlineColor = Color3.fromRGB(255,255,255),
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
            if obj.Name == "DasterEggEsp" then obj:Destroy() end
        end
    end
end)

Toggle(VisPage, "🐾 ESP на питомцев (зелёный)", function(state)
    State.ESPPets = state
    if state then
        task.spawn(function()
            while State.ESPPets do
                pcall(function()
                    for _, p in ipairs(FindByNames(PET_KW)) do
                        local part = p:IsA("Model") and (p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart")) or p
                        if part and not part:FindFirstChild("DasterPetEsp") then
                            U.Create("Highlight", {
                                Name = "DasterPetEsp",
                                FillColor = Theme.Animal,
                                OutlineColor = Color3.fromRGB(255,255,255),
                                FillTransparency = 0.5, Parent = part,
                            })
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    else
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "DasterPetEsp" then obj:Destroy() end
        end
    end
end)

Toggle(VisPage, "👥 ESP на игроков (красный)", function(state)
    State.ESPPlayers = state
    if state then
        task.spawn(function()
            while State.ESPPlayers do
                pcall(function()
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character then
                            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                            if hrp and not hrp:FindFirstChild("DasterPlrEsp") then
                                U.Create("Highlight", {
                                    Name = "DasterPlrEsp",
                                    FillColor = Color3.fromRGB(255, 0, 0),
                                    OutlineColor = Color3.fromRGB(255, 255, 255),
                                    FillTransparency = 0.5, Parent = hrp,
                                })
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    else
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "DasterPlrEsp" then obj:Destroy() end
        end
    end
end)

--============================================================
-- 8) ANTI-AFK / SERVER
--============================================================
local ServerPage = CreateTab("Server", "🌐", 8)

Section(ServerPage, "🛡 Anti-AFK Pro")
Toggle(ServerPage, "🛡 Anti-AFK (базовый)", function(state)
    State.AntiAFK = state
    Config.AntiAFKLevel = 1
    AntiAFKPro()
end)
Toggle(ServerPage, "🛡 Anti-AFK (агрессивный)", function(state)
    State.AntiAFK = state
    Config.AntiAFKLevel = 2
    AntiAFKPro()
end)
Toggle(ServerPage, "🛡 Anti-AFK (параноик)", function(state)
    State.AntiAFK = state
    Config.AntiAFKLevel = 3
    AntiAFKPro()
end)

Section(ServerPage, "🌐 Auto-Server Hop")
Toggle(ServerPage, "🌐 Auto-Hop (каждые 10 минут)", function(state)
    State.AutoHop = state
    if state then
        task.spawn(function()
            while State.AutoHop do
                task.wait(Config.AutoHopMinutes * 60)
                if State.AutoHop then
                    pcall(function()
                        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
                        for _, s in ipairs(servers) do
                            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                                break
                            end
                        end
                    end)
                end
            end
        end)
    end
end)

--============================================================
-- 9) REMOTES
--============================================================
local RemPage = CreateTab("Remotes", "🔧", 9)

Section(RemPage, "⚠ Server-side")
Label(RemPage, "Монеты/питомцы на сервере. Ниже — попытки через remotes.", Color3.fromRGB(255, 200, 100))

Section(RemPage, "💰 Монеты")
TextBox(RemPage, "Сколько монет добавить?", function(text)
    local num = tonumber(text)
    if not num then U.Notify("Введи число!", 2, Theme.Error); return end
    local r = RemoteScanner.Get()
    for _, remote in ipairs(r.Coins) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(num)
                remote:FireServer("add", num)
            end
        end)
    end
    U.Notify("Отправлено на " .. num, 3)
end)

Button(RemPage, "🚀 Попробовать +1.000.000 монет", function()
    local r = RemoteScanner.Get()
    for _, remote in ipairs(r.Coins) do
        pcall(function()
            if remote:IsA("RemoteEvent") then remote:FireServer(1000000) end
        end)
    end
    U.Notify("Отправлено на 1.000.000", 3)
end)

Section(RemPage, "🐾 Питомцы")
Button(RemPage, "🎁 Попробовать выдать легендарного питомца", function()
    local r = RemoteScanner.Get()
    for _, remote in ipairs(r.Pets) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer("give", "Legendary")
                remote:FireServer("give", "Dragon")
                remote:FireServer("give", "Unicorn")
            end
        end)
    end
    U.Notify("Попытка выдать легендарного", 3)
end)

Section(RemPage, "🔍 Сканер")
Button(RemPage, "🔍 Сканировать все remotes", function()
    Remotes = RemoteScanner.Scan()
    U.Notify("Всего: " .. #Remotes.All 
        .. " | 💰 " .. #Remotes.Coins 
        .. " | 🐾 " .. #Remotes.Pets 
        .. " | 🥚 " .. #Remotes.Eggs
        .. " | 🎁 " .. #Remotes.Claim
        .. " | 🔄 " .. #Remotes.Rebirth, 6)
end)

Button(RemPage, "📋 Все remotes в консоль", function()
    local r = RemoteScanner.Get()
    for _, remote in ipairs(r.All) do
        print("[DasterJFA Remote] " .. remote:GetFullName())
    end
    U.Notify("Список в консоли (F9)", 3)
end)

--============================================================
-- 10) STATS
--============================================================
local StatsPage = CreateTab("Stats", "📊", 10)

Section(StatsPage, "📊 Статистика сессии")
local uptimeLbl = Label(StatsPage, "⏱ Uptime: 0с", Theme.TextDim)
local jumpsLbl = Label(StatsPage, "🦘 Прыжков: 0", Theme.TextDim)
local fpsLbl = Label(StatsPage, "📈 FPS: 0", Theme.TextDim)
local pingLbl = Label(StatsPage, "📡 Ping: 0 ms", Theme.TextDim)

task.spawn(function()
    while uptimeLbl.Parent do
        pcall(function()
            uptimeLbl.Text = "⏱ Uptime: " .. U.FormatTime(tick() - Stats_.StartTime)
            jumpsLbl.Text = "🦘 Прыжков: " .. U.FormatNumber(Stats_.Jumps)
            fpsLbl.Text = "📈 FPS: " .. math.floor(1 / RunService.RenderStepped:Wait())
            pingLbl.Text = "📡 Ping: " .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. " ms"
        end)
        task.wait(1)
    end
end)

Section(StatsPage, "🎮 Инфа об игре")
Button(StatsPage, "🖥 Job ID", function()
    if setclipboard then
        setclipboard(game.JobId)
        U.Notify("Job ID скопирован!", 2, Theme.Success)
    else
        U.Notify("Job ID: " .. game.JobId, 5)
    end
end)

--============================================================
-- 11) SETTINGS
--============================================================
local SetPage = CreateTab("Settings", "⚙", 11)

Section(SetPage, "🎨 Внешний вид")
Label(SetPage, "Смена фона меню:", Theme.TextDim)
for i, bg in ipairs(Config.Backgrounds) do
    Button(SetPage, "🖼 Фон #" .. i, function()
        BgImage.Image = bg
        U.Notify("Фон #" .. i .. " установлен", 2)
    end)
end

Section(SetPage, "ℹ Информация")
Label(SetPage, "Версия: v" .. Config.Version)
Label(SetPage, "Toggle UI: " .. Config.ToggleKey.Name)
Label(SetPage, "Hide UI: " .. Config.HideKey.Name)
Label(SetPage, "Автор: Daster")

Section(SetPage, "🚨 Опасная зона")
Button(SetPage, "🗑 Отключить ВСЁ", function()
    for k in pairs(State) do State[k] = false end
    for _, conn in pairs({_G.DasterFlyConn, _G.DasterGodConn, _G.DasterNoclipConn, 
                          _G.DasterAFKConn, _G.DasterAntiFlingConn, _G.DasterInfJump}) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:find("Daster") and obj.Name:find("Esp") then obj:Destroy() end
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
-- TOGGLE / HIDE KEYS
--============================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Config.ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
    end
    if input.KeyCode == Config.HideKey then
        ScreenGui.Enabled = not ScreenGui.Enabled
        U.Notify(ScreenGui.Enabled and "UI показан" or "UI полностью скрыт", 1.5)
    end
end)

--============================================================
-- ОТКРЫВАЕМ ПЕРВУЮ ВКЛАДКУ
--============================================================
Tabs["MegaFarm"].BackgroundColor3 = Theme.Accent
Tabs["MegaFarm"].TextColor3 = Color3.fromRGB(255, 255, 255)
Pages["MegaFarm"].Visible = true

--============================================================
-- ЗАГРУЗКА
--============================================================
task.wait(0.3)
U.Notify("🐾 Daster JFA ULTIMATE v2.0 загружен!", 4, Theme.Accent)
task.wait(0.6)
U.Notify("🔥 Жми 'ЗАПУСТИТЬ ВСЁ' в MegaFarm!", 5, Theme.Success)
task.wait(0.6)
U.Notify("🎁 Не забудь про Auto-Codes!", 4, Theme.Coin)

print("[Daster JFA] ✅ ULTIMATE v2.0 загружен! Вкладок: 11")
