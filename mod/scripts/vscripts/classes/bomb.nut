untyped
global function InitBombClass
global var Bomb

void function InitBombClass()
{
    class Bomb {
		origin = null
		terrorist = null
		bomb = null
        delay = 0

		constructor (entity player)
		{
			this.terrorist = player
			this.origin = player.GetOrigin()
            this.delay = 3

			foreach(entity online in GetPlayerArray()) {
                Remote_CallFunction_NonReplay(online, "ServerCallback_AnnounceBombPlanted")
            }
            entity bomb = CreateEntity( "prop_dynamic" )
            bomb.SetValueForModelKey($"models/weapons/at_satchel_charge/at_satchel_charge.mdl")
            bomb.SetOrigin( player.GetOrigin() )
            vector pAngles = player.GetAngles()
            bomb.SetAngles( < -90, -1*pAngles.y, pAngles.z> )
            bomb.kv.solid = SOLID_VPHYSICS
            DispatchSpawn( bomb )
            this.bomb = bomb

            SendTeamMessage( "Bomb has been planted by " + player.GetPlayerName() + ".", player.GetTeam() )

            thread this._StartExplosionCountdown()

            // set bomb as defusable
            bomb.SetUsable()
            bomb.SetUsableByGroup( "pilot" )
            bomb.SetUsePrompts( "Hold %use% to defuse bomb", "Hold %use% to defuse bomb" )
            thread this._CheckHoldState()
		}

		/**
		  * This allows to trigger some code if a player kept use button hold for a given 
		  * time (in seconds).
		  **/
		function _CheckHoldState()
		{
			table times = {}
			float currTime = Time()
			vector origin = expect entity(this.bomb).GetOrigin()

			while(GamePlayingOrSuddenDeath())
			{
				float currTime = Time()
				foreach(player in GetPlayerArray())
				{
					if (player.GetPlayerName() in times && player.UseButtonPressed() && Distance(origin, player.GetOrigin()) < 80)
					{
						if (currTime - times[player.GetPlayerName()] >= this.delay)
						{
							round.bombHasBeenDefused = true
							this.bomb.UnsetUsable()
							SendTeamMessage( player.GetPlayerName() + " has defused the bomb.", player.GetTeam() )
							SetWinner(player.GetTeam())
							return
						}
						player.MovementDisable()
						player.ConsumeDoubleJump()
						var timeLeft = format("%.1f", (this.delay - (currTime - times[player.GetPlayerName()])).tofloat())
						this.bomb.SetUsePrompts( "Hold %use% to defuse bomb (" + timeLeft + "s)", "Hold %use% to defuse bomb (" + timeLeft + "s)" )
					} else
					{
						times[player.GetPlayerName()] <- currTime
						this.bomb.SetUsePrompts( "#GAMEMODE_BR_BOMB_DEFUSE_PROMPT", "#GAMEMODE_BR_BOMB_DEFUSE_PROMPT" )
						player.MovementEnable()
					}
				}
				WaitFrame()
			}
		}

		function _LightBlink(vector pos)
		{
			entity light = CreateLightSprite (pos, <0,0,0>, "255 255 255", 1)
			WaitFrame()
			light.Destroy()
		}

		function _StartExplosionCountdown() 
		{
			int duration = GetConVarInt("br_bomb_explosion_delay")
			vector origin = expect entity(this.bomb).GetOrigin()
			int step = (duration / 3).tointeger()
			int lowTickRateSoundDuration = step*2
			int lowTickRateDuration = 2
			int highTickRateSoundDuration = step
			int highTickRateDuration = 1

			for (int i=0; i<lowTickRateSoundDuration; i+=lowTickRateDuration) {
				if (round.bombHasBeenDefused) return;
				EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "ui_ingame_markedfordeath_countdowntomarked")
				thread this._LightBlink(origin)
				wait lowTickRateDuration
			}

			for (int i=0; i<highTickRateSoundDuration; i+=highTickRateDuration) {
				if (round.bombHasBeenDefused) return;
				EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "ui_ingame_markedfordeath_countdowntoyouaremarked")
				thread this._LightBlink(origin)
				wait highTickRateDuration
			}

			if (round.bombHasBeenDefused) return;

			// if it blows, team who planted it wins
			SetWinner ( expect entity(this.terrorist).GetTeam() )
			thread this._TriggerExplosion()
		}

		function _TriggerExplosion()
		{
			int innerRadius = 0
			int outerRadius = 1000
			int normalDamage = 1000
			int heavyArmorDamage = 2000

			thread __CreateFxInternal( TITAN_NUCLEAR_CORE_FX_1P, null, "", expect vector(this.origin), Vector(0,RandomInt(360),0), C_PLAYFX_SINGLE, null, 1, expect entity(this.terrorist) )
			thread __CreateFxInternal( TITAN_NUCLEAR_CORE_FX_3P, null, "", expect vector(this.origin + Vector( 0, 0, -100 )), Vector(0,RandomInt(360),0), C_PLAYFX_SINGLE, null, 6, expect entity(this.terrorist) )
			
			CreateShake(expect entity(this.bomb).GetOrigin())
			EmitSoundAtPosition( TEAM_IMC, expect vector(this.origin), "titan_nuclear_death_explode" )
			EmitSoundAtPosition( TEAM_MILITIA, expect vector(this.origin), "titan_nuclear_death_explode" )

			RadiusDamage_DamageDef( damagedef_nuclear_core,
				this.origin,						// origin
				this.terrorist,						// owner
				this.bomb,							// inflictor
				normalDamage,						// normal damage
				heavyArmorDamage,					// heavy armor damage
				innerRadius,						// inner radius
				outerRadius,						// outer radius
				0 )									// dist from attacker

			this.bomb.Hide()
			this.bomb.NotSolid()
			this.bomb.UnsetUsable()
		}
	}
}
