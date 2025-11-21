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


--------------------------------------------------------
--EZ
--------------------------------------------------------
-- KHAI BÁO BIẾN CHO WALK SPEED (Mới)
local isWalkSpeedToggleActive = false -- Biến trạng thái mới
local walkSpeedLoop           = nil   -- Biến lưu trữ luồng vòng lặp
local myspeed                 = 16    -- Giá trị mặc định ban đầu cho slider
local myjump                  = 50    -- Giá trị mặc định ban đầu cho Jump
----------------------------------------------------------------------
-- Start UI
----------------------------------------------------------------------

local Window = Rayfield:CreateWindow({
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

})

})

