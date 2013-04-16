//________________________________
//
//   	NS2 Arcade-Mod   
//	Made by JimWest 2013
//
//________________________________

// Game.lua
// Base class for all Arcade games

class 'Game'

function Game:OnCreate(canvas)
    self.canvas = canvas
    self.pressedKey = {}
end

function Game:OnDestroy()
end

function Game:OnUpdate(deltaTime)
    // games schould checked key before calling this
    self.pressedKey = {}
end

function Game:GetAllowedKeys()
    return {}
end

function Game:SendKeyEvent(key, down)
    //if down then
        // only save allowed keys
        if down and table.contains(self:GetAllowedKeys(), key) then
            table.insert(self.pressedKey, key)
        end
    //end
end