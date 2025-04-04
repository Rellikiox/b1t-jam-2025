local Events = require 'engine.events'
local Enemy = require 'game.enemy'
local Particles = require 'game.particles'
local Metronome = require 'game.metronome'
local ui = require 'engine.ui'

local combat = {}

function combat:enter(previous, ...)
	self.state = 'combat'

	self.metronome = Metronome(100, 10)

	Events:listen(self, 'beat', function()
		assets.sounds.beat:play()
	end)

	self.successful_hits = 0

	self.hits_spritesheet = {}
	local spritesheet = assets.images.pips_spritesheet
	local quad_width = 72
	local quad_height = 20
	for i = 0, 10 do
		self.hits_spritesheet[i + 1] = love.graphics.newQuad(
			0, i * quad_height, quad_width, quad_height, spritesheet:getDimensions()
		)
	end

	self.enemies = Enemy.EnemyManager()
	self.enemies:spawn_enemy()

	self.particles = Particles()
	self.tempo_bar_filling = 0
	self.tempo_bar_filled = 0

	self.upgrades = {}
	self.upgrade_ui = nil
end

function combat:update(delta)
	self.metronome:update(delta)
	if self.state == 'combat' then
		self.enemies:update(delta)
		self.particles:update(delta)
	elseif self.state == 'upgrade' then
		self.upgrade_ui:update(delta)
	end
	self.tempo_bar_filling = self.successful_hits / 10
	self.tempo_bar_filled = lerp(self.tempo_bar_filled, self.tempo_bar_filling, 0.08)
end

function combat:leave(next, ...)
	Events:deregister(self)
end

function combat:draw()
	self.enemies:draw()
	self.particles:draw()

	-- top bar
	local start_x = love.graphics.getWidth() / 2 - 312
	local start_y = 30
	love.graphics.draw(assets.images.xp_frame, start_x, start_y, 0, 2, 2)

	local function get_stencil_for(percentage)
		return function()
			love.graphics.rectangle(
				'fill',
				start_x,
				start_y,
				624 * percentage,
				60
			)
		end
	end
	love.graphics.stencil(get_stencil_for(self.tempo_bar_filling), 'replace', 1)
	love.graphics.setStencilTest('greater', 0)
	love.graphics.draw(assets.images.xp_frame_filling, start_x, start_y, 0, 2, 2)

	love.graphics.stencil(get_stencil_for(self.tempo_bar_filled), 'replace', 1)
	love.graphics.setStencilTest('greater', 0)
	love.graphics.draw(assets.images.xp_frame_filled, start_x, start_y, 0, 2, 2)

	love.graphics.setStencilTest()

	if self.state == 'upgrade' then
		self.upgrade_ui:draw()
	end
end

function combat:mousepressed(x, y, button)
	if button == 1 then
		local point = vec2 { x, y }
		local enemy_under_mouse = self.enemies:get_enemies_in_radius(point, 30)
		local on_beat = self.metronome:is_on_beat()
		if on_beat and #enemy_under_mouse > 0 then
			assets.sounds.successful_hit:play()
			self.enemies:remove(enemy_under_mouse[1])
			self.particles:spawn(enemy_under_mouse[1].position, self.metronome.tempo_level)
			for upgrade, _ in pairs(self.upgrades) do
				if upgrade.on_successful_hit then
					upgrade:on_successful_hit(enemy_under_mouse[1].position, self)
				end
			end

			self.successful_hits = self.successful_hits + 1
			if self.successful_hits == 10 then
				self:set_state('upgrade')
			end
		else
			assets.sounds.failed_hit:play()
			self.successful_hits = 0
		end
	elseif button == 2 then
		if self.state == 'combat' then
			self:set_state('upgrade')
		end
	elseif button == 3 then
		-- middle click
	end
end

function combat:mousereleased(x, y, button)
end

function combat:mousemoved(x, y, dx, dy)

end

function combat:set_state(state)
	if state == 'combat' then
		self.state = 'combat'
		self.upgrade_ui.visible = false
	elseif state == 'upgrade' then
		self.state = 'upgrade'
		local available_upgrades = {}
		for upgrade_name, _ in pairs(assets.data.upgrades) do
			table.insert(available_upgrades, upgrade_name)
		end
		table.shuffle(available_upgrades)

		local buttons = {}
		for i = 1, 3 do
			local upgrade_name = available_upgrades[i]
			local upgrade = assets.data.upgrades[upgrade_name]

			table.insert(buttons, ui.Button {
				text = upgrade.name,
				style = {
					font = MediumFont,
				},
				on_pressed = function()
					if self.upgrades[upgrade_name] then
						self.upgrades[upgrade_name].level = self.upgrades[upgrade_name].level + 1
					else
						self.upgrades[upgrade_name] = table.shallow_copy(assets.data.upgrades[upgrade_name])
					end

					self:set_state('combat')

					self.metronome:increase_bpm()
					self.successful_hits = 0
				end,
				on_hover_enter = function()
					self.upgrade_ui.root.children[3] = ui.Label {
						text = upgrade.description,
						justify = ui.Justify.Center,
						align = ui.Align.Center,
						style = {
							font = SmallFont,
						}
					}
					self.upgrade_ui.root:calculate_layout()
				end,
				on_hover_exit = function()
					self.upgrade_ui.root.children[3].text = ''
				end
			})
		end


		self.upgrade_ui = ui.UI {
			ui.CenteredColumn {
				width = game_size.x,
				height = game_size.y,
				separation = 20,
				ui.Label {
					text = 'Choose your boon...',
					style = {
						font = MediumFont,
					}
				},
				ui.Row {
					separation = 20,
					buttons[1],
					buttons[2],
					buttons[3],
				},
				ui.Label {
					text = ''
				}
			}
		}
	end
end

return combat
