//________________________________
//
//   	NS2 Arcade-Mod   
//	Made by JimWest 2013
//
//________________________________

ArcadeMixin = CreateMixin( ArcadeMixin )
ArcadeMixin.type = "Arcade"

function ArcadeMixin:__initmixin()

    // only allow on client
    assert(Client)

	self.arcadeGUI = GetGUIManager():CreateGUIScript("GUIArcade")
    self.arcadeGUI:SetIsVisible(false)  
end

function ArcadeMixin:SetArcadeGUIVisible(isVisible)
    if self.arcadeGUI then
        self.arcadeGUI:SetIsVisible(isVisible)
    end
end

function ArcadeMixin:OnKillClient()

    if self.arcadeGUI then
        self.arcadeGUI:SetIsVisible(false)
    end

end

if Client then

    function OnCommandAracde()
        Client.GetLocalPlayer():SetArcadeGUIVisible(true)
    end

    Event.Hook("Console_arcade", OnCommandAracde)
    
end
