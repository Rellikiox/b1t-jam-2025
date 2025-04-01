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
local scenes = require('lib.roomy').new()
local combat_scene = require 'scenes.combat'
local Terebi = require "lib.terebi"

function love.load()
	local font = love.graphics.newFont('assets/fonts/m3x6.ttf', 16, 'mono')
	love.graphics.setFont(font)


	game_size = vec2 { 320, 240 }
	Terebi.initializeLoveDefaults()
	screen = Terebi.newScreen(game_size.x, game_size.y, 4)

	--

	love.graphics.setBackgroundColor(unpack(Pallete.Dark:to_array()))

	scenes:hook({ exclude = { 'draw' } })
	scenes:enter(combat_scene)
end

function love.update(delta)
	Coroutines:update(delta)
end

function love.draw()
	screen:draw(function()
		scenes:emit('draw')
	end)
end
