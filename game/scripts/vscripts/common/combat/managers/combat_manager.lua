_G.DOTA_DAMAGE_FLAG_LAST = 2 ^ 15
_G.DOTA_DAMAGE_FLAG_DIRECT = DOTA_DAMAGE_FLAG_LAST * 2--直接伤害
_G.DOTA_DAMAGE_FLAG_INDIRECT = DOTA_DAMAGE_FLAG_DIRECT * 2--持续伤害
_G.DOTA_DAMAGE_FLAG_FIERY_SOUL_COMBO = DOTA_DAMAGE_FLAG_INDIRECT * 2--炽魂连击瞬发光击阵或神灭斩

--贝塞尔曲线型Motion类型标识
_G.BEZIER_MOTION_TYPE_NONE = 1 --默认
_G.BEZIER_MOTION_TYPE_VEHICLE = 2 --上下载具

LinkLuaModifier( "modifier_stun_custom", "common/combat/modifiers/modifier_stun_custom.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_combat", "common/combat/modifiers/modifier_combat.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_taunt_custom", "common/combat/modifiers/modifier_taunt_custom.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_disable_autoattack_custom", "common/combat/modifiers/modifier_disable_autoattack_custom.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_escape", "common/combat/modifiers/modifier_escape.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_no_combat_slow", "common/combat/modifiers/modifier_no_combat_slow.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_hide_aggro", "common/combat/modifiers/modifier_hide_aggro.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_channel_watcher", "common/combat/modifiers/modifier_channel_watcher.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Invulnerable", "common/combat/modifiers/modifier_Invulnerable.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_interactive", "common/combat/modifiers/modifier_interactive.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_Bezier_motion", "common/combat/modifiers/modifier_Bezier_motion.lua", LUA_MODIFIER_MOTION_BOTH )
LinkLuaModifier("modifier_Vehicle", "units/abilities/dungeon/kobold_mine_cave/modifier_Vehicle.lua", LUA_MODIFIER_MOTION_NONE)

if IsClient() then
    function C_DOTA_BaseNPC:InCombat()
        if self:HasModifier("modifier_combat") then
            return true
        end
        return false
    end
elseif IsServer() then
    function CDOTA_BaseNPC:InCombat()
        if self:HasModifier("modifier_combat") then
            return true
        end
        return false
    end

    function CDOTA_BaseNPC:GetDPS()
        if not IsServer() then
            return 0
        end
        if self:HasModifier("modifier_combat") then
            return (self:FindModifierByName("modifier_combat").damage / math.max((GameRules:GetGameTime() - self:FindModifierByName("modifier_combat").combat_start_time), 1)) or 0
        else
            return 0
        end
    end

    function CDOTA_BaseNPC:GetHPS()
        if not IsServer() then
            return 0
        end
        if self:HasModifier("modifier_combat") then
            return (self:FindModifierByName("modifier_combat").heal / math.max((GameRules:GetGameTime() - self:FindModifierByName("modifier_combat").combat_start_time), 1)) or 0
        else
            return 0
        end
    end

    function CDOTA_BaseNPC:UpdateDHPS()
        -- print(self:GetDPS(), self:GetHPS())
        CustomNetTables:SetTableValue("DHPS", tostring(self:entindex()), 
        {
            DPS = self:GetDPS(),
            HPS = self:GetHPS(),
        })
    end

    function CDOTA_BaseNPC:GetAggroFactor()
        return Schools[self:GetUnitName()] or 0
    end

    function AbilityBehaviorFilter(iBehavior_group, iBehavior)
        if bit.band(iBehavior_group, iBehavior) == iBehavior then
            return true
        else
            return false
        end
    end

    original_add_modifier__function = CDOTA_BaseNPC.AddNewModifier
    function CDOTA_BaseNPC:AddNewModifier(hCaster, hAbility, sModifierName, params, bIgnoreResistance)
        if self:GetTeamNumber() == hCaster:GetTeamNumber() and bIgnoreResistance == nil then
            bIgnoreResistance = true
        elseif self:GetTeamNumber() ~= hCaster:GetTeamNumber() and bIgnoreResistance == nil then
            bIgnoreResistance = false
        end
    
        if bIgnoreResistance then
            return original_add_modifier__function(self, hCaster, hAbility, sModifierName, params)
        else
            if params.duration ~= 0 and type(params.duration) == "number" then
                params.duration = params.duration * ( 100 - Rounding(self:GetStatusResistance() * 100)) * 0.01
            end
            return original_add_modifier__function(self, hCaster, hAbility, sModifierName, params)
        end
    end

    function CDOTA_BaseNPC:AddStun(hCaster, hAbility, params, bIgnoreResistance)
        -- if self:HasModifier("modifier_stun_custom") then
        --     if params.duration < self:FindModifierByName("modifier_stun_custom"):GetRemainingTime() then
        --         params.duration = self:FindModifierByName("modifier_stun_custom"):GetRemainingTime()
        --     end
        -- end

        self:AddNewModifier(hCaster, hAbility, "modifier_stun_custom", params, bIgnoreResistance)
    end

    function CDOTA_BaseNPC:AddBezierMotion(hCaster, hAbility, params) --params={vStart,vEnd,fHeight) 
        params.vStart_x = (params.vStart or Vector(0, 0, 0)).x or 0
        params.vStart_y = (params.vStart or Vector(0, 0, 0)).y or 0
        params.vStart_z = (params.vStart or Vector(0, 0, 0)).z or 0
        params.vEnd_x = (params.vEnd or Vector(0, 0, 0)).x or 0
        params.vEnd_y = (params.vEnd or Vector(0, 0, 0)).y or 0
        params.vEnd_z = (params.vEnd or Vector(0, 0, 0)).z or 0
        self:AddNewModifier(hCaster, hAbility, "modifier_Bezier_motion", params)
    end

end
