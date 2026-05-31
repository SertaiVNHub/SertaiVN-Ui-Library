# SarXNight Library — Documentation (v3.1)

A lightweight Roblox UI library for script hubs. This page covers the
**v3.1 additions** plus the standard element reference.

> **v3.1 changelog**
> - Removed version strings from the UI.
> - `AddParagraph` now supports an optional **image**.
> - New **`AddSocial`** element — a paragraph-style card with a copyable
>   image/link and a copy button.
> - `AddSlider` now has a **typed input box** (click and type an exact value).

---

## Getting Started

```lua
local Lib = loadstring(game:HttpGet("YOUR_RAW_URL/source.luau"))()

local Window = Lib:MakeWindow({
    Name = "My Hub",
    ConfigFolder = "MyHub",
    SaveConfig = true,
    IntroEnabled = true,
    IntroText = "My Hub",
    InterfaceId = "rbxassetid://11436111346",   -- window/mobile icon
    LoadingLogoId = "rbxassetid://11436111346", -- loading screen logo
    CloseCallback = function() print("closed") end
})

local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://10723345516"
})

local Section = Tab:AddSection({ Name = "Features" })

Lib:Init() -- call after building UI (loads saved config)
```

---

## Paragraph (with optional image) — *updated v3.1*

```lua
Tab:AddParagraph(
    "Title text",
    "This is the body content of the paragraph.",
    "rbxassetid://11436111346" -- optional image (omit for text-only)
)
```

**Arguments**

| # | Name    | Type   | Description                          |
|---|---------|--------|--------------------------------------|
| 1 | Title   | string | Header text.                         |
| 2 | Content | string | Body text (auto-wraps & resizes).    |
| 3 | Image   | string | *(optional)* `rbxassetid://` image.  |

**Returns** an object:

```lua
local p = Tab:AddParagraph("Info", "Old content")
p:Set("New content")
p:SetImage("rbxassetid://123456")
```

---

## Social — *new v3.1*

A paragraph-style card showing an image, a title, and a description, with a
copy button that copies a link/text to the clipboard.

```lua
Section:AddSocial({
    Name = "Discord",
    Content = "Join our community server!",
    Image = "rbxassetid://11436111346",   -- icon / logo
    Copy = "https://discord.gg/example",  -- text copied to clipboard
    Callback = function(copied)
        print("Copied:", copied)
    end
})
```

**Config**

| Key      | Type     | Default        | Description                              |
|----------|----------|----------------|------------------------------------------|
| Name     | string   | `"Social"`     | Title of the card.                       |
| Content  | string   | `""`           | Description text.                        |
| Image    | string   | Library logo   | `rbxassetid://` shown on the left.       |
| Copy     | string   | `Content`      | Text/link copied when the button is hit. |
| Callback | function | `function() end`| Called with the copied string.          |

**Returns**

```lua
local s = Section:AddSocial({ Name = "YouTube", Copy = "https://youtube.com/@me" })
s:Set("New description")
s:SetImage("rbxassetid://123")
s:SetCopy("https://new-link.example")
```

> Copying relies on the executor exposing `setclipboard`
> (or `syn.write_clipboard` / `toclipboard`). If none is available, a
> notification informs the user instead of erroring.

---

## Slider (with input) — *updated v3.1*

Drag the bar **or** click the number on the right and type an exact value.

```lua
Section:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Increment = 1,
    ValueName = "spd",
    Flag = "WalkSpeed",
    Save = true,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})
```

**Config**

| Key       | Type     | Default | Description                                  |
|-----------|----------|---------|----------------------------------------------|
| Name      | string   | `"Slider"` | Label.                                    |
| Min       | number   | `0`     | Minimum value.                               |
| Max       | number   | `100`   | Maximum value.                               |
| Increment | number   | `1`     | Step size (rounding).                        |
| Default   | number   | `50`    | Starting value.                              |
| ValueName | string   | `""`    | Suffix shown after the number.               |
| Flag      | string   | `nil`   | Config key for saving.                       |
| Save      | bool     | `false` | Whether the value is saved to config.        |
| Callback  | function | `noop`  | Fired with the numeric value on change.      |

- **Typed input:** Click the value, type a number, press Enter. Invalid
  input is rejected and the previous value restored. Out-of-range values are
  clamped to `Min`/`Max`.

**Returns**

```lua
local sl = Section:AddSlider({ ... })
sl:Set(120)        -- programmatic set (clamps + rounds)
print(sl.Value)    -- current value
```

---

## Other Elements (unchanged)

### Label
```lua
local l = Tab:AddLabel("Hello")
l:Set("Updated")
```

### Button
```lua
Tab:AddButton({ Name = "Click me", Callback = function() print("hi") end })
```

### Toggle
```lua
Tab:AddToggle({
    Name = "God Mode",
    Default = false,
    Flag = "God",
    Save = true,
    Callback = function(state) print(state) end
})
```

### Dropdown
```lua
local dd = Tab:AddDropdown({
    Name = "Mode",
    Options = {"A", "B", "C"},
    Default = "A",
    Flag = "Mode",
    Save = true,
    Callback = function(opt) print(opt) end
})
dd:Refresh({"X","Y","Z"}, true) -- replace options
dd:Set("Y")
```

### Keybind
```lua
Tab:AddBind({
    Name = "Toggle",
    Default = Enum.KeyCode.E,
    Hold = false,
    Flag = "MyBind",
    Save = true,
    Callback = function() print("pressed") end
})
```

### Textbox
```lua
Tab:AddTextbox({
    Name = "Username",
    Default = "",
    TextDisappear = false,
    Callback = function(text) print(text) end
})
```

### Colorpicker
```lua
Tab:AddColorpicker({
    Name = "Color",
    Default = Color3.fromRGB(255,0,0),
    Flag = "Col",
    Save = true,
    Callback = function(color) print(color) end
})
```

---

## Notifications
```lua
Lib:MakeNotification({
    Name = "Title",
    Content = "Message body",
    Image = "rbxassetid://10709751939",
    Time = 5
})
```

## Hiding / Showing
- **PC:** Press `RightShift` to reopen after closing.
- **Mobile:** Tap the floating draggable icon.

## Cleanup
```lua
Lib:Destroy()
```
