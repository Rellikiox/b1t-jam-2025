--[[
	TODO
	- Fail state = heart takes damage > goes down one tempo level. If at 0, game over.
	- Game over = show score, show main menu button
	- More upgrades
]]

require 'globals'
assets = require('lib.cargo').init({
	dir = 'assets',
	processors = {
		['images/'] = function(image, filename)
			image:setFilter('nearest', 'nearest')
		end
	}
})
local Coroutines = require 'engine.coroutines'
scenes = require('lib.roomy').new()
local main_menu_scene = require 'scenes.main_menu'


function love.load()
	love.mouse.setVisible(false)

	HugeFont = love.graphics.newFont('assets/fonts/antiquity-print.ttf', 52, 'mono')
	LargeFont = love.graphics.newFont('assets/fonts/antiquity-print.ttf', 39, 'mono')
	MediumFont = love.graphics.newFont('assets/fonts/antiquity-print.ttf', 26, 'mono')
	SmallFont = love.graphics.newFont('assets/fonts/antiquity-print.ttf', 13, 'mono')

	love.graphics.setBackgroundColor(unpack(Pallete.Background:to_array()))

	game_size = vec2 { 1280, 720 }

	scenes:hook({ exclude = { 'draw' } })
	scenes:enter(main_menu_scene)
end

function love.update(delta)
	Coroutines:update(delta)
end

function love.draw()
	love.graphics.setBackgroundColor(unpack(Pallete.Background:to_array()))
	Pallete.Foreground:set()

	scenes:emit('draw')
end
