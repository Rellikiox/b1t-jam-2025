local Physics = Object:extend()

function Physics:new()
	self.world = love.physics.newWorld(0, 0, true)
	self.world:setCallbacks(
		function(fixture_a, fixture_b, contact)
			local a = fixture_a:getUserData()
			local b = fixture_b:getUserData()
		end,
		nil,
		nil,
		nil
	)
end

return Physics
