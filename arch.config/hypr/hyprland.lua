-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@144",
	position = "0x0",
	scale = "1",
})

---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal = "ghostty"
local fileManager = "dolphin"
local menu = "vicinae toggle"
local qs_ipc = "qs -c noctalia-shell ipc call"
local cursorTheme = "Remus-White"
local cursorSize = "24"

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function()
	hl.exec_cmd("xrdb ~/.Xresources")
	hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
	hl.exec_cmd("hyprctl setcursor " .. cursorTheme .. " " .. cursorSize)
	hl.exec_cmd("uwsm app -- qs -c noctalia-shell")
	-- hl.exec_cmd("uwsm app -- mako &")
	hl.exec_cmd("uwsm app -- vicinae server &")
	hl.exec_cmd("uwsm app -- jamesdsp -t")
	-- hl.exec_cmd("uwsm app -- swayosd-server &")
	hl.exec_cmd("uwsm app -- wl-paste --type text --watch cliphist store &")
	hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store &")
	hl.exec_cmd("uwsm app -- gnome-keyring-daemon --start --components=secrets &")
	hl.exec_cmd("~/.config/hypr/dynamic-borders.sh") --TODO:
	-- hl.exec_cmd("uwsm app -- bash /home/soham/dotfiles/binomarchy/omarchy-toggle-nightlight &") --TODO:
	hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_THEME", cursorTheme)
hl.env("XCURSOR_SIZE", cursorSize)
hl.env("HYPRCURSOR_SIZE", cursorSize)
hl.env("HYPRCURSOR_THEME", cursorTheme)
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("XDG_SESSION_TYPE", "wayland")
-- hl.env("GBM_BACKEND", "nvidia-drm")
-- hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIBVA_DRIVER_NAME", "iHD")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
-- hl.env("NVD_BACKEND", "direct")
hl.env("GDK_SCALE", "1")
hl.env("FREETYPE_PROPERTIES", "truetype:interpreter-version=35 cff:no-stem-darkening=1 autofitter:no-stem-darkening=1")

-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 3,

		border_size = 2,

		col = {
			active_border = { colors = { "rgba(66bcbbaa)", "rgba(88aaaacc)" }, angle = 45 },
			inactive_border = "rgba(88888877)",
			-- active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			-- inactive_border = "rgba(595959aa)",
		},

		-- Set to true to enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = true,

		-- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
		allow_tearing = true,

		layout = "dwindle",
	},

	decoration = {
		rounding = 8,
		rounding_power = 2,

		-- Change transparency of focused and unfocused windows
		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = false,
			range = 2,
			render_power = 3,
			color = 0xee1a1a1a,
		},

		blur = {
			enabled = false,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = true,
	},

	xwayland = {
		force_zero_scaling = true,
	},

	cursor = {
		no_hardware_cursors = 1,
		no_warps = true,
	},
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Default springs
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})
hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

-- Browser types
hl.window_rule({
	tag = "+chromium-based-browser",
	match = {
		class = "([cC]hrom(e|ium)|google-chrome|[bB]rave-browser|Microsoft-edge|Vivaldi-stable)",
	},
})
hl.window_rule({
	tag = "+firefox-based-browser",
	match = {
		class = "(Firefox|zen|librewolf)",
	},
})
-- Force chromium-based browsers into a tile to deal with --app bug
hl.window_rule({
	tile = true,
	match = {
		tag = "chromium-based-browser",
	},
})

-- Floating windows
hl.window_rule({
	tag = "+floating-window",
	match = {
		class = "(blueberry.py|Impala|Wiremix|org.gnome.NautilusPreviewer|com.gabm.satty|Omarchy|About|TUI.float|org.gnome.Loupe|com.ghostty.floating|vlc|com.ghostty.btop|localsend)",
	},
})
hl.window_rule({
	tag = "+floating-window",
	match = {
		class = "(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|org.gnome.Nautilus|dev.zed.Zed)",
		title = "^(Open.*Files?|Open Folder|Save.*Files?|Save.*As|Save|All Files|Zed — Settings)",
	},
})
hl.window_rule({
	float = true,
	center = true,
	size = "{1300, 850}",
	match = {
		tag = "floating-window",
	},
})

-- Fullscreen
hl.window_rule({
	fullscreen = true,
	match = {
		class = "Screensaver",
	},
})

-- No transparency on media windows
hl.window_rule({
	opacity = "1 1",
	match = {
		class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$",
	},
})

-- Application-specific animation
hl.layer_rule({
	blur = true,
	ignore_alpha = 0.1,
	match = {
		namespace = "waybar",
	},
})
hl.layer_rule({
	no_anim = true,
	match = {
		namespace = "vicinae",
	},
})

-- Picture in picture
hl.window_rule({
	float = true,
	pin = true,
	match = {
		title = "^(Picture in picture)",
	},
})

-- No border on single window
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ rounding = 0, match = { workspace = "w[v1]" } })
hl.window_rule({ border_size = 0, match = { workspace = "w[v1]" } })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
	dwindle = {
		pseudotile = true, -- Master switch for pseudotiling
		preserve_split = true, -- You probably want this
	},
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
-- hl.config({
-- 	master = {
-- 		new_status = "master",
-- 	},
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
-- hl.config({
-- 	scrolling = {
-- 		fullscreen_on_one_column = true,
-- 		column_width = 0.75,
-- 	},
-- })

----------------
----  MISC  ----
----------------

hl.config({
	misc = {
		force_default_wallpaper = 0, -- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		focus_on_activate = true,
		vrr = 0,
	},
})

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,

		-- Change speed of keyboard repeat
		repeat_rate = 25,
		repeat_delay = 400,

		touchpad = {
			natural_scroll = true,
			scroll_factor = 0.07,
		},
		accel_profile = "flat",
		force_no_accel = false,
		sensitivity = 0.20,

		scroll_method = "on_button_down",
		scroll_button = 274,
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	scale = 0.4,
	action = "workspace",
})
hl.gesture({
	fingers = 3,
	direction = "vertical",
	action = "fullscreen",
})
hl.gesture({
	fingers = 4,
	direction = "up",
	action = function()
		hl.exec_cmd(qs_ipc .. " volume increase")
	end,
})
hl.gesture({
	fingers = 4,
	direction = "down",
	action = function()
		hl.exec_cmd(qs_ipc .. " volume decrease")
	end,
})
hl.gesture({
	fingers = 4,
	direction = "left",
	action = function()
		hl.exec_cmd(qs_ipc .. " media next")
	end,
})
hl.gesture({
	fingers = 4,
	direction = "right",
	action = function()
		hl.exec_cmd(qs_ipc .. " media previous")
	end,
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
-- hl.device({
-- 	name = "epic-mouse-v1",
-- 	sensitivity = -0.5,
-- })

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "ALT"

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
-- hl.bind("ALT_R + E", hl.dsp.focus({ workspace = "previous" }), { separate = true })
hl.bind("ALT_R + E", hl.dsp.focus({ urgent_or_last = true }), { separate = true })
hl.bind("ALT_L + Tab", hl.dsp.focus({ urgent_or_last = true }), { separate = true })
hl.bind("ALT_R + T", hl.dsp.exec_cmd("~/.config/hypr/helper.sh ghostty"), { separate = true })
hl.bind("ALT_R + C", hl.dsp.exec_cmd("~/.config/hypr/helper.sh google-chrome-stable"), { separate = true })
hl.bind("ALT_R + B", hl.dsp.exec_cmd("~/.config/hypr/helper.sh brave"), { separate = true })

hl.bind("SUPER + V", hl.dsp.exec_cmd("vicinae vicinae://extensions/vicinae/clipboard/history"))
hl.bind("SUPER + period", hl.dsp.exec_cmd("vicinae vicinae://extensions/vicinae/core/search-emojis"))

-- Only display the OSD on the currently focused monitor
-- local osdclient = "swayosd-client --monitor \"$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')\""
-- local qs_ipc = "qs -p ~/.config/noctalia-shell/ ipc call"

-- Desktop multimedia keys for volume and LCD brightness (with OSD)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(qs_ipc .. " volume increase"),
	{ description = "Volume up", ignore_mods = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(qs_ipc .. " volume decrease"),
	{ description = "Volume down", ignore_mods = true }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(qs_ipc .. " volume muteOutput"), { description = "Mute", ignore_mods = true })
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd(qs_ipc .. " volume muteInput"),
	{ description = "Mute microphone", ignore_mods = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd(qs_ipc .. " brightness increase"),
	{ description = "Brightness up", ignore_mods = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd(qs_ipc .. " brightness decrease"),
	{ description = "Brightness down", ignore_mods = true }
)
hl.bind("ALT_R + Up", hl.dsp.exec_cmd(qs_ipc .. " volume increase"), { separate = true })
hl.bind("ALT_R + Down", hl.dsp.exec_cmd(qs_ipc .. " volume decrease"), { separate = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(qs_ipc .. " media next"), { description = "Next track", ignore_mods = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(qs_ipc .. " media playPause"), { description = "Pause", ignore_mods = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(qs_ipc .. " media playPause"), { description = "Play", ignore_mods = true })
hl.bind(
	"XF86AudioPrev",
	hl.dsp.exec_cmd(qs_ipc .. " media previous"),
	{ description = "Previous track", ignore_mods = true }
)

hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal))
hl.bind("ALT_R + SHIFT_R + Q", hl.dsp.window.close(), { separate = true })
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("hyprshutdown"))
hl.bind("ALT_R + V", hl.dsp.window.float({ action = "toggle" }), { separate = true })
hl.bind("ALT_R + P", hl.dsp.window.pin(), { separate = true })
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu))
hl.bind("CTRL + SHIFT + l", hl.dsp.exec_cmd(qs_ipc .. " lockScreen lock"))
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -z -m region -o /home/soham/Pictures/Screenshots/"))
hl.bind("CTRL + SHIFT + S", hl.dsp.exec_cmd("hyprshot -z -m window -o /home/soham/Pictures/Screenshots/"))
hl.bind("SUPER + SHIFT + bracketleft", hl.dsp.exec_cmd("hyprshot -z -m output -o /home/soham/Pictures/Screenshots/"))
-- hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle
hl.bind("SUPER + E", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- dwindle
-- hl.bind(mainMod .. " + W", hl.dsp.group.toggle()) -- dwindle

-- Move focus with mainMod + arrow keys
hl.bind("SUPER + h", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "d" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("SUPER + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

-- Cycle wallpaper
-- hl.bind("SUPER + N", hl.dsp.exec_cmd("/home/soham/.config/hypr/next-wallpaper.sh"))
hl.bind("SUPER + N", hl.dsp.exec_cmd(qs_ipc .. " wallpaper random eDP-1"))
