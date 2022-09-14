local Players = game:GetService("Players")
local player = Players.LocalPlayer
local randomise = Random.new()
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local PlayerGui = player:WaitForChild("PlayerGui")
local ScreenGui = PlayerGui:WaitForChild("ScreenGui1")
local ScreenGui2 = PlayerGui:WaitForChild("ScreenGui2")
ScreenGui2.Enabled = false
local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")


local frame = ScreenGui:WaitForChild("Frame1")
local frame2 = ScreenGui2:WaitForChild("Frame2")
local randomButton = ScreenGui2:WaitForChild("randomButton")
local sendButton2 = ScreenGui2:WaitForChild("sendButton")



local data = {"planet", "iterations"}
local planetData = {}
local finalData = {}

local dictInfo = {"x_position", "y_position", "z_position",	"mass", "v_x", "v_y", "v_z"	}



local iterationsBox = frame:WaitForChild("TextBox")
local sendButton1 = frame:WaitForChild("sendButton")
local planetButtons = 
{	frame.button2,
 	frame.button3,
 	frame.button4,
 	frame.button5,
 	frame.button6,
	frame.button7,
 	frame.button8,
	frame.button9,
 	frame.button10 }

local folderData = {
	frame2.folder1,
	frame2.folder2,
	frame2.folder3,
	frame2.folder4,
	frame2.folder5,
	frame2.folder6,
	frame2.folder7,
	frame2.folder8,
	frame2.folder9,
	frame2.folder10
}


local function orderData(random)
	--probably the most inefficient code I have ever written, however it works and since it only needs to run once per game I am going to let it be
	local leftOver = {}
	for i,v in pairs(folderData) do
		if i > tonumber(data[1]) then
			table.insert(leftOver, i)
		end
	end

	table.sort(
    leftOver,
    function(a, b)
        return a > b
    end)
	
	for i,v in pairs(leftOver) do
		table.remove(folderData, v)
	end
	

	if random == nil then

		for i,v in ipairs(folderData) do	
			local x_pos = v.xBox.Text
			local y_pos = v.yBox.Text
			local z_pos = v.zBox.Text
			local mass = v.massBox.Text
			local vx = v.vxBox.Text
			local vy = v.vyBox.Text
			local vz = v.vzBox.Text
			
			table.insert(planetData, x_pos)
			table.insert(planetData, y_pos)
			table.insert(planetData, z_pos)
			table.insert(planetData, -tonumber(mass))
			table.insert(planetData, vx)
			table.insert(planetData, vy)
			table.insert(planetData, vz)
		end
		
		for i,v in ipairs(planetData) do
			if typeof(tonumber(v)) == "number" then
				table.insert(finalData, v)
				
			else
				
				table.clear(finalData)
				table.clear(planetData)
				sendButton2.Text = "Error: You did not fill in all the data with numbers (so it is blank or you filled in letters"
				task.wait(4)
				sendButton2.Text = "Send"
				return
			end
		end
	elseif random == true then
		for i = 1, tonumber(data[1]), 1 do
			local x_data = randomise:NextInteger(10, 100)
			local y_data = randomise:NextInteger(10, 100)
			local z_data = randomise:NextInteger(10, 100)
			local mass_data = -randomise:NextInteger(100000000000, 10000000000000000)
			local vx_data = randomise:NextInteger(0, 1)
			local vy_data = randomise:NextInteger(0, 1)
			local vz_data = randomise:NextInteger(0, 1)
			
			table.insert(finalData, x_data)
			table.insert(finalData, y_data)
			table.insert(finalData, z_data)
			table.insert(finalData, mass_data)
			table.insert(finalData, vx_data)
			table.insert(finalData, vy_data)
			table.insert(finalData, vz_data)
		end

	end	
	print(data, finalData)
	ScreenGui2.Enabled = false
	RemoteEvent:FireServer(data, finalData)
end

local function randomOrderData()
	orderData(true)
end


local function setUpMenu2(amountOfPlanets)
	ScreenGui.Enabled = false
	ScreenGui2.Enabled = true

	for i,v in ipairs(frame2:GetChildren()) do
		for z = 1, amountOfPlanets, 1 do
			if v.Name == "folder" .. tostring(z) then
				for j,k in pairs(v:GetChildren()) do	
					k.Visible = true

					if k:IsA("TextBox") then
						k.TextEditable = true
					end
			
				end
			end
		end
	end
		
end
	
for i,v in ipairs(planetButtons) do 
	v.MouseButton1Click:Connect(function()
		local values = v.Name:split("n")
		data[1] = tonumber(values[2])
	end)
end

iterationsBox.InputEnded:Connect(function()
	if typeof(tonumber(iterationsBox.Text)) == "number" then
		data[2] = iterationsBox.Text
	end
end)

sendButton1.MouseButton1Click:Connect(function()
	task.wait(2)
	if typeof(tonumber(data[1])) == "number" and typeof(tonumber(data[2])) == "number" then
		setUpMenu2(data[1])
	else
		local textNow = iterationsBox.Text
		iterationsBox.Text = "Error: You did not fill both datafields, or you added text instead of a number in the iterations textbox"
		task.wait(3)
		iterationsBox.Text = textNow
	end
end)

randomButton.MouseButton1Click:Connect(randomOrderData)
sendButton2.MouseButton1Click:Connect(orderData)

