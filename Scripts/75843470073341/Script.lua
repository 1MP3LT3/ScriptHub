-- // Variables

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local lplr = Players.LocalPlayer
local isTeleported = false
local originalPosition = nil
local platform = nil
local platformConnection = nil
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local chrs = {}
local Emotes =
	game:GetService("ReplicatedStorage"):WaitForChild("Storage"):WaitForChild("BaseAnimations"):WaitForChild("Emotes")
local RenderredEmotes = {}
local EmotePlaying = {}
local lplr = game:GetService("Players").LocalPlayer
local EmoteNames = {}
for _, Emote in Emotes:GetChildren() do
	table.insert(EmoteNames, Emote.Name)
end

-- // Functions

local function PlayEmote(Emote)
	RenderredEmotes[Emote]:Play()
end

local function RenderEmotes()
	for _, Emote in Emotes:GetChildren() do
		local Animator: Animator = lplr.Character:WaitForChild("Humanoid"):WaitForChild("Animator")

		local AnimT = Animator:LoadAnimation(Emote)
		AnimT.Priority = Enum.AnimationPriority.Action4

		AnimT:GetPropertyChangedSignal("IsPlaying"):Connect(function()
			if AnimT.IsPlaying then
				local OldJumpHeight = lplr.Character:WaitForChild("Humanoid").JumpHeight

				AnimT.Stopped:Once(function()
					lplr.Character:WaitForChild("Humanoid").JumpHeight = OldJumpHeight
				end)
			end
		end)

		lplr.Character:WaitForChild("Humanoid").Jumping:Connect(function(active)
			AnimT:Stop()
		end)

		local OldHealth = lplr.Character:WaitForChild("Humanoid").Health
		lplr.Character:WaitForChild("Humanoid").HealthChanged:Connect(function()
			if OldHealth > lplr.Character:WaitForChild("Humanoid").Health then
				AnimT:Stop()
			end
			OldHealth = lplr.Character:WaitForChild("Humanoid").Health
		end)

		RenderredEmotes[Emote.Name] = AnimT
	end
end

local function SetupCharacter(Player)
	local function AddToListOfCharacters(Character)
		table.insert(chrs, Character)
	end

	local function RemoveToListOfCharacters(Character)
		local chrnumber = nil
		for Number, chr in ipairs(chrs) do
			if chr == Character then
				chrnumber = Number
			end
		end

		table.remove(chrs, chrnumber)
	end

	if Player.Character then
		AddToListOfCharacters(Player.Character)
	end

	Player.CharacterAdded:Connect(AddToListOfCharacters)

	Player.CharacterRemoving:Connect(RemoveToListOfCharacters)
end

local function disableMapCollision()
	local mapFolder = Workspace:FindFirstChild("Map")
	local boundariesFolder = Workspace:WaitForChild("Ignore"):FindFirstChild("Boundaries")
	if mapFolder then
		for _, descendant in mapFolder:GetDescendants() do
			if descendant:IsA("BasePart") and descendant.CanCollide then
				-- Don't disable collision for our platform
				if not (descendant:FindFirstChild("TeleportPlatform") or descendant.Name == "Emit") then
					descendant.CanCollide = false
				end
			end
		end
	end
	if boundariesFolder then
		for _, boundarie in boundariesFolder:GetChildren() do
			if boundarie:IsA("Part") then
				boundarie.CanCollide = false
			end
		end
	end
end

local function restoreMapCollision()
	local mapFolder = Workspace:FindFirstChild("Map")
	local boundariesFolder = Workspace:WaitForChild("Ignore"):FindFirstChild("Boundaries")
	if mapFolder then
		for _, descendant in mapFolder:GetDescendants() do
			if descendant:IsA("BasePart") then
				-- Restore collision for all parts except our platform
				if not (descendant:FindFirstChild("TeleportPlatform") or descendant.Name == "Emit") then
					descendant.CanCollide = true
				end
			end
		end
		for _, boundarie in boundariesFolder:GetChildren() do
			if boundarie:IsA("Part") then
				boundarie.CanCollide = true
			end
		end
	end
	if boundariesFolder then
		for _, boundarie in boundariesFolder:GetChildren() do
			if boundarie:IsA("Part") then
				boundarie.CanCollide = true
			end
		end
	end
end

local function createPlatform()
	platform = Instance.new("Part")
	platform.Name = "TeleportPlatform_" .. player.UserId
	platform.Size = Vector3.new(8, 1, 8)
	platform.Material = Enum.Material.Neon
	platform.BrickColor = BrickColor.new("Cyan")
	platform.Anchored = true
	platform.CanCollide = true
	platform.Transparency = 0.3
	platform.Parent = Workspace

	-- Add a tag to identify this platform
	local tag = Instance.new("BoolValue")
	tag.Name = "TeleportPlatform"
	tag.Parent = platform

	return platform
end

local function startPlatformFollowing()
	if platformConnection then
		platformConnection:Disconnect()
	end

	platformConnection = RunService.Heartbeat:Connect(function()
		if isTeleported then
			local character = player.Character
			if character and character.PrimaryPart then
				-- Check if platform exists, if not create a new one
				if not platform or not platform.Parent then
					createPlatform()
				end

				-- Position platform under player
				platform.Position = character.PrimaryPart.Position - Vector3.new(0, 3.5, 0)
			end
		end
	end)
end
local function teleportToTarget()
	local character = player.Character
	if not character or not character.PrimaryPart then
		return
	end

	-- Store original position
	originalPosition = character.PrimaryPart.CFrame

	-- Disable Map collision
	disableMapCollision()

	-- Create platform at current position
	createPlatform()

	-- Move player down by -5 studs
	local currentPosition = character.PrimaryPart.CFrame
	character.PrimaryPart.CFrame = currentPosition * CFrame.new(0, -10, 0)

	-- Start platform following
	startPlatformFollowing()

	isTeleported = true
end
local function teleportBack()
	local character = player.Character
	if not character or not character.PrimaryPart then
		return
	end

	if originalPosition then
		-- Teleport back to original position
		character.PrimaryPart.CFrame = originalPosition

		-- Clean up platform (only when Z is pressed again)
		if platform and platform.Parent then
			platform:Destroy()
			platform = nil
		end

		-- Stop platform following
		if platformConnection then
			platformConnection:Disconnect()
			platformConnection = nil
		end
		task.delay(0.1, function()
			-- Restore Map collision
			restoreMapCollision()
		end)

		isTeleported = false
		originalPosition = nil
	end
end

local function safecall(func)
	task.spawn(function()
		pcall(func)
	end)
end
-- // Load

for _, Player in Players:GetPlayers() do
	if Player == lplr then
		continue
	end
	SetupCharacter(Player)
end

Players.PlayerAdded:Connect(SetupCharacter)

game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
	if _G.AutoAttack then
		safecall(function()
			local Insts = {}

			for _, chr in ipairs(chrs) do
				local PrimaryPart = nil
				repeat
					task.wait()
					PrimaryPart = chr.PrimaryPart
				until PrimaryPart

				local Value = (PrimaryPart.Position - lplr.Character.PrimaryPart.Position).Magnitude

				if Value < _G.ReachAutoAttack then
					local Player = Players:FindFirstChild(chr.Name)

					if _G.ExpectionAutoAttack == "Friends" and lplr:IsFriendsWithAsync(Player.UserId) then
						continue
					end

					local DuelActivated = Player.DuelFolder.DuelInfo.IsActive.Value

					local IsInLobby = not chr:GetAttribute("Spawned")
					local InTurtorial = Player:GetAttribute("Turtorial")
					local Health0 = (chr:FindFirstChild("Humanoid") and chr.Humanoid.Health <= 0) and true
					local BlockDetected = chr:FindFirstChild("Blocking")
					local CounterDetected = chr:FindFirstChild("CounterReturner")

					if
						not (
							DuelActivated
							or InTurtorial
							or Health0
							or IsInLobby
							or (BlockDetected and _G.AutoDetectBlock)
							or (CounterDetected and _G.AutoDetectCounters)
						)
					then
						table.insert(Insts, chr)
					end
				end
			end

			local Targets = {}

			for _, Inst in Insts do
				if _G.AutoAttackFLING then
					table.insert(Targets, {
						Inst = Inst,
						CF = CFrame.new(0, 0, 0),
					})
				else
					table.insert(Targets, {
						Inst = Inst,
						CF = (_G.NOKNOCKBACKAURA and Inst.PrimaryPart.CFrame * Vector3.new(1, 1, -1))
							or Inst.PrimaryPart.CFrame,
					})
				end
			end

			safecall(function()
				local args = {}
				if _G.AutoAttackFLING then
					args = {
						{
							1767074436,
							{
								"M1HitRequest",
								CFrame.new(Vector3.new(math.huge, math.huge, math.huge)),
								4,
								"Combat_AdamDash",
								1767074436,
								{
									unpack(Targets),
								},
							},
						},
					}
				else
					args = {
						{
							1767074436,
							{
								"M1HitRequest",
								lplr.Character.PrimaryPart.CFrame,
								1,
								"Combat_AdamDash",
								1767074436,
								{
									unpack(Targets),
								},
							},
						},
					}
				end

				safecall(function()
					lplr:WaitForChild("Input"):FireServer(unpack(args))
				end)
			end)
		end)
	end
	if _G.WalkSpeedToggle then
		safecall(function()
			local chr = lplr.Character
			if chr then
				local Humanoid = chr:WaitForChild("Humanoid", 1) or nil
				if Humanoid then
					Humanoid.WalkSpeed = _G.WalkSpeedSlider
				end
			end
		end)
	end
	if _G.AutoFarm then
		local chrsLOADED = {}

		for _, chr in chrs do
			safecall(function()
				if chr:GetAttribute("Spawned") and not (chr.Humanoid.Health <= 0) then
					table.insert(chrsLOADED, chr)
				end
			end)
		end

		local Targets = {}

		for _, chrLOADED in chrsLOADED do
			safecall(function()
				table.insert(Targets, {
					Inst = chrLOADED,
					CF = CFrame.new(0, 0, 0),
				})
			end)
		end

		for _, chr in chrsLOADED do
			if
				_G.OccupiedChr and _G.OccupiedChr ~= chr
				or not _G.RevokeAccess == chr
				or chr:FindFirstChild("CounterReturner")
				or chr:GetAttribute("Turtorial")
			then
				continue
			end

			safecall(function()
				lplr.Character.PrimaryPart.CFrame = chr.PrimaryPart.CFrame

				if not _G.OccupiedChr then
					_G.OccupiedChr = chr
					task.delay(0.05, function()
						_G.RevokeAccess = chr
						_G.OccupiedChr = nil
					end)
				end

				local args = {
					{
						1767074436,
						{
							"M1HitRequest",
							lplr.Character.PrimaryPart.CFrame,
							1,
							"Combat_AdamDash",
							1767074436,
							{
								unpack(Targets),
							},
						},
					},
				}

				task.wait(0.01)

				lplr:WaitForChild("Input"):FireServer(unpack(args))
			end)
			task.wait(0.05)
		end
	end
end)

lplr.CharacterAdded:Connect(RenderredEmotes)

if lplr.Character then
	RenderEmotes()
end
-- // _G Stuff

_G.ReachAutoAttack = 15
_G.WalkSpeedSlider = 16

-- // UI

local Luna = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/luna", true))()

local Window = Luna:CreateWindow({
	Name = "GDPR", -- This Is Title Of Your Window
	Subtitle = "Version: 1.0", -- A Gray Subtitle next To the main title.
	LogoID = 76165628540410, -- The Asset ID of your logo. Set to nil if you do not have a logo for Luna to use.
	LoadingEnabled = true, -- Whether to enable the loading animation. Set to false if you do not want the loading screen or have your own custom one.
	LoadingTitle = "GDPR", -- Header for loading screen
	LoadingSubtitle = "by FOREST FIRE DEVELEPEMENT TEAM", -- Subtitle for loading screen

	ConfigSettings = {
		RootFolder = "GDPR", -- The Root Folder Is Only If You Have A Hub With Multiple Game Scripts and u may remove it. DO NOT ADD A SLASH
		ConfigFolder = "SuddenImpact", -- The Name Of The Folder Where Luna Will Store Configs For This Script. DO NOT ADD A SLASH
	},
})

local Main = Window:CreateTab({
	Name = "Main",
	ShowTitle = true, -- This will determine whether the big header text in the tab will show
})

local Credits = Window:CreateTab({
	Name = "Credits",
	ShowTitle = false, -- This will determine whether the big header text in the tab will show
})

local UISettings = Window:CreateTab({
	Name = "UI Settings",
	ShowTitle = true, -- This will determine whether the big header text in the tab will show
})

Credits:CreateSection(
	'<font color="rgb(255,0,0)">[enzoe15226 (Crimson)]</font> On Discord For Main Developer <font color="rgb(255,100,0)">im</font> writing this btw!'
)

Main:CreateSection("Player")

Main:CreateToggle({
	Name = "Speed Toggle",
	Default = false, -- Default value (true / false

	Callback = function(Value)
		_G.WalkSpeedToggle = Value
	end,
}, "WalkSpeedToggle")
Main:CreateSlider({
	Name = "Speed",
	CurrentValue = 16,
	Range = { 16, 100 },
	Increment = 1,
	Compact = false,

	Callback = function(Value)
		_G.WalkSpeedSlider = Value
	end,
}, "WalkSpeedSlider")

Main:CreateSection("Aura")

Main:CreateToggle({
	Name = "Aura Attack",
	Default = false, -- Default value (true / false)
	Visible = true,

	Callback = function(Value)
		_G.AutoAttack = Value
	end,
}, "AutoAttack")
Main:CreateToggle({
	Name = "No Aura Knockback",
	Default = false, -- Default value (true / false)

	Callback = function(Value)
		_G.NOKNOCKBACKAURA = Value
	end,
}, "NOAURAKNOCKB2CK")
Main:CreateToggle({
	Name = "Aura Fling",
	Default = false, -- Default value (true / false)

	Callback = function(Value)
		_G.AutoAttackFLING = Value
	end,
}, "AutoAttackFLING")
Main:CreateDropdown({
	Options = { "Friends", "Nobody" },
	CurrentOption = { "Nobody" },
	Name = "Expections",

	Callback = function(Value)
		_G.ExpectionAutoAttack = Value
	end,
}, "AutoAttackExpection")
Main:CreateDivider()
Main:CreateToggle({
	Name = "Ignore Blocks",
	Default = false, -- Default value (true / false)
	Disabled = not IsPremium,

	Callback = function(Value)
		_G.AutoDetectBlock = Value
	end,
}, "AutoDetectBlocks")
Main:CreateToggle({
	Name = "Ignore Counters",
	Default = false, -- Default value (true / false)
	Disabled = not IsPremium,

	Callback = function(Value)
		_G.AutoDetectCounters = Value
	end,
}, "AutoDetectCounters")
Main:CreateDivider()
Main:CreateSlider({
	Name = "Aura Attack Reach",
	CurrentValue = 15,
	Range = { 10, 25 },
	Increment = 1,
	Compact = false,

	Callback = function(Value)
		_G.ReachAutoAttack = Value
	end,
}, "AutoAttackReach")
Main:CreateSection("Others")
Main:CreateToggle({
	Name = "Auto Farm",
	Default = false, -- Default value (true / false)
	Disabled = not IsPremium,

	Callback = function(Value)
		_G.AutoFarm = Value
	end,
}, "AutoFarm")
Main:CreateDivider()
Main:CreateToggle({
	Name = "Hide Underground",
	Default = false, -- Default value (true / false)
	Disabled = not IsPremium,

	Callback = function(Value)
		if not isTeleported then
			teleportToTarget()
		else
			teleportBack()
		end
	end,
}, "HideUnderGround")
Main:CreateSection("Emote Player FE")
Main:CreateDropdown({
	Options = EmoteNames,
	CurrentOption = { EmoteNames[1] },
	Name = "Emotes",

	Callback = function(Value)
		_G.SelectedEmote = Value
	end,
}, "EmoteSelected")
Main:CreateButton({
	Name = "Play Emote Selected",
	Callback = function()
		PlayEmote(_G.SelectedEmote)
	end,
	DoubleClick = false,

	Description = "sets the current clipboard to The Discord Invite",
	DisabledDescription = "I am disabled!",

	Disabled = false, -- Will disable the button (true / false)
	Visible = true, -- Will make the button invisible (true / false)
	Risky = false, -- Makes the text red (the color can be changed using Library.Scheme.Red) (Default value = false)
})
Credits:CreateParagraph({
	Name = "Credits",
	Text = '<stroke color="rgb(0,0,0)" thickness="2"><font color="rgb(255,0,0)">[enzoe15226 (Crimson)]</font></stroke> Made The Full Script \n <stroke color="rgb(0,0,0)" thickness="2"><font color="rgb(128, 0, 128)">[lunaa_cat. (Incognito)]</font></stroke> Made Hide Underground',
	DoesWrap = true,
})

Credits:CreateButton({
	Name = '<font color="rgb(255,0,0)">[Set Clipboard To Discord Invite]</font>!',
	Callback = function()
		local fgd = loadstring(
			game:HttpGet("https://raw.githubusercontent.com/dizzyhvh/Forest-Fire/refs/heads/main/discordurl.lua")
		)()
		setclipboard(tostring(fgd))
	end,
	DoubleClick = false,

	Description = "sets the current clipboard to The Discord Invite",
	DisabledDescription = "I am disabled!",

	Disabled = false, -- Will disable the button (true / false)
	Visible = true, -- Will make the button invisible (true / false)
	Risky = false, -- Makes the text red (the color can be changed using Library.Scheme.Red) (Default value = false)
})

UISettings:BuildConfigSection() -- Tab Should be the name of the tab you are adding this section to.

Luna:LoadAutoloadConfig()
