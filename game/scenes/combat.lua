local Events = require 'engine.events'
local Enemy = require 'game.enemy'
local Particles = require 'game.particles'

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

local combat = {}

function combat:enter(previous, ...)
	local beat_sfx = assets.sounds.beat:clone()
	local half_beat_sfx = assets.sounds.beat:clone()
	half_beat_sfx:setPitch(0.5)
	half_beat_sfx:setVolume(0.5)
	self.metronome = Metronome(100, 10)

	Events:listen(self, 'beat', function()
		beat_sfx:play()
	end)

	self.successful_hits = 0

	self.hits_spritesheet = {}
	local spritesheet = assets.images.pips_spritesheet
	local quad_width = 72
	local quad_height = 20
	for i = 0, 10 do
		self.hits_spritesheet[i + 1] = love.graphics.newQuad(
			0, i * quad_height, quad_width, quad_height, spritesheet:getDimensions()
		)
	end

	self.enemies = Enemy.EnemyManager()
	self.enemies:spawn_enemy()

	self.particles = Particles()
end

function combat:update(delta)
	self.metronome:update(delta)
	self.enemies:update(delta)
	self.particles:update(delta)
end

function combat:leave(next, ...)
	Events:deregister(self)
end

function combat:draw()
	local text_width = love.graphics.getFont():getWidth(self.metronome.bpm)
	love.graphics.print(self.metronome.bpm, 20, 10)
	love.graphics.setLineWidth(1)

	love.graphics.draw(
		assets.images.pips_spritesheet, self.hits_spritesheet[self.successful_hits + 1],
		20 + text_width + 8, 22
	)

	love.graphics.print(self.metronome.bpm + 10, 145, 10)

	self.enemies:draw()
	self.particles:draw()
end

function combat:mousepressed(x, y, button)
	if button == 1 then
		local enemy_under_mouse = self.enemies:get_enemy_at(x, y)
		local on_beat = self.metronome:is_on_beat()
		if on_beat and enemy_under_mouse then
			-- play sound
			assets.sounds.successful_hit:play()
			self.successful_hits = self.successful_hits + 1
			if self.successful_hits == 10 then
				self.metronome:increase_bpm()
				self.successful_hits = 0
			end
			self.enemies:remove(enemy_under_mouse)
			self.particles:spawn(enemy_under_mouse.position, self.metronome.tempo_level)
		else
			assets.sounds.failed_hit:play()
			self.metronome:decrease_bpm()
			self.successful_hits = 0
		end
	elseif button == 2 then
		-- right click
	elseif button == 3 then
		-- middle click
	end
end

function combat:mousereleased(x, y, button)
end

function combat:mousemoved(x, y, dx, dy)
end

return combat
