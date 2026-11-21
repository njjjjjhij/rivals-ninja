-- Ninja / Rivals loader
-- Execute this in Delta (or any executor) to load the client from GitHub.

local SOURCE = "https://raw.githubusercontent.com/njjjjjhij/rivals-ninja/main/RivalsClient.lua"

local ok, result = pcall(function()
	local source = game:HttpGet(SOURCE)
	local chunk = loadstring(source)
	if not chunk then
		error("loadstring returned nil")
	end
	return chunk()
end)

if not ok then
	warn("[Ninja] failed to load: " .. tostring(result))
end
