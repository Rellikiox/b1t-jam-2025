local Effects = require 'game.effects'

return {
	chain_lightning = {
		name = "chain lightning",
		description = "20% chance to chain damage to a nearby enemy. Repeats.",
		icon = "chain_lightning",
		on_successful_hit = function(position, combat)
			local should_chain = love.math.random() <= 0.2 + combat.extra_probability
			while should_chain do
				local enemies = combat.enemies:get_enemies_in_radius(position, 100)

				local enemy = enemies[1]
				if enemy then
					combat:kill_enemy(enemy)
					assets.sounds.shock:play()
					position = enemy.position
					should_chain = love.math.random() <= 0.2 + combat.extra_probability
				else
					should_chain = false
				end
			end
		end
	},
	wide_click = {
		name = 'wide click',
		description = 'increase the attack radius by 5 pixels.',
		icon = "wide_click",
		on_selected = function(combat)
			combat.attack_radius = combat.attack_radius + 5
		end,
	},
	echo = {
		name = 'echo',
		description = '10% change to repeat your attack on the next 10 beats',
		icon = "echo",
		on_successful_hit = function(position, combat)
			if love.math.random() <= 0.1 + combat.extra_probability then
				table.insert(combat.effects, Effects.Echo(position, combat.attack_radius))
			end
		end
	},
	riff = {
		name = 'riff',
		description = '50% chance to send out a bat-destroying riff.',
		icon = "riff",
		on_successful_hit = function(position, combat)
			if love.math.random() <= 0.50 + combat.extra_probability then
				table.insert(combat.effects, Effects.Riff(position, vec2.from_angle(love.math.random() * math.pi * 2)))
			end
		end
	},
	shield = {
		name = 'shield',
		description = 'prevent the next damage',
		icon = "shield",
		on_selected = function(combat)
			combat.shield = combat.shield + 1
		end
	},
	multinote = {
		name = 'Multinote',
		description = 'Attacks an additional enemy on every successful hit.',
		icon = "multinote",

		on_selected = function(combat)
			combat.attack_count = combat.attack_count + 1
		end
	},
	lucky = {
		name = 'lucky',
		description = '+5% to all probabilities',
		icon = "lucky",
		on_selected = function(combat)
			combat.extra_probability = combat.extra_probability + 0.05
		end
	},
	saving_grace = {
		name = 'saving grace',
		description = '50% change to prevent a misclick',
		icon = "saving_grace",
		on_failed_hit = function(combat)
			if love.math.random() <= 0.5 + combat.extra_probability then
				return false
			end
			return true
		end
	}
}
