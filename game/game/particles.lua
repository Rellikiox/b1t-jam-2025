local Particles = Object:extend()

function Particles:new()
	self.particles = {}
	self.particle_lifetime = 0.5
	self.particle_speed = 200
	self.quads = {
		love.graphics.newQuad(0, 0, 16, 16, 32, 32),
		love.graphics.newQuad(16, 0, 16, 16, 32, 32),
		love.graphics.newQuad(0, 16, 16, 16, 32, 32),
		love.graphics.newQuad(16, 16, 16, 16, 32, 32),
	}
end

function Particles:spawn(position, intensity)
	for i = 1, 3 * intensity do
		local particle = {
			position = position,
			lifetime = self.particle_lifetime * intensity,
			speed = self.particle_speed * intensity,
			scale = math.random() * 0.2 + 0.9,
			direction = vec2.from_angle(math.random() * math.pi * 2):normalized(),
			quad = self.quads[math.random(#self.quads)],
			rotation = math.random() * math.pi * 2
		}
		table.insert(self.particles, particle)
	end
end

function Particles:update(delta)
	for i = #self.particles, 1, -1 do
		local particle = self.particles[i]
		particle.lifetime = particle.lifetime - delta
		if particle.scale < 0.1 then
			table.remove(self.particles, i)
		elseif particle.lifetime <= 0 then
			particle.scale = particle.scale * 0.999
		else
			particle.speed = particle.speed * 0.9
			particle.position = particle.position + particle.direction * particle.speed * delta
		end
	end
end

function Particles:draw()
	for _, particle in ipairs(self.particles) do
		love.graphics.draw(
			assets.images.particles,
			particle.quad,
			particle.position.x, particle.position.y,
			particle.rotation, particle.scale, particle.scale,
			8, 8
		)
	end
end

return Particles
