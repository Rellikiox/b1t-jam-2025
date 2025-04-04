local Effect = Object:extend()

function Effect:new()
end

function Effect:update(delta)
end

function Effect:draw()
end

local Riff = Effect:extend()

function Riff:new(position, direction)
	self.position = position
	self.direction = direction
	self.speed = 100
	self.angle = self.direction:angle() + math.pi / 4
	self.dead = false
end

function Riff:update(delta)
	self.position = self.position + self.direction * self.speed * delta
end

function Riff:on_beat(combat)
	local enemies = combat.enemies:get_enemies_in_radius(self.position + self.direction * 8, 30)
	if #enemies >= 1 then
		combat:kill_enemy(enemies[1])
		self.dead = true
	end
end

function Riff:draw()
	love.graphics.draw(assets.images.riff_effect, self.position.x + 64, self.position.y - 96, self.angle, 1, 1, -0, -64)
end

return {
	Riff = Riff
}
