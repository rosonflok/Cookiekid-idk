local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local function setupAnimations(character: Model)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid

	-- Disable Animate if present
	local animate = character:FindFirstChild("Animate")
	if animate and animate:IsA("LocalScript") then
		animate.Disabled = true
	end

	-- Ensure Animator exists (modern approach)
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Name = "Animator"
		animator.Parent = humanoid
	end

	-- Load custom animations
	local idleAnim = Instance.new("Animation")
	idleAnim.AnimationId = "rbxassetid://18885903667"

	local moveAnim = Instance.new("Animation")
	moveAnim.AnimationId = "rbxassetid://18885906143"

	local idleTrack = animator:LoadAnimation(idleAnim)
	local moveTrack = animator:LoadAnimation(moveAnim)

	idleTrack.Priority = Enum.AnimationPriority.Action
	moveTrack.Priority = Enum.AnimationPriority.Movement

	idleTrack:Play()

	RunService.Heartbeat:Connect(function()
		local speed = humanoid.MoveDirection.Magnitude

		-- Stop other idle animations (defensive)
		for _, track in humanoid:GetPlayingAnimationTracks() do
			local id = track.Animation and track.Animation.AnimationId or ""
			if id ~= idleAnim.AnimationId and id ~= moveAnim.AnimationId then
				if track.Priority == Enum.AnimationPriority.Core or track.Name == "idle" or id:lower():find("idle") then
					track:Stop()
				end
			end
		end

		-- Transition between idle and move
		if speed > 0.01 then
			if not moveTrack.IsPlaying then
				idleTrack:Stop()
				moveTrack:Play()
			end
		else
			if not idleTrack.IsPlaying then
				moveTrack:Stop()
				idleTrack:Play()
			end
		end
	end)
end

-- Run for current character
if player.Character then
	setupAnimations(player.Character)
end

-- Handle new characters
player.CharacterAdded:Connect(setupAnimations)
