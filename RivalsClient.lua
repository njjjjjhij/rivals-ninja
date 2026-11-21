--[[
	Ninja  /  Rivals
	Single-file aimbot + ESP interface for Roblox Rivals.
	Built for Delta on phone and PC.

	Execute:
		loadstring(game:HttpGet("https://raw.githubusercontent.com/njjjjjhij/rivals-ninja/main/RivalsClient.lua"))()

	Tap the round ninja icon to hide or show the interface.
	Insert toggles the interface, RightShift unloads it.
	Tap a feature name to enable it, tap + beside it for its settings.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StatsService = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
	return
end

if _G.NinjaRivals and typeof(_G.NinjaRivals) == "table" and _G.NinjaRivals.destroy then
	pcall(_G.NinjaRivals.destroy)
end

local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local SCALE = IS_MOBILE and 0.86 or 1

local function px(value)
	return math.floor(value * SCALE + 0.5)
end

local Theme = {
	panel = Color3.fromRGB(13, 17, 20),
	panelDeep = Color3.fromRGB(9, 12, 14),
	row = Color3.fromRGB(18, 23, 26),
	rowHover = Color3.fromRGB(29, 36, 40),
	rowActive = Color3.fromRGB(34, 44, 48),
	separator = Color3.fromRGB(30, 37, 41),
	stroke = Color3.fromRGB(44, 54, 60),
	accent = Color3.fromRGB(96, 232, 222),
	accentDark = Color3.fromRGB(40, 170, 162),
	text = Color3.fromRGB(234, 242, 244),
	textDim = Color3.fromRGB(142, 156, 162),
	textMuted = Color3.fromRGB(94, 108, 114),
	dark = Color3.fromRGB(8, 14, 16),
	good = Color3.fromRGB(86, 226, 140),
	bad = Color3.fromRGB(240, 82, 96),
}

local Metrics = {
	width = 178,
	header = 24,
	row = 24,
}

local Config = {
	aimbot = {
		enabled = false,
		mode = "Always",
		fov = 150,
		smooth = 18,
		turn = 720,
		prediction = 0,
		jitter = 0,
		deadzone = 0,
		part = "Head",
		wall = true,
		team = false,
		sticky = true,
		instant = false,
		firstPerson = true,
		showFov = true,
		autoFire = false,
		autoScope = false,
		hitMarker = true,
		killNotify = true,
		targetHud = true,
	},
	rage = {
		enabled = false,
		fov = 180,
		prediction = 12,
		part = "Head",
		wall = true,
		team = false,
		sticky = true,
		autoFire = false,
	},
	trigger = {
		enabled = false,
		range = 150,
		delay = 80,
		team = false,
	},
	skin = {
		enabled = false,
		color = "Cyan",
		material = "Neon",
		rainbow = false,
	},
	esp = {
		enabled = true,
		box = true,
		fill = false,
		health = true,
		name = true,
		distance = true,
		tracer = false,
		chams = false,
		maxDist = 600,
		team = false,
		hideKnocked = true,
		skeleton = true,
		headDot = true,
		arrows = false,
		pickups = false,
	},
	visual = {
		fullbright = false,
		noFog = false,
		crosshair = true,
		crosshairSize = 9,
		watermark = true,
		clock = true,
		playerCount = true,
	},
	move = {
		speed = false,
		speedValue = 26,
		jump = false,
		jumpValue = 75,
		infiniteJump = false,
		autoJump = false,
		fly = false,
		flySpeed = 60,
		noclip = false,
		fov = false,
		fovValue = 90,
	},
}

local function create(class, props, parent)
	local object = Instance.new(class)
	if props then
		for key, value in pairs(props) do
			object[key] = value
		end
	end
	if parent then
		object.Parent = parent
	end
	return object
end

local function isPrimary(input)
	local kind = input.UserInputType
	return kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch
end

local function viewport()
	local camera = workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end
	return Vector2.new(1280, 720)
end

local function sameTeam(player)
	if not player.Team or not LocalPlayer.Team then
		return false
	end
	return player.Team == LocalPlayer.Team
end

local function getCharacter(player)
	local character = player.Character
	if not character then
		local found = workspace:FindFirstChild(player.Name)
		if found and found:FindFirstChildOfClass("Humanoid") then
			character = found
		end
	end
	if not character then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart", true)
	local head = character:FindFirstChild("Head", true)
	if not root or not head then
		return nil
	end
	return character, humanoid, root, head
end

local KNOCK_NAMES = { "Knocked", "knocked", "Downed", "downed", "IsKnocked", "IsDowned" }

local function isKnocked(player, character, humanoid)
	if humanoid and humanoid.Health <= 0 then
		return true
	end
	for _, name in ipairs(KNOCK_NAMES) do
		if character:GetAttribute(name) == true or player:GetAttribute(name) == true then
			return true
		end
	end
	return false
end

local DRAW_OK = false
do
	local ok = pcall(function()
		local probe = Drawing.new("Square")
		probe:Remove()
	end)
	DRAW_OK = ok
end

local function newDrawing(class)
	if not DRAW_OK then
		return nil
	end
	local ok, object = pcall(function()
		return Drawing.new(class)
	end)
	if ok then
		return object
	end
	return nil
end

local function hideDrawing(object)
	if object then
		object.Visible = false
	end
end

local function removeDrawing(object)
	if object and object.Remove then
		pcall(function()
			object:Remove()
		end)
	end
end

local function setSquare(object, position, size, color, thickness, transparency, filled)
	if not object then
		return
	end
	object.Position = position
	object.Size = size
	object.Color = color
	object.Thickness = thickness
	object.Transparency = transparency
	object.Filled = filled
	object.Visible = true
end

local function setText(object, text, position, color, size)
	if not object then
		return
	end
	object.Text = text
	object.Position = position
	object.Color = color
	object.Size = size
	object.Center = true
	object.Outline = true
	object.OutlineColor = Color3.fromRGB(0, 0, 0)
	object.Visible = true
end

local function setLine(object, from, to, color, thickness, transparency)
	if not object then
		return
	end
	object.From = from
	object.To = to
	object.Color = color
	object.Thickness = thickness or 1
	object.Transparency = transparency or 0.1
	object.Visible = true
end

--------------------------------------------------------------------------
-- Target maths
--------------------------------------------------------------------------

local function screenRadius(camera, fov)
	local size = camera.ViewportSize
	local halfFov = math.rad(math.clamp(fov, 1, 179.5)) * 0.5
	local halfCamera = math.rad(math.clamp(camera.FieldOfView, 1, 179)) * 0.5
	local radius = math.tan(halfFov) / math.max(math.tan(halfCamera), 0.001) * (size.Y * 0.5)
	return math.clamp(radius, 10, math.max(size.X, size.Y))
end

local rayParams = RaycastParams.new()
local modernFilter = pcall(function()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
end)
if not modernFilter then
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
end
rayParams.IgnoreWater = true
pcall(function()
	rayParams.RespectCanCollide = true
end)

local Aim = {
	player = nil,
	part = nil,
	point = nil,
	lockPoint = nil,
	lockCFrame = nil,
	scoped = false,
	scopeFov = nil,
	watchHumanoid = nil,
	lastHealth = nil,
	watchName = nil,
	holdingMouse = false,
	holdingKey = false,
	cache = {},
}

local function partFor(character, head, root, mode, origin)
	if mode == "Body" then
		return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso") or root
	end
	if mode == "Nearest" then
		local best = head
		local bestDistance = (head.Position - origin).Magnitude
		local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
		if torso then
			local distance = (torso.Position - origin).Magnitude
			if distance < bestDistance then
				best = torso
			end
		end
		return best
	end
	return head
end

local function canSee(player, camera, character, part)
	local now = os.clock()
	local cached = Aim.cache[player]
	if cached and now - cached.time < 0.12 then
		return cached.value
	end
	local origin = camera.CFrame.Position
	local filter = { character }
	if LocalPlayer.Character then
		filter[#filter + 1] = LocalPlayer.Character
	end
	filter[#filter + 1] = camera
	rayParams.FilterDescendantsInstances = filter
	local hit = workspace:Raycast(origin, part.Position - origin, rayParams)
	local value = true
	if hit and hit.Instance and not hit.Instance:IsDescendantOf(character) then
		if (hit.Position - origin).Magnitude > 2.5 then
			value = false
		end
	end
	Aim.cache[player] = { time = now, value = value }
	return value
end

local function pickTarget(settings, current)
	local camera = workspace.CurrentCamera
	if not camera then
		return nil, nil
	end
	local size = camera.ViewportSize
	local center = Vector2.new(size.X * 0.5, size.Y * 0.5)
	local radius = screenRadius(camera, settings.fov)
	local origin = camera.CFrame.Position
	local bestPlayer, bestPart, bestScore = nil, nil, math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and not (settings.team and sameTeam(player)) then
			local character, _humanoid, root, head = getCharacter(player)
			if character then
				local part = partFor(character, head, root, settings.part, origin)
				if part then
					local screen, onScreen = camera:WorldToViewportPoint(part.Position)
					if onScreen and screen.Z > 0 then
						local offsetX = screen.X - center.X
						local offsetY = screen.Y - center.Y
						local screenDistance = math.sqrt(offsetX * offsetX + offsetY * offsetY)
						local worldDistance = (part.Position - origin).Magnitude
						if screenDistance <= radius and worldDistance <= 1500 then
							if not settings.wall or canSee(player, camera, character, part) then
								local score = screenDistance + worldDistance * 0.02
								if settings.sticky and current and player == current then
									score = score - radius * 2 - 500
								end
								if score < bestScore then
									bestScore = score
									bestPlayer = player
									bestPart = part
								end
							end
						end
					end
				end
			end
		end
	end

	return bestPlayer, bestPart
end

local function aimActive()
	local settings = Config.aimbot
	if not settings.enabled then
		return false
	end
	if settings.mode == "Hold RMB" then
		return Aim.holdingMouse
	end
	if settings.mode == "Hold Q" then
		return Aim.holdingKey
	end
	return true
end

local Rage = { player = nil }
local Trigger = { last = 0 }
local FX = { hitUntil = 0 }
local notify = function() end
local lastFire = 0

local function fireWeapon()
	local now = os.clock()
	if now - lastFire < 0.05 then
		return
	end
	lastFire = now
	if type(mouse1click) == "function" then
		local ok = pcall(mouse1click)
		if ok then
			return
		end
	end
	local camera = workspace.CurrentCamera
	local size = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local clicked = pcall(function()
		game:GetService("VirtualUser"):ClickButton1(Vector2.new(size.X * 0.5, size.Y * 0.5))
	end)
	if clicked then
		return
	end
	pcall(function()
		game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1, false)
	end)
end

local CameraState = {
	previous = nil,
	scriptable = false,
	releaseFrom = nil,
	releaseClock = 0,
}

local function firstPersonHead(camera)
	local character = LocalPlayer.Character
	local head = character and character:FindFirstChild("Head")
	if not head then
		return nil
	end
	if LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
		return head
	end
	if (camera.CFrame.Position - head.Position).Magnitude < 2.6 then
		return head
	end
	return nil
end

local function restoreCameraType(camera)
	if camera and CameraState.previous and camera.CameraType ~= CameraState.previous then
		pcall(function()
			camera.CameraType = CameraState.previous
		end)
	end
	CameraState.scriptable = false
end

local function applyScope(on)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	if on then
		if not Aim.scoped then
			Aim.scopeFov = camera.FieldOfView
			Aim.scoped = true
		end
		camera.FieldOfView = math.min(Aim.scopeFov or 70, 55)
	elseif Aim.scoped then
		camera.FieldOfView = Aim.scopeFov or 70
		Aim.scoped = false
	end
end

local function beginRelease()
	if not Aim.lockPoint and not Aim.lockCFrame then
		return
	end
	local camera = workspace.CurrentCamera
	if CameraState.scriptable and camera then
		CameraState.releaseFrom = camera.CFrame
		CameraState.releaseClock = os.clock()
	end
	if camera then
		restoreCameraType(camera)
	end
	applyScope(false)
	Aim.lockPoint = nil
	Aim.lockCFrame = nil
end

local function finishRelease()
	local from = CameraState.releaseFrom
	if not from then
		return
	end
	local camera = workspace.CurrentCamera
	if not camera then
		CameraState.releaseFrom = nil
		return
	end
	local t = (os.clock() - CameraState.releaseClock) / 0.22
	if t >= 1 then
		CameraState.releaseFrom = nil
		return
	end
	local eased = t * t * (3 - 2 * t)
	camera.CFrame = camera.CFrame:Lerp(from, 1 - eased)
end

local function aimCamera(point, smooth, turn, delta, instant, deadzone)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	CameraState.releaseFrom = nil

	local firstPerson = nil
	if (Config.aimbot.enabled and Config.aimbot.firstPerson) or Config.rage.enabled then
		firstPerson = firstPersonHead(camera)
	end

	local cameraFrame = camera.CFrame
	local origin = cameraFrame.Position
	if firstPerson then
		if not CameraState.scriptable then
			CameraState.previous = camera.CameraType
			CameraState.scriptable = true
		end
		if camera.CameraType ~= Enum.CameraType.Scriptable then
			camera.CameraType = Enum.CameraType.Scriptable
		end
		origin = firstPerson.Position + Vector3.new(0, 0.2, 0)
	elseif CameraState.scriptable then
		restoreCameraType(camera)
	end

	local desired = point - origin
	if desired.Magnitude < 0.3 then
		return
	end
	desired = desired.Unit

	if deadzone and deadzone > 0 then
		local screen, onScreen = camera:WorldToViewportPoint(point)
		if onScreen and screen.Z > 0 then
			local offsetX = screen.X - camera.ViewportSize.X * 0.5
			local offsetY = screen.Y - camera.ViewportSize.Y * 0.5
			if math.sqrt(offsetX * offsetX + offsetY * offsetY) <= deadzone then
				camera.CFrame = CFrame.lookAt(origin, origin + cameraFrame.LookVector)
				Aim.lockCFrame = camera.CFrame
				return
			end
		end
	end

	local current = cameraFrame.LookVector
	local dot = math.clamp(current:Dot(desired), -1, 1)
	local angle = math.acos(dot)
	local direction
	if instant or angle < 0.0006 then
		direction = desired
	else
		local alpha = 1 - math.exp(-math.max(smooth, 0.1) * delta)
		local maxStep = math.rad(math.max(turn, 10)) * delta
		local step = math.min(angle * alpha, maxStep)
		direction = current:Lerp(desired, math.clamp(step / angle, 0, 1)).Unit
	end
	camera.CFrame = CFrame.lookAt(origin, origin + direction)
	Aim.lockCFrame = camera.CFrame
end

local function aimStep(delta)
	local settings = Config.aimbot
	if not aimActive() then
		Aim.player = nil
		Aim.point = nil
		applyScope(false)
		beginRelease()
		return
	end

	local player, part = pickTarget(settings, Aim.player)
	if not player or not part then
		if Aim.watchHumanoid and Aim.lastHealth and Aim.lastHealth > 0 and Aim.watchHumanoid.Health <= 0 then
			if settings.killNotify and Aim.watchName then
				notify("Eliminated " .. Aim.watchName)
			end
			Aim.watchHumanoid = nil
			Aim.lastHealth = nil
			Aim.watchName = nil
		end
		Aim.player = nil
		Aim.point = nil
		applyScope(false)
		beginRelease()
		return
	end

	if player ~= Aim.player then
		Aim.player = player
		Aim.point = nil
	end
	Aim.part = part

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		if Aim.watchHumanoid ~= humanoid then
			Aim.watchHumanoid = humanoid
			Aim.lastHealth = humanoid.Health
			Aim.watchName = player.DisplayName or player.Name
		elseif Aim.lastHealth and humanoid.Health < Aim.lastHealth - 0.5 then
			if settings.hitMarker then
				FX.hitUntil = os.clock() + 0.16
			end
			if settings.killNotify and humanoid.Health <= 0 then
				notify("Eliminated " .. (player.DisplayName or player.Name))
			end
		end
		Aim.lastHealth = humanoid.Health
	end

	local aimPoint = part.Position
	local velocity = part.AssemblyLinearVelocity
	if settings.prediction > 0 and velocity then
		aimPoint = aimPoint + velocity * (settings.prediction / 100)
	end

	if settings.instant then
		Aim.point = aimPoint
	elseif Aim.point == nil then
		Aim.point = aimPoint
	elseif settings.jitter > 1 then
		local filter = settings.jitter / 1000
		local alpha = 1 - math.exp(-delta / filter)
		Aim.point = Aim.point:Lerp(aimPoint, math.clamp(alpha, 0, 1))
		if (Aim.point - aimPoint).Magnitude > 14 then
			Aim.point = aimPoint
		end
	else
		Aim.point = aimPoint
	end

	aimCamera(Aim.point, settings.smooth, settings.turn, delta, settings.instant, settings.deadzone)
	Aim.lockPoint = Aim.point

	if settings.autoScope then
		applyScope(true)
	else
		applyScope(false)
	end

	if settings.autoFire then
		local camera = workspace.CurrentCamera
		if camera then
			local toTarget = Aim.point - camera.CFrame.Position
			if toTarget.Magnitude > 0.1 and camera.CFrame.LookVector:Dot(toTarget.Unit) > 0.99 then
				fireWeapon()
			end
		end
	end
end

local function rageStep()
	local settings = Config.rage
	if not settings.enabled then
		Rage.player = nil
		return
	end
	local player, part = pickTarget(settings, Rage.player)
	Rage.player = player
	if not player or not part then
		beginRelease()
		return
	end
	local point = part.Position
	local velocity = part.AssemblyLinearVelocity
	if settings.prediction > 0 and velocity then
		point = point + velocity * (settings.prediction / 100)
	end
	aimCamera(point, 1, 99999, 0, true, 0)
	Aim.lockPoint = point
	if settings.autoFire then
		fireWeapon()
	end
end

local function playerFromPart(part)
	local node = part
	while node and node ~= workspace do
		if node:IsA("Model") then
			local player = Players:GetPlayerFromCharacter(node)
			if player then
				return player
			end
		end
		node = node.Parent
	end
	return nil
end

local function enforceAim()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	if Aim.lockPoint and Aim.lockCFrame then
		camera.CFrame = Aim.lockCFrame
	elseif CameraState.releaseFrom then
		finishRelease()
	end
end

local triggerParams = RaycastParams.new()
local triggerModern = pcall(function()
	triggerParams.FilterType = Enum.RaycastFilterType.Exclude
end)
if not triggerModern then
	triggerParams.FilterType = Enum.RaycastFilterType.Blacklist
end
triggerParams.IgnoreWater = true
pcall(function()
	triggerParams.RespectCanCollide = true
end)

local function triggerStep()
	local settings = Config.trigger
	if not settings.enabled then
		return
	end
	local now = os.clock()
	if now - Trigger.last < settings.delay / 1000 then
		return
	end
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local filter = { camera }
	if LocalPlayer.Character then
		filter[#filter + 1] = LocalPlayer.Character
	end
	triggerParams.FilterDescendantsInstances = filter
	local hit = workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * settings.range, triggerParams)
	if not hit or not hit.Instance then
		return
	end
	local player = playerFromPart(hit.Instance)
	if not player or player == LocalPlayer then
		return
	end
	if settings.team and sameTeam(player) then
		return
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	Trigger.last = now
	fireWeapon()
end

--------------------------------------------------------------------------
-- ESP
--------------------------------------------------------------------------

local ESP = { entries = {}, chams = {}, activeChars = {} }

local function newEspEntry()
	local entry = {
		box = newDrawing("Square"),
		fill = newDrawing("Square"),
		healthBack = newDrawing("Square"),
		health = newDrawing("Square"),
		name = newDrawing("Text"),
		distance = newDrawing("Text"),
		tracer = newDrawing("Line"),
		headDot = newDrawing("Square"),
		arrow = newDrawing("Triangle"),
		skeleton = {},
	}
	return entry
end

local function releaseEspEntry(entry)
	for _, line in ipairs(entry.skeleton or {}) do
		removeDrawing(line)
	end
	entry.skeleton = {}
	for _, object in pairs(entry) do
		removeDrawing(object)
	end
end

local function setCham(character)
	if ESP.chams[character] and ESP.chams[character].Parent then
		return
	end
	local highlight = Instance.new("Highlight")
	highlight.Name = "NinjaHighlight"
	highlight.Adornee = character
	highlight.FillColor = Theme.accent
	highlight.FillTransparency = 0.62
	highlight.OutlineColor = Theme.accent
	highlight.OutlineTransparency = 0.1
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = workspace
	ESP.chams[character] = highlight
end

local function clearChams()
	for character, highlight in pairs(ESP.chams) do
		pcall(function()
			highlight:Destroy()
		end)
		ESP.chams[character] = nil
	end
end

local SKELETON_LINKS = {
	{ "Head", "UpperTorso" },
	{ "UpperTorso", "LowerTorso" },
	{ "UpperTorso", "LeftUpperArm" },
	{ "LeftUpperArm", "LeftLowerArm" },
	{ "LeftLowerArm", "LeftHand" },
	{ "UpperTorso", "RightUpperArm" },
	{ "RightUpperArm", "RightLowerArm" },
	{ "RightLowerArm", "RightHand" },
	{ "LowerTorso", "LeftUpperLeg" },
	{ "LeftUpperLeg", "LeftLowerLeg" },
	{ "LeftLowerLeg", "LeftFoot" },
	{ "LowerTorso", "RightUpperLeg" },
	{ "RightUpperLeg", "RightLowerLeg" },
	{ "RightLowerLeg", "RightFoot" },
}

local R6_LINKS = {
	{ "Head", "Torso" },
	{ "Torso", "Left Arm" },
	{ "Torso", "Right Arm" },
	{ "Torso", "Left Leg" },
	{ "Torso", "Right Leg" },
}

local function updateEsp()
	local settings = Config.esp
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local seen = {}
	ESP.activeChars = {}

	if settings.enabled and DRAW_OK then
		local origin = camera.CFrame.Position
		local size = camera.ViewportSize

		for _, player in ipairs(Players:GetPlayers()) do
			local character, humanoid, root, head = getCharacter(player)
			local skip = false
			if not character then
				skip = true
			elseif settings.team and sameTeam(player) then
				skip = true
			elseif settings.hideKnocked and isKnocked(player, character, humanoid) then
				skip = true
			end

			local distance = 0
			if not skip then
				distance = (root.Position - origin).Magnitude
				if distance > settings.maxDist or distance < 0.5 then
					skip = true
				end
			end

			if not skip then
				if settings.arrows then
					local screen, onScreen = camera:WorldToViewportPoint(root.Position)
					if not onScreen or screen.Z <= 0 then
						local entry = ESP.entries[player]
						if not entry then
							entry = newEspEntry()
							ESP.entries[player] = entry
						end
						local sx, sy = screen.X, screen.Y
						if screen.Z <= 0 then
							sx = size.X - sx
							sy = size.Y * 0.5
						end
						local dx = sx - size.X * 0.5
						local dy = sy - size.Y * 0.5
						local length = math.max(math.sqrt(dx * dx + dy * dy), 0.1)
						local ux, uy = dx / length, dy / length
						local margin = px(46)
						local scaleX = (size.X * 0.5 - margin) / math.max(math.abs(ux), 0.001)
						local scaleY = (size.Y * 0.5 - margin) / math.max(math.abs(uy), 0.001)
						local reach = math.min(scaleX, scaleY)
						local tipX = size.X * 0.5 + ux * reach
						local tipY = size.Y * 0.5 + uy * reach
						local arrow = entry.arrow
						if arrow then
							arrow.PointA = Vector2.new(tipX, tipY)
							arrow.PointB = Vector2.new(tipX - ux * px(16) - uy * px(10), tipY - uy * px(16) + ux * px(10))
							arrow.PointC = Vector2.new(tipX - ux * px(16) + uy * px(10), tipY - uy * px(16) - ux * px(10))
							arrow.Color = Theme.accent
							arrow.Thickness = 1
							arrow.Filled = true
							arrow.Transparency = 0.2
							arrow.Visible = true
						end
						seen[player] = true
					else
						local entry = ESP.entries[player]
						if entry then
							hideDrawing(entry.arrow)
						end
					end
				else
					local entry = ESP.entries[player]
					if entry then
						hideDrawing(entry.arrow)
					end
				end

				local boxFrame, boxSize = character:GetBoundingBox()
				local topWorld = boxFrame.Position + Vector3.new(0, boxSize.Y * 0.5, 0)
				local footWorld = boxFrame.Position - Vector3.new(0, boxSize.Y * 0.5, 0)
				local topPoint, topOn = camera:WorldToViewportPoint(topWorld)
				local footPoint, footOn = camera:WorldToViewportPoint(footWorld)

				if topOn and footOn and topPoint.Z > 0 and footPoint.Z > 0 then
					seen[player] = true
					ESP.activeChars[character] = true

					local entry = ESP.entries[player]
					if not entry then
						entry = newEspEntry()
						ESP.entries[player] = entry
					end

					local height = math.abs(footPoint.Y - topPoint.Y)
					local width = math.max(height * 0.55, 6)
					local centerX = (topPoint.X + footPoint.X) * 0.5
					local topY = math.min(topPoint.Y, footPoint.Y)
					local bottomY = math.max(topPoint.Y, footPoint.Y)
					local left = centerX - width * 0.5
					local fade = math.clamp(1 - (distance / math.max(settings.maxDist, 1)) * 0.5, 0.45, 1)
					local transparency = 1 - fade * 0.88

					if settings.box then
						setSquare(entry.box, Vector2.new(left, topY), Vector2.new(width, height), Theme.accent, 1, transparency, false)
					else
						hideDrawing(entry.box)
					end

					if settings.fill then
						setSquare(entry.fill, Vector2.new(left + 1, topY + 1), Vector2.new(math.max(width - 2, 1), math.max(height - 2, 1)), Theme.accent, 1, 0.86, true)
					else
						hideDrawing(entry.fill)
					end

					if settings.health and humanoid then
						local ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
						local barX = left - px(6)
						setSquare(entry.healthBack, Vector2.new(barX, topY), Vector2.new(px(3), height), Color3.fromRGB(14, 18, 20), 1, 0.25, true)
						local healthColor = Theme.good:Lerp(Theme.bad, 1 - ratio)
						setSquare(entry.health, Vector2.new(barX, topY + height * (1 - ratio)), Vector2.new(px(3), math.max(height * ratio, 1)), healthColor, 1, 0.05, true)
					else
						hideDrawing(entry.healthBack)
						hideDrawing(entry.health)
					end

					if settings.name then
						setText(entry.name, player.DisplayName or player.Name, Vector2.new(centerX, topY - px(17)), Theme.text, px(14))
					else
						hideDrawing(entry.name)
					end

					if settings.distance then
						setText(entry.distance, string.format("%d m", math.floor(distance + 0.5)), Vector2.new(centerX, bottomY + px(2)), Theme.accent, px(13))
					else
						hideDrawing(entry.distance)
					end

					if settings.tracer and entry.tracer then
						entry.tracer.From = Vector2.new(size.X * 0.5, size.Y)
						entry.tracer.To = Vector2.new(centerX, bottomY)
						entry.tracer.Color = Theme.accent
						entry.tracer.Thickness = 1
						entry.tracer.Transparency = 0.55
						entry.tracer.Visible = true
					else
						hideDrawing(entry.tracer)
					end

					if settings.skeleton then
						local links = character:FindFirstChild("UpperTorso") and SKELETON_LINKS or R6_LINKS
						for index, link in ipairs(links) do
							local line = entry.skeleton[index]
							if not line then
								line = newDrawing("Line")
								entry.skeleton[index] = line
							end
							local jointA = character:FindFirstChild(link[1], true)
							local jointB = character:FindFirstChild(link[2], true)
							if line and jointA and jointB then
								local pointA, onA = camera:WorldToViewportPoint(jointA.Position)
								local pointB, onB = camera:WorldToViewportPoint(jointB.Position)
								if onA and onB and pointA.Z > 0 and pointB.Z > 0 then
									setLine(line, Vector2.new(pointA.X, pointA.Y), Vector2.new(pointB.X, pointB.Y), Theme.text, 1, math.max(transparency - 0.12, 0.05))
								else
									hideDrawing(line)
								end
							elseif line then
								hideDrawing(line)
							end
						end
					else
						for _, line in ipairs(entry.skeleton) do
							hideDrawing(line)
						end
					end

					if settings.headDot then
						local headPoint, headOn = camera:WorldToViewportPoint(head.Position)
						if headOn and headPoint.Z > 0 then
							setSquare(entry.headDot, Vector2.new(headPoint.X - px(3), headPoint.Y - px(3)), Vector2.new(px(6), px(6)), Theme.bad, 1, 0.15, true)
						else
							hideDrawing(entry.headDot)
						end
					else
						hideDrawing(entry.headDot)
					end

					if settings.chams then
						setCham(character)
					end
				end
			end
		end
	end

	for player, entry in pairs(ESP.entries) do
		if not seen[player] then
			releaseEspEntry(entry)
			ESP.entries[player] = nil
		end
	end

	for character, highlight in pairs(ESP.chams) do
		if not ESP.activeChars[character] or not settings.enabled or not settings.chams then
			pcall(function()
				highlight:Destroy()
			end)
			ESP.chams[character] = nil
		end
	end
end

--------------------------------------------------------------------------
-- Client-side skin changer
--------------------------------------------------------------------------

local Skin = {
	originals = {},
	dirty = false,
	clock = 0,
}

local SKIN_COLORS = {
	Cyan = Color3.fromRGB(96, 232, 222),
	Gold = Color3.fromRGB(255, 196, 78),
	Crimson = Color3.fromRGB(235, 70, 90),
	Violet = Color3.fromRGB(170, 110, 255),
	Emerald = Color3.fromRGB(80, 226, 140),
	Ice = Color3.fromRGB(178, 226, 255),
	Pink = Color3.fromRGB(255, 120, 200),
	White = Color3.fromRGB(245, 245, 245),
}

local function skinPaint(container, color, material)
	for _, part in ipairs(container:GetDescendants()) do
		if part:IsA("BasePart") then
			if not Skin.originals[part] then
				Skin.originals[part] = { color = part.Color, material = part.Material }
			end
			part.Color = color
			part.Material = material
		elseif part:IsA("SurfaceAppearance") then
			if not Skin.originals[part] then
				Skin.originals[part] = { color = part.Color, appearance = true }
			end
			part.Color = color
		end
	end
end

local function skinRestore()
	for part, original in pairs(Skin.originals) do
		if part and part.Parent then
			if original.appearance then
				pcall(function()
					part.Color = original.color
				end)
			else
				pcall(function()
					part.Color = original.color
					part.Material = original.material
				end)
			end
		end
	end
	Skin.originals = {}
end

local function skinRefresh()
	if not Config.skin.enabled then
		if next(Skin.originals) then
			skinRestore()
		end
		return
	end

	local color
	if Config.skin.rainbow then
		color = Color3.fromHSV((os.clock() * 0.25) % 1, 0.85, 1)
	else
		color = SKIN_COLORS[Config.skin.color] or SKIN_COLORS.Cyan
	end
	local material = Enum.Material.Neon
	pcall(function()
		material = Enum.Material[Config.skin.material]
	end)
	if not material then
		material = Enum.Material.Neon
	end

	local character = LocalPlayer.Character
	if character then
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Tool") then
				skinPaint(child, color, material)
			end
		end
	end

	local camera = workspace.CurrentCamera
	if camera then
		skinPaint(camera, color, material)
	end

	for _, object in ipairs(workspace:GetChildren()) do
		local lower = string.lower(object.Name)
		if object:IsA("Model") or object:IsA("Folder") then
			if lower:find("viewmodel") or lower:find("view model") or lower:find("weapon") or lower:find("arms") then
				skinPaint(object, color, material)
			end
		end
	end
end

--------------------------------------------------------------------------
-- Pickup ESP
--------------------------------------------------------------------------

local Pickups = { entries = {}, clock = 0 }

local function clearPickups()
	for _, entry in pairs(Pickups.entries) do
		removeDrawing(entry.box)
		removeDrawing(entry.text)
	end
	Pickups.entries = {}
end

local function updatePickups(delta)
	Pickups.clock = Pickups.clock + delta
	local settings = Config.esp
	local camera = workspace.CurrentCamera
	if not settings.enabled or not settings.pickups or not camera or not DRAW_OK or not workspace.GetDescendants then
		if next(Pickups.entries) then
			clearPickups()
		end
		return
	end

	if Pickups.clock >= 0.5 then
		Pickups.clock = 0
		local found = {}
		for _, object in ipairs(workspace:GetDescendants()) do
			if object:IsA("Tool") then
				local owner = object.Parent and Players:GetPlayerFromCharacter(object.Parent)
				if not owner then
					found[object] = true
					if not Pickups.entries[object] then
						Pickups.entries[object] = { box = newDrawing("Square"), text = newDrawing("Text") }
					end
				end
			end
		end
		for object, entry in pairs(Pickups.entries) do
			if not found[object] or not object.Parent then
				removeDrawing(entry.box)
				removeDrawing(entry.text)
				Pickups.entries[object] = nil
			end
		end
	end

	local origin = camera.CFrame.Position
	for object, entry in pairs(Pickups.entries) do
		local handle = object:FindFirstChild("Handle")
		if handle then
			local distance = (handle.Position - origin).Magnitude
			if distance <= settings.maxDist then
				local screen, onScreen = camera:WorldToViewportPoint(handle.Position)
				if onScreen and screen.Z > 0 then
					setSquare(entry.box, Vector2.new(screen.X - px(5), screen.Y - px(5)), Vector2.new(px(10), px(10)), Theme.good, 1, 0.25, false)
					setText(entry.text, object.Name, Vector2.new(screen.X, screen.Y - px(14)), Theme.good, px(12))
				else
					hideDrawing(entry.box)
					hideDrawing(entry.text)
				end
			else
				hideDrawing(entry.box)
				hideDrawing(entry.text)
			end
		else
			hideDrawing(entry.box)
			hideDrawing(entry.text)
		end
	end
end

--------------------------------------------------------------------------
-- World visuals
--------------------------------------------------------------------------

local World = { saved = nil, fog = nil }

local function updateWorldVisuals()
	local lighting = nil
	pcall(function()
		lighting = game:GetService("Lighting")
	end)
	if not lighting then
		return
	end

	local settings = Config.visual
	if settings.fullbright then
		if not World.saved then
			World.saved = {
				brightness = lighting.Brightness,
				ambient = lighting.Ambient,
				outdoor = lighting.OutdoorAmbient,
				clock = lighting.ClockTime,
			}
		end
		lighting.Brightness = 3
		lighting.Ambient = Color3.fromRGB(180, 180, 180)
		lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
		lighting.ClockTime = 14
	elseif World.saved then
		lighting.Brightness = World.saved.brightness or 2
		lighting.Ambient = World.saved.ambient or Color3.fromRGB(0, 0, 0)
		lighting.OutdoorAmbient = World.saved.outdoor or Color3.fromRGB(128, 128, 128)
		lighting.ClockTime = World.saved.clock or 14
		World.saved = nil
	end

	if settings.noFog then
		if not World.fog then
			World.fog = { start = lighting.FogStart, finish = lighting.FogEnd }
		end
		lighting.FogStart = 1000000
		lighting.FogEnd = 1000000
	elseif World.fog then
		lighting.FogStart = World.fog.start or 0
		lighting.FogEnd = World.fog.finish or 1000000
		World.fog = nil
	end
end

--------------------------------------------------------------------------
-- Movement
--------------------------------------------------------------------------

local Move = {
	humanoid = nil,
	baseSpeed = nil,
	baseJump = nil,
	speedApplied = false,
	jumpApplied = false,
	flyBody = nil,
	flying = false,
	clipped = {},
	baseFov = nil,
	fovApplied = false,
	jumpConnection = nil,
}

local function currentHumanoid()
	local character = LocalPlayer.Character
	if not character then
		return nil, nil
	end
	return character:FindFirstChildOfClass("Humanoid"), character
end

local function stopFly()
	if Move.flyBody then
		pcall(function()
			Move.flyBody:Destroy()
		end)
	end
	Move.flyBody = nil
	if Move.flying then
		local humanoid = currentHumanoid()
		if humanoid then
			pcall(function()
				humanoid.PlatformStand = false
			end)
		end
	end
	Move.flying = false
end

local function restoreNoclip()
	for part in pairs(Move.clipped) do
		if part and part.Parent then
			pcall(function()
				part.CanCollide = true
			end)
		end
	end
	Move.clipped = {}
end

local function updateMovement(delta)
	local humanoid, character = currentHumanoid()
	if humanoid ~= Move.humanoid then
		stopFly()
		Move.humanoid = humanoid
		Move.baseSpeed = humanoid and humanoid.WalkSpeed or nil
		Move.baseJump = humanoid and humanoid.JumpPower or nil
		Move.speedApplied = false
		Move.jumpApplied = false
		Move.clipped = {}
	end
	if not humanoid then
		return
	end

	local settings = Config.move

	if settings.speed then
		if not Move.speedApplied then
			Move.baseSpeed = humanoid.WalkSpeed
			Move.speedApplied = true
		end
		humanoid.WalkSpeed = settings.speedValue
	elseif Move.speedApplied then
		humanoid.WalkSpeed = Move.baseSpeed or 16
		Move.speedApplied = false
	end

	if settings.jump then
		if not Move.jumpApplied then
			Move.baseJump = humanoid.JumpPower
			Move.jumpApplied = true
		end
		pcall(function()
			humanoid.UseJumpPower = true
		end)
		humanoid.JumpPower = settings.jumpValue
	elseif Move.jumpApplied then
		humanoid.JumpPower = Move.baseJump or 50
		Move.jumpApplied = false
	end

	if settings.autoJump and humanoid.FloorMaterial ~= Enum.Material.Air then
		humanoid.Jump = true
	end

	if settings.infiniteJump and not Move.jumpConnection then
		pcall(function()
			Move.jumpConnection = UserInputService.JumpRequest:Connect(function()
				if not Config.move.infiniteJump then
					return
				end
				local hum = currentHumanoid()
				if hum then
					pcall(function()
						hum:ChangeState(Enum.HumanoidStateType.Jumping)
					end)
				end
			end)
		end)
	end

	if settings.fly then
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			if not Move.flyBody then
				local body = Instance.new("BodyVelocity")
				body.Name = "NinjaFly"
				body.MaxForce = Vector3.new(1000000, 1000000, 1000000)
				body.P = 1250
				body.Parent = root
				Move.flyBody = body
				Move.flying = true
				pcall(function()
					humanoid.PlatformStand = true
				end)
			end
			local camera = workspace.CurrentCamera
			local look = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
			local velocity = look * settings.flySpeed
			local up, down = false, false
			pcall(function()
				up = UserInputService:IsKeyDown(Enum.KeyCode.Space)
				down = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
			end)
			if up then
				velocity = velocity + Vector3.new(0, settings.flySpeed, 0)
			elseif down then
				velocity = velocity - Vector3.new(0, settings.flySpeed, 0)
			end
			Move.flyBody.Velocity = velocity
		end
	elseif Move.flyBody then
		stopFly()
	end

	if settings.noclip then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				Move.clipped[part] = true
				part.CanCollide = false
			end
		end
	elseif next(Move.clipped) then
		restoreNoclip()
	end

	if settings.fov then
		local camera = workspace.CurrentCamera
		if camera and not Aim.scoped then
			if not Move.fovApplied then
				Move.baseFov = camera.FieldOfView
				Move.fovApplied = true
			end
			camera.FieldOfView = settings.fovValue
		end
	elseif Move.fovApplied then
		local camera = workspace.CurrentCamera
		if camera and not Aim.scoped then
			camera.FieldOfView = Move.baseFov or 70
		end
		Move.fovApplied = false
	end
end

local function shutdownMovement()
	Config.move.speed = false
	Config.move.jump = false
	Config.move.fly = false
	Config.move.noclip = false
	Config.move.fov = false
	stopFly()
	restoreNoclip()
	local humanoid = Move.humanoid
	if humanoid then
		if Move.speedApplied then
			pcall(function()
				humanoid.WalkSpeed = Move.baseSpeed or 16
			end)
		end
		if Move.jumpApplied then
			pcall(function()
				humanoid.JumpPower = Move.baseJump or 50
			end)
		end
	end
	local camera = workspace.CurrentCamera
	if camera and Move.fovApplied then
		camera.FieldOfView = Move.baseFov or 70
	end
	Move.speedApplied = false
	Move.jumpApplied = false
	Move.fovApplied = false
	applyScope(false)
	if Move.jumpConnection then
		pcall(function()
			Move.jumpConnection:Disconnect()
		end)
		Move.jumpConnection = nil
	end
end

--------------------------------------------------------------------------
-- Crosshair, hit marker and target HUD
--------------------------------------------------------------------------

local Cross = { lines = {}, dot = nil }

local function updateCrosshair()
	if not DRAW_OK then
		return
	end
	if #Cross.lines == 0 then
		for index = 1, 4 do
			Cross.lines[index] = newDrawing("Line")
		end
		Cross.dot = newDrawing("Square")
	end
	local camera = workspace.CurrentCamera
	if not camera or not Config.visual.crosshair then
		for _, line in ipairs(Cross.lines) do
			hideDrawing(line)
		end
		hideDrawing(Cross.dot)
		return
	end
	local size = camera.ViewportSize
	local cx, cy = size.X * 0.5, size.Y * 0.5
	local gap = px(3)
	local length = px(Config.visual.crosshairSize)
	setLine(Cross.lines[1], Vector2.new(cx - gap - length, cy), Vector2.new(cx - gap, cy), Theme.accent, 1, 0.15)
	setLine(Cross.lines[2], Vector2.new(cx + gap, cy), Vector2.new(cx + gap + length, cy), Theme.accent, 1, 0.15)
	setLine(Cross.lines[3], Vector2.new(cx, cy - gap - length), Vector2.new(cx, cy - gap), Theme.accent, 1, 0.15)
	setLine(Cross.lines[4], Vector2.new(cx, cy + gap), Vector2.new(cx, cy + gap + length), Theme.accent, 1, 0.15)
	setSquare(Cross.dot, Vector2.new(cx - 1, cy - 1), Vector2.new(2, 2), Theme.accent, 1, 0.1, true)
end

local HitMark = { lines = {} }

local function updateHitMarker()
	if not DRAW_OK then
		return
	end
	if #HitMark.lines == 0 then
		for index = 1, 4 do
			HitMark.lines[index] = newDrawing("Line")
		end
	end
	local camera = workspace.CurrentCamera
	if not camera or os.clock() > FX.hitUntil then
		for _, line in ipairs(HitMark.lines) do
			hideDrawing(line)
		end
		return
	end
	local size = camera.ViewportSize
	local cx, cy = size.X * 0.5, size.Y * 0.5
	local inner, outer = px(5), px(12)
	setLine(HitMark.lines[1], Vector2.new(cx - outer, cy - outer), Vector2.new(cx - inner, cy - inner), Theme.bad, 2, 0.02)
	setLine(HitMark.lines[2], Vector2.new(cx + inner, cy - inner), Vector2.new(cx + outer, cy - outer), Theme.bad, 2, 0.02)
	setLine(HitMark.lines[3], Vector2.new(cx - outer, cy + outer), Vector2.new(cx - inner, cy + inner), Theme.bad, 2, 0.02)
	setLine(HitMark.lines[4], Vector2.new(cx + inner, cy + inner), Vector2.new(cx + outer, cy + outer), Theme.bad, 2, 0.02)
end

local targetHud = newDrawing("Text")

local function updateTargetHud()
	local camera = workspace.CurrentCamera
	local settings = Config.aimbot
	if not targetHud or not settings.enabled or not settings.targetHud or not Aim.player or not camera then
		hideDrawing(targetHud)
		return
	end
	local character, humanoid, root = getCharacter(Aim.player)
	if not character or not humanoid or not root then
		hideDrawing(targetHud)
		return
	end
	local distance = (root.Position - camera.CFrame.Position).Magnitude
	local size = camera.ViewportSize
	setText(targetHud, string.format("%s  %d HP  %dm", Aim.player.DisplayName or Aim.player.Name, math.floor(humanoid.Health + 0.5), math.floor(distance + 0.5)), Vector2.new(size.X * 0.5, size.Y * 0.5 - px(62)), Theme.bad, px(13))
end

--------------------------------------------------------------------------
-- Interface
--------------------------------------------------------------------------

local UI = {
	visible = true,
	syncers = {},
}

local gui = Instance.new("ScreenGui")
gui.Name = "NinjaRivals"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 500

local parentOk = pcall(function()
	gui.Parent = game:GetService("CoreGui")
end)
if not parentOk then
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui", 10)
end

local root = create("Frame", {
	Name = "Root",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
}, gui)

local iconGui = Instance.new("ScreenGui")
iconGui.Name = "NinjaRivalsIcon"
iconGui.ResetOnSpawn = false
iconGui.IgnoreGuiInset = true
iconGui.DisplayOrder = 501

local iconParentOk = pcall(function()
	iconGui.Parent = game:GetService("CoreGui")
end)
if not iconParentOk then
	iconGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 10)
end

local brand = create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(px(74), px(17)),
	Size = UDim2.fromOffset(px(240), px(30)),
	Font = Enum.Font.GothamBold,
	Text = "NINJA / RIVALS",
	TextSize = px(17),
	TextColor3 = Theme.text,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextStrokeTransparency = 0.55,
}, root)

local watermarkLabel = create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(px(74), px(39)),
	Size = UDim2.fromOffset(px(360), px(14)),
	Font = Enum.Font.Code,
	Text = "",
	TextSize = px(10),
	TextColor3 = Theme.textMuted,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextStrokeTransparency = 0.6,
}, root)

local activePanel = create("Frame", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -px(16), 0, px(16)),
	Size = UDim2.fromOffset(px(150), 0),
	AutomaticSize = Enum.AutomaticSize.Y,
}, root)
create("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, px(2)),
}, activePanel)
create("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, px(16)),
	LayoutOrder = 0,
	Font = Enum.Font.GothamBold,
	Text = "ACTIVE",
	TextSize = px(10),
	TextColor3 = Theme.textMuted,
	TextXAlignment = Enum.TextXAlignment.Right,
	TextStrokeTransparency = 0.6,
}, activePanel)

local coordsLabel = create("TextLabel", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, px(14), 1, -px(12)),
	Size = UDim2.fromOffset(px(200), px(56)),
	Font = Enum.Font.Code,
	Text = "X  --\nY  --\nZ  --",
	TextSize = px(12),
	TextColor3 = Theme.text,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Bottom,
	TextWrapped = true,
	TextStrokeTransparency = 0.45,
}, root)

local statsLabel = create("TextLabel", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -px(14), 1, -px(12)),
	Size = UDim2.fromOffset(px(210), px(94)),
	Font = Enum.Font.Code,
	Text = "FPS: --\nPing: -- ms\nTarget: -",
	TextSize = px(12),
	TextColor3 = Theme.text,
	TextXAlignment = Enum.TextXAlignment.Right,
	TextYAlignment = Enum.TextYAlignment.Bottom,
	TextWrapped = true,
	TextStrokeTransparency = 0.45,
}, root)

local function bindDrag(target, onBegin, onDelta, onTap)
	target.InputBegan:Connect(function(input)
		if not isPrimary(input) then
			return
		end
		if onBegin then
			onBegin()
		end
		local start = Vector2.new(input.Position.X, input.Position.Y)
		local moved = false
		local moveConnection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				return
			end
			local current = Vector2.new(input.Position.X, input.Position.Y)
			local delta = current - start
			if delta.Magnitude > px(5) then
				moved = true
			end
			if onDelta then
				onDelta(delta)
			end
		end)
		local endConnection
		endConnection = UserInputService.InputEnded:Connect(function(other)
			if other ~= input then
				return
			end
			if moveConnection then
				moveConnection:Disconnect()
			end
			if endConnection then
				endConnection:Disconnect()
			end
			if not moved and onTap then
				onTap()
			end
		end)
	end)
end

local function bindTap(target, callback)
	target.InputBegan:Connect(function(input)
		if not isPrimary(input) then
			return
		end
		local start = Vector2.new(input.Position.X, input.Position.Y)
		local moved = false
		local moveConnection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				return
			end
			local current = Vector2.new(input.Position.X, input.Position.Y)
			if (current - start).Magnitude > px(8) then
				moved = true
			end
		end)
		local endConnection
		endConnection = UserInputService.InputEnded:Connect(function(other)
			if other ~= input then
				return
			end
			if moveConnection then
				moveConnection:Disconnect()
			end
			if endConnection then
				endConnection:Disconnect()
			end
			local finish = Vector2.new(input.Position.X, input.Position.Y)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local ok, location = pcall(function()
					return UserInputService:GetMouseLocation()
				end)
				if ok and location then
					finish = Vector2.new(location.X, location.Y)
				end
			end
			if not moved and (finish - start).Magnitude <= px(10) then
				callback()
			end
		end)
	end)
end

local function makeWindow(title, x, y)
	local size = viewport()
	local window = {
		title = title,
		x = math.clamp(x, 0, math.max(size.X / SCALE - Metrics.width, 0)),
		y = math.clamp(y, 0, math.max(size.Y / SCALE - Metrics.header, 0)),
		width = Metrics.width,
		order = 0,
		collapsed = false,
	}

	local panel = create("Frame", {
		Name = "Window_" .. title,
		BackgroundColor3 = Theme.panel,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(px(window.x), px(window.y)),
		Size = UDim2.fromOffset(px(window.width), px(Metrics.header)),
		ClipsDescendants = true,
	}, root)

	create("UIStroke", {
		Color = Theme.stroke,
		Thickness = 1,
		Transparency = 0.4,
	}, panel)

	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 0),
	}, panel)

	local header = create("TextButton", {
		Name = "Header",
		AutoButtonColor = false,
		BackgroundColor3 = Theme.accent,
		BorderSizePixel = 0,
		Text = "",
		Size = UDim2.new(1, 0, 0, px(Metrics.header)),
		LayoutOrder = 0,
	}, panel)

	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(px(8), 0),
		Size = UDim2.new(1, -px(28), 1, 0),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextSize = px(13),
		TextColor3 = Theme.dark,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, header)

	local collapse = create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -px(22), 0, 0),
		Size = UDim2.fromOffset(px(22), px(Metrics.header)),
		Font = Enum.Font.GothamBold,
		Text = "-",
		TextSize = px(15),
		TextColor3 = Theme.dark,
	}, header)

	local body = create("ScrollingFrame", {
		Name = "Body",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = px(3),
		ScrollBarImageColor3 = Theme.accent,
		ScrollBarImageTransparency = 0.35,
		LayoutOrder = 1,
		ClipsDescendants = true,
	}, panel)

	local content = create("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -px(4), 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, body)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 0),
	}, content)

	local function resizeBody()
		local maxHeight = math.max(viewport().Y - px(window.y) - px(Metrics.header) - px(14), px(90))
		local bodyHeight = math.min(content.AbsoluteSize.Y, maxHeight)
		body.Size = UDim2.fromOffset(px(window.width), bodyHeight)
		panel.Size = UDim2.fromOffset(px(window.width), px(Metrics.header) + bodyHeight)
	end

	local function setCollapsed(value)
		window.collapsed = value and true or false
		body.Visible = not window.collapsed
		collapse.Text = window.collapsed and "+" or "-"
		if window.collapsed then
			panel.Size = UDim2.fromOffset(px(window.width), px(Metrics.header))
		else
			resizeBody()
		end
	end

	content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if not window.collapsed then
			resizeBody()
		end
	end)
	task.defer(resizeBody)

	bindTap(collapse, function()
		setCollapsed(not window.collapsed)
	end)

	bindDrag(header, function()
		window.baseX = window.x
		window.baseY = window.y
	end, function(delta)
		local size = viewport()
		window.x = math.clamp(window.baseX + delta.X / SCALE, 0, math.max(size.X / SCALE - window.width, 0))
		window.y = math.clamp(window.baseY + delta.Y / SCALE, 0, math.max(size.Y / SCALE - Metrics.header, 0))
		panel.Position = UDim2.fromOffset(px(window.x), px(window.y))
		resizeBody()
	end)

	function window.addRow(rowTitle, options)
		options = options or {}
		window.order = window.order + 1

		local rowFrame = create("Frame", {
			Name = "Row",
			BackgroundColor3 = Theme.row,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, px(Metrics.row)),
			LayoutOrder = window.order,
		}, content)

		if not IS_MOBILE then
			rowFrame.MouseEnter:Connect(function()
				rowFrame.BackgroundColor3 = Theme.rowHover
			end)
			rowFrame.MouseLeave:Connect(function()
				rowFrame.BackgroundColor3 = Theme.row
			end)
		end

		create("Frame", {
			BackgroundColor3 = Theme.separator,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, -1),
			Size = UDim2.new(1, 0, 0, 1),
		}, rowFrame)

		local plus = create("TextButton", {
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(px(2), 0),
			Size = UDim2.fromOffset(px(22), px(Metrics.row)),
			Font = Enum.Font.GothamBold,
			Text = "+",
			TextSize = px(13),
			TextColor3 = Theme.textDim,
			Visible = false,
		}, rowFrame)

		local titleButton = create("TextButton", {
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(px(24), 0),
			Size = UDim2.new(1, -px(38), 1, 0),
			Font = Enum.Font.GothamMedium,
			Text = rowTitle,
			TextSize = px(13),
			TextColor3 = Theme.text,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, rowFrame)

		local status = create("Frame", {
			BackgroundColor3 = Theme.accent,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -px(8), 0.5, -px(6)),
			Size = UDim2.fromOffset(px(3), px(12)),
			Visible = false,
		}, rowFrame)

		window.order = window.order + 1
		local settings = create("Frame", {
			Name = "Settings",
			BackgroundColor3 = Theme.panelDeep,
			BackgroundTransparency = 0.12,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = window.order,
			Visible = false,
		}, content)
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 0),
		}, settings)

		local row = {
			frame = rowFrame,
			settings = settings,
			collapsed = true,
			widgetOrder = 0,
		}

		function row.setActive(on)
			status.Visible = on and true or false
			titleButton.TextColor3 = on and Theme.accent or Theme.text
		end

		function row.setExpanded(on)
			row.collapsed = not on
			settings.Visible = on and true or false
			plus.Text = on and "-" or "+"
		end

		function row.enablePlus()
			plus.Visible = true
		end

		function row.addToggle(text, get, set)
			row.enablePlus()
			row.widgetOrder = row.widgetOrder + 1

			local line = create("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, 0, 0, px(28)),
				LayoutOrder = row.widgetOrder,
			}, settings)

			local caption = create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(px(22), 0),
				Size = UDim2.new(1, -px(64), 1, 0),
				Font = Enum.Font.Gotham,
				Text = text,
				TextSize = px(12),
				TextColor3 = Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, line)

			local track = create("Frame", {
				BackgroundColor3 = Theme.rowActive,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -px(38), 0.5, -px(8)),
				Size = UDim2.fromOffset(px(30), px(16)),
			}, line)
			create("UICorner", { CornerRadius = UDim.new(0, px(3)) }, track)

			local knob = create("Frame", {
				BackgroundColor3 = Theme.textMuted,
				BorderSizePixel = 0,
				Position = UDim2.new(0, px(2), 0.5, -px(6)),
				Size = UDim2.fromOffset(px(12), px(12)),
			}, track)
			create("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

			local function paint()
				local on = get() and true or false
				track.BackgroundColor3 = on and Theme.accentDark or Theme.rowActive
				knob.Position = UDim2.new(0, on and px(16) or px(2), 0.5, -px(6))
				knob.BackgroundColor3 = on and Theme.text or Theme.textMuted
				caption.TextColor3 = on and Theme.text or Theme.textDim
			end

			bindTap(line, function()
				set(not get())
				UI.sync()
			end)

			paint()
			table.insert(UI.syncers, paint)
		end

		function row.addSlider(text, minValue, maxValue, step, get, set, suffix, decimals)
			row.enablePlus()
			row.widgetOrder = row.widgetOrder + 1

			local line = create("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, 0, 0, px(34)),
				LayoutOrder = row.widgetOrder,
			}, settings)

			create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(px(22), 0),
				Size = UDim2.new(1, -px(96), 0, px(16)),
				Font = Enum.Font.Gotham,
				Text = text,
				TextSize = px(12),
				TextColor3 = Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, line)

			local valueLabel = create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -px(76), 0, 0),
				Size = UDim2.fromOffset(px(52), px(16)),
				Font = Enum.Font.Code,
				Text = "",
				TextSize = px(11),
				TextColor3 = Theme.accent,
				TextXAlignment = Enum.TextXAlignment.Right,
			}, line)

			local track = create("Frame", {
				BackgroundColor3 = Theme.rowActive,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(px(22), px(22)),
				Size = UDim2.new(1, -px(34), 0, px(6)),
			}, line)
			create("UICorner", { CornerRadius = UDim.new(1, 0) }, track)

			local fill = create("Frame", {
				BackgroundColor3 = Theme.accentDark,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 0, 1, 0),
			}, track)
			create("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)

			local knob = create("Frame", {
				BackgroundColor3 = Theme.accent,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.fromOffset(px(12), px(12)),
				ZIndex = 2,
			}, track)
			create("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

			local format = "%." .. tostring(decimals or 0) .. "f"

			local function paint()
				local ratio = math.clamp((get() - minValue) / math.max(maxValue - minValue, 0.0001), 0, 1)
				fill.Size = UDim2.new(ratio, 0, 1, 0)
				knob.Position = UDim2.new(ratio, 0, 0.5, 0)
				valueLabel.Text = string.format(format, get()) .. (suffix or "")
			end

			local function valueAt(x)
				local ratio = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
				local raw = minValue + (maxValue - minValue) * ratio
				if step and step > 0 then
					raw = math.floor(raw / step + 0.5) * step
				end
				return math.clamp(raw, minValue, maxValue)
			end

			line.InputBegan:Connect(function(input)
				if not isPrimary(input) then
					return
				end
				set(valueAt(input.Position.X))
				paint()
				local movingConnection = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						return
					end
					set(valueAt(input.Position.X))
					paint()
				end)
				local endConnection
				endConnection = UserInputService.InputEnded:Connect(function(other)
					if other ~= input then
						return
					end
					if movingConnection then
						movingConnection:Disconnect()
					end
					if endConnection then
						endConnection:Disconnect()
					end
				end)
			end)

			paint()
			table.insert(UI.syncers, paint)
		end

		function row.addDropdown(text, options, get, set)
			row.enablePlus()
			row.widgetOrder = row.widgetOrder + 1

			local line = create("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, px(28)),
				LayoutOrder = row.widgetOrder,
				Text = "",
			}, settings)

			create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(px(22), 0),
				Size = UDim2.new(1, -px(104), 1, 0),
				Font = Enum.Font.Gotham,
				Text = text,
				TextSize = px(12),
				TextColor3 = Theme.textDim,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, line)

			local valueLabel = create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -px(98), 0, 0),
				Size = UDim2.fromOffset(px(74), px(28)),
				Font = Enum.Font.Code,
				Text = tostring(get()),
				TextSize = px(11),
				TextColor3 = Theme.accent,
				TextXAlignment = Enum.TextXAlignment.Right,
			}, line)

			create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -px(18), 0, 0),
				Size = UDim2.fromOffset(px(14), px(28)),
				Font = Enum.Font.GothamBold,
				Text = "v",
				TextSize = px(10),
				TextColor3 = Theme.textMuted,
				TextXAlignment = Enum.TextXAlignment.Center,
			}, line)

			row.widgetOrder = row.widgetOrder + 1
			local menu = create("Frame", {
				BackgroundColor3 = Theme.panel,
				BackgroundTransparency = 0.05,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = row.widgetOrder,
				Visible = false,
			}, settings)
			create("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 0),
			}, menu)

			for index, option in ipairs(options) do
				local optionButton = create("TextButton", {
					AutoButtonColor = false,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, px(24)),
					LayoutOrder = index,
					Font = Enum.Font.Gotham,
					Text = "     " .. option,
					TextSize = px(12),
					TextColor3 = Theme.textDim,
					TextXAlignment = Enum.TextXAlignment.Left,
				}, menu)

				optionButton.MouseEnter:Connect(function()
					optionButton.TextColor3 = Theme.accent
				end)
				optionButton.MouseLeave:Connect(function()
					optionButton.TextColor3 = Theme.textDim
				end)

				bindTap(optionButton, function()
					set(option)
					valueLabel.Text = tostring(option)
					menu.Visible = false
					UI.sync()
				end)
			end

			bindTap(line, function()
				menu.Visible = not menu.Visible
			end)
		end

		function row.addButton(text, callback)
			row.enablePlus()
			row.widgetOrder = row.widgetOrder + 1

			local button = create("TextButton", {
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, px(28)),
				LayoutOrder = row.widgetOrder,
				Font = Enum.Font.GothamMedium,
				Text = "     " .. text,
				TextSize = px(12),
				TextColor3 = Theme.accent,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, settings)

			bindTap(button, callback)
		end

		function row.addInfo(text)
			row.enablePlus()
			row.widgetOrder = row.widgetOrder + 1

			create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, px(24)),
				LayoutOrder = row.widgetOrder,
				Font = Enum.Font.Gotham,
				Text = "     " .. text,
				TextSize = px(11),
				TextColor3 = Theme.textMuted,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, settings)
		end

		if options.get then
			local function sync()
				row.setActive(options.get())
			end
			table.insert(UI.syncers, sync)
			sync()
		end

		if options.toggle then
			bindTap(titleButton, function()
				options.toggle()
				UI.sync()
			end)
		elseif options.onClick then
			bindTap(titleButton, options.onClick)
		end

		bindTap(plus, function()
			if row.widgetOrder == 0 then
				return
			end
			row.setExpanded(row.collapsed)
		end)

		return row
	end

	return window
end

local function refreshActive()
	for _, label in ipairs(UI.activeLabels or {}) do
		label:Destroy()
	end
	UI.activeLabels = {}

	local items = {
		{ "Aimbot", Config.aimbot.enabled },
		{ "Rage", Config.rage.enabled },
		{ "Trigger", Config.trigger.enabled },
		{ "ESP", Config.esp.enabled },
		{ "Skin Unlocker", Config.skin.enabled },
		{ "Chams", Config.esp.enabled and Config.esp.chams },
		{ "Tracer", Config.esp.enabled and Config.esp.tracer },
		{ "FOV", Config.aimbot.enabled and Config.aimbot.showFov },
	}

	for index, item in ipairs(items) do
		if item[2] then
			local label = create("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, px(18)),
				LayoutOrder = index,
				Font = Enum.Font.GothamMedium,
				Text = item[1],
				TextSize = px(12),
				TextColor3 = Theme.accent,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextStrokeTransparency = 0.45,
			}, activePanel)
			table.insert(UI.activeLabels, label)
		end
	end
end

function UI.sync()
	for _, sync in ipairs(UI.syncers) do
		pcall(sync)
	end
	refreshActive()
end

local function toast(message)
	if UI.notice then
		UI.notice:Destroy()
	end
	local notice = create("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, px(92)),
		Size = UDim2.fromOffset(px(340), px(22)),
		Font = Enum.Font.GothamBold,
		Text = message,
		TextSize = px(14),
		TextColor3 = Theme.text,
		TextStrokeTransparency = 0.45,
	}, iconGui)
	UI.notice = notice
	TweenService:Create(notice, TweenInfo.new(2.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()
	task.delay(2.6, function()
		if UI.notice == notice then
			notice:Destroy()
			UI.notice = nil
		end
	end)
end

notify = toast

function UI.setVisible(value)
	UI.visible = value and true or false
	gui.Enabled = UI.visible
end

local aimWindow = makeWindow("Aimbot", 12, 70)
local espWindow = makeWindow("ESP", 202, 70)
local moveWindow = makeWindow("Movement", 392, 70)
local interfaceWindow = makeWindow("Interface", 582, 70)

--------------------------------------------------------------------------
-- Aimbot panel
--------------------------------------------------------------------------

local aimRow = aimWindow.addRow("Aimbot", {
	get = function()
		return Config.aimbot.enabled
	end,
	toggle = function()
		Config.aimbot.enabled = not Config.aimbot.enabled
		if Config.aimbot.enabled then
			toast("Aimbot enabled")
		end
	end,
})

aimRow.addToggle("Enabled", function()
	return Config.aimbot.enabled
end, function(value)
	Config.aimbot.enabled = value
end)

aimRow.addDropdown("Mode", { "Always", "Hold RMB", "Hold Q" }, function()
	return Config.aimbot.mode
end, function(value)
	Config.aimbot.mode = value
end)

aimRow.addSlider("FOV", 10, 180, 1, function()
	return Config.aimbot.fov
end, function(value)
	Config.aimbot.fov = value
end, " deg", 0)

aimRow.addSlider("Smoothness", 1, 40, 0.5, function()
	return Config.aimbot.smooth
end, function(value)
	Config.aimbot.smooth = value
end, "", 1)

aimRow.addSlider("Max Turn", 60, 720, 10, function()
	return Config.aimbot.turn
end, function(value)
	Config.aimbot.turn = value
end, " d/s", 0)

aimRow.addSlider("Prediction", 0, 20, 1, function()
	return Config.aimbot.prediction
end, function(value)
	Config.aimbot.prediction = value
end, "%", 0)

aimRow.addSlider("Jitter Filter", 0, 200, 5, function()
	return Config.aimbot.jitter
end, function(value)
	Config.aimbot.jitter = value
end, " ms", 0)

aimRow.addSlider("Deadzone", 0, 20, 1, function()
	return Config.aimbot.deadzone
end, function(value)
	Config.aimbot.deadzone = value
end, " px", 0)

aimRow.addDropdown("Target", { "Head", "Body", "Nearest" }, function()
	return Config.aimbot.part
end, function(value)
	Config.aimbot.part = value
end)

aimRow.addToggle("Instant Lock", function()
	return Config.aimbot.instant
end, function(value)
	Config.aimbot.instant = value
end)

aimRow.addToggle("1st Person Lock", function()
	return Config.aimbot.firstPerson
end, function(value)
	Config.aimbot.firstPerson = value
end)

aimRow.addToggle("Wall Check", function()
	return Config.aimbot.wall
end, function(value)
	Config.aimbot.wall = value
	Aim.cache = {}
end)

aimRow.addToggle("Team Check", function()
	return Config.aimbot.team
end, function(value)
	Config.aimbot.team = value
end)

aimRow.addToggle("FOV Circle", function()
	return Config.aimbot.showFov
end, function(value)
	Config.aimbot.showFov = value
end)

aimRow.addToggle("Sticky", function()
	return Config.aimbot.sticky
end, function(value)
	Config.aimbot.sticky = value
end)

aimRow.addToggle("Auto Fire", function()
	return Config.aimbot.autoFire
end, function(value)
	Config.aimbot.autoFire = value
end)

aimRow.addToggle("Auto Scope", function()
	return Config.aimbot.autoScope
end, function(value)
	Config.aimbot.autoScope = value
	if not value then
		applyScope(false)
	end
end)

aimRow.addToggle("Hit Marker", function()
	return Config.aimbot.hitMarker
end, function(value)
	Config.aimbot.hitMarker = value
end)

aimRow.addToggle("Kill Notify", function()
	return Config.aimbot.killNotify
end, function(value)
	Config.aimbot.killNotify = value
end)

aimRow.addToggle("Target HUD", function()
	return Config.aimbot.targetHud
end, function(value)
	Config.aimbot.targetHud = value
end)

local rageRow = aimWindow.addRow("Ragebot", {
	get = function()
		return Config.rage.enabled
	end,
	toggle = function()
		Config.rage.enabled = not Config.rage.enabled
		if not Config.rage.enabled then
			Rage.player = nil
		end
	end,
})

rageRow.addToggle("Enabled", function()
	return Config.rage.enabled
end, function(value)
	Config.rage.enabled = value
	if not value then
		Rage.player = nil
	end
end)

rageRow.addSlider("FOV", 10, 180, 1, function()
	return Config.rage.fov
end, function(value)
	Config.rage.fov = value
end, " deg", 0)

rageRow.addDropdown("Target", { "Head", "Body", "Nearest" }, function()
	return Config.rage.part
end, function(value)
	Config.rage.part = value
end)

rageRow.addSlider("Prediction", 0, 25, 1, function()
	return Config.rage.prediction
end, function(value)
	Config.rage.prediction = value
end, "%", 0)

rageRow.addToggle("Wall Check", function()
	return Config.rage.wall
end, function(value)
	Config.rage.wall = value
end)

rageRow.addToggle("Team Check", function()
	return Config.rage.team
end, function(value)
	Config.rage.team = value
end)

rageRow.addToggle("Sticky", function()
	return Config.rage.sticky
end, function(value)
	Config.rage.sticky = value
end)

rageRow.addToggle("Auto Fire", function()
	return Config.rage.autoFire
end, function(value)
	Config.rage.autoFire = value
end)

local triggerRow = aimWindow.addRow("Triggerbot", {
	get = function()
		return Config.trigger.enabled
	end,
	toggle = function()
		Config.trigger.enabled = not Config.trigger.enabled
	end,
})

triggerRow.addToggle("Enabled", function()
	return Config.trigger.enabled
end, function(value)
	Config.trigger.enabled = value
end)

triggerRow.addSlider("Range", 20, 1000, 10, function()
	return Config.trigger.range
end, function(value)
	Config.trigger.range = value
end, " m", 0)

triggerRow.addSlider("Delay", 0, 500, 10, function()
	return Config.trigger.delay
end, function(value)
	Config.trigger.delay = value
end, " ms", 0)

triggerRow.addToggle("Team Check", function()
	return Config.trigger.team
end, function(value)
	Config.trigger.team = value
end)

--------------------------------------------------------------------------
-- ESP panel
--------------------------------------------------------------------------

local espRow = espWindow.addRow("ESP", {
	get = function()
		return Config.esp.enabled
	end,
	toggle = function()
		Config.esp.enabled = not Config.esp.enabled
		if Config.esp.enabled then
			toast("ESP enabled")
		end
	end,
})

espRow.addToggle("Enabled", function()
	return Config.esp.enabled
end, function(value)
	Config.esp.enabled = value
end)

espRow.addToggle("Boxes", function()
	return Config.esp.box
end, function(value)
	Config.esp.box = value
end)

espRow.addToggle("Box Fill", function()
	return Config.esp.fill
end, function(value)
	Config.esp.fill = value
end)

espRow.addToggle("Health Bar", function()
	return Config.esp.health
end, function(value)
	Config.esp.health = value
end)

espRow.addToggle("Names", function()
	return Config.esp.name
end, function(value)
	Config.esp.name = value
end)

espRow.addToggle("Distance", function()
	return Config.esp.distance
end, function(value)
	Config.esp.distance = value
end)

espRow.addToggle("Tracers", function()
	return Config.esp.tracer
end, function(value)
	Config.esp.tracer = value
end)

espRow.addToggle("Chams", function()
	return Config.esp.chams
end, function(value)
	Config.esp.chams = value
	if not value then
		clearChams()
	end
end)

espRow.addSlider("Max Distance", 50, 2000, 25, function()
	return Config.esp.maxDist
end, function(value)
	Config.esp.maxDist = value
end, " m", 0)

espRow.addToggle("Team Check", function()
	return Config.esp.team
end, function(value)
	Config.esp.team = value
end)

espRow.addToggle("Hide Knocked", function()
	return Config.esp.hideKnocked
end, function(value)
	Config.esp.hideKnocked = value
end)

espRow.addToggle("Skeleton", function()
	return Config.esp.skeleton
end, function(value)
	Config.esp.skeleton = value
end)

espRow.addToggle("Head Dot", function()
	return Config.esp.headDot
end, function(value)
	Config.esp.headDot = value
end)

espRow.addToggle("Off-screen Arrows", function()
	return Config.esp.arrows
end, function(value)
	Config.esp.arrows = value
end)

espRow.addToggle("Pickup ESP", function()
	return Config.esp.pickups
end, function(value)
	Config.esp.pickups = value
	if not value then
		clearPickups()
	end
end)

local skinRow = interfaceWindow.addRow("Skin Unlocker", {
	get = function()
		return Config.skin.enabled
	end,
	toggle = function()
		Config.skin.enabled = not Config.skin.enabled
		Skin.dirty = true
	end,
})

skinRow.addToggle("Enabled", function()
	return Config.skin.enabled
end, function(value)
	Config.skin.enabled = value
	Skin.dirty = true
end)

skinRow.addDropdown("Skin", { "Cyan", "Gold", "Crimson", "Violet", "Emerald", "Ice", "Pink", "White" }, function()
	return Config.skin.color
end, function(value)
	Config.skin.color = value
	Skin.dirty = true
end)

skinRow.addToggle("Rainbow", function()
	return Config.skin.rainbow
end, function(value)
	Config.skin.rainbow = value
	Skin.dirty = true
end)

skinRow.addDropdown("Material", { "Neon", "ForceField", "Glass", "Metal", "SmoothPlastic", "Plastic" }, function()
	return Config.skin.material
end, function(value)
	Config.skin.material = value
	Skin.dirty = true
end)

--------------------------------------------------------------------------
-- Movement panel
--------------------------------------------------------------------------

local speedRow = moveWindow.addRow("Walk Speed", {
	get = function()
		return Config.move.speed
	end,
	toggle = function()
		Config.move.speed = not Config.move.speed
	end,
})

speedRow.addToggle("Enabled", function()
	return Config.move.speed
end, function(value)
	Config.move.speed = value
end)

speedRow.addSlider("Speed", 16, 120, 1, function()
	return Config.move.speedValue
end, function(value)
	Config.move.speedValue = value
end, "", 0)

local jumpRow = moveWindow.addRow("Jump", {
	get = function()
		return Config.move.jump
	end,
	toggle = function()
		Config.move.jump = not Config.move.jump
	end,
})

jumpRow.addToggle("Enabled", function()
	return Config.move.jump
end, function(value)
	Config.move.jump = value
end)

jumpRow.addSlider("Power", 50, 250, 5, function()
	return Config.move.jumpValue
end, function(value)
	Config.move.jumpValue = value
end, "", 0)

jumpRow.addToggle("Infinite Jump", function()
	return Config.move.infiniteJump
end, function(value)
	Config.move.infiniteJump = value
end)

jumpRow.addToggle("Auto Jump", function()
	return Config.move.autoJump
end, function(value)
	Config.move.autoJump = value
end)

local flyRow = moveWindow.addRow("Fly", {
	get = function()
		return Config.move.fly
	end,
	toggle = function()
		Config.move.fly = not Config.move.fly
		if not Config.move.fly then
			stopFly()
		end
	end,
})

flyRow.addToggle("Enabled", function()
	return Config.move.fly
end, function(value)
	Config.move.fly = value
	if not value then
		stopFly()
	end
end)

flyRow.addSlider("Speed", 10, 300, 5, function()
	return Config.move.flySpeed
end, function(value)
	Config.move.flySpeed = value
end, "", 0)

flyRow.addInfo("Space / LeftControl for up and down")

local noclipRow = moveWindow.addRow("Noclip", {
	get = function()
		return Config.move.noclip
	end,
	toggle = function()
		Config.move.noclip = not Config.move.noclip
		if not Config.move.noclip then
			restoreNoclip()
		end
	end,
})

noclipRow.addToggle("Enabled", function()
	return Config.move.noclip
end, function(value)
	Config.move.noclip = value
	if not value then
		restoreNoclip()
	end
end)

local cameraRow = moveWindow.addRow("Camera FOV", {
	get = function()
		return Config.move.fov
	end,
	toggle = function()
		Config.move.fov = not Config.move.fov
	end,
})

cameraRow.addToggle("Enabled", function()
	return Config.move.fov
end, function(value)
	Config.move.fov = value
end)

cameraRow.addSlider("FOV", 30, 120, 1, function()
	return Config.move.fovValue
end, function(value)
	Config.move.fovValue = value
end, " deg", 0)

--------------------------------------------------------------------------
-- Extra interface rows
--------------------------------------------------------------------------

local worldRow = interfaceWindow.addRow("World Visuals", {
	get = function()
		return Config.visual.fullbright
	end,
	toggle = function()
		Config.visual.fullbright = not Config.visual.fullbright
	end,
})

worldRow.addToggle("Fullbright", function()
	return Config.visual.fullbright
end, function(value)
	Config.visual.fullbright = value
end)

worldRow.addToggle("No Fog", function()
	return Config.visual.noFog
end, function(value)
	Config.visual.noFog = value
end)

local crosshairRow = interfaceWindow.addRow("Crosshair", {
	get = function()
		return Config.visual.crosshair
	end,
	toggle = function()
		Config.visual.crosshair = not Config.visual.crosshair
	end,
})

crosshairRow.addToggle("Custom Crosshair", function()
	return Config.visual.crosshair
end, function(value)
	Config.visual.crosshair = value
end)

crosshairRow.addSlider("Length", 2, 24, 1, function()
	return Config.visual.crosshairSize
end, function(value)
	Config.visual.crosshairSize = value
end, " px", 0)

local hudRow = interfaceWindow.addRow("HUD", {
	get = function()
		return Config.visual.watermark
	end,
	toggle = function()
		Config.visual.watermark = not Config.visual.watermark
	end,
})

hudRow.addToggle("Watermark", function()
	return Config.visual.watermark
end, function(value)
	Config.visual.watermark = value
end)

hudRow.addToggle("Clock", function()
	return Config.visual.clock
end, function(value)
	Config.visual.clock = value
end)

hudRow.addToggle("Player Count", function()
	return Config.visual.playerCount
end, function(value)
	Config.visual.playerCount = value
end)

local pendingDestroy
local function unloadClient()
	if pendingDestroy then
		pendingDestroy()
	end
end

--------------------------------------------------------------------------
-- Interface panel
--------------------------------------------------------------------------

local interfaceRow = interfaceWindow.addRow("Interface", {})

interfaceRow.addButton("Hide UI", function()
	UI.setVisible(false)
	toast("Tap the ninja icon to return")
end)

interfaceRow.addButton("Unload Client", function()
	unloadClient()
end)

interfaceRow.addInfo("Insert - show or hide UI")
interfaceRow.addInfo("RightShift - unload")
interfaceRow.addInfo("Tap a name to toggle it")
interfaceRow.addInfo("Tap + for settings")
interfaceRow.addInfo("v1.1.0 - 45+ features")

--------------------------------------------------------------------------
-- Floating ninja icon
--------------------------------------------------------------------------

local startSize = viewport()
local iconX = math.max(math.floor(startSize.X / SCALE - 60), 8)
local iconY = math.floor(startSize.Y / SCALE * 0.42)
local icon = create("TextButton", {
	Name = "NinjaIcon",
	AutoButtonColor = false,
	BackgroundColor3 = Theme.panel,
	BackgroundTransparency = 0.02,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBlack,
	Text = "N",
	TextSize = px(28),
	TextColor3 = Theme.accent,
	Position = UDim2.fromOffset(px(iconX), px(iconY)),
	Size = UDim2.fromOffset(px(52), px(52)),
}, iconGui)
create("UICorner", { CornerRadius = UDim.new(1, 0) }, icon)
create("UIStroke", {
	Color = Theme.accent,
	Thickness = px(2),
	Transparency = 0.05,
}, icon)

bindDrag(icon, function()
	icon.baseX = iconX
	icon.baseY = iconY
end, function(delta)
	local size = viewport()
	local maxX = math.max(size.X / SCALE - 52, 0)
	iconX = math.clamp(icon.baseX + delta.X / SCALE, 0, maxX)
	iconY = math.clamp(icon.baseY + delta.Y / SCALE, 0, math.max(size.Y / SCALE - 52, 0))
	if iconX > maxX - 18 then
		iconX = maxX
	elseif iconX < 18 then
		iconX = 0
	end
	icon.Position = UDim2.fromOffset(px(iconX), px(iconY))
end, function()
	UI.setVisible(not UI.visible)
end)

--------------------------------------------------------------------------
-- Render loop
--------------------------------------------------------------------------

local fovCircle = newDrawing("Circle")

local function updateFovCircle()
	if not fovCircle then
		return
	end
	local camera = workspace.CurrentCamera
	local settings = Config.aimbot
	if not camera or not settings.enabled or not settings.showFov then
		fovCircle.Visible = false
		return
	end
	local size = camera.ViewportSize
	fovCircle.Position = Vector2.new(size.X * 0.5, size.Y * 0.5)
	fovCircle.Radius = screenRadius(camera, settings.fov)
	fovCircle.Color = Theme.accent
	fovCircle.Thickness = 1
	fovCircle.Transparency = 0.65
	fovCircle.NumSides = 72
	fovCircle.Filled = false
	fovCircle.Visible = true
end

local fpsFrames = 0
local fpsClock = 0
local fpsValue = 60
local hudClock = 0

local function updateHud(delta)
	fpsFrames = fpsFrames + 1
	fpsClock = fpsClock + delta
	if fpsClock >= 0.5 then
		fpsValue = math.floor(fpsFrames / fpsClock + 0.5)
		fpsFrames = 0
		fpsClock = 0
	end

	hudClock = hudClock + delta
	if hudClock < 0.2 then
		return
	end
	hudClock = 0

	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		local position = root.Position
		coordsLabel.Text = string.format("X  %.1f\nY  %.1f\nZ  %.1f", position.X, position.Y, position.Z)
	else
		coordsLabel.Text = "X  --\nY  --\nZ  --"
	end

	local ping = 0
	pcall(function()
		ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
	end)
	local targetName = "-"
	local tracked = Config.rage.enabled and Rage.player or Aim.player
	if tracked then
		targetName = tracked.Name
	end
	local lines = { string.format("FPS: %d", fpsValue), string.format("Ping: %d ms", ping) }
	if Config.visual.clock then
		local ok, stamp = pcall(function()
			return os.date("%H:%M")
		end)
		lines[#lines + 1] = "Time: " .. (ok and stamp or "--:--")
	end
	if Config.visual.playerCount then
		lines[#lines + 1] = "Players: " .. tostring(#Players:GetPlayers())
	end
	lines[#lines + 1] = "Target: " .. targetName
	statsLabel.Text = table.concat(lines, "\n")
	watermarkLabel.Visible = Config.visual.watermark and true or false
	if Config.visual.watermark then
		watermarkLabel.Text = string.format("ninja / rivals  |  %d fps  |  %d ms  |  %d online", fpsValue, ping, #Players:GetPlayers())
	end
end

local function onRender(delta)
	rageStep()
	if not Config.rage.enabled then
		aimStep(delta)
	end
	triggerStep()
	updateEsp()
	updatePickups(delta)
	updateTargetHud()
	updateCrosshair()
	updateHitMarker()
	updateMovement(delta)
	World.clock = (World.clock or 0) + delta
	if World.clock >= 0.25 then
		World.clock = 0
		updateWorldVisuals()
	end

	if Config.skin.enabled then
		Skin.clock = Skin.clock + delta
		local interval = Config.skin.rainbow and 0.12 or 1
		if Skin.clock >= interval or Skin.dirty then
			Skin.clock = 0
			Skin.dirty = false
			skinRefresh()
		end
	elseif next(Skin.originals) then
		skinRefresh()
	end

	updateFovCircle()
	updateHud(delta)
end

RunService:BindToRenderStep("NinjaRivals", Enum.RenderPriority.Camera.Value + 20, onRender)

local lateConnections = {}
local preRenderOk = pcall(function()
	table.insert(lateConnections, RunService.PreRender:Connect(enforceAim))
end)
if not preRenderOk then
	table.insert(lateConnections, RunService.RenderStepped:Connect(enforceAim))
end

--------------------------------------------------------------------------
-- Input and teardown
--------------------------------------------------------------------------

local inputConnections = {}

table.insert(inputConnections, UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		Aim.holdingMouse = true
	elseif input.KeyCode == Enum.KeyCode.Q then
		Aim.holdingKey = true
	elseif input.KeyCode == Enum.KeyCode.Insert then
		UI.setVisible(not UI.visible)
	elseif input.KeyCode == Enum.KeyCode.RightShift then
		unloadClient()
	end
end))

table.insert(inputConnections, UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		Aim.holdingMouse = false
	elseif input.KeyCode == Enum.KeyCode.Q then
		Aim.holdingKey = false
	end
end))

table.insert(inputConnections, Players.PlayerRemoving:Connect(function(player)
	Aim.cache[player] = nil
	local entry = ESP.entries[player]
	if entry then
		releaseEspEntry(entry)
		ESP.entries[player] = nil
	end
end))

pendingDestroy = function()
	RunService:UnbindFromRenderStep("NinjaRivals")
	for _, connection in ipairs(inputConnections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	for _, connection in ipairs(lateConnections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	lateConnections = {}
	Aim.lockPoint = nil
	Aim.lockCFrame = nil
	CameraState.releaseFrom = nil
	restoreCameraType(workspace.CurrentCamera)
	inputConnections = {}

	for player, entry in pairs(ESP.entries) do
		releaseEspEntry(entry)
		ESP.entries[player] = nil
	end
	clearChams()
	shutdownMovement()
	Config.visual.fullbright = false
	Config.visual.noFog = false
	updateWorldVisuals()
	clearPickups()
	for _, line in ipairs(Cross.lines) do
		removeDrawing(line)
	end
	Cross.lines = {}
	removeDrawing(Cross.dot)
	Cross.dot = nil
	for _, line in ipairs(HitMark.lines) do
		removeDrawing(line)
	end
	HitMark.lines = {}
	removeDrawing(targetHud)
	removeDrawing(fovCircle)
	fovCircle = nil
	if gui then
		gui:Destroy()
	end
	if iconGui then
		iconGui:Destroy()
	end
	if _G.NinjaRivals then
		_G.NinjaRivals = nil
	end
	pendingDestroy = nil
end

_G.NinjaRivals = {
	version = "1.1.0",
	config = Config,
	destroy = function()
		if pendingDestroy then
			pendingDestroy()
		end
	end,
}

UI.sync()
toast("Ninja loaded - tap the icon to hide")

if not DRAW_OK then
	toast("Drawing API missing - ESP disabled")
	Config.esp.enabled = false
	UI.sync()
end
