local ServerScriptService = game:GetService("ServerScriptService")
local vec3 = require(ServerScriptService.vec3Module)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RemoteEvent = ReplicatedStorage.RemoteEvent
local DataGuiRE = ReplicatedStorage.DataGuiRE

local dt = 1 --the time between each iteration

local colorList = {"Really blue", "Really red", "New Yeller", "Lime green", "Bright violet", "Bright orange", 
"Medium stone grey", "Toothpaste", "Black", "Burnt Sienna"}

Players.PlayerAdded:Connect(function(player) --makes it so the playerswalkspeed is faster
	player.CharacterAdded:Connect(function(character)
		character:FindFirstChildWhichIsA("Humanoid").WalkSpeed = 64
	end)
end)

local function createPlanets(n)
	local tempPlanets = {}

	for i = 1, n, 1 do
		local planet = Instance.new("Part")
		planet.Shape = "Ball"
		planet.Size = Vector3.new(5, 5, 5)
		planet.Anchored = true
		planet.Material = Enum.Material.SmoothPlastic
		planet.BrickColor = BrickColor.new(colorList[i])
		planet.Parent = workspace
		table.insert(tempPlanets, planet)
	end

	return tempPlanets
end

local function movePlanets(planets, pos_x, pos_y, pos_z)
	for i,v in ipairs(planets) do
		print(pos_x, pos_y, pos_z)
		v.Position = Vector3.new(pos_x[i]/1000000, pos_y[i]/1000000, pos_z[i]/1000000)
		print(v, v.Position)
	end
end


local function definePosAndMass(data, planetData)
	print(data)
	local temp_x = {}
	local temp_y = {}
	local temp_z = {}
	local temp_m = {}
	local temp_vx = {}
	local temp_vy = {}
	local temp_vz = {}

	local num
	for i = 0, ((data[1])-1), 1 do
		num = (i * 7) + 1
		table.insert(temp_x, planetData[num])
		table.insert(temp_y, planetData[num+1])
		table.insert(temp_z, planetData[num+2])
		table.insert(temp_m, planetData[num+3])
		table.insert(temp_vx, planetData[num+4])
		table.insert(temp_vy, planetData[num+5])
		table.insert(temp_vz, planetData[num+6])

	end
	return temp_x, temp_y, temp_z, temp_m, temp_vx, temp_vy, temp_vz, data[1], data[2]
end


local function getMainVectors(n, pos_x, pos_y, pos_z, mass)
	local vector_list = {}
	
	for i = 1, n, 1 do
		for j = 1, n, 1 do
			if j == i then
				continue
			end
			--math explained in thesis
			local dx, dy, dz = vec3.getDeltaxyz(pos_x[i], pos_x[j], pos_y[i], pos_y[j], pos_z[i], pos_z[j])
			local dist = vec3.getDistance(dx, dy, dz)
			local Fz = vec3.getGravity(mass[i], mass[j], dist)
			local a = vec3.getAcceleration(mass[i], dx, dy, dz, Fz, dist) --a_x, a_y, a_z
			
			table.insert(vector_list, a)
    	end
    end
	print(vector_list) 
	local mainVectorList = {}
	table.clear(mainVectorList)

	local dividedVectorList = {}
	for i = 0, (n-1), 1 do --Sorts the vectorlist so the data can be easily extracted
		local leftVector = i * (n - 1)
		dividedVectorList[i+1] = {}
		
		for j = 1, (n-1), 1 do
			print(leftVector + j, vector_list[leftVector + j])
			table.insert(dividedVectorList[i+1], vector_list[leftVector + j])
		end
		print(dividedVectorList)
		table.insert(mainVectorList, table.clone(dividedVectorList[i+1]))
		
		table.clear(dividedVectorList)
	end
		
	local finalVectorList = vec3.addVectors(mainVectorList)

	return finalVectorList
	
end

local function getNewPositions(mainVectorList, old_pos_x, old_pos_y, old_pos_z, v_x, v_y, v_z, dt)
	local temp_x = {}
	local temp_y = {}
	local temp_z = {}

	local temp_vx = {}
	local temp_vy = {}
	local temp_vz = {}
	print(mainVectorList)

	for i = 1, #mainVectorList, 1 do
		--m/s^2 * s + m/s = m/s
        local new_v_x = (mainVectorList[i][1] * dt) + v_x[i] 
        local new_v_y = (mainVectorList[i][2] * dt) + v_y[i]
        local new_v_z = (mainVectorList[i][3] * dt) + v_z[i]

		--m/s * s + m = m
        local new_x = (new_v_x * dt) + old_pos_x[i] 
        local new_y = (new_v_y * dt) + old_pos_x[i]
        local new_z = (new_v_z * dt) + old_pos_x[i]
		
		table.insert(temp_x, new_x)
		table.insert(temp_y, new_y)
		table.insert(temp_z, new_z)
		table.insert(temp_vx, new_v_x)
		table.insert(temp_vy, new_v_y)
		table.insert(temp_vz, new_v_z)
	end
	print(temp_x, temp_y, temp_z, old_pos_x, old_pos_y, old_pos_z)
	return temp_x, temp_y, temp_z, temp_vx, temp_vy, temp_vz
end


RemoteEvent.OnServerEvent:Connect(function(player, data, planetData)
	data[1] = tonumber(data[1])
	data[2] = tonumber(data[2])
	local pos_x, pos_y, pos_z, mass, v_x, v_y, v_z, n, amount = definePosAndMass(data, planetData)
	local planets = createPlanets(n)

	DataGuiRE:FireClient(player, pos_x, pos_y, pos_z, mass, v_x, v_y, v_z, n) --updates the ui that displays the info of the planets
	
	local max = 0
	while amount > max do
		task.wait(0.1)
		max += 1
		
		local mainVectorList = getMainVectors(n, pos_x, pos_y, pos_z, mass)
		pos_x, pos_y, pos_z, v_x, v_y, v_z = getNewPositions(mainVectorList, pos_x, pos_y, pos_z, v_x, v_y, v_z, dt)
		movePlanets(planets, pos_x, pos_y, pos_z)
		DataGuiRE:FireClient(player, pos_x, pos_y, pos_z, mass, v_x, v_y, v_z, n) --updates the ui that displays the info of the planets
		
		table.clear(mainVectorList)
	end

	return true
end)
