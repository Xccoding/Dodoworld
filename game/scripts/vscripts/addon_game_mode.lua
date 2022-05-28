-- Generated from template

_G.DodoWorld = DodoWorld or class({})
-- if CAddonTemplateGameMode == nil then
-- 	CAddonTemplateGameMode = class({})
-- end
require('GameConfig')

_G.UnitLevels = LoadKeyValues("scripts/npc/levels.txt")
_G.RoleAbilities = LoadKeyValues("scripts/npc/role_abilities.txt")

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	require('precache_assets')
	Precache_sounds( context )
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = DodoWorld()
	GameRules.AddonTemplate:InitGameMode()
end

function DodoWorld:InitGameMode()
	require('common.combat.managers.combat_manager')
	require('common.combat.managers.abilities_manager')
	require('events.OnNpcSpawned')
	require('events.OnPlayerGainedLevel')
	require('events.OnPlayerPickHero')
	require('utils')
	require('heroes.label.schools')
	require('ai.ai_manager')
	require('abilities_required_lvl')
	level_table = {[0] = 0}

	for lvl = 1, MAX_UNIT_LEVEL do
		level_table[lvl] = lvl * UnitLevels.level_factor + UnitLevels.other_param
	end

	-- for key, value in pairs(level_table) do
	-- 	print(key, value)
	-- end

	--自定义等级
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(level_table)

	--设定监听事件
	ListenToGameEvent('npc_spawned',Dynamic_Wrap(DodoWorld,'OnNpcSpawned'),self)
	ListenToGameEvent('dota_player_gained_level',Dynamic_Wrap(DodoWorld,'OnPlayerGainedLevel'),self)
	ListenToGameEvent('dota_player_pick_hero',Dynamic_Wrap(DodoWorld,'OnPlayerPickHero'),self)
	
	--游戏性测试
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_DAMAGE, 0.3)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP, 0)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_DAMAGE, 0.3)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED, 0)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ARMOR, 0)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_DAMAGE, 0.3)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA, 0)

	GameRules:GetGameModeEntity():SetSendToStashEnabled(false)--禁用中立装备储藏处

	--初始化流派：默认0
	InitSchools()

	--监听自定义游戏事件
	CustomGameEventManager:RegisterListener("ChangeRoleMastery", OnChangeRoleMastery)

	print( "DodoWorld is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
end

-- Evaluate the state of the game
function DodoWorld:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end