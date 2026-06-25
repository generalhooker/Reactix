--[[
  Reactix — autoexec.lua
  Place this file in your executor's `autoexec` folder to load Reactix
  automatically on every game join.

  The script waits for the game to finish loading, then fetches and
  executes the latest Reactix loader.

  Loader URL:
  https://raw.githubusercontent.com/generalhooker/Reactix/main/loader/latest.lua
--]]

local LOADER_URL = "https://raw.githubusercontent.com/generalhooker/Reactix/main/loader/latest.lua"

-- Wait for game to be fully loaded
if not game:IsLoaded() then
  game.Loaded:Wait()
end

-- Small grace period so the game's own scripts can initialize
task.wait(1)

local ok, err = pcall(function()
  loadstring(game:HttpGet(LOADER_URL, true))()
end)

if not ok then
  warn("[Reactix autoexec] Failed to load: " .. tostring(err))
end
