
LinkLuaModifier("modifier_Vehicle_inside", "units/abilities/dungeon/kobold_mine_cave/modifier_Vehicle.lua", LUA_MODIFIER_MOTION_BOTH)

--=======================================modifier_Vehicle=======================================
if modifier_Vehicle == nil then
    modifier_Vehicle = class({})
end
function modifier_Vehicle:IsHidden()
    return true
end
function modifier_Vehicle:IsDebuff()
    return false
end
function modifier_Vehicle:IsPurgable()
    return false
end
function modifier_Vehicle:IsPurgeException()
    return false
end
function modifier_Vehicle:OnCreated(params)
    local hCaster = self:GetCaster()
    if IsServer() then
        self.VehicleData = KeyValues:GetUnitSpecialValue(hCaster, "VehicleData")
        self.Seats_array = self.VehicleData.Seats_array
        self.Passenger_offset = {}
        for seat_index, seat_offset in pairs(self.Seats_array) do
            print("N2O", seat_index, seat_offset)

            self.Passenger_offset[tonumber(seat_index)] = vlua.split(seat_offset, " ")
        end

        self.Passengers = {}
        for i = 1, self.VehicleData.Vehicle_capacity do
            self.Passengers[i] = nil
        end

        self.Vehicle_height = self.VehicleData.Vehicle_height or 130
    end
end
function modifier_Vehicle:OnRefresh(params)
end
function modifier_Vehicle:OnDestroy(params)
end
function modifier_Vehicle:RemoveOnDeath()
    return false
end
function modifier_Vehicle:DeclareFunctions()
    return {
    }
end
function modifier_Vehicle:CDeclareFunctions()
    return {
        CMODIFIER_EVENT_ON_INTERACTIVE,
        CMODIFIER_EVENT_ON_PASSENGER_GETON,
    }
end
function modifier_Vehicle:CheckState()
    return {
    }
end
function modifier_Vehicle:C_OnInterActive( params )
    local hCaster = self:GetCaster()
    if params.target == hCaster then
        local vTarget_pos = Vector(0, 0, 0)
        for i = 1, self.VehicleData.Vehicle_capacity do
            if self.Passengers[i] == nil then
                print("N2O", tonumber(self.Passenger_offset[i][1]), tonumber(self.Passenger_offset[i][2]))
                vTarget_pos = hCaster:GetAbsOrigin() + tonumber(self.Passenger_offset[i][1]) * hCaster:GetRightVector() + tonumber(self.Passenger_offset[i][2]) * hCaster:GetForwardVector() + Vector(0, 0, 130)
                print("N2O", i, self.Passengers[i])
                self.Passengers[i] = params.unit
                print("N2O", i, self.Passengers[i])
                break
            end
        end
        EmitSoundOn("Ability.TossThrow", hCaster)
        params.unit:AddBezierMotion(hCaster, nil, {
            vStart = params.unit:GetAbsOrigin(), 
            vEnd = vTarget_pos, 
            fHeight = 400, 
            -- fSpeed = 3,
            bStun = true,
            anim = ACT_DOTA_FLAIL,
            particle_attach = PATTACH_ABSORIGIN_FOLLOW,
            particle_name = "particles/items_fx/pogo_stick.vpcf",
            duration = 1,
            motion_type = BEZIER_MOTION_TYPE_VEHICLE,
            })

    end
end
function modifier_Vehicle:C_OnPassengerGetOn( params )
    local unit = params.passenger
    local hCaster = self:GetCaster()
    local vTarget_pos = Vector(0, 0, 0)
    for i = 1, self.VehicleData.Vehicle_capacity do
        if self.Passengers[i] == unit then
            print("N2O", tonumber(self.Passenger_offset[i][1]), tonumber(self.Passenger_offset[i][2]))
            vTarget_pos = hCaster:GetAbsOrigin() + tonumber(self.Passenger_offset[i][1]) * hCaster:GetRightVector() + tonumber(self.Passenger_offset[i][2]) * hCaster:GetForwardVector() + Vector(0, 0, self.Vehicle_height)
            break
        end
    end
    unit:AddNewModifier(unit, nil, "modifier_Vehicle_inside", {x = vTarget_pos.x, y = vTarget_pos.y, z = vTarget_pos.z})
end
--=======================================modifier_Vehicle_inside=======================================
if modifier_Vehicle_inside == nil then
    modifier_Vehicle_inside = class({})
end
function modifier_Vehicle_inside:IsHidden()
    return true
end
function modifier_Vehicle_inside:IsDebuff()
    return false
end
function modifier_Vehicle_inside:IsPurgable()
    return false
end
function modifier_Vehicle_inside:IsPurgeException()
    return false
end
function modifier_Vehicle_inside:OnCreated(params)
    if IsServer() then
        self.position = Vector(params.x, params.y, params.z)
        
        if not self:ApplyHorizontalMotionController() then
            self:Destroy()
        end
        if not self:ApplyVerticalMotionController() then
            self:Destroy()
        end
    end
end
function modifier_Vehicle_inside:OnRefresh(params)
end
function modifier_Vehicle_inside:OnDestroy(params)
end
function modifier_Vehicle_inside:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
end
function modifier_Vehicle_inside:CDeclareFunctions()
    return {
    }
end
function modifier_Vehicle_inside:CheckState()
    return {
        --[MODIFIER_STATE_ROOTED] = true,
    }
end
function modifier_Vehicle_inside:UpdateHorizontalMotion(hParent, dt)
    local hCaster = self:GetCaster()
    if IsServer() then
        hParent:SetAbsOrigin(self.position)
    end
end
function modifier_Vehicle_inside:UpdateVerticalMotion(hParent, dt)
    local hCaster = self:GetCaster()
    if IsServer() then
        hParent:SetAbsOrigin(self.position)
    end
end
function modifier_Vehicle_inside:GetModifierModelScale()
    return -50
end
