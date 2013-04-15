//________________________________
//
//   	NS2 Arcade-Mod   
//	Made by JimWest 2013
//
//________________________________

// modified from GuiExploreHint


Script.Load("lua/GUIScript.lua")
Script.Load("lua/NS2Utility.lua")

class 'GUIArcade' (GUIScript)

function GUIArcade:Initialize()
    // create background + game
    self.game = Game()
    self.game:OnCreate(self:GetBackground())
end

function GUIArcade:InitializeBackground()
end


function GUIArcade:Uninitialize()

    // destroy background + game
    if self.background then
        GUI.DestroyItem(self.background)
    end
end

function GUIArcade:SetIsVisible(setIsVisible)
    self.background:SetIsVisible(setIsVisible)
end

function GUIArcade:GetBackground()
    // games can modify it, load there own logic on it
    return self.background
end

function GUIArcade:Update(deltaTime)
    // update game
    self.game:Update(deltaTime)
end


function GUIArcade:SendKeyEvent(key, down)

    // check if exitwas pressend, if not, parse key to game
    if "exit" then
        // destroy self
    else
        self.game:SendKeyEvent(key, down)
    end
    
end