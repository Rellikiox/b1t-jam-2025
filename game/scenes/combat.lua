local Events = require 'engine.events'
local Enemy = require 'game.enemy'
local Particles = require 'game.particles'
local Metronome = require 'game.metronome'
local ui = require 'engine.ui'
local Effects = require 'game.effects'

local stencil_shader = love.graphics.newShader([[
extern vec4 color;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords);
    if (pixel.a == 0.0) {
        discard; // Skip fully transparent pixels
    }
    return pixel * color;
}
]])

local combat = {}

function combat:enter(previous, ...)
	self.state = 'combat'

	self.metronome = Metronome(100, 10)

	Events:listen(self, 'beat', function()
		assets.sounds.beat:play()

		if self.state == 'combat' then
			for _, effect in ipairs(self.effects) do
				effect:on_beat(self)
			end
		end
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

	self.dots_canvas = love.graphics.newCanvas(game_size.x, game_size.y)
	self.dots_canvas:renderTo(function()
		for x = 1, game_size.x, 10 do
			for y = 1, game_size.y, 10 do
				local px = x + math.random() * 4
				local py = y + math.random() * 4
				love.graphics.circle('fill', px, py, 2)
			end
		end
	end)
	self.attack_radius = 30

	self.effects = {}
	self:spawn_riff(vec2 { game_size.x / 2, game_size.y / 2 })
end

function combat:kill_enemy(enemy)
	self.enemies:remove(enemy)
	self.particles:spawn(enemy.position, self.metronome.tempo_level)
end

function combat:update(delta)
	self.metronome:update(delta)
	if self.state == 'combat' then
		self.enemies:update(delta)
		self.particles:update(delta)
		for i = #self.effects, 1, -1 do
			local effect = self.effects[i]
			effect:update(delta)
			if not is_point_in_rect(effect.position, vec2 { -100, -100 }, game_size + vec2 { 200, 200 }) then
				table.remove(self.effects, i)
			end
		end
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
	love.graphics.draw(assets.images.heart, game_size.x / 2 - 32, game_size.y / 2 - 32)

	love.graphics.setShader(stencil_shader)
	love.graphics.stencil(function()
		love.graphics.setLineWidth(self.attack_radius / 2)
		love.graphics.circle('line', love.mouse.getX(), love.mouse.getY(), self.attack_radius / 2)
		love.graphics.setLineWidth(1)

		for _, effect in ipairs(self.effects) do
			effect:draw()
		end
	end)
	love.graphics.setShader()

	love.graphics.setStencilTest('greater', 0)
	love.graphics.draw(self.dots_canvas, 0, 0)

	love.graphics.setStencilTest()

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

	local x, y = love.mouse.getPosition()
	if self.state == 'upgrade' then
		self.upgrade_ui:draw()
		love.graphics.draw(assets.images.cursor, x + 2, y)
	end

	start_x = love.graphics.getWidth() / 2 - 312
	start_y = 70
	for index, upgrade in ipairs(self.upgrades) do
		local icon = assets.images.upgrades[upgrade.icon]
		love.graphics.draw(icon, start_x + index * 40, start_y, 0, 1, 1, -10, -10)
	end
end

function combat:mousepressed(x, y, button)
	if self.state == 'upgrade' then
		return
	end

	if button == 1 then
		local point = vec2 { x, y }
		local enemy_under_mouse = self.enemies:get_enemies_in_radius(point, self.attack_radius)
		local on_beat = self.metronome:is_on_beat()
		if on_beat and #enemy_under_mouse > 0 then
			assets.sounds.successful_hit:play()
			self:kill_enemy(enemy_under_mouse[1])
			for _, upgrade in ipairs(self.upgrades) do
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
		self:spawn_riff(vec2 { love.mouse.getPosition() })
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
					local upgrade = table.shallow_copy(assets.data.upgrades[upgrade_name])
					table.insert(self.upgrades, upgrade)

					if upgrade.on_selected then
						upgrade:on_selected(self)
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

function combat:spawn_riff(position)
	table.insert(self.effects, Effects.Riff(position, vec2.from_angle(math.random() * math.pi * 2)))
end

return combat
