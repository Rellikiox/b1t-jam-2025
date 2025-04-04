local Events = require 'engine.events'

local Enemy = Object:extend()

function Enemy:new(args)
	self.speed = 60
	self.position = args.position
	self.target_position = args.position
	self.direction = (game_size / 2 - self.position):normalized()
	self.next_position = self:get_next_position()
	self.frames = args.frames
	self.frame = 1
	self.move_step = 1
	self.beat_needs_update = true
end

function Enemy:get_next_position()
	return self.target_position + self.direction * self.speed
end

function Enemy:on_half_beat()
	self.frame = math.fmod(self.frame + 1, 2)
end

function Enemy:on_beat()
	self.beat_needs_update = true
end

function Enemy:update(delta)
	self.position = exp_smoothing(self.position, self.target_position, 3, delta)
	if self.beat_needs_update then
		self.move_step = self.move_step + 1
		if self.move_step > 3 then
			self.move_step = 1
			self.target_position = self.next_position
			self.next_position = self:get_next_position()
		end
		self.beat_needs_update = false
	end
end

function Enemy:draw()
	love.graphics.draw(
		assets.images.bat,
		self.frames[self.frame + 1],
		self.position.x - 16,
		self.position.y - 8
	)
end

local EnemyManager = Object:extend()

function EnemyManager:new()
	self.next_spawn_in = 0
	self.spawn_interval = 1

	self.enemies = {}
	Events:listen(self, 'beat', function(args)
		for _, enemy in ipairs(self.enemies) do
			enemy:on_beat()
		end
		if self.next_spawn_in <= 0 then
			self:spawn_enemy()
			self.next_spawn_in = self.next_spawn_in + self.spawn_interval
		else
			self.next_spawn_in = self.next_spawn_in - 1
		end
	end)
	Events:listen(self, 'half_beat', function(args)
		for _, enemy in ipairs(self.enemies) do
			enemy:on_half_beat()
		end
	end)
	Events:listen(self, 'tempo_up', function(tempo_level)
		self.spawn_interval = self.spawn_interval - 0.07
		for i = 1, 10 do
			self:spawn_enemy()
		end
	end)
	Events:listen(self, 'tempo_down', function(tempo_level)
		self.spawn_interval = self.spawn_interval + 0.07
	end)

	self.bat_frames = {
		love.graphics.newQuad(0, 0, 32, 16, 32, 32),
		love.graphics.newQuad(0, 16, 32, 16, 32, 32)
	}
	for i = 1, 10 do
		self:spawn_enemy()
	end
end

function EnemyManager:spawn_enemy()
	local radius = (game_size / 2):length()
	local position = vec2.from_angle(math.random() * math.pi * 2) * radius +
		game_size / 2
	local enemy = Enemy {
		position = position,
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

function EnemyManager:get_enemies_in_radius(point, radius)
	local enemies = {}
	for _, enemy in ipairs(self.enemies) do
		if enemy.position:distance(point) < radius then
			table.insert(enemies, enemy)
		end
	end
	return enemies
end

return {
	Enemy = Enemy,
	EnemyManager = EnemyManager,
}
