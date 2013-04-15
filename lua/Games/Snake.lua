//________________________________
//
//   	NS2 Arcade-Mod   
//	Made by JimWest 2013
//
//________________________________

// Snake.lua


class 'Snake' (Game)

local startSpeed = 1
local kMovement = enum( {'Up', 'Down', 'Left', 'Right'} )
local kMovementVector = {
                            Vector(0, 1, 0), // up
                            Vector(0, -1, 0), // down
                            Vector(-1, 0, 0), // left
                            Vector(1, 0, 0), // right
                        }

function Snake:OnCreate(canvas)
    Game.OnCreatze(self, canvas)
    self.score = 0
    self.speed = startSpeed
    // elements of snake in a table
    self.snake = {}
    self.movement = kMovement.Right
	
	// add 2 snake elements
	self:AddSnakeElement(2)
	
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
    
    if key == Move.W then
        self.movement = kMovement.Up
    elseif key == Move.S then
        self.movement = kMovement.Down
    elseif key == Move.A then
        self.movement = kMovement.Left
    elseif key == Move.D then
        self.movement = kMovement.Right
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
            snakeElement:SetPosition(snakeElement:GetPosition() + moveVector)
			local checkPosition = snakeElement:GetPosition()
			
			if checkPosition == self.apple:GetPosition() then
				self:HitApple(tempPosition)
				// we added an element to the old position, so stop the loop here
				break
			else
				for i, snakeElementCollision in ipairs(self.snake) do
					if i > 1 then
						if checkPosition ==  snakeElementCollision:GetPosition() the
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
	
	for i = 1 to amount do
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
	self.score = self.score + 1
	GetGUIManager:Destroy(self.apple)
	// check speed up
	self:AddSnakeElement(1, oldPosition)
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
	self.lostScreen:SetPosition(position or Vector(0, 0, 0)
	self.canvas:AddChild(self.lostScreen)
end

