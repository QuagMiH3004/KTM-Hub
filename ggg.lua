-- File: Beta1_Optimized.lua
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService         = game:GetService("RunService")
local Workspace          = game:GetService("Workspace")
local LocalPlayer        = Players.LocalPlayer
local uis                = game:GetService("UserInputService")
local rs                 = game:GetService("RunService")
local player             = LocalPlayer -- Sử dụng biến đã khai báo để nhất quán
local Players = game:GetService("Players")

-- Biến nhân vật (được khai báo 1 lần)
local character          = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart   = character:WaitForChild("HumanoidRootPart")

-- BIẾN CỐT LÕI TORNADO (Không trùng lặp, dùng để UI điều khiển)
local radius             = 50
local height             = 100
local rotationSpeed      = 0.5
local attractionStrength = 1000
local ringPartsEnabled   = false -- Biến Tắt/Mở chính
local parts              = {}    -- Bảng lưu trữ các vật thể bị ảnh hưởng
-- Noclip
-- ==================== KHAI BÁO BIẾN HỖ TRỢ CHO GHOST MODE ====================

-- Bảng lưu trữ các Part đang trong chế độ Ghost Mode để tránh xử lý trùng lặp
local ghostParts         = {}
local touchConnection    = nil   -- Biến lưu trữ kết nối sự kiện Touched
local isGhostModeActive  = false -- Trạng thái Toggle chính

-- ==================== HÀM XỬ LÝ KHI CHẠM VÀO PART ====================
local function onPartTouched(otherPart)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if root and isGhostModeActive and otherPart:IsA("BasePart") and not otherPart.Anchored and not ghostParts[otherPart] then [cite: 7]
        -- Lọc để chỉ xử lý khi HumanoidRootPart chạm vào vật thể
        if otherPart.Parent == root.Parent then return end -- Part thuộc về nhân vật thì bỏ qua

        -- Lấy giá trị CanCollide ban đầu để phục hồi sau này
        local originalCanCollide = otherPart.CanCollide 

        -- Chỉ xử lý nếu vật thể ban đầu KHÔNG THỂ XUYÊN QUA (CanCollide = true) [cite: 8]
        if originalCanCollide then
            
            -- Đánh dấu Part này đang được xử lý (và lưu trạng thái CanCollide gốc)
            -- CHỈ LƯU TRẠNG THÁI GỐC LÀ originalCanCollide
            ghostParts[otherPart] = originalCanCollide

            print("Kích hoạt chế độ xuyên thấu cho Part: " .. otherPart.Name) [cite: 8]

            -- TẮT VA CHẠM (Xuyên qua ngay lập tức) [cite: 8]
            otherPart.CanCollide = false
            
            -- *** ĐÃ XÓA: task.wait(2) và logic phục hồi Va chạm tự động ***
        end
    end
end
function toggleGhostMode(shouldBeActive)
    if shouldBeActive then
        if not isGhostModeActive then
            -- Bắt đầu lắng nghe sự kiện Touched của nhân vật [cite: 11]
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- Kết nối sự kiện Touched vào hàm xử lý [cite: 11]
                touchConnection = root.Touched:Connect(onPartTouched)
                isGhostModeActive = true [cite: 12]
                print("Chế độ Ghost Mode ĐÃ BẬT. Bắt đầu lắng nghe va chạm.") [cite: 12]
            end
        end
    else
        -- ----------------------------------------------------
        -- THÊM LOGIC PHỤC HỒI VA CHẠM HÀNG LOẠT
        -- ----------------------------------------------------
        -- Duyệt qua tất cả các Part đang trong chế độ Ghost Mode
        for part, originalCanCollide in pairs(ghostParts) do
            if part and part.Parent then -- Kiểm tra Part còn tồn tại không
                -- Đặt lại CanCollide về giá trị gốc đã lưu
                part.CanCollide = originalCanCollide
                print("Va chạm đã được BẬT lại cho Part: " .. part.Name)
            end
        end
        -- Xóa sạch bảng ghostParts sau khi phục hồi
        ghostParts = {}
        
        -- Ngắt kết nối sự kiện Touched [cite: 12]
        if touchConnection then
            touchConnection:Disconnect() [cite: 13]
            touchConnection = nil [cite: 13]
            isGhostModeActive = false [cite: 13]
            print("Chế độ Ghost Mode ĐÃ TẮT. Không còn xử lý va chạm.") [cite: 14]
        end
    end
end
--------------------------------------------------------
--EZ
--------------------------------------------------------
-- KHAI BÁO BIẾN CHO WALK SPEED (Mới)
local isWalkSpeedToggleActive = false -- Biến trạng thái mới
local walkSpeedLoop           = nil   -- Biến lưu trữ luồng vòng lặp
local myspeed                 = 16    -- Giá trị mặc định ban đầu cho slider
local myjump                  = 50    -- Giá trị mặc định ban đầu cho Jump
-- ...
-------------------------------------------------------------------------------------------------------------------------------------------------------
--Set checkpoint
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Biến lưu trữ CFrame của Checkpoint
local checkPointCFrame = nil
local checkPointPart = nil -- Biến lưu trữ khối Part Checkpoint (nếu có)

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
    newPart.BrickColor = BrickColor.new("Lime green") -- Màu xanh lá cây
    newPart.Transparency = 0.5                        -- Hơi trong suốt
    newPart.Anchored = true                           -- Không di chuyển
    newPart.CanCollide = false                        -- Có thể đi xuyên qua
    newPart.Name = "LocalCheckpoint"

    -- 2. Đặt vị trí
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
        local checkpointPosition = checkPointCFrame *
            CFrame.new(0, 1.5 + 3 / 2, 0) -- Nâng lên 1.5 stud + nửa chiều cao Part

        createCheckpointPart(checkpointPosition)

        -- In thông báo thành công
        print("Checkpoint đã được đặt tại: " .. tostring(checkPointCFrame.Position))
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
        Torque.Torque = Vector3.new(100000, 100000, 100000)

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
        part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        part.CanCollide = false
        -- Áp dụng ForcePart để chuẩn bị Part cho Tornado
        ForcePart(part)
        return true
    end
    return false
end

-- Hàm quản lý bảng `parts`
local function addPart(part)
    if RetainPart(part) and not table.find(parts, part) then
        table.insert(parts, part)
    end
end
local function removePart(part)
    local idx = table.find(parts, part)
    if idx then table.remove(parts, idx) end
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
                    center.X + math.cos(newAngle) * math.min(radius, dist),                -- X: Xoay và giới hạn bán kính
                    center.Y + (height * math.abs(math.sin((pos.Y - center.Y) / height))), -- Y: Đẩy lên/xuống theo hình xoắn ốc
                    center.Z +
                    math.sin(newAngle) *
                    math.min(radius, dist)                                                 -- Z: Xoay và giới hạn bán kính
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

local Window        = Rayfield:CreateWindow({
    Name = "KTM Hub",
    Icon = 0,
    LoadingTitle = "v1.1.6 (Beta)",
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
        Note = "Key: Linux || Windows",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = { "Linux", "Windows" } -- Sửa lại định dạng table
    }
})
local myspeed
local myjump
local speed         = 80    -- vận tốc bay mặc định
local flying        = false -- trạng thái
local bv, bg                -- BodyVelocity & BodyGyro
local loopConn              -- kết nối RenderStepped

-- TAB HOME (Speed, Jump, Fly)
local MainTab       = Window:CreateTab("Home", nil)
local MainSection   = MainTab:CreateSection("Simple")

local Speed_Slider  = MainTab:CreateSlider({
    Name = "Slider WalkSpeed",
    Range = { 16, 40 },
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "SliderWalkSpeed", -- Sửa flag
    Callback = function(Value)
        myspeed = (Value)
    end,
})
local Speed_Toggle  = MainTab:CreateToggle({
    Name = "Walk Speed",
    CurrentValue = false,
    Flag = "ToggleWalkSpeed",
    Callback = function(Value)
        isWalkSpeedToggleActive = Value -- (1) Cập nhật cờ kiểm soát

        if Value then
            -- (2) KHỞI ĐỘNG LUỒNG MỚI CHO VÒNG LẶP
            walkSpeedLoop = task.spawn(function()
                while isWalkSpeedToggleActive do
                    task.wait(1) -- Cập nhật mỗi 1 giây
                    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = myspeed
                    end
                end
            end)
        else
            -- (3) DỪNG LUỒNG VÀ ĐẶT LẠI GIÁ TRỊ
            if walkSpeedLoop then
                task.cancel(walkSpeedLoop) -- Ngừng luồng ngay lập tức
                walkSpeedLoop = nil
            end
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
    end,
})

local Jump_Slider   = MainTab:CreateSlider({
    Name = "Slider JumpPower",
    Range = { 5, 200 },
    Increment = 5,
    Suffix = "JumpPower",
    CurrentValue = 16,
    Flag = "SliderJumpPower", -- Sửa flag
    Callback = function(Value)
        myjump = (Value)
    end,
})
local Jump_Toggle   = MainTab:CreateToggle({
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
local Button        = MainTab:CreateButton({
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
                        humanoid = game:GetService 'Players'.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
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
        toggleGhostMode(Value)
    end,
})

local Section       = MainTab:CreateSection("Fly")
local Fly_Slider    = MainTab:CreateSlider({
    Name = "FlySpeed",
    Range = { 30, 100 },
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
    flying            = true
    local char        = player.Character or player.CharacterAdded:Wait()
    local root        = char:WaitForChild("HumanoidRootPart")
    local hum         = char:WaitForChild("Humanoid")

    hum.PlatformStand = true

    bg                = Instance.new("BodyGyro")
    bg.P              = 1e5
    bg.MaxTorque      = Vector3.new(1e5, 1e5, 1e5)
    bg.Parent         = root

    bv                = Instance.new("BodyVelocity")
    bv.MaxForce       = Vector3.new(1e5, 1e5, 1e5)
    bv.Parent         = root

    loopConn          = rs.RenderStepped:Connect(function()
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
    Range = { 40, 100 },
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
    Range = { 80, 400 },
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
    Range = { 0, 2 },
    Increment = 0.1,
    Suffix = "Rotation",
    CurrentValue = 0.5,
    Flag = "RotationSlider", -- Sửa flag
    Callback = function(Value)
        rotationSpeed = (Value)
    end,
})
local AttractionSlider = NDSTab:CreateSlider({
    Name = "Attraction Strength",
    Range = { 800, 3000 },
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
local WW2_Section = TP_Tab:CreateSection("ww2 tanks sim")
-- ==================== KHỐI DỮ LIỆU VỊ TRÍ CỐ ĐỊNH ====================

-- Bảng lưu trữ tên và tọa độ của các điểm dịch chuyển
local FixedTeleportLocations = {
    -- Tên hiển thị = Vector3.new(X, Y, Z)
    ["Spawn"] = Vector3.new(1039.132, 5, 878.529),
    ["Normal Spawn"] = Vector3.new(-176.264, 10, -7.797),
    ["USA"] = Vector3.new(787.818, 15, 327.274),
    ["Plane"] = Vector3.new( -434.277, 5, -10.98),
    ["Flamethrower"] = Vector3.new(100, 500, 20),
    ["Panzerfaust"] = Vector3.new(-110.498, 5, -408.433),
    ["Bomber"] = Vector3.new(2407.033, 5, -2154.998),
}
-- MẢNG CHỈ CHỨA TÊN (KEY) DÙNG CHO OPTIONS CỦA DROPDOWN
local TeleportOptions = {}
for name, _ in pairs(FixedTeleportLocations) do
    table.insert(TeleportOptions, name)
end

-- =====================================================================
-- ==================== HÀM DỊCH CHUYỂN (ĐỘNG) ====================

-- Sử dụng LocalPlayer/player/character đã khai báo
local function teleportToFixedLocation(targetPosition)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = char:WaitForChild("HumanoidRootPart")

    -- Teleport nhân vật đến vị trí đã cho
    humanoidRootPart.CFrame = CFrame.new(targetPosition)

    print("Đã dịch chuyển đến vị trí cố định: " .. tostring(targetPosition))
end

-- ==================== TẠO DROPDOWN CHO TELEPORT ====================


-- 1. DROP DOWN ĐỂ CHỌN VỊ TRÍ
local LocationDropdown = TP_Tab:CreateDropdown({
    Name = "Chọn Vị Trí Dịch Chuyển",
    Options = TeleportOptions, -- Sử dụng mảng tên vị trí
    CurrentOption = { TeleportOptions[1] or "None" },
    MultipleOptions = false,
    Flag = "TeleportLocationDropdown",
    Callback = function(SelectedOptions)
        -- Khi người dùng chọn, lưu tên vị trí đã chọn
        -- (SelectedOptions là một bảng, nhưng vì MultipleOptions=false nên chỉ lấy phần tử đầu tiên)
        local selectedName = SelectedOptions[1]
        -- Không làm gì ở đây, chỉ lưu tên để nút Button sử dụng
    end,
})

-- 2. NÚT DỊCH CHUYỂN (Thực hiện hành động)
local TeleportExecuteButton = TP_Tab:CreateButton({
    Name = "TP to area",
    Callback = function()
        local selectedName = LocationDropdown:GetOptions()[1]     -- Lấy tên vị trí đang được chọn
        local targetVector = FixedTeleportLocations[selectedName] -- Lấy Vector3 tương ứng

        if targetVector then
            teleportToFixedLocation(targetVector) -- Gọi hàm dịch chuyển
        else
            warn("Lỗi: Không tìm thấy tọa độ cho vị trí: " .. selectedName)
        end
    end,
})