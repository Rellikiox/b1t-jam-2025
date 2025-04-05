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

local Clearout = Effect:extend()

function Clearout:new(position, radius, combat)
	self.position = position
	self.radius = radius
	self.combat = combat
	self.dead = false
end

function Clearout:update(delta)
	local enemies = self.combat.enemies:get_enemies_in_radius(self.position, self.radius)
	for _, enemy in ipairs(enemies) do
		self.combat.enemies:remove(enemy)
	end
	self.dead = true
end

local Echo = Effect:extend()

function Echo:new(position, radius)
	self.position = position
	self.radius = radius
	self.dead = false
end

function Echo:on_beat(combat)
	combat:perform_attack(self.position, true)
	self.dead = true
end

function Echo:draw()
	love.graphics.circle('line', self.position.x, self.position.y, self.radius)
end

return {
	Riff = Riff, Clearout = Clearout, Echo = Echo,
}
