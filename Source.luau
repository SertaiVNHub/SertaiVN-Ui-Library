-- SertaiVN UI Library v2.2 (Based on Orion - Discontinued)
-- Thanks to Orion team! Reworked by SertaiVN
-- Removed: PremiumOnly, Sections, emoji icons (now rbxassetid)
-- Added: Settings panel, search tabs, socials paragraph, drag toggle, dropdown scroll (max 3)

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local SertaiVNLib = {
    Elements = {}, ThemeObjects = {}, Connections = {}, Flags = {},
    Themes = {Default = {
        Main = Color3.fromRGB(20, 20, 26),
        Second = Color3.fromRGB(28, 28, 36),
        Stroke = Color3.fromRGB(55, 55, 70),
        Divider = Color3.fromRGB(55, 55, 70),
        Text = Color3.fromRGB(245, 245, 250),
        TextDark = Color3.fromRGB(160, 160, 175),
        Accent = Color3.fromRGB(130, 110, 230)
    }},
    SelectedTheme = "Default", Folder = nil, SaveCfg = false
}

local SertaiVN = Instance.new("ScreenGui")
SertaiVN.Name = "SertaiVN"
if syn then syn.protect_gui(SertaiVN); SertaiVN.Parent = game.CoreGui
else SertaiVN.Parent = gethui and gethui() or game.CoreGui end

if gethui then
    for _, I in ipairs(gethui():GetChildren()) do if I.Name == "SertaiVN" and I ~= SertaiVN then I:Destroy() end end
else
    for _, I in ipairs(game.CoreGui:GetChildren()) do if I.Name == "SertaiVN" and I ~= SertaiVN then I:Destroy() end end
end

function SertaiVNLib:IsRunning()
    if gethui then return SertaiVN.Parent == gethui() else return SertaiVN.Parent == game:GetService("CoreGui") end
end

local function AddConnection(S, F)
    if not SertaiVNLib:IsRunning() then return end
    local C = S:Connect(F); table.insert(SertaiVNLib.Connections, C); return C
end

task.spawn(function()
    while SertaiVNLib:IsRunning() do wait() end
    for _, C in next, SertaiVNLib.Connections do C:Disconnect() end
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
                TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset+Delta.X, FramePos.Y.Scale, FramePos.Y.Offset+Delta.Y)}):Play()
            end
        end)
    end)
end

local function Create(Name, Props, Children)
    local O = Instance.new(Name)
    for i, v in next, Props or {} do O[i] = v end
    for i, v in next, Children or {} do v.Parent = O end
    return O
end

local function CreateElement(N, F) SertaiVNLib.Elements[N] = function(...) return F(...) end end
local function MakeElement(N, ...) return SertaiVNLib.Elements[N](...) end
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

local function LoadCfg(Cfg)
    local D = HttpService:JSONDecode(Cfg)
    for a, b in pairs(D) do
        if SertaiVNLib.Flags[a] then
            spawn(function()
                if SertaiVNLib.Flags[a].Type == "Colorpicker" then SertaiVNLib.Flags[a]:Set(UnpackColor(b))
                else SertaiVNLib.Flags[a]:Set(b) end
            end)
        end
    end
end

local function SaveCfg(N)
    local D = {}
    for i, v in pairs(SertaiVNLib.Flags) do
        if v.Save then
            if v.Type == "Colorpicker" then D[i] = PackColor(v.Value) else D[i] = v.Value end
        end
    end
    pcall(function() writefile(SertaiVNLib.Folder .. "/" .. N .. ".txt", HttpService:JSONEncode(D)) end)
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right, Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Backspace, Enum.KeyCode.Escape}
local function CheckKey(T, K) for _, v in next, T do if v == K then return true end end end

CreateElement("Corner", function(S, O) return Create("UICorner", {CornerRadius = UDim.new(S or 0, O or 10)}) end)
CreateElement("Stroke", function(C, T) return Create("UIStroke", {Color = C or Color3.fromRGB(255,255,255), Thickness = T or 1}) end)
CreateElement("List", function(S, O) return Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(S or 0, O or 0)}) end)
CreateElement("Padding", function(B, L, R, T) return Create("UIPadding", {PaddingBottom = UDim.new(0,B or 4), PaddingLeft = UDim.new(0,L or 4), PaddingRight = UDim.new(0,R or 4), PaddingTop = UDim.new(0,T or 4)}) end)
CreateElement("TFrame", function() return Create("Frame", {BackgroundTransparency = 1}) end)
CreateElement("Frame", function(C) return Create("Frame", {BackgroundColor3 = C or Color3.fromRGB(255,255,255), BorderSizePixel = 0}) end)
CreateElement("RoundFrame", function(C, S, O) return Create("Frame", {BackgroundColor3 = C or Color3.fromRGB(255,255,255), BorderSizePixel = 0}, {Create("UICorner", {CornerRadius = UDim.new(S, O)})}) end)
CreateElement("Button", function() return Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0}) end)
CreateElement("ScrollFrame", function(C, W) return Create("ScrollingFrame", {BackgroundTransparency = 1, MidImage = "rbxassetid://7445543667", BottomImage = "rbxassetid://7445543667", TopImage = "rbxassetid://7445543667", ScrollBarImageColor3 = C, BorderSizePixel = 0, ScrollBarThickness = W, CanvasSize = UDim2.new(0,0,0,0)}) end)
CreateElement("Image", function(ID) return Create("ImageLabel", {Image = "rbxassetid://" .. tostring(ID), BackgroundTransparency = 1}) end)
CreateElement("ImageButton", function(ID) return Create("ImageButton", {Image = "rbxassetid://" .. tostring(ID), BackgroundTransparency = 1}) end)
CreateElement("Label", function(T, S, Tr) return Create("TextLabel", {Text = T or "", TextColor3 = Color3.fromRGB(240,240,240), TextTransparency = Tr or 0, TextSize = S or 15, Font = Enum.Font.Gotham, RichText = true, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left}) end)

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
    SetProps(MakeElement("List"), {HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0,5)})
}), {Position = UDim2.new(1,-25,1,-25), Size = UDim2.new(0,300,1,-25), AnchorPoint = Vector2.new(1,1), Parent = SertaiVN})

function SertaiVNLib:MakeNotification(NC)
    spawn(function()
        NC.Name = NC.Name or "Notification"
        NC.Content = NC.Content or "Test"
        NC.Image = NC.Image or 4384403532
        NC.Time = NC.Time or 15

        local NP = SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Parent = NotificationHolder})
        local NF = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25,25,25), 0, 10), {
            Parent = NP, Size = UDim2.new(1,0,0,0), Position = UDim2.new(1,-55,0,0), AutomaticSize = Enum.AutomaticSize.Y
        }), {
            MakeElement("Stroke", Color3.fromRGB(93,93,93), 1.2),
            MakeElement("Padding", 12, 12, 12, 12),
            SetProps(MakeElement("Image", NC.Image), {Size = UDim2.new(0,20,0,20), ImageColor3 = Color3.fromRGB(240,240,240), Name = "Icon"}),
            SetProps(MakeElement("Label", NC.Name, 15), {Size = UDim2.new(1,-30,0,20), Position = UDim2.new(0,30,0,0), Font = Enum.Font.GothamBold, Name = "Title"}),
            SetProps(MakeElement("Label", NC.Content, 14), {Size = UDim2.new(1,0,0,0), Position = UDim2.new(0,0,0,25), Font = Enum.Font.GothamSemibold, Name = "Content", AutomaticSize = Enum.AutomaticSize.Y, TextColor3 = Color3.fromRGB(200,200,200), TextWrapped = true})
        })

        TweenService:Create(NF, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0,0,0,0)}):Play()
        wait(NC.Time - 0.88)
        TweenService:Create(NF.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        TweenService:Create(NF, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
        wait(0.3)
        TweenService:Create(NF.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
        TweenService:Create(NF.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
        TweenService:Create(NF.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
        wait(0.05)
        NF:TweenPosition(UDim2.new(1,20,0,0), 'In', 'Quint', 0.8, true)
        wait(1.35); NF:Destroy()
    end)
end

function SertaiVNLib:Init()
    if SertaiVNLib.SaveCfg then
        pcall(function()
            if isfile(SertaiVNLib.Folder .. "/" .. game.GameId .. ".txt") then
                LoadCfg(readfile(SertaiVNLib.Folder .. "/" .. game.GameId .. ".txt"))
                SertaiVNLib:MakeNotification({Name = "Configuration", Content = "Auto-loaded for game " .. game.GameId, Time = 5})
            end
        end)
    end
end

function SertaiVNLib:MakeWindow(WC)
    local FirstTab = true
    local Minimized = false
    local UIHidden = false

    WC = WC or {}
    WC.Name = WC.Name or "SertaiVN Library"
    WC.ConfigFolder = WC.ConfigFolder or WC.Name
    WC.SaveConfig = WC.SaveConfig or false
    WC.IntroIcon = WC.IntroIcon or 9405923708
    WC.Icon = WC.Icon or 9405923708
    WC.ToggleIcon = WC.ToggleIcon or 9405923708
    WC.CloseIcon = WC.CloseIcon or 99967063680607
    WC.SettingsIcon = WC.SettingsIcon or 2484550861
    WC.HomeIcon = WC.HomeIcon or 9405923708
    if WC.IntroEnabled == nil then WC.IntroEnabled = true end
    WC.IntroText = WC.IntroText or "SertaiVN Library"
    WC.CloseCallback = WC.CloseCallback or function() end
    SertaiVNLib.Folder = WC.ConfigFolder
    SertaiVNLib.SaveCfg = WC.SaveConfig

    if WC.SaveConfig then if not isfolder(WC.ConfigFolder) then makefolder(WC.ConfigFolder) end end

    -- Search bar (top of tabs)
    local SearchBar = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {Size = UDim2.new(1,-10,0,28), Position = UDim2.new(0,5,0,5)}), {
        AddThemeObject(MakeElement("Stroke"), "Stroke"),
        AddThemeObject(SetProps(Create("TextBox", {
            Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,8,0,0),
            BackgroundTransparency = 1, PlaceholderText = "🔍 Search tabs...",
            Text = "", Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = Color3.fromRGB(240,240,240), PlaceholderColor3 = Color3.fromRGB(160,160,175),
            TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Name = "Input"
        }), {}), "Text")
    }), "Second")

    local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 4), {Size = UDim2.new(1,0,1,-90), Position = UDim2.new(0,0,0,40)}), {
        MakeElement("List"), MakeElement("Padding", 4, 0, 0, 4)
    }), "Divider")

    AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        TabHolder.CanvasSize = UDim2.new(0,0,0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
    end)

    -- Search filter
    AddConnection(SearchBar.Input:GetPropertyChangedSignal("Text"), function()
        local query = string.lower(SearchBar.Input.Text)
        for _, tab in pairs(TabHolder:GetChildren()) do
            if tab:IsA("TextButton") then
                if query == "" or string.find(string.lower(tab.Title.Text), query, 1, true) then
                    tab.Visible = true
                else
                    tab.Visible = false
                end
            end
        end
    end)

    local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(0.5,0,1,0), Position = UDim2.new(0.5,0,0,0), BackgroundTransparency = 1}), {
        AddThemeObject(SetProps(MakeElement("Image", WC.CloseIcon), {Position = UDim2.new(0,9,0,6), Size = UDim2.new(0,18,0,18)}), "Text")
    })
    local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(0.5,0,1,0), BackgroundTransparency = 1}), {
        AddThemeObject(SetProps(MakeElement("Label", "—", 18), {Size = UDim2.new(1,0,1,0), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold, Name = "Ico"}), "Text")
    })

    local DragPoint = SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,50)})

    -- Settings panel button (in sidebar bottom)
    local SettingsBtn = AddThemeObject(SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(1,-10,0,32), Position = UDim2.new(0,5,1,-44), Name = "SettingsBtn"}), {
        SetProps(MakeElement("Image", WC.SettingsIcon), {Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,10,0.5,-9)}),
        AddThemeObject(SetProps(MakeElement("Label", "Settings", 13), {Size = UDim2.new(1,-36,1,0), Position = UDim2.new(0,36,0,0), Font = Enum.Font.GothamSemibold}), "Text"),
        AddThemeObject(MakeElement("Stroke"), "Stroke"),
        MakeElement("Corner", 0, 6)
    }), "Second")

    local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 10), {Size = UDim2.new(0,160,1,-50), Position = UDim2.new(0,0,0,50)}), {
        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,10)}), "Second"),
        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0,10,1,0), Position = UDim2.new(1,-10,0,0)}), "Second"),
        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0,1,1,0), Position = UDim2.new(1,-1,0,0)}), "Stroke"),
        SearchBar, TabHolder, SettingsBtn
    }), "Second")

    local WindowName = AddThemeObject(SetProps(MakeElement("Label", WC.Name, 14), {Size = UDim2.new(1,-30,2,0), Position = UDim2.new(0,50,0,-24), Font = Enum.Font.GothamBlack, TextSize = 18}), "Text")
    local WindowIcon = SetProps(MakeElement("Image", WC.Icon), {Size = UDim2.new(0,22,0,22), Position = UDim2.new(0,18,0,14)})
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

    -- Mobile toggle button (draggable, image icon)
    local MobileToggle = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 1, 0), {
        Parent = SertaiVN, Position = UDim2.new(0,15,0,80), Size = UDim2.new(0,50,0,50), Visible = false
    }), {
        AddThemeObject(MakeElement("Stroke", nil, 2), "Stroke"),
        SetProps(MakeElement("Image", WC.ToggleIcon), {Size = UDim2.new(0,30,0,30), Position = UDim2.new(0.5,-15,0.5,-15)}),
        SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0), Name = "Click"})
    }), "Second")

    AddDraggingFunctionality(DragPoint, MainWindow)
    AddDraggingFunctionality(MobileToggle, MobileToggle)  -- Mobile toggle is draggable!

    AddConnection(CloseBtn.MouseButton1Up, function()
        MainWindow.Visible = false; UIHidden = true; MobileToggle.Visible = true
        SertaiVNLib:MakeNotification({Name = "Interface Hidden", Content = "Tap RightShift or floating button to reopen", Time = 5})
        WC.CloseCallback()
    end)

    AddConnection(MobileToggle.Click.MouseButton1Click, function()
        MainWindow.Visible = true; UIHidden = false; MobileToggle.Visible = false
    end)

    AddConnection(UserInputService.InputBegan, function(I)
        if I.KeyCode == Enum.KeyCode.RightShift and UIHidden then
            MainWindow.Visible = true; UIHidden = false; MobileToggle.Visible = false
        end
    end)

    AddConnection(MinimizeBtn.MouseButton1Up, function()
        if Minimized then
            TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0,615,0,344)}):Play()
            MinimizeBtn.Ico.Text = "—"; wait(0.02)
            MainWindow.ClipsDescendants = false; WindowStuff.Visible = true; WindowTopBarLine.Visible = true
        else
            MainWindow.ClipsDescendants = true; WindowTopBarLine.Visible = false
            MinimizeBtn.Ico.Text = "+"
            TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, WindowName.TextBounds.X+170, 0, 50)}):Play()
            wait(0.1); WindowStuff.Visible = false
        end
        Minimized = not Minimized
    end)

    -- NEW Loading screen with logo image
    local function LoadSequence()
        MainWindow.Visible = false
        local LB = SetProps(MakeElement("RoundFrame", Color3.fromRGB(15,15,20), 0, 0), {Parent = SertaiVN, Size = UDim2.new(1,0,1,0), ZIndex = 100})
        Create("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(15,15,20), Color3.fromRGB(28,22,45)), Rotation = 135, Parent = LB})

        local LogoBox = SetProps(MakeElement("RoundFrame", Color3.fromRGB(28,28,38), 0, 20), {
            Parent = LB, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,-20), Size = UDim2.new(0,0,0,0), ZIndex = 101
        })
        Create("UIStroke", {Color = SertaiVNLib.Themes.Default.Accent, Thickness = 2, Parent = LogoBox})

        local LogoImg = SetProps(MakeElement("Image", WC.IntroIcon), {
            Parent = LogoBox, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,60,0,60), ImageTransparency = 1, ZIndex = 102
        })

        local TitleText = SetProps(MakeElement("Label", "", 22), {
            Parent = LB, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,70), Size = UDim2.new(1,0,0,30), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255,255,255), ZIndex = 101
        })

        local SubText = SetProps(MakeElement("Label", "Initializing...", 12), {
            Parent = LB, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,100), Size = UDim2.new(1,0,0,16), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(160,160,180), TextTransparency = 1, ZIndex = 101
        })

        TweenService:Create(LogoBox, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0,100,0,100)}):Play()
        wait(0.3)
        TweenService:Create(LogoImg, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
        wait(0.4)
        for i = 1, #WC.IntroText do TitleText.Text = string.sub(WC.IntroText, 1, i); wait(0.04) end
        TweenService:Create(SubText, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        wait(1.2)
        TweenService:Create(LogoBox, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0,0,0,0)}):Play()
        TweenService:Create(TitleText, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        TweenService:Create(SubText, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        TweenService:Create(LB, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
        wait(0.5)
        MainWindow.Visible = true
        LB:Destroy()
    end

    if WC.IntroEnabled then LoadSequence() end

    -- ============ ELEMENT BUILDERS ============
    local function GetElements(ItemParent)
        local EF = {}

        function EF:AddLabel(Text)
            local LF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,30), BackgroundTransparency = 0.7, Parent = ItemParent}), {
                AddThemeObject(SetProps(MakeElement("Label", Text, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                AddThemeObject(MakeElement("Stroke"), "Stroke")
            }), "Second")
            return {Set = function(_, T) LF.Content.Text = T end}
        end

        function EF:AddParagraph(Text, Content)
            Text = Text or "Text"; Content = Content or "Content"
            local PF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,30), BackgroundTransparency = 0.7, Parent = ItemParent}), {
                AddThemeObject(SetProps(MakeElement("Label", Text, 15), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,10), Font = Enum.Font.GothamBold, Name = "Title"}), "Text"),
                AddThemeObject(SetProps(MakeElement("Label", "", 13), {Size = UDim2.new(1,-24,0,0), Position = UDim2.new(0,12,0,26), Font = Enum.Font.GothamSemibold, Name = "Content", TextWrapped = true}), "TextDark"),
                AddThemeObject(MakeElement("Stroke"), "Stroke")
            }), "Second")
            AddConnection(PF.Content:GetPropertyChangedSignal("Text"), function()
                PF.Content.Size = UDim2.new(1,-24,0, PF.Content.TextBounds.Y)
                PF.Size = UDim2.new(1,0,0, PF.Content.TextBounds.Y + 35)
            end)
            PF.Content.Text = Content
            return {Set = function(_, T) PF.Content.Text = T end}
        end

        -- Socials Paragraph (image + copy link)
        function EF:AddSocialsParagraph(Cfg)
            Cfg = Cfg or {}; Cfg.Title = Cfg.Title or "Socials"; Cfg.Content = Cfg.Content or ""
            Cfg.Image = Cfg.Image or 9405923708; Cfg.LinkName = Cfg.LinkName or "Copy"; Cfg.URL = Cfg.URL or ""
            local SF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,70), BackgroundTransparency = 0.7, Parent = ItemParent}), {
                SetProps(MakeElement("Image", Cfg.Image), {Size = UDim2.new(0,46,0,46), Position = UDim2.new(0,10,0,12)}),
                AddThemeObject(SetProps(MakeElement("Label", Cfg.Title, 14), {Size = UDim2.new(1,-180,0,16), Position = UDim2.new(0,64,0,10), Font = Enum.Font.GothamBold}), "Text"),
                AddThemeObject(SetProps(MakeElement("Label", Cfg.Content, 12), {Size = UDim2.new(1,-180,0,30), Position = UDim2.new(0,64,0,28), Font = Enum.Font.Gotham, TextWrapped = true}), "TextDark"),
                AddThemeObject(MakeElement("Stroke"), "Stroke")
            }), "Second")
            local CopyBtn = SetChildren(SetProps(MakeElement("RoundFrame", SertaiVNLib.Themes.Default.Accent, 0, 6), {Size = UDim2.new(0,100,0,28), Position = UDim2.new(1,-110,0.5,-14), Parent = SF}), {
                SetProps(MakeElement("Label", "🔗 " .. Cfg.LinkName, 12), {Size = UDim2.new(1,0,1,0), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamSemibold, TextColor3 = Color3.fromRGB(255,255,255)}),
                SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0), Name = "Click"})
            })
            AddConnection(CopyBtn.Click.MouseButton1Click, function()
                pcall(function() if setclipboard then setclipboard(Cfg.URL); SertaiVNLib:MakeNotification({Name = Cfg.Title .. " Copied", Content = Cfg.URL, Time = 4}) end end)
            end)
            return SF
        end

        function EF:AddButton(BC)
            BC = BC or {}; BC.Name = BC.Name or "Button"; BC.Callback = BC.Callback or function() end; BC.Icon = BC.Icon or 3944703587
            local Btn = {}
            local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
            local BF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,33), Parent = ItemParent}), {
                AddThemeObject(SetProps(MakeElement("Label", BC.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                AddThemeObject(SetProps(MakeElement("Image", BC.Icon), {Size = UDim2.new(0,20,0,20), Position = UDim2.new(1,-30,0,7)}), "TextDark"),
                AddThemeObject(MakeElement("Stroke"), "Stroke"), Click
            }), "Second")
            AddConnection(Click.MouseEnter, function() TweenService:Create(BF, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(SertaiVNLib.Themes.Default.Second.R*255+3, SertaiVNLib.Themes.Default.Second.G*255+3, SertaiVNLib.Themes.Default.Second.B*255+3)}):Play() end)
            AddConnection(Click.MouseLeave, function() TweenService:Create(BF, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = SertaiVNLib.Themes.Default.Second}):Play() end)
            AddConnection(Click.MouseButton1Up, function() spawn(function() BC.Callback() end) end)
            function Btn:Set(T) BF.Content.Text = T end
            return Btn
        end

        function EF:AddToggle(TC)
            TC = TC or {}; TC.Name = TC.Name or "Toggle"; TC.Default = TC.Default or false; TC.Callback = TC.Callback or function() end
            TC.Color = TC.Color or SertaiVNLib.Themes.Default.Accent; TC.Flag = TC.Flag or nil; TC.Save = TC.Save or false
            local Tog = {Value = TC.Default, Save = TC.Save}
            local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
            local Box = SetChildren(SetProps(MakeElement("RoundFrame", TC.Color, 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-24,0.5,0), AnchorPoint = Vector2.new(0.5,0.5)}), {
                SetProps(MakeElement("Stroke"), {Color = TC.Color, Name = "Stroke", Transparency = 0.5}),
                SetProps(MakeElement("Image", 3944680095), {Size = UDim2.new(0,20,0,20), AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), ImageColor3 = Color3.fromRGB(255,255,255), Name = "Ico"})
            })
            local TF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
                AddThemeObject(SetProps(MakeElement("Label", TC.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                AddThemeObject(MakeElement("Stroke"), "Stroke"), Box, Click
            }), "Second")
            function Tog:Set(V)
                Tog.Value = V
                TweenService:Create(Box, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = V and TC.Color or SertaiVNLib.Themes.Default.Divider}):Play()
                TweenService:Create(Box.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Color = V and TC.Color or SertaiVNLib.Themes.Default.Stroke}):Play()
                TweenService:Create(Box.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = V and 0 or 1, Size = V and UDim2.new(0,20,0,20) or UDim2.new(0,8,0,8)}):Play()
                TC.Callback(V)
            end
            Tog:Set(Tog.Value)
            AddConnection(Click.MouseButton1Up, function() SaveCfg(game.GameId); Tog:Set(not Tog.Value) end)
            if TC.Flag then SertaiVNLib.Flags[TC.Flag] = Tog end
            return Tog
        end

        function EF:AddSlider(SC)
            SC = SC or {}; SC.Name = SC.Name or "Slider"; SC.Min = SC.Min or 0; SC.Max = SC.Max or 100
            SC.Increment = SC.Increment or 1; SC.Default = SC.Default or 50; SC.Callback = SC.Callback or function() end
            SC.ValueName = SC.ValueName or ""; SC.Color = SC.Color or SertaiVNLib.Themes.Default.Accent
            SC.Flag = SC.Flag or nil; SC.Save = SC.Save or false
            local Sl = {Value = SC.Default, Save = SC.Save}; local Dragging = false
            local SDr = SetChildren(SetProps(MakeElement("RoundFrame", SC.Color, 0, 5), {Size = UDim2.new(0,0,1,0), BackgroundTransparency = 0.3, ClipsDescendants = true}), {
                AddThemeObject(SetProps(MakeElement("Label", "value", 13), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,6), Font = Enum.Font.GothamBold, Name = "Value"}), "Text")
            })
            local SB = SetChildren(SetProps(MakeElement("RoundFrame", SC.Color, 0, 5), {Size = UDim2.new(1,-24,0,26), Position = UDim2.new(0,12,0,30), BackgroundTransparency = 0.9}), {
                SetProps(MakeElement("Stroke"), {Color = SC.Color}),
                AddThemeObject(SetProps(MakeElement("Label", "value", 13), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,6), Font = Enum.Font.GothamBold, Name = "Value", TextTransparency = 0.8}), "Text"),
                SDr
            })
            AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(1,0,0,65), Parent = ItemParent}), {
                AddThemeObject(SetProps(MakeElement("Label", SC.Name, 15), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,10), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                AddThemeObject(MakeElement("Stroke"), "Stroke"), SB
            }), "Second")
            SB.InputBegan:Connect(function(I) if I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch then Dragging = true end end)
            SB.InputEnded:Connect(function(I) if I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch then Dragging = false end end)
            UserInputService.InputChanged:Connect(function(I)
                if Dragging and (I.UserInputType == Enum.UserInputType.MouseMovement or I.UserInputType == Enum.UserInputType.Touch) then
                    local SS = math.clamp((I.Position.X - SB.AbsolutePosition.X) / SB.AbsoluteSize.X, 0, 1)
                    Sl:Set(SC.Min + ((SC.Max - SC.Min) * SS)); SaveCfg(game.GameId)
                end
            end)
            function Sl:Set(V)
                self.Value = math.clamp(Round(V, SC.Increment), SC.Min, SC.Max)
                TweenService:Create(SDr, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size = UDim2.fromScale((self.Value - SC.Min)/(SC.Max - SC.Min), 1)}):Play()
                SB.Value.Text = tostring(self.Value) .. " " .. SC.ValueName
                SDr.Value.Text = tostring(self.Value) .. " " .. SC.ValueName
                SC.Callback(self.Value)
            end
            Sl:Set(Sl.Value)
            if SC.Flag then SertaiVNLib.Flags[SC.Flag] = Sl end
            return Sl
        end

        -- Dropdown: SCROLLABLE, MAX 3 visible
        function EF:AddDropdown(DC)
            DC = DC or {}; DC.Name = DC.Name or "Dropdown"; DC.Options = DC.Options or {}; DC.Default = DC.Default or ""
            DC.Callback = DC.Callback or function() end; DC.Flag = DC.Flag or nil; DC.Save = DC.Save or false
            local Dd = {Value = DC.Default, Options = DC.Options, Buttons = {}, Toggled = false, Type = "Dropdown", Save = DC.Save}
            local MaxElements = 3  -- LIMIT TO 3
            if not table.find(Dd.Options, Dd.Value) then Dd.Value = "..." end

            local DL = MakeElement("List")
            local DCt = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40,40,40), 4), {DL}), {
                Position = UDim2.new(0,0,0,38), Size = UDim2.new(1,0,1,-38), ClipsDescendants = true
            }), "Divider")
            local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})

            local DF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent, ClipsDescendants = true}), {
                DCt,
                SetProps(SetChildren(MakeElement("TFrame"), {
                    AddThemeObject(SetProps(MakeElement("Label", DC.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                    AddThemeObject(SetProps(MakeElement("Image", 7072706796), {Size = UDim2.new(0,20,0,20), AnchorPoint = Vector2.new(0,0.5), Position = UDim2.new(1,-30,0.5,0), Name = "Ico"}), "TextDark"),
                    AddThemeObject(SetProps(MakeElement("Label", "Selected", 13), {Size = UDim2.new(1,-40,1,0), Font = Enum.Font.Gotham, Name = "Selected", TextXAlignment = Enum.TextXAlignment.Right}), "TextDark"),
                    AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1), Name = "Line", Visible = false}), "Stroke"),
                    Click
                }), {Size = UDim2.new(1,0,0,38), ClipsDescendants = true, Name = "F"}),
                AddThemeObject(MakeElement("Stroke"), "Stroke"), MakeElement("Corner")
            }), "Second")

            AddConnection(DL:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                DCt.CanvasSize = UDim2.new(0, 0, 0, DL.AbsoluteContentSize.Y)
            end)

            local function AddOptions(Opts)
                for _, Opt in pairs(Opts) do
                    local Btn = AddThemeObject(SetProps(SetChildren(MakeElement("Button", Color3.fromRGB(40,40,40)), {
                        MakeElement("Corner", 0, 6),
                        AddThemeObject(SetProps(MakeElement("Label", Opt, 13, 0.4), {Position = UDim2.new(0,8,0,0), Size = UDim2.new(1,-8,1,0), Name = "Title"}), "Text")
                    }), {Parent = DCt, Size = UDim2.new(1,-6,0,28), BackgroundTransparency = 1, ClipsDescendants = true}), "Divider")
                    AddConnection(Btn.MouseButton1Click, function() Dd:Set(Opt); SaveCfg(game.GameId) end)
                    Dd.Buttons[Opt] = Btn
                end
            end

            function Dd:Refresh(Opts, Delete)
                if Delete then
                    for _, v in pairs(Dd.Buttons) do v:Destroy() end
                    table.clear(Dd.Options); table.clear(Dd.Buttons)
                end
                Dd.Options = Opts; AddOptions(Dd.Options)
            end

            function Dd:Set(V)
                if not table.find(Dd.Options, V) then
                    Dd.Value = "..."; DF.F.Selected.Text = Dd.Value
                    for _, v in pairs(Dd.Buttons) do
                        TweenService:Create(v, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
                        TweenService:Create(v.Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {TextTransparency = 0.4}):Play()
                    end; return
                end
                Dd.Value = V; DF.F.Selected.Text = Dd.Value
                for _, v in pairs(Dd.Buttons) do
                    TweenService:Create(v, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
                    TweenService:Create(v.Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {TextTransparency = 0.4}):Play()
                end
                TweenService:Create(Dd.Buttons[V], TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
                TweenService:Create(Dd.Buttons[V].Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
                return DC.Callback(Dd.Value)
            end

            AddConnection(Click.MouseButton1Click, function()
                Dd.Toggled = not Dd.Toggled
                DF.F.Line.Visible = Dd.Toggled
                TweenService:Create(DF.F.Ico, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Rotation = Dd.Toggled and 180 or 0}):Play()
                -- ALWAYS limit to MaxElements (3); scroll for more
                local height = math.min(#Dd.Options, MaxElements) * 30
                TweenService:Create(DF, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size = Dd.Toggled and UDim2.new(1,0,0, 38+height) or UDim2.new(1,0,0,38)}):Play()
            end)
            Dd:Refresh(Dd.Options, false); Dd:Set(Dd.Value)
            if DC.Flag then SertaiVNLib.Flags[DC.Flag] = Dd end
            return Dd
        end

        function EF:AddBind(BC)
            BC.Name = BC.Name or "Bind"; BC.Default = BC.Default or Enum.KeyCode.Unknown
            BC.Hold = BC.Hold or false; BC.Callback = BC.Callback or function() end
            BC.Flag = BC.Flag or nil; BC.Save = BC.Save or false
            local Bn = {Value, Binding = false, Type = "Bind", Save = BC.Save}; local Holding = false
            local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
            local Box = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-12,0.5,0), AnchorPoint = Vector2.new(1,0.5)}), {
                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                AddThemeObject(SetProps(MakeElement("Label", BC.Name, 14), {Size = UDim2.new(1,0,1,0), Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center, Name = "Value"}), "Text")
            }), "Main")
            local BF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
                AddThemeObject(SetProps(MakeElement("Label", BC.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                AddThemeObject(MakeElement("Stroke"), "Stroke"), Box, Click
            }), "Second")
            AddConnection(Box.Value:GetPropertyChangedSignal("Text"), function()
                TweenService:Create(Box, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(0, Box.Value.TextBounds.X+16, 0, 24)}):Play()
            end)
            AddConnection(Click.InputEnded, function(I)
                if I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch then
                    if Bn.Binding then return end; Bn.Binding = true; Box.Value.Text = ""
                end
            end)
            AddConnection(UserInputService.InputBegan, function(I)
                if UserInputService:GetFocusedTextBox() then return end
                if (I.KeyCode.Name == Bn.Value or I.UserInputType.Name == Bn.Value) and not Bn.Binding then
                    if BC.Hold then Holding = true; BC.Callback(Holding) else BC.Callback() end
                elseif Bn.Binding then
                    local Key
                    pcall(function() if not CheckKey(BlacklistedKeys, I.KeyCode) then Key = I.KeyCode end end)
                    pcall(function() if CheckKey(WhitelistedMouse, I.UserInputType) and not Key then Key = I.UserInputType end end)
                    Key = Key or Bn.Value; Bn:Set(Key); SaveCfg(game.GameId)
                end
            end)
            AddConnection(UserInputService.InputEnded, function(I)
                if I.KeyCode.Name == Bn.Value or I.UserInputType.Name == Bn.Value then
                    if BC.Hold and Holding then Holding = false; BC.Callback(Holding) end
                end
            end)
            function Bn:Set(K) Bn.Binding = false; Bn.Value = K or Bn.Value; Bn.Value = Bn.Value.Name or Bn.Value; Box.Value.Text = Bn.Value end
            Bn:Set(BC.Default)
            if BC.Flag then SertaiVNLib.Flags[BC.Flag] = Bn end
            return Bn
        end

        function EF:AddTextbox(TC)
            TC = TC or {}; TC.Name = TC.Name or "Textbox"; TC.Default = TC.Default or ""
            TC.TextDisappear = TC.TextDisappear or false; TC.Callback = TC.Callback or function() end
            local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
            local TA = AddThemeObject(Create("TextBox", {
                Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255,255,255),
                PlaceholderColor3 = Color3.fromRGB(210,210,210), PlaceholderText = "Input",
                Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Center,
                TextSize = 14, ClearTextOnFocus = false
            }), "Text")
            local TCt = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-12,0.5,0), AnchorPoint = Vector2.new(1,0.5)}), {AddThemeObject(MakeElement("Stroke"), "Stroke"), TA}), "Main")
            local TF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
                AddThemeObject(SetProps(MakeElement("Label", TC.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                AddThemeObject(MakeElement("Stroke"), "Stroke"), TCt, Click
            }), "Second")
            AddConnection(TA:GetPropertyChangedSignal("Text"), function()
                TweenService:Create(TCt, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Size = UDim2.new(0, TA.TextBounds.X+16, 0, 24)}):Play()
            end)
            AddConnection(TA.FocusLost, function() TC.Callback(TA.Text); if TC.TextDisappear then TA.Text = "" end end)
            TA.Text = TC.Default
            AddConnection(Click.MouseButton1Up, function() TA:CaptureFocus() end)
        end

        function EF:AddColorpicker(CC)
            CC = CC or {}; CC.Name = CC.Name or "Colorpicker"; CC.Default = CC.Default or Color3.fromRGB(255,255,255)
            CC.Callback = CC.Callback or function() end; CC.Flag = CC.Flag or nil; CC.Save = CC.Save or false
            local ColorH, ColorS, ColorV = 1, 1, 1
            local Cp = {Value = CC.Default, Toggled = false, Type = "Colorpicker", Save = CC.Save}
            local CS = Create("ImageLabel", {Size = UDim2.new(0,18,0,18), Position = UDim2.new(select(3, Color3.toHSV(Cp.Value))), ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, Image = "rbxassetid://4805639000"})
            local HS = Create("ImageLabel", {Size = UDim2.new(0,18,0,18), Position = UDim2.new(0.5,0,1-select(1, Color3.toHSV(Cp.Value))), ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, Image = "rbxassetid://4805639000"})
            local Color = Create("ImageLabel", {Size = UDim2.new(1,-25,1,0), Visible = false, Image = "rbxassetid://4155801252"}, {Create("UICorner", {CornerRadius = UDim.new(0,5)}), CS})
            local Hue = Create("Frame", {Size = UDim2.new(0,20,1,0), Position = UDim2.new(1,-20,0,0), Visible = false}, {
                Create("UIGradient", {Rotation = 270, Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,4)),ColorSequenceKeypoint.new(0.2,Color3.fromRGB(234,255,0)),ColorSequenceKeypoint.new(0.4,Color3.fromRGB(21,255,0)),ColorSequenceKeypoint.new(0.6,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.8,Color3.fromRGB(0,17,255)),ColorSequenceKeypoint.new(0.9,Color3.fromRGB(255,0,251)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,4))}}),
                Create("UICorner", {CornerRadius = UDim.new(0,5)}), HS
            })
            local CCt = Create("Frame", {Position = UDim2.new(0,0,0,32), Size = UDim2.new(1,0,1,-32), BackgroundTransparency = 1, ClipsDescendants = true}, {Hue, Color, Create("UIPadding", {PaddingLeft = UDim.new(0,35), PaddingRight = UDim.new(0,35), PaddingBottom = UDim.new(0,10), PaddingTop = UDim.new(0,17)})})
            local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
            local CB = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-12,0.5,0), AnchorPoint = Vector2.new(1,0.5)}), {AddThemeObject(MakeElement("Stroke"), "Stroke")}), "Main")
            local CF = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
                SetProps(SetChildren(MakeElement("TFrame"), {
                    AddThemeObject(SetProps(MakeElement("Label", CC.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                    CB, Click,
                    AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1), Name = "Line", Visible = false}), "Stroke")
                }), {Size = UDim2.new(1,0,0,38), ClipsDescendants = true, Name = "F"}),
                CCt, AddThemeObject(MakeElement("Stroke"), "Stroke")
            }), "Second")
            AddConnection(Click.MouseButton1Click, function()
                Cp.Toggled = not Cp.Toggled
                TweenService:Create(CF, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size = Cp.Toggled and UDim2.new(1,0,0,148) or UDim2.new(1,0,0,38)}):Play()
                Color.Visible = Cp.Toggled; Hue.Visible = Cp.Toggled; CF.F.Line.Visible = Cp.Toggled
            end)
            local function UCP() CB.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV); Color.BackgroundColor3 = Color3.fromHSV(ColorH,1,1); Cp:Set(CB.BackgroundColor3); CC.Callback(CB.BackgroundColor3); SaveCfg(game.GameId) end
            AddConnection(Color.InputBegan, function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    if ColorInput then ColorInput:Disconnect() end
                    ColorInput = AddConnection(RunService.RenderStepped, function()
                        local CX = math.clamp(Mouse.X-Color.AbsolutePosition.X,0,Color.AbsoluteSize.X)/Color.AbsoluteSize.X
                        local CY = math.clamp(Mouse.Y-Color.AbsolutePosition.Y,0,Color.AbsoluteSize.Y)/Color.AbsoluteSize.Y
                        CS.Position = UDim2.new(CX,0,CY,0); ColorS = CX; ColorV = 1-CY; UCP()
                    end)
                end
            end)
            AddConnection(Color.InputEnded, function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and ColorInput then ColorInput:Disconnect() end end)
            AddConnection(Hue.InputBegan, function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    if HueInput then HueInput:Disconnect() end
                    HueInput = AddConnection(RunService.RenderStepped, function()
                        local HY = math.clamp(Mouse.Y-Hue.AbsolutePosition.Y,0,Hue.AbsoluteSize.Y)/Hue.AbsoluteSize.Y
                        HS.Position = UDim2.new(0.5,0,HY,0); ColorH = 1-HY; UCP()
                    end)
                end
            end)
            AddConnection(Hue.InputEnded, function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and HueInput then HueInput:Disconnect() end end)
            function Cp:Set(V) Cp.Value = V; CB.BackgroundColor3 = V; CC.Callback(V) end
            Cp:Set(Cp.Value)
            if CC.Flag then SertaiVNLib.Flags[CC.Flag] = Cp end
            return Cp
        end

        return EF
    end

    local TabFunction = {}
    function TabFunction:MakeTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or WC.HomeIcon  -- Default home icon

        local TabFrame = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,0,30), Parent = TabHolder}), {
            SetProps(MakeElement("Image", TabConfig.Icon), {
                AnchorPoint = Vector2.new(0,0.5), Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,10,0.5,0),
                ImageTransparency = 0.4, ImageColor3 = SertaiVNLib.Themes.Default.Text, Name = "Ico"
            }),
            AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {Size = UDim2.new(1,-35,1,0), Position = UDim2.new(0,35,0,0), Font = Enum.Font.GothamSemibold, TextTransparency = 0.4, Name = "Title"}), "Text")
        })

        local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 5), {
            Size = UDim2.new(1,-160,1,-50), Position = UDim2.new(0,160,0,50), Parent = MainWindow, Visible = false, Name = "ItemContainer"
        }), {MakeElement("List", 0, 6), MakeElement("Padding", 15, 10, 10, 15)}), "Divider")

        AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            Container.CanvasSize = UDim2.new(0,0,0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
        end)

        if FirstTab then
            FirstTab = false
            TabFrame.Ico.ImageTransparency = 0
            TabFrame.Title.TextTransparency = 0
            TabFrame.Title.Font = Enum.Font.GothamBlack
            Container.Visible = true
        end

        AddConnection(TabFrame.MouseButton1Click, function()
            for _, T in next, TabHolder:GetChildren() do
                if T:IsA("TextButton") then
                    T.Title.Font = Enum.Font.GothamSemibold
                    TweenService:Create(T.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.4}):Play()
                    TweenService:Create(T.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
                end
            end
            for _, IC in next, MainWindow:GetChildren() do if IC.Name == "ItemContainer" then IC.Visible = false end end
            TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
            TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
            TabFrame.Title.Font = Enum.Font.GothamBlack
            Container.Visible = true
        end)

        local ElementFunction = {}
        for i, v in next, GetElements(Container) do ElementFunction[i] = v end
        return ElementFunction
    end

    -- Settings Panel
    local SettingsContainer = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 5), {
        Size = UDim2.new(1,-160,1,-50), Position = UDim2.new(0,160,0,50), Parent = MainWindow, Visible = false, Name = "SettingsContainer"
    }), {MakeElement("List", 0, 6), MakeElement("Padding", 15, 10, 10, 15)}), "Divider")

    AddConnection(SettingsContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        SettingsContainer.CanvasSize = UDim2.new(0,0,0, SettingsContainer.UIListLayout.AbsoluteContentSize.Y + 30)
    end)

    local SettingsElements = GetElements(SettingsContainer)
    
    -- Profile
    local profileFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {Size = UDim2.new(1,0,0,72), Parent = SettingsContainer}), {
        SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"), {Size = UDim2.new(0,54,0,54), Position = UDim2.new(0,10,0,9)}),
        MakeElement("Corner", 0, 27),
        AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, 15), {Size = UDim2.new(1,-80,0,18), Position = UDim2.new(0,72,0,12), Font = Enum.Font.GothamBold}), "Text"),
        AddThemeObject(SetProps(MakeElement("Label", "@" .. LocalPlayer.Name, 12), {Size = UDim2.new(1,-80,0,14), Position = UDim2.new(0,72,0,32)}), "TextDark"),
        AddThemeObject(SetProps(MakeElement("Label", "ID: " .. LocalPlayer.UserId, 11), {Size = UDim2.new(1,-80,0,12), Position = UDim2.new(0,72,0,48)}), "TextDark"),
        AddThemeObject(MakeElement("Stroke"), "Stroke")
    }), "Second")

    SettingsElements:AddLabel("Device: " .. (UserInputService.TouchEnabled and not UserInputService.MouseEnabled and "Mobile" or (UserInputService.MouseEnabled and "PC" or "Unknown")))
    local fpsLabel = SettingsElements:AddLabel("FPS: 0")
    local pingLabel = SettingsElements:AddLabel("Ping: 0ms")

    local frames, last = 0, tick()
    AddConnection(RunService.RenderStepped, function()
        frames = frames + 1
        if tick() - last >= 1 then
            fpsLabel:Set("FPS: " .. frames); frames = 0; last = tick()
            pcall(function() pingLabel:Set("Ping: " .. math.floor(LocalPlayer:GetNetworkPing()*1000) .. "ms") end)
        end
    end)

    SettingsElements:AddSocialsParagraph({Title = "Discord", Content = "Join SertaiVN HUB community", Image = 4384403532, LinkName = "Copy", URL = "https://discord.gg/sertaivn"})

    AddConnection(SettingsBtn.MouseButton1Click, function()
        for _, T in next, TabHolder:GetChildren() do
            if T:IsA("TextButton") then
                T.Title.Font = Enum.Font.GothamSemibold
                TweenService:Create(T.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.4}):Play()
                TweenService:Create(T.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
            end
        end
        for _, IC in next, MainWindow:GetChildren() do if IC.Name == "ItemContainer" then IC.Visible = false end end
        SettingsContainer.Visible = true
    end)

    -- Hide settings when clicking other tabs
    AddConnection(TabHolder.ChildAdded, function(c)
        if c:IsA("TextButton") then
            AddConnection(c.MouseButton1Click, function() SettingsContainer.Visible = false end)
        end
    end)

    return TabFunction
end

function SertaiVNLib:Destroy() SertaiVN:Destroy() end

return SertaiVNLib
