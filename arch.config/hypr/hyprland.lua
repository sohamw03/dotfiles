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
	output = "",
	mode = "highres@highrr",
	position = "0x0",
	scale = "1",
})

---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal = "ghostty"
local fileManager = "nautilus"
local menu = "vicinae toggle"
local qs_ipc = "qs -p /home/soham/dotfiles/shell ipc call"
local cursorTheme = "Adwaita"
local cursorSize = "24"

local current_focused_window = nil
local previous_focused_window = nil

local single_launch_apps = {
	brave = {
		class = "brave-browser",
		name = "Brave",
		command = "brave",
		notification_id_file = "/tmp/hypr-single-launch-brave.notification",
	},
	["google-chrome-stable"] = {
		class = "google-chrome",
		name = "Google Chrome",
		command = "google-chrome-stable --disable-lcd-text --disable-font-subpixel-positioning",
		notification_id_file = "/tmp/hypr-single-launch-google-chrome-stable.notification",
	},
	ghostty = {
		class = "com.mitchellh.ghostty",
		name = "Ghostty",
		command = "ghostty --working-directory=home",
		notification_id_file = "/tmp/hypr-single-launch-ghostty.notification",
	},
}
local pending_single_launches = {}

local function find_window_by_class(class)
	for _, window in ipairs(hl.get_windows()) do
		if string.lower(window.class or "") == string.lower(class) then
			return window
		end
	end
end

local function dismiss_launch_notification(notification_id_file)
	hl.exec_cmd(
		[[sh -c 'id_file="]]
			.. notification_id_file
			.. [["; [ -s "$id_file" ] || exit 0; id="$(cat "$id_file")"; rm -f "$id_file"; command -v gdbus >/dev/null 2>&1 || exit 0; gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.CloseNotification "$id" >/dev/null 2>&1 || true']]
	)
end

hl.on("window.active", function(window)
	if window == nil or (current_focused_window ~= nil and window.address == current_focused_window.address) then
		return
	end
	-- Skip layer surfaces (panels, bars); only regular windows count.
	local regular = false
	for _, w in ipairs(hl.get_windows()) do
		if w.address == window.address then
			regular = true
			break
		end
	end
	if not regular then
		return
	end
	previous_focused_window = current_focused_window
	current_focused_window = window
end)

local function clear_focus_history_window(window)
	if window == nil then
		return
	end

	if current_focused_window ~= nil and window.address == current_focused_window.address then
		current_focused_window = nil
	end
	if previous_focused_window ~= nil and window.address == previous_focused_window.address then
		previous_focused_window = nil
	end
end

hl.on("window.close", clear_focus_history_window)
hl.on("window.destroy", clear_focus_history_window)

local function focus_previous_window()
	local active = hl.get_active_window()
	-- A panel/void focus must never overwrite history; fall back to last regular window.
	if active ~= nil then
		local regular = false
		for _, w in ipairs(hl.get_windows()) do
			if w.address == active.address then
				regular = true
				break
			end
		end
		if not regular then
			active = current_focused_window
		end
	else
		active = current_focused_window
	end
	local previous = previous_focused_window

	if previous ~= nil and (active == nil or previous.address ~= active.address) then
		local live_previous = nil
		for _, window in ipairs(hl.get_windows()) do
			if window.address == previous.address then
				live_previous = window
				break
			end
		end

		if live_previous ~= nil then
			previous_focused_window = active
			current_focused_window = live_previous
			hl.dispatch(hl.dsp.focus({ window = live_previous }))
			return
		end
	end

	hl.dispatch(hl.dsp.focus({ urgent_or_last = true }))
end

hl.on("window.open", function(window)
	local class = string.lower(window.class or "")
	local pending = pending_single_launches[class]
	if pending == nil then
		return
	end

	pending.timer:set_enabled(false)
	dismiss_launch_notification(pending.notification_id_file)
	pending_single_launches[class] = nil
	hl.dispatch(hl.dsp.focus({ window = window }))
end)

local function focus_or_launch_single(app)
	local spec = single_launch_apps[app]
	assert(spec, "unknown app: " .. tostring(app))
	local class = string.lower(spec.class)

	local window = find_window_by_class(class)
	if window ~= nil then
		hl.dispatch(hl.dsp.focus({ window = window }))
		return
	end

	if pending_single_launches[class] ~= nil then
		return
	end

	local timer = hl.timer(function()
		local pending = pending_single_launches[class]
		if pending ~= nil then
			dismiss_launch_notification(pending.notification_id_file)
			pending_single_launches[class] = nil
		end
	end, { timeout = 20000, type = "oneshot" })

	pending_single_launches[class] = {
		notification_id_file = spec.notification_id_file,
		timer = timer,
	}

	hl.exec_cmd(
		[[sh -c 'notify-send --app-name=ahk-rs --urgency=critical --expire-time=0 --print-id "Opening ]]
			.. spec.name
			.. [[..." > ]]
			.. spec.notification_id_file
			.. [[ 2>/dev/null || true; ]]
			.. spec.command
			.. [[']]
	)
end

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
	hl.exec_cmd("uwsm app -- qs -p /home/soham/dotfiles/shell")
	-- hl.exec_cmd("uwsm app -- mako &")
	hl.exec_cmd("uwsm app -- vicinae server &")
	-- hl.exec_cmd("uwsm app -- jamesdsp -t")
	hl.exec_cmd("uwsm app -- easyeffects --service-mode")
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
hl.env("GTK_USE_PORTAL", "1")

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
		gaps_in = 0,
		gaps_out = 0,

		border_size = 1,

		col = {
			-- active_border = { colors = { "rgba(66bcbbaa)", "rgba(88aaaacc)" }, angle = 45 },
			-- inactive_border = "rgba(88888877)",

			-- active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			-- inactive_border = "rgba(595959aa)",

			-- Active: A very soft, semi-transparent slate grey line
			active_border = "rgba(606060ff)",
			-- Inactive: An ultra-faint ghost grey line that prevents overlapping windows from blending together
			inactive_border = "rgba(202020ff)",
		},

		-- Set to true to enable resizing windows by clicking and dragging on borders and gaps
		resize_on_border = true,

		-- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
		allow_tearing = true,

		layout = "dwindle",
		no_focus_fallback = true
	},

	dwindle = {
		preserve_split = true, -- You probably want this
		smart_split = true,
	},

	decoration = {
		-- rounding = 8,
		rounding = 0,
		rounding_power = 2,

		-- Change transparency of focused and unfocused windows
		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = false,
			range = 2,
			render_power = 3,
			color = "0xee1a1a1a",
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
hl.curve("smoothEase", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })

-- Default springs
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = false, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "smoothEase" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
-- Keep workspace switching instant.
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = false, speed = 0, bezier = "default" })
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
		class = "(blueberry.py|Impala|Wiremix|org.gnome.NautilusPreviewer|com.gabm.satty|dev.tensaku.Tensaku|Omarchy|About|TUI.float|org.gnome.Loupe|io.github.diegopvlk.Cine|com.ghostty.floating|vlc|com.ghostty.btop|localsend)",
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
	size = "985 808",
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
hl.layer_rule({
	no_anim = true,
	match = {
		namespace = "noctalia-bar.*",
	},
})
hl.layer_rule({
	no_anim = true,
	match = {
		namespace = "noctalia-background.*",
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

		follow_mouse = 2,

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

-- Flick-triggered switch glides; keybinds stay instant (animation off by default).
local ws_anim_timer = nil
local function animated_workspace_switch(target)
	hl.animation({ leaf = "workspaces", enabled = true, speed = 8, bezier = "easeOutQuint" })
	hl.dispatch(hl.dsp.focus({ workspace = target }))
	if ws_anim_timer ~= nil then
		ws_anim_timer:set_enabled(false)
	end
	ws_anim_timer = hl.timer(function()
		hl.animation({ leaf = "workspaces", enabled = false, speed = 0, bezier = "default" })
		ws_anim_timer = nil
	end, { timeout = 1000, type = "oneshot" })
end
hl.gesture({
	fingers = 3,
	direction = "left",
	action = function()
		animated_workspace_switch("e+1")
	end,
})
hl.gesture({
	fingers = 3,
	direction = "right",
	action = function()
		animated_workspace_switch("e-1")
	end,
})
hl.gesture({
	fingers = 3,
	direction = "vertical",
	action = "fullscreen",
})
-- 4-finger vertical volume: continuous, with a gentle boost on fast flicks (max 2.5x).
-- Fires at most once every 3 updates; each fire spawns qs + wpctl processes.
local volume_acc = 0
local volume_pushes = 0
local function volume_fire()
	local d = volume_acc
	volume_acc = 0
	volume_pushes = 0
	hl.exec_cmd(qs_ipc .. " volume adjust " .. string.format("%.4f", d))
end
local function volume_push(delta_y)
	if delta_y == nil then
		return
	end
	-- delta.y is +down / -up, so swipe up (negative) = increase
	local gain = 0.5 + math.min(math.abs(delta_y) / 20, 2.0)
	volume_acc = volume_acc + (-delta_y * 0.0025 * gain)
	volume_pushes = volume_pushes + 1
	-- Leftovers keep accumulating; flush() applies them on lift.
	if math.abs(volume_acc) >= 0.01 and volume_pushes >= 3 then
		volume_fire()
	end
end
local function volume_flush()
	if math.abs(volume_acc) >= 0.008 then
		volume_fire()
	else
		volume_acc = 0
	end
end
hl.gesture({
	fingers = 4,
	direction = "vertical",
	action = {
		start = function(e)
			volume_push(e.delta.y)
		end,
		update = function(e)
			volume_push(e.delta.y)
		end,
		finish = function(_e)
			volume_flush()
		end,
	},
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
-- hl.bind("ALT + E", hl.dsp.focus({ workspace = "previous" }), { separate = true })
hl.bind("ALT + E", focus_previous_window, { separate = true })
hl.bind("ALT + Tab", focus_previous_window, { separate = true })
hl.bind("ALT + T", function()
	focus_or_launch_single("ghostty")
end, { separate = true })
hl.bind("ALT + C", function()
	focus_or_launch_single("google-chrome-stable")
end, { separate = true })
hl.bind("ALT + B", function()
	focus_or_launch_single("brave")
end, { separate = true })

hl.bind("SUPER + V", hl.dsp.exec_cmd("vicinae vicinae://launch/clipboard/history"))
hl.bind("SUPER + period", hl.dsp.exec_cmd("vicinae vicinae://launch/core/search-emojis"))

-- Only display the OSD on the currently focused monitor
-- local osdclient = "swayosd-client --monitor \"$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')\""
-- local qs_ipc = "qs -p ~/.config/noctalia-shell/ ipc call"

-- Desktop multimedia keys for volume and LCD brightness (with OSD)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(qs_ipc .. " volume increase"),
	{ description = "Volume up", ignore_mods = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(qs_ipc .. " volume decrease"),
	{ description = "Volume down", ignore_mods = true, repeating = true }
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
	{ description = "Brightness up", ignore_mods = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd(qs_ipc .. " brightness decrease"),
	{ description = "Brightness down", ignore_mods = true, repeating = true }
)
hl.bind("ALT + K", hl.dsp.exec_cmd(qs_ipc .. " volume increase"), { repeating = true })
hl.bind("ALT + J", hl.dsp.exec_cmd(qs_ipc .. " volume decrease"), { repeating = true })
hl.bind("ALT + M", hl.dsp.exec_cmd(qs_ipc .. " media playPause"), { description = "Play/Pause", separate = true })

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
hl.bind("ALT + SHIFT + Q", hl.dsp.window.close(), { separate = true })
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd("hyprshutdown"))
hl.bind("ALT + V", hl.dsp.window.float({ action = "toggle" }), { separate = true })
hl.bind("ALT + P", hl.dsp.window.pin(), { separate = true })
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu))
hl.bind("CTRL + SHIFT + l", hl.dsp.exec_cmd(qs_ipc .. " lockScreen lock"))
-- Reload drops hyprshade's screen shader, so re-assert night light afterwards
-- (Noctalia reads enabled from settings while the compositor has no shader).
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("sh -c 'hyprctl reload; sleep 1; " .. qs_ipc .. " nightLight reapply'"))
-- Omarchy-style grim+slurp screenshots: night light suppressed during capture,
-- preview notification offers Tensaku edit. Modes: smart (drag or click a
-- window), windows (snap to window/monitor), fullscreen (focused monitor).
local screenshot = "/home/soham/.config/hypr/Scripts/screenshot.sh"
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(screenshot .. " smart"))
hl.bind("CTRL + SHIFT + S", hl.dsp.exec_cmd(screenshot .. " windows"))
hl.bind("SUPER + SHIFT + bracketleft", hl.dsp.exec_cmd(screenshot .. " fullscreen"))
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

-- Cycle wallpaper on active display
local active_display = (hl.get_active_workspace() and hl.get_active_workspace().monitor.name) or "eDP-1"
hl.on("workspace.active", function(ws)
	if ws and ws.monitor then
		active_display = ws.monitor.name
	end
end)

hl.bind("SUPER + N", function()
	hl.exec_cmd(qs_ipc .. " wallpaper random " .. active_display)
end)

-- Win-tap toggles Noctalia bar (normal hide/show, fullscreen peek overlay)
local noctalia_is_overlay, bar_hidden = false, false

local function hide_fullscreen_bar()
	if noctalia_is_overlay then
		hl.exec_cmd(qs_ipc .. " bar hideFullscreenOverlay")
		if bar_hidden then
			hl.exec_cmd(qs_ipc .. " bar hideBar")
		end
		noctalia_is_overlay = false
	end
end

local function toggle_win_bar()
	local win = hl.get_active_window()
	local fs = win and win.fullscreen and win.fullscreen ~= 0 and win.fullscreen ~= "0"
	if fs then
		if noctalia_is_overlay then
			hide_fullscreen_bar()
		else
			if bar_hidden then
				hl.exec_cmd(qs_ipc .. " bar showBar")
			end
			hl.exec_cmd(qs_ipc .. " bar showFullscreenOverlay")
			noctalia_is_overlay = true
		end
	else
		hide_fullscreen_bar()
		bar_hidden = not bar_hidden
		hl.exec_cmd(qs_ipc .. " bar " .. (bar_hidden and "hideBar" or "showBar"))
	end
end

hl.on("window.fullscreen", hide_fullscreen_bar)
hl.bind("SUPER + SUPER_L", toggle_win_bar, { release = true })
