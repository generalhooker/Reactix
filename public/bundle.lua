--[[
  Reactix v1.0.0 — bundle.lua
  This is the compiled Luau bundle for Reactix.
  https://github.com/generalhooker/Reactix
--]]

-- Guard against double-loading
if getgenv and getgenv()._REACTIX_BUNDLE_LOADED then
  return
end
if getgenv then
  getgenv()._REACTIX_BUNDLE_LOADED = true
end

print("[Reactix v1.0.0] Bundle loaded successfully!")
print("[Reactix v1.0.0] Ready — use Reactix.createWindow() to get started.")

-- Minimal API surface (stub until full compile is pushed)
local Reactix = {}

function Reactix.createWindow(options)
  options = options or {}
  local title = options.title or "Reactix Window"
  print("[Reactix] createWindow: " .. title)
end

function Reactix.version()
  return "1.0.0"
end

-- Expose on shared environment
if getgenv then
  getgenv().Reactix = Reactix
end

return Reactix
