local ui = require('engine.ui')
local combat_scene = require 'scenes.combat'
local Metronome = require 'game.metronome'
local Events = require 'engine.events'

local main_menu = {}

function main_menu:enter(previous, ...)
	self.metronome = Metronome(100, 10, {
		path = "Three_Red_Hearts-Sanctuary",
		bpm = 150,
		name = "Three Red Hearts - Sanctuary",
	})
	self.metronome:play()
	self.metronome:set_low_pass_filter_enabled(true)

	Pallete.Foreground = Colors.Tan

	local set_difficulty_text = function(ui_node, difficulty)
		local data = assets.data.difficulty[difficulty]
		ui_node.children[7].text = data.bpm .. ' bpm ( +' .. data.bpm_increase .. ' bpm per level )'
		ui_node.children[8].text = 'kill ' .. data.kills_per_level .. ' bats times the current level to satisfy the beat'
		ui_node.children[9].text = 'starts with ' .. data.starting_upgrades .. ' boons'
		local text = 'nothing happens if you misclick'
		if data.resets_on_fails then
			text = 'kills reset on misclicks'
		end
		ui_node.children[10].text = text
		ui_node:calculate_layout()
	end

	local reset_difficulty_text = function(ui_node)
		ui_node.children[7].text = ''
		ui_node.children[8].text = ''
		ui_node.children[9].text = ''
		ui_node.children[10].text = ''
	end

	self.ui = ui.UI {
		ui.CenteredColumn {
			width = game_size.x,
			height = game_size.y,
			alignment = ui.Align.Center,
			justify = ui.Justify.Center,
			separation = 10,
			ui.Label {
				text = 'does a mere human dare enter the',
				style = {
					font = SmallFont,
				}
			},
			ui.Label {
				text = '~ realm of the bat ~',
				style = {
					font = HugeFont,
				}
			},
			ui.Row {
				padding = ui.Padding(20)
			},
			ui.Label {
				text = '  choose your fate...  ',
				style = {
					font = MediumFont,
				}
			},
			ui.Row {
				separation = 10,
				Button({
					text = '  calm  ',
					on_pressed = function()
						scenes:push(combat_scene, 'calm')
						self.metronome:stop()
					end,
					hover_color = Colors.Grass,
					on_hover_enter = function()
						set_difficulty_text(self.ui.root, 'calm')
					end,
					on_hover_exit = function()
						reset_difficulty_text(self.ui.root)
					end
				}),
				Button {
					text = ' frenzy ',
					on_pressed = function()
						scenes:push(combat_scene, 'frenzy')
						self.metronome:stop()
					end,
					hover_color = Colors.Yellow,
					on_hover_enter = function()
						set_difficulty_text(self.ui.root, 'frenzy')
					end,
					on_hover_exit = function()
						reset_difficulty_text(self.ui.root)
					end
				},
				Button {
					text = ' bloodlust ',
					on_pressed = function()
						scenes:push(combat_scene, 'bloodlust')
						self.metronome:stop()
					end,
					hover_color = Colors.Red,
					on_hover_enter = function()
						set_difficulty_text(self.ui.root, 'bloodlust')
					end,
					on_hover_exit = function()
						reset_difficulty_text(self.ui.root)
					end
				},
			},
			ui.Label {
				text = '',
				style = {
					font = SmallFont,
				}
			},
			ui.Label {
				text = '',
				style = {
					font = SmallFont,
				}
			},
			ui.Label {
				text = '',
				style = {
					font = SmallFont,
				}
			},
			ui.Label {
				text = '',
				style = {
					font = SmallFont,
				}
			},
			ui.Row {
				padding = ui.Padding(10)
			},
			ui.Button {
				text = '  abbandon the beat  ',
				style = {
					font = MediumFont,
				},
				on_pressed = function()
					love.event.push('quit')
					assets.sounds.failed_hit:play()
				end,
				on_hover_enter = function()
					assets.sounds.successful_hit:play()
					Pallete.Foreground = Colors.Purple
				end,
				on_hover_exit = function()
					Pallete.Foreground = Colors.Tan
				end
			},
			ui.Label {
				text = 'Music by Abstraction https://abstractionmusic.com/',
				style = {
					font = SmallFont,
				}
			},
		}
	}

	self.play_button = self.ui.root.children[3]
	self.play_button_center = vec2 {
		self.play_button.x + self.play_button.width / 2,
		self.play_button.y + self.play_button.height / 2
	}
end

function main_menu:update(delta)
	self.ui:update(delta)
end

function main_menu:leave(next, ...)
	-- destroy entities and cleanup resources
end

function main_menu:draw()
	self.ui:draw()

	local x, y = love.mouse.getPosition()
	love.graphics.draw(assets.images.cursor, x + 2, y)
end

function main_menu:mousemoved(x, y, dx, dy)
end

return main_menu
