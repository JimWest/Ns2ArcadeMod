// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\ThreeDeeMenuMixin.lua
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

Script.Load("lua/ThreeDeeUtility.lua")

ThreeDeeMenuMixin = CreateMixin( ThreeDeeMenuMixin )
ThreeDeeMenuMixin.type = "ThreeDeeMenu"

// variable defines which move to override to purchase items at the menu
//local kPurchase = Move.PrimaryAttack
local kPurchase = Move.Use

local kModelName = PrecacheAsset("models/marine/armory/menu.model")
local kMenuDisplayRange = 2.2
local useAxis = {

    Vector(1, 0, 0),
    Vector(0, 0, 1),
    Vector(-1, 0, 0),
    Vector(0, 0, -1)

}

local kVerticalOffset = Vector(0, 1.5, 0)
local kDistanceFromHostStructure = 0.85

// needs to be same size as physic plane
local kPlaneSize = Vector(0.5, 0.5, 0)

// returns closest armory / ptlab
local function GetNearbyMenuStructure(self)

    local hostStructures = {}
    
    table.copy(GetEntitiesForTeamWithinRange("Armory", self:GetTeamNumber(), self:GetOrigin(), kMenuDisplayRange), hostStructures, true)
    table.copy(GetEntitiesForTeamWithinRange("PrototypeLab", self:GetTeamNumber(), self:GetOrigin(), kMenuDisplayRange), hostStructures, true)
    
    Shared.SortEntitiesByDistance(self:GetOrigin(), hostStructures)
    
    for _, structure in pairs(hostStructures) do
    
        if GetIsUnitActive(structure) then
            return structure
        end    
        
    end
    
    return nil

end


// These are functions that override existing same-named functions instead
// of the default case of combining with them.
ThreeDeeMenuMixin.overrideFunctions =
{
}

ThreeDeeMenuMixin.expectedMixins =
{
}

ThreeDeeMenuMixin.optionalCallbacks =
{
}

ThreeDeeMenuMixin.networkVars =
{
}

function ThreeDeeMenuMixin:__initmixin()

    // only allow on client
    assert(Client)
    
    local modelIndex = Shared.GetModelIndex(kModelName)
    
    self.menuModel = Client.CreateRenderModel(RenderScene.Zone_Default)
    self.menuModel:SetModel(modelIndex)
    self.menuModel:SetIsVisible(false)
    self.menuCoords = Coords.GetIdentity()
    self.menuType = 0

    self.timeLastThreeDeeClick = 0
    self.focused = 0
    
    self.textGUIScript = GetGUIManager():CreateGUIScript("GUIArcade")
    
    self.purchasePressed = false
    
end

function ThreeDeeMenuMixin:OnKillClient()

    if self.menuModel then
    
        Client.DestroyRenderModel(self.menuModel)
        self.menuModel = nil  
      
    end
    
    if self.textGUIScript then
        
        GetGUIManager():DestroyGUIScript(self.textGUIScript)
        self.textGUIScript = nil

    end

end

local function SharedUpdate(self)

    if self:GetIsLocalPlayer() and self.menuModel then

        local hostStructure = GetNearbyMenuStructure(self)
        self.menuModel:SetIsVisible(hostStructure ~= nil)
        
        if hostStructure then
        
            // need at first to choose the right axis for menu position
            self.menuCoords.zAxis = hostStructure:GetCoords().zAxis
            local distance = 100
            
            for _, axis in ipairs(useAxis) do
            
                local worldAxis = hostStructure:GetCoords():TransformVector(axis)
                local useOrigin = hostStructure:GetOrigin() + worldAxis
                local useDistance = (self:GetOrigin() - useOrigin):GetLength()
                
                if useDistance < distance then
                
                    distance = useDistance
                    self.menuCoords.zAxis = worldAxis
                
                end
            
            end
        
            self.menuCoords.origin = hostStructure:GetOrigin() + self.menuCoords.zAxis * kDistanceFromHostStructure + kVerticalOffset
            self.menuCoords.xAxis = self.menuCoords.yAxis:CrossProduct(self.menuCoords.zAxis)
            self.menuModel:SetCoords(self.menuCoords)
            
            if hostStructure:GetTechId() == kTechId.Armory then
                self.menuType = kThreeDeeMenuType.Armory
            elseif hostStructure:GetTechId() == kTechId.AdvancedArmory then
                self.menuType = kThreeDeeMenuType.AdvancedArmory
            elseif hostStructure:isa("PrototypeLab") then
                self.menuType = kThreeDeeMenuType.PrototypeLab
            end
        
        else
            self.menuType = 0
        end
    
    end
    
end

if Client then
    /*
    function ThreeDeeMenuMixin:OnUpdate(deltaTime)   
        SharedUpdate(self)
    end

    function ThreeDeeMenuMixin:OnProcessMove(input)   
        SharedUpdate(self)
    end
    */
    
    function ThreeDeeMenuMixin:OnProcessIntermediate(input)
        SharedUpdate(self)
    end

end

if Client then

    local kHoverSound = "sound/ns2.fev/marine/common/weapon_select"
    Client.PrecacheLocalSound(kHoverSound)

    local function OnHover()    
        Shared.PlaySound(nil, kHoverSound)        
    end
    
    local kFocusSound = "sound/NS2.fev/common/open"
    Client.PrecacheLocalSound(kFocusSound)
    
    local function OnFocus()
        Shared.PlaySound(nil, kFocusSound)     
    end
    
    local kBlurSound = "sound/NS2.fev/common/close"
    Client.PrecacheLocalSound(kBlurSound)
    
    local function OnBlur()
        Shared.PlaySound(nil, kBlurSound)   
    end
    
    local function IntersectWithMenu(self)
        return GetLinePlaneIntersection(self.menuCoords.origin, self.menuCoords.zAxis * 3, self:GetEyePos(), self:GetViewCoords().zAxis)    
    end
    
    local function PointOnMenu(self, intersectionPoint)
    
        local xzLength = (intersectionPoint - self.menuCoords.origin):GetLengthXZ()
        local yLength = math.abs(intersectionPoint.y - self.menuCoords.origin.y)
        return xzLength < kPlaneSize.x and yLength < kPlaneSize.y
    
    end

    function ThreeDeeMenuMixin:OnUpdateRender()
    
        if not self:GetIsLocalPlayer() then
            return
        end    

        self.overrideInput = false
        local focused = 0

        if self.menuModel then
        
            if self.menuModel:GetIsVisible() then
            
                self.menuModel:SetMaterialParameter("menuType", self.menuType)
                
                for _, techId in ipairs(kMenuItems[self.menuType]) do        
                    UpdateBuyMenuParam(self.menuModel, techId)
                end
                
                local trace = Shared.TraceRay(self:GetEyePos() + self:GetViewCoords().zAxis * 0.2, self:GetEyePos() + self:GetViewCoords().zAxis * kMenuDisplayRange * 1.2, CollisionRep.Select, PhysicsMask.CommanderBuild)
                
                local intersectionPoint = IntersectWithMenu(self)
                
                if intersectionPoint and PointOnMenu(self, intersectionPoint) then
                
                    // the physic shape of the menu is a simple plane, but the menu itself is bended. this "projection" of the mouse position has a neat effect of snapping the cursor when reaching the edge of the menu
                    local relativePos = intersectionPoint - self.menuCoords.origin
                    self.mouse_x = 1 + self.menuCoords.xAxis:DotProduct(relativePos) * (1 / kPlaneSize.x)
                    self.mouse_y = 1 + self.menuCoords.yAxis:DotProduct(relativePos) * (1 / kPlaneSize.y)
                
                    focused = 1
 
                    self.mouse_x = self.mouse_x * kThreeDeeMenuWidth * 0.5
                    self.mouse_y = kThreeDeeMenuHeight - self.mouse_y * kThreeDeeMenuHeight * 0.5 // GUI starts Y = 0 on top

                    self.menuModel:SetMaterialParameter("mouse_x", self.mouse_x)
                    self.menuModel:SetMaterialParameter("mouse_y", self.mouse_y)
                    self.menuModel:SetMaterialParameter("currentRes", self:GetResources())
                    
                    local currentTechId = GetTechIdAt(self.mouse_x, self.mouse_y, self.menuType)
                    if currentTechId and currentTechId ~= kTechId.None then
                        self.menuModel:SetMaterialParameter("currentCost", GetCostForTech(currentTechId))
                    else
                        self.menuModel:SetMaterialParameter("currentCost", 0)
                    end
                    
                    if currentTechId and currentTechId ~= kTechId.None and currentTechId ~= self.threeDeeTechId and self.textGUIScript then
                    
                        self.textGUIScript:SetItemText(MarineBuy_GetWeaponDescription(currentTechId))
                        self.textGUIScript:TriggerFlashAnimation()
                        OnHover()
                    
                    end
                    
                    self.threeDeeTechId = currentTechId            
                    self.overrideInput = true
                
                else
                    self.textGUIScript:SetItemText("")
                end

            end 

            self.menuModel:SetMaterialParameter("focused", focused)   
        
        end
        
        if focused ~= self.focused then
        
            self.focused = focused
            
            if self.focused == 1 then
                OnFocus()
            else
                OnBlur()
            end
        
        end

    end

    local kClickDelay = 0.1
    local kPurchaseSound = "sound/ns2.fev/marine/common/comm_spend_metal"
    Client.PrecacheLocalSound(kPurchaseSound)

    local function ProcessClick(self)
    
        local overItem = false

        if self.mouse_x and self.mouse_y then
        
            local clickedTechId = GetTechIdAt(self.mouse_x, self.mouse_y, self.menuType)
            
            overItem = clickedTechId ~= nil and clickedTechId ~= kTechId.None
            
            /*
            if overItem then
            
                Print("clicked %s", ToString(clickedTechId))
                Print("has item: %s", ToString(PlayerUI_GetHasItem(clickedTechId)))
                Print("is researched: %s", ToString(MarineBuy_IsResearched(clickedTechId)))
                Print("has resources: %s", ToString(PlayerUI_GetPlayerResources() >= MarineBuy_GetCosts(clickedTechId)))
                Print("click delay ok %s", ToString(self.timeLastThreeDeeClick + kClickDelay < Shared.GetTime()))
            
            end
            */
            
            if overItem and not PlayerUI_GetHasItem(clickedTechId) and MarineBuy_IsResearched(clickedTechId) and
               PlayerUI_GetPlayerResources() >= MarineBuy_GetCosts(clickedTechId) and self.timeLastThreeDeeClick + kClickDelay < Shared.GetTime() then
               
                Client.SendNetworkMessage("Buy", BuildBuyMessage({ clickedTechId }), true)
                Shared.PlaySound(nil, kPurchaseSound)
                self.timeLastThreeDeeClick = Shared.GetTime()
                
            else
                self:TriggerInvalidSound()
            end
        
        end
        
        return overItem

    end

    function ThreeDeeMenuMixin:MixinOverrideInput(input)

        // capture on purchase key down event
        // due to some strange reason receives override input wrong data.
        // holding down a key will not cause the check to always result true/ false as expected
        // not that this code is not running in predict thread, a check Shared.GetIsRunningPrediction wont
        // change this wrong behavior
        
        local purchasePressed = bit.band(input.commands, kPurchase) ~= 0
        local onPurchaseKeyDown = false
        local onPurchaseKeyUp = false
    
        if purchasePressed then
        
            self.timeLastPurchaseKeyPress = Shared.GetTime()
            onPurchaseKeyDown = self.purchasePressed == false
            self.purchasePressed = true
        
        // we "release" the button only after a time out, necesseary due to the bug described above    
        elseif self.timeLastPurchaseKeyPress and self.timeLastPurchaseKeyPress + 0.15 < Shared.GetTime() then

            onPurchaseKeyUp = self.purchasePressed == true
            self.purchasePressed = false
        
        end
        
        if self.overrideInput then

            if onPurchaseKeyDown then
                ProcessClick(self)
            end
        
            // Don't allow primary attack when interacting with the menu
            local removePurchaseKeyMask = bit.bxor(0xFFFFFFFF, kPurchase)
            input.commands = bit.band(input.commands, removePurchaseKeyMask)

        end
        
        return input
        
    end
    
    function ThreeDeeMenuMixin:GetIsLookingAtMenu()
        return self.overrideInput == true
    end

end