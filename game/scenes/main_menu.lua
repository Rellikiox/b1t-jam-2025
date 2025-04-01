local main_menu = {}

function main_menu:enter(previous, ...)
	-- set up the level
end

function main_menu:update(dt)
	-- update entities
end

function main_menu:leave(next, ...)
	-- destroy entities and cleanup resources
end

function main_menu:draw()
	-- draw the level
end

return main_menu
