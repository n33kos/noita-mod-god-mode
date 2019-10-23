dofile( "data/scripts/perks/perk.lua" )

function OnPlayerSpawned( player_entity ) -- this runs when player entity has been created
	local init_check_flag = "init_god_mode_done"
	if GameHasFlagRun( init_check_flag ) then
		return
	end
	GameAddFlagRun( init_check_flag )
	
	local inventory = nil
	local cape = nil
	local player_arm = nil
	
	local loadout_cape_color = 0xFFFFFFFF
	local loadout_cape_color_edge =  0xFFEEEEEE

	local player_child_entities = EntityGetAllChildren( player_entity )
	if ( player_child_entities ~= nil ) then
		for i,child_entity in ipairs( player_child_entities ) do
			local child_entity_name = EntityGetName( child_entity )
			
			if ( child_entity_name == "inventory_quick" ) then
				inventory = child_entity
			end
			
			if ( child_entity_name == "cape" ) then
				cape = child_entity
			end
			
			if ( child_entity_name == "arm_r" ) then
				player_arm = child_entity
			end
		end
	end
	
	-- set player sprite (since we change only one value, ComponentSetValue is fine)
	local player_sprite_component = EntityGetFirstComponent( player_entity, "SpriteComponent" )
	local player_sprite_file = "mods/god_mode/files/player.xml"
	ComponentSetValue( player_sprite_component, "image_file", player_sprite_file )
	
	-- set player arm sprite
	local player_arm_sprite_component = EntityGetFirstComponent( player_arm, "SpriteComponent" )
	local player_arm_sprite_file = "mods/god_mode/files/player_arm.xml"
	ComponentSetValue( player_arm_sprite_component, "image_file", player_arm_sprite_file )
	
	-- set player cape colour (since we're changing multiple variables, we'll use the edit_component() utility)
	edit_component( cape, "VerletPhysicsComponent", function(comp,vars) 
		vars.cloth_color = loadout_cape_color
		vars.cloth_color_edge = loadout_cape_color_edge
	end)

	-- Disable falling and material damage (redundant since the game effect seems to already do this)
	-- Also set ragdoll files
	edit_component( player_entity, "DamageModelComponent", function(comp,vars)
		vars.falling_damages="0"
		vars.materials_damage="0"
		vars.materials_that_damage=""
		vars.materials_how_much_damage=""
		vars.fire_probability_of_ignition="0"
		vars.ragdoll_filenames_file="mods/god_mode/files/ragdoll/filenames.txt"
	end)

	-- Infinite flight
	edit_component( player_entity, "CharacterDataComponent", function(comp,vars)
		vars.flying_needs_recharge="0"
	end)

	-- Move faster (For some reason this only works if you override the file. doing it this way breaks something)
	-- edit_component( player_entity, "CharacterPlatformingComponent", function(comp,vars)
	-- 	vars.run_velocity="300"
	-- 	vars.velocity_min_x="-100"
	-- 	vars.velocity_max_x="100"
	-- end)

	-- Set god effect
	LoadGameEffectEntityTo( player_entity, "mods/god_mode/files/effect_god.xml")

	local x, y = EntityGetTransform(player_entity)
	EntityLoad("mods/god_mode/files/pickup_emitter.xml", x, y)

	GamePrintImportant( "God Mode", "" )
end
