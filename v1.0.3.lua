--v1.0.3
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local uis = game:GetService("UserInputService")
local rs  = game:GetService("RunService")
local player = LocalPlayer -- Sử dụng biến đã khai báo để nhất quán

-- Biến nhân vật (được khai báo 1 lần)
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- BIẾN CỐT LÕI TORNADO (Không trùng lặp, dùng để UI điều khiển)
local radius = 50 
local height = 100
local rotationSpeed = 0.5
local attractionStrength = 1000
local ringPartsEnabled = false -- Biến Tắt/Mở chính
local parts = {} -- Bảng lưu trữ các vật thể bị ảnh hưởng
-------------------------------------------------------------------------------------------------------------------------------------------------------
--Set checkpoint
-------------------------------------------------------------------------------------------------------------------------------------------------------

-- =========================================================================
-- HÀM ĐẶT CHECKPOINT
-- =========================================================================
-- Biến lưu trữ CFrame của Checkpoint
local checkPointCFrame = nil 
local checkPointPart = nil   -- Biến lưu trữ khối Part Checkpoint (nếu có)

-- =========================================================================
-- HÀM TẠO KHỐI CHECKPOINT
-- =========================================================================
local function createCheckpointPart(cframe)
    -- Nếu đã có khối checkpoint cũ, xóa nó đi
    if checkPointPart and checkPointPart.Parent then
        checkPointPart:Destroy()
    end

    -- 1. Tạo Part mới (Chỉ hiển thị cục bộ)
    local newPart = Instance.new("Part")
    newPart.Size = Vector3.new(3, 3, 3) 
    newPart.BrickColor = Color3.fromRGB(83, 255, 26) -- Màu xanh lá cây
    newPart.Transparency = 0.5                      -- Hơi trong suốt
    newPart.Anchored = true                         -- Không di chuyển
    newPart.CanCollide = false                      -- Có thể đi xuyên qua
    newPart.Name = "LocalCheckpoint1"

    -- 2. Đặt vị t
    newPart.CFrame = cframe
    
    -- 3. Gán vào Workspace
    newPart.Parent = Workspace
    
    checkPointPart = newPart
end

-- =========================================================================
-- HÀM ĐẶT CHECKPOINT
-- =========================================================================
function setCheckpoint()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        -- Lấy CFrame (Vị trí và Hướng) của chân nhân vật
        checkPointCFrame = root.CFrame
        
        -- Tạo khối cục bộ ngay tại vị trí Checkpoint (cao hơn một chút để không bị kẹt)
        local checkpointPosition = checkPointCFrame * CFrame.new(0, 1.5 + 3/2, 0) -- Nâng lên 1.5 stud + nửa chiều cao Part
        
        createCheckpointPart(checkpointPosition)
        
        -- In thông báo thành công
        print("Checkpoint done at : " .. tostring(checkPointCFrame.Position))
    end
end

-- =========================================================================
-- HÀM DỊCH CHUYỂN VỀ CHECKPOINT
-- =========================================================================
function teleportToCheckpoint()
    if checkPointCFrame then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if root then
            -- Dịch chuyển HumanoidRootPart về CFrame đã lưu
            root.CFrame = checkPointCFrame
            print("Dịch chuyển thành công đến Checkpoint.")
        end
    else
        print("Lỗi: Chưa có Checkpoint nào được đặt!")
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------
--NDS
---------------------------------------------------------------------------------------------------------------------------------------------------------

-- THIẾT LẬP CÁC PHẦN TỬ HỖ TRỢ TRONG WORKSPACE
local Folder = Instance.new("Folder", Workspace)
Folder.Name = "Tornado_Physics_Helper"
local Part = Instance.new("Part", Folder)
Part.Anchored = true
Part.CanCollide = false
Part.Transparency = 1
local Attachment1 = Instance.new("Attachment", Part)

-- HÀM HỖ TRỢ VẬT LÝ
-- Hàm tùy chỉnh vật lý cho Part, làm cho chúng dễ bị đẩy và xoay
local function ForcePart(v)
    if v:IsA("Part") and not v.Anchored and not v.Parent:FindFirstChild("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
        -- Xóa các BodyMovers cũ
        for _, x in next, v:GetChildren() do
            if x:IsA("BodyAngularVelocity") or x:IsA("BodyForce") or x:IsA("BodyGyro") or x:IsA("BodyPosition") or x:IsA("BodyThrust") or x:IsA("BodyVelocity") or x:IsA("RocketPropulsion") then
                x:Destroy()
            end
        end
        if v:FindFirstChild("Attachment") then v:FindFirstChild("Attachment"):Destroy() end
        if v:FindFirstChild("AlignPosition") then v:FindFirstChild("AlignPosition"):Destroy() end
        if v:FindFirstChild("Torque") then v:FindFirstChild("Torque"):Destroy() end
        
        v.CanCollide = false
        
        local Torque = Instance.new("Torque", v)
        Torque.Torque = Vector3.new(100000,100000,100000)
        
        local AlignPosition = Instance.new("AlignPosition", v)
        local Attachment2 = Instance.new("Attachment", v)
        
        Torque.Attachment0 = Attachment2
        AlignPosition.MaxForce = 99999999999999999
        AlignPosition.MaxVelocity = math.huge
        AlignPosition.Responsiveness = 200
        AlignPosition.Attachment0 = Attachment2
        AlignPosition.Attachment1 = Attachment1 -- Liên kết với Part ẩn trên mặt đất
    end
end

-- Hàm tùy chỉnh thuộc tính vật lý để giữ Part trong bảng `parts`
local function RetainPart(part)
    if part:IsA("BasePart") and not part.Anchored and part:IsDescendantOf(Workspace) then
        if part:IsDescendantOf(LocalPlayer.Character) then return false end
        -- Tắt va chạm và đặt thuộc tính vật lý về 0
        part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
        part.CanCollide = false
        -- Áp dụng ForcePart để chuẩn bị Part cho Tornado
        ForcePart(part) 
        return true
    end
    return false
end

-- Hàm quản lý bảng `parts`
local function addPart(part)
    if RetainPart(part) and not table.find(parts,part) then
        table.insert(parts,part)
    end
end
local function removePart(part)
    local idx = table.find(parts,part)
    if idx then table.remove(parts,idx) end
end

-- Thu thập các Part hiện có và kết nối sự kiện thêm/xóa Part mới
for _, part in pairs(Workspace:GetDescendants()) do addPart(part) end
Workspace.DescendantAdded:Connect(addPart)
Workspace.DescendantRemoving:Connect(removePart)

-- VÒNG LẶP CHÍNH CỦA TORNADO
RunService.Heartbeat:Connect(function()
    -- Chỉ chạy nếu lốc xoáy đang được bật
    if not ringPartsEnabled then return end
    
    local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if humanoidRootPart then
        local center = humanoidRootPart.Position -- Tâm lốc xoáy là vị trí nhân vật
        
        for _, part in pairs(parts) do
            if part.Parent and not part.Anchored then
                local pos = part.Position
                
                -- Tính toán khoảng cách 2D (trên mặt phẳng XZ) và góc hiện tại
                local dist = (Vector3.new(pos.X, center.Y, pos.Z) - center).Magnitude
                local angle = math.atan2(pos.Z - center.Z, pos.X - center.X)
                
                -- Tính toán góc mới (xoay)
                local newAngle = angle + math.rad(rotationSpeed)
                
                -- Tính toán vị trí mục tiêu của Tornado
                local targetPos = Vector3.new(
                    center.X + math.cos(newAngle) * math.min(radius, dist), -- X: Xoay và giới hạn bán kính
                    center.Y + (height * math.abs(math.sin((pos.Y - center.Y)/height))), -- Y: Đẩy lên/xuống theo hình xoắn ốc
                    center.Z + math.sin(newAngle) * math.min(radius, dist) -- Z: Xoay và giới hạn bán kính
                )
                
                -- Áp dụng lực Velocity để kéo Part về vị trí mục tiêu
                local dir = (targetPos - part.Position).Unit
                part.Velocity = dir * attractionStrength
            end
        end
    end
end)
----------------------------------------------------------------------
-- Start UI
----------------------------------------------------------------------

local Window = Rayfield:CreateWindow({
   Name = "KTM Hub",
   Icon = 0, 
   LoadingTitle = "v1.0.3 (Beta)",
   LoadingSubtitle = "by HKatama299",
   ShowText = "-KTM Hub-", 
   Theme = "Amethyst", 
   ToggleUIKeybind = "y", 
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, 
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "KTM", -- Cần đặt trong chuỗi (string)
      FileName = "Config"
   },
   Discord = {
      Enabled = false, 
      Invite = "noinvitelink", 
      RememberJoins = true 
   },
   KeySystem = true, 
   KeySettings = {
      Title = "Key system",
      Subtitle = "Enter key",
      Note = "Key: Windows || Linux", 
      FileName = "Key", 
      SaveKey = true, 
      GrabKeyFromSite = false, 
      Key = {"Linux", "Windows"} -- Sửa lại định dạng table
   }
})
local myspeed
local myjump
local speed    = 80         -- vận tốc bay mặc định
local flying   = false       -- trạng thái
local bv, bg   -- BodyVelocity & BodyGyro
local loopConn -- kết nối RenderStepped

-- TAB HOME (Speed, Jump, Fly)
local MainTab = Window:CreateTab("Home", nil)
local MainSection = MainTab:CreateSection("Simple")

local Speed_Slider = MainTab:CreateSlider({
   Name = "Slider WalkSpeed",
   Range = {16, 40},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SliderWalkSpeed", -- Sửa flag
   Callback = function(Value)
        myspeed = (Value)
   end,
})
local Speed_Toggle = MainTab:CreateToggle({
   Name = "Walk Speed",
   CurrentValue = false,
   Flag = "ToggleWalkSpeed", -- Sửa flag
   Callback = function(Value)
        if (Value) then
            while (Value) do
                wait(1)
                player.Character.Humanoid.WalkSpeed = (myspeed)
            end
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
   end,
})

local Jump_Slider = MainTab:CreateSlider({
   Name = "Slider JumpPower",
   Range = {5, 200},
   Increment = 5,
   Suffix = "JumpPower",
   CurrentValue = 16,
   Flag = "SliderJumpPower", -- Sửa flag
   Callback = function(Value)
        myjump = (Value)
   end,
})
local Jump_Toggle = MainTab:CreateToggle({
   Name = "Jump Power",
   CurrentValue = false,
   Flag = "ToggleJumpPower", -- Sửa flag
   Callback = function(Value)
        if (Value) then
            player.Character.Humanoid.JumpPower = (myjump)
        else
            player.Character.Humanoid.JumpPower = 50 -- Đổi về 50 cho JumpPower mặc định (hoặc 16 nếu bạn muốn)
        end
   end,
})
local Button = MainTab:CreateButton({
   Name = "Infinite Jump",
   Callback = function()
--Toggles the infinite jump between on or off on every script run
_G.infinjump = not _G.infinjump
if _G.infinJumpStarted == nil then
	--Ensures this only runs once to save resources
	_G.infinJumpStarted = true
	--The actual infinite jump
	local plr = game:GetService('Players').LocalPlayer
	local m = plr:GetMouse()
	m.KeyDown:connect(function(k)
		if _G.infinjump then
			if k:byte() == 32 then
			humanoid = game:GetService'Players'.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
			humanoid:ChangeState('Jumping')
			task.wait() -- Dùng task.wait()
			humanoid:ChangeState('Seated')
			end
		end
	end)
end
   end,
})
local Noclip_Toggle = MainTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "Noclip-Toggle", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        if (Value) then
            print(Value)
            else
            print(Value)
        end
   end,
})

local Section = MainTab:CreateSection("Fly")
local Fly_Slider = MainTab:CreateSlider({
   Name = "FlySpeed",
   Range = {30, 100},
   Increment = 1,
   Suffix = "Fly Speed",
   CurrentValue = 70,
   Flag = "SliderFlySpeed", -- Sửa flag
   Callback = function(Value)
        speed = (Value)
   end,
})
------------------------------------------------------------
-- HÀM BẮT ĐẦU BAY
------------------------------------------------------------
local function startFly()
	flying = true
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	local hum  = char:WaitForChild("Humanoid")

	hum.PlatformStand = true

	bg = Instance.new("BodyGyro")
	bg.P        = 1e5
	bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
	bg.Parent    = root

	bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e5,1e5,1e5)
	bv.Parent   = root

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
-- HÀM DỪNG BAY
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
-- HÀM CHUYỂN TRẠNG THÁI BAY
------------------------------------------------------------
local Button = MainTab:CreateButton({
   Name = "Fly (Start/Stop)",
   Callback = function()
    if flying then
		stopFly()
	else
		startFly()
	end
   end,
})

-- TAB NDS (Tornado)
local NDSTab = Window:CreateTab("NDS", nil) 
local TornadoSection = NDSTab:CreateSection("Tornado")

local Toggle = NDSTab:CreateToggle({
   Name = "Tornado",
   CurrentValue = false,
   Flag = "ToggleTornado", -- Sửa flag
   Callback = function(Value)
        if (Value) then
            ringPartsEnabled = true
        else
            ringPartsEnabled = false
        end
   end,
})
local RadiusSlider = NDSTab:CreateSlider({
   Name = "Radius",
   Range = {40, 100},
   Increment = 2,
   Suffix = "Stud",
   CurrentValue = 50,
   Flag = "RadiusSlider", 
   Callback = function(Value)
        radius = (Value)
   end,
})
local HeightSlider = NDSTab:CreateSlider({
   Name = "Height",
   Range = {80, 400},
   Increment = 10,
   Suffix = "Height",
   CurrentValue = 100,
   Flag = "HeightSlider", 
   Callback = function(Value)
        height = (Value)
   end,
})
local RotationSlider = NDSTab:CreateSlider({
   Name = "Rotation Speed",
   Range = {0, 2},
   Increment = 0.1,
   Suffix = "Rotation",
   CurrentValue = 0.5,
   Flag = "RotationSlider", -- Sửa flag
   Callback = function(Value)
        rotationSpeed = (Value)
   end,
})
local AttractionSlider = NDSTab:CreateSlider({ -- SỬA: Dùng NDSTab thay vì Tab
   Name = "Attraction Strength",
   Range = {800, 3000},
   Increment = 200,
   Suffix = "Attractions",
   CurrentValue = 1000,
   Flag = "AttractionSlider", -- Sửa flag
   Callback = function(Value)
        attractionStrength = (Value)
   end,
})
local Fling_Section = NDSTab:CreateSection("Fling")
local FlingButton = NDSTab:CreateButton({
   Name = "Fling 1",
   Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ThawaBR/Touch-Fling/refs/heads/main/source"))()
   end,
})

local TP_Tab = Window:CreateTab("TP", nil) -- Title, Image
local C1_Section = TP_Tab:CreateSection("Checkpoint 1")

local SetCheckpointButton1 = TP_Tab:CreateButton({
   Name = "Set checkpoint",
   Callback = function()
        setCheckpoint() -- Gọi hàm đặt Checkpoint
   end,
})

local TeleportButton = TP_Tab:CreateButton({
   Name = "Teleport to checkpoint 1",
   Callback = function()
        teleportToCheckpoint()
   end,
})