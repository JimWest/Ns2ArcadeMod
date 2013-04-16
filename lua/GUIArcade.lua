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
    self.background:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.background:SetSize(Vector(512, 512,  0))
    self.background:SetPosition(Vector(-GUIScale(512)/ 2, -GUIScale(512)/ 2, 0))
    self.background:SetIsVisible(false)
end


function GUIArcade:Uninitialize()

    // destroy background + game
    if self.background then
        GUI.DestroyItem(self.background)
    end
end

function GUIArcade:SetIsVisible(setIsVisible)
    self.background:SetIsVisible(setIsVisible)
    SetMoveInputBlocked(setIsVisible)
    
    if setIsVisible then   
        if self.game then
            self.game:ResetGame()
        end
    end
    
end

function GUIArcade:GetBackground()
    // games can modify it, load there own logic on it
    return self.background
end

function GUIArcade:Update(deltaTime)
    // update game
    
    if self.background:GetIsVisible() then   
        if self.game then
            self.game:OnUpdate(deltaTime)
        end
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