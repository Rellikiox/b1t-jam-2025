local ui = require('engine.ui')
local combat_scene = require 'scenes.combat'
local Metronome = require 'game.metronome'
local Events = require 'engine.events'

local main_menu = {}

function main_menu:enter(previous, ...)
	self.metronome = Metronome(50, 10)
	self.ui = ui.UI {
		ui.CenteredColumn {
			width = game_size.x,
			height = game_size.y,
			alignment = ui.Align.Center,
			justify = ui.Justify.Center,
			separation = 20,
			ui.Label {
				text = 'Survive the Beat',
				style = {
					font = LargeFont,
				}
			},
			ui.Row {
				padding = ui.Padding(80)
			},
			ui.Button {
				text = '  summon the bats  ',
				style = {
					font = MediumFont,
				},
				on_pressed = function()
					scenes:enter(combat_scene)
					assets.sounds.successful_hit:play()
				end
			},
			ui.Button {
				text = '  surrender to the beat  ',
				style = {
					font = MediumFont,
				},
				on_pressed = function()
					love.event.push('quit')
					assets.sounds.failed_hit:play()
				end
			}
		}
	}

	self.play_button = self.ui.root.children[3]
	self.play_button_center = vec2 {
		self.play_button.x + self.play_button.width / 2,
		self.play_button.y + self.play_button.height / 2
	}

	Events:listen(self, 'beat', function()
		assets.sounds.beat:play()
	end)
end

function main_menu:update(delta)
	self.metronome:update(delta)
	self.ui:update(delta)
end

function main_menu:leave(next, ...)
	-- destroy entities and cleanup resources
end

function main_menu:draw()
	self.ui:draw()
end

function main_menu:mousemoved(x, y, dx, dy)
	local distance_to_button = self.play_button_center:distance(vec2 { x, y })
	local max_distance = game_size.x / 2
	self.metronome:set_bpm(
		lerp(100, 50, distance_to_button / max_distance)
	)
end

return main_menu
