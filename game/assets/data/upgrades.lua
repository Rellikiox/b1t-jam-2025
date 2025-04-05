return {
	chain_lightning = {
		name = "Chain Lightning",
		description = "20% chance to chain damage to a nearby enemy. Repeats.",
		icon = "chain_lightning",
		on_successful_hit = function(self, position, combat)
			local should_chain = math.random() < 0.2
			while should_chain do
				local enemies = combat.enemies:get_enemies_in_radius(position, 100)

				local enemy = enemies[1]
				if enemy then
					combat:kill_enemy(enemy)
					assets.sounds.shock:play()
					position = enemy.position
					should_chain = math.random() < 0.2
				else
					should_chain = false
				end
			end
		end
	},
	wide_click = {
		name = 'Wide Click',
		description = 'Increase the attack radius by 5 pixels.',
		icon = "wide_click",
		on_selected = function(self, combat)
			combat.attack_radius = combat.attack_radius + 5
		end,
	},
	wide_click = {
		name = 'Wide Click',
		description = 'Increase the attack radius by 5 pixels.',
		icon = "wide_click",
		on_selected = function(self, combat)
			combat.attack_radius = combat.attack_radius + 5
		end,
	},
	echo = {
		name = 'Echo',
		description = '10% change to repeat your attack on the next beat',
		icon = "echo",
		on_successful_hit = function(self, position, combat)
			if math.random() <= 0.1 then
				combat:spawn_echo(position)
			end
		end
	},
	riff = {
		name = 'Riff',
		description = '50% chance to send out a bat-destroying riff.',
		icon = "riff",
		on_successful_hit = function(self, position, combat)
			if math.random() <= 0.50 then
				combat:spawn_riff(position)
			end
		end
	},
	shield = {
		name = 'Shield',
		description = 'Prevent the next damage',
		icon = "shield",
		on_selected = function(self, combat)
			combat.shield = combat.shield + 1
		end
	},
	mutinote = {
		name = 'Multinote',
		description = 'Attacks an additional enemy on every successful hit.',
		icon = "multinote",

		on_selected = function(self, combat)
			combat.attack_count = combat.attack_count + 1
		end
	},
}
