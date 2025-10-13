local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()			

local Window = Rayfield:CreateWindow({
   Name = "QM-A1 Hub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "QM-A",
   LoadingSubtitle = "v.2 by KTM",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "QM-A1 Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "QM-A1 hub | Key",
      Subtitle = "Key System",
      Note = "Key: Execute", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = true, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Execute"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local MainTab = Window:CreateTab("Home",nil) -- Title, Image
local MainSection = MainTab:CreateSection("Main")

Rayfield:Notify({
   Title = "Script Execute",
   Content = "Start QM-A1 hub v3",
   Duration = 5,
   Image = "circle-play",
})

local Button = MainTab:CreateButton({
   Name = "Infinite Jump",
   Callback = function()
--Toggles the infinite jump between on or off on every script run
_G.infinjump = not _G.infinjump

if _G.infinJumpStarted == nil then
	--Ensures this only runs once to save resources
	_G.infinJumpStarted = true
	
	--Notifies readiness
	game.StarterGui:SetCore("SendNotification", {Title="QM-A1 Hub"; Text="Infinite Jump Activated!"; Duration=8;})

	--The actual infinite jump
	local plr = game:GetService('Players').LocalPlayer
	local m = plr:GetMouse()
	m.KeyDown:connect(function(k)
		if _G.infinjump then
			if k:byte() == 32 then
			humanoid = game:GetService'Players'.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
			humanoid:ChangeState('Jumping')
			wait()
			humanoid:ChangeState('Seated')
			end
		end
	end)
end
   end,
})

local Slider = MainTab:CreateSlider({
   Name = "WalkSpeed Slider",
   Range = {15, 45},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "sliderws", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = (Value)
   end,
})

local Slider = MainTab:CreateSlider({
   Name = "JumpPower Slider",
   Range = {16, 100},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "sliderjp", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = (Value)
   end,
})

-- LocalScript / Executor inject – chạy client
local uis = game:GetService("UserInputService")
local rs  = game:GetService("RunService")
local player = game.Players.LocalPlayer

local speed    = 65         -- vận tốc bay
local flying   = false       -- trạng thái
local bv, bg   -- BodyVelocity & BodyGyro
local loopConn -- kết nối RenderStepped

--------------------------------------------------------------------
-- Hàm BẬT bay
--------------------------------------------------------------------
local function startFly()
	flying = true
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	local hum  = char:WaitForChild("Humanoid")

	-- Tắt rag-doll & trọng lực trên nhân vật
	hum.PlatformStand = true

	-- Giữ hướng nhìn & khử lực rơi
	bg = Instance.new("BodyGyro")
	bg.P        = 1e5
	bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
	bg.Parent    = root

	-- Đẩy nhân vật theo hướng di chuyển
	bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e5,1e5,1e5)
	bv.Parent   = root

	loopConn = rs.RenderStepped:Connect(function()
		-- Luôn xoay theo camera
		bg.CFrame = workspace.CurrentCamera.CFrame

		-- Xác định hướng WASD theo camera
		local dir = Vector3.zero
		if uis:IsKeyDown(Enum.KeyCode.W) then
			dir += workspace.CurrentCamera.CFrame.LookVector
		end
		if uis:IsKeyDown(Enum.KeyCode.S) then
			dir -= workspace.CurrentCamera.CFrame.LookVector
		end
		if uis:IsKeyDown(Enum.KeyCode.A) then
			dir -= workspace.CurrentCamera.CFrame.RightVector
		end
		if uis:IsKeyDown(Enum.KeyCode.D) then
			dir += workspace.CurrentCamera.CFrame.RightVector
		end

		-- Nếu đang nhấn phím → bay; thả phím → hover
		if dir.Magnitude > 0 then
			bv.Velocity = dir.Unit * speed
		else
			bv.Velocity = Vector3.zero
		end
	end)
end

--------------------------------------------------------------------
-- Hàm TẮT bay
--------------------------------------------------------------------
local function stopFly()
	flying = false
	local char = player.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	local hum  = char:FindFirstChild("Humanoid")

	if loopConn then loopConn:Disconnect() end
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
	if hum then hum.PlatformStand = false end
	if root then root.Velocity = Vector3.zero end
end

--------------------------------------------------------------------
-- Gán phím F bật/tắt
--------------------------------------------------------------------
local function toggleFly()
	if flying then
		stopFly()
	else
		startFly()
	end
end

-- Bạn đang dùng UI library (Tab:CreateButton)
local Button = MainTab:CreateButton({
	Name = "Fly",
	Callback = function()
		-- Chỉ cần gán 1 lần
		uis.InputBegan:Connect(function(inp, gp)
			if gp then return end          -- bỏ qua nếu gõ trong ô chat
			if inp.KeyCode == Enum.KeyCode.F then
				toggleFly()
			end
		end)

		-- Thông báo nhỏ
		print("Press F to fly/ unfly (speed = "..speed..")")
	end
})

local OtherSection = MainTab:CreateSection("Section Example")

local Button = MainTab:CreateButton({
   Name = "Voidware",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/loader.lua", true))()
   end,
})

local Button = MainTab:CreateButton({
   Name = "Deadrail",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/Scripts/main/DeadRails"))()
   end,
})

local Button = MainTab:CreateButton({
   Name = "Blox fruit",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/kimprobloxdz/Banana-Free/refs/heads/main/Protected_5609200582002947.lua.txt"))()
   end,
})

local Button = MainTab:CreateButton({
   Name = "Nature Disaster Survival",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/QuagMiH3004/KTM-Hub/refs/heads/main/KTM-NDS.lua"))()
   end,
})

