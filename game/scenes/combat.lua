local combat = {}

function combat:enter(previous, ...)
end

function combat:update(delta)
end

function combat:leave(next, ...)
	-- destroy entities and cleanup resources
end

function combat:draw()
end

function combat:mousepressed(x, y, button)
end

function combat:mousereleased(x, y, button)
end

function combat:mousemoved(x, y, dx, dy)
end

return combat
