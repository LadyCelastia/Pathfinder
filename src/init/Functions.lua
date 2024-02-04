local module = {}

module.RecursiveClean = function(t, destroy: boolean)
	for _,v in pairs(t) do
		if typeof(v) == "RBXScriptConnection" then
			v:Disconnect()
		elseif typeof(v) == "Instance" then
			if destroy then
				v:Destroy()
			end
		--[[
		elseif typeof(v) == "table" and getmetatable(v) == nil then
			module.RecursiveClean(v)
		--]]
		end
	end
	table.clear(t)
	t.Destroyed = true
	table.freeze(t)
end

module.GarbageCollect = function(t, destroy: boolean)
	setmetatable(t, nil)
	module.RecursiveClean(t, destroy)
end

module.GetClosestPointOnBlock = function(Block: BasePart, Origin: Vector3)
	local transform = Block.CFrame:PointToObjectSpace(Origin)
	local halfSize = Block.Size * 0.5
	return Block.CFrame * Vector3.new(
		math.clamp(transform.X, -halfSize.X, halfSize.X),
		math.clamp(transform.Y, -halfSize.Y, halfSize.Y),
		math.clamp(transform.Z, -halfSize.Z, halfSize.Z)
	)
end

return module
