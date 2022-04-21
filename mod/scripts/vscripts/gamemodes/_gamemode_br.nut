untyped
global function _BR_Init
global bool IS_BR = false
struct {
	bool bombHasBeenDefused
	entity bomb = null
} round;

void function _BR_Init() {
	IS_BR = true

	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, 10 )
	SetShouldUseRoundWinningKillReplay( true )
	SetRoundBased( true )
	SetSwitchSidesBased( true )
	SetRespawnsEnabled( false )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	Riff_ForceSetEliminationMode( eEliminationMode.Pilots )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	AddCallback_GameStateEnter( eGameState.Prematch, SetupLevel )
	SetTimeoutWinnerDecisionFunc( BombingRunDecideWinner )
}

// If no team planted bomb, no one wins.
int function BombingRunDecideWinner()
{
	return TEAM_UNASSIGNED
}

void function SetupLevel() 
{
	round.bombHasBeenDefused = false
	if (round.bomb)
		round.bomb.Destroy()
	round.bomb = null
	thread CheckBombSite()
}

void function CheckBombSite()
{
	vector volumeMins = Vector(992.031, -5351.97, -206)
	vector volumeMaxs = Vector(1567.97, -4200.03, -89.315)
	table times = {}
    float currTime = Time()
	int bombPlantDelay = 3

	while(true)
	{
    	float currTime = Time()
		foreach(player in GetPlayerArray())
		{
			if (PointIsWithinBounds( player.GetOrigin(), volumeMins, volumeMaxs ) && player.UseButtonPressed())
			{
				if (currTime - times[player.GetPlayerName()] >= bombPlantDelay)
				{
					print(player.GetPlayerName() + " triggered entity action.");
					player.MovementEnable()
					SpawnBomb(player)
					return
				}
				player.MovementDisable()
				player.ConsumeDoubleJump()
			} else
			{
				times[player.GetPlayerName()] <- currTime
				player.MovementEnable()
			}
		}
		WaitFrame()
	}
}

function SpawnBomb(entity player)
{
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
	round.bomb = bomb

	SendTeamMessage( "Bomb has been planted by " + player.GetPlayerName() + ".", player.GetTeam() )

	thread StartExplosionCountdown(bomb, player)

	// set bomb as defusable
	bomb.SetUsable()
	bomb.SetUsableByGroup( "pilot" )
	bomb.SetUsePrompts( "Hold %use% to defuse bomb", "Hold %use% to defuse bomb" )
	thread CheckHoldState(bomb, 3)
}

/**
  * This allows to trigger some code if a player kept use button hold for a given 
  * time (in seconds).
  **/
function CheckHoldState(entity bomb, int delay)
{
	table times = {}
    float currTime = Time()
	vector origin = bomb.GetOrigin()

	while(GamePlayingOrSuddenDeath())
	{
    	float currTime = Time()
		foreach(player in GetPlayerArray())
		{
			if (player.GetPlayerName() in times && player.UseButtonPressed() && Distance(origin, player.GetOrigin()) < 80)
			{
				if (currTime - times[player.GetPlayerName()] >= delay)
				{
					round.bombHasBeenDefused = true
					bomb.UnsetUsable()
					SendTeamMessage( player.GetPlayerName() + " has defused the bomb.", player.GetTeam() )
					SetWinner(player.GetTeam())
					return
				}
				player.MovementDisable()
				player.ConsumeDoubleJump()
				var timeLeft = format("%.1f", (delay - (currTime - times[player.GetPlayerName()])).tofloat())
				bomb.SetUsePrompts( "Hold %use% to defuse bomb (" + timeLeft + "s)", "Hold %use% to defuse bomb (" + timeLeft + "s)" )
			} else
			{
				times[player.GetPlayerName()] <- currTime
				bomb.SetUsePrompts( "Hold %use% to defuse bomb", "Hold %use% to defuse bomb" )
				player.MovementEnable()
			}
		}
		WaitFrame()
	}
}

function StartExplosionCountdown(entity inflictor, entity player) 
{
	int duration = GetConVarInt("br_bomb_explosion_delay")
	vector origin = inflictor.GetOrigin()
	int step = (duration / 3).tointeger()
	int lowTickRateSoundDuration = step*2
	int lowTickRateDuration = 2
	int highTickRateSoundDuration = step
	int highTickRateDuration = 1

	for (int i=0; i<lowTickRateSoundDuration; i+=lowTickRateDuration) {
		if (round.bombHasBeenDefused) return;
		EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "ui_ingame_markedfordeath_countdowntomarked")
		wait lowTickRateDuration
	}

	for (int i=0; i<highTickRateSoundDuration; i+=highTickRateDuration) {
		if (round.bombHasBeenDefused) return;
		EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "ui_ingame_markedfordeath_countdowntoyouaremarked")
		wait highTickRateDuration
	}

	if (round.bombHasBeenDefused) return;

	// if it blows, team who planted it wins
	SetWinner (player.GetTeam() )
	thread TriggerExplosion(inflictor)
}


function TriggerExplosion(entity inflictor)
{
	vector origin = inflictor.GetOrigin()
	entity explosionOwner = inflictor
	int innerRadius = 0
	int outerRadius = 1000
	int normalDamage = 1000
	int heavyArmorDamage = 2000

	thread __CreateFxInternal( TITAN_NUCLEAR_CORE_FX_1P, null, "", origin, Vector(0,RandomInt(360),0), C_PLAYFX_SINGLE, null, 1, inflictor )
	thread __CreateFxInternal( TITAN_NUCLEAR_CORE_FX_3P, null, "", origin + Vector( 0, 0, -100 ), Vector(0,RandomInt(360),0), C_PLAYFX_SINGLE, null, 6, inflictor )
	
	CreateShake(inflictor.GetOrigin())
	EmitSoundAtPosition( TEAM_IMC, origin, "titan_nuclear_death_explode" )
	EmitSoundAtPosition( TEAM_MILITIA, origin, "titan_nuclear_death_explode" )

	RadiusDamage_DamageDef( damagedef_nuclear_core,
		origin,								// origin
		explosionOwner,						// owner
		inflictor,							// inflictor
		normalDamage,						// normal damage
		heavyArmorDamage,					// heavy armor damage
		innerRadius,						// inner radius
		outerRadius,						// outer radius
		0 )									// dist from attacker

	inflictor.Hide()
	inflictor.NotSolid()
	inflictor.UnsetUsable()
}

function SendTeamMessage (string message, int team)
{
	foreach(player in GetPlayerArray()) 
	{
		if (player.GetTeam() == team)
		{
			Chat_ServerPrivateMessage(player, message, false)
		}
	}
}
