--[[
  Reactix v1.0.0 — bundle.lua
  Full Roblox ScreenGui UI library.
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

-- ═══════════════════════════════════════════════════════
--  INTERNAL HELPERS
-- ═══════════════════════════════════════════════════════

local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService     = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

local function createInstance(className, properties, parent)
  local inst = Instance.new(className)
  for k, v in pairs(properties or {}) do
    inst[k] = v
  end
  if parent then inst.Parent = parent end
  return inst
end

local function tween(instance, info, props)
  local t = TweenService:Create(instance, info, props)
  t:Play()
  return t
end

local function makeDraggable(frame, handle)
  handle = handle or frame
  local dragging = false
  local dragStart, startPos

  handle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
      or input.UserInputType == Enum.UserInputType.Touch then
      dragging  = true
      dragStart = input.Position
      startPos  = frame.Position
    end
  end)

  UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
      and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(
      startPos.X.Scale, startPos.X.Offset + delta.X,
      startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
  end)

  UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
      or input.UserInputType == Enum.UserInputType.Touch then
      dragging = false
    end
  end)
end

-- ═══════════════════════════════════════════════════════
--  REACTIX API
-- ═══════════════════════════════════════════════════════

local Reactix = {}

-- ───────────────────────────────────────────────────────
--  Reactix.createWindow(options) → Window
--
--  options = {
--    title       = string,                    -- window title
--    size        = UDim2,                     -- default UDim2.new(0,400,0,300)
--    position    = UDim2,                     -- default centered
--    theme       = "dark"|"light",            -- default "dark"
--    resizable   = bool,                      -- default false
--    onClose     = function(),                -- called when window closes
--  }
--
--  Window methods:
--    window:Close()              — destroys the window
--    window:Send(text, duration) — shows a toast notification inside the window
--    window:SetTitle(text)       — changes the title bar text
--    window:AddLabel(text)       — appends a text label to the content area
--    window:AddButton(text, fn)  — appends a clickable button
--    window:AddSeparator()       — appends a horizontal rule
-- ───────────────────────────────────────────────────────

function Reactix.createWindow(options)
  options = options or {}

  local title     = options.title    or "Reactix"
  local winSize   = options.size     or UDim2.new(0, 400, 0, 300)
  local winPos    = options.position or UDim2.new(0.5, -200, 0.5, -150)
  local theme     = options.theme    or "dark"
  local onClose   = options.onClose

  -- Theme colours
  local colours = {}
  if theme == "light" then
    colours.bg        = Color3.fromRGB(240, 240, 240)
    colours.titleBar  = Color3.fromRGB(200, 200, 200)
    colours.titleText = Color3.fromRGB(30,  30,  30)
    colours.border    = Color3.fromRGB(180, 180, 180)
    colours.content   = Color3.fromRGB(255, 255, 255)
    colours.text      = Color3.fromRGB(30,  30,  30)
    colours.button    = Color3.fromRGB(0,   120, 215)
    colours.buttonTxt = Color3.fromRGB(255, 255, 255)
    colours.close     = Color3.fromRGB(196, 43,  28)
    colours.toast     = Color3.fromRGB(60,  60,  60)
    colours.toastTxt  = Color3.fromRGB(255, 255, 255)
  else -- dark (default)
    colours.bg        = Color3.fromRGB(30,  30,  30)
    colours.titleBar  = Color3.fromRGB(20,  20,  20)
    colours.titleText = Color3.fromRGB(220, 220, 220)
    colours.border    = Color3.fromRGB(60,  60,  60)
    colours.content   = Color3.fromRGB(35,  35,  35)
    colours.text      = Color3.fromRGB(210, 210, 210)
    colours.button    = Color3.fromRGB(0,   120, 215)
    colours.buttonTxt = Color3.fromRGB(255, 255, 255)
    colours.close     = Color3.fromRGB(196, 43,  28)
    colours.toast     = Color3.fromRGB(50,  50,  50)
    colours.toastTxt  = Color3.fromRGB(230, 230, 230)
  end

  -- ── Root ScreenGui ──────────────────────────────────
  local screenGui = createInstance("ScreenGui", {
    Name            = "ReactixWindow_" .. title,
    ResetOnSpawn    = false,
    ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
  }, playerGui)

  -- ── Main frame ──────────────────────────────────────
  local mainFrame = createInstance("Frame", {
    Name            = "MainFrame",
    Size            = winSize,
    Position        = winPos,
    BackgroundColor3 = colours.bg,
    BorderSizePixel = 0,
    ClipsDescendants = true,
  }, screenGui)

  createInstance("UICorner", { CornerRadius = UDim.new(0, 8) }, mainFrame)
  createInstance("UIStroke", {
    Color     = colours.border,
    Thickness = 1,
  }, mainFrame)

  -- ── Title bar ───────────────────────────────────────
  local titleBar = createInstance("Frame", {
    Name             = "TitleBar",
    Size             = UDim2.new(1, 0, 0, 32),
    BackgroundColor3 = colours.titleBar,
    BorderSizePixel  = 0,
  }, mainFrame)

  createInstance("UICorner", { CornerRadius = UDim.new(0, 8) }, titleBar)

  -- square off the bottom corners of the title bar
  createInstance("Frame", {
    Size             = UDim2.new(1, 0, 0.5, 0),
    Position         = UDim2.new(0, 0, 0.5, 0),
    BackgroundColor3 = colours.titleBar,
    BorderSizePixel  = 0,
  }, titleBar)

  local titleLabel = createInstance("TextLabel", {
    Name             = "Title",
    Size             = UDim2.new(1, -40, 1, 0),
    Position         = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text             = title,
    TextColor3       = colours.titleText,
    TextSize         = 14,
    Font             = Enum.Font.GothamBold,
    TextXAlignment   = Enum.TextXAlignment.Left,
  }, titleBar)

  -- Close button
  local closeBtn = createInstance("TextButton", {
    Name             = "CloseBtn",
    Size             = UDim2.new(0, 24, 0, 24),
    Position         = UDim2.new(1, -28, 0, 4),
    BackgroundColor3 = colours.close,
    Text             = "✕",
    TextColor3       = Color3.new(1, 1, 1),
    TextSize         = 12,
    Font             = Enum.Font.GothamBold,
    BorderSizePixel  = 0,
  }, titleBar)

  createInstance("UICorner", { CornerRadius = UDim.new(0, 4) }, closeBtn)

  -- ── Content scroll frame ────────────────────────────
  local scrollFrame = createInstance("ScrollingFrame", {
    Name                 = "Content",
    Size                 = UDim2.new(1, -16, 1, -48),
    Position             = UDim2.new(0, 8, 0, 40),
    BackgroundColor3     = colours.content,
    BorderSizePixel      = 0,
    ScrollBarThickness   = 4,
    ScrollBarImageColor3 = colours.border,
    CanvasSize           = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize  = Enum.AutomaticSize.Y,
  }, mainFrame)

  createInstance("UICorner",  { CornerRadius = UDim.new(0, 6) }, scrollFrame)
  createInstance("UIPadding", {
    PaddingTop    = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8),
    PaddingLeft   = UDim.new(0, 8),
    PaddingRight  = UDim.new(0, 8),
  }, scrollFrame)

  local listLayout = createInstance("UIListLayout", {
    SortOrder       = Enum.SortOrder.LayoutOrder,
    Padding         = UDim.new(0, 6),
    FillDirection   = Enum.FillDirection.Vertical,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
  }, scrollFrame)

  -- ── Toast container (sits above content) ────────────
  local toastFrame = createInstance("Frame", {
    Name             = "Toast",
    Size             = UDim2.new(1, -16, 0, 36),
    Position         = UDim2.new(0, 8, 1, 8),  -- starts below window
    BackgroundColor3 = colours.toast,
    BorderSizePixel  = 0,
    Visible          = false,
    ZIndex           = 10,
  }, mainFrame)

  createInstance("UICorner", { CornerRadius = UDim.new(0, 6) }, toastFrame)

  local toastLabel = createInstance("TextLabel", {
    Size             = UDim2.new(1, -12, 1, 0),
    Position         = UDim2.new(0, 6, 0, 0),
    BackgroundTransparency = 1,
    Text             = "",
    TextColor3       = colours.toastTxt,
    TextSize         = 13,
    Font             = Enum.Font.Gotham,
    TextXAlignment   = Enum.TextXAlignment.Left,
    TextTruncate     = Enum.TextTruncate.AtEnd,
    ZIndex           = 11,
  }, toastFrame)

  -- ── Draggable ───────────────────────────────────────
  makeDraggable(mainFrame, titleBar)

  -- ── Entrance animation ──────────────────────────────
  mainFrame.BackgroundTransparency = 1
  mainFrame.Size = UDim2.new(
    winSize.X.Scale, winSize.X.Offset,
    0, 0
  )

  tween(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0,
    Size = winSize,
  })

  -- ── Window object ───────────────────────────────────
  local Window = {}
  local toastThread = nil

  -- Close the window
  function Window:Close()
    if onClose then
      pcall(onClose)
    end
    tween(mainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
      BackgroundTransparency = 1,
      Size = UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 0),
    })
    task.delay(0.2, function()
      if screenGui and screenGui.Parent then
        screenGui:Destroy()
      end
    end)
  end

  -- Show a toast notification inside the window
  -- duration defaults to 3 seconds
  function Window:Send(text, duration)
    text     = tostring(text or "")
    duration = tonumber(duration) or 3

    if toastThread then
      task.cancel(toastThread)
      toastThread = nil
    end

    toastLabel.Text    = text
    toastFrame.Visible = true
    toastFrame.Position = UDim2.new(0, 8, 1, -44)

    tween(toastFrame,
      TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
      { Position = UDim2.new(0, 8, 1, -44) }
    )

    toastThread = task.delay(duration, function()
      tween(toastFrame,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Position = UDim2.new(0, 8, 1, 8) }
      )
      task.wait(0.25)
      toastFrame.Visible = false
      toastThread = nil
    end)
  end

  -- Change the title bar text
  function Window:SetTitle(text)
    titleLabel.Text = tostring(text or "")
  end

  -- Add a text label to the content area
  function Window:AddLabel(text)
    local lbl = createInstance("TextLabel", {
      Size             = UDim2.new(1, 0, 0, 22),
      BackgroundTransparency = 1,
      Text             = tostring(text or ""),
      TextColor3       = colours.text,
      TextSize         = 13,
      Font             = Enum.Font.Gotham,
      TextXAlignment   = Enum.TextXAlignment.Left,
      TextWrapped      = true,
      AutomaticSize    = Enum.AutomaticSize.Y,
    }, scrollFrame)
    return lbl
  end

  -- Add a clickable button
  function Window:AddButton(text, callback)
    local btn = createInstance("TextButton", {
      Size             = UDim2.new(1, 0, 0, 32),
      BackgroundColor3 = colours.button,
      Text             = tostring(text or "Button"),
      TextColor3       = colours.buttonTxt,
      TextSize         = 13,
      Font             = Enum.Font.GothamBold,
      BorderSizePixel  = 0,
      AutoButtonColor  = false,
    }, scrollFrame)

    createInstance("UICorner", { CornerRadius = UDim.new(0, 6) }, btn)

    btn.MouseEnter:Connect(function()
      tween(btn, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(0, 100, 185),
      })
    end)
    btn.MouseLeave:Connect(function()
      tween(btn, TweenInfo.new(0.1), {
        BackgroundColor3 = colours.button,
      })
    end)

    if callback then
      btn.MouseButton1Click:Connect(function()
        pcall(callback)
      end)
    end

    return btn
  end

  -- Add a horizontal separator line
  function Window:AddSeparator()
    local sep = createInstance("Frame", {
      Size             = UDim2.new(1, 0, 0, 1),
      BackgroundColor3 = colours.border,
      BorderSizePixel  = 0,
    }, scrollFrame)
    return sep
  end

  -- Wire close button
  closeBtn.MouseButton1Click:Connect(function()
    Window:Close()
  end)

  return Window
end

-- ───────────────────────────────────────────────────────
--  Reactix.version()
-- ───────────────────────────────────────────────────────
function Reactix.version()
  return "1.0.0"
end

-- ── Expose on shared environment ────────────────────────
if getgenv then
  getgenv().Reactix = Reactix
end

return Reactix
