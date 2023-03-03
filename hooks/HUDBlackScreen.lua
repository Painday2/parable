-- Kill the blackscreen display stuff.
function HUDBlackScreen:_set_job_data() end
function HUDBlackScreen:set_loading_text_status()
	self._blackscreen_panel:child("loading_text"):set_visible(false)
	self._blackscreen_panel:child("skip_text"):set_visible(false)
end