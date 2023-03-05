ParableLoadingScreenGuiScript = ParableLoadingScreenGuiScript or class()

local prefix = "PAIN IS ALWAYS IN PAIN IS ALWAYS IN PAIN IS ALWAYS IN PAIN IS ALWAYS IN PAIN IS "
local middle = "LOADING"
local suffix = " ALWAYS IN PAIN IN PAIN IS ALWAYS IN PAIN"

local size = 72
local offset = {
	x = 80,
	y = 58
}

function ParableLoadingScreenGuiScript:init(scene_gui, resolution, progress, base_layer, is_win32)
	self._base_layer = base_layer
	self._is_win32 = is_win32
	self._scene_gui = scene_gui
	self._resolution = resolution
	self._workspace = scene_gui:create_screen_workspace()

	if _G.IS_VR then
		self._workspace:set_pinned_screen(true)
	end

	self._fullrect = self._scene_gui:create_screen_workspace()
	self:layout_fullrect()

	local panel = self._workspace:panel()
	self._panel = panel
	self._background_gui = panel:rect({
		visible = true,
		color = Color.black,
		layer = base_layer
	})

	self._fullrect_panel = self._fullrect:panel()

	self._prefix_text = self._fullrect_panel:text({
		font_size = size,
		align = "right",
		font = "fonts/font_large_mf",
		color = Color.white:with_alpha(0.25),
		layer = self._base_layer + 1,
		text = prefix
	})

	self._middle_text = self._fullrect_panel:text({
		font_size = size,
		align = "center",
		font = "fonts/font_large_mf",
		color = Color.white,
		layer = self._base_layer + 1,
		text = middle
	})

	self._suffix_text = self._fullrect_panel:text({
		font_size = size,
		align = "left",
		font = "fonts/font_large_mf",
		color = Color.white:with_alpha(0.25),
		layer = self._base_layer + 1,
		text = suffix
	})

	self._loading_bar_border = self._fullrect_panel:rect({
		color = Color.white,
		layer = self._base_layer + 1
	})

	self._loading_bar_bg = self._fullrect_panel:rect({
		color = Color.black,
		layer = self._base_layer + 2
	})

	self._loading_max_width = 100 - 16
	self._loading_bar = self._fullrect_panel:rect({
		color = Color.white,
		layer = self._base_layer + 3
	})


	self._init_progress = 0
	self._fake_progress = 0

	self:setup(progress)
end

function ParableLoadingScreenGuiScript:layout_fullrect()
	local base_height = 720

	local aspect_ratio = self._resolution.x / self._resolution.y
	local fullrect_w = base_height * aspect_ratio
	local fullrect_h = base_height

	self._fullrect:set_screen(fullrect_w, fullrect_h, 0, 0, self._resolution.x)
end

local function text_sizer(text)
	local _, _, w, h = text:text_rect()
	text:set_size(w, h)
end

function ParableLoadingScreenGuiScript:setup(progress)
	text_sizer(self._middle_text)
	text_sizer(self._prefix_text)
	text_sizer(self._suffix_text)

	self._middle_text:set_rightbottom(self._fullrect_panel:right() - offset.x, self._fullrect_panel:bottom() - offset.y)
	local loading_text_x, loading_text_y, loading_text_w, loading_text_h = self._middle_text:text_rect()

	self._prefix_text:set_top(loading_text_y)
	self._prefix_text:set_right(loading_text_x)

	self._suffix_text:set_top(loading_text_y)
	self._suffix_text:set_left(loading_text_x + loading_text_w)

	self._loading_bar_border:set_position(loading_text_x, loading_text_y + loading_text_h - 5)
	self._loading_bar_border:set_size(loading_text_w, 36)

	self._loading_bar_bg:set_position(loading_text_x + 3, loading_text_y + loading_text_h - 2)
	self._loading_bar_bg:set_size(loading_text_w - 6, 36 - 6)

	self._loading_bar:set_position(loading_text_x + 6, loading_text_y + loading_text_h + 1)
	self._loading_max_width = loading_text_w - 12
	self._loading_bar:set_size(self._loading_max_width * (progress/100), 36 - 12)

	self._background_gui:set_size(self._resolution.x, self._resolution.y)

	if progress > 0 then
		self._init_progress = progress
	end
end

function ParableLoadingScreenGuiScript:update(progress, dt)
	if self._init_progress < 100 and progress == -1 then
		self._fake_progress = self._fake_progress + 0.2 * dt

		if self._fake_progress > 100 then
			self._fake_progress = 100
		end

		self._loading_bar:set_width((self._fake_progress / 100) * self._loading_max_width)

		progress = self._fake_progress
	end
end

function ParableLoadingScreenGuiScript:set_text(text)
end

function ParableLoadingScreenGuiScript:destroy()
	if alive(self._workspace) then
		self._scene_gui:destroy_workspace(self._workspace)
		self._scene_gui:destroy_workspace(self._fullrect)

		self._workspace = nil
		self._fullrect = nil
	end
end

function ParableLoadingScreenGuiScript:visible()
	return self._workspace:visible()
end

function ParableLoadingScreenGuiScript:set_visible(visible, resolution)
	if resolution then
		self._resolution = resolution

		self:layout_fullrect()
		self:setup(-1)
	end

	if visible then
		if _G.IS_VR then
			return
		end

		self._workspace:show()
		self._fullrect:show()
	else
		self._workspace:hide()
		self._fullrect:hide()
	end
end

if LightLoadingScreenGuiScript then
	LightLoadingScreenGuiScript = ParableLoadingScreenGuiScript
end

if LevelLoadingScreenGuiScript then
	LevelLoadingScreenGuiScript = ParableLoadingScreenGuiScript
end