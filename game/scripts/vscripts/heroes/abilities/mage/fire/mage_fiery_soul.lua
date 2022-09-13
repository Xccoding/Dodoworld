LinkLuaModifier("modifier_mage_fiery_soul", "heroes/abilities/mage/fire/mage_fiery_soul.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mage_fiery_soul_combo", "heroes/abilities/mage/fire/mage_fiery_soul.lua", LUA_MODIFIER_MOTION_NONE)

--Abilities
if mage_fiery_soul == nil then
    mage_fiery_soul = class({})
end
function mage_fiery_soul:GetIntrinsicModifierName()
    if self:GetLevel() >= 1 then
        return "modifier_mage_fiery_soul"
    end
end
---------------------------------------------------------------------
--炽热连击Modifiers
if modifier_mage_fiery_soul == nil then
    modifier_mage_fiery_soul = class({})
end
function modifier_mage_fiery_soul:IsDebuff()
    return false
end
function modifier_mage_fiery_soul:IsHidden()
    return true
end
function modifier_mage_fiery_soul:IsPurgable()
    return false
end
function modifier_mage_fiery_soul:GetAbilityValues()
    self.combo_duration = self:GetAbilitySpecialValueFor("combo_duration")
end
function modifier_mage_fiery_soul:OnCreated(params)
    self:GetAbilityValues()
    self.spell_records = {}
    if IsServer() then
        self:StartIntervalThink(FrameTime())
    end
end
function modifier_mage_fiery_soul:OnRefresh(params)
    self:GetAbilityValues()
    if IsServer() then
    end
end
function modifier_mage_fiery_soul:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP,
    }
end
function modifier_mage_fiery_soul:OnTooltip()
    return self:GetStackCount()
end
function modifier_mage_fiery_soul:CDeclareFunctions()
    return {
        CMODIFIER_EVENT_ON_SPELL_CRIT,
        CMODIFIER_EVENT_ON_SPELL_NOTCRIT
    }
end

function modifier_mage_fiery_soul:C_OnSpellCrit(params)
    if not IsServer() then
        return
    end
    local hCaster = self:GetCaster()
    if params.attacker == hCaster then
        local hAbility = params.inflictor
        if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_DIRECT) == DOTA_DAMAGE_FLAG_DIRECT then
            local bShoudCount = false
            local schoolData = nil
            if KeyValues.SchoolsKv[hCaster:GetUnitLabel()] ~= nil then
                schoolData = KeyValues.SchoolsKv[hCaster:GetUnitLabel()][tostring(Abilities_manager:GetCurrentSchools(hCaster))]
            end

            if schoolData ~= nil then
                for i = 1, 12 do
                    if schoolData["Ability" .. i] ~= nil then
                        if hAbility:GetAbilityName() ~= "mage_blink" and hAbility:GetAbilityName() == schoolData["Ability" .. i] then
                            bShoudCount = true
                            break
                        end
                    end
                end
            end

            if bShoudCount then
                local bAlready_record = false
                for _, record in pairs(self.spell_records) do
                    if record.hAbility == hAbility and record.time == GameRules:GetGameTime() then
                        if not record.bCrit then
                            record.bCrit = true
                        end
                        bAlready_record = true
                    end
                end

                if not bAlready_record then
                    table.insert(self.spell_records, { hAbility = hAbility, time = GameRules:GetGameTime(), bCrit = true })
                end
            end
        end
    end
end
function modifier_mage_fiery_soul:C_OnSpellNotCrit(params)
    if not IsServer() then
        return
    end
    local hCaster = self:GetCaster()
    if params.attacker == hCaster then
        local hAbility = params.inflictor
        if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_DIRECT) == DOTA_DAMAGE_FLAG_DIRECT then
            local bShoudCount = false
            local schoolData = nil
            if KeyValues.SchoolsKv[hCaster:GetUnitLabel()] ~= nil then
                schoolData = KeyValues.SchoolsKv[hCaster:GetUnitLabel()][tostring(Abilities_manager:GetCurrentSchools(hCaster))]
            end

            if schoolData ~= nil then
                for i = 1, 12 do
                    if schoolData["Ability" .. i] ~= nil then
                        if hAbility:GetAbilityName() == schoolData["Ability" .. i] then
                            bShoudCount = true
                            break
                        end
                    end
                end
            end

            if bShoudCount then
                local bAlready_record = false
                for _, record in pairs(self.spell_records) do
                    if record.hAbility == hAbility and record.time == GameRules:GetGameTime() then
                        bAlready_record = true
                    else
                        if record.hAbility == hAbility then
                            -- print(record.time,GameRules:GetGameTime(),"not equal time")
                        end
                    end
                end

                if not bAlready_record then
                    table.insert(self.spell_records, { hAbility = hAbility, time = GameRules:GetGameTime(), bCrit = false })
                end
            end

        end

    end
end
function modifier_mage_fiery_soul:OnIntervalThink()
    for i = #self.spell_records, 1, -1 do
        if GameRules:GetGameTime() - self.spell_records[i].time >= FrameTime() then
            if self.spell_records[i].bCrit == false then
                --最近一个法术没暴击，取消连击
                --print("取消连击")
                for j = i, 1, -1 do
                    table.remove(self.spell_records, j)
                end
                self:SetStackCount(0)
                break
            else
                --最近一个法术暴击了
                if i - 1 >= 1 then
                    if self.spell_records[i - 1].bCrit == true then
                        --print("炽热连击")
                        local hCaster = self:GetCaster()
                        local mage_laguna_blade = hCaster:FindAbilityByName("mage_laguna_blade")
                        local mage_light_strike_array = hCaster:FindAbilityByName("mage_light_strike_array")
                        mage_laguna_blade:EndCooldown()
                        mage_light_strike_array:EndCooldown()

                        EmitSoundOnEntityForPlayer("Hero_Nevermore.Shadowraze.Arcana", hCaster, hCaster:GetPlayerOwnerID())

                        if self.particle_combo ~= nil then
                            ParticleManager:DestroyParticle(self.particle_combo, true)
                        end
                        self.particle_combo = ParticleManager:CreateParticleForPlayer("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_double.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster, hCaster:GetPlayerOwner())

                        hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_mage_fiery_soul_combo", { duration = self.combo_duration })
                        self:SetStackCount(0)
                        for j = i, 1, -1 do
                            table.remove(self.spell_records, j)
                        end
                        break
                    end
                else
                    if self:GetStackCount() < 1 then
                        local hCaster = self:GetCaster()
                        if self.particle_combo ~= nil then
                            ParticleManager:DestroyParticle(self.particle_combo, true)
                        end
                        EmitSoundOnEntityForPlayer("Hero_Nevermore.Shadowraze.Arcana", hCaster, hCaster:GetPlayerOwnerID())
                        self.particle_combo = ParticleManager:CreateParticleForPlayer("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze_ovr_lrg_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster, hCaster:GetPlayerOwner())
                        ParticleManager:SetParticleControlEnt(self.particle_combo, 0, hCaster, PATTACH_OVERHEAD_FOLLOW, "", Vector(0, 0, 0), false)
                        --print("一层连击")
                        self:SetStackCount(1)
                    end
                end
            end
        end
    end
end

--连击Modifiers
if modifier_mage_fiery_soul_combo == nil then
    modifier_mage_fiery_soul_combo = class({})
end
function modifier_mage_fiery_soul_combo:IsDebuff()
    return false
end
function modifier_mage_fiery_soul_combo:IsHidden()
    return false
end
function modifier_mage_fiery_soul_combo:IsPurgable()
    return false
end
function modifier_mage_fiery_soul_combo:GetAbilityValues()
    self.combo_multiple = self:GetAbilitySpecialValueFor("combo_multiple")
    self.combo_duration = self:GetAbilitySpecialValueFor("combo_duration")
    self.reset_chance = self:GetAbilitySpecialValueFor("reset_chance")
end
function modifier_mage_fiery_soul_combo:OnCreated(params)
    self:GetAbilityValues()
    local hCaster = self:GetCaster()
    if IsServer() then
        local particleID = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_lina/lina_fiery_soul.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster, hCaster:GetPlayerOwner())
        ParticleManager:SetParticleControl(particleID, 1, Vector(1, 0, 0))
        self:AddParticle(particleID, false, false, -1, false, false)
    end
end
function modifier_mage_fiery_soul_combo:OnRefresh(params)
    self:GetAbilityValues()
end
function modifier_mage_fiery_soul_combo:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP
    }
end
function modifier_mage_fiery_soul_combo:OnDestroy()
    if IsServer() then
        local hCaster = self:GetCaster()
        if RandomFloat(0, 100) < self.reset_chance and self:GetRemainingTime() > 0 then
            local mage_laguna_blade = hCaster:FindAbilityByName("mage_laguna_blade")
            local mage_light_strike_array = hCaster:FindAbilityByName("mage_light_strike_array")
            mage_laguna_blade:EndCooldown()
            mage_light_strike_array:EndCooldown()
            hCaster:AddNewModifier(hCaster, self:GetAbility(), "modifier_mage_fiery_soul_combo", { duration = self.combo_duration })
        end
    end
end
function modifier_mage_fiery_soul_combo:OnTooltip()
    return self.combo_multiple
end