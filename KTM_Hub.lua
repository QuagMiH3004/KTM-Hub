local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

WindUI:AddTheme({
    Name = "KTM Theme", -- theme name
    
    Accent = WindUI:Gradient({                                                  
        ["0"] = { Color = Color3.fromHex("#1f1f23"), Transparency = 0 },        
        ["100"]   = { Color = Color3.fromHex("#18181b"), Transparency = 0 },    
    }, {                                                                        
        Rotation = 0,                                                           
    }),                                                                         
    Dialog = Color3.fromHex("#161616"),
    Outline = Color3.fromHex("#FFFFFF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#7a7a7a"),
    Background = Color3.fromHex("#101010"),
    Button = Color3.fromHex("#52525b"),
    Icon = Color3.fromHex("#a1a1aa")
})

local Window = WindUI:CreateWindow({
    Title = "KTM Hub",
    Icon = "blocks", -- lucide icon
    Author = "by HKatama299",
    Folder = "KTMHub",
    
    -- ↓ This all is Optional. You can remove it.
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    
    -- ↓ Optional. You can remove it.
    --[[ You can set 'rbxassetid://' or video to Background.
        'rbxassetid://':
            Background = "rbxassetid://", -- rbxassetid
        Video:
            Background = "video:YOUR-RAW-LINK-TO-VIDEO.webm", -- video 
    --]]
    
    -- ↓ Optional. You can remove it.
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("clicked")
        end,
    },
        WindUI:Notify({
    Title = "Roblox",
    Content = "KTM Hub started",
    Duration = 4, -- 3 seconds
    Icon = "circle-play",
})
    
local Tab = Window:MainTab({
    Title = "Main",
    Icon = "circle-check", -- optional
    Locked = false,
})
local Button = MainTab:Button({
    Title = "Print",
    Desc = "Test Button",
    Locked = false,
    Callback = function()
    WindUI:Notify({
        Title = "KTM Hub",
        Content = "Completed, Hello Roblox",
        Duration = 3, -- 3 seconds
        Icon = "message-square-text",
        })
    end
})

local Toggle = Tab:Toggle({
    Title = "Jump",
    Desc = "Infinity Jump",
    Icon = "toggle-right",
    Type = "Checkbox",
    Default = false,
    Callback = function(state) 
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
    end
})

local Tab = Window:ESPTab({
    Title = "Visual",
    Icon = "eye", -- optional
    Locked = false,
})

local Toggle = ESPTab:Toggle({
    Title = "ESP Player",
    Desc = "See Player",
    Icon = "scan-eye",
    Type = "Checkbox",
    Default = false,
    Callback = function(state) 
                    -- LocalScript này nên được đặt trong StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ESP_DISTANCE = 500  -- Khoảng cách tối đa để hiển thị chấm ESP (studs)
local ESP_SIZE = 10       -- Kích thước của chấm ESP (studs)

-- Hàm tạo BillboardGui và Frame cho người chơi mục tiêu
local function createESP(targetPlayer)
    -- Tạo BillboardGui
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "ESP_Dot"
    Billboard.Size = UDim2.new(0, ESP_SIZE, 0, ESP_SIZE) -- Kích thước cố định (dùng Offset)
    Billboard.AlwaysOnTop = true -- Luôn hiển thị trên mọi thứ
    Billboard.ExtentsOffset = Vector3.new(0, 5, 0) -- Đặt cao hơn đầu nhân vật một chút

    -- Tạo Frame (Chấm trắng)
    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(1, 0, 1, 0) -- Chiếm toàn bộ BillboardGui
    Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Màu trắng
    Dot.BorderSizePixel = 0
    Dot.CornerRadius = UDim.new(0.5, 0) -- Tạo hình tròn (50% của Size)
    Dot.Parent = Billboard

    -- Tìm HumanoidRootPart của người chơi mục tiêu để gắn vào
    local targetCharacter = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
    local RootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
    
    if RootPart then
        Billboard.Parent = RootPart -- Gắn Billboard vào phần thân chính
    end
    
    return Billboard
end

-- Hàm quản lý việc tạo/xóa ESP khi người chơi vào/ra
local function manageESP(player)
    -- Bỏ qua LocalPlayer
    if player == LocalPlayer then return end

    local espGui = nil

    -- Xử lý khi nhân vật được tải hoặc tái tạo (respawn)
    player.CharacterAdded:Connect(function(character)
        if espGui then 
            -- Xóa GUI cũ nếu nhân vật respawn
            espGui:Destroy() 
            espGui = nil
        end
        espGui = createESP(player)
    end)

    -- Xử lý việc hiển thị/ẩn dựa trên khoảng cách
    RunService.Heartbeat:Connect(function()
        if not espGui or not espGui.Parent or not LocalPlayer.Character then return end
        
        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetRoot = espGui.Parent:FindFirstChild("HumanoidRootPart")
        
        if localRoot and targetRoot then
            local distance = (localRoot.Position - targetRoot.Position).Magnitude
            
            -- Chỉ hiển thị chấm khi người chơi còn trong tầm nhìn
            espGui.Enabled = (distance <= ESP_DISTANCE)
        else
             -- Ẩn nếu không tìm thấy bộ phận cần thiết
            espGui.Enabled = false
        end
    end)
end

-- Bắt đầu quản lý ESP cho tất cả người chơi hiện có
for _, player in ipairs(Players:GetPlayers()) do
    manageESP(player)
end

-- Bắt đầu quản lý ESP cho người chơi mới tham gia sau này
Players.PlayerAdded:Connect(manageESP)
    end
})