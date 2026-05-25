-- SertaiVN UI Library v2.2
-- Based on Orion (Discontinued) - Thanks to Orion team!
-- Reworked by SertaiVN: Settings Panel, rbxassetid icons, search tabs, mobile improvements

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local SertaiVNLib = {
    Elements = {}, ThemeObjects = {}, Connections = {}, Flags = {},
    Themes = {
        Default = {
            Main = Color3.fromRGB(20, 20, 26),
            Second = Color3.fromRGB(28, 28, 36),
            Stroke = Color3.fromRGB(55, 55, 70),
            Divider = Color3.fromRGB(55, 55, 70),
            Text = Color3.fromRGB(245, 245, 250),
            TextDark = Color3.fromRGB(160, 160, 175),
            Accent = Color3.fromRGB(130, 110, 230)
        }
    },
    SelectedTheme = "Default", Folder = nil, SaveCfg = false
}

local DEFAULT_CLOSE = "rbxassetid://99967063680607"
local DEFAULT_SETTINGS = "rbxassetid://2484550861"
local DEFAULT_HOME = "rbxassetid://9405923708"

local SertaiVN = Instance.new("ScreenGui")
SertaiVN.Name = "SertaiVN"
if syn then syn.protect_gui(SertaiVN); SertaiVN.Parent = CoreGui
else SertaiVN.Parent = gethui and gethui() or CoreGui end

local target = gethui and gethui() or CoreGui
for _, Interface in ipairs(target:GetChildren()) do
    if Interface.Name == SertaiVN.Name and Interface ~= SertaiVN then Interface:Destroy() end
end

function SertaiVNLib:IsRunning()
    return SertaiVN.Parent == (gethui and gethui() or CoreGui)
end

local function AddConnection(Signal, Function)
    if not SertaiVNLib:IsRunning() then return end
    local c = Signal:Connect(Function)
    table.insert(SertaiVNLib.Connections, c)
    return c
end

task.spawn(function()
    while SertaiVNLib:IsRunning() do wait() end
    for _, c in next, SertaiVNLib.Connections do c:Disconnect() end
end)

local function AddDraggingFunctionality(DragPoint, Main)
    pcall(function()
        local Dragging, DragInput, MousePos, FramePos = false
        DragPoint.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true; MousePos = Input.Position; FramePos = Main.Position
                Input.Changed:Connect(function() if Input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
            end
        end)
        DragPoint.InputChanged:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then DragInput = Input end
        end)
        UserInputService.InputChanged:Connect(function(Input)
            if Input == DragInput and Dragging then
                local Delta = Input.Position - MousePos
                TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)}):Play()
            end
        end)
    end)
end

local function Create(Name, Properties, Children)
    local Object = Instance.new(Name)
    for i, v in next, Properties or {} do Object[i] = v end
    for i, v in next, Children or {} do v.Parent = Object end
    return Object
end

local function CreateElement(n, f) SertaiVNLib.Elements[n] = function(...) return f(...) end end
local function MakeElement(n, ...) return SertaiVNLib.Elements[n](...) end
local function SetProps(E, P) for k, v in pairs(P) do E[k] = v end; return E end
local function SetChildren(E, C) for _, c in pairs(C) do c.Parent = E end; return E end
local function Round(N, F) local R = math.floor(N/F + (math.sign(N)*0.5))*F; if R < 0 then R = R + F end; return R end

local function ReturnProperty(O)
    if O:IsA("Frame") or O:IsA("TextButton") then return "BackgroundColor3" end
    if O:IsA("ScrollingFrame") then return "ScrollBarImageColor3" end
    if O:IsA("UIStroke") then return "Color" end
    if O:IsA("TextLabel") or O:IsA("TextBox") then return "TextColor3" end
    if O:IsA("ImageLabel") or O:IsA("ImageButton") then return "ImageColor3" end
end

local function AddThemeObject(O, T)
    if not SertaiVNLib.ThemeObjects[T] then SertaiVNLib.ThemeObjects[T] = {} end
    table.insert(SertaiVNLib.ThemeObjects[T], O)
    O[ReturnProperty(O)] = SertaiVNLib.Themes[SertaiVNLib.SelectedTheme][T]
    return O
end

local function PackColor(C) return {R = C.R*255, G = C.G*255, B = C.B*255} end
local function UnpackColor(C) return Color3.fromRGB(C.R, C.G, C.B) end

local function LoadCfg(Config)
    local Data = HttpService:JSONDecode(Config)
    for a, b in pairs(Data) do
        if SertaiVNLib.Flags[a] then
            spawn(function()
                if SertaiVNLib.Flags[a].Type == "Colorpicker" then SertaiVNLib.Flags[a]:Set(UnpackColor(b))
                else SertaiVNLib.Flags[a]:Set(b) end
            end)
        end
    end
end

local function SaveCfg(Name)
    local Data = {}
    for i, v in pairs(SertaiVNLib.Flags) do
        if v.Save then
            if v.Type == "Colorpicker" then Data[i] = PackColor(v.Value) else Data[i] = v.Value end
        end
    end
    pcall(function() writefile(SertaiVNLib.Folder .. "/" .. Name .. ".txt", HttpService:JSONEncode(Data)) end)
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right, Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Backspace, Enum.KeyCode.Escape}

local function CheckKey(T, K) for _, v in next, T do if v == K then return true end end end

CreateElement("Corner", function(S, O) return Create("UICorner", {CornerRadius = UDim.new(S or 0, O or 10)}) end)
CreateElement("Stroke", function(C, T) return Create("UIStroke", {Color = C or Color3.fromRGB(255,255,255), Thickness = T or 1}) end)
CreateElement("List", function(S, O) return Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(S or 0, O or 0)}) end)
CreateElement("Padding", function(B, L, R, T) return Create("UIPadding", {PaddingBottom = UDim.new(0, B or 4), PaddingLeft = UDim.new(0, L or 4), PaddingRight = UDim.new(0, R or 4), PaddingTop = UDim.new(0, T or 4)}) end)
CreateElement("TFrame", function() return Create("Frame", {BackgroundTransparency = 1}) end)
CreateElement("Frame", function(C) return Create("Frame", {BackgroundColor3 = C or Color3.fromRGB(255,255,255), BorderSizePixel = 0}) end)
CreateElement("RoundFrame", function(C, S, O) return Create("Frame", {BackgroundColor3 = C or Color3.fromRGB(255,255,255), BorderSizePixel = 0}, {Create("UICorner", {CornerRadius = UDim.new(S, O)})}) end)
CreateElement("Button", function() return Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0}) end)
CreateElement("ScrollFrame", function(C, W) return Create("ScrollingFrame", {BackgroundTransparency = 1, MidImage = "rbxassetid://7445543667", BottomImage = "rbxassetid://7445543667", TopImage = "rbxassetid://7445543667", ScrollBarImageColor3 = C, BorderSizePixel = 0, ScrollBarThickness = W, CanvasSize = UDim2.new(0,0,0,0)}) end)
CreateElement("Image", function(I) return Create("ImageLabel", {Image = I, BackgroundTransparency = 1}) end)
CreateElement("ImageButton", function(I) return Create("ImageButton", {Image = I, BackgroundTransparency = 1}) end)
CreateElement("Label", function(T, S, Tr) return Create("TextLabel", {Text = T or "", TextColor3 = Color3.fromRGB(240,240,240), TextTransparency = Tr or 0, TextSize = S or 15, Font = Enum.Font.Gotham, RichText = true, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left}) end)

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
    SetProps(MakeElement("List"), {HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0,5)})
}), {Position = UDim2.new(1,-25,1,-25), Size = UDim2.new(0,300,1,-25), AnchorPoint = Vector2.new(1,1), Parent = SertaiVN})

function SertaiVNLib:MakeNotification(c)
    spawn(function()
        c.Name = c.Name or "Notification"
        c.Content = c.Content or "Test"
        c.Image = c.Image or "rbxassetid://4384403532"
        c.Time = c.Time or 15

        local NotificationParent = SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Parent = NotificationHolder})
        local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25,25,25), 0, 10), {
            Parent = NotificationParent, Size = UDim2.new(1,0,0,0), Position = UDim2.new(1,-55,0,0), BackgroundTransparency = 0, AutomaticSize = Enum.AutomaticSize.Y
        }), {
            MakeElement("Stroke", Color3.fromRGB(93,93,93), 1.2),
            MakeElement("Padding", 12, 12, 12, 12),
            SetProps(MakeElement("Image", c.Image), {
                Size = UDim2.new(0, 20, 0, 20), ImageColor3 = SertaiVNLib.Themes.Default.Accent, Name = "Icon"
            }),
            SetProps(MakeElement("Label", c.Name, 15), {Size = UDim2.new(1,-30,0,20), Position = UDim2.new(0,30,0,0), Font = Enum.Font.GothamBold, Name = "Title"}),
            SetProps(MakeElement("Label", c.Content, 14), {Size = UDim2.new(1,0,0,0), Position = UDim2.new(0,0,0,25), Font = Enum.Font.GothamSemibold, Name = "Content", AutomaticSize = Enum.AutomaticSize.Y, TextColor3 = Color3.fromRGB(200,200,200), TextWrapped = true})
        })

        TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0,0,0,0)}):Play()
        wait(c.Time - 0.88)
        TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
        wait(0.3)
        TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
        TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
        TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
        wait(0.05)
        NotificationFrame:TweenPosition(UDim2.new(1,20,0,0), 'In', 'Quint', 0.8, true)
        wait(1.35); NotificationFrame:Destroy()
    end)
end

function SertaiVNLib:Init()
    if SertaiVNLib.SaveCfg then
        pcall(function()
            if isfile(SertaiVNLib.Folder .. "/" .. game.GameId .. ".txt") then
                LoadCfg(readfile(SertaiVNLib.Folder .. "/" .. game.GameId .. ".txt"))
                SertaiVNLib:MakeNotification({Name = "Configuration", Content = "Auto-loaded config for game " .. game.GameId, Time = 5})
            end
        end)
    end
end

function SertaiVNLib:MakeWindow(WindowConfig)
    local FirstTab = true
    local Minimized = false
    local UIHidden = false

    WindowConfig = WindowConfig or {}
    WindowConfig.Name = WindowConfig.Name or "SertaiVN Library"
    WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
    WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
    WindowConfig.HidePremium = WindowConfig.HidePremium or false
    if WindowConfig.IntroEnabled == nil then WindowConfig.IntroEnabled = true end
    WindowConfig.IntroText = WindowConfig.IntroText or "SertaiVN Library"
    WindowConfig.IntroLogo = WindowConfig.IntroLogo or "rbxassetid://9405923708"
    WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
    WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://9405923708"
    WindowConfig.ToggleIcon = WindowConfig.ToggleIcon or "rbxassetid://9405923708"
    WindowConfig.Socials = WindowConfig.Socials or {}
    SertaiVNLib.Folder = WindowConfig.ConfigFolder
    SertaiVNLib.SaveCfg = WindowConfig.SaveConfig

    if WindowConfig.SaveConfig then
        if not isfolder(WindowConfig.ConfigFolder) then pcall(makefolder, WindowConfig.ConfigFolder) end
    end

    local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 4), {Size = UDim2.new(1,0,1,-90)}), {
        MakeElement("List"), MakeElement("Padding", 8, 0, 0, 8)
    }), "Divider")

    AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        TabHolder.CanvasSize = UDim2.new(0,0,0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
    end)

    -- Search Tabs Bar
    local SearchBar = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {
        Size = UDim2.new(1,-10,0,28), Position = UDim2.new(0,5,0,5)
    }), {
        AddThemeObject(MakeElement("Stroke"), "Stroke"),
        Create("TextBox", {
            Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,8,0,0), BackgroundTransparency = 1,
            Text = "", PlaceholderText = "🔍 Search tabs...", TextColor3 = Color3.fromRGB(240,240,240),
            PlaceholderColor3 = Color3.fromRGB(160,160,175), Font = Enum.Font.Gotham, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Name = "Input"
        })
    }), "Second")

    -- Custom close button using rbxassetid
    local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(0.5,0,1,0), Position = UDim2.new(0.5,0,0,0), BackgroundTransparency = 1}), {
        AddThemeObject(SetProps(MakeElement("Image", DEFAULT_CLOSE), {Position = UDim2.new(0,9,0,6), Size = UDim2.new(0,18,0,18)}), "Text")
    })

    local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(0.5,0,1,0), BackgroundTransparency = 1}), {
        AddThemeObject(SetProps(MakeElement("Label", "—", 18), {Size = UDim2.new(1,0,1,0), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold, Name = "Ico"}), "Text")
    })

    local DragPoint = SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,50)})

    -- Settings Button (bottom of sidebar)
    local SettingsBtn = AddThemeObject(SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(1,-10,0,32), Position = UDim2.new(0,5,1,-37)}), {
        AddThemeObject(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {Size = UDim2.new(1,0,1,0)}), "Second"),
        AddThemeObject(SetProps(MakeElement("Image", DEFAULT_SETTINGS), {Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,8,0.5,-9)}), "Text"),
        AddThemeObject(SetProps(MakeElement("Label", "Settings", 13), {Size = UDim2.new(1,-32,1,0), Position = UDim2.new(0,32,0,0), Font = Enum.Font.GothamSemibold}), "Text")
    }), "Text")

    local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 10), {Size = UDim2.new(0,150,1,-50), Position = UDim2.new(0,0,0,50)}), {
        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,0,0)}), "Second"),
        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0,10,1,0), Position = UDim2.new(1,-10,0,0)}), "Second"),
        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0,1,1,0), Position = UDim2.new(1,-1,0,0)}), "Stroke"),
        SearchBar,
        SetProps(SetChildren(MakeElement("TFrame"), {TabHolder}), {Size = UDim2.new(1,0,1,-40), Position = UDim2.new(0,0,0,38), Name = "TabContainer"}),
        SettingsBtn
    }), "Second")

    -- Fix TabHolder positioning
    TabHolder.Parent = WindowStuff.TabContainer
    TabHolder.Position = UDim2.new(0,0,0,0)
    TabHolder.Size = UDim2.new(1,0,1,-37)

    local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {Size = UDim2.new(1,-30,2,0), Position = UDim2.new(0,45,0,-24), Font = Enum.Font.GothamBlack, TextSize = 20}), "Text")
    local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {Size = UDim2.new(0,22,0,22), Position = UDim2.new(0,15,0,14)})
    local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1)}), "Stroke")

    local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 10), {
        Parent = SertaiVN, Position = UDim2.new(0.5,-307,0.5,-172), Size = UDim2.new(0,615,0,344), ClipsDescendants = true
    }), {
        SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,50), Name = "TopBar"}), {
            WindowIcon, WindowName, WindowTopBarLine,
            AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 7), {Size = UDim2.new(0,70,0,30), Position = UDim2.new(1,-90,0,10)}), {
                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0,1,1,0), Position = UDim2.new(0.5,0,0,0)}), "Stroke"),
                CloseBtn, MinimizeBtn
            }), "Second")
        }),
        DragPoint, WindowStuff
    }), "Main")

    -- Mobile Toggle Button (uses rbxassetid icon, draggable on UI itself)
    local MobileToggle = SetChildren(SetProps(MakeElement("RoundFrame", SertaiVNLib.Themes.Default.Second, 0, 25), {
        Parent = SertaiVN, Position = UDim2.new(0,15,0,80), Size = UDim2.new(0,50,0,50), Visible = false
    }), {
        MakeElement("Stroke", SertaiVNLib.Themes.Default.Accent, 2),
        SetProps(MakeElement("Image", WindowConfig.ToggleIcon), {Size = UDim2.new(0,28,0,28), Position = UDim2.new(0.5,-14,0.5,-14)}),
        SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0), Name = "Click"})
    })

    AddDraggingFunctionality(DragPoint, MainWindow)
    AddDraggingFunctionality(MobileToggle, MobileToggle)

    AddConnection(CloseBtn.MouseButton1Up, function()
        MainWindow.Visible = false
        UIHidden = true
        MobileToggle.Visible = true
        SertaiVNLib:MakeNotification({Name = "Interface Hidden", Content = "Tap RightShift or floating button to reopen", Time = 5})
        WindowConfig.CloseCallback()
    end)

    AddConnection(MobileToggle.Click.MouseButton1Click, function()
        MainWindow.Visible = true; UIHidden = false; MobileToggle.Visible = false
    end)

    AddConnection(UserInputService.InputBegan, function(Input)
        if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
            MainWindow.Visible = true; UIHidden = false; MobileToggle.Visible = false
        end
    end)

    AddConnection(MinimizeBtn.MouseButton1Up, function()
        if Minimized then
            TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0,615,0,344)}):Play()
            MinimizeBtn.Ico.Text = "—"
            wait(0.02); MainWindow.ClipsDescendants = false; WindowStuff.Visible = true; WindowTopBarLine.Visible = true
        else
            MainWindow.ClipsDescendants = true; WindowTopBarLine.Visible = false; MinimizeBtn.Ico.Text = "+"
            TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, WindowName.TextBounds.X + 160, 0, 50)}):Play()
            wait(0.1); WindowStuff.Visible = false
        end
        Minimized = not Minimized
    end)

    -- NEW Loading Screen with logo image
    local function LoadSequence()
        MainWindow.Visible = false
        local LoadingBg = SetProps(MakeElement("RoundFrame", Color3.fromRGB(15,15,20), 0, 0), {
            Parent = SertaiVN, Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 0, ZIndex = 100
        })
        Create("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(15,15,20), Color3.fromRGB(25,20,40)), Rotation = 135, Parent = LoadingBg})

        local LogoFrame = SetProps(MakeElement("RoundFrame", SertaiVNLib.Themes.Default.Second, 1, 0), {
            Parent = LoadingBg, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,-30), Size = UDim2.new(0,0,0,0), ZIndex = 101
        })
        Create("UIStroke", {Color = SertaiVNLib.Themes.Default.Accent, Thickness = 2, Parent = LogoFrame})

        local LogoImage = SetProps(MakeElement("Image", WindowConfig.IntroLogo), {
            Parent = LogoFrame, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,48,0,48), ImageTransparency = 1, ZIndex = 102
        })

        local TitleText = SetProps(MakeElement("Label", "", 22), {
            Parent = LoadingBg, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,40), Size = UDim2.new(1,0,0,30), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255,255,255), ZIndex = 101
        })

        local SubText = SetProps(MakeElement("Label", "Loading...", 12), {
            Parent = LoadingBg, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,68), Size = UDim2.new(1,0,0,16), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(160,160,180), TextTransparency = 1, ZIndex = 101
        })

        TweenService:Create(LogoFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = UDim2.new(0,80,0,80)}):Play()
        wait(0.3)
        TweenService:Create(LogoImage, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
        wait(0.4)

        local fullText = WindowConfig.IntroText
        for i = 1, #fullText do TitleText.Text = string.sub(fullText, 1, i); wait(0.04) end

        TweenService:Create(SubText, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        wait(1.4)

        TweenService:Create(LogoFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0,0,0,0)}):Play()
        TweenService:Create(TitleText, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        TweenService:Create(SubText, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        TweenService:Create(LoadingBg, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
        wait(0.5)
        MainWindow.Visible = true
        LoadingBg:Destroy()
    end

    if WindowConfig.IntroEnabled then LoadSequence() end

    -- ============ SETTINGS PANEL ============
    local SettingsPanel = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 10), {
        Parent = MainWindow, Size = UDim2.new(1,-150,1,-50), Position = UDim2.new(0,150,0,50), Visible = false, Name = "SettingsPanel", ClipsDescendants = true
    }), {
        SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 5), {
            Size = UDim2.new(1,0,1,0), Name = "Scroll", CanvasSize = UDim2.new(0,0,0,0)
        }), {MakeElement("List", 0, 8), MakeElement("Padding", 12, 12, 12, 12)})
    }), "Main")

    local SS = SettingsPanel.Scroll
    AddConnection(SS.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        SS.CanvasSize = UDim2.new(0,0,0, SS.UIListLayout.AbsoluteContentSize.Y + 24)
    end)

    -- Profile Section
    local Profile = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 8), {Size = UDim2.new(1,0,0,70), Parent = SS}), {
        AddThemeObject(MakeElement("Stroke"), "Stroke"),
        SetChildren(SetProps(MakeElement("Frame", Color3.fromRGB(40,40,55)), {AnchorPoint = Vector2.new(0,0.5), Size = UDim2.new(0,54,0,54), Position = UDim2.new(0,10,0.5,0)}), {
            SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"), {Size = UDim2.new(1,0,1,0), Name = "Avatar"}),
            MakeElement("Corner", 1)
        }),
        AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, 15), {Size = UDim2.new(1,-80,0,16), Position = UDim2.new(0,72,0,12), Font = Enum.Font.GothamBold}), "Text"),
        AddThemeObject(SetProps(MakeElement("Label", "@" .. LocalPlayer.Name, 12), {Size = UDim2.new(1,-80,0,14), Position = UDim2.new(0,72,0,32)}), "TextDark"),
        AddThemeObject(SetProps(MakeElement("Label", "ID: " .. LocalPlayer.UserId, 11), {Size = UDim2.new(1,-80,0,14), Position = UDim2.new(0,72,0,48)}), "TextDark")
    }), "Second")

    -- Info Section
    local function MakeInfoRow(label, default)
        local row = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {Size = UDim2.new(1,0,0,28), Parent = SS}), {
            AddThemeObject(MakeElement("Stroke"), "Stroke"),
            AddThemeObject(SetProps(MakeElement("Label", label, 12), {Size = UDim2.new(0.5,0,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.Gotham}), "TextDark"),
            AddThemeObject(SetProps(MakeElement("Label", default, 12), {Size = UDim2.new(0.5,-12,1,0), Position = UDim2.new(0.5,0,0,0), Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Right, Name = "Val"}), "Text")
        }), "Second")
        return row.Val
    end

    local function DetectDevice()
        if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then return "Mobile"
        elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then return "Console"
        elseif UserInputService.MouseEnabled then return "PC" else return "Unknown" end
    end

    MakeInfoRow("Device", DetectDevice())
    local FPSLbl = MakeInfoRow("FPS", "0")
    local PingLbl = MakeInfoRow("Ping", "0ms")

    local fr, lu = 0, tick()
    AddConnection(RunService.RenderStepped, function()
        fr = fr + 1
        if tick() - lu >= 1 then
            FPSLbl.Text = fr .. " FPS"; fr = 0; lu = tick()
            pcall(function() PingLbl.Text = string.format("%dms", LocalPlayer:GetNetworkPing() * 1000) end)
        end
    end)

    -- Discord/Socials paragraph
    if WindowConfig.Socials and WindowConfig.Socials.Discord then
        local DC = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(88,101,242), 0, 8), {Size = UDim2.new(1,0,0,60), Parent = SS}), {
            SetProps(MakeElement("Image", WindowConfig.Socials.DiscordImage or "rbxassetid://9405923708"), {Size = UDim2.new(0,38,0,38), Position = UDim2.new(0,10,0.5,-19)}),
            SetProps(MakeElement("Label", "SertaiVN HUB", 14), {Size = UDim2.new(1,-110,0,18), Position = UDim2.new(0,56,0,10), Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255,255,255)}),
            SetProps(MakeElement("Label", "Join our community", 11), {Size = UDim2.new(1,-110,0,14), Position = UDim2.new(0,56,0,32), TextColor3 = Color3.fromRGB(220,220,255)}),
            SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {Size = UDim2.new(0,80,0,28), Position = UDim2.new(1,-92,0.5,-14)}), {
                SetProps(MakeElement("Label", "Copy", 12), {Size = UDim2.new(1,0,1,0), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(88,101,242)}),
                SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0), Name = "Click"})
            })
        }), "Second")
        AddConnection(DC:FindFirstChild("Click", true).MouseButton1Click, function()
            pcall(function() if setclipboard then setclipboard(WindowConfig.Socials.Discord); SertaiVNLib:MakeNotification({Name = "Copied!", Content = "Discord link copied", Time = 3}) end end)
        end)
    end

    -- Config buttons
    local CfgRow = SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,32), Parent = SS}), {
        SetProps(MakeElement("List", 0, 6), {FillDirection = Enum.FillDirection.Horizontal})
    })
    local function MakeCfgBtn(text, color)
        return SetChildren(SetProps(MakeElement("RoundFrame", color, 0, 6), {Size = UDim2.new(0.5,-3,1,0), Parent = CfgRow}), {
            SetProps(MakeElement("Label", text, 12), {Size = UDim2.new(1,0,1,0), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255,255,255)}),
            SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0), Name = "Click"})
        })
    end
    local SaveBtn = MakeCfgBtn("💾 Save Config", Color3.fromRGB(90,210,130))
    local LoadBtn = MakeCfgBtn("📂 Load Config", SertaiVNLib.Themes.Default.Accent)

    AddConnection(SaveBtn.Click.MouseButton1Click, function()
        SaveCfg(game.GameId); SertaiVNLib:MakeNotification({Name = "Saved", Content = "Config saved", Time = 3})
    end)
    AddConnection(LoadBtn.Click.MouseButton1Click, function()
        pcall(function()
            if isfile(SertaiVNLib.Folder .. "/" .. game.GameId .. ".txt") then
                LoadCfg(readfile(SertaiVNLib.Folder .. "/" .. game.GameId .. ".txt"))
                SertaiVNLib:MakeNotification({Name = "Loaded", Content = "Config loaded", Time = 3})
            end
        end)
    end)

    -- Settings panel toggle
    local SettingsOpen = false
    AddConnection(SettingsBtn.MouseButton1Click, function()
        SettingsOpen = not SettingsOpen
        for _, ItemContainer in next, MainWindow:GetChildren() do
            if ItemContainer.Name == "ItemContainer" then ItemContainer.Visible = false end
        end
        SettingsPanel.Visible = SettingsOpen
        if not SettingsOpen and FirstTab == false then
            -- restore current tab
            for _, Tab in next, TabHolder:GetChildren() do
                if Tab:IsA("TextButton") and Tab.Title.Font == Enum.Font.GothamBlack then
                    for _, ItemContainer in next, MainWindow:GetChildren() do
                        if ItemContainer.Name == "ItemContainer" and ItemContainer.TabRef == Tab then
                            ItemContainer.Visible = true; break
                        end
                    end
                    break
                end
            end
        end
    end)

    -- Search tabs functionality
    AddConnection(SearchBar.Input:GetPropertyChangedSignal("Text"), function()
        local q = string.lower(SearchBar.Input.Text)
        for _, Tab in next, TabHolder:GetChildren() do
            if Tab:IsA("TextButton") then
                Tab.Visible = q == "" or string.find(string.lower(Tab.Title.Text), q, 1, true) ~= nil
            end
        end
    end)

    local TabFunction = {}
    function TabFunction:MakeTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or DEFAULT_HOME

        local TabFrame = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,0,30), Parent = TabHolder}), {
            AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
                AnchorPoint = Vector2.new(0,0.5), Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,10,0.5,0), ImageTransparency = 0.4, Name = "Ico"
            }), "Text"),
            AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
                Size = UDim2.new(1,-35,1,0), Position = UDim2.new(0,35,0,0), Font = Enum.Font.GothamSemibold, TextTransparency = 0.4, Name = "Title"
            }), "Text")
        })

        local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 5), {
            Size = UDim2.new(1,-150,1,-50), Position = UDim2.new(0,150,0,50), Parent = MainWindow, Visible = false, Name = "ItemContainer"
        }), {MakeElement("List", 0, 6), MakeElement("Padding", 15, 10, 10, 15)}), "Divider")
        Container.TabRef = TabFrame

        AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            Container.CanvasSize = UDim2.new(0,0,0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
        end)

        if FirstTab then
            FirstTab = false
            TabFrame.Ico.ImageTransparency = 0; TabFrame.Title.TextTransparency = 0
            TabFrame.Title.Font = Enum.Font.GothamBlack; Container.Visible = true
        end

        AddConnection(TabFrame.MouseButton1Click, function()
            SettingsOpen = false; SettingsPanel.Visible = false
            for _, Tab in next, TabHolder:GetChildren() do
                if Tab:IsA("TextButton") then
                    Tab.Title.Font = Enum.Font.GothamSemibold
                    TweenService:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.4}):Play()
                    TweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
                end
            end
            for _, IC in next, MainWindow:GetChildren() do
                if IC.Name == "ItemContainer" then IC.Visible = false end
            end
            TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
            TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
            TabFrame.Title.Font = Enum.Font.GothamBlack; Container.Visible = true
        end)

        local function GetElements(ItemParent)
            local ElementFunction = {}

            function ElementFunction:AddLabel(Text)
                local LF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,30), BackgroundTransparency = 0.7, Parent = ItemParent}), {
                    AddThemeObject(SetProps(MakeElement("Label", Text, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke")
                }), "Second")
                return {Set = function(_, t) LF.Content.Text = t end}
            end

            function ElementFunction:AddParagraph(Text, Content)
                local PF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,30), BackgroundTransparency = 0.7, Parent = ItemParent}), {
                    AddThemeObject(SetProps(MakeElement("Label", Text or "Text", 15), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,10), Font = Enum.Font.GothamBold, Name = "Title"}), "Text"),
                    AddThemeObject(SetProps(MakeElement("Label", "", 13), {Size = UDim2.new(1,-24,0,0), Position = UDim2.new(0,12,0,26), Font = Enum.Font.GothamSemibold, Name = "Content", TextWrapped = true}), "TextDark"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke")
                }), "Second")
                AddConnection(PF.Content:GetPropertyChangedSignal("Text"), function()
                    PF.Content.Size = UDim2.new(1,-24,0, PF.Content.TextBounds.Y)
                    PF.Size = UDim2.new(1,0,0, PF.Content.TextBounds.Y + 35)
                end)
                PF.Content.Text = Content or ""
                return {Set = function(_, t) PF.Content.Text = t end}
            end

            -- Socials paragraph with image + copy link
            function ElementFunction:AddSocialsParagraph(SocialConfig)
                SocialConfig = SocialConfig or {}
                local title = SocialConfig.Title or "Socials"
                local content = SocialConfig.Content or ""
                local image = SocialConfig.Image or "rbxassetid://9405923708"
                local link = SocialConfig.Link or ""
                local linkText = SocialConfig.LinkText or "Copy Link"

                local PF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,80), Parent = ItemParent}), {
                    AddThemeObject(MakeElement("Stroke"), "Stroke"),
                    SetProps(MakeElement("Image", image), {Size = UDim2.new(0,48,0,48), Position = UDim2.new(0,10,0,12)}),
                    AddThemeObject(SetProps(MakeElement("Label", title, 14), {Size = UDim2.new(1,-70,0,16), Position = UDim2.new(0,66,0,10), Font = Enum.Font.GothamBold}), "Text"),
                    AddThemeObject(SetProps(MakeElement("Label", content, 12), {Size = UDim2.new(1,-70,0,14), Position = UDim2.new(0,66,0,28), Font = Enum.Font.Gotham, TextWrapped = true}), "TextDark"),
                    SetChildren(SetProps(MakeElement("RoundFrame", SertaiVNLib.Themes.Default.Accent, 0, 5), {Size = UDim2.new(0,110,0,22), Position = UDim2.new(0,66,1,-30)}), {
                        SetProps(MakeElement("Label", "🔗 " .. linkText, 11), {Size = UDim2.new(1,0,1,0), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamSemibold, TextColor3 = Color3.fromRGB(255,255,255)}),
                        SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0), Name = "Click"})
                    })
                }), "Second")
                AddConnection(PF:FindFirstChild("Click", true).MouseButton1Click, function()
                    pcall(function() if setclipboard then setclipboard(link); SertaiVNLib:MakeNotification({Name = "Copied", Content = link, Time = 3}) end end)
                end)
                return PF
            end

            function ElementFunction:AddButton(BC)
                BC = BC or {}; BC.Name = BC.Name or "Button"; BC.Callback = BC.Callback or function() end
                local Button = {}
                local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
                local BF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,33), Parent = ItemParent}), {
                    AddThemeObject(SetProps(MakeElement("Label", BC.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"), Click
                }), "Second")
                AddConnection(Click.MouseEnter, function() TweenService:Create(BF, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(SertaiVNLib.Themes.Default.Second.R*255+3, SertaiVNLib.Themes.Default.Second.G*255+3, SertaiVNLib.Themes.Default.Second.B*255+3)}):Play() end)
                AddConnection(Click.MouseLeave, function() TweenService:Create(BF, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = SertaiVNLib.Themes.Default.Second}):Play() end)
                AddConnection(Click.MouseButton1Up, function() spawn(BC.Callback) end)
                function Button:Set(t) BF.Content.Text = t end
                return Button
            end

            function ElementFunction:AddToggle(TC)
                TC = TC or {}; TC.Name = TC.Name or "Toggle"; TC.Default = TC.Default or false
                TC.Callback = TC.Callback or function() end; TC.Color = TC.Color or SertaiVNLib.Themes.Default.Accent
                TC.Flag = TC.Flag or nil; TC.Save = TC.Save or false
                local Toggle = {Value = TC.Default, Save = TC.Save}
                local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
                local TB = SetChildren(SetProps(MakeElement("RoundFrame", TC.Color, 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-24,0.5,0), AnchorPoint = Vector2.new(0.5,0.5)}), {
                    SetProps(MakeElement("Stroke"), {Color = TC.Color, Name = "Stroke", Transparency = 0.5}),
                    SetProps(MakeElement("Label", "✓", 16), {Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), TextColor3 = Color3.fromRGB(255,255,255), Name = "Ico", TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold})
                })
                local TF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
                    AddThemeObject(SetProps(MakeElement("Label", TC.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold}), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"), TB, Click
                }), "Second")
                function Toggle:Set(v)
                    Toggle.Value = v
                    TweenService:Create(TB, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = v and TC.Color or SertaiVNLib.Themes.Default.Divider}):Play()
                    TweenService:Create(TB.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Color = v and TC.Color or SertaiVNLib.Themes.Default.Stroke}):Play()
                    TweenService:Create(TB.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {TextTransparency = v and 0 or 1}):Play()
                    TC.Callback(v)
                end
                Toggle:Set(Toggle.Value)
                AddConnection(Click.MouseButton1Up, function() SaveCfg(game.GameId); Toggle:Set(not Toggle.Value) end)
                if TC.Flag then SertaiVNLib.Flags[TC.Flag] = Toggle end
                return Toggle
            end

            function ElementFunction:AddSlider(SC)
                SC = SC or {}; SC.Name = SC.Name or "Slider"; SC.Min = SC.Min or 0; SC.Max = SC.Max or 100
                SC.Increment = SC.Increment or 1; SC.Default = SC.Default or 50; SC.Callback = SC.Callback or function() end
                SC.ValueName = SC.ValueName or ""; SC.Color = SC.Color or SertaiVNLib.Themes.Default.Accent
                SC.Flag = SC.Flag or nil; SC.Save = SC.Save or false
                local Slider = {Value = SC.Default, Save = SC.Save}
                local Dragging = false
                local SD = SetChildren(SetProps(MakeElement("RoundFrame", SC.Color, 0, 5), {Size = UDim2.new(0,0,1,0), BackgroundTransparency = 0.3, ClipsDescendants = true}), {
                    AddThemeObject(SetProps(MakeElement("Label", "v", 13), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,6), Font = Enum.Font.GothamBold, Name = "Value"}), "Text")
                })
                local SB = SetChildren(SetProps(MakeElement("RoundFrame", SC.Color, 0, 5), {Size = UDim2.new(1,-24,0,26), Position = UDim2.new(0,12,0,30), BackgroundTransparency = 0.9}), {
                    SetProps(MakeElement("Stroke"), {Color = SC.Color}),
                    AddThemeObject(SetProps(MakeElement("Label", "v", 13), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,6), Font = Enum.Font.GothamBold, Name = "Value", TextTransparency = 0.8}), "Text"),
                    SD
                })
                AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(1,0,0,65), Parent = ItemParent}), {
                    AddThemeObject(SetProps(MakeElement("Label", SC.Name, 15), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,10), Font = Enum.Font.GothamBold}), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"), SB
                }), "Second")
                SB.InputBegan:Connect(function(I) if I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch then Dragging = true end end)
                SB.InputEnded:Connect(function(I) if I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch then Dragging = false end end)
                UserInputService.InputChanged:Connect(function(I)
                    if Dragging and (I.UserInputType == Enum.UserInputType.MouseMovement or I.UserInputType == Enum.UserInputType.Touch) then
                        local s = math.clamp((I.Position.X - SB.AbsolutePosition.X) / SB.AbsoluteSize.X, 0, 1)
                        Slider:Set(SC.Min + ((SC.Max - SC.Min) * s)); SaveCfg(game.GameId)
                    end
                end)
                function Slider:Set(v)
                    self.Value = math.clamp(Round(v, SC.Increment), SC.Min, SC.Max)
                    TweenService:Create(SD, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size = UDim2.fromScale((self.Value - SC.Min) / (SC.Max - SC.Min), 1)}):Play()
                    SB.Value.Text = tostring(self.Value) .. " " .. SC.ValueName
                    SD.Value.Text = tostring(self.Value) .. " " .. SC.ValueName
                    SC.Callback(self.Value)
                end
                Slider:Set(Slider.Value)
                if SC.Flag then SertaiVNLib.Flags[SC.Flag] = Slider end
                return Slider
            end

            -- Dropdown: Max 3 visible, scrollable
            function ElementFunction:AddDropdown(DC)
                DC = DC or {}; DC.Name = DC.Name or "Dropdown"; DC.Options = DC.Options or {}
                DC.Default = DC.Default or ""; DC.Callback = DC.Callback or function() end
                DC.Flag = DC.Flag or nil; DC.Save = DC.Save or false
                local Dropdown = {Value = DC.Default, Options = DC.Options, Buttons = {}, Toggled = false, Type = "Dropdown", Save = DC.Save}
                local MaxElements = 3  -- LIMITED TO 3
                if not table.find(Dropdown.Options, Dropdown.Value) then Dropdown.Value = "..." end
                local DL = MakeElement("List")
                local DCon = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40,40,40), 4), {DL}), {Parent = ItemParent, Position = UDim2.new(0,0,0,38), Size = UDim2.new(1,0,1,-38), ClipsDescendants = true}), "Divider")
                local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
                local DF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent, ClipsDescendants = true}), {
                    DCon,
                    SetProps(SetChildren(MakeElement("TFrame"), {
                        AddThemeObject(SetProps(MakeElement("Label", DC.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                        AddThemeObject(SetProps(MakeElement("Label", "▼", 14), {Size = UDim2.new(0,20,0,20), AnchorPoint = Vector2.new(0,0.5), Position = UDim2.new(1,-30,0.5,0), Name = "Ico", TextXAlignment = Enum.TextXAlignment.Center}), "TextDark"),
                        AddThemeObject(SetProps(MakeElement("Label", "Selected", 13), {Size = UDim2.new(1,-40,1,0), Font = Enum.Font.Gotham, Name = "Selected", TextXAlignment = Enum.TextXAlignment.Right}), "TextDark"),
                        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1), Name = "Line", Visible = false}), "Stroke"), Click
                    }), {Size = UDim2.new(1,0,0,38), ClipsDescendants = true, Name = "F"}),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"), MakeElement("Corner")
                }), "Second")
                AddConnection(DL:GetPropertyChangedSignal("AbsoluteContentSize"), function() DCon.CanvasSize = UDim2.new(0,0,0, DL.AbsoluteContentSize.Y) end)
                local function AddOpts(Opts)
                    for _, O in pairs(Opts) do
                        local OB = AddThemeObject(SetProps(SetChildren(MakeElement("Button", Color3.fromRGB(40,40,40)), {
                            MakeElement("Corner", 0, 6),
                            AddThemeObject(SetProps(MakeElement("Label", O, 13, 0.4), {Position = UDim2.new(0,8,0,0), Size = UDim2.new(1,-8,1,0), Name = "Title"}), "Text")
                        }), {Parent = DCon, Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1, ClipsDescendants = true}), "Divider")
                        AddConnection(OB.MouseButton1Click, function() Dropdown:Set(O); SaveCfg(game.GameId) end)
                        Dropdown.Buttons[O] = OB
                    end
                end
                function Dropdown:Refresh(Opts, Del)
                    if Del then for _, v in pairs(Dropdown.Buttons) do v:Destroy() end; table.clear(Dropdown.Options); table.clear(Dropdown.Buttons) end
                    Dropdown.Options = Opts; AddOpts(Dropdown.Options)
                end
                function Dropdown:Set(v)
                    if not table.find(Dropdown.Options, v) then
                        Dropdown.Value = "..."; DF.F.Selected.Text = Dropdown.Value
                        for _, b in pairs(Dropdown.Buttons) do
                            TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
                            TweenService:Create(b.Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {TextTransparency = 0.4}):Play()
                        end
                        return
                    end
                    Dropdown.Value = v; DF.F.Selected.Text = Dropdown.Value
                    for _, b in pairs(Dropdown.Buttons) do
                        TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
                        TweenService:Create(b.Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {TextTransparency = 0.4}):Play()
                    end
                    TweenService:Create(Dropdown.Buttons[v], TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
                    TweenService:Create(Dropdown.Buttons[v].Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
                    return DC.Callback(Dropdown.Value)
                end
                AddConnection(Click.MouseButton1Click, function()
                    Dropdown.Toggled = not Dropdown.Toggled
                    DF.F.Line.Visible = Dropdown.Toggled
                    TweenService:Create(DF.F.Ico, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Rotation = Dropdown.Toggled and 180 or 0}):Play()
                    TweenService:Create(DF, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size = Dropdown.Toggled and UDim2.new(1,0,0,38 + math.min(#Dropdown.Options, MaxElements)*28) or UDim2.new(1,0,0,38)}):Play()
                end)
                Dropdown:Refresh(Dropdown.Options, false); Dropdown:Set(Dropdown.Value)
                if DC.Flag then SertaiVNLib.Flags[DC.Flag] = Dropdown end
                return Dropdown
            end

            function ElementFunction:AddBind(BC)
                BC = BC or {}; BC.Name = BC.Name or "Bind"; BC.Default = BC.Default or Enum.KeyCode.Unknown
                BC.Hold = BC.Hold or false; BC.Callback = BC.Callback or function() end
                BC.Flag = BC.Flag or nil; BC.Save = BC.Save or false
                local Bind = {Value, Binding = false, Type = "Bind", Save = BC.Save}
                local Holding = false
                local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
                local BB = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-12,0.5,0), AnchorPoint = Vector2.new(1,0.5)}), {
                    AddThemeObject(MakeElement("Stroke"), "Stroke"),
                    AddThemeObject(SetProps(MakeElement("Label", BC.Name, 14), {Size = UDim2.new(1,0,1,0), Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center, Name = "Value"}), "Text")
                }), "Main")
                local BF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
                    AddThemeObject(SetProps(MakeElement("Label", BC.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold}), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"), BB, Click
                }), "Second")
                AddConnection(BB.Value:GetPropertyChangedSignal("Text"), function()
                    TweenService:Create(BB, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(0, BB.Value.TextBounds.X + 16, 0, 24)}):Play()
                end)
                AddConnection(Click.InputEnded, function(I)
                    if (I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch) and not Bind.Binding then
                        Bind.Binding = true; BB.Value.Text = ""
                    end
                end)
                AddConnection(UserInputService.InputBegan, function(I)
                    if UserInputService:GetFocusedTextBox() then return end
                    if (I.KeyCode.Name == Bind.Value or I.UserInputType.Name == Bind.Value) and not Bind.Binding then
                        if BC.Hold then Holding = true; BC.Callback(Holding) else BC.Callback() end
                    elseif Bind.Binding then
                        local K
                        pcall(function() if not CheckKey(BlacklistedKeys, I.KeyCode) then K = I.KeyCode end end)
                        pcall(function() if CheckKey(WhitelistedMouse, I.UserInputType) and not K then K = I.UserInputType end end)
                        K = K or Bind.Value; Bind:Set(K); SaveCfg(game.GameId)
                    end
                end)
                AddConnection(UserInputService.InputEnded, function(I)
                    if (I.KeyCode.Name == Bind.Value or I.UserInputType.Name == Bind.Value) and BC.Hold and Holding then
                        Holding = false; BC.Callback(Holding)
                    end
                end)
                function Bind:Set(K) Bind.Binding = false; Bind.Value = K or Bind.Value; Bind.Value = Bind.Value.Name or Bind.Value; BB.Value.Text = Bind.Value end
                Bind:Set(BC.Default)
                if BC.Flag then SertaiVNLib.Flags[BC.Flag] = Bind end
                return Bind
            end

            function ElementFunction:AddTextbox(TC)
                TC = TC or {}; TC.Name = TC.Name or "Textbox"; TC.Default = TC.Default or ""
                TC.TextDisappear = TC.TextDisappear or false; TC.Callback = TC.Callback or function() end
                local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
                local TA = AddThemeObject(Create("TextBox", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255,255,255), PlaceholderColor3 = Color3.fromRGB(210,210,210), PlaceholderText = "Input", Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Center, TextSize = 14, ClearTextOnFocus = false}), "Text")
                local TCon = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-12,0.5,0), AnchorPoint = Vector2.new(1,0.5)}), {AddThemeObject(MakeElement("Stroke"), "Stroke"), TA}), "Main")
                local TF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
                    AddThemeObject(SetProps(MakeElement("Label", TC.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold}), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"), TCon, Click
                }), "Second")
                AddConnection(TA:GetPropertyChangedSignal("Text"), function()
                    TweenService:Create(TCon, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Size = UDim2.new(0, TA.TextBounds.X + 16, 0, 24)}):Play()
                end)
                AddConnection(TA.FocusLost, function() TC.Callback(TA.Text); if TC.TextDisappear then TA.Text = "" end end)
                TA.Text = TC.Default
                AddConnection(Click.MouseButton1Up, function() TA:CaptureFocus() end)
            end

            function ElementFunction:AddColorpicker(CC)
                CC = CC or {}; CC.Name = CC.Name or "Colorpicker"; CC.Default = CC.Default or Color3.fromRGB(255,255,255)
                CC.Callback = CC.Callback or function() end; CC.Flag = CC.Flag or nil; CC.Save = CC.Save or false
                local CH, CS, CV = 1, 1, 1
                local Colorpicker = {Value = CC.Default, Toggled = false, Type = "Colorpicker", Save = CC.Save}
                local CSel = Create("ImageLabel", {Size = UDim2.new(0,18,0,18), Position = UDim2.new(select(3, Color3.toHSV(Colorpicker.Value))), ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, Image = "http://www.roblox.com/asset/?id=4805639000"})
                local HSel = Create("ImageLabel", {Size = UDim2.new(0,18,0,18), Position = UDim2.new(0.5,0,1 - select(1, Color3.toHSV(Colorpicker.Value))), ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, Image = "http://www.roblox.com/asset/?id=4805639000"})
                local Color = Create("ImageLabel", {Size = UDim2.new(1,-25,1,0), Visible = false, Image = "rbxassetid://4155801252"}, {Create("UICorner", {CornerRadius = UDim.new(0,5)}), CSel})
                local Hue = Create("Frame", {Size = UDim2.new(0,20,1,0), Position = UDim2.new(1,-20,0,0), Visible = false}, {
                    Create("UIGradient", {Rotation = 270, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,4)), ColorSequenceKeypoint.new(0.2, Color3.fromRGB(234,255,0)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(21,255,0)), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)), ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,17,255)), ColorSequenceKeypoint.new(0.9, Color3.fromRGB(255,0,251)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,4))}}),
                    Create("UICorner", {CornerRadius = UDim.new(0,5)}), HSel
                })
                local CCon = Create("Frame", {Position = UDim2.new(0,0,0,32), Size = UDim2.new(1,0,1,-32), BackgroundTransparency = 1, ClipsDescendants = true}, {
                    Hue, Color, Create("UIPadding", {PaddingLeft = UDim.new(0,35), PaddingRight = UDim.new(0,35), PaddingBottom = UDim.new(0,10), PaddingTop = UDim.new(0,17)})
                })
                local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
                local CB = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-12,0.5,0), AnchorPoint = Vector2.new(1,0.5)}), {AddThemeObject(MakeElement("Stroke"), "Stroke")}), "Main")
                local CF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
                    SetProps(SetChildren(MakeElement("TFrame"), {
                        AddThemeObject(SetProps(MakeElement("Label", CC.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold}), "Text"),
                        CB, Click,
                        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1), Name = "Line", Visible = false}), "Stroke")
                    }), {Size = UDim2.new(1,0,0,38), ClipsDescendants = true, Name = "F"}),
                    CCon, AddThemeObject(MakeElement("Stroke"), "Stroke")
                }), "Second")
                AddConnection(Click.MouseButton1Click, function()
                    Colorpicker.Toggled = not Colorpicker.Toggled
                    TweenService:Create(CF, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size = Colorpicker.Toggled and UDim2.new(1,0,0,148) or UDim2.new(1,0,0,38)}):Play()
                    Color.Visible = Colorpicker.Toggled; Hue.Visible = Colorpicker.Toggled; CF.F.Line.Visible = Colorpicker.Toggled
                end)
                local function Upd()
                    CB.BackgroundColor3 = Color3.fromHSV(CH, CS, CV); Color.BackgroundColor3 = Color3.fromHSV(CH, 1, 1)
                    Colorpicker:Set(CB.BackgroundColor3); CC.Callback(CB.BackgroundColor3); SaveCfg(game.GameId)
                end
                local ColorInput, HueInput
                AddConnection(Color.InputBegan, function(I)
                    if I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch then
                        if ColorInput then ColorInput:Disconnect() end
                        ColorInput = AddConnection(RunService.RenderStepped, function()
                            local cx = math.clamp(Mouse.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X
                            local cy = math.clamp(Mouse.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y
                            CSel.Position = UDim2.new(cx,0,cy,0); CS = cx; CV = 1 - cy; Upd()
                        end)
                    end
                end)
                AddConnection(Color.InputEnded, function(I) if (I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch) and ColorInput then ColorInput:Disconnect() end end)
                AddConnection(Hue.InputBegan, function(I)
                    if I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch then
                        if HueInput then HueInput:Disconnect() end
                        HueInput = AddConnection(RunService.RenderStepped, function()
                            local hy = math.clamp(Mouse.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y
                            HSel.Position = UDim2.new(0.5,0,hy,0); CH = 1 - hy; Upd()
                        end)
                    end
                end)
                AddConnection(Hue.InputEnded, function(I) if (I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch) and HueInput then HueInput:Disconnect() end end)
                function Colorpicker:Set(v) Colorpicker.Value = v; CB.BackgroundColor3 = v; CC.Callback(v) end
                Colorpicker:Set(Colorpicker.Value)
                if CC.Flag then SertaiVNLib.Flags[CC.Flag] = Colorpicker end
                return Colorpicker
            end

            return ElementFunction
        end

        local ElementFunction = {}
        for i, v in next, GetElements(Container) do ElementFunction[i] = v end
        return ElementFunction
    end
    return TabFunction
end

function SertaiVNLib:Destroy() SertaiVN:Destroy() end

return SertaiVNLib
