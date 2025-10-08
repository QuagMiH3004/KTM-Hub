-- Fly Script có TextBox chỉnh tốc độ (GUI di chuyển được)
-- Tác giả: HKatama299 + ChatGPT 

local uis = game:GetService("UserInputService")
local rs  = game:GetService("RunService")
local player = game.Players.LocalPlayer

local speed    = 80         -- vận tốc bay mặc định
local flying   = false       -- trạng thái
local bv, bg   -- BodyVelocity & BodyGyro
local loopConn -- kết nối RenderStepped

------------------------------------------------------------
-- TẠO GUI
------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyControlGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Frame di chuyển được
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 180, 0, 80)
Frame.Position = UDim2.new(1, -200, 0.5, -40) -- bên phải giữa
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "Fly Controller"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.Parent = Frame

-- Ô nhập tốc độ
local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(1, -20, 0, 30)
SpeedBox.Position = UDim2.new(0, 10, 0, 35)
SpeedBox.PlaceholderText = "Speed = "..speed
SpeedBox.Text = tostring(speed)
SpeedBox.ClearTextOnFocus = false
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBox.Font = Enum.Font.SourceSans
SpeedBox.TextSize = 18
SpeedBox.Parent = Frame

-- Khi người dùng nhập tốc độ mới
SpeedBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local val = tonumber(SpeedBox.Text)
		if val then
			speed = val
			print("[Fly] Speed set to", speed)
		else
			SpeedBox.Text = tostring(speed)
		end
	end
end)

------------------------------------------------------------
-- Hàm BẮT ĐẦU bay
------------------------------------------------------------
local function startFly()
	flying = true
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	local hum  = char:WaitForChild("Humanoid")

	hum.PlatformStand = true

	bg = Instance.new("BodyGyro")
	bg.P = 1e5
	bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
	bg.Parent = root

	bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e5,1e5,1e5)
	bv.Parent = root

	loopConn = rs.RenderStepped:Connect(function()
		bg.CFrame = workspace.CurrentCamera.CFrame
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

		if dir.Magnitude > 0 then
			bv.Velocity = dir.Unit * speed
		else
			bv.Velocity = Vector3.zero
		end
	end)
end

------------------------------------------------------------
-- Hàm DỪNG bay
------------------------------------------------------------
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

------------------------------------------------------------
-- Phím bật/tắt bay (F)
------------------------------------------------------------
local function toggleFly()
	if flying then
		stopFly()
	else
		startFly()
	end
end

uis.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.KeyCode == Enum.KeyCode.F then
		toggleFly()
	end
end)

print("Press F to toggle fly (Speed: "..speed..")")
