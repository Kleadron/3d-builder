
-- Made by Xelostar: https://www.youtube.com/channel/UCDE2STpSWJrIUyKtiYGeWxw

local path = "/"..shell.dir() -- path to this program

os.loadAPI(path.."/ThreeD") -- loading the APIs
os.loadAPI(path.."/bufferAPI")
os.loadAPI(path.."/blittle")

local objects = {} -- all objects in the game
local selectedObject = nil
local selectionBox = {model = "boxselect", x = 0, y = -5, z = 0, solid = false, hidden = true};

objects[#objects+1] = selectionBox

--ThreeDFrame:loadObject({model = "flip", x = 0, y = -5, z = 0, width = 1, height = 1, color = colors.blue})
-- ascending descending
local selectionSquareXa = {model = "flip", x = 0, y = -5, z = 0, width = 0.75, height = 0.75, color = colors.red, hidden = true, solid = true};
local selectionSquareXd = {model = "flip", x = 0, y = -5, z = 0, width = 0.75, height = 0.75, color = colors.red, hidden = true, solid = true};
local selectionSquareYa = {model = "flip", x = 0, y = -5, z = 0, width = 0.75, height = 0.75, color = colors.green, hidden = true, solid = true};
local selectionSquareYd = {model = "flip", x = 0, y = -5, z = 0, width = 0.75, height = 0.75, color = colors.green, hidden = true, solid = true};
local selectionSquareZa = {model = "flip", x = 0, y = -5, z = 0, width = 0.75, height = 0.75, color = colors.blue, hidden = true, solid = true};
local selectionSquareZd = {model = "flip", x = 0, y = -5, z = 0, width = 0.75, height = 0.75, color = colors.blue, hidden = true, solid = true};

objects[#objects+1] = selectionSquareXa
objects[#objects+1] = selectionSquareXd
objects[#objects+1] = selectionSquareYa
objects[#objects+1] = selectionSquareYd
objects[#objects+1] = selectionSquareZa
objects[#objects+1] = selectionSquareZd

local size = 3
for x = 1, size do
	for z = 1, size do
		for y = 1, size do
			objects[#objects+1] = {model = "box2", x = x, y = y, z = z, solid = true}
		end
	end
end

local playerX = -3 -- player position
local playerY = 0
local playerZ = 1

local playerSpeed = 3 -- player movement speed
local playerTurnSpeed = 180 -- player turn speed

local keysDown = {} -- keysDown[key] is true if the key is down (for smooth input)
local blockThickness = 0.9 -- the size of the hitbox for the solid blocks from the middle of the object

local FoV = 90 -- field of view

local playerDirectionHor = 0 -- camera direction
local playerDirectionVer = 0

local screenWidth, screenHeight = term.getSize() -- size of the screen

screenWidth = screenWidth - 16

local backgroundColor1 = colors.gray -- ground color
local backgroundColor2 = colors.gray -- sky color

local ThreeDFrame = ThreeD.newFrame(1, 1, screenWidth, screenHeight, FoV, playerX, playerY, playerZ, playerDirectionVer, playerDirectionHor, path.."/models") -- making a new frame where the camera is 0.5 blocks above the player
local blittleOn = true -- blittle is turned on by default
ThreeDFrame:useBLittle(blittleOn) -- set the frame to use blittle

local totalTime = 0 -- time in seconds elapsed since the start of the program

local sidebarItem = 1

local function drawSidebarItem(text)
	term.setCursorPos(screenWidth + 1, sidebarItem)
	local length = string.len(text)
	for i = 1, 16 do
		if length < i then
			text = text .. " "
		end
	end
	term.write(text)
	sidebarItem = sidebarItem + 1
end

local function drawSidebar()
	sidebarItem = 1 -- reset
	drawSidebarItem("Tunnel Viewer")
	drawSidebarItem("(c) Kleadron")
	drawSidebarItem("")
	drawSidebarItem(playerX)
	drawSidebarItem(playerY)
	drawSidebarItem(playerZ)
	drawSidebarItem("")
	
	if selectedObject ~= nil then
		drawSidebarItem("Selected Object")
		drawSidebarItem(selectedObject.x)
		drawSidebarItem(selectedObject.y)
		drawSidebarItem(selectedObject.z)
		drawSidebarItem("Place--LMB")
		drawSidebarItem("Remove-RMB")
	else
		drawSidebarItem("No Object")
	end
	
	drawSidebarItem("")
	drawSidebarItem("[Exit]")
	--drawSidebarItem("")
	
	for i = sidebarItem, screenHeight do
		drawSidebarItem("")
	end
end

-- this is kinda dumb but I don't care
local function setClickPoints()
	if selectedObject == nil then
		selectionSquareXa.hidden = true
		selectionSquareXd.hidden = true
		
		selectionSquareYa.hidden = true
		selectionSquareYd.hidden = true
		
		selectionSquareZa.hidden = true
		selectionSquareZd.hidden = true
	else
		selectionSquareXa.hidden = false
		selectionSquareXd.hidden = false
		
		selectionSquareYa.hidden = false
		selectionSquareYd.hidden = false
		
		selectionSquareZa.hidden = false
		selectionSquareZd.hidden = false
	
		-- X
		selectionSquareXa.x = selectedObject.x + 1
		selectionSquareXa.y = selectedObject.y
		selectionSquareXa.z = selectedObject.z
		
		selectionSquareXd.x = selectedObject.x - 1
		selectionSquareXd.y = selectedObject.y
		selectionSquareXd.z = selectedObject.z
		
		-- Y
		selectionSquareYa.x = selectedObject.x
		selectionSquareYa.y = selectedObject.y + 1
		selectionSquareYa.z = selectedObject.z
		
		selectionSquareYd.x = selectedObject.x
		selectionSquareYd.y = selectedObject.y - 1
		selectionSquareYd.z = selectedObject.z
		
		-- Z
		selectionSquareZa.x = selectedObject.x
		selectionSquareZa.y = selectedObject.y
		selectionSquareZa.z = selectedObject.z + 1
		
		selectionSquareZd.x = selectedObject.x
		selectionSquareZd.y = selectedObject.y
		selectionSquareZd.z = selectedObject.z - 1
	end
end

term.clear()

local function rendering()
	while true do
		ThreeDFrame:loadGround(backgroundColor1)
		ThreeDFrame:loadSky(backgroundColor2)
		ThreeDFrame:loadObjects(objects)
		--ThreeDFrame:loadObject({model = "flip", x = 0, y = -5, z = 0, width = 1, height = 1, color = colors.blue})
		ThreeDFrame:drawBuffer()

		drawSidebar()
		
		
		
		os.queueEvent("FakeEvent") -- to prevent "too long without yielding" errors without slowing down the program
		os.pullEvent("FakeEvent")
	end
end

local function free(x, y, z) -- for collision detection. Tests to see if there's a hitbox (x, y, z) is in
	for _, object in pairs(objects) do
		if (object.solid == true) then
			if (x >= object.x - blockThickness and x <= object.x + blockThickness) then
				if (y >= object.y - 1 and y <= object.y + 0.5 + 0.2) then -- the height is done differently, since the  player has to have a certain height (different collision from feet and head)
					if (z >= object.z - blockThickness and z <= object.z + blockThickness) then
						return false -- collision detected
					end
				end
			end
		end
	end

	return true -- no collision detected
end

local function inputPlayer(time) -- time is the elapsed time in seconds since the last time this function was executed
	local dx = 0
	local dy = 0
	local dz = 0
	
	local resolvePlayerSpeed = playerSpeed
	local resolvePlayerTurnSpeed = playerTurnSpeed

	if (keysDown[keys.l]) then
		resolvePlayerSpeed = resolvePlayerSpeed * 0.25
	end
	
	if (keysDown[keys.l]) then
		resolvePlayerTurnSpeed = resolvePlayerTurnSpeed * 0.25
	end
	
	if (keysDown[keys.left]) then
		playerDirectionHor = playerDirectionHor - resolvePlayerTurnSpeed * time
		if (playerDirectionHor <= -180) then
			playerDirectionHor = playerDirectionHor + 360
		end
	end
	if (keysDown[keys.right]) then
		playerDirectionHor = playerDirectionHor + resolvePlayerTurnSpeed * time
		if (playerDirectionHor >= 180) then
			playerDirectionHor = playerDirectionHor - 360
		end
	end
	if (keysDown[keys.down]) then
		playerDirectionVer = playerDirectionVer - resolvePlayerTurnSpeed * time
		if (playerDirectionVer < -80) then
			playerDirectionVer = -80
		end
	end
	if (keysDown[keys.up]) then
		playerDirectionVer = playerDirectionVer + resolvePlayerTurnSpeed * time
		if (playerDirectionVer > 80) then
			playerDirectionVer = 80
		end
	end
	if (keysDown[keys.w]) then
		dx = resolvePlayerSpeed * math.cos(math.rad(playerDirectionHor)) + dx
		dz = resolvePlayerSpeed * math.sin(math.rad(playerDirectionHor)) + dz
	end
	if (keysDown[keys.s]) then
		dx = -resolvePlayerSpeed * math.cos(math.rad(playerDirectionHor)) + dx
		dz = -resolvePlayerSpeed * math.sin(math.rad(playerDirectionHor)) + dz
	end
	if (keysDown[keys.a]) then
		dx = resolvePlayerSpeed * math.cos(math.rad(playerDirectionHor - 90)) + dx
		dz = resolvePlayerSpeed * math.sin(math.rad(playerDirectionHor - 90)) + dz
	end
	if (keysDown[keys.d]) then
		dx = resolvePlayerSpeed * math.cos(math.rad(playerDirectionHor + 90)) + dx
		dz = resolvePlayerSpeed * math.sin(math.rad(playerDirectionHor + 90)) + dz
	end
	
	if (keysDown[keys.space]) then
		dy = resolvePlayerSpeed + dy
	end
	if (keysDown[keys.leftShift]) then
		dy = -resolvePlayerSpeed + dy
	end
	
	-- if where the player will move to is free (no collisions) then move there
	--[[
	if (free(playerX + dx * time, playerY, playerZ) == true) then
		playerX = playerX + dx * time -- multiply by time so that dx becomes blocks per second
	end
	if (playerY + dy * time >= 0) then
		if (free(playerX, playerY + dy * time, playerZ) == true) then
			playerY = playerY + dy * time
		end
	end
	if (free(playerX, playerY, playerZ + dz * time) == true) then
		playerZ = playerZ + dz * time
	end
	--]]
	
	playerX = playerX + dx * time -- multiply by time so that dx becomes blocks per second
	playerY = playerY + dy * time
	playerZ = playerZ + dz * time
	
	ThreeDFrame:setCamera(playerX, playerY + 0.5, playerZ, playerDirectionHor, playerDirectionVer) -- set the new camera position according to the player (again the height is 0.5 blocks above the feet)
end

local function keyInput()
	while true do
		local event, key, x, y = os.pullEventRaw()

		if (event == "key") then -- detect key presses
			keysDown[key] = true
			if (key == keys.g) then -- if the button is supposed to be pressed once, we'll deal with the processing of the input here
				if (blittleOn == false) then
					blittleOn = true
					ThreeDFrame:useBLittle(true)
				else
					blittleOn = false
					ThreeDFrame:useBLittle(false)
				end
			end
		elseif (event == "key_up") then -- detect key releases
			keysDown[key] = nil
		elseif (event == "mouse_click") then
			local objectIndex, polyIndex = ThreeDFrame:getObjectIndexTrace(objects, x, y) -- detect on what and object the player clicked
			local squareIndex = ThreeDFrame:getSquareIndexTrace(objects, x, y)
			
			
			if selectedObject == nil then -- Object discovered, select it
				if objectIndex ~= nil then
					selectedObject = objects[objectIndex]
				end
			else -- already have an object selected
				if key == 1 then -- left mouse button, try to place
					if squareIndex ~= -1 then -- clicked a sqaure
						local square = objects[squareIndex] 
						--if square == selectionSquareXa then
							selectedObject = {model = "box2", x = square.x, y = square.y, z = square.z, solid = true}
							objects[#objects+1] = selectedObject
						--end
					else -- clicked on nothing, deselect
						selectedObject = nil
						selectionBox.hidden = true
					end
				end
				if objectIndex == -1 then -- clicked on nothing, deselect
					
				else -- clicked on something? 
					if objects[objectIndex] == selectedObject then	-- interact with the same object
						
						if key == 2 then -- right mouse button, remove
							table.remove(objects, objectIndex) -- remove the object the player clicked on
							selectedObject = nil
						end
					elseif key ~= 1 then -- different object, select that
						selectedObject = objects[objectIndex]
					end
				end
			end
			
			
			-- update state
			if selectedObject == nil then
				selectionBox.hidden = true
			else
				selectionBox.x = selectedObject.x
				selectionBox.y = selectedObject.y
				selectionBox.z = selectedObject.z
				selectionBox.hidden = false
			end
			
			setClickPoints()
		end
	end
end

local function updateGame(time) -- time is the elapsede time in seconds since the last time this function was executed
	totalTime = totalTime + time -- increase the total time that has elapsed
	for objectNr, object in pairs(objects) do
		if (object.model == "pineapple") then -- for all pineapples:
			object.y = math.sin(totalTime*2)/4 -- set their height according to totalTime to make them smoothly bob up and down
			object.rotationY = object.rotationY + 50*time -- increase their rotation according to the time that has elapsed (50 degrees per second of rotation)
		end
	end
end

local function gameUpdate() -- this function uses some trickery to estimate the time elapsed more precise than 1 Minecraft tick (0.05 seconds)
	-- a lot of the time, withing each game tick about three frames are rendered which means that the accuracy is more like 0.02 seconds
	local timeFromLastUpdate = os.clock() -- the time frome last update
	local avgUpdateSpeed = 0 -- this indicates the average update speed in seconds per frame
	local updateCount = 0 -- keep track of the frames drawn between each game tick

	while true do
		local currentTime = os.clock() -- the current time
		if (currentTime <= timeFromLastUpdate) then
			updateGame(avgUpdateSpeed) -- still the same game tick as the last frame, so just update it with the average delay
			inputPlayer(avgUpdateSpeed) -- same for the player input

			updateCount = updateCount + 1 -- increase the update counter
			if (updateCount >= 3) then
				sleep(0)
			end
		else -- if the next game tick is here:
			local timeOff = -avgUpdateSpeed * (updateCount - 1)

			updateGame(currentTime - timeFromLastUpdate + timeOff) -- update the game normally with the difference in time minus the time we estimated wrongly to compensate
			inputPlayer(currentTime - timeFromLastUpdate + timeOff) -- same for the player input

			avgUpdateSpeed = 0.05 / (updateCount + 2) -- calculate the new average delay between each frame

			updateCount = 1 -- set the update counter to 0 to restart counting
			timeFromLastUpdate = currentTime -- update the time since the last update
		end

		coroutine.yield()
	end
end

parallel.waitForAll(keyInput, gameUpdate, rendering) -- handle input, the game mechanics and the rendering simultaniously
