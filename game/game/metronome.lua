local Events = require 'engine.events'


local TempoColors = {
	Colors.Grass, Colors.Orange, Colors.Yellow, Colors.Red, Colors.Pink,
	Colors.Violet, Colors.Blue, Colors.Teal, Colors.Tan, Colors.White
}

local Metronome = Object:extend()

function Metronome:new(start_bpm, bpm_increase, song_data)
	self.bpm_increase = bpm_increase
	self.tempo_level = 1
	self.beat_sfx = assets.sounds.beat:clone()

	self.beat_timer = Timer {
		timeout = self.interval,
		callback = function()
			self.beat_sfx:play()

			Events:send('beat')
		end
	}
	self.half_beat_timer = Timer {
		timeout = self.half_interval,
		callback = function()
			Events:send('half_beat')
		end
	}

	self.song_data = song_data
	self.song = assets.sounds.songs[self.song_data.path]
	self.song:setLooping(true)
	self.song:setVolume(0.1)

	self:set_bpm(start_bpm)
	love.audio.setEffect('other_room', { type = 'reverb', airabsorption = 0.998 })
	love.audio.setEffect('other_room', false)

	self.low_pass = false
end

function Metronome:change_song(song_data)
	self.song_data = song_data
	self.song:stop()
	self.song = assets.sounds.songs[song_data.path]
	self.song:setLooping(true)
	self.song:setVolume(0.1)
	self.song:setPitch(self.bpm / song_data.bpm)
	self.song:play()
	self.beat_timer.elapsed = 0
	self.half_beat_timer.elapsed = 0
	if self.low_pass then
		self:set_low_pass_filter_enabled(true)
	end
end

function Metronome:play()
	self.song:play()
end

function Metronome:stop()
	self.song:stop()
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

	self.song:setPitch(self.bpm / self.song_data.bpm)

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

function Metronome:set_low_pass_filter_enabled(enabled)
	self.low_pass = enabled
	if enabled then
		self.song:setFilter({
			type     = "lowpass",
			volume   = 0.5,
			highgain = .6,
		})
		self.song:setEffect('other_room')
		self.beat_sfx:setVolume(0.2)
		self.beat_sfx:setEffect('other_room')
	else
		self.song:setFilter()
		self.beat_sfx:setFilter()
		self.beat_sfx:setVolume(1)
		love.audio.setEffect('other_room', false)
	end
end

return Metronome
