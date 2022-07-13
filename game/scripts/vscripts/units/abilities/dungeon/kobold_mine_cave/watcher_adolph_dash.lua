LinkLuaModifier("modifier_watcher_adolph_dash_pre", "units/abilities/dungeon/kobold_mine_cave/watcher_adolph_dash.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_watcher_adolph_dash", "units/abilities/dungeon/kobold_mine_cave/watcher_adolph_dash.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

--=======================================watcher_adolph_dash=======================================
if watcher_adolph_dash == nil then
    watcher_adolph_dash = class({})
end
function watcher_adolph_dash:OnSpellStart()
    local hCaster = self:GetCaster()
    local hTarget = self:GetCursorTarget()
    local pre_time = self:GetSpecialValueFor("pre_time")

    EmitSoundOn("Hero_Lycan.Howl", hCaster)

    hCaster:AddNewModifier(hCaster, self, "modifier_watcher_adolph_dash_pre", {duration = pre_time, target_index = hTarget:entindex()})
    
end
--=======================================modifier_watcher_adolph_dash_pre=======================================
if modifier_watcher_adolph_dash_pre == nil then
    modifier_watcher_adolph_dash_pre = class({})
end
function modifier_watcher_adolph_dash_pre:IsHidden()
    return true
end
function modifier_watcher_adolph_dash_pre:IsDebuff()
    return false
end
function modifier_watcher_adolph_dash_pre:IsPurgable()
    return false
end
function modifier_watcher_adolph_dash_pre:IsPurgeException()
    return false
end
function modifier_watcher_adolph_dash_pre:OnCreated(params)
    if IsServer() then
        local hCaster = self:GetCaster()
        self.target = EntIndexToHScript(params.target_index)

        self.alert_particle = ParticleManager:CreateParticle("particles/spell_alert/generic_alert_unit_aoe.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControlEnt(self.alert_particle, 2, self.target, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0, 0, 50), true)
        ParticleManager:SetParticleControl(self.alert_particle, 3, Vector(self:GetAbilitySpecialValueFor("radius"), 0, 0))
        ParticleManager:SetParticleControl(self.alert_particle, 4, Vector(255, 0, 0))
        ParticleManager:SetParticleControlEnt(self.alert_particle, 7, hCaster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 50), true)
        self:AddParticle(self.alert_particle, true, false, -1, false, false)
        self:StartIntervalThink(FrameTime())
    end
end
function modifier_watcher_adolph_dash_pre:OnRefresh(params)
end
function modifier_watcher_adolph_dash_pre:OnDestroy(params)
    local hCaster = self:GetCaster()
    local hParent = self:GetParent()
    if not IsServer() then
        return
    end
    if not hParent:IsAlive() then
        return
    end
    if IsValidEntity(self.target) and self.target:IsAlive() then
        hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_watcher_adolph_dash", {target_index = self.target:entindex()})
    end
    
end
function modifier_watcher_adolph_dash_pre:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
    }
end
function modifier_watcher_adolph_dash_pre:CDeclareFunctions()
    return {
    }
end
function modifier_watcher_adolph_dash_pre:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
    }
end
function modifier_watcher_adolph_dash_pre:OnIntervalThink()
    local hCaster = self:GetCaster()
    if IsValidEntity(self.target) and self.target:IsAlive() then
        --ParticleManager:SetParticleControl(self.alert_particle, 7, hCaster:GetAbsOrigin())
        -- ParticleManager:SetParticleControl(self.alert_particle, 2, self.target:GetAbsOrigin())
        --ParticleManager:SetParticleControlEnt(self.alert_particle, 7, hCaster, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0, 0, 50), true)
        --ParticleManager:SetParticleControlEnt(self.alert_particle, 2, self.target, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0, 0, 50), true)
        hCaster:SetForwardVector((self.target:GetAbsOrigin() - hCaster:GetAbsOrigin()):Normalized())
    else
        self:Destroy()
    end
end
function modifier_watcher_adolph_dash_pre:GetOverrideAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end
function modifier_watcher_adolph_dash_pre:GetOverrideAnimationRate()
    return 0.3
end
--=======================================modifier_watcher_adolph_dash=======================================
if modifier_watcher_adolph_dash == nil then
    modifier_watcher_adolph_dash = class({})
end
function modifier_watcher_adolph_dash:IsHidden()
    return true
end
function modifier_watcher_adolph_dash:IsDebuff()
    return false
end
function modifier_watcher_adolph_dash:IsPurgable()
    return false
end
function modifier_watcher_adolph_dash:IsPurgeException()
    return false
end
function modifier_watcher_adolph_dash:OnCreated(params)
    if IsServer() then
        self.target = EntIndexToHScript(params.target_index)
        self.radius = self:GetAbilitySpecialValueFor("radius")
        self.damage = self:GetAbilitySpecialValueFor("damage")
        EmitSoundOn("Hero_Lycan.Shapeshift.Cast", self:GetParent())
        if not self:ApplyHorizontalMotionController() then
            self:Destroy()
        end
    end
end
function modifier_watcher_adolph_dash:OnRefresh(params)
end
function modifier_watcher_adolph_dash:OnDestroy(params)
end
function modifier_watcher_adolph_dash:UpdateHorizontalMotion(me, dt)
    if (self.target:GetAbsOrigin() - me:GetAbsOrigin()):Length2D() <= me:Script_GetAttackRange() then

        StopSoundOn("Hero_Lycan.Shapeshift.Cast", me)
        EmitSoundOn("hero_bloodseeker.bloodRite.silence", self:GetParent())

        local particleID = ParticleManager:CreateParticle("particles/units/neutrals/watcher_adolph/watcher_adolph_dash_aoe.vpcf", PATTACH_ABSORIGIN_FOLLOW, me)
        ParticleManager:ReleaseParticleIndex(particleID)

        local enemies = FindUnitsInRadius(me:GetTeamNumber(), me:GetAbsOrigin(), nil, self.radius, self:GetAbility():GetAbilityTargetTeam(), self:GetAbility():GetAbilityTargetType(), self:GetAbility():GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
        for _, enemy in pairs(enemies) do
            if IsValidEntity(enemy) and enemy:IsAlive() then
                EmitSoundOn("Hero_Spectre.Attack", enemy)
                ApplyDamage({
                    victim = enemy,
                    attacker = me,
                    damage = self.damage,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    ability = self:GetAbility(),
                })
            end
        end

        FindClearSpaceForUnit(me, me:GetAbsOrigin(), true)
        self:Destroy()
    else
        me:SetAbsOrigin(me:GetAbsOrigin() + (self.target:GetAbsOrigin() - me:GetAbsOrigin()):Normalized() * 50)
    end
end
function modifier_watcher_adolph_dash:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
end
function modifier_watcher_adolph_dash:CDeclareFunctions()
    return {
    }
end
function modifier_watcher_adolph_dash:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true,
    }
end
function modifier_watcher_adolph_dash:GetOverrideAnimation()
    return ACT_DOTA_RUN
end
function modifier_watcher_adolph_dash:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_watcher_adolph_dash:GetEffectName()
    return "particles/units/heroes/hero_lycan/lycan_shapeshift_buff.vpcf"
end