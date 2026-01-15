-- Forsaken Script !!!

-- Variables

local Exclusive_Emotes = {}
local Gettable_Emotes = {}
local Characters = {}
local Gens = {}
local Minions = {}
local Items = {}
local SPRINTINGTable = {}
local Sprays = {}
local Camera = workspace.CurrentCamera
local DefaultKillerESP = Color3.new(1, 0, 0)
local DefaultSurvivorESP = Color3.new(0, 1, 0)
local DefaultSpectatorESP = Color3.new(1, 1, 1)
local DefaultMininonESP = Color3.new(0, 0.9, 1)
local DefaultGeneratorNONCOMPLETEDESP = Color3.new(1, 0.5, 0)
local DefaultGeneratorCOMPLETEDESP = Color3.new(1, 1, 0)
local DefaultItemESP = Color3.new(0, 0.5, 1)
local DefaultSprayESP = Color3.new(1, 0, 0.7)
local HighlightsFOLDER = workspace:FindFirstChild("HIGHLIGHTS") or Instance.new("Folder", workspace)
HighlightsFOLDER.Name = "HIGHLIGHTS"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets
local Survivors = Assets.Survivors
local Killers = Assets.Killers
local emotes = Assets.Emotes
local lchr = nil
local lplr = game.Players.LocalPlayer
local IngameFolder = workspace:FindFirstChild("Map"):FindFirstChild("Ingame")
local CharactersTABLE = {}
local CharacterConfig = nil
local CharacterSELECTED = nil
local AnimationTOREPLACEWITH = nil
local AnimationToReplace = nil

local Emotes = {}

_G.KeybindStart = Enum.KeyCode.H
_G.KeybindStop = Enum.KeyCode.X

-- Functions

local function AddToCharactersTable(chr)
	Characters[chr] = {}
end

local function AddToGeneratorsTable(Gen)
	Gens[Gen] = {}
end

local function safecall(func)
	task.spawn(function()
		pcall(func)
	end)
end

local function SetupGeneratorStuff(Map)
	local function CheckIfIsAGenerator(Generator)
		if Generator.Name == "Generator" then
			AddToGeneratorsTable(Generator)
		end
	end

	for _, Generator in Map:GetChildren() do
		CheckIfIsAGenerator(Generator)
	end

	Map.ChildAdded:Connect(CheckIfIsAGenerator)
end

local function SetupCharacterStuff(plr)
	local chr = plr.Character
	if chr then
		AddToCharactersTable(chr)
	end

	plr.CharacterAdded:Connect(AddToCharactersTable)
end

local function CheckIfItIsAItem(child)
	if child:IsA("Tool") then
		Items[child] = {}
	end
end

local function CheckIfIsASprayPaint(child)
	local Player = game:GetService("Players"):FindFirstChild(string.split(child.Name, "Spray")[1])
	if Player then
		local ClosestObject = nil
		local ClosestNumber = math.huge

		repeat
			task.wait(0.5)
			for _, Object in pairs(child.Parent:GetChildren()) do
				if Object:IsA("Part") and Object.Name == "GraffitiCL" then
					local Number = (Object.Position - child.PrimaryPart.Position).Magnitude
					if Number < ClosestNumber and Number < 15 then
						ClosestNumber = Number
						ClosestObject = Object
					end
				end
			end
		until ClosestObject

		Sprays[ClosestObject] = {
			Player = Player,
			MODELSpray = child,
		}
	end
end

local function SetupItemStuff(Map)
	for _, object in Map:GetChildren() do
		CheckIfItIsAItem(object)
	end

	Map.ChildAdded:Connect(CheckIfItIsAItem)
end

local function CheckIfIsAMap(child)
	if child.Name == "Map" then
		SetupGeneratorStuff(child)
		SetupItemStuff(child)
	end
end

local function CheckIfItIsAMinion(child)
	local Humanoid = child:FindFirstChild("Humanoid") or nil
	if Humanoid and child:GetAttribute("Team") and child:GetAttribute("Team") == "Killers" then
		Minions[child] = {}
	end
end

local function GetDistance(part, fort)
	return (fort.Position - part.Position).Magnitude
end

local function EmoteUseCopy(mobile)
	local EmoteName = nil
	for _, Emote in emotes:GetChildren() do
		local requireEmote = require(Emote)
		if requireEmote.DisplayName == _G.Emotes then
			EmoteName = Emote.Name
		end
	end

	if _G.SepecialDropdownForE == "CopyGame" then
		local args = {
			[1] = "PlayEmote",
			[2] = "Animations",
			[3] = EmoteName,
		}
		game:GetService("ReplicatedStorage")
			:FindFirstChild("Modules")
			:FindFirstChild("Network")
			:FindFirstChild("RemoteEvent")
			:FireServer(unpack(args))

		if mobile then
			task.spawn(function()
				while true do
					task.wait(0.1)
					if _G.OFF then
						safecall(function()
							local args = {
								[1] = "PlayEmote",
								[2] = "Animations",
								[3] = EmoteName,
							}
							game:GetService("ReplicatedStorage")
								:FindFirstChild("Modules")
								:FindFirstChild("Network")
								:FindFirstChild("RemoteEvent")
								:FireServer(unpack(args))
						end)
						safecall(function()
							local args = {
								"PlayEmote",
								{
									buffer.fromstring('"Animations"'),
									buffer.fromstring('"' .. EmoteName .. '"'),
								},
							}
							game:GetService("ReplicatedStorage")
								:WaitForChild("Modules")
								:WaitForChild("Network")
								:WaitForChild("RemoteEvent")
								:FireServer(unpack(args))
						end)
						break
					end
				end
			end)
		else
			local Endput
			Endput = game:GetService("UserInputService").InputBegan:Connect(function(input)
				if input.KeyCode == _G.KeybindStop then
					safecall(function()
						local args = {
							[1] = "StopEmote",
							[2] = "Animations",
							[3] = EmoteName,
						}
						game:GetService("ReplicatedStorage")
							:FindFirstChild("Modules")
							:FindFirstChild("Network")
							:FindFirstChild("RemoteEvent")
							:FireServer(unpack(args))
					end)
					safecall(function()
						local args = {
							"StopEmote",
							{
								buffer.fromstring('"Animations"'),
								buffer.fromstring('"' .. EmoteName .. '"'),
							},
						}
						game:GetService("ReplicatedStorage")
							:WaitForChild("Modules")
							:WaitForChild("Network")
							:WaitForChild("RemoteEvent")
							:FireServer(unpack(args))
					end)

					Endput:Disconnect()
				end
			end)
		end
	end
end

local function SetupUpdateCharacter()
	if lplr.Character then
		lchr = lplr.Character
	end

	lplr.CharacterAdded:Connect(function(chrA)
		lchr = chrA
	end)
	lplr.CharacterRemoving:Connect(function()
		lchr = nil
	end)
end

local function GetMAX(Table)
	local MAX = 0
	for _, _ in pairs(Table) do
		MAX += 1
	end
	if MAX == 0 then
		MAX += 1
	end
	return MAX
end

SetupUpdateCharacter()

local function EmoteUseNormal(mobile)
	-- // ENGINE MADE BY CRIMSON :D

	-- // Gets The Humanoid

	local Hum = lchr:FindFirstChild("Humanoid") or nil

	-- // Returns If No Humanoid Is Detected
	if not Hum then
		return
	end

	-- // Gets The Emote's Names

	local EmoteName = nil
	for _, Emote in emotes:GetChildren() do
		local requireEmote = require(Emote)
		if requireEmote.DisplayName == _G.Emotes then
			EmoteName = Emote.Name
		elseif
			requireEmote.Exclusive
			and string.split(tostring(_G.Emotes), "[!] ")[2]
			and requireEmote.DisplayName == string.split(tostring(_G.Emotes), "[!] ")[2]
		then
			EmoteName = Emote.Name
		end
	end

	-- // Returns If No Emote has that name (incase no Emote Is selected)

	if not EmoteName then
		return
	end

	-- // Gets Variables For The Speed Multiplier

	local SpeedMultipliers = lchr:FindFirstChild("SpeedMultipliers")
	if not SpeedMultipliers then
		return
	end
	local EmoteHACK = SpeedMultipliers:FindFirstChild("EmoteHACK")

	-- // Detects If There Is Another Instance Running And If So Stops It

	if EmoteHACK then
		if getgenv().StopEmoting then
			getgenv().StopEmoting()
		end
		EmoteHACK:Destroy()
	end

	-- // Gets A Already Created Emote Table

	local ADEmote = Emotes[EmoteName]

	-- // Creates A Speed Multiplier

	EmoteHACK = Instance.new("NumberValue")
	EmoteHACK.Value = 0
	EmoteHACK.Name = "EmoteHACK"
	EmoteHACK.Parent = SpeedMultipliers

	-- // Variables For The Emote

	local Audios = ADEmote.Audios
	local AnimTracks = ADEmote.AnimTracks

	local Audio = nil
	local AnimTrack = nil

	-- // Makes Uhhhh Camera Go To Head instead of Humanoid Root Part

	Camera.CameraSubject = lchr:FindFirstChild("Head")

	-- // Makes A Table For Connections Simple

	local Connections = {}

	-- // Gets The Already Existing Table For The Emote

	local RequiredEmote = ADEmote.RequiredEmote

	-- // Sets The Speed Multiplier Or Not (If not then its 0 automaticily)

	if RequiredEmote.Speed then
		EmoteHACK.Value = RequiredEmote.Speed / (Hum.WalkSpeed or 12)
		if RequiredEmote.Speed > Hum.WalkSpeed then
			EmoteHACK.Value = 1
		end
	end

	-- // Uses The GetMAX Function To Get All The Number Of Animation Tracks

	local RandomNumber = math.random(1, GetMAX(AnimTracks))

	-- // Simple Trick To Get One Single Animation Track And Play It

	for Number, AnimTrackP in pairs(AnimTracks) do
		if RandomNumber == tonumber(Number) then
			AnimTrack = AnimTrackP

			AnimTrack:Play()
		end
	end

	-- // Complicated To Say How This Works

	RandomNumber = ((AnimTracks == Audios) and RandomNumber) or math.random(1, GetMAX(Audios))

	-- // Simple Trick To Get One Single Audio And Play It

	for Number, AudioP in pairs(Audios) do
		if RandomNumber == tonumber(Number) then
			Audio = AudioP

			Audio:Play()
		end
	end

	-- // Creates A Table For Start And End Function (If There Is Any)

	local TableForFunctions = {
		Character = lchr,
		-- // FOR ACTUAL FORSAKEN
		Emote = {
			Animation = AnimTrack.Animation,
			SFX = Audio,
		},
	}

	-- // Uses The Start Function (If There Is Any)

	if Emotes[EmoteName].StartFunction then
		Emotes[EmoteName].StartFunction(TableForFunctions)
	end

	-- // Stop Emoting Function IMPORTANT

	getgenv().StopEmoting = function()
		Camera.CameraSubject = lchr:FindFirstChild("Humanoid")

		AnimTrack:Stop()
		Audio:Stop()

		EmoteHACK:Destroy()

		for _, Connection in Connections do
			Connection:Disconnect()
		end

		if Emotes[EmoteName].EndFunction then
			Emotes[EmoteName].EndFunction(TableForFunctions)
		end

		getgenv().StopEmoting = nil
	end

	-- // Connections

	local JumpConnection = Hum.Jumping:Connect(function()
		if getgenv().StopEmoting then
			getgenv().StopEmoting()
		end
	end)

	local DiedConnection = Hum.Died:Connect(function()
		if getgenv().StopEmoting then
			getgenv().StopEmoting()
		end
	end)

	local StoppedEmoteConnection = AnimTrack.Stopped:Connect(function()
		if getgenv().StopEmoting then
			getgenv().StopEmoting()
		end
	end)

	-- // Adds Connections Into the table

	table.insert(Connections, StoppedEmoteConnection)
	table.insert(Connections, JumpConnection)

	-- // End Of Playing The Emote
end

function PlayEmote(mobile)
	if _G.SepecialDropdownForE == "Original" then
		EmoteUseNormal(mobile)
	else
		EmoteUseCopy(mobile)
	end
end

local function ApplyCustomAnimations(AnimationToReplace, CustomAnimationToInforce)
	local Animator = (lchr:FindFirstChild("Humanoid")) and (lchr.Humanoid:FindFirstChild("Animator"))
	if Animator then
		RemoveAlreadyExistingCUSTOMANIMATIONS()

		if lchr.Parent == workspace.Players.Spectating then
			Library:Notify("Error Use This When U Are In The Game")
			return
		end

		_G.ANIMATIONCONNECTION = Animator.AnimationPlayed:Connect(function(animationTrackTrack)
			local Animation = animationTrack.Animation
			if Animation.AnimationId == AnimationToReplace then
				Animation.AnimationId = CustomAnimationToInforce
				local NewAnimationTrack = Animator:LoadAnimation(Animation)
				NewAnimationTrack:Play()
				if animationTrack.Looped then
					animationTrack.Stopped:Connect(function()
						NewAnimationTrack:Stop()
						Animation.AnimationId = AnimationToReplace
					end)
				end
			end
		end)

		Library:Notify("Successfully Applyed Custom Animations (RESETS AFTER U DIE)")
	end
end

local function UpdateEmotes()
	repeat
		task.wait()
	until lchr and lchr.PrimaryPart

	for _, Emote in emotes:GetChildren() do
		local RequiredEmote = table.clone(require(Emote))

		local StartFunction = RequiredEmote.Created or RequiredEmote.CreatedServer or nil
		local EndFunction = RequiredEmote.Destroyed or RequiredEmote.DestroyedServer or nil

		local AudioProps = RequiredEmote.SFXProperties

		local AnimId = RequiredEmote.AssetID
		local AudioId = RequiredEmote.SFX

		local Audios = {}
		local AnimTracks = {}

		local function AnimTP(AnimationId)
			local Anim = Instance.new("Animation")
			Anim.AnimationId = AnimationId
			local AnimT = lchr:WaitForChild("Humanoid", 5):WaitForChild("Animator", 5):LoadAnimation(Anim)

			return AnimT
		end

		local function CreateAudio(SoundId)
			local Audio = Instance.new("Sound", lchr.PrimaryPart)
			Audio.Name = Emote.Name
			Audio.SoundId = SoundId

			return Audio
		end

		if typeof(AnimId) == "string" then
			local Number = 1

			local AnimT = AnimTP(AnimId)
			AnimTracks[tostring(Number)] = AnimT
		elseif typeof(AnimId) == "table" then
			for Number, Anim in ipairs(AnimId) do
				local AnimT = AnimTP(Anim)
				AnimTracks[tostring(Number)] = AnimT
			end
		end

		if typeof(AudioId) == "string" then
			local Number = 1
			Audios[tostring(Number)] = CreateAudio(AudioId)
		elseif typeof(AudioId) == "table" then
			for Number, Audio in pairs(AudioId) do
				Audios[tostring(Number)] = CreateAudio(Audio)
			end
		end

		if AudioProps then
			for _, Audio in pairs(Audios) do
				for AudioPropName, AudioPropVal in AudioProps do
					if typeof(AudioPropVal) == "number" and AudioPropVal == 0 then
						continue
					end

					Audio[AudioPropName] = AudioPropVal
				end
			end
		end

		Emotes[Emote.Name] = {
			StartFunction = StartFunction,
			EndFunction = EndFunction,

			Audios = Audios,
			AnimTracks = AnimTracks,
			RequiredEmote = RequiredEmote,
		}
	end
end

local function AutoDoGens()
	if _G.AutoDoGens and not _G.AutoDoGensWAIT then
		local function ClostNum(part, part2)
			return (part.Position - part2.CFrame.Position).Magnitude
		end

		local BiggestVal = math.huge
		local BiggestObject = nil

		for Generator, _ in Gens do
			if not Generator:IsDescendantOf(workspace) then
				continue
			end

			local Val = ClostNum(Generator.Positions.Center, game.Players.LocalPlayer.Character.HumanoidRootPart)
			if Val < BiggestVal then
				BiggestVal = Val
				BiggestObject = Generator
			end
		end

		if BiggestObject then
			local Remotes = BiggestObject:FindFirstChild("Remotes")
			if Remotes then
				local RemoteEvent = Remotes:FindFirstChild("RE")
				if RemoteEvent then
					_G.AutoDoGensWAIT = true
					task.delay((_G.AutoDoGensWAITTIME or 1.4), function()
						_G.AutoDoGensWAIT = false

						RemoteEvent:FireServer()
					end)
				end
			end
		end
	end
end

local function EspThing(Highlight, Text, Table)
	if not Highlight then
		Highlight = Instance.new("Highlight", HighlightsFOLDER)
		Highlight.Adornee = nil

		Table.Highlight = Highlight
	end

	if not Text then
		Text = Drawing.new("Text")
		Text.Center = true
		Text.Outline = true
		Text.Visible = false
		Text.Size = 15
		Text.Font = 1

		Table.Text = Text
	end
end

local function RemoveEsp(Text, Highlight, Table)
	if Highlight then
		Highlight.Adornee = nil
		Highlight:Destroy()

		Table.Highlight = nil
	end
	if Text then
		Text.Visible = false
		Text:Remove()

		Table.Text = nil
	end
end

local function esp()
	for chr, v in pairs(Characters) do
		task.spawn(function()
			local Highlight = v.Highlight
			local Text = v.Text

			local Root = chr and chr.PrimaryPart

			if not Root or not chr:IsDescendantOf(workspace) or not _G.Esp then
				RemoveEsp(Text, Highlight, v)
				return
			end

			EspThing(Highlight, Text, v)
			Highlight = v.Highlight
			Text = v.Text

			local function IsParentOf(PathName)
				local Success = false
				if
					game:GetService("Workspace").Players:FindFirstChild(PathName)
					and chr.Parent == game:GetService("Workspace").Players:FindFirstChild(PathName)
				then
					if not _G[PathName .. "Esp"] then
						Highlight.Adornee = nil
						Text.Visible = false
						Text:Remove()

						v.Text = nil

						return Success
					end
					Success = true
				end

				return Success
			end

			local function ChangeColor(Color)
				Highlight.FillColor = Color
				Highlight.OutlineColor = Color

				Text.Color = Color

				Highlight.Adornee = chr
				Text.Visible = true
			end

			local Position, OnScreen = Camera:WorldToScreenPoint(Root.Position)
			if OnScreen then
				Text.Position = Vector2.new(Position.X, Position.Y)
				if IsParentOf("Killers") then
					local SkinName = chr:GetAttribute("SkinNameDisplay")
					if tostring(SkinName) == "" then
						SkinName = "None"
					end

					Text.Text = "Character: "
						.. chr:GetAttribute("ActorDisplayName")
						.. ""
						.. (" | Skin: " .. SkinName or "None")
						.. " | Player: "
						.. chr:GetAttribute("Username")
					ChangeColor(DefaultKillerESP)
				elseif IsParentOf("Survivors") then
					local SkinName = chr:GetAttribute("SkinNameDisplay")
					if tostring(SkinName) == "" then
						SkinName = "None"
					end

					Text.Text = "Character: "
						.. chr:GetAttribute("ActorDisplayName")
						.. ""
						.. (" | Skin: " .. SkinName or "None")
						.. " | Player: "
						.. chr:GetAttribute("Username")
					ChangeColor(DefaultSurvivorESP)
				elseif IsParentOf("Spectating") then
					Text.Name = "Player: " .. chr.Name
					ChangeColor(DefaultSpectatorESP)
				end
			else
				RemoveEsp(Text, Highlight, v)
			end
		end)
	end
	for Minion, v in pairs(Minions) do
		task.spawn(function()
			local Highlight = v.Highlight
			local Text = v.Text

			local Root = Minion and Minion.PrimaryPart

			if not Root or not Minion:IsDescendantOf(workspace) or not _G.Esp or not _G.MinionEsp then
				RemoveEsp(Text, Highlight, v)
				return
			end

			EspThing(Highlight, Text, v)
			Highlight = v.Highlight
			Text = v.Text

			local function ChangeColor(Color)
				Highlight.FillColor = Color
				Highlight.OutlineColor = Color

				Text.Color = Color

				Highlight.Adornee = Minion
				Text.Visible = true
			end

			local Position, OnScreen = Camera:WorldToScreenPoint(Root.Position)
			if OnScreen then
				Text.Visible = true
				Text.Position = Vector2.new(Position.X, Position.Y)
				Text.Text = "Minion"
				Highlight.Adornee = Minion
				ChangeColor(DefaultMininonESP)
			else
				RemoveEsp(Text, Highlight, v)
			end
		end)
	end
	for Generator, v in pairs(Gens) do
		task.spawn(function()
			local Highlight = v.Highlight
			local Text = v.Text

			local Root = Generator and Generator.PrimaryPart
			local Progress = Generator and Generator:FindFirstChild("Progress")

			if
				not Root
				or not Progress
				or not Generator:IsDescendantOf(workspace)
				or not _G.Esp
				or not _G.GeneratorEsp
			then
				RemoveEsp(Text, Highlight, v)
				return
			end

			EspThing(Highlight, Text, v)
			Highlight = v.Highlight
			Text = v.Text

			local function ChangeColor(Color)
				Text.Color = Color
				Highlight.FillColor = Color
				Highlight.OutlineColor = Color
			end

			local Position, OnScreen = Camera:WorldToScreenPoint(Root.Position)
			if OnScreen then
				Text.Visible = true
				Text.Position = Vector2.new(Position.X, Position.Y)
				Highlight.Adornee = Generator

				Text.Text = "Generator Progress: " .. Progress.Value

				if Progress.Value ~= 100 then
					ChangeColor(DefaultGeneratorNONCOMPLETEDESP)
				else
					ChangeColor(DefaultGeneratorCOMPLETEDESP)
				end
			else
				RemoveEsp(Text, Highlight, v)
			end
		end)
	end
	for Item, v in pairs(Items) do
		task.spawn(function()
			local Highlight = v.Highlight
			local Text = v.Text

			local Root = Item and Item:FindFirstChild("ItemRoot")

			if not Root or not Item:IsDescendantOf(workspace) or not _G.Esp or not _G.ItemEsp then
				RemoveEsp(Text, Highlight, v)
				return
			end

			EspThing(Highlight, Text, v)
			Highlight = v.Highlight
			Text = v.Text

			local function ChangeColor(Color)
				Text.Color = Color
				Highlight.FillColor = Color
				Highlight.OutlineColor = Color
			end

			local Position, OnScreen = Camera:WorldToScreenPoint(Root.Position)
			if OnScreen then
				Text.Visible = true
				Text.Position = Vector2.new(Position.X, Position.Y)
				Highlight.Adornee = Root

				Text.Text = "Item: "
					.. Item.Name
					.. " | Distance: "
					.. tostring(math.floor((Root.Position - lplr.Character.PrimaryPart.Position).Magnitude))
				ChangeColor(DefaultItemESP)
			else
				RemoveEsp(Text, Highlight, v)
			end
		end)
	end
	for Spray, v in pairs(Sprays) do
		task.spawn(function()
			local Highlight = v.Highlight
			local Text = v.Text
			local MODELSpray = v.MODELSpray

			local Root = Spray and Spray:FindFirstChild("SprayRangeIndicator")
			local Progress = MODELSpray:GetAttribute("Progression")
			local Completed = MODELSpray:GetAttribute("Completed")

			if not Root or not Spray:IsDescendantOf(workspace) or not _G.Esp or not _G.SprayEsp then
				RemoveEsp(Text, Highlight, v)
				if Root then
					Spray.Transparency = 1
				end
				return
			end

			EspThing(Highlight, Text, v)
			Highlight = v.Highlight
			Text = v.Text

			local function ChangeColor(Color)
				Spray.Color = Color

				Text.Color = Color
				Highlight.FillColor = Color
				Highlight.OutlineColor = Color
			end

			local Position, OnScreen = Camera:WorldToScreenPoint(Spray.Position)
			if OnScreen then
				Text.Visible = true
				Text.Position = Vector2.new(Position.X, Position.Y)
				Highlight.Adornee = Spray

				Text.Text = "Spray | Player: "
					.. v.Player.Name
					.. " | "
					.. (
						Progress < 100 and "Progress: " .. math.floor(Progress)
						or ("Completed: True" and Completed)
						or "FATAL ERROR INCODE"
					)
				Spray.Transparency = 0
				ChangeColor(DefaultSprayESP)
			else
				Spray.Transparency = 1
				RemoveEsp(Text, Highlight, v)
			end
		end)
	end
end

-- Script (Looads)

safecall(UpdateEmotes)

lplr.CharacterAdded:Connect(UpdateEmotes)

game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == _G.KeybindStart then
		PlayEmote()
	elseif input.KeyCode == _G.KeybindStop then
		if getgenv().StopEmoting then
			getgenv().StopEmoting()
		end
	end
end)

game:GetService("Players").PlayerAdded:Connect(SetupCharacterStuff)

IngameFolder.ChildAdded:Connect(function(child)
	CheckIfIsAMap(child)
	CheckIfIsASprayPaint(child)
	CheckIfItIsAMinion(child)
end)

for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
	if plr == lplr then
		continue
	end

	SetupCharacterStuff(plr)
end

for _, child in IngameFolder:GetChildren() do
	CheckIfIsAMap(child)
	CheckIfIsASprayPaint(child)
	CheckIfItIsAMinion(child)
end

for _, Emote in emotes:GetChildren() do
	local requireEmote = require(Emote)
	if requireEmote.Exclusive then
		table.insert(Exclusive_Emotes, "[!] " .. requireEmote.DisplayName)
	else
		table.insert(Gettable_Emotes, requireEmote.DisplayName)
	end
end

-- Load

local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()
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
		ConfigFolder = "Forsaken", -- The Name Of The Folder Where Luna Will Store Configs For This Script. DO NOT ADD A SLASH
	},
})

local Main = Window:CreateTab({
	Name = "Main",
	ShowTitle = true, -- This will determine whether the big header text in the tab will show
})
local Visual = Window:CreateTab({
	Name = "Visual",
	ShowTitle = true, -- This will determine whether the big header text in the tab will show
})
local Player = Window:CreateTab({
	Name = "Player",
	ShowTitle = true, -- This will determine whether the big header text in the tab will show
})
local Credits = Window:CreateTab({
	Name = "Credits",
	ShowTitle = true, -- This will determine whether the big header text in the tab will show
})

Credits:CreateSection(
	'<font color="rgb(255,0,0)">[enzoe15226 (Crimson)]</font> On Discord For Main Developer <font color="rgb(255,100,0)">im</font> writing this btw!'
)

Credits:CreateButton({
	Name = '<font color="rgb(255,0,0)">[Set Clipboard To Discord Invite]</font>!',
	Callback = function()
		local fgd = loadstring(
			game:HttpGet("https://raw.githubusercontent.com/dizzyhvh/Forest-Fire/refs/heads/main/discordurl.lua")
		)()
		setclipboard(tostring(fgd))
	end,
})

local Sound = Instance.new("Sound")
safecall(function()
	local response = request({
		Url = "https://raw.githubusercontent.com/dizzyhvh/Forest-Fire/refs/heads/main/Don't%20You%20Forget%20(Reprise)%20Sing-Along%20-%20Hazbin%20Hotel%20S2%20%20%20Prime%20Video.mp3",
		Method = "GET",
	})

	writefile("SIGMAMUSIC.mp3", response.Body)

	Sound.SoundId = getcustomasset("SIGMAMUSIC.mp3", false)
end)
Credits:CreateButton({
	Name = '<font color="rgb(0,255,0)">[PLAY SIGMA MUSIC]</font>!',
	Callback = function()
		writefile("SIGMAMUSIC.mp3", response.Body)

		Sound.Parent = game:GetService("SoundService")
		Sound.Looped = true
		Sound.Volume = 3
		Sound:Play()
	end,
	DoubleClick = false,

	Tooltip = "PLAYS SIGMA MUSIC LOOPED",
	DisabledTooltip = "I am disabled!",

	Disabled = false, -- Will disable the button (true / false)
	Visible = true, -- Will make the button invisible (true / false)
	Risky = false, -- Makes the text red (the color can be changed using Library.Scheme.Red) (Default value = false)
})

Credits:CreateButton({
	Name = '<font color="rgb(0,255,0)">[STOP SIGMA MUSIC]</font>!',
	Callback = function()
		Sound:Stop()
	end,
	DoubleClick = false,

	Tooltip = "STOP SIGMA MUSIC LOOPED",
	DisabledTooltip = "I am disabled!",

	Disabled = false, -- Will disable the button (true / false)
	Visible = true, -- Will make the button invisible (true / false)
	Risky = false, -- Makes the text red (the color can be changed using Library.Scheme.Red) (Default value = false)
})
--- GroupBoxes

Main:CreateSection("Other")
Visual:CreateSection("Esp")
Player:CreateSection("Sprint Speed")

-- Script Stuff

Main:CreateToggle({
	Name = "Auto Complete Generator",
	Default = false, -- Default value (true / false)
	Visible = true,
	Tooltip = "Auto Completes Closses Generator", -- Information shown when you hover over the toggle

	Callback = function(Value)
		_G.AutoDoGens = Value
	end,
}, "GenAuto")

Visual:CreateToggle({
	Name = "Killer Esp",
	Default = false, -- Default value (true / false)
	Visible = true,
	Tooltip = "Self Explanastory", -- Information shown when you hover over the toggle

	Callback = function(Value)
		_G.KillersEsp = Value
	end,
}, "KillerEsp")

Visual:CreateColorPicker({
	Color = DefaultKillerESP,
	Title = "Esp Color",

	Callback = function(Value)
		DefaultKillerESP = Value
	end,
}, "KillerColorESP")

Visual:CreateDivider()
Visual:CreateToggle({
	Name = "Survivor Esp",
	Default = false, -- Default value (true / false)
	Visible = true,
	Tooltip = "Self Explanastory", -- Information shown when you hover over the toggle

	Callback = function(Value)
		_G.SurvivorsEsp = Value
	end,
}, "SurvivorESP")
Visual:CreateColorPicker({
	Color = DefaultSurvivorESP,
	Title = "Esp Color",

	Callback = function(Value)
		DefaultSurvivorESP = Value
	end,
}, "SurvivorColorESP")
Visual:CreateDivider()
Visual:CreateToggle({
	Name = "Spectator Esp",
	Default = false, -- Default value (true / false)
	Visible = true,
	Tooltip = "Self Explanastory", -- Information shown when you hover over the toggle

	Callback = function(Value)
		_G.SpectatingEsp = Value
	end,
}, "SpectatorESP")
Visual:CreateColorPicker({
	Color = DefaultSpectatorESP,
	Name = "Esp Color",

	Callback = function(Value)
		DefaultSpectatorESP = Value
	end,
}, "SpectatorColorESP")
Visual:CreateDivider()
Visual:CreateToggle({
	Name = "Spray Esp",
	Default = false, -- Default value (true / false)
	Visible = true,
	Tooltip = "Self Explanastory", -- Information shown when you hover over the toggle

	Callback = function(Value)
		_G.SprayEsp = Value
	end,
}, "SprayESP")
Visual:CreateColorPicker({
	Color = DefaultSprayESP,
	Name = "Esp Color",

	Callback = function(Value)
		DefaultSprayESP = Value
	end,
}, "SprayColorESP")
Visual:CreateDivider()
Visual:CreateToggle({
	Name = "Item Esp",
	Default = false, -- Default value (true / false)
	Visible = true,
	Tooltip = "Self Explanastory", -- Information shown when you hover over the toggle

	Callback = function(Value)
		_G.ItemEsp = Value
	end,
}, "ItemESP")
Visual:CreateColorPicker({
	Color = DefaultItemESP,
	Name = "Color",

	Callback = function(Value)
		DefaultItemESP = Value
	end,
}, "ItemColorESP")
Visual:CreateDivider()
Visual:CreateToggle({
	Name = "Minion Esp",
	Default = false, -- Default value (true / false)
	Visible = true,
	Tooltip = "Self Explanastory", -- Information shown when you hover over the toggle

	Callback = function(Value)
		_G.MinionEsp = Value
	end,
}, "MinionESP")
Visual:CreateColorPicker({
	Color = DefaultMininonESP,
	Name = "Color",

	Callback = function(Value)
		DefaultMininonESP = Value
	end,
}, "MinionColorESP")
Visual:CreateDivider()
Visual:CreateToggle({
	Name = "Generator Esp",
	Default = false, -- Default value (true / false)
	Visible = true,
	Tooltip = "Self Explanastory", -- Information shown when you hover over the toggle

	Callback = function(Value)
		_G.GeneratorEsp = Value
	end,
}, "GeneratorESP")

Visual:CreateColorPicker({
	Color = DefaultGeneratorNONCOMPLETEDESP,
	Name = "Non Completed Generator Color",

	Callback = function(Value)
		DefaultGeneratorNONCOMPLETEDESP = Value
	end,
}, "GeneratorESPColorNONCOMPLETED")
Visual:CreateColorPicker({
	Color = DefaultGeneratorCOMPLETEDESP,
	Name = "Completed Generator Color",

	Callback = function(Value)
		DefaultGeneratorCOMPLETEDESP = Value
	end,
}, "SpectatorColorESPColorCOMPLETED")
Visual:CreateDivider()

Visual:CreateToggle({
	Name = "Esp",
	Default = false, -- Default value (true / false)
	Visible = true,
	Tooltip = "This is a tooltip", -- Information shown when you hover over the toggle

	Callback = function(Value)
		_G.Esp = Value
	end,
}, "EspToggle")

Main:CreateSlider({
	Name = "Solving Time (Generator Puzzle)",
	Range = { 1.4, 5 },
	Increment = 0.1,
	CurrentValue = 2.3,

	Callback = function(Value)
		_G.AutoDoGensWAITTIME = Value
	end,
}, "WAITTIME")

Main:CreateSection(
	'Emotes \n <font color="rgb(255,0,0)">[Original]</font> This Is For Original Game Only FE Animations \n <font color="rgb(0,255,0)">[Force]</font> This Is For a Copy Everything Is FE'
)

Main:CreateDropdown({
	Options = Gettable_Emotes,
	CurrentOption = {Gettable_Emotes[1]},
	Multi = false, -- true / false, allows multiple choices to be selected
	Searchable = true, -- true / false, makes the dropdown searchable (great for a long list of values)

	Name = "Emotes Free",
	Visible = true,
	Tooltip = "Select A Emote", -- Information shown when you hover over the dropdown

	Callback = function(Value)
		_G.Emotes = Value
	end,
}, "EmotesFree")

Main:CreateDropdown({
	Options = Exclusive_Emotes,
	CurrentOption = {Exclusive_Emotes[1]},
	Default = 0, -- number index of the value / string
	Multi = false, -- true / false, allows multiple choices to be selected
	Searchable = true, -- true / false, makes the dropdown searchable (great for a long list of values)

	Name = "Emotes Exclusive",
	Visible = true,
	Tooltip = "Select A Emote", -- Information shown when you hover over the dropdown

	Callback = function(Value)
		_G.Emotes = Value
	end,
}, "EmotesExclusive")

_G.SepecialDropdownForE = "Original"

Main:CreateDropdown({
	Options = { "Force", "Original" },
	CurrentOption = { "Original" }, -- number index of the value / string
	Multi = false, -- true / false, allows multiple choices to be selected

	Name = "Select A Mode",
	Visible = true,
	Tooltip = "Select A Mode", -- Information shown when you hover over the dropdown

	Callback = function(Value)
		_G.SepecialDropdownForE = Value
	end,
}, "ModeEMOTE")

Main:CreateBind({
	Name = "Play Emote",
	Description = nil,
	CurrentBind = "H", -- Check Roblox Studio Docs For KeyCode Names
	HoldToInteract = true, -- When true, Instead of toggling, You hold to achieve the active state of the Bind
	Callback = function(BindState)
		-- The function that takes place when the keybind is pressed
		-- The variable (BindState) is a boolean for whether the Bind is being held or not (HoldToInteract needs to be true) OR it is whether the Bind is active
	end,

	OnChangedCallback = function(Bind)
		_G.KeybindStart = Bind
	end,
}, "EmoteKeybindPLAY") -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps

Main:CreateBind({
	Name = "Stop Emote",
	Description = nil,
	CurrentBind = "X", -- Check Roblox Studio Docs For KeyCode Names
	HoldToInteract = true, -- When true, Instead of toggling, You hold to achieve the active state of the Bind
	Callback = function(BindState)
		-- The function that takes place when the keybind is pressed
		-- The variable (BindState) is a boolean for whether the Bind is being held or not (HoldToInteract needs to be true) OR it is whether the Bind is active
	end,

	OnChangedCallback = function(Bind)
		_G.KeybindStop = Bind
	end,
}, "EmoteKeybindEND") -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps

local MyButton = Main:CreateButton({
	Name = "Play Emote",
	Callback = function()
		_G.OFF = false
		PlayEmote(true)
	end,
	DoubleClick = false,
	Visible = true,
	Tooltip = "Plays The Emote Selected",
})

local MyButton = Main:CreateButton({
	Name = "Stop Emote",
	Callback = function()
		_G.OFF = true
		if getgenv().StopEmoting then
			getgenv().StopEmoting()
		end
	end,
	DoubleClick = false,
	Visible = true,
	Tooltip = "Stops The Emote Already Playing",
})

local requirespeed = require(game:GetService("ReplicatedStorage").Systems.Character.Game.Sprinting) or {}

Player:CreateButton({
	Name = "Inf Stamina",
	Callback = function()
		SPRINTINGTable.MaxStamina = math.huge
	end,
	DoubleClick = false,
	Visible = true,
	Tooltip = "gives you inf stamina",
})

Player:CreateButton({
	Name = "No Stamina Loss",
	Callback = function()
		SPRINTINGTable.StaminaLoss = 0
	end,
	DoubleClick = false,
	Visible = true,
	Tooltip = "no stamina lost",
})

Player:CreateButton({
	Name = "Revert Stamina Loss",
	Callback = function()
		SPRINTINGTable.StaminaLoss = requirespeed.DefaultConfig.StaminaLoss
	end,
	DoubleClick = false,
	Visible = true,
	Tooltip = "reverts stamina loss",
})

Player:CreateButton({
	Name = "Revert Stamina",
	Callback = function()
		SPRINTINGTable.MaxStamina = requirespeed.DefaultConfig.MaxStamina
	end,
	DoubleClick = false,
	Visible = true,
	Tooltip = "reverts stamina",
})

Player:CreateButton({
	Name = "Revert Stamina Gain",
	Callback = function()
		SPRINTINGTable.StaminaGain = requirespeed.DefaultConfig.StaminaGain
	end,
	DoubleClick = false,
	Visible = true,
	Tooltip = "reverts stamina gain",
})

Player:CreateButton({
	Name = "Revert Sprint Speed",
	Callback = function()
		SPRINTINGTable.SprintSpeed = requirespeed.DefaultConfig.SprintSpeed
	end,
	DoubleClick = false,
	Visible = true,
	Tooltip = "reverts sprint speed",
})

Player:CreateSlider({
	Name = "Stamina",
	CurrentValue = requirespeed.DefaultConfig.MaxStamina,
	Range = { 0, 1000 },
	Increment = 1,
	Compact = false,

	Callback = function(Value)
		SPRINTINGTable.MaxStamina = Value
	end,
}, "MaxStaminaSlider")

Player:CreateSlider({
	Name = "Stamina Gain",
	CurrentValue = requirespeed.DefaultConfig.StaminaGain,
	Range = { 0, 1000 },
	Increment = 1,
	Compact = false,

	Callback = function(Value)
		SPRINTINGTable.StaminaGain = Value
	end,
}, "StaminaGainSlider")

Player:CreateSlider({
	Name = "Stamina Loss",
	CurrentValue = requirespeed.DefaultConfig.StaminaLoss,
	Range = { 0, 1000 },
	Increment = 1,
	Compact = false,

	Callback = function(Value)
		SPRINTINGTable.StaminaLoss = Value
	end,
}, "StaminaLossSlider")
Player:CreateSlider({
	Name = "Sprint Speed",
	CurrentValue = requirespeed.DefaultConfig.SprintSpeed,
	Range = { 0, 1000 },
	Increment = 1,
	Compact = false,

	Callback = function(Value)
		SPRINTINGTable.SprintSpeed = Value
	end,
}, "SprintSpeedSlider")

local RenderStepped = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
	esp()
	AutoDoGens()
end)

UISettings:BuildConfigSection() -- Tab Should be the name of the tab you are adding this section to.

Luna:LoadAutoloadConfig()

