local Coroutines = {
	coroutines = {}
}

function Coroutines:start(fn)
	local co = coroutine.create(fn)
	self.coroutines[co] = true
	coroutine.resume_with_traceback(co, 0)
	return co
end

function Coroutines:update(dt)
	for co in pairs(self.coroutines) do
		if coroutine.status(co) == "dead" then
			self.coroutines[co] = nil
		else
			local success, err = coroutine.resume_with_traceback(co, dt)
			if not success then
				print("Coroutine error:", err)
				self.coroutines[co] = nil
			end
		end
	end
end

function Coroutines:stop(co)
	self.coroutines[co] = nil
end

return Coroutines
