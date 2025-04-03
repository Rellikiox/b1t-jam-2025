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

function love.load()
	local font = love.graphics.newFont('assets/fonts/m3x6.ttf', 48, 'mono')
	love.graphics.setFont(font)
	love.graphics.setBackgroundColor(unpack(Pallete.Background:to_array()))

	game_size = vec2 { 1280, 720 }

	scenes:hook({ exclude = { 'draw' } })
	scenes:enter(combat_scene)
end

function love.update(delta)
	Coroutines:update(delta)
end

function love.draw()
	love.graphics.setBackgroundColor(unpack(Pallete.Background:to_array()))
	Pallete.Foreground:set()

	scenes:emit('draw')
end
