local SpatialHash = Object:extend()

function SpatialHash:new(size)
	self.size = size or 100
	self.cells = {}
	self.objects = {}
end

function SpatialHash:add(object)
	local cell_key = self:cell_key(object.position)

	if not self.cells[cell_key] then
		self.cells[cell_key] = {}
	end

	table.insert(self.cells[cell_key], object)
	self.objects[object] = cell_key
end

function SpatialHash:update(object)
	local old_cell_key = self.objects[object]
	local new_cell_key = self:cell_key(object.position)

	if old_cell_key ~= new_cell_key then
		-- Remove from old cell
		for i, obj in ipairs(self.cells[old_cell_key]) do
			if obj == object then
				table.remove(self.cells[old_cell_key], i)
				break
			end
		end

		-- Add to new cell
		if not self.cells[new_cell_key] then
			self.cells[new_cell_key] = {}
		end

		table.insert(self.cells[new_cell_key], object)
		self.objects[object] = new_cell_key
	end
end

function SpatialHash:cell_key(position)
	local cell_x = math.floor(position.x / self.size)
	local cell_y = math.floor(position.y / self.size)
	return string.format("%d,%d", cell_x, cell_y)
end

function SpatialHash:query_radius(position, radius)
	if table.len(self.objects) == 1 then
		return {}
	end

	local cell_x = math.floor(position.x / self.size)
	local cell_y = math.floor(position.y / self.size)

	local cell_delta = math.ceil(radius / self.size)
	local results = {}
	for dx = -cell_delta, cell_delta do
		for dy = -cell_delta, cell_delta do
			local cell_key = string.format("%d,%d", cell_x + dx, cell_y + dy)
			if self.cells[cell_key] then
				for _, object in ipairs(self.cells[cell_key]) do
					if object.position:distance(position) <= radius then
						table.insert(results, object)
					end
				end
			end
		end
	end

	return results
end

return SpatialHash
