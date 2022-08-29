LinkLuaModifier("modifier_Vehicle", "common/managers/vehicle_manager.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_Vehicle_inside", "common/managers/vehicle_manager.lua", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_Vehicle_Bezier", "common/enviroment/modifiers/modifier_Vehicle_Bezier.lua", LUA_MODIFIER_MOTION_BOTH)

VEHICLE_STATE_WAIT = 1
VEHICLE_STATE_MOVE = 2

--贝塞尔曲线型Motion类型标识
_G.BEZIER_MOTION_TYPE_NONE = 1 --默认
_G.BEZIER_MOTION_TYPE_VEHICLE = 2 --上下载具

if Vehicle_manager == nil then
    Vehicle_manager = {}
end

function Vehicle_manager:constructor(unit)
    self.VehicleData = KeyValues:GetUnitSpecialValue(unit, "VehicleData")
    self.Seats_array = self.VehicleData.Seats_array
    self.Passenger_offset = {}
    for seat_index, seat_offset in pairs(self.Seats_array) do
        self.Passenger_offset[tonumber(seat_index)] = vlua.split(seat_offset, " ")
    end

    self.Passengers = {}
    for i = 1, self.VehicleData.Vehicle_capacity do
        self.Passengers[i] = nil
    end

    self.Vehicle_height = self.VehicleData.Vehicle_height or 130
    
    self.me = unit
    self.Vehicle_modifier = unit:AddNewModifier(unit, nil, "modifier_Vehicle", {})
    self.Vehicle_state = VEHICLE_STATE_WAIT
    unit.Vehicle = self
end
function Vehicle_manager:C_OnInterActive( params )
    local hCaster = self.me
    if params.target == hCaster then
        --如果已经在载具上，不能再次上载具
        for i = 1, self.VehicleData.Vehicle_capacity do
            if self.Passengers[i] ~= nil and self.Passengers[i] == params.unit then
                return
            end
        end

        local vTarget_pos = Vector(0, 0, 0)
        for i = 1, self.VehicleData.Vehicle_capacity do
            if self.Passengers[i] == nil then
                vTarget_pos = hCaster:GetAbsOrigin() + tonumber(self.Passenger_offset[i][1]) * hCaster:GetRightVector() + tonumber(self.Passenger_offset[i][2]) * hCaster:GetForwardVector() + Vector(0, 0, 130)
                self.Passengers[i] = params.unit
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
function Vehicle_manager:C_OnPassengerGetOn( params )
    local unit = params.passenger
    local hCaster = self.me
    local bFull = true

    for i = 1, self.VehicleData.Vehicle_capacity do
        if self.Passengers[i] == unit then
            unit:AddNewModifier(hCaster, nil, "modifier_Vehicle_inside", { x = tonumber(self.Passenger_offset[i][1]), y = tonumber(self.Passenger_offset[i][2]), z = self.Vehicle_height })
            break
        end
    end
    
    --如果乘客已满,发车
    for i = 1, self.VehicleData.Vehicle_capacity do
        if self.Passengers[i] == nil then
            bFull = false
        end
    end
    if bFull  or true then
        self.Vehicle_state = VEHICLE_STATE_MOVE
        
        hCaster:SetContextThink(DoUniqueString("VehicleMoving"), function ()
            if not hCaster:IsCurrentlyHorizontalMotionControlled() then
                self.Vehicle_state = VEHICLE_STATE_WAIT
                return nil
            else
                for i = 1, self.VehicleData.Vehicle_capacity do
                    if self.Passengers[i] ~= nil then
                        self.Passengers[i]:SetAbsOrigin(hCaster:GetAbsOrigin() + tonumber(self.Passenger_offset[i][1]) * hCaster:GetRightVector() + tonumber(self.Passenger_offset[i][2]) * hCaster:GetForwardVector() + Vector(0, 0, self.Vehicle_height))
                    end
                end
                return 0         
            end
        end, 0)
        hCaster:AddNewModifier(hCaster, nil, "modifier_Vehicle_Bezier", {})
    end
end
function Vehicle_manager:RemovePassenger( unit )
    for i = 1, self.VehicleData.Vehicle_capacity do
        if self.Passengers[i] == unit then
            self.Passengers[i] = nil
            break
        end
    end
end

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
function modifier_Vehicle:C_OnInterActive(params)
    params.target.Vehicle:C_OnInterActive(params)
end
function modifier_Vehicle:C_OnPassengerGetOn(params)
    params.target.Vehicle:C_OnPassengerGetOn(params)
end
--=======================================modifier_Vehicle_inside=======================================
if modifier_Vehicle_inside == nil then
    modifier_Vehicle_inside = class({})
end
function modifier_Vehicle_inside:IsHidden()
    return false
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
        self.offset_x = params.x
        self.offset_y = params.y
        self.offset_z = params.z

        --self:StartIntervalThink(0)

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
        MODIFIER_EVENT_ON_ORDER,
    }
end
function modifier_Vehicle_inside:CDeclareFunctions()
    return {
    }
end
function modifier_Vehicle_inside:CheckState()
    local hCaster = self:GetCaster()
    if hCaster.Vehicle.Vehicle_state == VEHICLE_STATE_MOVE then
        return {
            [MODIFIER_STATE_STUNNED] = true,
        }
    else
        return {}
    end
    
end
function modifier_Vehicle_inside:UpdateHorizontalMotion(hParent, dt)
    if IsServer() then
    end
end
function modifier_Vehicle_inside:UpdateVerticalMotion(hParent, dt)
    if IsServer() then
    end
end
function modifier_Vehicle_inside:GetModifierModelScale()
    return -50
end
function modifier_Vehicle_inside:OnOrder(params)
    local hParent = self:GetParent()
    local hCaster = self:GetCaster()
    if params.unit == hParent and params.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
        local dir = (params.new_pos - params.unit:GetAbsOrigin()):Normalized()
        local range = math.min((params.new_pos - params.unit:GetAbsOrigin()):Length2D(), 300)
        local new_pos = params.unit:GetAbsOrigin() + dir * range
        hCaster.Vehicle:RemovePassenger(hParent)
        params.unit:AddBezierMotion(params.unit, nil, {
            vStart = params.unit:GetAbsOrigin(),
            vEnd = new_pos,
            fHeight = 400,
            -- fSpeed = 3,
            bStun = true,
            anim = ACT_DOTA_FLAIL,
            particle_attach = PATTACH_ABSORIGIN_FOLLOW,
            particle_name = "particles/items_fx/pogo_stick.vpcf",
            duration = 1,
            motion_type = BEZIER_MOTION_TYPE_VEHICLE,
        })
        self:Destroy()
    end
end

return Vehicle_manager