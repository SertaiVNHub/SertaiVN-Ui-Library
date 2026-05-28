local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local SertaiVNLib = {
    Elements = {},
    ThemeObjects = {},
    Connections = {},
    Flags = {},
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
    SelectedTheme = "Default",
    Folder = nil,
    SaveCfg = false
}

-- ============ ASSET IDs (replace with your own uploaded assets) ============
local Assets = {
    Logo = "rbxassetid://11436111346",          -- Loading screen logo
    NotificationIcon = "rbxassetid://10709751939", -- Notification bell icon
    ToggleIcon = "rbxassetid://10734898355",    -- Mobile toggle button icon
    WindowIcon = "rbxassetid://11436111346",    -- Window title icon
    CloseIcon = "rbxassetid://10747384394",     -- Close X icon
    MinimizeIcon = "rbxassetid://10734896206",  -- Minimize dash icon
    DropdownIcon = "rbxassetid://10709790948",  -- Dropdown arrow
    SearchIcon = "rbxassetid://10747373144",    -- Search magnifier
    DefaultTabIcon = "rbxassetid://10723345516",-- Default tab icon
    Checkmark = "rbxassetid://10747384394"      -- Toggle checkmark
}

local SertaiVN = Instance.new("ScreenGui")
SertaiVN.Name = "SertaiVN"
if syn then
    syn.protect_gui(SertaiVN)
    SertaiVN.Parent = game.CoreGui
else
    SertaiVN.Parent = gethui and gethui() or game.CoreGui
end

if gethui then
    for _, Interface in ipairs(gethui():GetChildren()) do
        if Interface.Name == SertaiVN.Name and Interface ~= SertaiVN then
            Interface:Destroy()
        end
    end
else
    for _, Interface in ipairs(game.CoreGui:GetChildren()) do
        if Interface.Name == SertaiVN.Name and Interface ~= SertaiVN then
            Interface:Destroy()
        end
    end
end

function SertaiVNLib:IsRunning()
    if gethui then
        return SertaiVN.Parent == gethui()
    else
        return SertaiVN.Parent == game:GetService("CoreGui")
    end
end

local function AddConnection(Signal, Function)
    if not SertaiVNLib:IsRunning() then return end
    local SignalConnect = Signal:Connect(Function)
    table.insert(SertaiVNLib.Connections, SignalConnect)
    return SignalConnect
end

task.spawn(function()
    while SertaiVNLib:IsRunning() do wait() end
    for _, Connection in next, SertaiVNLib.Connections do
        Connection:Disconnect()
    end
end)

-- ============ FIXED DRAGGING (separates DragPoint from Target) ============
local function AddDraggingFunctionality(DragPoint, Main)
    pcall(function()
        local Dragging, DragInput, MousePos, FramePos = false
        
        DragPoint.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                MousePos = Input.Position
                FramePos = Main.Position
                Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)
        
        DragPoint.InputChanged:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                DragInput = Input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(Input)
            if Input == DragInput and Dragging then
                local Delta = Input.Position - MousePos
                TweenService:Create(Main, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
                }):Play()
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

local function CreateElement(ElementName, ElementFunction)
    SertaiVNLib.Elements[ElementName] = function(...) return ElementFunction(...) end
end

local function MakeElement(ElementName, ...)
    return SertaiVNLib.Elements[ElementName](...)
end

local function SetProps(Element, Props)
    for Property, Value in pairs(Props) do Element[Property] = Value end
    return Element
end

local function SetChildren(Element, Children)
    for _, Child in pairs(Children) do Child.Parent = Element end
    return Element
end

local function Round(Number, Factor)
    local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
    if Result < 0 then Result = Result + Factor end
    return Result
end

local function ReturnProperty(Object)
    if Object:IsA("Frame") or Object:IsA("TextButton") then return "BackgroundColor3" end
    if Object:IsA("ScrollingFrame") then return "ScrollBarImageColor3" end
    if Object:IsA("UIStroke") then return "Color" end
    if Object:IsA("TextLabel") or Object:IsA("TextBox") then return "TextColor3" end
    if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then return "ImageColor3" end
end

local function AddThemeObject(Object, Type)
    if not SertaiVNLib.ThemeObjects[Type] then SertaiVNLib.ThemeObjects[Type] = {} end
    table.insert(SertaiVNLib.ThemeObjects[Type], Object)
    Object[ReturnProperty(Object)] = SertaiVNLib.Themes[SertaiVNLib.SelectedTheme][Type]
    return Object
end

local function PackColor(Color) return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255} end
local function UnpackColor(Color) return Color3.fromRGB(Color.R, Color.G, Color.B) end

local function LoadCfg(Config)
    local Data = HttpService:JSONDecode(Config)
    for a, b in pairs(Data) do
        if SertaiVNLib.Flags[a] then
            spawn(function()
                if SertaiVNLib.Flags[a].Type == "Colorpicker" then
                    SertaiVNLib.Flags[a]:Set(UnpackColor(b))
                else
                    SertaiVNLib.Flags[a]:Set(b)
                end
            end)
        else
            warn("SertaiVN Library Config Loader - Could not find ", a, b)
        end
    end
end

local function SaveCfg(Name)
    local Data = {}
    for i, v in pairs(SertaiVNLib.Flags) do
        if v.Save then
            if v.Type == "Colorpicker" then Data[i] = PackColor(v.Value)
            else Data[i] = v.Value end
        end
    end
    writefile(SertaiVNLib.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right, Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Backspace, Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
    for _, v in next, Table do if v == Key then return true end end
end

CreateElement("Corner", function(Scale, Offset)
    return Create("UICorner", {CornerRadius = UDim.new(Scale or 0, Offset or 10)})
end)
CreateElement("Stroke", function(Color, Thickness)
    return Create("UIStroke", {Color = Color or Color3.fromRGB(255,255,255), Thickness = Thickness or 1})
end)
CreateElement("List", function(Scale, Offset)
    return Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(Scale or 0, Offset or 0)})
end)
CreateElement("Padding", function(Bottom, Left, Right, Top)
    return Create("UIPadding", {PaddingBottom = UDim.new(0, Bottom or 4), PaddingLeft = UDim.new(0, Left or 4), PaddingRight = UDim.new(0, Right or 4), PaddingTop = UDim.new(0, Top or 4)})
end)
CreateElement("TFrame", function()
    return Create("Frame", {BackgroundTransparency = 1})
end)
CreateElement("Frame", function(Color)
    return Create("Frame", {BackgroundColor3 = Color or Color3.fromRGB(255,255,255), BorderSizePixel = 0})
end)
CreateElement("RoundFrame", function(Color, Scale, Offset)
    return Create("Frame", {BackgroundColor3 = Color or Color3.fromRGB(255,255,255), BorderSizePixel = 0}, {Create("UICorner", {CornerRadius = UDim.new(Scale, Offset)})})
end)
CreateElement("Button", function()
    return Create("TextButton", {Text = "", AutoButtonColor = false, BackgroundTransparency = 1, BorderSizePixel = 0})
end)
CreateElement("ScrollFrame", function(Color, Width)
    return Create("ScrollingFrame", {BackgroundTransparency = 1, MidImage = "rbxassetid://7445543667", BottomImage = "rbxassetid://7445543667", TopImage = "rbxassetid://7445543667", ScrollBarImageColor3 = Color, BorderSizePixel = 0, ScrollBarThickness = Width, CanvasSize = UDim2.new(0,0,0,0)})
end)
CreateElement("Image", function(ImageID)
    return Create("ImageLabel", {Image = ImageID, BackgroundTransparency = 1})
end)
CreateElement("ImageButton", function(ImageID)
    return Create("ImageButton", {Image = ImageID, BackgroundTransparency = 1})
end)
CreateElement("Label", function(Text, TextSize, Transparency)
    return Create("TextLabel", {Text = Text or "", TextColor3 = Color3.fromRGB(240,240,240), TextTransparency = Transparency or 0, TextSize = TextSize or 15, Font = Enum.Font.Gotham, RichText = true, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left})
end)

-- ============ NOTIFICATIONS (with image icon, no emoji) ============
local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
    SetProps(MakeElement("List"), {HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0,5)})
}), {Position = UDim2.new(1,-25,1,-25), Size = UDim2.new(0,300,1,-25), AnchorPoint = Vector2.new(1,1), Parent = SertaiVN})

function SertaiVNLib:MakeNotification(NotificationConfig)
    spawn(function()
        NotificationConfig.Name = NotificationConfig.Name or "Notification"
        NotificationConfig.Content = NotificationConfig.Content or "Test"
        NotificationConfig.Image = NotificationConfig.Image or Assets.NotificationIcon
        NotificationConfig.Time = NotificationConfig.Time or 15

        local NotificationParent = SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, Parent = NotificationHolder})

        local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25,25,25), 0, 10), {
            Parent = NotificationParent, Size = UDim2.new(1,0,0,0), Position = UDim2.new(1,-55,0,0), BackgroundTransparency = 0, AutomaticSize = Enum.AutomaticSize.Y
        }), {
            MakeElement("Stroke", Color3.fromRGB(93,93,93), 1.2),
            MakeElement("Padding", 12, 12, 12, 12),
            SetProps(MakeElement("Image", NotificationConfig.Image), {
                Size = UDim2.new(0,20,0,20), Position = UDim2.new(0,0,0,0), ImageColor3 = SertaiVNLib.Themes.Default.Accent, Name = "Icon"
            }),
            SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
                Size = UDim2.new(1,-30,0,20), Position = UDim2.new(0,30,0,0), Font = Enum.Font.GothamBold, Name = "Title"
            }),
            SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
                Size = UDim2.new(1,0,0,0), Position = UDim2.new(0,0,0,25), Font = Enum.Font.GothamSemibold, Name = "Content", AutomaticSize = Enum.AutomaticSize.Y, TextColor3 = Color3.fromRGB(200,200,200), TextWrapped = true
            })
        })

        TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0,0,0,0)}):Play()

        wait(NotificationConfig.Time - 0.88)
        TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
        wait(0.3)
        TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
        TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
        TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
        wait(0.05)
        NotificationFrame:TweenPosition(UDim2.new(1,20,0,0),'In','Quint',0.8,true)
        wait(1.35)
        NotificationFrame:Destroy()
    end)
end

function SertaiVNLib:Init()
    if SertaiVNLib.SaveCfg then
        pcall(function()
            if isfile(SertaiVNLib.Folder .. "/" .. game.GameId .. ".txt") then
                LoadCfg(readfile(SertaiVNLib.Folder .. "/" .. game.GameId .. ".txt"))
                SertaiVNLib:MakeNotification({Name = "Configuration", Content = "Auto-loaded configuration for the game " .. game.GameId .. ".", Time = 5})
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
    WindowConfig.Icon = WindowConfig.Icon or Assets.WindowIcon
    if WindowConfig.IntroEnabled == nil then WindowConfig.IntroEnabled = true end
    WindowConfig.IntroText = WindowConfig.IntroText or "SertaiVN Library"
    WindowConfig.IntroIcon = WindowConfig.IntroIcon or Assets.Logo
    WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
    SertaiVNLib.Folder = WindowConfig.ConfigFolder
    SertaiVNLib.SaveCfg = WindowConfig.SaveConfig

    if WindowConfig.SaveConfig then
        if not isfolder(WindowConfig.ConfigFolder) then makefolder(WindowConfig.ConfigFolder) end
    end

    -- ============ SEARCH BOX ============
    local SearchBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 6), {
        Size = UDim2.new(1,-12,0,30), Position = UDim2.new(0,6,0,6)
    }), {
        AddThemeObject(MakeElement("Stroke"), "Stroke"),
        SetProps(MakeElement("Image", Assets.SearchIcon), {
            Size = UDim2.new(0,14,0,14), Position = UDim2.new(0,8,0.5,-7), ImageColor3 = SertaiVNLib.Themes.Default.TextDark, Name = "Icon"
        }),
        AddThemeObject(Create("TextBox", {
            Size = UDim2.new(1,-30,1,0), Position = UDim2.new(0,28,0,0), BackgroundTransparency = 1,
            PlaceholderText = "Search tabs...", PlaceholderColor3 = SertaiVNLib.Themes.Default.TextDark,
            Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            Text = "", ClearTextOnFocus = false, Name = "Input"
        }), "Text")
    }), "Main")

    local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255,255,255), 4), {
        Size = UDim2.new(1,0,1,-92), Position = UDim2.new(0,0,0,42)
    }), {
        MakeElement("List"), MakeElement("Padding", 8, 0, 0, 8)
    }), "Divider")

    AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        TabHolder.CanvasSize = UDim2.new(0,0,0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
    end)

    -- Search filter
    AddConnection(SearchBox.Input:GetPropertyChangedSignal("Text"), function()
        local query = string.lower(SearchBox.Input.Text)
        for _, Tab in next, TabHolder:GetChildren() do
            if Tab:IsA("TextButton") then
                if query == "" then
                    Tab.Visible = true
                else
                    Tab.Visible = string.find(string.lower(Tab.Title.Text), query) ~= nil
                end
            end
        end
    end)

    -- ============ CLOSE & MINIMIZE BUTTONS (image based) ============
    local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(0.5,0,1,0), Position = UDim2.new(0.5,0,0,0), BackgroundTransparency = 1}), {
        AddThemeObject(SetProps(MakeElement("Image", Assets.CloseIcon), {
            AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,14,0,14)
        }), "Text")
    })

    local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {Size = UDim2.new(0.5,0,1,0), BackgroundTransparency = 1}), {
        AddThemeObject(SetProps(MakeElement("Image", Assets.MinimizeIcon), {
            AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,14,0,14), Name = "Ico"
        }), "Text")
    })

    local DragPoint = SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,-100,0,50)})

    local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 10), {
        Size = UDim2.new(0,150,1,-50), Position = UDim2.new(0,0,0,50)
    }), {
        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,10), Position = UDim2.new(0,0,0,0)}), "Second"),
        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0,10,1,0), Position = UDim2.new(1,-10,0,0)}), "Second"),
        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(0,1,1,0), Position = UDim2.new(1,-1,0,0)}), "Stroke"),
        SearchBox,
        TabHolder,
        SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,50), Position = UDim2.new(0,0,1,-50)}), {
            AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,1)}), "Stroke"),
            AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {AnchorPoint = Vector2.new(0,0.5), Size = UDim2.new(0,32,0,32), Position = UDim2.new(0,10,0.5,0)}), {
                SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"), {Size = UDim2.new(1,0,1,0)}),
                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {Size = UDim2.new(1,0,1,0)}), "Second"),
                MakeElement("Corner", 1)
            }), "Divider"),
            SetChildren(SetProps(MakeElement("TFrame"), {AnchorPoint = Vector2.new(0,0.5), Size = UDim2.new(0,32,0,32), Position = UDim2.new(0,10,0.5,0)}), {
                AddThemeObject(MakeElement("Stroke"), "Stroke"), MakeElement("Corner", 1)
            }),
            AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, 13), {
                Size = UDim2.new(1,-60,0,13), Position = UDim2.new(0,50,0,12), Font = Enum.Font.GothamBold, ClipsDescendants = true
            }), "Text"),
            AddThemeObject(SetProps(MakeElement("Label", "@" .. LocalPlayer.Name, 12), {
                Size = UDim2.new(1,-60,0,12), Position = UDim2.new(0,50,1,-25)
            }), "TextDark")
        })
    }), "Second")

    -- ============ WINDOW TITLE with ICON ============
    local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
        Size = UDim2.new(0,20,0,20), Position = UDim2.new(0,15,0,15), ImageColor3 = SertaiVNLib.Themes.Default.Accent
    })

    local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
        Size = UDim2.new(1,-50,0,20), Position = UDim2.new(0,42,0,15), Font = Enum.Font.GothamBlack, TextSize = 16
    }), "Text")

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

    -- ============ MOBILE TOGGLE (image icon, draggable, no flicker) ============
    local MobileToggleFrame = SetProps(MakeElement("TFrame"), {
        Parent = SertaiVN, Position = UDim2.new(0,15,0,80), Size = UDim2.new(0,50,0,50), Visible = false
    })

    local MobileToggle = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", SertaiVNLib.Themes.Default.Second, 1, 0), {
        Parent = MobileToggleFrame, Size = UDim2.new(1,0,1,0)
    }), {
        AddThemeObject(MakeElement("Stroke", SertaiVNLib.Themes.Default.Accent, 2), "Accent"),
        SetProps(MakeElement("Image", Assets.ToggleIcon), {
            AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,26,0,26),
            ImageColor3 = SertaiVNLib.Themes.Default.Accent
        })
    }), "Second")

    -- Separate invisible click button on top (only triggers on tap, not drag)
    local ToggleClickButton = SetProps(MakeElement("Button"), {
        Parent = MobileToggleFrame, Size = UDim2.new(1,0,1,0), Name = "ClickArea"
    })

    -- Dragging logic for mobile toggle (won't trigger click if dragged)
    do
        local dragging, dragStart, startPos, didMove = false, nil, nil, false
        ToggleClickButton.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                didMove = false
                dragStart = Input.Position
                startPos = MobileToggleFrame.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(Input)
            if dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                local delta = Input.Position - dragStart
                if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then didMove = true end
                MobileToggleFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                if dragging and not didMove then
                    -- Treat as click
                    MainWindow.Visible = true
                    UIHidden = false
                    MobileToggleFrame.Visible = false
                end
                dragging = false
            end
        end)
    end

    AddDraggingFunctionality(DragPoint, MainWindow)

    AddConnection(CloseBtn.MouseButton1Up, function()
        MainWindow.Visible = false
        UIHidden = true
        MobileToggleFrame.Visible = true
        SertaiVNLib:MakeNotification({Name = "Interface Hidden", Content = "Press RightShift (PC) or tap the floating icon (Mobile) to reopen.", Time = 5})
        WindowConfig.CloseCallback()
    end)

    AddConnection(UserInputService.InputBegan, function(Input)
        if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
            MainWindow.Visible = true
            UIHidden = false
            MobileToggleFrame.Visible = false
        end
    end)

    AddConnection(MinimizeBtn.MouseButton1Up, function()
        if Minimized then
            TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0,615,0,344)}):Play()
            MinimizeBtn.Ico.Image = Assets.MinimizeIcon
            wait(0.02)
            MainWindow.ClipsDescendants = false
            WindowStuff.Visible = true
            WindowTopBarLine.Visible = true
        else
            MainWindow.ClipsDescendants = true
            WindowTopBarLine.Visible = false
            MinimizeBtn.Ico.Image = Assets.MinimizeIcon
            TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 180, 0, 50)}):Play()
            wait(0.1)
            WindowStuff.Visible = false
        end
        Minimized = not Minimized
    end)

    -- ============ NEW LOADING SCREEN (image logo, typewriter text) ============
    local function LoadSequence()
        MainWindow.Visible = false

        local LoadingBg = SetProps(MakeElement("RoundFrame", Color3.fromRGB(15,15,20), 0, 0), {
            Parent = SertaiVN, Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 0, ZIndex = 100
        })
        Create("UIGradient", {Color = ColorSequence.new(Color3.fromRGB(15,15,20), Color3.fromRGB(25,20,40)), Rotation = 135, Parent = LoadingBg})

        local LogoCircle = SetProps(MakeElement("RoundFrame", SertaiVNLib.Themes.Default.Accent, 1, 0), {
            Parent = LoadingBg, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,-30), Size = UDim2.new(0,0,0,0), ZIndex = 101
        })
        Create("UIGradient", {Color = ColorSequence.new(SertaiVNLib.Themes.Default.Accent, Color3.fromRGB(90,70,200)), Rotation = 45, Parent = LogoCircle})

        local LogoImage = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
            Parent = LogoCircle, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), Size = UDim2.new(0,40,0,40),
            ImageColor3 = Color3.fromRGB(255,255,255), ImageTransparency = 1, ZIndex = 102
        })

        local TitleText = SetProps(MakeElement("Label", "", 22), {
            Parent = LoadingBg, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,30), Size = UDim2.new(1,0,0,30), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(255,255,255), ZIndex = 101
        })

        local SubText = SetProps(MakeElement("Label", "Loading...", 12), {
            Parent = LoadingBg, AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,60), Size = UDim2.new(1,0,0,16), TextXAlignment = Enum.TextXAlignment.Center, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(160,160,180), TextTransparency = 1, ZIndex = 101
        })

        TweenService:Create(LogoCircle, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,72,0,72)}):Play()
        wait(0.2)
        TweenService:Create(LogoImage, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
        wait(0.5)

        -- Typewriter effect
        local fullText = WindowConfig.IntroText
        for i = 1, #fullText do
            TitleText.Text = string.sub(fullText, 1, i)
            wait(0.05)
        end

        TweenService:Create(SubText, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        wait(1.5)

        TweenService:Create(LogoCircle, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0,0,0,0)}):Play()
        TweenService:Create(TitleText, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        TweenService:Create(SubText, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        TweenService:Create(LoadingBg, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
        wait(0.5)

        MainWindow.Visible = true
        LoadingBg:Destroy()
    end

    if WindowConfig.IntroEnabled then LoadSequence() end

    local TabFunction = {}
    function TabFunction:MakeTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or Assets.DefaultTabIcon

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
            for _, Tab in next, TabHolder:GetChildren() do
                if Tab:IsA("TextButton") then
                    Tab.Title.Font = Enum.Font.GothamSemibold
                    TweenService:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0.4}):Play()
                    TweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
                end
            end
            for _, ItemContainer in next, MainWindow:GetChildren() do
                if ItemContainer.Name == "ItemContainer" then ItemContainer.Visible = false end
            end
            TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
            TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
            TabFrame.Title.Font = Enum.Font.GothamBlack
            Container.Visible = true
        end)

        local function GetElements(ItemParent)
            local ElementFunction = {}

            function ElementFunction:AddLabel(Text)
                local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,30), BackgroundTransparency = 0.7, Parent = ItemParent}), {
                    AddThemeObject(SetProps(MakeElement("Label", Text, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke")
                }), "Second")
                local LabelFunction = {}
                function LabelFunction:Set(ToChange) LabelFrame.Content.Text = ToChange end
                return LabelFunction
            end

            function ElementFunction:AddParagraph(Text, Content)
                Text = Text or "Text"; Content = Content or "Content"
                local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,30), BackgroundTransparency = 0.7, Parent = ItemParent}), {
                    AddThemeObject(SetProps(MakeElement("Label", Text, 15), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,10), Font = Enum.Font.GothamBold, Name = "Title"}), "Text"),
                    AddThemeObject(SetProps(MakeElement("Label", "", 13), {Size = UDim2.new(1,-24,0,0), Position = UDim2.new(0,12,0,26), Font = Enum.Font.GothamSemibold, Name = "Content", TextWrapped = true}), "TextDark"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke")
                }), "Second")
                AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
                    ParagraphFrame.Content.Size = UDim2.new(1,-24,0, ParagraphFrame.Content.TextBounds.Y)
                    ParagraphFrame.Size = UDim2.new(1,0,0, ParagraphFrame.Content.TextBounds.Y + 35)
                end)
                ParagraphFrame.Content.Text = Content
                local ParagraphFunction = {}
                function ParagraphFunction:Set(ToChange) ParagraphFrame.Content.Text = ToChange end
                return ParagraphFunction
            end

            function ElementFunction:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Name = ButtonConfig.Name or "Button"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end
                local Button = {}
                local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
                local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,33), Parent = ItemParent}), {
                    AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                    AddThemeObject(SetProps(MakeElement("Image", Assets.DropdownIcon), {Size = UDim2.new(0,16,0,16), Position = UDim2.new(1,-26,0.5,-8), Rotation = -90}), "TextDark"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"),
                    Click
                }), "Second")
                AddConnection(Click.MouseEnter, function() TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(SertaiVNLib.Themes[SertaiVNLib.SelectedTheme].Second.R*255+3, SertaiVNLib.Themes[SertaiVNLib.SelectedTheme].Second.G*255+3, SertaiVNLib.Themes[SertaiVNLib.SelectedTheme].Second.B*255+3)}):Play() end)
                AddConnection(Click.MouseLeave, function() TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = SertaiVNLib.Themes[SertaiVNLib.SelectedTheme].Second}):Play() end)
                AddConnection(Click.MouseButton1Up, function() TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(SertaiVNLib.Themes[SertaiVNLib.SelectedTheme].Second.R*255+3, SertaiVNLib.Themes[SertaiVNLib.SelectedTheme].Second.G*255+3, SertaiVNLib.Themes[SertaiVNLib.SelectedTheme].Second.B*255+3)}):Play(); spawn(function() ButtonConfig.Callback() end) end)
                AddConnection(Click.MouseButton1Down, function() TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(SertaiVNLib.Themes[SertaiVNLib.SelectedTheme].Second.R*255+6, SertaiVNLib.Themes[SertaiVNLib.SelectedTheme].Second.G*255+6, SertaiVNLib.Themes[SertaiVNLib.SelectedTheme].Second.B*255+6)}):Play() end)
                function Button:Set(ButtonText) ButtonFrame.Content.Text = ButtonText end
                return Button
            end

            function ElementFunction:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                ToggleConfig.Name = ToggleConfig.Name or "Toggle"
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end
                ToggleConfig.Color = ToggleConfig.Color or SertaiVNLib.Themes.Default.Accent
                ToggleConfig.Flag = ToggleConfig.Flag or nil
                ToggleConfig.Save = ToggleConfig.Save or false
                local Toggle = {Value = ToggleConfig.Default, Save = ToggleConfig.Save}
                local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
                local ToggleBox = SetChildren(SetProps(MakeElement("RoundFrame", ToggleConfig.Color, 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-24,0.5,0), AnchorPoint = Vector2.new(0.5,0.5)}), {
                    SetProps(MakeElement("Stroke"), {Color = ToggleConfig.Color, Name = "Stroke", Transparency = 0.5}),
                    SetProps(MakeElement("Image", Assets.Checkmark), {Size = UDim2.new(0,14,0,14), AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.new(0.5,0,0.5,0), ImageColor3 = Color3.fromRGB(255,255,255), Name = "Ico"})
                })
                local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
                    AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"), ToggleBox, Click
                }), "Second")
                function Toggle:Set(Value)
                    Toggle.Value = Value
                    TweenService:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Toggle.Value and ToggleConfig.Color or SertaiVNLib.Themes.Default.Divider}):Play()
                    TweenService:Create(ToggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Color = Toggle.Value and ToggleConfig.Color or SertaiVNLib.Themes.Default.Stroke}):Play()
                    TweenService:Create(ToggleBox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = Toggle.Value and 0 or 1}):Play()
                    ToggleConfig.Callback(Toggle.Value)
                end
                Toggle:Set(Toggle.Value)
                AddConnection(Click.MouseButton1Up, function() SaveCfg(game.GameId); Toggle:Set(not Toggle.Value) end)
                if ToggleConfig.Flag then SertaiVNLib.Flags[ToggleConfig.Flag] = Toggle end
                return Toggle
            end

            function ElementFunction:AddSlider(SliderConfig)
                SliderConfig = SliderConfig or {}
                SliderConfig.Name = SliderConfig.Name or "Slider"
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100
                SliderConfig.Increment = SliderConfig.Increment or 1
                SliderConfig.Default = SliderConfig.Default or 50
                SliderConfig.Callback = SliderConfig.Callback or function() end
                SliderConfig.ValueName = SliderConfig.ValueName or ""
                SliderConfig.Color = SliderConfig.Color or SertaiVNLib.Themes.Default.Accent
                SliderConfig.Flag = SliderConfig.Flag or nil
                SliderConfig.Save = SliderConfig.Save or false
                local Slider = {Value = SliderConfig.Default, Save = SliderConfig.Save}
                local Dragging = false

                local SliderDrag = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {Size = UDim2.new(0,0,1,0), BackgroundTransparency = 0.3, ClipsDescendants = true}), {
                    AddThemeObject(SetProps(MakeElement("Label", "value", 13), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,6), Font = Enum.Font.GothamBold, Name = "Value", TextTransparency = 0}), "Text")
                })
                local SliderBar = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {Size = UDim2.new(1,-24,0,26), Position = UDim2.new(0,12,0,30), BackgroundTransparency = 0.9}), {
                    SetProps(MakeElement("Stroke"), {Color = SliderConfig.Color}),
                    AddThemeObject(SetProps(MakeElement("Label", "value", 13), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,6), Font = Enum.Font.GothamBold, Name = "Value", TextTransparency = 0.8}), "Text"),
                    SliderDrag
                })
                local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(1,0,0,65), Parent = ItemParent}), {
                    AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,12,0,10), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"), SliderBar
                }), "Second")

                SliderBar.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                    end
                end)
                SliderBar.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                        local SizeScale = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                        Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale))
                        SaveCfg(game.GameId)
                    end
                end)

                function Slider:Set(Value)
                    self.Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
                    TweenService:Create(SliderDrag, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size = UDim2.fromScale((self.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1)}):Play()
                    SliderBar.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
                    SliderDrag.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
                    SliderConfig.Callback(self.Value)
                end
                Slider:Set(Slider.Value)
                if SliderConfig.Flag then SertaiVNLib.Flags[SliderConfig.Flag] = Slider end
                return Slider
            end

            -- ============ DROPDOWN (max 3 visible, scrollable, fixed length) ============
            function ElementFunction:AddDropdown(DropdownConfig)
                DropdownConfig = DropdownConfig or {}
                DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
                DropdownConfig.Options = DropdownConfig.Options or {}
                DropdownConfig.Default = DropdownConfig.Default or ""
                DropdownConfig.Callback = DropdownConfig.Callback or function() end
                DropdownConfig.Flag = DropdownConfig.Flag or nil
                DropdownConfig.Save = DropdownConfig.Save or false
                local Dropdown = {Value = DropdownConfig.Default, Options = DropdownConfig.Options, Buttons = {}, Toggled = false, Type = "Dropdown", Save = DropdownConfig.Save}
                local MaxElements = 3 -- FIXED max length = 3
                local ItemHeight = 28
                if not table.find(Dropdown.Options, Dropdown.Value) then Dropdown.Value = "..." end

                local DropdownList = MakeElement("List", 0, 2)
                local DropdownContainer = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", SertaiVNLib.Themes.Default.Accent, 4), {
                    DropdownList, MakeElement("Padding", 4, 4, 4, 4)
                }), {Parent = nil, Position = UDim2.new(0,0,0,38), Size = UDim2.new(1,0,1,-38), ClipsDescendants = true, ScrollingDirection = Enum.ScrollingDirection.Y}), "Divider")
                local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})

                local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent, ClipsDescendants = true}), {
                    DropdownContainer,
                    SetProps(SetChildren(MakeElement("TFrame"), {
                        AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                        AddThemeObject(SetProps(MakeElement("Image", Assets.DropdownIcon), {Size = UDim2.new(0,16,0,16), AnchorPoint = Vector2.new(0,0.5), Position = UDim2.new(1,-28,0.5,0), Name = "Ico"}), "TextDark"),
                        AddThemeObject(SetProps(MakeElement("Label", "Selected", 13), {Size = UDim2.new(1,-50,1,0), Font = Enum.Font.Gotham, Name = "Selected", TextXAlignment = Enum.TextXAlignment.Right, Position = UDim2.new(0,0,0,0)}), "TextDark"),
                        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1), Name = "Line", Visible = false}), "Stroke"),
                        Click
                    }), {Size = UDim2.new(1,0,0,38), ClipsDescendants = true, Name = "F"}),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"), MakeElement("Corner")
                }), "Second")

                AddConnection(DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                    DropdownContainer.CanvasSize = UDim2.new(0,0,0, DropdownList.AbsoluteContentSize.Y + 8)
                end)

                local function AddOptions(Options)
                    for _, Option in pairs(Options) do
                        local OptionBtn = AddThemeObject(SetProps(SetChildren(MakeElement("Button", Color3.fromRGB(40,40,40)), {
                            MakeElement("Corner", 0, 6),
                            AddThemeObject(SetProps(MakeElement("Label", Option, 13, 0.4), {Position = UDim2.new(0,8,0,0), Size = UDim2.new(1,-8,1,0), Name = "Title"}), "Text")
                        }), {Parent = DropdownContainer, Size = UDim2.new(1,-4,0,26), BackgroundTransparency = 1, ClipsDescendants = true}), "Divider")
                        AddConnection(OptionBtn.MouseButton1Click, function() Dropdown:Set(Option); SaveCfg(game.GameId) end)
                        Dropdown.Buttons[Option] = OptionBtn
                    end
                end

                function Dropdown:Refresh(Options, Delete)
                    if Delete then
                        for _, v in pairs(Dropdown.Buttons) do v:Destroy() end
                        table.clear(Dropdown.Options); table.clear(Dropdown.Buttons)
                    end
                    Dropdown.Options = Options
                    AddOptions(Dropdown.Options)
                end

                function Dropdown:Set(Value)
                    if not table.find(Dropdown.Options, Value) then
                        Dropdown.Value = "..."; DropdownFrame.F.Selected.Text = Dropdown.Value
                        for _, v in pairs(Dropdown.Buttons) do
                            TweenService:Create(v, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
                            TweenService:Create(v.Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {TextTransparency = 0.4}):Play()
                        end
                        return
                    end
                    Dropdown.Value = Value
                    DropdownFrame.F.Selected.Text = Dropdown.Value
                    for _, v in pairs(Dropdown.Buttons) do
                        TweenService:Create(v, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
                        TweenService:Create(v.Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {TextTransparency = 0.4}):Play()
                    end
                    TweenService:Create(Dropdown.Buttons[Value], TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
                    TweenService:Create(Dropdown.Buttons[Value].Title, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
                    return DropdownConfig.Callback(Dropdown.Value)
                end

                AddConnection(Click.MouseButton1Click, function()
                    Dropdown.Toggled = not Dropdown.Toggled
                    DropdownFrame.F.Line.Visible = Dropdown.Toggled
                    TweenService:Create(DropdownFrame.F.Ico, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Rotation = Dropdown.Toggled and 180 or 0}):Play()
                    -- FIXED: Always cap at MaxElements (3) so dropdown never grows huge
                    local visibleCount = math.min(#Dropdown.Options, MaxElements)
                    local expandedHeight = 38 + (visibleCount * (ItemHeight + 2)) + 8
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = Dropdown.Toggled and UDim2.new(1,0,0,expandedHeight) or UDim2.new(1,0,0,38)}):Play()
                end)

                Dropdown:Refresh(Dropdown.Options, false); Dropdown:Set(Dropdown.Value)
                if DropdownConfig.Flag then SertaiVNLib.Flags[DropdownConfig.Flag] = Dropdown end
                return Dropdown
            end

            function ElementFunction:AddBind(BindConfig)
                BindConfig.Name = BindConfig.Name or "Bind"
                BindConfig.Default = BindConfig.Default or Enum.KeyCode.Unknown
                BindConfig.Hold = BindConfig.Hold or false
                BindConfig.Callback = BindConfig.Callback or function() end
                BindConfig.Flag = BindConfig.Flag or nil
                BindConfig.Save = BindConfig.Save or false
                local Bind = {Value, Binding = false, Type = "Bind", Save = BindConfig.Save}
                local Holding = false
                local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
                local BindBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-12,0.5,0), AnchorPoint = Vector2.new(1,0.5)}), {
                    AddThemeObject(MakeElement("Stroke"), "Stroke"),
                    AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 14), {Size = UDim2.new(1,0,1,0), Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Center, Name = "Value"}), "Text")
                }), "Main")
                local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
                    AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"), BindBox, Click
                }), "Second")
                AddConnection(BindBox.Value:GetPropertyChangedSignal("Text"), function()
                    TweenService:Create(BindBox, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(0, BindBox.Value.TextBounds.X+16, 0, 24)}):Play()
                end)
                AddConnection(Click.InputEnded, function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        if Bind.Binding then return end
                        Bind.Binding = true
                        BindBox.Value.Text = ""
                    end
                end)
                AddConnection(UserInputService.InputBegan, function(Input)
                    if UserInputService:GetFocusedTextBox() then return end
                    if (Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value) and not Bind.Binding then
                        if BindConfig.Hold then Holding = true; BindConfig.Callback(Holding)
                        else BindConfig.Callback() end
                    elseif Bind.Binding then
                        local Key
                        pcall(function() if not CheckKey(BlacklistedKeys, Input.KeyCode) then Key = Input.KeyCode end end)
                        pcall(function() if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then Key = Input.UserInputType end end)
                        Key = Key or Bind.Value
                        Bind:Set(Key); SaveCfg(game.GameId)
                    end
                end)
                AddConnection(UserInputService.InputEnded, function(Input)
                    if Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value then
                        if BindConfig.Hold and Holding then Holding = false; BindConfig.Callback(Holding) end
                    end
                end)
                function Bind:Set(Key) Bind.Binding = false; Bind.Value = Key or Bind.Value; Bind.Value = Bind.Value.Name or Bind.Value; BindBox.Value.Text = Bind.Value end
                Bind:Set(BindConfig.Default)
                if BindConfig.Flag then SertaiVNLib.Flags[BindConfig.Flag] = Bind end
                return Bind
            end

            function ElementFunction:AddTextbox(TextboxConfig)
                TextboxConfig = TextboxConfig or {}
                TextboxConfig.Name = TextboxConfig.Name or "Textbox"
                TextboxConfig.Default = TextboxConfig.Default or ""
                TextboxConfig.TextDisappear = TextboxConfig.TextDisappear or false
                TextboxConfig.Callback = TextboxConfig.Callback or function() end
                local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
                local TextboxActual = AddThemeObject(Create("TextBox", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255,255,255), PlaceholderColor3 = Color3.fromRGB(210,210,210), PlaceholderText = "Input", Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Center, TextSize = 14, ClearTextOnFocus = false}), "Text")
                local TextContainer = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-12,0.5,0), AnchorPoint = Vector2.new(1,0.5)}), {AddThemeObject(MakeElement("Stroke"), "Stroke"), TextboxActual}), "Main")
                local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
                    AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                    AddThemeObject(MakeElement("Stroke"), "Stroke"), TextContainer, Click
                }), "Second")
                AddConnection(TextboxActual:GetPropertyChangedSignal("Text"), function()
                    TweenService:Create(TextContainer, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {Size = UDim2.new(0, TextboxActual.TextBounds.X+16, 0, 24)}):Play()
                end)
                AddConnection(TextboxActual.FocusLost, function()
                    TextboxConfig.Callback(TextboxActual.Text)
                    if TextboxConfig.TextDisappear then TextboxActual.Text = "" end
                end)
                TextboxActual.Text = TextboxConfig.Default
                AddConnection(Click.MouseButton1Up, function() TextboxActual:CaptureFocus() end)
            end

            function ElementFunction:AddColorpicker(ColorpickerConfig)
                ColorpickerConfig = ColorpickerConfig or {}
                ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
                ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255,255,255)
                ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
                ColorpickerConfig.Flag = ColorpickerConfig.Flag or nil
                ColorpickerConfig.Save = ColorpickerConfig.Save or false
                local ColorH, ColorS, ColorV = 1, 1, 1
                local Colorpicker = {Value = ColorpickerConfig.Default, Toggled = false, Type = "Colorpicker", Save = ColorpickerConfig.Save}
                local ColorSelection = Create("ImageLabel", {Size = UDim2.new(0,18,0,18), Position = UDim2.new(select(3, Color3.toHSV(Colorpicker.Value))), ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, Image = "http://www.roblox.com/asset/?id=4805639000"})
                local HueSelection = Create("ImageLabel", {Size = UDim2.new(0,18,0,18), Position = UDim2.new(0.5,0,1-select(1, Color3.toHSV(Colorpicker.Value))), ScaleType = Enum.ScaleType.Fit, AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, Image = "http://www.roblox.com/asset/?id=4805639000"})
                local Color = Create("ImageLabel", {Size = UDim2.new(1,-25,1,0), Visible = false, Image = "rbxassetid://4155801252"}, {Create("UICorner", {CornerRadius = UDim.new(0,5)}), ColorSelection})
                local Hue = Create("Frame", {Size = UDim2.new(0,20,1,0), Position = UDim2.new(1,-20,0,0), Visible = false}, {
                    Create("UIGradient", {Rotation = 270, Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,4)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234,255,0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21,255,0)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0,255,255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0,17,255)), ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255,0,251)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,4))}}),
                    Create("UICorner", {CornerRadius = UDim.new(0,5)}), HueSelection
                })
                local ColorpickerContainer = Create("Frame", {Position = UDim2.new(0,0,0,32), Size = UDim2.new(1,0,1,-32), BackgroundTransparency = 1, ClipsDescendants = true}, {
                    Hue, Color, Create("UIPadding", {PaddingLeft = UDim.new(0,35), PaddingRight = UDim.new(0,35), PaddingBottom = UDim.new(0,10), PaddingTop = UDim.new(0,17)})
                })
                local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1,0,1,0)})
                local ColorpickerBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 4), {Size = UDim2.new(0,24,0,24), Position = UDim2.new(1,-12,0.5,0), AnchorPoint = Vector2.new(1,0.5)}), {AddThemeObject(MakeElement("Stroke"), "Stroke")}), "Main")
                local ColorpickerFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255,255,255), 0, 5), {Size = UDim2.new(1,0,0,38), Parent = ItemParent}), {
                    SetProps(SetChildren(MakeElement("TFrame"), {
                        AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 15), {Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), Font = Enum.Font.GothamBold, Name = "Content"}), "Text"),
                        ColorpickerBox, Click,
                        AddThemeObject(SetProps(MakeElement("Frame"), {Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1), Name = "Line", Visible = false}), "Stroke")
                    }), {Size = UDim2.new(1,0,0,38), ClipsDescendants = true, Name = "F"}),
                    ColorpickerContainer, AddThemeObject(MakeElement("Stroke"), "Stroke")
                }), "Second")
                AddConnection(Click.MouseButton1Click, function()
                    Colorpicker.Toggled = not Colorpicker.Toggled
                    TweenService:Create(ColorpickerFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size = Colorpicker.Toggled and UDim2.new(1,0,0,148) or UDim2.new(1,0,0,38)}):Play()
                    Color.Visible = Colorpicker.Toggled; Hue.Visible = Colorpicker.Toggled; ColorpickerFrame.F.Line.Visible = Colorpicker.Toggled
                end)
                local function UpdateColorPicker()
                    ColorpickerBox.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
                    Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
                    Colorpicker:Set(ColorpickerBox.BackgroundColor3)
                    ColorpickerConfig.Callback(ColorpickerBox.BackgroundColor3)
                    SaveCfg(game.GameId)
                end
                AddConnection(Color.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if ColorInput then ColorInput:Disconnect() end
                        ColorInput = AddConnection(RunService.RenderStepped, function()
                            local ColorX = (math.clamp(Mouse.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X)
                            local ColorY = (math.clamp(Mouse.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)
                            ColorSelection.Position = UDim2.new(ColorX,0,ColorY,0); ColorS = ColorX; ColorV = 1-ColorY
                            UpdateColorPicker()
                        end)
                    end
                end)
                AddConnection(Color.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if ColorInput then ColorInput:Disconnect() end
                    end
                end)
                AddConnection(Hue.InputBegan, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if HueInput then HueInput:Disconnect() end
                        HueInput = AddConnection(RunService.RenderStepped, function()
                            local HueY = (math.clamp(Mouse.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y)
                            HueSelection.Position = UDim2.new(0.5,0,HueY,0); ColorH = 1-HueY
                            UpdateColorPicker()
                        end)
                    end
                end)
                AddConnection(Hue.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if HueInput then HueInput:Disconnect() end
                    end
                end)
                function Colorpicker:Set(Value) Colorpicker.Value = Value; ColorpickerBox.BackgroundColor3 = Colorpicker.Value; ColorpickerConfig.Callback(Colorpicker.Value) end
                Colorpicker:Set(Colorpicker.Value)
                if ColorpickerConfig.Flag then SertaiVNLib.Flags[ColorpickerConfig.Flag] = Colorpicker end
                return Colorpicker
            end

            return ElementFunction
        end

        local ElementFunction = {}
        function ElementFunction:AddSection(SectionConfig)
            SectionConfig.Name = SectionConfig.Name or "Section"
            local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {Size = UDim2.new(1,0,0,26), Parent = Container}), {
                AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {Size = UDim2.new(1,-12,0,16), Position = UDim2.new(0,0,0,3), Font = Enum.Font.GothamSemibold}), "TextDark"),
                SetChildren(SetProps(MakeElement("TFrame"), {AnchorPoint = Vector2.new(0,0), Size = UDim2.new(1,0,1,-24), Position = UDim2.new(0,0,0,23), Name = "Holder"}), {MakeElement("List", 0, 6)})
            })
            AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                SectionFrame.Size = UDim2.new(1,0,0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
                SectionFrame.Holder.Size = UDim2.new(1,0,0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
            end)
            local SectionFunction = {}
            for i, v in next, GetElements(SectionFrame.Holder) do SectionFunction[i] = v end
            return SectionFunction
        end

        for i, v in next, GetElements(Container) do ElementFunction[i] = v end
        return ElementFunction
    end
    return TabFunction
end

function SertaiVNLib:Destroy()
    SertaiVN:Destroy()
end

return SertaiVNLib
