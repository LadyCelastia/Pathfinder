local PathWrapper = require(script:WaitForChild("PathWrapper"))
local Chaser = require(script:WaitForChild("Chaser"))
local Walker = require(script:WaitForChild("Walker"))

local DefaultParas = {
	WaypointSpacing = 1000,
	AgentCanClimb = true,
	AgentCanJump = true,
  Costs = {},
}

local Pathfinder = {}

Pathfinder.AttachWalker = function(Character: Model, Path): boolean
	if Character and PathWrapper then
		local Hum = Character:FindFirstChildOfClass("Humanoid")
		local RootPart: BasePart = Character:FindFirstChild("HumanoidRootPart")
		if Hum and RootPart then
			Walker.new({
				Humanoid = Hum,
				Root = RootPart,
				PathWrapper = Path
			})
			return true
		end
	end
	return false
end

Pathfinder.AttachChaser = function(Character: Model, Target: BasePart, Path): boolean
	if Character and Target and PathWrapper then
		local Root: BasePart = Character:FindFirstChild("HumanoidRootPart")
		if Root then
			Chaser.new({
				Target = Target,
				Origin = Root,
				PathWrapper = Path
			})
			return true
		end
	end
	return false
end

Pathfinder.ToPoint = function(Character: Model, Point: Vector3, Paras)
	local Root: BasePart = Character:FindFirstChild("HumanoidRootPart")
	if Root then
		local ParasToUse = Paras or DefaultParas
		ParasToUse.AgentHeight = Root.Size.Y * 2.5
		ParasToUse.AgentRadius = Root.Size.X
		local newPath = PathWrapper.new({
			Start = Root.Position,
			Finish = Point,
			Parameters = ParasToUse
		})
		Pathfinder.AttachWalker(Character, newPath)
		return newPath
	end
end

Pathfinder.ToPart = function(Character: Model, Part: BasePart, Paras)
	local Root: BasePart = Character:FindFirstChild("HumanoidRootPart")
	if Root then
		local ParasToUse = Paras or DefaultParas
		--[[
		ParasToUse.AgentHeight = Root.Size.Y * 2.5
		ParasToUse.AgentRadius = Root.Size.X
		--]]
		local newPath = PathWrapper.new({
			Start = Root.Position,
			Finish = Part.Position,
			Parameters = ParasToUse
		})
		Pathfinder.AttachWalker(Character, newPath)
		Pathfinder.AttachChaser(Character, Part, newPath)
		newPath:ComputeAsync()
		return newPath
	end
end

Pathfinder.ToCharacter = function(Character: Model, Target: Model, Paras)
	local TargetRoot: BasePart = Target:FindFirstChild("HumanoidRootPart")
	if TargetRoot then
		return Pathfinder.ToPart(Character, TargetRoot, Paras)
	end
end

return Pathfinder
