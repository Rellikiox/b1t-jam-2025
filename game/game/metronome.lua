local Events = require 'engine.events'


local TempoColors = {
	Colors.Grass, Colors.Orange, Colors.Yellow, Colors.Pink, Colors.Red,
	Colors.Violet, Colors.Blue, Colors.Teal, Colors.Purple, Colors.Tan, Colors.White
}

local Metronome = Object:extend()

function Metronome:new(start_bmp, bpm_increase)
	self.bpm_increase = bpm_increase
	self.tempo_level = 1

	self.beat_timer = Timer {
		timeout = self.interval,
		callback = function()
			Events:send('beat')
		end
	}
	self.half_beat_timer = Timer {
		timeout = self.half_interval,
		callback = function()
			Events:send('half_beat')
		end
	}

	self:set_bpm(start_bmp)
end

function Metronome:increase_bpm()
	if self.tempo_level == 11 then
		return
	end
	self.tempo_level = self.tempo_level + 1
	self:set_bpm(self.bpm + self.bpm_increase)
	Events:send('tempo_up', self.tempo_level)
end

function Metronome:decrease_bpm()
	if self.tempo_level == 1 then
		return
	end
	self.tempo_level = self.tempo_level - 1
	self:set_bpm(self.bpm - self.bpm_increase)
	Events:send('tempo_down', self.tempo_level)
end

function Metronome:set_bpm(bpm)
	self.bpm = bpm
	self.interval = 60 / bpm
	self.half_interval = self.interval / 2
	self.beat_margin = self.interval / 6

	self.beat_timer.timeout = self.interval
	self.half_beat_timer.timeout = self.half_interval
	Pallete.Foreground = TempoColors[self.tempo_level]
end

function Metronome:update(delta)
	self.beat_timer:increment(delta)
	self.half_beat_timer:increment(delta)
end

function Metronome:is_on_beat()
	local to_beat = math.min(
		self.beat_timer.elapsed,
		math.abs(self.beat_timer.timeout - self.beat_timer.elapsed)
	)
	return to_beat < self.beat_margin
end

return Metronome
