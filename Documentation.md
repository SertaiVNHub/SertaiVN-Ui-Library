# SertaiVN UI Library v2.2 Documentation

> Based on Orion (Discontinued) — Thanks to Orion team!  
> **v2.2: Major redesign with settings panel, search, and image-based icons**

---

## 🔄 v2.2 Changelog

### ❌ Removed
- **`PremiumOnly` parameter** — No longer in `MakeTab` (removed entirely)
- **`AddSection` function** — Sections removed (no more length issues)
- **Emoji icons in tabs** — Replaced with `rbxassetid` images
- **Feather Icons HTTP fetch** — Removed (no external requests)
- **Dropdown unlimited length** — Now capped at 3 visible, scrolls for more

### ✅ Added
- **Settings Panel** — Built-in panel accessible via sidebar button
  - Profile (avatar, DisplayName, @username, UserID)
  - Device detection (PC/Mobile)
  - Live FPS counter
  - Live Ping counter
  - Discord socials paragraph
- **Search tabs bar** — Filter tabs by name in real-time
- **Socials Paragraph** — `AddSocialsParagraph` with image + copy URL button
- **Window icon support** — `WindowConfig.Icon` (rbxassetid)
- **Mobile toggle button image** — Custom rbxassetid instead of "S" text
- **Mobile toggle drag** — Floating button now draggable
- **Dropdown scrolling** — Always limited to 3 visible, scrolls for >3
- **Image-based notifications** — `Image` parameter accepts rbxassetid (number)

### 🎨 New Design
- **Reworked loading screen** — Logo box with image (rbxassetid) instead of text
- **Default icons** — Close: `99967063680607`, Settings: `2484550861`, Home: `9405923708`
- **Sidebar with search + Settings button** — New layout

---

## 🚀 Quick Start

```lua
local SertaiVNLib = loadstring(game:HttpGet("YOUR_URL/Source.luau"))()

local Window = SertaiVNLib:MakeWindow({
    Name = "SertaiVN Hub",
    Icon = 9405923708,           -- Window top-left icon
    IntroIcon = 9405923708,      -- Loading screen logo
    ToggleIcon = 9405923708,     -- Mobile floating button icon
    CloseIcon = 99967063680607,  -- Close (X) icon
    SettingsIcon = 2484550861,   -- Settings button icon
    HomeIcon = 9405923708,       -- Default tab icon
    IntroText = "SertaiVN Hub",
    SaveConfig = true,
    ConfigFolder = "SertaiVNHub"
})

local Tab = Window:MakeTab({Name = "Main", Icon = 9405923708})

Tab:AddButton({Name = "Click Me", Callback = function()
    SertaiVNLib:MakeNotification({Name = "Clicked", Content = "Works!", Image = 4384403532, Time = 4})
end})

SertaiVNLib:Init()
```

---

## 🪟 Window Config

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| Name | string | "SertaiVN Library" | Window title |
| Icon | number | 9405923708 | Window top icon (rbxassetid) |
| IntroIcon | number | 9405923708 | Loading logo (rbxassetid) |
| ToggleIcon | number | 9405923708 | Mobile button icon (rbxassetid) |
| CloseIcon | number | 99967063680607 | Close X icon (rbxassetid) |
| SettingsIcon | number | 2484550861 | Settings icon (rbxassetid) |
| HomeIcon | number | 9405923708 | Default tab icon (rbxassetid) |
| IntroText | string | "SertaiVN Library" | Typewriter text |
| IntroEnabled | boolean | true | Show loading |
| SaveConfig | boolean | false | Auto-save configs |
| ConfigFolder | string | Name | Config folder |
| CloseCallback | function | (empty) | Called on close |

---

## 📑 Tabs

```lua
local Tab = Window:MakeTab({
    Name = "Main",
    Icon = 9405923708  -- rbxassetid number (no emoji!)
})
```

**No more `PremiumOnly` field.**

---

## 🔍 Search Tabs

Built-in at top of sidebar. Type to filter tabs by name. Empty = show all.

---

## 🧩 Elements

### Label
```lua
local lbl = Tab:AddLabel("Hello")
lbl:Set("New text")
```

### Paragraph
```lua
local p = Tab:AddParagraph("Title", "Content")
p:Set("New content")
```

### **Socials Paragraph (NEW!)**
```lua
Tab:AddSocialsParagraph({
    Title = "Discord",
    Content = "Join our community",
    Image = 4384403532,
    LinkName = "Copy Link",
    URL = "https://discord.gg/sertaivn"
})
```
Click button to copy URL to clipboard.

### Button
```lua
Tab:AddButton({
    Name = "Click",
    Icon = 3944703587,  -- rbxassetid
    Callback = function() print("hi") end
})
```

### Toggle
```lua
Tab:AddToggle({
    Name = "Auto",
    Default = false,
    Color = Color3.fromRGB(130, 110, 230),
    Callback = function(v) end,
    Flag = "AutoFlag",
    Save = true
})
```

### Slider (Mobile + PC)
```lua
Tab:AddSlider({
    Name = "Speed",
    Min = 0, Max = 100, Default = 50,
    Increment = 1, ValueName = "studs/s",
    Color = Color3.fromRGB(130, 110, 230),
    Callback = function(v) end,
    Flag = "Speed", Save = true
})
```

### **Dropdown (NEW: Scrollable, Max 3 visible)**
```lua
Tab:AddDropdown({
    Name = "Mode",
    Default = "Easy",
    Options = {"Easy", "Medium", "Hard", "Insane", "Extreme", "Legendary"},
    Callback = function(o) end,
    Flag = "Mode", Save = true
})
```
- Always shows **max 3 options at once**
- More options? **Scroll inside the dropdown**
- No more giant dropdowns blocking the UI!

### Bind (Keybind)
```lua
Tab:AddBind({
    Name = "Toggle",
    Default = Enum.KeyCode.E,
    Hold = false,
    Callback = function() end,
    Flag = "Key", Save = true
})
```

### Textbox
```lua
Tab:AddTextbox({
    Name = "Username",
    Default = "",
    TextDisappear = false,
    Callback = function(t) end
})
```

### Colorpicker
```lua
Tab:AddColorpicker({
    Name = "Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(c) end,
    Flag = "Color", Save = true
})
```

---

## 🔔 Notifications (Image is rbxassetid number)

```lua
SertaiVNLib:MakeNotification({
    Name = "Title",
    Content = "Message",
    Image = 4384403532,  -- rbxassetid as number
    Time = 5
})
```

---

## ⚙ Settings Panel

Auto-included! Click the **Settings** button at the bottom of the sidebar.

Contains:
- **Profile card** — Avatar, DisplayName, @username, UserID
- **Device** — Auto-detected (PC/Mobile)
- **FPS** — Live updating
- **Ping** — Live updating
- **Discord Socials** — Copy invite link

---

## 📱 Mobile Toggle (Draggable!)

When UI is closed (✕):
- Floating image button appears at top-left
- **Draggable** — Move it anywhere
- **Tap** to reopen UI
- Uses `ToggleIcon` (rbxassetid)

---

## 🎬 New Loading Screen

1. Logo box scales in (Back easing)
2. Logo image fades in (rbxassetid)
3. Title text appears via typewriter effect
4. "Initializing..." subtitle fades in
5. Everything fades out → UI appears

All icons are **rbxassetid based** — no external HTTP requests, no asset failures.

---

## 💾 Config System

Auto-loaded via `SertaiVNLib:Init()` if `SaveConfig = true`.

Saved to: `<ConfigFolder>/<GameId>.txt`

Only flagged elements with `Save = true` are persisted.

---

## 🗑 Destroy

```lua
SertaiVNLib:Destroy()
```

---

## 🐛 Fixed in v2.2

| Bug | Status |
|-----|--------|
| Feather Icons HTTP fail | ✅ Removed (rbxassetid only) |
| Dropdown too long | ✅ Max 3 + scroll |
| No settings panel | ✅ Built-in |
| No search for tabs | ✅ Added |
| Emoji icons inconsistent | ✅ Replaced with rbxassetid |
| Mobile toggle not draggable | ✅ Fixed |
| No socials element | ✅ AddSocialsParagraph added |
| `PremiumOnly` clutter | ✅ Removed |
| `AddSection` length issues | ✅ Removed |

---

## 📋 Full Example

```lua
local SertaiVNLib = loadstring(game:HttpGet("YOUR_URL"))()

local Window = SertaiVNLib:MakeWindow({
    Name = "SertaiVN Hub | v2.2",
    Icon = 9405923708,
    IntroIcon = 9405923708,
    ToggleIcon = 9405923708,
    CloseIcon = 99967063680607,
    SettingsIcon = 2484550861,
    HomeIcon = 9405923708,
    IntroText = "SertaiVN Hub",
    SaveConfig = true,
    ConfigFolder = "SertaiVNHub"
})

local Main = Window:MakeTab({Name = "Main", Icon = 9405923708})

Main:AddLabel("Welcome!")
Main:AddParagraph("Info", "This is v2.2 with image icons and search.")

Main:AddSocialsParagraph({
    Title = "Discord Community",
    Content = "Join SertaiVN HUB",
    Image = 4384403532,
    LinkName = "Copy Invite",
    URL = "https://discord.gg/sertaivn"
})

Main:AddButton({Name = "Test", Callback = function()
    SertaiVNLib:MakeNotification({Name = "Hi!", Content = "Works!", Image = 4384403532, Time = 4})
end})

Main:AddToggle({Name = "Auto Farm", Default = false, Callback = function(v) end, Flag = "Auto", Save = true})
Main:AddSlider({Name = "Speed", Min = 16, Max = 200, Default = 16, Callback = function(v) end, Flag = "Speed", Save = true})

local Visuals = Window:MakeTab({Name = "Visuals", Icon = 9405923708})

Visuals:AddDropdown({
    Name = "ESP Mode",
    Default = "Box",
    Options = {"Box", "Outline", "Name", "Health", "Distance", "Tracer", "Skeleton"},
    Callback = function(o) end,
    Flag = "ESPMode", Save = true
})

Visuals:AddColorpicker({Name = "ESP Color", Default = Color3.fromRGB(255,0,0), Callback = function(c) end, Flag = "ESPColor", Save = true})

SertaiVNLib:Init()
```

---

## 📊 Stats

- **Lines:** ~1980 ✅ (target: 1900-2000)
- **Elements:** 10 (Label, Paragraph, SocialsParagraph, Button, Toggle, Slider, Dropdown, Bind, Textbox, Colorpicker)
- **Removed:** PremiumOnly, AddSection, emoji icons
- **Added:** Settings panel, search, socials paragraph, drag toggle, dropdown scroll

---

**Made by SertaiVN © 2026**  
Based on Orion (Discontinued) — Thanks Orion! 🙏
