// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
//    Created by:   Andreas Urwalek (andi@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

// modified for
//________________________________
//
//   	NS2 Arcade-Mod   
//	Made by JimWest 2013
//
//________________________________

Script.Load("lua/Class.lua")
Script.Load("lua/ThreeDeeMenuMixin.lua")

local onInitialized = Player.OnInitialized
function OverridePlayerOnInitialized(self)

    onInitialized(self)

    if Client and self:GetIsLocalPlayer() then
        InitMixin(self, ThreeDeeMenuMixin)
    end

end

Class_ReplaceMethod("Player", "OnInitialized", OverridePlayerOnInitialized)


function PlayerUI_GetBuyMenuDisplaying()

    local player = Client.GetLocalPlayer()    
    if player and HasMixin(player, "ThreeDeeMenu") then
        return player:GetIsLookingAtMenu()
    end

    return false
    
end