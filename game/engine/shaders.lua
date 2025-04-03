--[[
Public domain:

Copyright (C) 2017 by Matthias Richter <vrld@vrld.org>

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
]] --

local shader = love.graphics.newShader [[
	  extern vec2 distortion_factor;
	  extern vec2 scale_factor;
	  extern number feather;

	  vec4 effect(vec4 color, Image tex, vec2 uv, vec2 px) {
		// to barrel coordinates
		uv = uv * 2.0 - vec2(1.0);

		// distort
		uv *= scale_factor;
		uv += (uv.yx*uv.yx) * uv * (distortion_factor - 1.0);
		number mask = (1.0 - smoothstep(1.0-feather,1.0,abs(uv.x)))
					* (1.0 - smoothstep(1.0-feather,1.0,abs(uv.y)));

		// to cartesian coordinates
		uv = (uv + vec2(1.0)) / 2.0;

		return color * Texel(tex, uv) * mask;
	  }
	]]
shader:send("distortion_factor", { 1.06, 1.065 })
shader:send("feather", 0.02)
shader:send("scale_factor", { 1, 1 })
return shader
