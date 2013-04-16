//________________________________
//
//   	NS2 Arcade-Mod   
//	Made by JimWest 2013
//
//________________________________

// Snake.lua

Script.Load("lua/Game.lua")

class 'Snake' (Game)

local startSpeed = 10
local kMovement = enum( {'Up', 'Down', 'Left', 'Right'} )
local kMovementVector = {
                            Vector(0, -10, 0), // up
                            Vector(0, 10, 0), // down
                            Vector(-10, 0, 0), // left
                            Vector(10, 0, 0), // right
                        }

function Snake:OnCreate(canvas)
    Game.OnCreate(self, canvas)
    self.score = 0
    self.speed = startSpeed
    // elements of snake in a table
    self.snake = {}
    self.movement = kMovement.Right
	
	// add 2 snake elements
	self:AddSnakeElement(1, Vector(20,0,0))
	self:AddSnakeElement(1, Vector(10,0,0))
	self:AddSnakeElement(1, Vector(0,0,0))
	
end

function Snake:GetAllowedKeys()
    return {InputKey.W,
            InputKey.A,
            InputKey.S,
            InputKey.D
            }
end


function Snake:OnUpdate(deltaTime)
    // main game loop, called every tick from the GUIArcade
    // 1. Generate apple
    // 2. check key
    // 3. move snake and check collision
   
    // 1
    self:CheckApple()
    
    // 2
	// only look at last key
    local key = self.pressedKey[#self.pressedKey]
    if key then
        if key == InputKey.W then
            if self.movement ~= kMovement.Down then
                self.movement = kMovement.Up
            end
        elseif key == InputKey.S then
            if self.movement ~= kMovement.Up then
                self.movement = kMovement.Down
            end
        elseif key == InputKey.A then
            if self.movement ~= kMovement.Right then
                self.movement = kMovement.Left
            end
        elseif key == InputKey.D then
            if self.movement ~= kMovement.Left then
                self.movement = kMovement.Right
            end
        end
    end
    
    // 3 move every element    
    local oldPosition = nil
    local moveVector = kMovementVector[self.movement]
    
    // move first element and then move alle elements to the n+1 old position
    for i, snakeElement in ipairs(self.snake) do
        local tempPosition = snakeElement:GetPosition()
        
        if oldPosition then
            snakeElement:SetPosition(oldPosition)
        else
			// 1st element, check collision or apple
			// check that no element goes out of the window
			local headMove = snakeElement:GetPosition() + (moveVector * deltaTime * startSpeed) 
			local canvasSize = self.canvas:GetSize()
			
			if headMove.x > canvasSize.x then
			    headMove.x = 0 
			elseif headMove.x < 0 then
                headMove.x = canvasSize.x
                
            elseif headMove.y > canvasSize.y then
                headMove.y =  0
            elseif headMove.y < 0 then
                headMove.y =  canvasSize.y
			end
			
            snakeElement:SetPosition(headMove)
			local checkPosition = snakeElement:GetPosition()
			
			if checkPosition == self.apple:GetPosition() then
				self:HitApple(tempPosition)
				// we added an element to the old position, so stop the loop here
				break
			else
				for i, snakeElementCollision in ipairs(self.snake) do
					if i > 1 then
						if checkPosition == snakeElementCollision:GetPosition() then
							self:GameOver()
						end
					end
				end
			end
			
        end
		
		oldPosition = tempPosition
    end
    
    // when done everything here, call the game OnUpdate
    Game.OnUpdate(self, deltaTime)
end


function Snake:AddSnakeElement(amount, position)
	// add element directly after the head
	
	if not amount then
	    amount = 1
    end
	
	for i = 1, amount, 1 do
		local newSnakeElement = GUIManager:CreateTextItem()
        newSnakeElement:SetText("X")
        //self.apple:SetColor(ColorIntToColor(kAlienTeamColor))
        newSnakeElement:SetPosition(position or Vector(0, 0, 0))
		table.insert(self.snake, newSnakeElement)
		self.canvas:AddChild(newSnakeElement)
	end
end

function Snake:CheckApple()
    if not self.apple then
        self.apple = GUIManager:CreateTextItem()
        self.apple:SetText("O")
        self.apple:SetColor(ColorIntToColor(kAlienTeamColor))
        // random position, not at snake
        self.apple:SetPosition(Vector(0, 0,  0))
		self.canvas:AddChild(self.apple)
    end
end

function Snake:HitApple(oldPosition)
	//self.score = self.score + 1
	//GUIManager:DestroyGUIScript(self.apple)
	// check speed up
	//self:AddSnakeElement(1, oldPosition)
end

function Snake:GameOver()
	for i, element in ipairs(self.snake) do
		GUI.DestroyItem(element)
		element = nil
	end
	
	GUI.DestroyItem(self.apple)
	
	self.lostScreen = GUIManager:CreateTextItem()
	self.lostScreen:SetText("LOST")
    //self.apple:SetColor(ColorIntToColor(kAlienTeamColor))
	self.lostScreen:SetPosition(position or Vector(0, 0, 0))
	self.canvas:AddChild(self.lostScreen)
end

