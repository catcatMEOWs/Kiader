local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Analytics = game:GetService("RbxAnalyticsService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

--// Robustly get the LocalPlayer
local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = Player:WaitForChild("PlayerGui")

-- == [ Box Notifications ] == --
local TweenService = game:GetService("TweenService")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

function ShowBoxNotif(message)
	local Gui = Instance.new("ScreenGui", PlayerGui)
	Gui.Name = "LunarUi"
	Gui.IgnoreGuiInset = true
	Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local Overlay = Instance.new("Frame", Gui)
	Overlay.Name = "GlassOverlay"
	Overlay.Size = UDim2.new(1, 0, 1, 0)
	Overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	Overlay.BackgroundTransparency = 1
	Overlay.ZIndex = 0

	local Frame = Instance.new("Frame", Gui)
	Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	Frame.Position = UDim2.new(0.5, 0, 1.5, 0)
	Frame.Size = UDim2.new(0, 326, 0, 193)
	Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BackgroundTransparency = 0.1
	Frame.BorderSizePixel = 0
	Instance.new("UICorner", Frame)

	local stroke = Instance.new("UIStroke", Frame)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.fromRGB(0, 170, 255)
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Thickness = 2
	stroke.Transparency = 0

	local ImageLabel = Instance.new("ImageLabel", Frame)
	ImageLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Position = UDim2.new(0.354749441, 0, 0.164281815, 0)
	ImageLabel.Size = UDim2.new(0, 95, 0, 76)
	ImageLabel.Image = "rbxassetid://81628958072398"

	local MainText = Instance.new("TextLabel", Frame)
	MainText.Name = "MainText"
	MainText.BackgroundTransparency = 1
	MainText.Position = UDim2.new(0.0730055347, 0, 0.729062259, 0)
	MainText.Size = UDim2.new(0.854823947, 0, -0.122750714, 40)
	MainText.Font = Enum.Font.Arial
	MainText.Text = message
	MainText.TextColor3 = Color3.new(1,1,1)
	MainText.TextScaled = true
	MainText.TextWrapped = true

	local SubText = Instance.new("TextLabel", Frame)
	SubText.BackgroundTransparency = 1
	SubText.Position = UDim2.new(0.0699380487, 0, 0.844559431, 0)
	SubText.Size = UDim2.new(0.854823947, 0, -0.130853057, 40)
	SubText.Font = Enum.Font.Arial
	SubText.Text = "(discord.gg/PT.BEST)"
	SubText.TextColor3 = Color3.new(1,1,1)
	SubText.TextScaled = true
	SubText.TextWrapped = true

	-- Animasi masuk
	TweenService:Create(Overlay, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.2}):Play()
	local tweenIn = TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)})
	local tweenOut = TweenService:Create(Frame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, -0.5, 0)})
	tweenIn:Play(); tweenIn.Completed:Wait()

	task.wait(4)
	tweenOut:Play()
	TweenService:Create(Overlay, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {BackgroundTransparency = 1}):Play()
	tweenOut.Completed:Wait(); task.wait(0.2)

	Gui:Destroy()
end


-- == [ Key Validation with Worker Detection & First-Time Claim ] ==
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Analytics = game:GetService("RbxAnalyticsService")

-- Define a reusable HTTP request function for robustness
local Http =
    (syn and syn.request) or
    (http and http.request) or
    (http_request) or
    (request) or
    (fluxus and fluxus.request)

if not Http then
    ShowBoxNotif("❌ Error: No compatible HTTP function found on your client.")
    return
end

-- =============================================
-- STEP 1: VALIDATE THE KEY AND GET ITS STATUS
-- =============================================

local keyCheckPayload = {
    key = _G.script_key
}

local keyCheckResponse = Http({
    Url = "http://206.189.82.194:80/api/validate_key",
    Method = "POST",
    Headers = { ["Content-Type"] = "application/json" },
    Body = HttpService:JSONEncode(keyCheckPayload)
})

-- Handle network or initial errors
if not (keyCheckResponse and keyCheckResponse.Body) then
    ShowBoxNotif("⚠️ Network error during initial key check.")
    return
end

local keyCheckBody = HttpService:JSONDecode(keyCheckResponse.Body)
local isWorker = nil -- Default to nil
local canProceed = false

if keyCheckResponse.StatusCode == 200 and keyCheckBody and keyCheckBody.status == "success" then
    isWorker = keyCheckBody.isWorker -- We get the worker status here
    canProceed = true

elseif keyCheckResponse.StatusCode == 403 and keyCheckBody and keyCheckBody.message:find("Key valid but not bound") then

    canProceed = true

else
    if keyCheckBody and keyCheckBody.message then
        ShowBoxNotif("❌ " .. keyCheckBody.message)
    else
        ShowBoxNotif("❌ Invalid key or unknown validation error.")
    end
    return -- Stop execution
end

-- If the script can't proceed, stop.
if not canProceed then
    ShowBoxNotif("❌ Key validation failed. Cannot proceed.")
    return
end

-- Store the worker status globally if we have it.
_G.isWorker = isWorker 

-- =========================================================
-- STEP 2: BIND THE KEY TO THE CURRENT USER AND CLIENT
-- =========================================================

local bindPayload = {
    username = Players.LocalPlayer and Players.LocalPlayer.Name or "?",
    clientId = Analytics:GetClientId(),
    customerKey = _G.script_key
}

local bindResponse = Http({
    Url = "http://206.189.82.194:80/api/usekey",
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json",
        ["X-Api-Key"] = "LUNAR-SECRET-KEY-123"
    },
    Body = HttpService:JSONEncode(bindPayload)
})

-- Handle the response from the binding step
if bindResponse and bindResponse.StatusCode == 200 then
    local bindBody = HttpService:JSONDecode(bindResponse.Body)
    
    if bindBody.message:find("successfully claimed") then
         ShowBoxNotif("✅ Key successfully claimed! Loading script...")
    elseif isWorker then
        ShowBoxNotif("✅ Worker Key validated. Loading script...")
    else
        ShowBoxNotif("✅ Standard Key validated. Loading script...")
    end
    -- The script can now proceed to load its main functions
else
    -- An error occurred during the binding step
    local bindBody = bindResponse and HttpService:JSONDecode(bindResponse.Body) or {}
    
    if bindBody.status == "denied" then
        ShowBoxNotif("❌ This key has already been claimed by another user/machine.")
    elseif bindBody.status == "invalid" then
        ShowBoxNotif("❌ Key not found during binding. Please double-check it.")
    else
        ShowBoxNotif("⚠️ An unexpected error occurred during key binding.")
    end

    return -- Stop execution
end



--// =================================================================================
--// === SECTION 2: REVAMPED UI v2.0 & FUNCTIONALITY =================================
--// =================================================================================

--// Theme Configuration
local Theme = {
    Background = Color3.fromRGB(24, 25, 30),
    Surface = Color3.fromRGB(32, 33, 40),
    Primary = Color3.fromRGB(80, 110, 225),
    Danger = Color3.fromRGB(220, 70, 85),
    Success = Color3.fromRGB(40, 167, 69),
    Text = Color3.fromRGB(235, 235, 245),
    TextMuted = Color3.fromRGB(160, 160, 175),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamSemibold,
    Radius = UDim.new(0, 8),
    Stroke = Color3.fromRGB(55, 56, 65)
}

--// Main GUI Setup
pcall(function() CoreGui:FindFirstChild("Winter.TruckerUI"):Destroy() end)
local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name, Gui.ResetOnSpawn, Gui.IgnoreGuiInset, Gui.ZIndexBehavior = "Winter.TruckerUI", false, true, Enum.ZIndexBehavior.Sibling

--// Custom Notification System
local NotificationFrame = Instance.new("Frame", Gui)
NotificationFrame.Size, NotificationFrame.Position, NotificationFrame.AnchorPoint = UDim2.new(0, 280, 0, 60), UDim2.new(0.5, 0, 0, -80), Vector2.new(0.5, 0)
NotificationFrame.BackgroundColor3, NotificationFrame.BorderSizePixel, NotificationFrame.Visible = Theme.Surface, 0, false
Instance.new("UICorner", NotificationFrame).CornerRadius = Theme.Radius
Instance.new("UIStroke", NotificationFrame).Color = Theme.Stroke
local NotifTitle = Instance.new("TextLabel", NotificationFrame)
NotifTitle.Name, NotifTitle.Size, NotifTitle.Position = "Title", UDim2.new(1, -20, 0, 20), UDim2.fromOffset(10, 10)
NotifTitle.Font, NotifTitle.TextColor3, NotifTitle.TextXAlignment = Theme.FontBold, Theme.Text, Enum.TextXAlignment.Left
NotifTitle.BackgroundTransparency = 1
local NotifMessage = Instance.new("TextLabel", NotificationFrame)
NotifMessage.Name, NotifMessage.Size, NotifMessage.Position = "Message", UDim2.new(1, -20, 0, 20), UDim2.fromOffset(10, 30)
NotifMessage.Font, NotifMessage.TextColor3, NotifMessage.TextXAlignment = Theme.Font, Theme.TextMuted, Enum.TextXAlignment.Left
NotifMessage.BackgroundTransparency = 1

local function ShowNotification(title, message)
    if not (NotificationFrame and NotificationFrame.Parent) then return end
    NotifTitle.Text, NotifMessage.Text, NotificationFrame.Visible = title, message, true
    TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 20)}):Play()
    task.delay(3, function()
        if NotificationFrame and NotificationFrame.Parent then
           TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, -80)}):Play()
        end
    end)
end

--// UI Component Factory
local function createIcon(parent, iconName, color)
    local customIcons = {Close='<roblox rbxassetid="18043603704" p-ImageColor3="204,204,214" p-ImageRectSize="128,128" p-ImageRectOffset="448,576" ></roblox>',Minimize='<roblox rbxassetid="18043603704" p-ImageColor3="204,204,214" p-ImageRectSize="128,128" p-ImageRectOffset="448,832" ></roblox>',Settings='<roblox rbxassetid="18043603704" p-ImageColor3="204,204,214" p-ImageRectSize="128,128" p-ImageRectOffset="704,448" ></roblox>',Truck='<roblox rbxassetid="18043603704" p-ImageColor3="255,255,255" p-ImageRectSize="128,128" p-ImageRectOffset="832,704" ></roblox>',User='<roblox rbxassetid="18043603704" p-ImageColor3="160,160,175" p-ImageRectSize="128,128" p-ImageRectOffset="192,832" ></roblox>',Clock='<roblox rbxassetid="18043603704" p-ImageColor3="160,160,175" p-ImageRectSize="128,128" p-ImageRectOffset="64,576" ></roblox>',Money='<roblox rbxassetid="18043603704" p-ImageColor3="160,160,175" p-ImageRectSize="128,128" p-ImageRectOffset="576,192" ></roblox>',Graph='<roblox rbxassetid="18043603704" p-ImageColor3="160,160,175" p-ImageRectSize="128,128" p-ImageRectOffset="192,576" ></roblox>',Download='<roblox rbxassetid="18043603704" p-ImageColor3="160,160,175" p-ImageRectSize="128,128" p-ImageRectOffset="64,320" ></roblox>',Refresh='<roblox rbxassetid="18043603704" p-ImageColor3="255,255,255" p-ImageRectSize="128,128" p-ImageRectOffset="576,704" ></roblox>',Countdown='<roblox rbxassetid="18043603704" p-ImageColor3="204,204,214" p-ImageRectSize="128,128" p-ImageRectOffset="64,576" ></roblox>',Play='<roblox rbxassetid="18043603704" p-ImageColor3="255,255,255" p-ImageRectSize="128,128" p-ImageRectOffset="320,832" ></roblox>',Stop='<roblox rbxassetid="18043603704" p-ImageColor3="255,255,255" p-ImageRectSize="128,128" p-ImageRectOffset="64,832" ></roblox>'}
    local icon = Instance.new("ImageLabel")
    icon.Parent, icon.BackgroundTransparency, icon.Image = parent, 1, customIcons[iconName] or ""
    icon.ImageColor3 = color or Theme.TextMuted
    return icon
end

local function createIconButton(parent, iconName)
    local button = Instance.new("ImageButton", parent)
    button.BackgroundTransparency, button.Size, button.AutoButtonColor = 1, UDim2.fromOffset(24, 24), false
    local icon = createIcon(button, iconName)
    icon.Size, icon.Position = UDim2.fromScale(0.8, 0.8), UDim2.fromScale(0.1, 0.1)
    button.MouseEnter:Connect(function() TweenService:Create(icon, TweenInfo.new(0.2), { ImageColor3 = Theme.Text }):Play() end)
    button.MouseLeave:Connect(function() TweenService:Create(icon, TweenInfo.new(0.2), { ImageColor3 = Theme.TextMuted }):Play() end)
    return button, icon
end

--// Main UI Frame & Children
local Main = Instance.new("Frame", Gui)
Main.Name, Main.Size, Main.Position, Main.AnchorPoint = "MainUI", UDim2.fromOffset(0, 0), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5)
Main.BackgroundColor3, Main.BackgroundTransparency = Theme.Background, 1
Instance.new("UICorner", Main).CornerRadius = Theme.Radius
Instance.new("UIStroke", Main).Color = Theme.Stroke
local MainPadding = Instance.new("UIPadding", Main)
MainPadding.PaddingTop, MainPadding.PaddingBottom, MainPadding.PaddingLeft, MainPadding.PaddingRight = UDim.new(0,16), UDim.new(0,16), UDim.new(0,16), UDim.new(0,16)

local Header = Instance.new("Frame", Main)
Header.Name, Header.Size, Header.BackgroundTransparency = "Header", UDim2.new(1, 0, 0, 40), 1
local HeaderIcon = createIcon(Header, "Truck", Theme.Text)
HeaderIcon.Size, HeaderIcon.Position, HeaderIcon.AnchorPoint = UDim2.fromOffset(24, 24), UDim2.fromScale(0, 0.5), Vector2.new(0, 0.5)
local HeaderTitle = Instance.new("TextLabel", Header)
HeaderTitle.Text, HeaderTitle.Font, HeaderTitle.TextSize, HeaderTitle.TextColor3 = "Trucker Assistant", Theme.FontBold, 18, Theme.Text
HeaderTitle.BackgroundTransparency, HeaderTitle.Position, HeaderTitle.Size = 1, UDim2.fromOffset(34, 0), UDim2.new(1, -100, 1, 0)
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
local CloseBtn = createIconButton(Header, "Close")
CloseBtn.Position, CloseBtn.AnchorPoint = UDim2.new(1, 0, 0.5, 0), Vector2.new(1, 0.5)
local MinBtn = createIconButton(Header, "Minimize")
MinBtn.Position, MinBtn.AnchorPoint = UDim2.new(1, -34, 0.5, 0), Vector2.new(1, 0.5)
local SettingsBtn = createIconButton(Header, "Settings")
SettingsBtn.Position, SettingsBtn.AnchorPoint = UDim2.new(1, -68, 0.5, 0), Vector2.new(1, 0.5)

local Content = Instance.new("ScrollingFrame", Main)
Content.Name, Content.Size, Content.Position = "Content", UDim2.new(1, 0, 1, -56), UDim2.fromOffset(0, 56)
Content.BackgroundTransparency, Content.BorderSizePixel, Content.ScrollBarImageColor3, Content.ScrollBarThickness = 1, 0, Theme.Primary, 4
local ContentLayout = Instance.new("UIListLayout", Content)
ContentLayout.Padding, ContentLayout.SortOrder = UDim.new(0, 12), Enum.SortOrder.LayoutOrder

local UserSection = Instance.new("Frame", Content)
UserSection.Name, UserSection.Size, UserSection.BackgroundColor3, UserSection.LayoutOrder = "UserSection", UDim2.new(1, 0, 0, 50), Theme.Surface, 1
Instance.new("UICorner", UserSection).CornerRadius = Theme.Radius
local UserIcon = createIcon(UserSection, "User", Theme.TextMuted)
UserIcon.Size, UserIcon.Position, UserIcon.AnchorPoint = UDim2.fromOffset(24, 24), UDim2.fromOffset(15, 0), Vector2.new(0, 0.5)
UserIcon.Position = UDim2.fromScale(0, 0.5)
local UsernameLabel = Instance.new("TextLabel", UserSection)
UsernameLabel.Name, UsernameLabel.Size, UsernameLabel.Position = "UsernameLabel", UDim2.new(1, -80, 0, 20), UDim2.fromOffset(50, 0)
UsernameLabel.AnchorPoint, UsernameLabel.Position = Vector2.new(0, 0.5), UDim2.fromScale(0, 0.5)
UsernameLabel.Text, UsernameLabel.Font, UsernameLabel.TextSize = Player.Name, Theme.FontMedium, 15
UsernameLabel.TextColor3, UsernameLabel.BackgroundTransparency, UsernameLabel.TextXAlignment = Theme.Text, 1, Enum.TextXAlignment.Left
local RefreshBtn, RefreshIcon = createIconButton(UserSection, "Refresh")
RefreshBtn.Position, RefreshBtn.AnchorPoint = UDim2.new(1, -15, 0.5, 0), Vector2.new(1, 0.5)
RefreshIcon.ImageColor3 = Theme.Primary

local StatsSection = Instance.new("Frame", Content)
StatsSection.Name, StatsSection.Size, StatsSection.BackgroundTransparency, StatsSection.LayoutOrder = "StatsSection", UDim2.new(1, 0, 0, 120), 1, 2
local StatsLayout = Instance.new("UIGridLayout", StatsSection)
StatsLayout.CellSize, StatsLayout.CellPadding = UDim2.new(0.5, -6, 0.5, -6), UDim2.new(0, 12, 0, 12)

local function createStatCard(title, iconName)
    local card = Instance.new("Frame", StatsSection)
    card.BackgroundColor3 = Theme.Surface
    Instance.new("UICorner", card).CornerRadius = Theme.Radius
    local padding = Instance.new("UIPadding", card)
    padding.PaddingTop, padding.PaddingBottom, padding.PaddingLeft, padding.PaddingRight = UDim.new(0,10), UDim.new(0,10), UDim.new(0,10), UDim.new(0,10)
    local icon = createIcon(card, iconName)
    icon.Size, icon.Position, icon.AnchorPoint = UDim2.fromOffset(20, 20), UDim2.fromScale(0, 0.5), Vector2.new(0, 0.5)
    local textContainer = Instance.new("Frame", card)
    textContainer.BackgroundTransparency, textContainer.Size, textContainer.Position = 1, UDim2.new(1, -30, 1, 0), UDim2.fromOffset(30, 0)
    local titleLabel = Instance.new("TextLabel", textContainer)
    titleLabel.Size, titleLabel.Text, titleLabel.Font, titleLabel.TextSize = UDim2.fromScale(1, 0.5), title, Theme.FontMedium, 13
    titleLabel.TextColor3, titleLabel.BackgroundTransparency, titleLabel.TextXAlignment, titleLabel.TextYAlignment = Theme.TextMuted, 1, Enum.TextXAlignment.Left, Enum.TextYAlignment.Bottom
    local valueLabel = Instance.new("TextLabel", textContainer)
    valueLabel.Name, valueLabel.Size, valueLabel.Position = "ValueLabel", UDim2.fromScale(1, 0.5), UDim2.fromScale(0, 0.5)
    valueLabel.Text, valueLabel.Font, valueLabel.TextSize, valueLabel.TextColor3 = "Loading...", Theme.FontBold, 15, Theme.Text
    valueLabel.BackgroundTransparency, valueLabel.TextXAlignment, valueLabel.TextYAlignment = 1, Enum.TextXAlignment.Left, Enum.TextYAlignment.Top
    return valueLabel
end

local LabelMoney = createStatCard("Current Balance", "Money")
local LabelTime = createStatCard("Farming Time", "Clock")
local LabelLastEarning = createStatCard("Last Earning", "Download")
local LabelTotalEarning = createStatCard("Total Earning", "Graph")

local FarmingButton = Instance.new("TextButton", Content)
FarmingButton.Name, FarmingButton.Size, FarmingButton.LayoutOrder = "FarmingButton", UDim2.new(1, 0, 0, 42), 3
FarmingButton.BackgroundColor3, FarmingButton.TextColor3 = Theme.Primary, Theme.Text
FarmingButton.Text, FarmingButton.Font, FarmingButton.TextSize = "Start Auto Farming", Theme.FontBold, 16
Instance.new("UICorner", FarmingButton).CornerRadius = Theme.Radius
local FarmingBtnIcon = createIcon(FarmingButton, "Play", Theme.Text)
FarmingBtnIcon.Size, FarmingBtnIcon.Position, FarmingBtnIcon.AnchorPoint = UDim2.fromOffset(20, 20), UDim2.new(0, 15, 0.5, 0), Vector2.new(0, 0.5)

local SettingsPanel = Instance.new("Frame", Main)
SettingsPanel.Name, SettingsPanel.Size, SettingsPanel.Position = "SettingsPanel", UDim2.new(1, 0, 1, -56), UDim2.fromOffset(0, 56)
SettingsPanel.BackgroundColor3, SettingsPanel.BackgroundTransparency = Theme.Background, 0
SettingsPanel.BorderSizePixel, SettingsPanel.Visible, SettingsPanel.ClipsDescendants = 0, false, true
local SettingsPadding = Instance.new("UIPadding", SettingsPanel)
SettingsPadding.PaddingTop,SettingsPadding.PaddingBottom,SettingsPadding.PaddingLeft,SettingsPadding.PaddingRight = UDim.new(0,16),UDim.new(0,16),UDim.new(0,16),UDim.new(0,16)
local SettingsLayout = Instance.new("UIListLayout", SettingsPanel)
SettingsLayout.Padding, SettingsLayout.SortOrder = UDim.new(0, 12), Enum.SortOrder.LayoutOrder
local SettingsHeader = Instance.new("TextLabel", SettingsPanel)
SettingsHeader.Size, SettingsHeader.Text, SettingsHeader.Font, SettingsHeader.TextSize = UDim2.new(1, 0, 0, 30), "Configuration", Theme.FontBold, 18
SettingsHeader.TextColor3, SettingsHeader.BackgroundTransparency, SettingsHeader.TextXAlignment = Theme.Text, 1, Enum.TextXAlignment.Left

local CountdownRow = Instance.new("Frame", SettingsPanel)
CountdownRow.Size, CountdownRow.BackgroundTransparency = UDim2.new(1,0,0,30), 1
local CountdownIcon = createIcon(CountdownRow, "Countdown", Theme.TextMuted)
CountdownIcon.Size, CountdownIcon.Position, CountdownIcon.AnchorPoint = UDim2.fromOffset(20,20), UDim2.fromScale(0,0.5), Vector2.new(0,0.5)
local CountdownLabel = Instance.new("TextLabel", CountdownRow)
CountdownLabel.Size, CountdownLabel.Position, CountdownLabel.Text = UDim2.new(1,-80,1,0), UDim2.fromOffset(30,0), "Countdown Teleport (s)"
CountdownLabel.Font, CountdownLabel.TextSize, CountdownLabel.TextColor3 = Theme.FontMedium, 14, Theme.TextMuted
CountdownLabel.BackgroundTransparency, CountdownLabel.TextXAlignment = 1, Enum.TextXAlignment.Left
local CountdownInput = Instance.new("TextBox", CountdownRow)
CountdownInput.Size, CountdownInput.Position, CountdownInput.AnchorPoint = UDim2.new(0,60,1,0), UDim2.new(1,0,0.5,0), Vector2.new(1,0.5)
CountdownInput.BackgroundColor3, CountdownInput.Text, CountdownInput.Font = Theme.Surface, "45", Theme.FontBold
CountdownInput.TextSize, CountdownInput.TextColor3 = 14, Theme.Text
Instance.new("UICorner", CountdownInput).CornerRadius = UDim.new(0,6)

--// UI Functionality
TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 380, 0, 320), BackgroundTransparency = 0.1}):Play()
local dragging, dragStart, startPos; Header.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging,dragStart,startPos=true,i.Position,Main.Position;i.Changed:Connect(function()if i.UserInputState==Enum.UserInputState.End then dragging=false end end)end end)
UserInputService.InputChanged:Connect(function(i)if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then local d=i.Position-dragStart;Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)end end)
CloseBtn.MouseButton1Click:Connect(function() TweenService:Create(Main,TweenInfo.new(0.3),{Size=UDim2.fromOffset(0,0),BackgroundTransparency=1}):Play();task.wait(0.3);Gui:Destroy() end)
local isMinimized=false;MinBtn.MouseButton1Click:Connect(function()isMinimized=not isMinimized;Content.Visible=not isMinimized;FarmingButton.Visible=not isMinimized;local s=isMinimized and UDim2.fromOffset(380,56)or UDim2.fromOffset(380,320);TweenService:Create(Main,TweenInfo.new(0.3),{Size=s}):Play()end)
SettingsBtn.MouseButton1Click:Connect(function() SettingsPanel.Visible = not SettingsPanel.Visible end)
local CoolNames = {"ShadowBlitz", "RexThunder", "NeoPhantom", "VenomAce", "GhostNova"};RefreshBtn.MouseButton1Click:Connect(function()local r=TweenService:Create(RefreshIcon,TweenInfo.new(0.5),{Rotation=RefreshIcon.Rotation+360});r:Play();UsernameLabel.Text=CoolNames[math.random(1,#CoolNames)]end)
_G.CountdownValue = 45;CountdownInput:GetPropertyChangedSignal("Text"):Connect(function()local f=CountdownInput.Text:gsub("[^%d]","");local v=tonumber(f)or 0;_G.CountdownValue=math.clamp(v,0,999);if CountdownInput.Text~=tostring(_G.CountdownValue)then CountdownInput.Text=tostring(_G.CountdownValue)end end)


-- ================= // Utilities
local Player = game.Players.LocalPlayer
local CarName = Player.Name .. "sCar"

function TweenToJob()
	ShowNotification("🚚 Job", "Tweening To PT.Shad Factory...")
	game.ReplicatedStorage.NetworkContainer.RemoteEvents.Job:FireServer("Truck")
	
	local Root = Player.Character:FindFirstChild("HumanoidRootPart")
	if not Root then return end

	TweenService:Create(Root, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
		CFrame = Root.CFrame + Vector3.new(0, 100, 0)
	}):Play()

	task.delay(0.5, function()
		TweenService:Create(Root, TweenInfo.new(1, Enum.EasingStyle.Quad), {
			CFrame = CFrame.new(-21799.8, 1142.65, -26797.7)
		}):Play()

		task.delay(1, function()
			TweenService:Create(Root, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				CFrame = CFrame.new(-21799.8, 1042.65, -26797.7)
			}):Play()

			task.delay(1, function()
				Root.Anchored = true
				task.wait(0.3)
				Root.Anchored = false
			end)
		end)
	end)
end


function TakingJob()
	ShowNotification("🚚 Job", "Finding Best Destination...")
	repeat
		local Root = Player.Character:FindFirstChild("HumanoidRootPart")
		local Waypoint = workspace.Etc.Waypoint:FindFirstChild("Waypoint")
		local Label = Waypoint and Waypoint:FindFirstChild("BillboardGui") and Waypoint.BillboardGui:FindFirstChild("TextLabel")

		if Root then Root.Anchored = true end

		if Label and Label.Text ~= "Rojod Semarang" then
			game.ReplicatedStorage.NetworkContainer.RemoteEvents.Job:FireServer("Truck")
			local Prompt = workspace.Etc.Job.Truck.Starter:FindFirstChildWhichIsA("ProximityPrompt", true)
			if Prompt then
				Prompt.MaxActivationDistance = 100000
				fireproximityprompt(Prompt)
			end
		end

		if Root then Root.Anchored = false end
		task.wait(0.8)
	until Label and Label.Text == "Rojod Semarang"

	Player.Character.HumanoidRootPart.Anchored = false
	ShowNotification("🚚 Job", "Destination Found...")
end

function SpawningTruck()
	ShowNotification("🚚 Job", "Spawning Truck...")
	local Root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if not Root then return end

	Root.CFrame = CFrame.new(-21782.941, 1042.03, -26786.959)

	task.wait(2)
	local Vim = game:GetService("VirtualInputManager")
	Vim:SendKeyEvent(true, "F", false, game)
	task.wait(0.3)
	Vim:SendKeyEvent(false, "F", false, game)
	task.wait(5)

	local Car = workspace.Vehicles:FindFirstChild(CarName)
	local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
	local Seat = Car and Car:FindFirstChild("DriveSeat")
	if Humanoid and Seat then
		pcall(function() Seat:Sit(Humanoid) end)
		task.wait(0.5)
		Vim:SendKeyEvent(true, "Space", false, game)
		task.wait(0.1)
		Vim:SendKeyEvent(false, "Space", false, game)
	end

	local Trailer = Car and Car:FindFirstChild("Trailer1")
	if Trailer then
		Trailer:Destroy()
		print("Trailer destroyed to prevent interference.")
	end

end

function MovingCharacterToDestination(Destination)

	ShowNotification("🚚 Job", "Moving You To Near Destination...")

	local Root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	local Car = workspace.Vehicles:FindFirstChild(CarName)
	if not (Root and Car) then return end

	if not Car.PrimaryPart then
		for _, Part in ipairs(Car:GetDescendants()) do
			if Part:IsA("BasePart") then
				Car.PrimaryPart = Part
				break
			end
		end
	end

	local Follow = true
	task.spawn(function()
		while Follow do
			if Car.PrimaryPart then
				Car:PivotTo(Root.CFrame + Vector3.new(5, 0, 0))
			end
			task.wait(0.15)
		end
	end)

	local AboveStart = Root.CFrame + Vector3.new(0, 100, 0)
	local AboveDest = CFrame.new(Destination.Position + Vector3.new(0, 100, 0))

	TweenService:Create(Root, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
		CFrame = AboveStart
	}):Play()

	task.delay(0.4, function()
		TweenService:Create(Root, TweenInfo.new(1.6, Enum.EasingStyle.Sine), {
			CFrame = AboveDest
		}):Play()

		task.delay(1.6, function()
			TweenService:Create(Root, TweenInfo.new(1.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = Destination
			}):Play()

			task.delay(1.8, function()
				Follow = false

				Root.Anchored = true
				if Car.PrimaryPart then Car.PrimaryPart.Anchored = true end

				task.wait(0.8)
				
				if Car.PrimaryPart then Car.PrimaryPart.Anchored = false end

				ShowNotification("🚚 Job", "Moved, Wait 50 seconds To Claim Salary...")
			end)
		end)
	end)
end


function SitInVehicle()
	local Car = workspace.Vehicles:FindFirstChild(CarName)
	local Hum = Player.Character and Player.Character:FindFirstChild("Humanoid")
	local Seat = Car and Car:FindFirstChild("DriveSeat")
	if Hum and Seat then pcall(function() Seat:Sit(Hum) end) end
end

function InitialMap()
	local Workspace = cloneref(game:GetService("Workspace"))
	local Map = Workspace:FindFirstChild("Map", true)
	Map = Map and Map:FindFirstChild("Prop", true)
	if not Map then warn("Map not found") return true end

	local Target = Map:GetChildren()[499]
	if not Target then warn("Target object not found in Map") return false end
	Target:Destroy()

	local function Create(size, pos, name)
		local p = Instance.new("Part")
		p.Size, p.CFrame, p.Anchored, p.CanCollide, p.Material, p.Color, p.Name, p.Parent =
			size, CFrame.new(pos), true, true, Enum.Material.Plastic, Color3.fromRGB(163, 162, 165), name, workspace
		print(name .. " created at " .. tostring(pos))
	end

	local CharPos = Player.Character.HumanoidRootPart.Position
	Create(Vector3.new(128, 1, 128), Vector3.new(CharPos.X, 1, CharPos.Z), "BaseChar")
	Create(Vector3.new(128, 1, 128), Vector3.new(-21797.74, 1037.11, -26793.34), "BaseCarPart")
	Create(Vector3.new(2048, 1, 2048), Vector3.new(-21801, 1015, -26836), "BaseTruckPart")
	Create(Vector3.new(2048, 1, 2048), Vector3.new(-50919, 1005, -86457), "BaseRGPart")

	local mapFolder = workspace:FindFirstChild("Map")
	if mapFolder then mapFolder:Destroy() else print("Map folder not found") end
	return true
end

function AntiAFK()
	local VIM = game:GetService("VirtualInputManager")
	local Player = game:GetService("Players").LocalPlayer
	local Keys = {"W", "A", "S", "D"}

	local Connection = Player.Idled:Connect(function()
		task.spawn(function()
			local key = Keys[math.random(1, #Keys)]
			VIM:SendKeyEvent(true, key, false, game)
			task.wait(0.2)
			VIM:SendKeyEvent(false, key, false, game)

			local dx, dy = math.random(-5, 5), math.random(-5, 5)
			VIM:SendMouseMoveEvent(dx, dy, game)
		end)
	end)

	return Connection
end
AntiAFK()


-- [[ overlay glass black ]] -- 
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local CountdownLabel = nil

function CountdownTeleport(seconds)
	local overlay = CoreGui:FindFirstChild("GlassOverlay")
	if not overlay then return end

	if not CountdownLabel then
		CountdownLabel = Instance.new("TextLabel", overlay)
		CountdownLabel.Size = UDim2.new(0, 200, 0, 80)
		CountdownLabel.Position = UDim2.new(0.5, 0, 0.5, 100) 
		CountdownLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		CountdownLabel.BackgroundTransparency = 1
		CountdownLabel.Font = Enum.Font.GothamBold 
		CountdownLabel.TextSize = 70
		CountdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		CountdownLabel.TextStrokeTransparency = 0.5
		CountdownLabel.TextScaled = true
	end
	

	CountdownLabel.Visible = true
	for i = seconds, 1, -1 do
		CountdownLabel.Text = tostring(i)
		task.wait(1)
	end

	CountdownLabel.Visible = false
end

function ToggleGlassOverlay()
	local existing = CoreGui:FindFirstChild("GlassOverlay")
	if existing then
		existing:Destroy()
		print("[GlassOverlay] Removed from screen.")
	else
		local overlay = Instance.new("ScreenGui")
		overlay.Name = "GlassOverlay"
		overlay.IgnoreGuiInset = true
		overlay.ResetOnSpawn = false
		overlay.DisplayOrder = 1
		overlay.Parent = CoreGui

		local bg = Instance.new("Frame", overlay)
		bg.Size = UDim2.new(1, 0, 1, 0)
		bg.Position = UDim2.new(0, 0, 0, 0)
		bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		bg.BackgroundTransparency = 1
		bg.BorderSizePixel = 0

		local TextContainer = Instance.new("Frame", overlay)
		TextContainer.Size = UDim2.new(1, 0, 1, 0)
		TextContainer.BackgroundTransparency = 1

		local CombinedText = Instance.new("TextLabel", TextContainer)
		CombinedText.Size = UDim2.new(0, 800, 0, 50)
		CombinedText.Position = UDim2.new(0.5, 0, 0.5, -25)
		CombinedText.AnchorPoint = Vector2.new(0.5, 0.5)
		CombinedText.BackgroundTransparency = 1
		CombinedText.Font = Enum.Font.Ubuntu
		CombinedText.TextSize = 26
		CombinedText.TextColor3 = Color3.fromRGB(255, 255, 255)
		CombinedText.TextStrokeTransparency = 0.6
		CombinedText.TextWrapped = true
		CombinedText.TextScaled = true
		CombinedText.RichText = true
		CombinedText.Text = ""
		CombinedText.TextTransparency = 0

		local SubText = Instance.new("TextLabel", TextContainer)
		SubText.AnchorPoint = Vector2.new(0.5, 0.5)
		SubText.Position = UDim2.new(0.5, 0, 0.5, 30)
		SubText.Size = UDim2.new(0, 400, 0, 30)
		SubText.BackgroundTransparency = 1
		SubText.Text = "https://discord.gg/FMuRa8p5Hd"
		SubText.Font = Enum.Font.Ubuntu
		SubText.TextSize = 20
		SubText.TextColor3 = Color3.fromRGB(104, 168, 255)
		SubText.TextStrokeTransparency = 0.7
		SubText.TextWrapped = true
		SubText.TextScaled = true
		SubText.TextTransparency = 1

		TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 0.2}):Play()
		TweenService:Create(SubText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

		task.spawn(function()
			local prefix = "Auto Farming"
			local suffix = " actived, dont close or do anyting"
			local fullText = prefix .. suffix

			local delayPerChar = 0.03
			for i = 1, #fullText do
				local typed = fullText:sub(1, i)
				if typed:sub(1, #prefix) == prefix then
					CombinedText.Text = "<font color='rgb(104,168,255)'>" ..
						typed:sub(1, #prefix) ..
						"</font>" .. typed:sub(#prefix + 1)
				else
					CombinedText.Text = typed
				end
				game:GetService("RunService").RenderStepped:Wait()
				task.wait(delayPerChar)
			end
		end)
	end
end

function GlassOverlayStopped()
	local existing = CoreGui:FindFirstChild("GlassOverlay")
	if existing then
		existing:Destroy()
	end

	local overlay = Instance.new("ScreenGui")
	overlay.Name = "GlassOverlay"
	overlay.IgnoreGuiInset = true
	overlay.ResetOnSpawn = false
	overlay.DisplayOrder = 1
	overlay.Parent = CoreGui

	local bg = Instance.new("Frame", overlay)
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.Position = UDim2.new(0, 0, 0, 0)
	bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	bg.BackgroundTransparency = 1
	bg.BorderSizePixel = 0

	local TextContainer = Instance.new("Frame", overlay)
	TextContainer.Size = UDim2.new(1, 0, 1, 0)
	TextContainer.BackgroundTransparency = 1

	local CombinedText = Instance.new("TextLabel", TextContainer)
	CombinedText.Size = UDim2.new(0, 800, 0, 50)
	CombinedText.Position = UDim2.new(0.5, 0, 0.5, -25)
	CombinedText.AnchorPoint = Vector2.new(0.5, 0.5)
	CombinedText.BackgroundTransparency = 1
	CombinedText.Font = Enum.Font.Ubuntu
	CombinedText.TextSize = 26
	CombinedText.TextColor3 = Color3.fromRGB(255, 255, 255)
	CombinedText.TextStrokeTransparency = 0.6
	CombinedText.TextWrapped = true
	CombinedText.TextScaled = true
	CombinedText.RichText = true
	CombinedText.Text = ""
	CombinedText.TextTransparency = 0

	local SubText = Instance.new("TextLabel", TextContainer)
	SubText.AnchorPoint = Vector2.new(0.5, 0.5)
	SubText.Position = UDim2.new(0.5, 0, 0.5, 30)
	SubText.Size = UDim2.new(0, 400, 0, 30)
	SubText.BackgroundTransparency = 1
	SubText.Text = "https://discord.gg/FMuRa8p5Hd"
	SubText.Font = Enum.Font.Ubuntu
	SubText.TextSize = 20
	SubText.TextColor3 = Color3.fromRGB(104, 168, 255)
	SubText.TextStrokeTransparency = 0.7
	SubText.TextWrapped = true
	SubText.TextScaled = true
	SubText.TextTransparency = 1

	TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 0.2}):Play()
	TweenService:Create(SubText, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

	task.spawn(function()
		local prefix = "Auto Farming Stopped"
		local suffix = " thanks yall for using our script"
		local fullText = prefix .. suffix
		local delayPerChar = 0.03

		for i = 1, #fullText do
			local typed = fullText:sub(1, i)
			if typed:sub(1, #prefix) == prefix then
				CombinedText.Text =
					"<font color='rgb(255,80,80)'>" ..
					typed:sub(1, #prefix) ..
					"</font>" .. typed:sub(#prefix + 1)
			else
				CombinedText.Text = typed
			end
			RunService.RenderStepped:Wait()
			task.wait(delayPerChar)
		end

		task.wait(5)

		local fadeOutTime = 0.4
		TweenService:Create(bg, TweenInfo.new(fadeOutTime), {BackgroundTransparency = 1}):Play()
		TweenService:Create(CombinedText, TweenInfo.new(fadeOutTime), {TextTransparency = 1}):Play()
		TweenService:Create(SubText, TweenInfo.new(fadeOutTime), {TextTransparency = 1}):Play()

		task.wait(fadeOutTime + 0.1)
		overlay:Destroy()

		task.wait(0.8)
		local LocalPlayer = game:GetService("Players").LocalPlayer
		LocalPlayer:Kick("[Lunar Message]\nYour farming session has ended. Rejoin the game to resume safely.")

	end)
end


-- Farming Button
FarmingButton.MouseButton1Click:Connect(function()
    Farming = not Farming
    if Farming then
        FarmingButton.Text = "Stop Auto Farming"
        FarmingBtnIcon.Image = createIcon(FarmingBtnIcon, "Stop").Image
        TweenService:Create(FarmingButton, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Danger}):Play()
        ToggleGlassOverlay()
        StartFarming()
    else
        if FarmingThread then task.cancel(FarmingThread) end
        FarmingButton.Text = "Start Auto Farming"
        FarmingBtnIcon.Image = createIcon(FarmingBtnIcon, "Play").Image
        TweenService:Create(FarmingButton, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Primary}):Play()
        GlassOverlayStopped()
    end
end)

function StartFarming()
    Farming = true
    StartTime = os.clock()
    
    FarmingThread = task.spawn(function()
        while Farming do
            RunService:Set3dRenderingEnabled(false)
            InitialMap()
            task.wait(0.5)
            TweenToJob()
            task.wait(0.5)
            TakingJob()
            task.wait(0.5)
            SpawningTruck()
            task.wait(0.5)
            MovingCharacterToDestination(CFrame.new(-50937.152, 1012.215, -86353.031))
            CountdownTeleport(_G.CountdownValue)
            SitInVehicle()
            CarTween(CFrame.new(-50899.6015625, 1013.977783203125, -86534.9765625))
            task.wait(0.5)
        end
    end)
end

-- LAST TAG

function UpdateEarningStats()

	local function cleanToNumber(text)
		text = tostring(text or "")
		text = text:gsub("[^%d]", "")
		return tonumber(text) or 0
	end

	local function formatRupiah(amount)
		local formatted = tostring(amount)
		local k
		while true do
			formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
			if k == 0 then break end
		end
		return "Rp" .. formatted
	end

	local uangLabel = Player.PlayerGui.Main.Container.Hub.CashFrame.Frame:FindFirstChild("TextLabel")
	local EarningText = Player.PlayerGui.Main.Container.Hub.CashFrame:FindFirstChild("TextLabel")

	if uangLabel and EarningText then
		local uangText = uangLabel.Text
		LabelMoney.Text = " " .. uangText

		local EarningValue = cleanToNumber(EarningText.Text)
		local earned = EarningValue

		TotalEarning = TotalEarning or 0
		TotalEarning += earned

		_G.LastEarningFormatted = formatRupiah(earned)
		_G.TotalEarningFormatted = formatRupiah(TotalEarning)

		LabelLastEarning.Text = " " .. formatRupiah(earned)
		LabelTotalEarning.Text = " " .. formatRupiah(TotalEarning)

	end

	if StartTime then
		LabelTime.Text = " " .. math.floor(os.clock() - StartTime) .. " detik"
	end
end


function CarTween(TargetCFrame)
	local Root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	Root.Anchored = false

	task.wait(0.2)

	local Car = workspace.Vehicles:FindFirstChild(CarName)
	if not Car then warn("Vehicle not found.") return end
	if not Car.PrimaryPart then
		local Seat = Car:FindFirstChild("DriveSeat")
		if Seat then Car.PrimaryPart = Seat else return end
	end

	local Temp = Instance.new("CFrameValue", workspace)
	Temp.Value = Car:GetPivot()

	local Tween = game:GetService("TweenService"):Create(Temp, TweenInfo.new(3, Enum.EasingStyle.Linear), {
		Value = TargetCFrame
	})

	Temp:GetPropertyChangedSignal("Value"):Connect(function()
		Car:PivotTo(Temp.Value)
	end)

	Tween:Play()
	Tween.Completed:Wait()
	Temp:Destroy()

	game.ReplicatedStorage.NetworkContainer.RemoteEvents.Job:FireServer("Truck")

	task.wait(0.2)
	local Root = Player.Character:FindFirstChild("HumanoidRootPart")
	Root.Anchored = true
	task.wait(0.2)
	Root.Anchored = false
	task.wait(0.02)
	UpdateEarningStats()

	if DiscordEnabled and WebhookURL ~= "" then
		local Http = (syn and syn.request) or http_request
		local HttpService = game:GetService("HttpService")
	
		local uang = Player.PlayerGui.Main.Container.Hub.CashFrame.Frame:FindFirstChild("TextLabel")
		local waktuFarming = os.date("!%H:%M:%S", math.floor(os.clock() - StartTime))
	
		local embedData = {
			embeds = {{
				title = "💼 Jobs Data",
				color = 0x5865F2, -- Discord blurple
				fields = {
					{ name = "Nickname", value = "• " .. Player.Name, inline = false },
					{ name = "Elapsed Time", value = "• " .. waktuFarming, inline = false },
					{ name = "Current Money", value = "• " .. (uang and uang.Text or "-"), inline = false },
					{ name = "Money Received", value = "• " .. (_G.LastEarningFormatted or "-"), inline = false },
					{ name = "Total Earnings", value = "• " .. (_G.TotalEarningFormatted or "-"), inline = false }
				},
				footer = {
					text = "Send Time: " .. os.date("%X") .. "\nMade with love by Lunar"
				}
			}}
		}
	
		local json = HttpService:JSONEncode(embedData)
	
		pcall(function()
			Http({
				Url = WebhookURL,
				Method = "POST",
				Headers = {["Content-Type"] = "application/json"},
				Body = json
			})
		end)
	end

	-- Lua script roblox
	local Http =
		(syn and syn.request) or
		(http and http.request) or
		(http_request) or
		(request) or
		(fluxus and fluxus.request)

	local HttpService = game:GetService("HttpService")
	local Players = game:GetService("Players")
	local Analytics = game:GetService("RbxAnalyticsService")

	local API_KEY = "LUNAR-SECRET-KEY-123" 

	local Player = Players.LocalPlayer
	local clientId = Analytics:GetClientId()
	local username = Player.Name

	local uang = Player:WaitForChild("PlayerGui"):WaitForChild("Main").Container.Hub.CashFrame.Frame:FindFirstChild("TextLabel")
	local waktuFarming = os.date("!%H:%M:%S", math.floor(os.clock() - StartTime))


	local permanentData = {
		username = username,
		clientId = clientId,
		moneyReceived = _G.LastEarningFormatted or "-",
	}


	local tempData = {
		username = username,
		clientId = clientId,
		elapsedTime = waktuFarming,
		currentMoney = uang and uang.Text or "-",
		moneyReceived = _G.LastEarningFormatted or "-",
		totalEarnings = _G.TotalEarningFormatted or "-",
		keyUse = _G.script_key,
		status = true -- Added status field to indicate farming is active
	}

	-- Encode both payloads
	local permanentBody = HttpService:JSONEncode(permanentData)
	local tempBody = HttpService:JSONEncode(tempData)


	-- PERMANENT DATA (Saved To Database)
	pcall(function()
		if not Http then error("❌ No compatible HTTP method found") end

		local response = Http({
			Url = "http://206.189.82.194:80/api/receive", 
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["X-Api-Key"] = API_KEY
			},
			Body = permanentBody 
		})

		if response and response.StatusCode == 200 then
			print("✅ Job data sent successfully")
		else
			warn("❌ Failed to send job data:", response and response.Body or "Unknown error")
		end
	end)

	task.wait(0.2)

	-- TEMP DATA (Showing To Website)
	pcall(function()
		if not Http then error("❌ No compatible HTTP method found") end

		local response = Http({
			Url = "http://206.189.82.194:80/api/temp", 
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
				["X-Api-Key"] = API_KEY
			},
			Body = tempBody
		})

		if response and response.StatusCode == 200 then
			print("✅ Temp data sent successfully")
		else
			warn("❌ Failed to send temp data:", response and response.Body or "Unknown error")
		end
	end)

end

Player.CharacterAdded:Connect(function(char)
	if Farming then
		task.wait(1.5)
		if FarmingThread then
			task.cancel(FarmingThread)
		end
		StartFarming()
	end
end)


-- roblox lua
local Http =
    (syn and syn.request) or
    (http and http.request) or
    (http_request) or
    (request) or
    (fluxus and fluxus.request)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local API_KEY = "LUNAR-SECRET-KEY-123"  

-- This function now sends the username and the new 'false' status.
local function sendExitStatus()
    local data = {
        username = Player.Name,
        status = false -- Set status to false upon exit
    }

    local json = HttpService:JSONEncode(data)

    pcall(function()
        if not Http then return end
        
        -- The URL should not have the port 8080 if it's the standard HTTP port.
        -- If your server is indeed on port 8080, you can add it back.
        Http({
            Url = "http://206.189.82.194/api/exit", 
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["X-Api-Key"] = API_KEY
            },
            Body = json
        })
        print("Sent exit status update for " .. Player.Name)
    end)
end

-- Detect when the local player is leaving the game
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == Player then
        sendExitStatus()
    end
end)
