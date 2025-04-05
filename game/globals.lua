Object = require 'lib.classic'
require 'engine.vec2'
require 'engine.utils'
local ui = require 'engine.ui'
local Color = require 'engine.color'
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

Pallettes = {
	Red = {
		Dark = Color.from_hex('#3e232c'),
		Light = Color.from_hex('#edf6d6'),
	}
}

Colors = {
	Black = Color.from_hex('#28282e'),
	Purple = Color.from_hex('#6c5671'),
	Tan = Color.from_hex('#d9c8bf'),
	Red = Color.from_hex('#f98284'),
	Violet = Color.from_hex('#b0a9e4'),
	Blue = Color.from_hex('#accce4'),
	Teal = Color.from_hex('#b3e3da'),
	Pink = Color.from_hex('#feaae4'),
	Forest = Color.from_hex('#87a889'),
	Grass = Color.from_hex('#b0eb93'),
	Olive = Color.from_hex('#e9f59d'),
	Peach = Color.from_hex('#ffe6c6'),
	Brown = Color.from_hex('#dea38b'),
	Orange = Color.from_hex('#ffc384'),
	Yellow = Color.from_hex('#fff7a0'),
	White = Color.from_hex('#fff7e4'),
	FullWhite = Color.from_hex('#ffffff')
}

Pallete = {
	Background = Colors.Black,
	Foreground = Colors.Grass,
}


function Button(args)
	local prev_color = Pallete.Foreground
	return ui.Button {
		text = args.text,
		style = {
			font = MediumFont,
		},
		on_pressed = function()
			assets.sounds.successful_hit:play()
			args.on_pressed()
		end,
		on_hover_enter = function()
			prev_color = Pallete.Foreground
			Pallete.Foreground = args.hover_color
			assets.sounds.successful_hit:play()
		end,
		on_hover_exit = function()
			Pallete.Foreground = prev_color
		end
	}
end
