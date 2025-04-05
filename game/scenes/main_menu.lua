local ui = require('engine.ui')
local combat_scene = require 'scenes.combat'
local Metronome = require 'game.metronome'
local Events = require 'engine.events'

local main_menu = {}

function main_menu:enter(previous, ...)
	self.metronome = Metronome(100, 10, assets.data.difficulty.insane.songs[1])
	self.metronome:play()
	self.metronome:set_low_pass_filter_enabled(true)

	Pallete.Foreground = Colors.Tan

	self.ui = ui.UI {
		ui.CenteredColumn {
			width = game_size.x,
			height = game_size.y,
			alignment = ui.Align.Center,
			justify = ui.Justify.Center,
			separation = 10,
			ui.Label {
				text = 'does a mere human dare to',
				style = {
					font = SmallFont,
				}
			},
			ui.Label {
				text = 'enter the realm of the bat and',
				style = {
					font = MediumFont,
				}
			},
			ui.Label {
				text = 'Survive the Beat',
				style = {
					font = HugeFont,
				}
			},
			ui.Row {
				padding = ui.Padding(40)
			},
			ui.Label {
				text = '  summon the bats...  ',
				style = {
					font = MediumFont,
				}
			},
			ui.Row {
				separation = 10,
				ui.Button {
					text = ' easy ',
					style = {
						font = MediumFont,
					},
					on_pressed = function()
						scenes:enter(combat_scene, 'easy')
						self.metronome:stop()
						assets.sounds.successful_hit:play()
					end,
					on_hover_enter = function()
						assets.sounds.successful_hit:play()
						Pallete.Foreground = Colors.Grass
					end,
					on_hover_exit = function()
						Pallete.Foreground = Colors.Tan
					end
				},
				ui.Button {
					text = ' medium ',
					style = {
						font = MediumFont,
					},
					on_pressed = function()
						scenes:enter(combat_scene, 'medium')
						self.metronome:stop()
						assets.sounds.successful_hit:play()
					end,
					on_hover_enter = function()
						assets.sounds.successful_hit:play()
						Pallete.Foreground = Colors.Yellow
					end,
					on_hover_exit = function()
						Pallete.Foreground = Colors.Tan
					end
				},
				ui.Button {
					text = ' hard ',
					style = {
						font = MediumFont,
					},
					on_pressed = function()
						scenes:enter(combat_scene, 'hard')
						self.metronome:stop()
						assets.sounds.successful_hit:play()
					end,
					on_hover_enter = function()
						assets.sounds.successful_hit:play()
						Pallete.Foreground = Colors.Orange
					end,
					on_hover_exit = function()
						Pallete.Foreground = Colors.Tan
					end
				},
				ui.Button {
					text = ' insane ',
					style = {
						font = MediumFont,
					},
					on_pressed = function()
						scenes:enter(combat_scene, 'insane')
						self.metronome:stop()
						assets.sounds.successful_hit:play()
					end,
					on_hover_enter = function()
						assets.sounds.successful_hit:play()
						Pallete.Foreground = Colors.Red
					end,
					on_hover_exit = function()
						Pallete.Foreground = Colors.Tan
					end
				},
			},
			ui.Row {
				padding = ui.Padding(30)
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
