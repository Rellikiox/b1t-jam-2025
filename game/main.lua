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
local combat_scene = require('scenes.combat')

function love.load()
	love.graphics.setBackgroundColor(0.2, 0.2, 0.2)

	scenes:hook()
	scenes:enter(combat_scene)
end

function love.update(delta)
	Coroutines:update(delta)
end
