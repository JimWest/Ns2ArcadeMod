// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ThreeDeeUtility.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// Utility and interface functions for 3d menu.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

kThreeDeeMenuType = enum( { 'Armory', 'AdvancedArmory', 'PrototypeLab' } )
// available shows normal color, locked is greyed out, no money appears in red
kThreeDeeItemStatus = enum ({ 'Available', 'Locked', 'NoMoney' })

kThreeDeeMenuWidth = 512
kThreeDeeMenuHeight = 512

// passed as parameter to material
ShotgunTDI = kThreeDeeItemStatus.Available
WelderTDI = kThreeDeeItemStatus.Available
LayMinesTDI = kThreeDeeItemStatus.Available
GrenadeLauncherTDI = kThreeDeeItemStatus.Available
FlamethrowerTDI = kThreeDeeItemStatus.Available

JetpackTDI = kThreeDeeItemStatus.Available
ExosuitTDI = kThreeDeeItemStatus.Available
DualMinigunExosuitTDI = kThreeDeeItemStatus.Available


local internalItemTable = {}
local function InternalUpdateItems()

    internalItemTable[kTechId.Shotgun] = ShotgunTDI
    internalItemTable[kTechId.Welder] = WelderTDI
    internalItemTable[kTechId.LayMines] = LayMinesTDI
    internalItemTable[kTechId.GrenadeLauncher] = GrenadeLauncherTDI
    internalItemTable[kTechId.Flamethrower] = FlamethrowerTDI
    
    internalItemTable[kTechId.Jetpack] = JetpackTDI
    internalItemTable[kTechId.Exosuit] = ExosuitTDI
    internalItemTable[kTechId.DualMinigunExosuit] = DualMinigunExosuitTDI

end

function GetItemStatus(techId)

    InternalUpdateItems()
    return internalItemTable[techId]

end

function UpdateBuyMenuParam(model, techId)

    local itemStatus = kThreeDeeItemStatus.Available
    
    if not MarineBuy_IsResearched(techId) then        
        itemStatus = kThreeDeeItemStatus.Locked    
    elseif PlayerUI_GetPlayerResources() < MarineBuy_GetCosts(techId) then    
        itemStatus = kThreeDeeItemStatus.NoMoney
    end    

    model:SetMaterialParameter(EnumToString(kTechId, techId) .. "TDI", itemStatus)

end

kMenuItems = 
{ 

    { kTechId.Shotgun, kTechId.Welder, kTechId.LayMines, kTechId.GrenadeLauncher, kTechId.Flamethrower },
    { kTechId.Shotgun, kTechId.Welder, kTechId.LayMines, kTechId.GrenadeLauncher, kTechId.Flamethrower },
    { kTechId.Jetpack, kTechId.Exosuit, kTechId.DualMinigunExosuit }

}

kThreeDeeMenuItemsPerRow = 3
kThreeDeeMenuItemSize = Vector(128, 64, 0)

kItemXOffset = 64
kItemYOffset = 64

// checks relative position and defines which techId was hit
function GetTechIdAt(mouse_x, mouse_y, menuType)

    if mouse_x < kItemXOffset or mouse_x > kItemXOffset+kThreeDeeMenuItemSize.x*kThreeDeeMenuItemsPerRow  then
        return nil
    end
    
    local itemTable = kMenuItems[menuType]
    local numRows = math.ceil(#itemTable / kThreeDeeMenuItemsPerRow)

    if mouse_y < kItemYOffset or mouse_y > kItemYOffset+kThreeDeeMenuItemSize.y*numRows then
        return nil
    end
    
    mouse_x = mouse_x - kItemXOffset
    mouse_y = mouse_y - kItemYOffset
    
    local item = math.floor(mouse_y / kThreeDeeMenuItemSize.y) * kThreeDeeMenuItemsPerRow + math.floor(mouse_x / kThreeDeeMenuItemSize.x) + 1
    return itemTable[item]

end