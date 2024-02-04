local PathfindingService = game:GetService("PathfindingService")
local Functions = require(script.Parent:WaitForChild("Functions"))

local PathWrapper = {}
PathWrapper.__index = PathWrapper

PathWrapper.new = function(Configs: {[string]: any})
	local self = setmetatable({}, PathWrapper)
	
	self.HasPath = false :: boolean
	self.Completed = false :: boolean
	self.Path = PathfindingService:CreatePath(Configs["Parameters"]) :: Path
	self.NextWaypoint = 2 :: number
	self.Start = Configs["Start"] :: Vector3
	self.Finish = Configs["Finish"] :: Vector3
	self.Waypoints = {} :: {PathWaypoint}
	self.Connection = self.Path.Blocked:Connect(function(waypointIndex)
		if waypointIndex >= self.NextWaypoint then
			warn("Path blocked")
			self.HasPath = false
			self:ComputeAsync()
		end
	end)
	
	return self
end

function PathWrapper:HasNextWaypoint(): boolean
	return #self.Waypoints >= self.NextWaypoint
end

function PathWrapper:GetNextWaypoint(): PathWaypoint
	if #self.Waypoints >= self.NextWaypoint then
		return self.Waypoints[self.NextWaypoint]
	end
end

function PathWrapper:GetCurrentWaypoint(): PathWaypoint
	if (self.NextWaypoint - 1) >= 1 and #self.Waypoints >= (self.NextWaypoint - 1) then
		return self.Waypoints[self.NextWaypoint - 1]
	end
end

function PathWrapper:GetNearestWaypoint(Position: Vector3): PathWaypoint & number
	local closest, dist = nil, math.huge
	for _,v: PathWaypoint in ipairs(self.Waypoints) do
		local newDist = (v.Position - Position).Magnitude
		if newDist < dist then
			closest = v
			dist = newDist
		end
	end
	return closest, dist
end

function PathWrapper:UpdateAsync(): boolean
	if self.HasPath then
		local integral = true
		if self.Walker and not self.Walker.Destroyed then
			self.Walker:Update()
		else
			warn("Walker not valid", self.Walker)
			integral = false
		end
		if self.Chaser and not self.Chaser.Destroyed then
			self.Chaser:UpdateAsync()
		else
			warn("Chaser not valid", self.Chaser)
			integral = false
		end
		if not integral then
			warn("Caught delay in update")
			if table.isfrozen(self) then
				self:Destroy()
			end
			return false
		end
		return true
	end
end

function PathWrapper:ComputeAsync(supressUpdate: boolean): boolean
	self.Path:ComputeAsync(self.Start, self.Finish)
	if self.Path then
		if self.Path.Status == Enum.PathStatus.NoPath or self.Path.Status == Enum.PathStatus.FailStartNotEmpty or self.Path.Status == Enum.PathStatus.FailFinishNotEmpty then
			self.HasPath = false
			return false
		else
			self.HasPath = true
			self.Waypoints = self.Path:GetWaypoints()
			self.NextWaypoint = 2
			if not supressUpdate then
				self:UpdateAsync()
			end
		end
		return true
		--[[
	else
		error("Caught async delay", 0) -- This error is more like a duct tape fix for stopping a memory leak, ignore it]]
	end
	return false
end

function PathWrapper:Destroy()
	if self.Walker and not self.Walker.Destroyed then
		self.Walker:Destroy()
	end
	if self.Chaser and not self.Chaser.Destroyed then
		self.Chaser:Destroy()
	end
	Functions.GarbageCollect(self)
end

return PathWrapper
