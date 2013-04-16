//________________________________
//
//   	NS2 Arcade-Mod   
//	Made by JimWest 2013
//
//________________________________

// modified from GuiExploreHint


Script.Load("lua/GUIScript.lua")
Script.Load("lua/NS2Utility.lua")

Script.Load("lua/Games/Snake.lua")

class 'GUIArcade' (GUIScript)

function GUIArcade:Initialize()
    // create background + game
    self:InitializeBackground()
    
    
    self.game = Snake()
    self.game:OnCreate(self:GetBackground())
end

function GUIArcade:InitializeBackground()
    GUI.SetSize(512, 512)
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetTexture("ui/menu_background.dds")
    self.background:SetSize(Vector(512, 512,  0))
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
    
    if self.background:GetIsVisible() then        
        Client.GetLocalPlayer():BlockMove()
    end
    
    if self.game then
        self.game:OnUpdate(deltaTime)
    end
end


function GUIArcade:SendKeyEvent(key, down)

    // check if exitwas pressend, if not, parse key to game
    //if "exit" then
        // destroy self
    //else
        if self.game then
            self.game:SendKeyEvent(key, down)
        end
    //end
    
end