local Functions = require(script.Parent:WaitForChild("Functions"))

local Chaser = {}
Chaser.__index = Chaser

Chaser.new = function(Configs: {[string]: any})
	local self = setmetatable({}, Chaser)
	
	self.PathWrapper = Configs["PathWrapper"]
	self.Target = Configs["Target"] :: BasePart
	self.Origin = Configs["Origin"] :: BasePart
	
	self.PathWrapper.Chaser = self
	
	return self
end

function Chaser:UpdateAsync()
	if self.Target and self.Origin then
		if self.Target.Parent == nil or self.Origin.Parent == nil or self.PathWrapper.Destroyed == true then
			local success, _ = pcall(function()
				self.PathWrapper:Destroy()
			end)
			if success ~= true then
				self:Destroy()
			end
		else
			local different = false
			if self.Target.Position ~= self.PathWrapper.Finish then
				different = true
			end
			self.PathWrapper.Finish = self.Target.Position
			self.PathWrapper.Start = self.Origin.Position
			if different then
				local success = self.PathWrapper:ComputeAsync(true)
				--[[
				if not success and not self.Destroyed then
					self:Destroy()
				end
				--]]
			end
		end
	end
end

function Chaser:Destroy()
	Functions.GarbageCollect(self)
end

return Chaser
