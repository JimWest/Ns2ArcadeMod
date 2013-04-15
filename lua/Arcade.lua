//________________________________
//
//   	NS2 Arcade-Mod   
//	Made by JimWest 2013
//
//________________________________

// Arcade.lua


class 'Arcade' (Entity)

Arcade.kMapName = "arcade"

local networkVars =
{
}


function Arcade:OnCreate()
end


function Arcade:OnInitialized()    
end


function Arcade:OnDestroy()
    // delete game ui 
end

//TODO: useable vor game start
function Arcade:OnUse()
    // create game ui
end


function Arcade:OnUpdate(deltaTime)
    if GetGamerules():GetGameStarted() then
        // delete self + ui
    end
end


Shared.LinkClassToMap("Arcade", Arcade.kMapName, networkVars)