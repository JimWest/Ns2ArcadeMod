//________________________________
//
//   	NS2 Arcade-Mod   
//	Made by JimWest 2013
//
//________________________________

// Snake.lua

Script.Load("lua/Game.lua")

class 'Snake' (Game)

local kMinMove = 16
local borderOffset = 16

local kUpdateRate = 0.1
local startSpeed = 1
local kMovement = enum( {'Up', 'Down', 'Left', 'Right'} )
local kMovementVector = {
                            Vector(0, -kMinMove , 0), // up
                            Vector(0, kMinMove , 0), // down
                            Vector(-kMinMove , 0, 0), // left
                            Vector(kMinMove , 0, 0), // right
                        }
                        

function Snake:OnCreate(canvas)
    Game.OnCreate(self, canvas)
    self:ResetGame()
    self:CreateTexts()
end

function Snake:ResetGame()

    self.lost = false
    self.score = 0
    self.speed = startSpeed
    
    // elements of snake in a table
    if self.snake then
        for i, element in ipairs(self.snake) do
            GUI.DestroyItem(element)
            element = nil
        end
    end
    self.snake = {}
	
	if self.apple then
	    GUI.DestroyItem(self.apple)
	    self.apple = nil    
    end
    

    self.movement = kMovement.Right
	self.lastUpdate = nil
	
	// add 2 snake elements
	self:AddSnakeElement(Vector(64, 0,0))
	self:AddSnakeElement(Vector(48,0,0))
	self:AddSnakeElement(Vector(32,0,0))
	self:AddSnakeElement(Vector(16,0,0))
	self:AddSnakeElement(Vector(0,0,0))

    if self.lostScreen then
        self.lostScreen:SetIsVisible(false)
    end
	
end

function Snake:GetAllowedKeys()
    return {InputKey.W,
            InputKey.A,
            InputKey.S,
            InputKey.D,
            InputKey.R
            }
end


function Snake:OnUpdate(deltaTime)
    // main game loop, called every tick from the GUIArcade
    
    self:UpdateScores()
    
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
        elseif key == InputKey.R then
            // restart if lost
            if self.lost then
                self:ResetGame()
            end
        
        end
        
    end
    
    // check if its time to move 
    if not self.lost and (not self.lastUpdate or Shared.GetTime() - self.lastUpdate > kUpdateRate) then
    
        self:CheckApple()
    
        // 3 move every element    
        local oldPosition = nil
        local moveVector = kMovementVector[self.movement]
        
        // move first element and then move alle elements to the n+1 old position
        for i, snakeElement in ipairs(self.snake) do
            if snakeElement then
            
                local tempPosition = snakeElement:GetPosition()
                
                if oldPosition then
                    snakeElement:SetPosition(oldPosition)
                else
                    // 1st element, check collision or apple
                    // check that no element goes out of the window
                    local headMove = snakeElement:GetPosition() + (moveVector) 
                    local canvasSize = self.canvas:GetSize()
                    
                    if headMove.x > canvasSize.x -  kMinMove - borderOffset then
                        headMove.x = 0 + borderOffset 
                    elseif headMove.x < 0 + borderOffset then
                        headMove.x = canvasSize.x - kMinMove - borderOffset
                        
                    elseif headMove.y > canvasSize.y -  kMinMove - borderOffset then
                        headMove.y =  0 + borderOffset 
                    elseif headMove.y < 0 + borderOffset then
                        headMove.y =  canvasSize.y - kMinMove  - borderOffset
                    end
                    
                    snakeElement:SetPosition(headMove)
                    local checkPosition = snakeElement:GetPosition()
                    
                    if self.apple and checkPosition == self.apple:GetPosition() then
                        self:HitApple(tempPosition)
                        // we added an element to the old position, so stop the loop here
                        break
                    else                    
                        for i, snakeElementCollision in ipairs(self.snake) do
                            if i > 1 then
                                if checkPosition == snakeElementCollision:GetPosition() then
                                    self:GameOver()
                                    return
                                end
                            end
                        end                        
                    end
                    
                end
                
                oldPosition = tempPosition
                self.moved = true
            end
        end
        
        self.lastUpdate = Shared.GetTime()
        
    end   
    
    // when done everything here, call the game OnUpdate
    Game.OnUpdate(self, deltaTime)
        
end

function Snake:CreateTexts()
	self.scores = GUIManager:CreateTextItem()
	self.scores:SetText("Score: " .. self.score)
	self.scores:SetFontSize(32)
    //self.apple:SetColor(ColorIntToColor(kAlienTeamColor))
	self.scores:SetPosition(position or Vector(8 , 8, 0))
	self.canvas:AddChild(self.scores)
	
	    
    local canvasSize = self.canvas:GetSize()    
	self.lostScreen = GUIManager:CreateTextItem()
	self.lostScreen:SetText("LOST !! \n\n Press R to restart the match")
	self.lostScreen:SetFontSize(128)
    //self.apple:SetColor(ColorIntToColor(kAlienTeamColor))
	self.lostScreen:SetPosition(position or Vector((canvasSize.x / 2) - 10 , canvasSize.y / 2, 0))
	self.lostScreen:SetIsVisible(false)
	self.canvas:AddChild(self.lostScreen)
end

function Snake:UpdateScores()
	self.scores:SetText("Score: " .. self.score)
end

function Snake:AddSnakeElement(position, afterHead)
	// add element directly after the head
    local newSnakeElement = GUIManager:CreateGraphicItem()
    newSnakeElement:SetTexture("ui/snake.png")
    newSnakeElement:SetSize(Vector(kMinMove, kMinMove,  0))
    newSnakeElement:SetPosition(position or Vector(0, 0, 0))
    if afterHead then
        table.insert(self.snake, 2, newSnakeElement)
    else    
        table.insert(self.snake, newSnakeElement)
    end
    self.canvas:AddChild(newSnakeElement)
end

function Snake:CheckApple()
    if not self.apple then
        local canvasSize = self.canvas:GetSize()
        local randX = math.random(0 + borderOffset , (canvasSize.x -  kMinMove - borderOffset ) / kMinMove ) * kMinMove
        local randY = math.random(0 + borderOffset , (canvasSize.y -  kMinMove -  borderOffset ) / kMinMove ) * kMinMove
        
        self.apple = GUIManager:CreateGraphicItem()
        self.apple:SetTexture("ui/apple.png")
        self.apple:SetSize(Vector(kMinMove, kMinMove,  0))
        self.apple:SetPosition(position or Vector(randX, randY, 0))
		self.canvas:AddChild(self.apple)
    end
end

function Snake:HitApple(oldPosition)
	self.score = self.score + 1
	GUI.DestroyItem(self.apple)
	self.apple = nil
	// check speed up
	self:AddSnakeElement(oldPosition, true)
	self.speed = self.speed + 1
end

function Snake:GameOver()
    self:ResetGame()    
    self.lost = true
    self.lostScreen:SetIsVisible(true)
end

