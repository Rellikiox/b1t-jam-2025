Object = require 'lib.classic'
require 'engine.vec2'
require 'engine.utils'
Settings = require 'settings'
local Tween = require('lib.tween')
local Coroutines = require 'engine.coroutines'

function coro_tween(tweens)
	Coroutines:start(function()
		for _, tween_data in ipairs(tweens) do
			local tween = Tween.new(unpack(tween_data))
			local complete = false
			while not complete do
				local delta = coroutine.yield()
				complete = tween:update(delta)
			end
		end
	end)
end
