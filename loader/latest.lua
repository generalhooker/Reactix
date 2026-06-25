--[[
  ██████╗ ██████╗ ██╗  ██╗██╗   ██╗██╗
  ██╔══██╗██╔══██╗╚██╗██╔╝██║   ██║██║
  ██████╔╝██████╔╝ ╚███╔╝ ██║   ██║██║
  ██╔══██╗██╔══██╗ ██╔██╗ ██║   ██║██║
  ██║  ██║██████╔╝██╔╝ ██╗╚██████╔╝██║
  ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝

  Reactix — latest.lua
  Version: 1.0.0

  Built with roblox-ts + @rbxts/react
  https://github.com/generalhooker/Reactix

  ─────────────────────────────────────────────────────────
  USAGE (paste into executor console):

    loadstring(game:HttpGet("https://raw.githubusercontent.com/generalhooker/Reactix/main/loader/latest.lua"))()

  OR via protected call:

    local ok, err = pcall(function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/generalhooker/Reactix/main/loader/latest.lua"))()
    end)
    if not ok then warn("[Reactix] " .. tostring(err)) end

  ─────────────────────────────────────────────────────────
  AUTOEXEC: Drop autoexec.lua into your executor's
  autoexec folder to load on every game join.
  ─────────────────────────────────────────────────────────
--]]

-- ═══════════════════════════════════════════════════════
--  CONFIGURATION
-- ═══════════════════════════════════════════════════════

local CONFIG = {
  -- Compiled Luau bundle fetched at runtime
  bundleUrl = "https://raw.githubusercontent.com/generalhooker/Reactix/main/public/bundle.lua",

  -- Fallback URL (set to nil to disable)
  fallbackUrl = nil,

  -- Library display name
  name = "Reactix",

  -- Library version
  version = "1.0.0",

  -- Seconds to wait after game loads before injecting UI
  startDelay = 0,

  -- Print debug messages to output console
  debug = true,

  -- Block specific games by PlaceId (empty = allow all)
  blockedPlaceIds = {},
}

-- ═══════════════════════════════════════════════════════
--  INTERNAL HELPERS
-- ═══════════════════════════════════════════════════════

local function printf(fmt, ...)
  print(string.format("[%s v%s] " .. fmt, CONFIG.name, CONFIG.version, ...))
end

local function warnf(fmt, ...)
  warn(string.format("[%s v%s] " .. fmt, CONFIG.name, CONFIG.version, ...))
end

local function debugf(fmt, ...)
  if CONFIG.debug then
    printf(fmt, ...)
  end
end

-- ═══════════════════════════════════════════════════════
--  GUARD: Already loaded
-- ═══════════════════════════════════════════════════════

if getgenv and getgenv()._REACTIX_LOADED then
  warnf("Already loaded — skipping duplicate execution.")
  return
end

-- ═══════════════════════════════════════════════════════
--  GUARD: Blocked place
-- ═══════════════════════════════════════════════════════

if #CONFIG.blockedPlaceIds > 0 then
  local currentPlaceId = game.PlaceId
  for _, id in ipairs(CONFIG.blockedPlaceIds) do
    if id == currentPlaceId then
      warnf("This game (PlaceId: %d) is blocked. Aborting.", currentPlaceId)
      return
    end
  end
end

-- ═══════════════════════════════════════════════════════
--  HTTP FETCH
--  Tries syn.request → http.request → game:HttpGet
-- ═══════════════════════════════════════════════════════

local function httpGet(url)
  debugf("Fetching: %s", url)

  -- Synapse / Delta / Wave
  if syn and syn.request then
    local res = syn.request({ Url = url, Method = "GET" })
    if res.StatusCode ~= 200 then
      error(string.format("HTTP %d from %s", res.StatusCode, url))
    end
    return res.Body
  end

  -- Fluxus / Script-Ware
  if http and http.request then
    local res = http.request({ Url = url, Method = "GET" })
    if res.StatusCode ~= 200 then
      error(string.format("HTTP %d from %s", res.StatusCode, url))
    end
    return res.Body
  end

  -- Fallback: game:HttpGet
  local ok, result = pcall(function()
    return game:HttpGet(url, true)
  end)
  if not ok then
    error("HttpGet failed: " .. tostring(result))
  end
  return result
end

-- ═══════════════════════════════════════════════════════
--  BUNDLE EXECUTOR
-- ═══════════════════════════════════════════════════════

local function executeBundle(source, label)
  label = label or "Reactix_bundle"
  debugf("Compiling bundle (%s)…", label)

  local fn, compileErr = loadstring(source, label)
  if not fn then
    error("Compile error in bundle: " .. tostring(compileErr))
  end

  debugf("Running bundle…")
  local ok, runErr = pcall(fn)
  if not ok then
    error("Runtime error in bundle: " .. tostring(runErr))
  end
end

-- ═══════════════════════════════════════════════════════
--  LOAD SEQUENCE
-- ═══════════════════════════════════════════════════════

local function load()
  if CONFIG.startDelay > 0 then
    debugf("Waiting %.1fs before injecting…", CONFIG.startDelay)
    task.wait(CONFIG.startDelay)
  end

  printf("Loading %s v%s…", CONFIG.name, CONFIG.version)

  local source = nil
  local fetchErr = nil

  local ok, err = pcall(function()
    source = httpGet(CONFIG.bundleUrl)
  end)

  if not ok then
    fetchErr = err
    warnf("Primary URL failed: %s", tostring(err))

    if CONFIG.fallbackUrl then
      debugf("Trying fallback URL…")
      local ok2, err2 = pcall(function()
        source = httpGet(CONFIG.fallbackUrl)
      end)
      if not ok2 then
        warnf("Fallback URL also failed: %s", tostring(err2))
      else
        fetchErr = nil
      end
    end
  end

  if fetchErr or not source then
    warnf("Could not fetch bundle. Is the URL correct?")
    warnf("  Primary:  %s", CONFIG.bundleUrl)
    if CONFIG.fallbackUrl then
      warnf("  Fallback: %s", CONFIG.fallbackUrl)
    end
    return false
  end

  local runOk, runErr = pcall(executeBundle, source, "Reactix_bundle")
  if not runOk then
    warnf("Failed to execute bundle: %s", tostring(runErr))
    return false
  end

  return true
end

-- ═══════════════════════════════════════════════════════
--  MAIN
-- ═══════════════════════════════════════════════════════

task.defer(function()
  local success = load()

  if success then
    if getgenv then
      getgenv()._REACTIX_LOADED = true
      getgenv()._REACTIX_VERSION = CONFIG.version
    end
    printf("Loaded successfully! (PlaceId: %d)", game.PlaceId)
  else
    warnf("Failed to load. Report issues at: https://github.com/generalhooker/Reactix/issues")
  end
end)
