local Events = require 'engine.events'
local Enemy = require 'game.enemy'

local Metronome = Object:extend()

function Metronome:new(bpm)
	self.bpm = bpm
	self.interval = 60 / bpm
	self.half_interval = self.interval / 2

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
end

function Metronome:set_bpm(bpm)
	self.bpm = bpm
	self.interval = 60 / bpm
	self.half_interval = self.interval / 2
	self.beat_timer.timeout = self.interval
	self.half_beat_timer.timeout = self.half_interval
end

function Metronome:update(delta)
	self.beat_timer:increment(delta)
	self.half_beat_timer:increment(delta)
end

function Metronome:time_to_beat()
	return math.min(
		self.beat_timer.elapsed,
		math.abs(self.beat_timer.timeout - self.beat_timer.elapsed)
	)
end

local combat = {}

function combat:enter(previous, ...)
	local beat_sfx = assets.sounds.beat:clone()
	local half_beat_sfx = assets.sounds.beat:clone()
	half_beat_sfx:setPitch(0.5)
	half_beat_sfx:setVolume(0.5)
	self.metronome = Metronome(100)

	Events:listen(self, 'beat', function()
		beat_sfx:play()
	end)


	self.successful_hits = 0

	self.hits_spritesheet = {}
	local spritesheet = assets.images.pips_spritesheet
	local quad_width = 18
	local quad_height = 5
	for i = 0, 10 do
		self.hits_spritesheet[i + 1] = love.graphics.newQuad(
			0, i * quad_height, quad_width, quad_height, spritesheet:getDimensions()
		)
	end

	self.enemies = Enemy.EnemyManager()
	self.enemies:spawn_enemy()
end

function combat:update(delta)
	self.metronome:update(delta)
	self.enemies:update(delta)
end

function combat:leave(next, ...)
	Events:deregister(self)
end

function combat:draw()
	Pallete.Light:set()
	local text_width = love.graphics.getFont():getWidth(self.metronome.bpm)
	love.graphics.print(self.metronome.bpm, 5, 2)
	love.graphics.setLineWidth(1)

	love.graphics.draw(
		assets.images.pips_spritesheet, self.hits_spritesheet[self.successful_hits + 1],
		5 + text_width + 2, 7
	)

	love.graphics.print(self.metronome.bpm + 10, 39, 2)

	self.enemies:draw()
end

function combat:mousepressed(x, y, button)
	if button == 1 then
		local x, y = screen:getMousePosition()
		local enemy_under_mouse = self.enemies:get_enemy_at(x, y)
		local on_beat = self.metronome:time_to_beat() < 0.2
		if on_beat and enemy_under_mouse then
			-- play sound
			assets.sounds.successful_hit:play()
			self.successful_hits = self.successful_hits + 1
			if self.successful_hits == 10 then
				self.metronome:set_bpm(self.metronome.bpm + 10)
				self.successful_hits = 0
			end
			self.enemies:remove(enemy_under_mouse)
		else
			assets.sounds.failed_hit:play()
			self.metronome:set_bpm(100)
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
