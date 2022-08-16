-- Generated from template

_G.DodoWorld = DodoWorld or class({})
-- if CAddonTemplateGameMode == nil then
-- 	CAddonTemplateGameMode = class({})
-- end
require('GameConfig')
require('KeyValues')

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
	require('common.managers.combat_manager')
	require('common.managers.heal_manager')
	require('common.managers.attribute_manager')
	require('common.managers.vehicle_manager')
	Alert_manger = require('common.managers.alert_manager')
	Abilities_manager = require('common.managers.abilities_manager')
	AI_manager = require('ai.ai_manager')
	AI_manager:constructor()
	require('events.OnNpcSpawned')
	require('events.OnPlayerGainedLevel')
	require('events.OnPlayerPickHero')
	require('events.OnInventoryItemAdded')
	require('utils')
	require('lib.timers')
	require('heroes.label.schools')
	--require('ai.ai_manager')
	require('backpack.backpack_manager')
	require('abilities_required_lvl')
	require('filters.ItemAddedToInventoryFilter')
	require('filters.ExecuteOrderFilter')
	require('filters.DamageFilter')
	require('modifiers.Cmodifier')

	level_table = {[0] = 0}

	for lvl = 1, MAX_UNIT_LEVEL - 1 do
		level_table[lvl] = lvl * KeyValues.UnitLevels.level_factor + KeyValues.UnitLevels.other_param
	end

	-- for key, value in pairs(level_table) do
	-- 	print(key, value)
	-- end

	--自定义等级
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(level_table)

	--设定监听事件
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(DodoWorld,'OnNpcSpawned'),self)
	ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(DodoWorld,'OnPlayerGainedLevel'),self)
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(DodoWorld,'OnPlayerPickHero'),self)
	ListenToGameEvent('dota_inventory_item_added', Dynamic_Wrap(DodoWorld,'OnInventoryItemAdded'),self)
	
	--游戏性常数
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_DAMAGE, 1)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP, 0)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_DAMAGE, 1)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED, 0)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ARMOR, 0)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_DAMAGE, 0)
	GameRules:GetGameModeEntity():SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA, 0)
	GameRules:GetGameModeEntity():SetInnateMeleeDamageBlockAmount(0)--设置近战英雄自带格挡值为0
	GameRules:GetGameModeEntity():SetInnateMeleeDamageBlockPercent(0)--设置近战英雄自带格挡几率为0
	GameRules:GetGameModeEntity():SetInnateMeleeDamageBlockPerLevelAmount(0)--设置近战英雄自带格挡每级成长为0
	
	GameRules:GetGameModeEntity():SetSendToStashEnabled(false)--禁用储藏处
	GameRules:GetGameModeEntity():SetUnseenFogOfWarEnabled(true) -- 启用全黑迷雾

	--过滤器
	GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(self.ItemAddedToInventoryFilter, self)
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(self.ExecuteOrderFilter, self)
	GameRules:GetGameModeEntity():SetDamageFilter(self.DamageFilter, self)

	--初始化流派：默认0
	Abilities_manager:InitSchools()

	--临时初始化背包
	InitBackpack()

	--监听自定义游戏事件
	CustomGameEventManager:RegisterListener("ChangeRoleMastery", Dynamic_Wrap(Abilities_manager,'OnChangeRoleMastery'))
	CustomGameEventManager:RegisterListener("EquipItem", OnEquipItem)
	CustomGameEventManager:RegisterListener("UnEquipItem", OnUnEquipItem)

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