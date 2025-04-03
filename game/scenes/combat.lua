local Events = require 'engine.events'
local Enemy = require 'game.enemy'
local Particles = require 'game.particles'
local Metronome = require 'game.metronome'

local combat = {}

function combat:enter(previous, ...)
	self.metronome = Metronome(100, 10)

	Events:listen(self, 'beat', function()
		assets.sounds.beat:play()
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
	self.tempo_bar_filling = 0
	self.tempo_bar_filled = 0
end

function combat:update(delta)
	self.metronome:update(delta)
	self.enemies:update(delta)
	self.particles:update(delta)

	self.tempo_bar_filling = self.successful_hits / 10
	self.tempo_bar_filled = lerp(self.tempo_bar_filled, self.tempo_bar_filling, 0.08)
end

function combat:leave(next, ...)
	Events:deregister(self)
end

function combat:draw()
	self.enemies:draw()
	self.particles:draw()

	-- top bar
	local start_x = love.graphics.getWidth() / 2 - 312
	local start_y = 30
	love.graphics.draw(assets.images.xp_frame, start_x, start_y, 0, 2, 2)

	local function get_stencil_for(percentage)
		return function()
			love.graphics.rectangle(
				'fill',
				start_x,
				start_y,
				624 * percentage,
				60
			)
		end
	end
	love.graphics.stencil(get_stencil_for(self.tempo_bar_filling), 'replace', 1)
	love.graphics.setStencilTest('greater', 0)
	love.graphics.draw(assets.images.xp_frame_filling, start_x, start_y, 0, 2, 2)

	love.graphics.stencil(get_stencil_for(self.tempo_bar_filled), 'replace', 1)
	love.graphics.setStencilTest('greater', 0)
	love.graphics.draw(assets.images.xp_frame_filled, start_x, start_y, 0, 2, 2)

	love.graphics.setStencilTest()
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
			if self.successful_hits == 0 then
				self.metronome:decrease_bpm()
			end
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
