## Migration from v2.5 → v3

| v2.5 | v3 | Notes |
|---|---|---|
| `SertaiVN` (global) | `SarXNight` | Rename your variable when calling `loadstring(...)()` |
| `SertaiVNLib` (internal) | `SarXNightLib` | Internal only — doesn't affect users |
| `ScreenGui` name `"SertaiVN"` | `"SarXNight"` | Internal only |
| `Icon` (MakeWindow) | **`InterfaceId`** | Old key still works as fallback |
| `IntroIcon` (MakeWindow) | **`LoadingLogoId`** | Old key still works as fallback |

### Find & Replace Cheat Sheet

```lua
-- Before (v2.5)
local SertaiVN = loadstring(game:HttpGet("..."))()
local Window = SertaiVN:MakeWindow({
    Name = "My Hub",
    Icon = "rbxassetid://123",
    IntroIcon = "rbxassetid://123"
})
SertaiVN:MakeNotification({...})
SertaiVN:Init()

-- After (v3)
local SarXNight = loadstring(game:HttpGet("..."))()
local Window = SarXNight:MakeWindow({
    Name = "My Hub",
    InterfaceId = "rbxassetid://123",
    LoadingLogoId = "rbxassetid://123"
})
SarXNight:MakeNotification({...})
SarXNight:Init()
```

---

## How To Create Your Own Script Hub With SarXNight

This section walks you through building a complete, polished script hub from zero. By the end you'll have a multi-tab hub with auto-farm, player mods, ESP, teleports, and persistent config.

### Step 1 — Prepare Your Assets

Upload these to Roblox as decals/images and grab the asset IDs:

1. **Hub logo** (used for `InterfaceId` and `LoadingLogoId`) — 256×256 PNG works great
2. **Tab icons** — one per tab, 64×64 PNG
3. *(Optional)* **Notification icon** — for branded notifications

> Tip: keep icons monochrome (white on transparent) so the library can tint them with your accent color.

---

### Step 2 — The Loader Script

The user-facing loader is what people put in their executor. Host `Source.luau` on GitHub (raw URL) or Pastebin (raw URL):

```lua
-- MyHub-Loader.lua
local ok, lib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Styuai6/SarXNight-Ui-Library/refs/heads/main/Source.luau"))()
end)

if not ok then
    warn("Failed to load SarXNight: " .. tostring(lib))
    return
end

_G.SarXNight = lib
loadstring(game:HttpGet("https://raw.githubusercontent.com/Styuai6/SarXNight-Ui-Library/refs/heads/main/Source.luau"))()
```

---

### Step 3 — Hub Skeleton

```lua
local SarXNight = _G.SarXNight or loadstring(game:HttpGet("https://raw.githubusercontent.com/Styuai6/SarXNight-Ui-Library/refs/heads/main/Source.luau"))()

local Window = SarXNight:MakeWindow({
    Name        = "Nightfall Hub",
    InterfaceId = "rbxassetid://YOUR_LOGO_ID",
    LoadingLogoId = "rbxassetid://YOUR_LOGO_ID",
    IntroText   = "Nightfall Hub",
    IntroEnabled = true,
    SaveConfig  = true,
    ConfigFolder = "NightfallHub",
    CloseCallback = function()
        print("Hub hidden")
    end
})
```

---

### Step 4 — Adding Tabs

```lua
local MainTab     = Window:MakeTab({ Name = "Main",      Icon = "rbxassetid://10723345516" })
local PlayerTab   = Window:MakeTab({ Name = "Player",    Icon = "rbxassetid://10747384394" })
local CombatTab   = Window:MakeTab({ Name = "Combat",    Icon = "rbxassetid://10734898355" })
local TeleportTab = Window:MakeTab({ Name = "Teleports", Icon = "rbxassetid://10709790948" })
local VisualTab   = Window:MakeTab({ Name = "Visuals",   Icon = "rbxassetid://10747373144" })
local MiscTab     = Window:MakeTab({ Name = "Misc",      Icon = "rbxassetid://10734896206" })
local SettingsTab = Window:MakeTab({ Name = "Settings",  Icon = "rbxassetid://10709751939" })
```

---

### Step 5 — Main Tab (info & quick actions)

```lua
MainTab:AddParagraph("Welcome", "Thanks for using Nightfall Hub! Use the search bar to find tabs quickly.")

local StatusLabel = MainTab:AddLabel("Status: Idle")

MainTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end
})

MainTab:AddButton({
    Name = "Copy Join Link",
    Callback = function()
        if setclipboard then
            setclipboard("https://www.roblox.com/games/" .. game.PlaceId)
            SarXNight:MakeNotification({ Name = "Copied", Content = "Game link copied!", Time = 3 })
        end
    end
})
```

---

### Step 6 — Player Tab (movement mods)

```lua
local function getHum()
    local c = game.Players.LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

PlayerTab:AddSlider({
    Name = "WalkSpeed", Min = 16, Max = 300, Default = 16, ValueName = "studs/s",
    Flag = "walkspeed", Save = true,
    Callback = function(v) local h = getHum(); if h then h.WalkSpeed = v end end
})

PlayerTab:AddSlider({
    Name = "JumpPower", Min = 50, Max = 500, Default = 50, ValueName = "power",
    Flag = "jumppower", Save = true,
    Callback = function(v) local h = getHum(); if h then h.JumpPower = v end end
})

PlayerTab:AddToggle({
    Name = "Infinite Jump", Default = false,
    Flag = "infjump", Save = true,
    Callback = function(state) _G.InfJump = state end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfJump then local h = getHum(); if h then h:ChangeState("Jumping") end end
end)

PlayerTab:AddBind({
    Name = "Toggle Noclip",
    Default = Enum.KeyCode.N,
    Flag = "noclipkey", Save = true,
    Callback = function() _G.Noclip = not _G.Noclip end
})
```

---

### Step 7 — Combat Tab (toggles + dropdown)

```lua
CombatTab:AddSection({ Name = "Auto Farm" })

CombatTab:AddToggle({
    Name = "Enable Auto Farm",
    Default = false, Flag = "autofarm", Save = true,
    Callback = function(state) _G.AutoFarm = state end
})

CombatTab:AddDropdown({
    Name = "Target Mob",
    Options = {"Bandit", "Goblin", "Wolf", "Troll", "Dragon", "Boss"},
    Default = "Bandit",
    Flag = "target", Save = true,
    Callback = function(v) _G.Target = v end
})

CombatTab:AddSlider({
    Name = "Attack Range", Min = 5, Max = 100, Default = 15, ValueName = "studs",
    Flag = "range", Save = true,
    Callback = function(v) _G.Range = v end
})

CombatTab:AddSection({ Name = "Auto Attack" })

CombatTab:AddBind({
    Name = "Toggle Auto Attack", Default = Enum.KeyCode.F,
    Flag = "autoattack_key", Save = true,
    Callback = function() _G.AutoAttack = not _G.AutoAttack end
})
```

---

### Step 8 — Teleports Tab (dynamic dropdown)

```lua
local locations = {
    ["Spawn"]   = CFrame.new(0, 5, 0),
    ["Shop"]    = CFrame.new(100, 5, 50),
    ["Dungeon"] = CFrame.new(-200, 50, 300),
    ["Boss"]    = CFrame.new(500, 100, -100),
}

local names = {}
for k in pairs(locations) do table.insert(names, k) end

TeleportTab:AddDropdown({
    Name = "Location",
    Options = names,
    Default = names[1],
    Flag = "tp_loc", Save = true,
    Callback = function(v) _G.TeleportTarget = v end
})

TeleportTab:AddButton({
    Name = "Teleport",
    Callback = function()
        local target = _G.TeleportTarget
        local c = game.Players.LocalPlayer.Character
        if c and locations[target] then
            c:PivotTo(locations[target])
            SarXNight:MakeNotification({ Name = "Teleport", Content = "Teleported to " .. target, Time = 3 })
        end
    end
})

TeleportTab:AddSection({ Name = "Players" })

local playerDropdown = TeleportTab:AddDropdown({
    Name = "Player",
    Options = {},
    Default = "",
    Callback = function() end
})

TeleportTab:AddButton({
    Name = "Refresh Players",
    Callback = function()
        local list = {}
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer then table.insert(list, p.Name) end
        end
        playerDropdown:Refresh(list, true)
    end
})
```

---

### Step 9 — Visuals Tab (colorpickers)

```lua
VisualTab:AddToggle({
    Name = "ESP Boxes", Default = false,
    Flag = "esp_box", Save = true,
    Callback = function(s) _G.ESPBox = s end
})

VisualTab:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "esp_color", Save = true,
    Callback = function(c) _G.ESPColor = c end
})

VisualTab:AddToggle({
    Name = "Fullbright", Default = false,
    Flag = "fullbright", Save = true,
    Callback = function(s)
        if s then
            game.Lighting.Brightness = 5; game.Lighting.FogEnd = 1e6
        else
            game.Lighting.Brightness = 1; game.Lighting.FogEnd = 1e4
        end
    end
})
```

---

### Step 10 — Settings Tab + Init

```lua
SettingsTab:AddParagraph("Hub Info", "Nightfall Hub v1.0 — built on SarXNight v3.")

SettingsTab:AddBind({
    Name = "Toggle UI", Default = Enum.KeyCode.RightShift,
    Flag = "ui_toggle", Save = true,
    Callback = function() end
})

SettingsTab:AddButton({
    Name = "Unload Hub",
    Callback = function()
        SarXNight:MakeNotification({ Name = "Unloading", Content = "Bye!", Time = 2 })
        wait(2); SarXNight:Destroy()
    end
})

-- Always last — loads saved values for every flagged element
SarXNight:Init()

SarXNight:MakeNotification({
    Name = "Nightfall Hub",
    Content = "Loaded successfully! Press RightShift to hide.",
    Time = 6
})
```

---

### Best Practices

- **Always set `Flag` + `Save = true`** on persistent settings.
- **Call `SarXNight:Init()` last**, after all elements are created.
- **Wrap risky callbacks in `pcall`** to avoid breaking your script.
- **Use sections** to group related controls — they read much cleaner.
- **Keep dropdowns short** or use `:Refresh()` to repopulate dynamically (max 3 visible, the rest scroll).
- **Don't hardcode colors** — use `Theme.Accent` for branded highlights.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Library doesn't show up | Make sure the raw URL is correct and the executor supports `loadstring + HttpGet` |
| Icons are blank | Replace placeholder `rbxassetid://` with your own uploaded IDs |
| Mobile toggle vanishes | It only appears after the X button is clicked. Drag it where you want it. |
| Config not saving | Set `SaveConfig = true` on the window AND `Save = true` + a unique `Flag` on each element |
| Old `SertaiVN` script breaks | Replace `SertaiVN` → `SarXNight` globally, see migration table above |

---

## License

Free to use, modify, and redistribute. Credit appreciated but not required.
