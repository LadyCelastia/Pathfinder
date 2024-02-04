local Functions = require(script.Parent:WaitForChild("Functions"))

local Walker = {}
Walker.__index = Walker

Walker.new = function(Configs: {[string]: any})
	local self = setmetatable({}, Walker)
	
	self.PathWrapper = Configs["PathWrapper"]
	self.Humanoid = Configs["Humanoid"] :: Humanoid
	self.Root = Configs["Root"] :: BasePart
	self.Connection = self.Humanoid.MoveToFinished:Connect(function(goalReached)
		if goalReached then
			self:MoveToNextWaypoint()
		else
			warn("Trying to unstuck")
			local success = self.PathWrapper:ComputeAsync()
			--[[
			if not success and not self.Destroyed then
				self:Destroy()
			end
			--]]
		end
	end)
	
	self.PathWrapper.Walker = self
	
	return self
end

function Walker:MoveToNextWaypoint()
	if self.PathWrapper:HasNextWaypoint() then
		local nextWaypoint: PathWaypoint = self.PathWrapper:GetNextWaypoint()
		self.Humanoid:MoveTo(nextWaypoint.Position)
		if nextWaypoint.Action == Enum.PathWaypointAction.Jump then
			self.Humanoid.Jump = true
		end
		self.PathWrapper.NextWaypoint += 1
		self.PathWrapper.Completed = false
	else
		self.PathWrapper.Completed = true
	end
end

function Walker:IsAtWaypoint()
	local currentWaypoint: PathWaypoint = self.PathWrapper:GetNextWaypoint()
	if currentWaypoint and self.Root then
		local planePos = Vector3.new(currentWaypoint.Position.X, 0, currentWaypoint.Position.Z)
		local rootPos = Vector3.new(self.Root.Position.X, 0, self.Root.Position.Z)
		if (planePos - rootPos).Magnitude < 1.5 and math.abs(currentWaypoint.Position.Y - self.Root.Position.Y) < 5.5 then
			return true
		end
		return false
	end
	return false
end

function Walker:Update()
	if self.Humanoid and self.Root then
		local nextWaypoint = self.PathWrapper:GetNextWaypoint()
		if nextWaypoint then
			self.PathWrapper.Completed = false
			self.Humanoid:MoveTo(nextWaypoint.Position)
			--[[
		else
			warn("No next waypoint for walker.")
		--]]
		end
		if self:IsAtWaypoint() then
			self:MoveToNextWaypoint()
		end
	end
end

function Walker:Destroy()
	Functions.GarbageCollect(self)
end

return Walker
