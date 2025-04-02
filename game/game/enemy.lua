local Events = require 'engine.events'

local Enemy = Object:extend()

function Enemy:new(args)
	self.speed = 15
	self.position = args.position
	self.target_position = args.position
	self.direction = (game_size / 2 - self.position):normalized()
	self.next_position = self:get_next_position()
	self.frames = args.frames
	self.frame = 1
	self.move_step = 1
end

function Enemy:get_next_position()
	return self.target_position + self.direction * self.speed
end

function Enemy:on_half_beat()
	self.frame = math.fmod(self.frame + 1, 2)
end

function Enemy:on_beat()
	self.move_step = self.move_step + 1
	if self.move_step > 3 then
		self.move_step = 1
		self.target_position = self.next_position
		self.next_position = self:get_next_position()
	end
end

function Enemy:update(delta)
	self.position = exp_smoothing(self.position, self.target_position, 3, delta)
end

function Enemy:draw()
	love.graphics.draw(
		assets.images.bat,
		self.frames[self.frame + 1],
		self.position.x - 4,
		self.position.y - 2,
		0, 1, 1,
		4, 2
	)
	local move_preview_start = self.position + self.direction * 2
	love.graphics.line(move_preview_start.x, move_preview_start.y, self.next_position.x, self.next_position.y)
end

local EnemyManager = Object:extend()

function EnemyManager:new()
	self.enemies = {}
	Events:listen(self, 'beat', function(args)
		for _, enemy in ipairs(self.enemies) do
			enemy:on_beat()
		end
	end)
	Events:listen(self, 'half_beat', function(args)
		for _, enemy in ipairs(self.enemies) do
			enemy:on_half_beat()
		end
	end)

	self.bat_frames = {
		love.graphics.newQuad(0, 0, 8, 4, 8, 8),
		love.graphics.newQuad(0, 4, 8, 4, 8, 8)
	}
end

function EnemyManager:spawn_enemy()
	local enemy = Enemy {
		position = vec2 { 100, 100 },
		frames = self.bat_frames,
	}
	table.insert(self.enemies, enemy)
end

function EnemyManager:draw()
	for _, enemy in ipairs(self.enemies) do
		enemy:draw()
	end
end

function EnemyManager:update(delta)
	for _, enemy in ipairs(self.enemies) do
		enemy:update(delta)
	end
end

function EnemyManager:remove(enemy)
	for i, e in ipairs(self.enemies) do
		if e == enemy then
			table.remove(self.enemies, i)
			break
		end
	end
end

function EnemyManager:get_enemy_at(x, y)
	local point = vec2 { x, y }
	for _, enemy in ipairs(self.enemies) do
		if enemy.position:distance(point) < 8 then
			return enemy
		end
	end
	return nil
end

return {
	Enemy = Enemy,
	EnemyManager = EnemyManager,
}
