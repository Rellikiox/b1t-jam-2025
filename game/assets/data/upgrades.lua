return {
	chain_lightning = {
		name = "Chain Lightning",
		description = "10% chance to chain damage to a nearby enemy. Repeats.",
		icon = "chain_lightning",
		on_successful_hit = function(self, position, combat)
			local should_chain = math.random() < 0.1
			while should_chain do
				local enemies = combat.enemies:get_enemies_in_radius(position, 100)

				local enemy = enemies[1]
				if enemy then
					combat:kill_enemy(enemy)
					position = enemy.position
					should_chain = math.random() < 0.1
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
	riff = {
		name = 'Riff',
		description = '15% chance to send out a bat-destroying riff.',
		icon = "riff",
		on_successful_hit = function(self, position, combat)
			if math.random() <= 0.15 then
				combat:spawn_riff(position)
			end
		end
	}
}
