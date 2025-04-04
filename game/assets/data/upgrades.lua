return {
	forgiving_beat = {
		name = "Forgiving Beat",
		description = "Negates the next ({level}) failed hit(s). Refreshes every 5 successful hits. ",
		icon = "assets/data/upgrades/forgiving_beat.png",
		level = 1
	},
	chain_reaction = {
		name = "Chain Reaction",
		description = "Every 5 successful hits, atttack {level} closest target(s).",
		icon = "assets/data/upgrades/chain_reaction.png",
		counter = 0,
		level = 1,
		on_successful_hit = function(self, position, combat)
			self.counter = self.counter + 1
			if self.counter == 5 then
				self.counter = 0
				local enemies = combat.enemies:get_enemies_in_radius(position, 100)
				for i = 1, math.min(self.level, #enemies) do
					local enemy = enemies[i]
					if enemy then
						combat.enemies:remove(enemy)
						combat.particles:spawn(enemy.position, combat.metronome.tempo_level)
					end
				end
			end
		end
	},
	beat_shield = {
		name = "Beat Shield",
		description = "Every 10 successful hits, gain a shield that negates the next enemy collision.",
		icon = "assets/data/upgrades/beat_shield.png",
		counter = 0,
		level = 1,
		on_successful_hit = function(self, position, combat)

		end
	},
	wide_click = {
		name = 'Wide Click',
		description = 'Increase the attack radius by 5 pixels.',
		level = 1,
		on_selected = function(self, combat)
			combat.attack_radius = combat.attack_radius + 5
		end,
	}
}
