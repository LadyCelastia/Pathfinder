local pathfinder = require(script:WaitForChild("Pathfinder")
local char = workspace.Dummy
local selfHum = char:FindFirstChildOfClass("Humanoid")
local enemy = workspace.Enemy

local newPath = pathfinder.ToCharacter(character, enemy) -- be VERY careful, this is asynchronous
if not newPath.HasPath then -- pathfind can fail if there is no walkable path to the target
  repeat
    task.wait(1)
    newPath:Compute()
  until newPath.HasPath
end
selfHum:MoveTo(newPath:GetNextWaypoint().Position)
