--[[
	Hilix  /  Rivals
	Hilix cheats interface for Roblox Rivals - sleepy-style panel.
	Built for Delta on phone and PC.

	Execute:
		loadstring(game:HttpGet("https://raw.githubusercontent.com/njjjjjhij/rivals-ninja/main/RivalsClient.lua"))()

	Tap the round H icon to hide or show the interface.
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

if _G.HilixRivals and typeof(_G.HilixRivals) == "table" and _G.HilixRivals.destroy then
	pcall(_G.HilixRivals.destroy)
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
		maxDist = 1500,
		offset = 0,
		delay = 0,
		switchDelay = 0,
		curve = "Exponential",
		priority = "Crosshair",
		ignoreKnocked = false,
		fireDelay = 50,
		lockLine = false,
		targetDot = false,
		stickyPower = 500,
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
		maxDist = 1500,
		switchDelay = 0,
		snap = "Instant",
		fireRate = 12,
		autoScope = false,
		ignoreKnocked = false,
	},
	trigger = {
		enabled = false,
		range = 150,
		delay = 80,
		team = false,
		fovMode = false,
		fov = 40,
		chance = 100,
		maxDist = 1000,
		ignoreKnocked = false,
		burst = 1,
		wall = true,
	},
	skin = {
		enabled = false,
		color = "Cyan",
		material = "Neon",
		rainbow = false,
		rainbowSpeed = 0.25,
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
		boxStyle = "Box",
		healthText = false,
		textSize = 13,
		opacity = 1,
		tracerFrom = "Bottom",
		teamColor = false,
		chamFill = 0.62,
		skeletonThickness = 1,
		arrowSize = 12,
		headDotSize = 6,
		nameMode = "DisplayName",
	},
	visual = {
		fullbright = false,
		noFog = false,
		crosshair = true,
		crosshairSize = 9,
		watermark = false,
		clock = true,
		playerCount = true,
		noEffects = false,
		customTime = false,
		time = 14,
		customBrightness = false,
		brightness = 2,
		crosshairStyle = "Cross",
		crosshairGap = 3,
		crosshairThickness = 1,
		coords = true,
		uiScale = 1,
		uiTransparency = 0.08,
		iconSize = 50,
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
		hipHeight = false,
		hipHeightValue = 2,
		gravity = false,
		gravityValue = 196.2,
		cameraDist = false,
		cameraDistValue = 20,
		flyMode = "Camera",
	},
	radar = {
		enabled = false,
		size = 110,
		range = 300,
		opacity = 0.85,
		names = false,
		dotSize = 4,
	},
	logs = {
		hitLog = true,
		killFeed = true,
		damageNumbers = false,
		duration = 3,
		maxLines = 5,
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
	acquired = nil,
	lastSwitch = 0,
	lastAuto = 0,
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
			local character, humanoid, root, head = getCharacter(player)
			local knocked = settings.ignoreKnocked and character and isKnocked(player, character, humanoid)
			if character and not knocked then
				local part = partFor(character, head, root, settings.part, origin)
				if part then
					local screen, onScreen = camera:WorldToViewportPoint(part.Position)
					if onScreen and screen.Z > 0 then
						local offsetX = screen.X - center.X
						local offsetY = screen.Y - center.Y
						local screenDistance = math.sqrt(offsetX * offsetX + offsetY * offsetY)
						local worldDistance = (part.Position - origin).Magnitude
						if screenDistance <= radius and worldDistance <= (settings.maxDist or 1500) then
							if not settings.wall or canSee(player, camera, character, part) then
								local score
								if settings.priority == "Distance" then
									score = worldDistance
								elseif settings.priority == "Low HP" then
									score = humanoid and humanoid.Health or 1000
								else
									score = screenDistance + worldDistance * 0.02
								end
								if settings.sticky and current and player == current then
									score = score - radius - (settings.stickyPower or 500)
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
local Trigger = { last = 0, lastBurst = 0, burstLeft = 0 }
local FX = { hitUntil = 0 }
local notify = function() end
local pushLog = function() end
local clearLog = function() end
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
		local rate = math.max(smooth, 0.1)
		local alpha
		local curve = Config.aimbot.curve
		if curve == "Linear" then
			alpha = math.clamp(rate * delta, 0, 1)
		elseif curve == "Spring" then
			alpha = math.clamp((1 - math.exp(-rate * delta)) * 1.6, 0, 1)
		else
			alpha = 1 - math.exp(-rate * delta)
		end
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

	local now = os.clock()
	if player ~= Aim.player then
		if Aim.player and (settings.switchDelay or 0) > 0 and now - (Aim.lastSwitch or 0) < settings.switchDelay / 1000 then
			return
		end
		Aim.player = player
		Aim.point = nil
		Aim.acquired = now
		Aim.lastSwitch = now
	end
	if (settings.delay or 0) > 0 and Aim.acquired and now - Aim.acquired < settings.delay / 1000 then
		return
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
			local damage = math.floor((Aim.lastHealth - humanoid.Health) + 0.5)
			if damage > 0 then
				pushLog(string.format("hit %s  -%d", player.DisplayName or player.Name, damage), Theme.bad, "hit")
			end
			if settings.killNotify and humanoid.Health <= 0 then
				notify("Eliminated " .. (player.DisplayName or player.Name))
			end
		end
		Aim.lastHealth = humanoid.Health
	end

	local aimPoint = part.Position + Vector3.new(0, settings.offset or 0, 0)
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
				if now - (Aim.lastAuto or 0) >= (settings.fireDelay or 50) / 1000 then
					Aim.lastAuto = now
					fireWeapon()
				end
			end
		end
	end
end

local function rageStep(delta)
	local settings = Config.rage
	if not settings.enabled then
		Rage.player = nil
		if not (Config.aimbot.enabled and Config.aimbot.autoScope) then
			applyScope(false)
		end
		return
	end
	local now = os.clock()
	local player, part = pickTarget(settings, Rage.player)
	if player ~= Rage.player and Rage.player and (settings.switchDelay or 0) > 0 and now - (Rage.lastSwitch or 0) < settings.switchDelay / 1000 then
		return
	end
	if player ~= Rage.player then
		Rage.lastSwitch = now
	end
	Rage.player = player
	if not player or not part then
		if not (Config.aimbot.enabled and Config.aimbot.autoScope) then
			applyScope(false)
		end
		beginRelease()
		return
	end
	local point = part.Position
	local velocity = part.AssemblyLinearVelocity
	if settings.prediction > 0 and velocity then
		point = point + velocity * (settings.prediction / 100)
	end
	if settings.autoScope then
		applyScope(true)
	end
	if settings.snap == "Smooth" then
		aimCamera(point, 24, 900, delta or (1 / 60), false, 0)
	else
		aimCamera(point, 1, 99999, 0, true, 0)
	end
	Aim.lockPoint = point
	if settings.autoFire then
		local rate = 1 / math.max(settings.fireRate or 12, 1)
		if now - (Rage.lastFire or 0) >= rate then
			Rage.lastFire = now
			fireWeapon()
		end
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
	if (Trigger.burstLeft or 0) > 0 then
		if now - (Trigger.lastBurst or 0) >= 0.06 then
			Trigger.lastBurst = now
			Trigger.burstLeft = Trigger.burstLeft - 1
			fireWeapon()
		end
		return
	end
	if now - Trigger.last < settings.delay / 1000 then
		return
	end
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local target = nil
	if settings.fovMode then
		target = pickTarget({
			fov = settings.fov,
			part = "Head",
			wall = settings.wall,
			team = settings.team,
			maxDist = settings.maxDist,
			ignoreKnocked = settings.ignoreKnocked,
			priority = "Crosshair",
		}, nil)
	else
		local filter = { camera }
		if LocalPlayer.Character then
			filter[#filter + 1] = LocalPlayer.Character
		end
		triggerParams.FilterDescendantsInstances = filter
		local hit = workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * settings.range, triggerParams)
		if hit and hit.Instance then
			target = playerFromPart(hit.Instance)
		end
	end

	if not target or target == LocalPlayer then
		return
	end
	if settings.team and sameTeam(target) then
		return
	end
	local character = target.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	if settings.ignoreKnocked and isKnocked(target, character, humanoid) then
		return
	end
	if math.random() * 100 > (settings.chance or 100) then
		return
	end
	Trigger.last = now
	Trigger.lastBurst = now
	Trigger.burstLeft = math.max((settings.burst or 1) - 1, 0)
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
		healthText = newDrawing("Text"),
		arrow = newDrawing("Triangle"),
		skeleton = {},
		corner = {},
	}
	return entry
end

local function releaseEspEntry(entry)
	for _, line in ipairs(entry.skeleton or {}) do
		removeDrawing(line)
	end
	entry.skeleton = {}
	for _, line in ipairs(entry.corner or {}) do
		removeDrawing(line)
	end
	entry.corner = {}
	for _, object in pairs(entry) do
		removeDrawing(object)
	end
end

local function setCham(character)
	if ESP.chams[character] and ESP.chams[character].Parent then
		return
	end
	local highlight = Instance.new("Highlight")
	highlight.Name = "HilixHighlight"
	highlight.Adornee = character
	highlight.FillColor = Theme.accent
	highlight.FillTransparency = Config.esp.chamFill or 0.62
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
							local tip = math.max(settings.arrowSize or 12, 6)
							local half = tip * 0.6
							arrow.PointA = Vector2.new(tipX, tipY)
							arrow.PointB = Vector2.new(tipX - ux * px(tip) - uy * px(half), tipY - uy * px(tip) + ux * px(half))
							arrow.PointC = Vector2.new(tipX - ux * px(tip) + uy * px(half), tipY - uy * px(tip) - ux * px(half))
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
					transparency = 1 - (1 - transparency) * (settings.opacity or 1)
					local color = Theme.accent
					if settings.teamColor and player.TeamColor then
						color = player.TeamColor.Color
					end

					if settings.box and settings.boxStyle ~= "Corners" then
						setSquare(entry.box, Vector2.new(left, topY), Vector2.new(width, height), color, 1, transparency, false)
					else
						hideDrawing(entry.box)
					end

					if settings.box and settings.boxStyle == "Corners" then
						local reach = math.min(width, height) * 0.22
						local points = {
							{ left, topY, left + reach, topY },
							{ left, topY, left, topY + reach },
							{ left + width, topY, left + width - reach, topY },
							{ left + width, topY, left + width, topY + reach },
							{ left, bottomY, left + reach, bottomY },
							{ left, bottomY, left, bottomY - reach },
							{ left + width, bottomY, left + width - reach, bottomY },
							{ left + width, bottomY, left + width, bottomY - reach },
						}
						for index, point in ipairs(points) do
							local line = entry.corner[index]
							if not line then
								line = newDrawing("Line")
								entry.corner[index] = line
							end
							setLine(line, Vector2.new(point[1], point[2]), Vector2.new(point[3], point[4]), color, 1, transparency)
						end
					else
						for _, line in ipairs(entry.corner) do
							hideDrawing(line)
						end
					end

					if settings.fill then
						setSquare(entry.fill, Vector2.new(left + 1, topY + 1), Vector2.new(math.max(width - 2, 1), math.max(height - 2, 1)), color, 1, 0.86, true)
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

					if settings.healthText and humanoid then
						setText(entry.healthText, tostring(math.floor(humanoid.Health + 0.5)), Vector2.new(left - px(11), topY + height * 0.5), Theme.text, px(9))
					else
						hideDrawing(entry.healthText)
					end

					if settings.name then
						local label = player.DisplayName or player.Name
						if settings.nameMode == "Name" then
							label = player.Name
						elseif settings.nameMode == "Both" then
							label = (player.DisplayName or player.Name) .. " (" .. player.Name .. ")"
						end
						setText(entry.name, label, Vector2.new(centerX, topY - px(17)), Theme.text, px(settings.textSize or 13))
					else
						hideDrawing(entry.name)
					end

					if settings.distance then
						setText(entry.distance, string.format("%d m", math.floor(distance + 0.5)), Vector2.new(centerX, bottomY + px(2)), color, px(math.max((settings.textSize or 13) - 2, 8)))
					else
						hideDrawing(entry.distance)
					end

					if settings.tracer and entry.tracer then
						local fromY = settings.tracerFrom == "Center" and size.Y * 0.5 or size.Y
						entry.tracer.From = Vector2.new(size.X * 0.5, fromY)
						entry.tracer.To = Vector2.new(centerX, bottomY)
						entry.tracer.Color = color
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
									setLine(line, Vector2.new(pointA.X, pointA.Y), Vector2.new(pointB.X, pointB.Y), Theme.text, math.max(settings.skeletonThickness or 1, 1), math.max(transparency - 0.12, 0.05))
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
							local dot = math.max(settings.headDotSize or 6, 2)
							setSquare(entry.headDot, Vector2.new(headPoint.X - px(dot * 0.5), headPoint.Y - px(dot * 0.5)), Vector2.new(px(dot), px(dot)), Theme.bad, 1, 0.15, true)
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
		color = Color3.fromHSV((os.clock() * (Config.skin.rainbowSpeed or 0.25)) % 1, 0.85, 1)
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

local World = { saved = nil, fog = nil, effects = nil, clock = 0 }

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

	if settings.customBrightness then
		lighting.Brightness = settings.brightness
	end
	if settings.customTime then
		lighting.ClockTime = settings.time
	end

	if settings.noEffects then
		if not World.effects then
			World.effects = true
			for _, object in ipairs(lighting:GetChildren()) do
				if object:IsA("ColorCorrectionEffect") or object:IsA("BlurEffect") or object:IsA("SunRaysEffect") or object:IsA("DepthOfFieldEffect") then
					object.Enabled = false
				end
			end
		end
	elseif World.effects then
		for _, object in ipairs(lighting:GetChildren()) do
			if object:IsA("ColorCorrectionEffect") or object:IsA("BlurEffect") or object:IsA("SunRaysEffect") or object:IsA("DepthOfFieldEffect") then
				object.Enabled = true
			end
		end
		World.effects = nil
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
	hipApplied = false,
	baseHip = nil,
	gravityApplied = false,
	baseGravity = nil,
	camApplied = false,
	baseCamMax = nil,
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

	if settings.hipHeight then
		if not Move.hipApplied then
			Move.baseHip = humanoid.HipHeight
			Move.hipApplied = true
		end
		humanoid.HipHeight = settings.hipHeightValue
	elseif Move.hipApplied then
		humanoid.HipHeight = Move.baseHip or 2
		Move.hipApplied = false
	end

	if settings.gravity then
		if not Move.gravityApplied then
			Move.baseGravity = workspace.Gravity
			Move.gravityApplied = true
		end
		workspace.Gravity = settings.gravityValue
	elseif Move.gravityApplied then
		workspace.Gravity = Move.baseGravity or 196.2
		Move.gravityApplied = false
	end

	if settings.cameraDist then
		if not Move.camApplied then
			Move.baseCamMax = LocalPlayer.CameraMaxZoomDistance
			Move.camApplied = true
		end
		LocalPlayer.CameraMaxZoomDistance = settings.cameraDistValue
		LocalPlayer.CameraMinZoomDistance = math.min(settings.cameraDistValue, 12)
	elseif Move.camApplied then
		LocalPlayer.CameraMaxZoomDistance = Move.baseCamMax or 128
		Move.camApplied = false
	end

	if settings.fly then
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			if not Move.flyBody then
				local body = Instance.new("BodyVelocity")
				body.Name = "HilixFly"
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
			local direction = look
			if settings.flyMode == "Horizontal" then
				local flat = Vector3.new(look.X, 0, look.Z)
				if flat.Magnitude > 0.01 then
					direction = flat.Unit
				end
			end
			local velocity = direction * settings.flySpeed
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
	Config.move.hipHeight = false
	Config.move.gravity = false
	Config.move.cameraDist = false
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
	if Move.humanoid then
		if Move.hipApplied then
			pcall(function()
				Move.humanoid.HipHeight = Move.baseHip or 2
			end)
		end
	end
	if Move.gravityApplied then
		pcall(function()
			workspace.Gravity = Move.baseGravity or 196.2
		end)
	end
	if Move.camApplied then
		pcall(function()
			LocalPlayer.CameraMaxZoomDistance = Move.baseCamMax or 128
		end)
	end
	Move.speedApplied = false
	Move.jumpApplied = false
	Move.fovApplied = false
	Move.hipApplied = false
	Move.gravityApplied = false
	Move.camApplied = false
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

local Cross = { lines = {}, dot = nil, circle = nil }

local function updateCrosshair()
	if not DRAW_OK then
		return
	end
	if #Cross.lines == 0 then
		for index = 1, 4 do
			Cross.lines[index] = newDrawing("Line")
		end
				Cross.dot = newDrawing("Square")
		Cross.circle = newDrawing("Circle")
	end
	local camera = workspace.CurrentCamera
	if not camera or not Config.visual.crosshair then
		for _, line in ipairs(Cross.lines) do
			hideDrawing(line)
		end
		hideDrawing(Cross.dot)
		hideDrawing(Cross.circle)
		return
	end
	local size = camera.ViewportSize

	local cx, cy = size.X * 0.5, size.Y * 0.5
	local gap = px(Config.visual.crosshairGap or 3)
	local length = px(Config.visual.crosshairSize)
	local thickness = math.max(Config.visual.crosshairThickness or 1, 1)
	local style = Config.visual.crosshairStyle or "Cross"

	if style == "Cross" then
		setLine(Cross.lines[1], Vector2.new(cx - gap - length, cy), Vector2.new(cx - gap, cy), Theme.accent, thickness, 0.15)
		setLine(Cross.lines[2], Vector2.new(cx + gap, cy), Vector2.new(cx + gap + length, cy), Theme.accent, thickness, 0.15)
		setLine(Cross.lines[3], Vector2.new(cx, cy - gap - length), Vector2.new(cx, cy - gap), Theme.accent, thickness, 0.15)
		setLine(Cross.lines[4], Vector2.new(cx, cy + gap), Vector2.new(cx, cy + gap + length), Theme.accent, thickness, 0.15)
		setSquare(Cross.dot, Vector2.new(cx - 1, cy - 1), Vector2.new(2, 2), Theme.accent, 1, 0.1, true)
		hideDrawing(Cross.circle)
	elseif style == "Dot" then
		for _, line in ipairs(Cross.lines) do
			hideDrawing(line)
		end
		hideDrawing(Cross.circle)
		setSquare(Cross.dot, Vector2.new(cx - px(2), cy - px(2)), Vector2.new(px(4), px(4)), Theme.accent, 1, 0.1, true)
	else
		for _, line in ipairs(Cross.lines) do
			hideDrawing(line)
		end
		hideDrawing(Cross.dot)
		Cross.circle.Position = Vector2.new(cx, cy)
		Cross.circle.Radius = px(Config.visual.crosshairSize)
		Cross.circle.Color = Theme.accent
		Cross.circle.Thickness = thickness
		Cross.circle.Transparency = 0.2
		Cross.circle.NumSides = 48
		Cross.circle.Filled = false
		Cross.circle.Visible = true
	end
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
-- Hilix interface
--------------------------------------------------------------------------

local HX = {
	panel = Color3.fromRGB(14, 14, 16),
	panel2 = Color3.fromRGB(19, 19, 22),
	line = Color3.fromRGB(40, 40, 45),
	accent = Color3.fromRGB(236, 62, 48),
	accentSoft = Color3.fromRGB(255, 112, 84),
	text = Color3.fromRGB(238, 238, 242),
	dim = Color3.fromRGB(152, 152, 160),
	muted = Color3.fromRGB(98, 98, 106),
	box = Color3.fromRGB(30, 30, 34),
}

local toast

local UI = {
	visible = true,
	syncers = {},
	pages = {},
	navButtons = {},
	tabButtons = {},
	tweaks = { iconSize = function() end },
	current = "main",
}

local gui = Instance.new("ScreenGui")
gui.Name = "HilixCheats"
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
iconGui.Name = "HilixIcon"
iconGui.ResetOnSpawn = false
iconGui.IgnoreGuiInset = true
iconGui.DisplayOrder = 501

local iconParentOk = pcall(function()
	iconGui.Parent = game:GetService("CoreGui")
end)
if not iconParentOk then
	iconGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 10)
end

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

local viewportSize = viewport()
local panelWidth = math.clamp(math.floor(viewportSize.X / SCALE - 24), 430, 560)
local panelX = math.floor((viewportSize.X / SCALE - panelWidth) * 0.5)
local panelY = 64
local panelHeight = math.clamp(math.floor(viewportSize.Y / SCALE - panelY - 16), 270, 392)

local panel = create("Frame", {
	Name = "HilixPanel",
	BackgroundColor3 = HX.panel,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(px(panelX), px(panelY)),
	Size = UDim2.fromOffset(px(panelWidth), px(panelHeight)),
	ClipsDescendants = true,
}, root)
create("UICorner", { CornerRadius = UDim.new(0, px(5)) }, panel)
create("UIStroke", {
	Color = HX.line,
	Thickness = 1,
	Transparency = 0.15,
}, panel)
local panelScale = create("UIScale", { Scale = 1 }, panel)

local headerHeight = 26
local header = create("Frame", {
	Name = "Header",
	BackgroundColor3 = HX.panel2,
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, px(headerHeight)),
}, panel)
create("Frame", {
	BackgroundColor3 = HX.line,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 1, -1),
	Size = UDim2.new(1, 0, 0, 1),
}, header)

local logo = create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(px(9), 0),
	Size = UDim2.fromOffset(px(74), px(headerHeight)),
	Font = Enum.Font.GothamBold,
	Text = "hilix.gg",
	TextSize = px(13),
	TextColor3 = HX.accent,
	TextXAlignment = Enum.TextXAlignment.Left,
}, header)

create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(px(70), 0),
	Size = UDim2.fromOffset(px(50), px(headerHeight)),
	Font = Enum.Font.Gotham,
	Text = "cheats",
	TextSize = px(9),
	TextColor3 = HX.muted,
	TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local function showPage(name)
	UI.current = name
	for key, page in pairs(UI.pages) do
		page.Visible = key == name
	end
	for key, button in pairs(UI.navButtons) do
		local active = key == name
		button.TextColor3 = active and HX.text or HX.dim
		if button.Marker then
			button.Marker.Visible = active
		end
	end
	for key, button in pairs(UI.tabButtons) do
		button.TextColor3 = key == name and HX.accent or HX.muted
	end
end

local tabNames = {
	{ "rage", "rage" },
	{ "visuals", "esp" },
	{ "misc", "movement" },
	{ "skins", "skins" },
	{ "settings", "config" },
}
local tabX = px(120)
for _, entry in ipairs(tabNames) do
	local label, pageName = entry[1], entry[2]
	local tab = create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(tabX, 0),
		Size = UDim2.fromOffset(px(44), px(headerHeight)),
		Font = Enum.Font.GothamMedium,
		Text = label,
		TextSize = px(10),
		TextColor3 = HX.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, header)
	tabX = tabX + px(44)
	UI.tabButtons[pageName] = tab
	bindTap(tab, function()
		showPage(pageName)
	end)
end

local closeButton = create("TextButton", {
	AutoButtonColor = false,
	BackgroundTransparency = 1,
	Position = UDim2.new(1, -px(26), 0, 0),
	Size = UDim2.fromOffset(px(24), px(headerHeight)),
	Font = Enum.Font.GothamBold,
	Text = "x",
	TextSize = px(13),
	TextColor3 = HX.dim,
}, header)
bindTap(closeButton, function()
	UI.setVisible(false)
	toast("hilix hidden - tap H")
end)

bindDrag(header, function()
	panel._baseX = panel.Position.X.Offset / SCALE
	panel._baseY = panel.Position.Y.Offset / SCALE
end, function(delta)
	local size = viewport()
	local maxX = math.max(size.X / SCALE - panelWidth, 0)
	local maxY = math.max(size.Y / SCALE - px(headerHeight), 0)
	local x = math.clamp(panel._baseX + delta.X / SCALE, 0, maxX)
	local y = math.clamp(panel._baseY + delta.Y / SCALE, 0, maxY)
	panel.Position = UDim2.fromOffset(px(x), px(y))
end)

local sidebarWidth = 62
local sidebar = create("Frame", {
	Name = "Sidebar",
	BackgroundColor3 = HX.panel2,
	BackgroundTransparency = 0.55,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(0, px(headerHeight)),
	Size = UDim2.fromOffset(px(sidebarWidth), px(panelHeight) - px(headerHeight)),
}, panel)
create("Frame", {
	BackgroundColor3 = HX.line,
	BackgroundTransparency = 0.4,
	BorderSizePixel = 0,
	Position = UDim2.new(1, -1, 0, 0),
	Size = UDim2.new(0, 1, 1, 0),
}, sidebar)
create("UIListLayout", {
	FillDirection = Enum.FillDirection.Vertical,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, px(1)),
}, sidebar)

local content = create("Frame", {
	Name = "Content",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(px(sidebarWidth), px(headerHeight)),
	Size = UDim2.new(1, -px(sidebarWidth), 1, -px(headerHeight)),
}, panel)

local function makePage(name)
	local page = create("ScrollingFrame", {
		Name = name,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 0,
		Visible = false,
	}, content)
	UI.pages[name] = page
	return page
end

local navItems = {
	{ "main", "main" },
	{ "aim", "aim" },
	{ "rage", "rage" },
	{ "trigger", "trigger" },
	{ "esp", "esp" },
	{ "visuals", "visuals" },
	{ "move", "movement" },
	{ "skins", "skins" },
	{ "radar", "radar" },
	{ "logs", "logs" },
	{ "config", "config" },
}
for index, entry in ipairs(navItems) do
	local label, pageName = entry[1], entry[2]
	local button = create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, px(20)),
		LayoutOrder = index,
		Font = Enum.Font.GothamMedium,
		Text = "  " .. label,
		TextSize = px(9),
		TextColor3 = HX.dim,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, sidebar)
	button.Marker = create("Frame", {
		BackgroundColor3 = HX.accent,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, px(6)),
		Size = UDim2.fromOffset(px(2), px(12)),
		Visible = false,
	}, button)
	UI.navButtons[pageName] = button
	bindTap(button, function()
		showPage(pageName)
	end)
end

local function pageColumns(page, count)
	local inner = panelWidth - sidebarWidth - 14
	local gap = 6
	local width = math.floor((inner - gap * (count - 1)) / count)
	local list = {}
	for index = 1, count do
		local column = create("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(px(6) + px((index - 1) * (width + gap)), px(6)),
			Size = UDim2.fromOffset(px(width), 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, page)
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, px(1)),
		}, column)
		column._order = 0
		list[index] = column
	end
	return list
end

local function addSection(column, title)
	column._order = column._order + 1
	local section = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = column._order,
	}, column)
	create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, px(14)),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextSize = px(9),
		TextColor3 = HX.accentSoft,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTransparency = 0.05,
	}, section)
	local rows = create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, px(14)),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, section)
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, px(1)),
	}, rows)
	rows._order = 0
	return rows
end

local function addCheck(rows, label, get, set)
	rows._order = rows._order + 1
	local row = create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.new(1, 0, 0, px(16)),
		LayoutOrder = rows._order,
	}, rows)
	local box = create("Frame", {
		BackgroundColor3 = HX.box,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, px(3)),
		Size = UDim2.fromOffset(px(9), px(9)),
	}, row)
	create("UICorner", { CornerRadius = UDim.new(0, px(1)) }, box)
	create("UIStroke", { Color = HX.line, Thickness = 1, Transparency = 0.2 }, box)
	local tick = create("Frame", {
		BackgroundColor3 = HX.accent,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(px(1), px(1)),
		Size = UDim2.fromOffset(px(7), px(7)),
		Visible = false,
	}, box)
	create("UICorner", { CornerRadius = UDim.new(0, px(1)) }, tick)
	local text = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(px(15), 0),
		Size = UDim2.new(1, -px(15), 1, 0),
		Font = Enum.Font.Gotham,
		Text = label,
		TextSize = px(10),
		TextColor3 = HX.dim,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	local function paint()
		local on = get() and true or false
		tick.Visible = on
		text.TextColor3 = on and HX.text or HX.dim
	end
	bindTap(row, function()
		set(not get())
		UI.sync()
	end)
	paint()
	table.insert(UI.syncers, paint)
end

local function addSlider(rows, label, minValue, maxValue, step, get, set, suffix, decimals)
	rows._order = rows._order + 1
	local row = create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.new(1, 0, 0, px(23)),
		LayoutOrder = rows._order,
	}, rows)
	create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(1, -px(45), 0, px(12)),
		Font = Enum.Font.Gotham,
		Text = label,
		TextSize = px(10),
		TextColor3 = HX.dim,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	local valueLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -px(45), 0, 0),
		Size = UDim2.fromOffset(px(45), px(12)),
		Font = Enum.Font.Code,
		Text = "",
		TextSize = px(9),
		TextColor3 = HX.accentSoft,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, row)
	local track = create("Frame", {
		BackgroundColor3 = HX.box,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, px(16)),
		Size = UDim2.new(1, 0, 0, px(2)),
	}, row)
	local fill = create("Frame", {
		BackgroundColor3 = HX.accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
	}, track)
	local format = "%." .. tostring(decimals or 0) .. "f"
	local function paint()
		local ratio = math.clamp((get() - minValue) / math.max(maxValue - minValue, 0.0001), 0, 1)
		fill.Size = UDim2.new(ratio, 0, 1, 0)
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
	row.InputBegan:Connect(function(input)
		if not isPrimary(input) then
			return
		end
		set(valueAt(input.Position.X))
		paint()
		local moving = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				return
			end
			set(valueAt(input.Position.X))
			paint()
		end)
		local ended
		ended = UserInputService.InputEnded:Connect(function(other)
			if other ~= input then
				return
			end
			if moving then
				moving:Disconnect()
			end
			if ended then
				ended:Disconnect()
			end
		end)
	end)
	paint()
	table.insert(UI.syncers, paint)
end

local function addSelect(rows, label, options, get, set)
	rows._order = rows._order + 1
	local row = create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.new(1, 0, 0, px(17)),
		LayoutOrder = rows._order,
	}, rows)
	create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -px(70), 1, 0),
		Font = Enum.Font.Gotham,
		Text = label,
		TextSize = px(10),
		TextColor3 = HX.dim,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	local value = create("TextLabel", {
		BackgroundColor3 = HX.box,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -px(72), 0, px(2)),
		Size = UDim2.fromOffset(px(72), px(13)),
		Font = Enum.Font.Code,
		Text = "",
		TextSize = px(9),
		TextColor3 = HX.accentSoft,
	}, row)
	create("UICorner", { CornerRadius = UDim.new(0, px(2)) }, value)
	local function paint()
		value.Text = tostring(get())
	end
	local function nextOption()
		local current = tostring(get())
		local at = 1
		for index, option in ipairs(options) do
			if tostring(option) == current then
				at = index
				break
			end
		end
		at = at % #options + 1
		set(options[at])
		UI.sync()
	end
	bindTap(row, nextOption)
	paint()
	table.insert(UI.syncers, paint)
end

local function addAction(rows, label, callback)
	rows._order = rows._order + 1
	local row = create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, px(17)),
		LayoutOrder = rows._order,
		Font = Enum.Font.GothamMedium,
		Text = "> " .. label,
		TextSize = px(10),
		TextColor3 = HX.text,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, rows)
	bindTap(row, callback)
end

local function addInfo(rows, text)
	rows._order = rows._order + 1
	create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, px(13)),
		LayoutOrder = rows._order,
		Font = Enum.Font.Code,
		Text = text,
		TextSize = px(9),
		TextColor3 = HX.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, rows)
end

function UI.sync()
	for _, paint in ipairs(UI.syncers) do
		pcall(paint)
	end
end

function UI.setVisible(value)
	UI.visible = value and true or false
	gui.Enabled = UI.visible
end

local noticeLabel

local function toast(message)
	if noticeLabel then
		noticeLabel:Destroy()
	end
	local notice = create("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, px(40)),
		Size = UDim2.fromOffset(px(360), px(20)),
		Font = Enum.Font.GothamBold,
		Text = message,
		TextSize = px(12),
		TextColor3 = HX.accentSoft,
		TextStrokeTransparency = 0.55,
	}, gui)
	noticeLabel = notice
	TweenService:Create(notice, TweenInfo.new(2.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()
	task.delay(2.6, function()
		if noticeLabel == notice then
			notice:Destroy()
			noticeLabel = nil
		end
	end)
end

notify = toast

local pendingDestroy
local function unloadClient()
	if pendingDestroy then
		pendingDestroy()
	end
end

-- Pages
do
--------------------------------------------------------------------------

local mainPage = makePage("main")
local aimPage = makePage("aim")
local ragePage = makePage("rage")
local triggerPage = makePage("trigger")
local espPage = makePage("esp")
local visualsPage = makePage("visuals")
local movementPage = makePage("movement")
local skinsPage = makePage("skins")
local radarPage = makePage("radar")
local logsPage = makePage("logs")
local configPage = makePage("config")

-- Main ----------------------------------------------------------------

local mainCols = pageColumns(mainPage, 3)

local quickRows = addSection(mainCols[1], "features")
addCheck(quickRows, "aimbot", function()
	return Config.aimbot.enabled
end, function(value)
	Config.aimbot.enabled = value
end)
addCheck(quickRows, "ragebot", function()
	return Config.rage.enabled
end, function(value)
	Config.rage.enabled = value
	if not value then
		Rage.player = nil
	end
end)
addCheck(quickRows, "triggerbot", function()
	return Config.trigger.enabled
end, function(value)
	Config.trigger.enabled = value
end)
addCheck(quickRows, "esp", function()
	return Config.esp.enabled
end, function(value)
	Config.esp.enabled = value
end)
addCheck(quickRows, "radar", function()
	return Config.radar.enabled
end, function(value)
	Config.radar.enabled = value
end)
addCheck(quickRows, "skin unlocker", function()
	return Config.skin.enabled
end, function(value)
	Config.skin.enabled = value
	Skin.dirty = true
end)

local quickMove = addSection(mainCols[2], "movement")
addCheck(quickMove, "fly", function()
	return Config.move.fly
end, function(value)
	Config.move.fly = value
	if not value then
		stopFly()
	end
end)
addCheck(quickMove, "noclip", function()
	return Config.move.noclip
end, function(value)
	Config.move.noclip = value
	if not value then
		restoreNoclip()
	end
end)
addCheck(quickMove, "walk speed", function()
	return Config.move.speed
end, function(value)
	Config.move.speed = value
end)
addCheck(quickMove, "infinite jump", function()
	return Config.move.infiniteJump
end, function(value)
	Config.move.infiniteJump = value
end)
addCheck(quickMove, "fullbright", function()
	return Config.visual.fullbright
end, function(value)
	Config.visual.fullbright = value
end)
addCheck(quickMove, "custom crosshair", function()
	return Config.visual.crosshair
end, function(value)
	Config.visual.crosshair = value
end)

local status = addSection(mainCols[3], "modules")
addInfo(status, "aim / rage / trigger")
addInfo(status, "esp / radar / logs")
addInfo(status, "movement / visuals")
addInfo(status, "skins / config")
addInfo(status, "tap a tab or nav icon")
addInfo(status, "x closes - H reopens")
addAction(status, "panic: disable all", function()
	Config.aimbot.enabled = false
	Config.rage.enabled = false
	Config.trigger.enabled = false
	Config.esp.enabled = false
	Config.radar.enabled = false
	Config.move.fly = false
	Config.move.noclip = false
	stopFly()
	restoreNoclip()
	clearChams()
	UI.sync()
	toast("all modules disabled")
end)

-- Aim -----------------------------------------------------------------

local aimCols = pageColumns(aimPage, 3)

local aimRows = addSection(aimCols[1], "aimbot")
addCheck(aimRows, "enabled", function()
	return Config.aimbot.enabled
end, function(value)
	Config.aimbot.enabled = value
end)
addSlider(aimRows, "fov", 10, 360, 5, function()
	return Config.aimbot.fov
end, function(value)
	Config.aimbot.fov = value
end, " deg", 0)
addSlider(aimRows, "smoothness", 1, 40, 0.5, function()
	return Config.aimbot.smooth
end, function(value)
	Config.aimbot.smooth = value
end, "", 1)
addSlider(aimRows, "max turn", 60, 720, 10, function()
	return Config.aimbot.turn
end, function(value)
	Config.aimbot.turn = value
end, " d/s", 0)
addSlider(aimRows, "prediction", 0, 20, 1, function()
	return Config.aimbot.prediction
end, function(value)
	Config.aimbot.prediction = value
end, "%", 0)
addSlider(aimRows, "jitter filter", 0, 200, 5, function()
	return Config.aimbot.jitter
end, function(value)
	Config.aimbot.jitter = value
end, " ms", 0)
addSlider(aimRows, "deadzone", 0, 20, 1, function()
	return Config.aimbot.deadzone
end, function(value)
	Config.aimbot.deadzone = value
end, " px", 0)
addSelect(aimRows, "curve", { "Exponential", "Linear", "Spring" }, function()
	return Config.aimbot.curve
end, function(value)
	Config.aimbot.curve = value
end)
addSelect(aimRows, "priority", { "Crosshair", "Distance", "Low HP" }, function()
	return Config.aimbot.priority
end, function(value)
	Config.aimbot.priority = value
end)
addSelect(aimRows, "target part", { "Head", "Body", "Nearest" }, function()
	return Config.aimbot.part
end, function(value)
	Config.aimbot.part = value
end)
addSlider(aimRows, "sticky strength", 0, 2000, 50, function()
	return Config.aimbot.stickyPower
end, function(value)
	Config.aimbot.stickyPower = value
end, "", 0)

local aimTarget = addSection(aimCols[2], "targeting")
addSelect(aimTarget, "mode", { "Always", "Hold RMB", "Hold Q" }, function()
	return Config.aimbot.mode
end, function(value)
	Config.aimbot.mode = value
end)
addCheck(aimTarget, "sticky aim", function()
	return Config.aimbot.sticky
end, function(value)
	Config.aimbot.sticky = value
end)
addCheck(aimTarget, "wall check", function()
	return Config.aimbot.wall
end, function(value)
	Config.aimbot.wall = value
	Aim.cache = {}
end)
addCheck(aimTarget, "team check", function()
	return Config.aimbot.team
end, function(value)
	Config.aimbot.team = value
end)
addCheck(aimTarget, "ignore knocked", function()
	return Config.aimbot.ignoreKnocked
end, function(value)
	Config.aimbot.ignoreKnocked = value
end)
addSlider(aimTarget, "max distance", 50, 2000, 25, function()
	return Config.aimbot.maxDist
end, function(value)
	Config.aimbot.maxDist = value
end, " m", 0)
addSlider(aimTarget, "aim height", -2, 4, 0.5, function()
	return Config.aimbot.offset
end, function(value)
	Config.aimbot.offset = value
end, " st", 1)
addSlider(aimTarget, "lock delay", 0, 500, 10, function()
	return Config.aimbot.delay
end, function(value)
	Config.aimbot.delay = value
end, " ms", 0)
addSlider(aimTarget, "switch delay", 0, 1000, 25, function()
	return Config.aimbot.switchDelay
end, function(value)
	Config.aimbot.switchDelay = value
end, " ms", 0)
addCheck(aimTarget, "1st person", function()
	return Config.aimbot.firstPerson
end, function(value)
	Config.aimbot.firstPerson = value
end)

local aimFire = addSection(aimCols[3], "fire & visuals")
addCheck(aimFire, "auto fire", function()
	return Config.aimbot.autoFire
end, function(value)
	Config.aimbot.autoFire = value
end)
addSlider(aimFire, "fire delay", 20, 400, 10, function()
	return Config.aimbot.fireDelay
end, function(value)
	Config.aimbot.fireDelay = value
end, " ms", 0)
addCheck(aimFire, "auto scope", function()
	return Config.aimbot.autoScope
end, function(value)
	Config.aimbot.autoScope = value
	if not value then
		applyScope(false)
	end
end)
addCheck(aimFire, "instant lock", function()
	return Config.aimbot.instant
end, function(value)
	Config.aimbot.instant = value
end)
addCheck(aimFire, "fov circle", function()
	return Config.aimbot.showFov
end, function(value)
	Config.aimbot.showFov = value
end)
addCheck(aimFire, "lock line", function()
	return Config.aimbot.lockLine
end, function(value)
	Config.aimbot.lockLine = value
end)
addCheck(aimFire, "target dot", function()
	return Config.aimbot.targetDot
end, function(value)
	Config.aimbot.targetDot = value
end)
addCheck(aimFire, "hit marker", function()
	return Config.aimbot.hitMarker
end, function(value)
	Config.aimbot.hitMarker = value
end)
addCheck(aimFire, "kill notify", function()
	return Config.aimbot.killNotify
end, function(value)
	Config.aimbot.killNotify = value
end)
addCheck(aimFire, "target hud", function()
	return Config.aimbot.targetHud
end, function(value)
	Config.aimbot.targetHud = value
end)

-- Rage -----------------------------------------------------------------

local rageCols = pageColumns(ragePage, 3)

local rageRows = addSection(rageCols[1], "ragebot")
addCheck(rageRows, "enabled", function()
	return Config.rage.enabled
end, function(value)
	Config.rage.enabled = value
	if not value then
		Rage.player = nil
	end
end)
addSlider(rageRows, "fov", 10, 360, 5, function()
	return Config.rage.fov
end, function(value)
	Config.rage.fov = value
end, " deg", 0)
addSelect(rageRows, "target", { "Head", "Body", "Nearest" }, function()
	return Config.rage.part
end, function(value)
	Config.rage.part = value
end)
addSlider(rageRows, "prediction", 0, 25, 1, function()
	return Config.rage.prediction
end, function(value)
	Config.rage.prediction = value
end, "%", 0)
addSlider(rageRows, "max distance", 50, 2000, 25, function()
	return Config.rage.maxDist
end, function(value)
	Config.rage.maxDist = value
end, " m", 0)

local rageFilter = addSection(rageCols[2], "filters")
addCheck(rageFilter, "wall check", function()
	return Config.rage.wall
end, function(value)
	Config.rage.wall = value
end)
addCheck(rageFilter, "team check", function()
	return Config.rage.team
end, function(value)
	Config.rage.team = value
end)
addCheck(rageFilter, "ignore knocked", function()
	return Config.rage.ignoreKnocked
end, function(value)
	Config.rage.ignoreKnocked = value
end)
addCheck(rageFilter, "sticky", function()
	return Config.rage.sticky
end, function(value)
	Config.rage.sticky = value
end)
addSlider(rageFilter, "switch delay", 0, 1000, 25, function()
	return Config.rage.switchDelay
end, function(value)
	Config.rage.switchDelay = value
end, " ms", 0)
addSelect(rageFilter, "snap", { "Instant", "Smooth" }, function()
	return Config.rage.snap
end, function(value)
	Config.rage.snap = value
end)

local rageFire = addSection(rageCols[3], "fire")
addCheck(rageFire, "auto fire", function()
	return Config.rage.autoFire
end, function(value)
	Config.rage.autoFire = value
end)
addSlider(rageFire, "fire rate", 1, 30, 1, function()
	return Config.rage.fireRate
end, function(value)
	Config.rage.fireRate = value
end, " /s", 0)
addCheck(rageFire, "auto scope", function()
	return Config.rage.autoScope
end, function(value)
	Config.rage.autoScope = value
	if not value then
		applyScope(false)
	end
end)
addInfo(rageFire, "large fov + sticky")
addInfo(rageFire, "snap instant for flick")

-- Trigger --------------------------------------------------------------

local trigCols = pageColumns(triggerPage, 2)

local trigRows = addSection(trigCols[1], "triggerbot")
addCheck(trigRows, "enabled", function()
	return Config.trigger.enabled
end, function(value)
	Config.trigger.enabled = value
end)
addCheck(trigRows, "fov mode", function()
	return Config.trigger.fovMode
end, function(value)
	Config.trigger.fovMode = value
end)
addSlider(trigRows, "fov", 5, 360, 5, function()
	return Config.trigger.fov
end, function(value)
	Config.trigger.fov = value
end, " deg", 0)
addSlider(trigRows, "range", 20, 1000, 10, function()
	return Config.trigger.range
end, function(value)
	Config.trigger.range = value
end, " m", 0)
addSlider(trigRows, "max distance", 50, 2000, 25, function()
	return Config.trigger.maxDist
end, function(value)
	Config.trigger.maxDist = value
end, " m", 0)

local trigOpts = addSection(trigCols[2], "timing & filters")
addSlider(trigOpts, "delay", 0, 500, 10, function()
	return Config.trigger.delay
end, function(value)
	Config.trigger.delay = value
end, " ms", 0)
addSlider(trigOpts, "hit chance", 10, 100, 5, function()
	return Config.trigger.chance
end, function(value)
	Config.trigger.chance = value
end, "%", 0)
addSlider(trigOpts, "burst", 1, 6, 1, function()
	return Config.trigger.burst
end, function(value)
	Config.trigger.burst = value
end, "", 0)
addCheck(trigOpts, "wall check", function()
	return Config.trigger.wall
end, function(value)
	Config.trigger.wall = value
end)
addCheck(trigOpts, "team check", function()
	return Config.trigger.team
end, function(value)
	Config.trigger.team = value
end)
addCheck(trigOpts, "ignore knocked", function()
	return Config.trigger.ignoreKnocked
end, function(value)
	Config.trigger.ignoreKnocked = value
end)

-- ESP -----------------------------------------------------------------

local espCols = pageColumns(espPage, 3)

local visuals = addSection(espCols[1], "esp visuals")
addCheck(visuals, "esp", function()
	return Config.esp.enabled
end, function(value)
	Config.esp.enabled = value
end)
addCheck(visuals, "boxes", function()
	return Config.esp.box
end, function(value)
	Config.esp.box = value
end)
addSelect(visuals, "box style", { "Box", "Corners" }, function()
	return Config.esp.boxStyle
end, function(value)
	Config.esp.boxStyle = value
end)
addCheck(visuals, "box fill", function()
	return Config.esp.fill
end, function(value)
	Config.esp.fill = value
end)
addCheck(visuals, "health bar", function()
	return Config.esp.health
end, function(value)
	Config.esp.health = value
end)
addCheck(visuals, "health text", function()
	return Config.esp.healthText
end, function(value)
	Config.esp.healthText = value
end)
addCheck(visuals, "names", function()
	return Config.esp.name
end, function(value)
	Config.esp.name = value
end)
addSelect(visuals, "name mode", { "DisplayName", "Name", "Both" }, function()
	return Config.esp.nameMode
end, function(value)
	Config.esp.nameMode = value
end)
addCheck(visuals, "distance", function()
	return Config.esp.distance
end, function(value)
	Config.esp.distance = value
end)
addSlider(visuals, "text size", 8, 20, 1, function()
	return Config.esp.textSize
end, function(value)
	Config.esp.textSize = value
end, " px", 0)
addSlider(visuals, "opacity", 0.1, 1, 0.05, function()
	return Config.esp.opacity
end, function(value)
	Config.esp.opacity = value
end, "", 2)

local espFilters = addSection(espCols[2], "tracers & filters")
addCheck(espFilters, "tracers", function()
	return Config.esp.tracer
end, function(value)
	Config.esp.tracer = value
end)
addSelect(espFilters, "tracer origin", { "Bottom", "Center" }, function()
	return Config.esp.tracerFrom
end, function(value)
	Config.esp.tracerFrom = value
end)
addCheck(espFilters, "team color", function()
	return Config.esp.teamColor
end, function(value)
	Config.esp.teamColor = value
end)
addCheck(espFilters, "off-screen arrows", function()
	return Config.esp.arrows
end, function(value)
	Config.esp.arrows = value
end)
addSlider(espFilters, "arrow size", 6, 30, 1, function()
	return Config.esp.arrowSize
end, function(value)
	Config.esp.arrowSize = value
end, " px", 0)
addCheck(espFilters, "pickup esp", function()
	return Config.esp.pickups
end, function(value)
	Config.esp.pickups = value
	if not value then
		clearPickups()
	end
end)
addCheck(espFilters, "team check", function()
	return Config.esp.team
end, function(value)
	Config.esp.team = value
end)
addCheck(espFilters, "hide knocked", function()
	return Config.esp.hideKnocked
end, function(value)
	Config.esp.hideKnocked = value
end)
addSlider(espFilters, "max distance", 50, 2000, 25, function()
	return Config.esp.maxDist
end, function(value)
	Config.esp.maxDist = value
end, " m", 0)

local espSkeleton = addSection(espCols[3], "chams & skeleton")
addCheck(espSkeleton, "chams", function()
	return Config.esp.chams
end, function(value)
	Config.esp.chams = value
	if not value then
		clearChams()
	end
end)
addSlider(espSkeleton, "cham fill", 0, 0.95, 0.05, function()
	return Config.esp.chamFill
end, function(value)
	Config.esp.chamFill = value
end, "", 2)
addCheck(espSkeleton, "skeleton", function()
	return Config.esp.skeleton
end, function(value)
	Config.esp.skeleton = value
end)
addSlider(espSkeleton, "bone thickness", 1, 4, 0.5, function()
	return Config.esp.skeletonThickness
end, function(value)
	Config.esp.skeletonThickness = value
end, " px", 1)
addCheck(espSkeleton, "head dot", function()
	return Config.esp.headDot
end, function(value)
	Config.esp.headDot = value
end)
addSlider(espSkeleton, "head dot size", 2, 16, 1, function()
	return Config.esp.headDotSize
end, function(value)
	Config.esp.headDotSize = value
end, " px", 0)

-- Visuals --------------------------------------------------------------

local visCols = pageColumns(visualsPage, 3)

local visWorld = addSection(visCols[1], "world")
addCheck(visWorld, "fullbright", function()
	return Config.visual.fullbright
end, function(value)
	Config.visual.fullbright = value
end)
addCheck(visWorld, "no fog", function()
	return Config.visual.noFog
end, function(value)
	Config.visual.noFog = value
end)
addCheck(visWorld, "no effects", function()
	return Config.visual.noEffects
end, function(value)
	Config.visual.noEffects = value
end)
addCheck(visWorld, "custom time", function()
	return Config.visual.customTime
end, function(value)
	Config.visual.customTime = value
end)
addSlider(visWorld, "time", 0, 24, 0.5, function()
	return Config.visual.time
end, function(value)
	Config.visual.time = value
end, " h", 1)
addCheck(visWorld, "custom brightness", function()
	return Config.visual.customBrightness
end, function(value)
	Config.visual.customBrightness = value
end)
addSlider(visWorld, "brightness", 0, 5, 0.1, function()
	return Config.visual.brightness
end, function(value)
	Config.visual.brightness = value
end, "", 1)

local visCross = addSection(visCols[2], "crosshair & hud")
addCheck(visCross, "custom crosshair", function()
	return Config.visual.crosshair
end, function(value)
	Config.visual.crosshair = value
end)
addSelect(visCross, "style", { "Cross", "Dot", "Circle" }, function()
	return Config.visual.crosshairStyle
end, function(value)
	Config.visual.crosshairStyle = value
end)
addSlider(visCross, "gap", 0, 16, 1, function()
	return Config.visual.crosshairGap
end, function(value)
	Config.visual.crosshairGap = value
end, " px", 0)
addSlider(visCross, "thickness", 1, 4, 0.5, function()
	return Config.visual.crosshairThickness
end, function(value)
	Config.visual.crosshairThickness = value
end, " px", 1)
addSlider(visCross, "length", 2, 24, 1, function()
	return Config.visual.crosshairSize
end, function(value)
	Config.visual.crosshairSize = value
end, " px", 0)
addCheck(visCross, "coords", function()
	return Config.visual.coords
end, function(value)
	Config.visual.coords = value
end)
addCheck(visCross, "watermark", function()
	return Config.visual.watermark
end, function(value)
	Config.visual.watermark = value
end)
addCheck(visCross, "clock", function()
	return Config.visual.clock
end, function(value)
	Config.visual.clock = value
end)
addCheck(visCross, "player count", function()
	return Config.visual.playerCount
end, function(value)
	Config.visual.playerCount = value
end)

local visPanel = addSection(visCols[3], "interface")
addSlider(visPanel, "ui scale", 0.8, 1.2, 0.01, function()
	return Config.visual.uiScale
end, function(value)
	Config.visual.uiScale = value
	if panelScale then
		panelScale.Scale = value
	end
end, "x", 2)
addSlider(visPanel, "panel fade", 0, 0.5, 0.01, function()
	return Config.visual.uiTransparency
end, function(value)
	Config.visual.uiTransparency = value
	panel.BackgroundTransparency = value
end, "", 2)
addSlider(visPanel, "icon size", 34, 74, 2, function()
	return Config.visual.iconSize
end, function(value)
	Config.visual.iconSize = value
	UI.tweaks.iconSize(value)
end, " px", 0)
addInfo(visPanel, "x closes the panel")
addInfo(visPanel, "h icon reopens it")
addInfo(visPanel, "drag header to move")

-- Movement -------------------------------------------------------------

local moveCols = pageColumns(movementPage, 2)

local movement = addSection(moveCols[1], "movement")
addCheck(movement, "walk speed", function()
	return Config.move.speed
end, function(value)
	Config.move.speed = value
end)
addSlider(movement, "speed", 16, 120, 1, function()
	return Config.move.speedValue
end, function(value)
	Config.move.speedValue = value
end, "", 0)
addCheck(movement, "jump power", function()
	return Config.move.jump
end, function(value)
	Config.move.jump = value
end)
addSlider(movement, "jump", 50, 250, 5, function()
	return Config.move.jumpValue
end, function(value)
	Config.move.jumpValue = value
end, "", 0)
addCheck(movement, "infinite jump", function()
	return Config.move.infiniteJump
end, function(value)
	Config.move.infiniteJump = value
end)
addCheck(movement, "auto jump", function()
	return Config.move.autoJump
end, function(value)
	Config.move.autoJump = value
end)
addCheck(movement, "fly", function()
	return Config.move.fly
end, function(value)
	Config.move.fly = value
	if not value then
		stopFly()
	end
end)
addSlider(movement, "fly speed", 10, 300, 5, function()
	return Config.move.flySpeed
end, function(value)
	Config.move.flySpeed = value
end, "", 0)
addSelect(movement, "fly mode", { "Camera", "Horizontal" }, function()
	return Config.move.flyMode
end, function(value)
	Config.move.flyMode = value
end)
addCheck(movement, "noclip", function()
	return Config.move.noclip
end, function(value)
	Config.move.noclip = value
	if not value then
		restoreNoclip()
	end
end)

local camera = addSection(moveCols[2], "camera & body")
addCheck(camera, "camera fov", function()
	return Config.move.fov
end, function(value)
	Config.move.fov = value
end)
addSlider(camera, "fov", 30, 120, 1, function()
	return Config.move.fovValue
end, function(value)
	Config.move.fovValue = value
end, " deg", 0)
addCheck(camera, "camera distance", function()
	return Config.move.cameraDist
end, function(value)
	Config.move.cameraDist = value
end)
addSlider(camera, "distance", 8, 128, 1, function()
	return Config.move.cameraDistValue
end, function(value)
	Config.move.cameraDistValue = value
end, " st", 0)
addCheck(camera, "hip height", function()
	return Config.move.hipHeight
end, function(value)
	Config.move.hipHeight = value
end)
addSlider(camera, "hip", -2, 6, 0.5, function()
	return Config.move.hipHeightValue
end, function(value)
	Config.move.hipHeightValue = value
end, " st", 1)
addCheck(camera, "gravity", function()
	return Config.move.gravity
end, function(value)
	Config.move.gravity = value
end)
addSlider(camera, "gravity value", 0, 400, 5, function()
	return Config.move.gravityValue
end, function(value)
	Config.move.gravityValue = value
end, "", 0)
addInfo(camera, "space / leftctrl = fly up / down")
addInfo(camera, "insert = hide ui")
addInfo(camera, "rightshift = unload")

-- Skins ---------------------------------------------------------------

local skinCols = pageColumns(skinsPage, 2)

local skinRows = addSection(skinCols[1], "skin unlocker")
addCheck(skinRows, "enabled", function()
	return Config.skin.enabled
end, function(value)
	Config.skin.enabled = value
	Skin.dirty = true
end)
addSelect(skinRows, "skin", { "Cyan", "Gold", "Crimson", "Violet", "Emerald", "Ice", "Pink", "White" }, function()
	return Config.skin.color
end, function(value)
	Config.skin.color = value
	Skin.dirty = true
end)
addCheck(skinRows, "rainbow", function()
	return Config.skin.rainbow
end, function(value)
	Config.skin.rainbow = value
	Skin.dirty = true
end)
addSlider(skinRows, "rainbow speed", 0.05, 1, 0.05, function()
	return Config.skin.rainbowSpeed
end, function(value)
	Config.skin.rainbowSpeed = value
end, "x", 2)
addSelect(skinRows, "material", { "Neon", "ForceField", "Glass", "Metal", "SmoothPlastic", "Plastic" }, function()
	return Config.skin.material
end, function(value)
	Config.skin.material = value
	Skin.dirty = true
end)
addInfo(skinRows, "client-side only - not real skins")

local session = addSection(skinCols[2], "interface")
addAction(session, "hide ui", function()
	UI.setVisible(false)
	toast("hilix hidden - tap H")
end)
addAction(session, "unload client", function()
	unloadClient()
end)
addAction(session, "reset character", function()
	local humanoid = currentHumanoid()
	if humanoid then
		pcall(function()
			humanoid.Health = 0
		end)
	end
end)
addInfo(session, "tap hilix.gg in the top bar")
addInfo(session, "to drag the window")

-- Radar ---------------------------------------------------------------

local radarCols = pageColumns(radarPage, 2)

local radarRows = addSection(radarCols[1], "radar")
addCheck(radarRows, "enabled", function()
	return Config.radar.enabled
end, function(value)
	Config.radar.enabled = value
end)
addSlider(radarRows, "size", 70, 200, 5, function()
	return Config.radar.size
end, function(value)
	Config.radar.size = value
end, " px", 0)
addSlider(radarRows, "range", 50, 1000, 25, function()
	return Config.radar.range
end, function(value)
	Config.radar.range = value
end, " m", 0)
addSlider(radarRows, "opacity", 0.1, 1, 0.05, function()
	return Config.radar.opacity
end, function(value)
	Config.radar.opacity = value
end, "", 2)
addSlider(radarRows, "dot size", 2, 10, 1, function()
	return Config.radar.dotSize
end, function(value)
	Config.radar.dotSize = value
end, " px", 0)
addCheck(radarRows, "names", function()
	return Config.radar.names
end, function(value)
	Config.radar.names = value
end)

local radarInfo = addSection(radarCols[2], "info")
addInfo(radarInfo, "top right minimap")
addInfo(radarInfo, "rotates with camera")
addInfo(radarInfo, "range = world studs")
addInfo(radarInfo, "team color if available")

-- Logs ----------------------------------------------------------------

local logCols = pageColumns(logsPage, 2)

local logRows = addSection(logCols[1], "event log")
addCheck(logRows, "hit log", function()
	return Config.logs.hitLog
end, function(value)
	Config.logs.hitLog = value
end)
addCheck(logRows, "kill feed", function()
	return Config.logs.killFeed
end, function(value)
	Config.logs.killFeed = value
end)
addSlider(logRows, "duration", 1, 10, 0.5, function()
	return Config.logs.duration
end, function(value)
	Config.logs.duration = value
end, " s", 1)
addSlider(logRows, "max lines", 2, 12, 1, function()
	return Config.logs.maxLines
end, function(value)
	Config.logs.maxLines = value
end, "", 0)
addAction(logRows, "clear log", function()
	clearLog()
	toast("log cleared")
end)

local logInfo = addSection(logCols[2], "info")
addInfo(logInfo, "hits appear bottom left")
addInfo(logInfo, "kills from all players")
addInfo(logInfo, "fades after duration")

-- Configs -------------------------------------------------------------

local configCols = pageColumns(configPage, 2)

local about = addSection(configCols[1], "hilix")
addInfo(about, "hilix.gg - rivals")
addInfo(about, "100+ features & settings")
addInfo(about, "for delta / mobile")
addInfo(about, "v1.3.0")
addAction(about, "copy loadstring", function()
	local url = "https://raw.githubusercontent.com/njjjjjhij/rivals-ninja/main/RivalsClient.lua"
	pcall(function()
		setclipboard("loadstring(game:HttpGet(\"" .. url .. "\"))()")
	end)
	toast("loadstring copied")
end)

local keys = addSection(configCols[2], "keys")
addInfo(keys, "insert - show / hide ui")
addInfo(keys, "rightshift - unload")
addInfo(keys, "tap h icon - show / hide ui")
addInfo(keys, "tap a row - toggle feature")
addInfo(keys, "tap a value - cycle option")
addInfo(keys, "drag a bar - change value")

end
--------------------------------------------------------------------------
-- Floating icon
--------------------------------------------------------------------------

local startSize = viewport()
local iconPx = Config.visual.iconSize or 50
local iconX = math.max(math.floor(startSize.X / SCALE - px(iconPx + 16)), px(8))
local iconY = math.floor(startSize.Y / SCALE * 0.42)
local icon = create("TextButton", {
	Name = "HilixIcon",
	AutoButtonColor = false,
	BackgroundColor3 = Color3.fromRGB(10, 10, 12),
	BackgroundTransparency = 0.02,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBlack,
	Text = "H",
	TextSize = px(math.floor(iconPx * 0.52)),
	TextColor3 = HX.text,
	Position = UDim2.fromOffset(px(iconX), px(iconY)),
	Size = UDim2.fromOffset(px(iconPx), px(iconPx)),
}, iconGui)
create("UICorner", { CornerRadius = UDim.new(1, 0) }, icon)
create("UIStroke", {
	Color = HX.accent,
	Thickness = px(2),
	Transparency = 0.05,
}, icon)

bindDrag(icon, function()
	icon.baseX = iconX
	icon.baseY = iconY
end, function(delta)
	local size = viewport()
	local maxX = math.max(size.X / SCALE - iconPx, 0)
	iconX = math.clamp(icon.baseX + delta.X / SCALE, 0, maxX)
	iconY = math.clamp(icon.baseY + delta.Y / SCALE, 0, math.max(size.Y / SCALE - iconPx, 0))
	if iconX > maxX - 18 then
		iconX = maxX
	elseif iconX < 18 then
		iconX = 0
	end
	icon.Position = UDim2.fromOffset(px(iconX), px(iconY))
end, function()
	UI.setVisible(not UI.visible)
end)

local function setIconSize(value)
	iconPx = value
	icon.Size = UDim2.fromOffset(px(value), px(value))
	icon.TextSize = px(math.floor(value * 0.52))
end
UI.tweaks.iconSize = setIconSize
setIconSize(Config.visual.iconSize or 50)

--------------------------------------------------------------------------
-- HUD
--------------------------------------------------------------------------

local coordsLabel = create("TextLabel", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, px(12), 1, -px(10)),
	Size = UDim2.fromOffset(px(170), px(46)),
	Font = Enum.Font.Code,
	Text = "X  --\nY  --\nZ  --",
	TextSize = px(10),
	TextColor3 = HX.text,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Bottom,
	TextStrokeTransparency = 0.5,
}, root)

local statsLabel = create("TextLabel", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -px(12), 1, -px(10)),
	Size = UDim2.fromOffset(px(190), px(80)),
	Font = Enum.Font.Code,
	Text = "FPS: --\nPing: -- ms\nTarget: -",
	TextSize = px(10),
	TextColor3 = HX.text,
	TextXAlignment = Enum.TextXAlignment.Right,
	TextYAlignment = Enum.TextYAlignment.Bottom,
	TextStrokeTransparency = 0.5,
}, root)

local watermarkLabel = create("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(px(12), px(14)),
	Size = UDim2.fromOffset(px(300), px(14)),
	Font = Enum.Font.Code,
	Text = "",
	TextSize = px(9),
	TextColor3 = HX.dim,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextStrokeTransparency = 0.55,
}, root)

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
	fovCircle.Color = HX.accent
	fovCircle.Thickness = 1
	fovCircle.Transparency = 0.6
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
	if hudClock < 0.25 then
		return
	end
	hudClock = 0

	coordsLabel.Visible = Config.visual.coords and true or false
	local character = LocalPlayer.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	if rootPart then
		local position = rootPart.Position
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
	local lines = { "FPS: " .. tostring(fpsValue), "Ping: " .. tostring(ping) .. " ms" }
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
		watermarkLabel.Text = string.format("hilix.gg  |  %d fps  |  %d ms  |  %d online", fpsValue, ping, #Players:GetPlayers())
	end
end

--------------------------------------------------------------------------
-- Lock visuals, radar and event log
--------------------------------------------------------------------------

local lockLine = newDrawing("Line")
local aimDot = newDrawing("Square")

local function updateLockVisuals()
	if not lockLine or not DRAW_OK then
		return
	end
	local settings = Config.aimbot
	local camera = workspace.CurrentCamera
	local part = Aim.part
	if not settings.enabled or not camera or not part or not part.Parent then
		hideDrawing(lockLine)
		hideDrawing(aimDot)
		return
	end
	local screen, onScreen = camera:WorldToViewportPoint(part.Position)
	if not onScreen or screen.Z <= 0 then
		hideDrawing(lockLine)
		hideDrawing(aimDot)
		return
	end
	local size = camera.ViewportSize
	local target = Vector2.new(screen.X, screen.Y)
	if settings.lockLine then
		setLine(lockLine, Vector2.new(size.X * 0.5, size.Y * 0.5), target, HX.accent, 1, 0.55)
	else
		hideDrawing(lockLine)
	end
	if settings.targetDot then
		setSquare(aimDot, Vector2.new(target.X - px(3), target.Y - px(3)), Vector2.new(px(6), px(6)), HX.accent, 1, 0.15, true)
	else
		hideDrawing(aimDot)
	end
end

local Radar = { dots = {}, frame = nil, border = nil, center = nil }

local function updateRadar()
	if not DRAW_OK then
		return
	end
	if not Radar.frame then
		Radar.frame = newDrawing("Square")
		Radar.border = newDrawing("Square")
		Radar.center = newDrawing("Square")
	end
	local settings = Config.radar
	local camera = workspace.CurrentCamera
	local seen = {}
	if not settings.enabled or not camera then
		hideDrawing(Radar.frame)
		hideDrawing(Radar.border)
		hideDrawing(Radar.center)
		for _, entry in pairs(Radar.dots) do
			hideDrawing(entry.dot)
			hideDrawing(entry.label)
		end
		return
	end
	local view = camera.ViewportSize
	local size = px(settings.size)
	local x = view.X - size - px(18)
	local y = px(96)
	setSquare(Radar.frame, Vector2.new(x, y), Vector2.new(size, size), Color3.fromRGB(8, 8, 10), 1, math.clamp(1 - (settings.opacity or 0.85), 0, 0.95), true)
	setSquare(Radar.border, Vector2.new(x, y), Vector2.new(size, size), HX.accent, 1, 0.35, false)
	setSquare(Radar.center, Vector2.new(x + size * 0.5 - px(1), y + size * 0.5 - px(1)), Vector2.new(px(2), px(2)), HX.accent, 1, 0.1, true)
	local origin = camera.CFrame.Position
	local look = camera.CFrame.LookVector
	local flat = Vector3.new(look.X, 0, look.Z)
	if flat.Magnitude < 0.01 then
		flat = Vector3.new(0, 0, -1)
	end
	flat = flat.Unit
	local rightX, rightZ = -flat.Z, flat.X
	local range = math.max(settings.range or 300, 1)
	local half = size * 0.5 - px(4)
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and not sameTeam(player) then
			local character, humanoid, root = getCharacter(player)
			if character and root and (not humanoid or humanoid.Health > 0) then
				local rel = root.Position - origin
				local dx = rel.X * rightX + rel.Z * rightZ
				local dz = rel.X * flat.X + rel.Z * flat.Z
				if math.abs(dx) <= range and math.abs(dz) <= range then
					local entry = Radar.dots[player]
					if not entry then
						entry = { dot = newDrawing("Square"), label = newDrawing("Text") }
						Radar.dots[player] = entry
					end
					local dot = math.max(settings.dotSize or 4, 2)
					local sx = x + size * 0.5 + (dx / range) * half
					local sy = y + size * 0.5 - (dz / range) * half
					local color = HX.accent
					if player.TeamColor then
						color = player.TeamColor.Color
					end
					setSquare(entry.dot, Vector2.new(sx - px(dot * 0.5), sy - px(dot * 0.5)), Vector2.new(px(dot), px(dot)), color, 1, 0.1, true)
					if settings.names then
						setText(entry.label, player.Name, Vector2.new(sx, sy - px(8)), HX.text, px(7))
					else
						hideDrawing(entry.label)
					end
					seen[player] = true
				end
			end
		end
	end
	for player, entry in pairs(Radar.dots) do
		if not seen[player] then
			hideDrawing(entry.dot)
			hideDrawing(entry.label)
		end
	end
end

local LogBox = { rows = {}, frame = nil }

local function relayoutLogs()
	for index, row in ipairs(LogBox.rows) do
		if row.label then
			row.label.Position = UDim2.fromOffset(0, px((#LogBox.rows - index) * 13))
		end
	end
end

local function updateLogs()
	local now = os.clock()
	local changed = false
	for index = #LogBox.rows, 1, -1 do
		local row = LogBox.rows[index]
		if now >= row.expires then
			if row.label then
				row.label:Destroy()
			end
			table.remove(LogBox.rows, index)
			changed = true
		end
	end
	if changed then
		relayoutLogs()
	end
end

local function pushLogImpl(text, color, kind)
	if kind == "hit" and not Config.logs.hitLog then
		return
	end
	if kind == "kill" and not Config.logs.killFeed then
		return
	end
	if not LogBox.frame then
		LogBox.frame = create("Frame", {
			Name = "HilixLog",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, px(12), 1, -px(132)),
			Size = UDim2.fromOffset(px(320), px(90)),
		}, root)
	end
	local label = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, px(12)),
		Font = Enum.Font.Code,
		Text = text,
		TextSize = px(9),
		TextColor3 = color or HX.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextStrokeTransparency = 0.6,
	}, LogBox.frame)
	table.insert(LogBox.rows, { label = label, expires = os.clock() + (Config.logs.duration or 3) })
	while #LogBox.rows > (Config.logs.maxLines or 5) do
		local row = table.remove(LogBox.rows, 1)
		if row.label then
			row.label:Destroy()
		end
	end
	relayoutLogs()
end
pushLog = pushLogImpl
clearLog = function()
	for _, row in ipairs(LogBox.rows) do
		if row.label then
			row.label:Destroy()
		end
	end
	LogBox.rows = {}
end

local killConnections = {}
local function watchPlayerKills(player)
	pcall(function()
		local function hookCharacter(character)
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				return
			end
			table.insert(killConnections, humanoid.Died:Connect(function()
				pushLogImpl((player.DisplayName or player.Name) .. " eliminated", HX.accent, "kill")
			end))
		end
		if player.Character then
			hookCharacter(player.Character)
		end
		table.insert(killConnections, player.CharacterAdded:Connect(hookCharacter))
	end)
end
for _, player in ipairs(Players:GetPlayers()) do
	watchPlayerKills(player)
end
pcall(function()
	table.insert(killConnections, Players.PlayerAdded:Connect(watchPlayerKills))
end)

local function onRender(delta)
	rageStep(delta)
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
	updateLockVisuals()
	updateRadar()
	updateLogs()
	updateHud(delta)
end

RunService:BindToRenderStep("HilixRender", Enum.RenderPriority.Camera.Value + 20, onRender)

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
	RunService:UnbindFromRenderStep("HilixRender")
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
	removeDrawing(Cross.circle)
	Cross.dot = nil
	Cross.circle = nil
	for _, line in ipairs(HitMark.lines) do
		removeDrawing(line)
	end
	HitMark.lines = {}
	removeDrawing(targetHud)
	removeDrawing(lockLine)
	removeDrawing(aimDot)
	if Radar.frame then
		removeDrawing(Radar.frame)
		removeDrawing(Radar.border)
		removeDrawing(Radar.center)
	end
	for _, entry in pairs(Radar.dots) do
		removeDrawing(entry.dot)
		removeDrawing(entry.label)
	end
	Radar.dots = {}
	for _, connection in ipairs(killConnections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	killConnections = {}
	removeDrawing(fovCircle)
	fovCircle = nil
	if gui then
		gui:Destroy()
	end
	if iconGui then
		iconGui:Destroy()
	end
	if _G.HilixRivals then
		_G.HilixRivals = nil
	end
	pendingDestroy = nil
end

_G.HilixRivals = {
	version = "1.3.0",
	config = Config,
	destroy = function()
		if pendingDestroy then
			pendingDestroy()
		end
	end,
}

showPage("main")
UI.sync()
toast("hilix cheats loaded")

if not DRAW_OK then
	toast("drawing api missing - esp disabled")
	Config.esp.enabled = false
	UI.sync()
end
