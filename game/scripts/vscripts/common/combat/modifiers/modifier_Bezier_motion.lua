--=======================================modifier_Bezier_motion=======================================
if modifier_Bezier_motion == nil then
    modifier_Bezier_motion = class({})
end
function modifier_Bezier_motion:IsHidden()
    return true
end
function modifier_Bezier_motion:IsDebuff()
    return false
end
function modifier_Bezier_motion:IsPurgable()
    return false
end
function modifier_Bezier_motion:IsPurgeException()
    return false
end
function modifier_Bezier_motion:OnCreated(params)
    if IsServer() then
        if params.vStart_x == nil or params.vStart_y == nil or params.vStart_z == nil or params.vEnd_x == nil or params.vEnd_y == nil or params.vEnd_z == nil then
            self:Destroy()
        end
        self:SetHasCustomTransmitterData(true)
        --状态部分
        self.bStun = params.bStun
        self.anim = params.anim
        self.particle_attach = params.particle_attach
        self.particle_name = params.particle_name
        self.motion_type = params.motion_type or BEZIER_MOTION_TYPE_NONE

        --曲线部分
        self.start_time = GameRules:GetGameTime()
        self.progress = 0
        self.fSpeed = params.fSpeed or 1
        self.vStart = Vector(params.vStart_x, params.vStart_y, params.vStart_z)
        self.vEnd = Vector(params.vEnd_x, params.vEnd_y, params.vEnd_z)
        self.fHeight = params.fHeight
        self.vMid = GetMidPoint(self.vStart, self.vEnd) + Vector(0, 0, self.fHeight)

        if not self:ApplyHorizontalMotionController() then
            self:Destroy()
        end
        if not self:ApplyVerticalMotionController() then
            self:Destroy()
        end
    end
end
function modifier_Bezier_motion:OnRefresh(params)
end
function modifier_Bezier_motion:OnDestroy(params)
    if IsServer() then
        local hCaster = self:GetCaster()
        local hParent = self:GetParent()
        if self.motion_type == BEZIER_MOTION_TYPE_VEHICLE then
            CFireModifierEvent(hCaster, CMODIFIER_EVENT_ON_PASSENGER_GETON, {passenger = hParent, target = hCaster})
            CFireModifierEvent(hParent, CMODIFIER_EVENT_ON_PASSENGER_GETON, {passenger = hParent, target = hCaster})
        end
    end
end
function modifier_Bezier_motion:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
end
function modifier_Bezier_motion:CDeclareFunctions()
    return {
    }
end
function modifier_Bezier_motion:CheckState()
    if self.bStun == nil then
        return {}
    elseif self.bStun then
        return {
            [MODIFIER_STATE_STUNNED] = true,
        }
    end
end
function modifier_Bezier_motion:AddCustomTransmitterData()
    return {
        anim = self.anim,
        particle_attach = self.particle_attach,
        particle_name = self.particle_name,
    }
end
function modifier_Bezier_motion:HandleCustomTransmitterData( data )
    self.anim = data.anim
    self.particle_attach = data.particle_attach
    self.particle_name = data.particle_name
end
function modifier_Bezier_motion:GetOverrideAnimation()
    return self.anim
end
function modifier_Bezier_motion:GetModifierModelScale()
    if self.motion_type == BEZIER_MOTION_TYPE_VEHICLE then
        return -50
    end
end
function modifier_Bezier_motion:GetEffectAttachType()
    return self.particle_attach
end
function modifier_Bezier_motion:GetEffectName()
    return self.particle_name
end
function modifier_Bezier_motion:UpdateHorizontalMotion(me, dt)
    if IsServer() then
        local progress
        local hCaster = self:GetCaster()
        if self:GetDuration() ~= 0 then
            progress = (self:GetDuration() - self:GetRemainingTime()) / self:GetDuration()
        else
            self.progress = self.progress + 0.01 * self.fSpeed
            progress = self.progress
        end
        me:SetAbsOrigin(math.pow((1 - progress), 2) * self.vStart + 2 * progress * (1 - progress) * self.vMid + math.pow(progress, 2) * self.vEnd)
        if progress >= 1 then
            FindClearSpaceForUnit(me, me:GetAbsOrigin(), true)
            self:Destroy()
        end
    end
end
function modifier_Bezier_motion:UpdateVerticalMotion(me, dt)
    if IsServer() then
        local progress
        local hCaster = self:GetCaster()
        if self:GetDuration() ~= 0 then
            progress = (self:GetDuration() - self:GetRemainingTime()) / self:GetDuration()
        else
            self.progress = self.progress + 0.01 * self.fSpeed
            progress = self.progress
        end
        me:SetAbsOrigin(math.pow((1 - progress), 2) * self.vStart + 2 * progress * (1 - progress) * self.vMid + math.pow(progress, 2) * self.vEnd)
        if progress >= 1 then
            FindClearSpaceForUnit(me, me:GetAbsOrigin(), true)
            self:Destroy()
        end
    end
end
