untyped
global function _BR_Init
global function SendTeamMessage
global function PlayDialogueToAllPlayers
global function PlayerHasBomb
global function SetPlayerBombCount
global bool IS_BR = false

global struct Match {
	bool bombHasBeenDefused
	bool hasSwitchedSides = false
	var bomb = null
	var zone = null
	var droppable_bomb = null
}

global Match round

void function _BR_Init() {
	IS_BR = true

	int ruleSet = GetConVarInt("br_rules")
	if (ruleSet != 0)
		throw "Rules sets different than 0 are not implemented yet."

	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, 10 )
	SetShouldUseRoundWinningKillReplay( true )
	SetRoundBased( true )
	SetSwitchSidesBased( true )
	SetRespawnsEnabled( ruleSet == 0 )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	AddCallback_GameStateEnter( eGameState.Prematch, SetupRound )
	SetTimeoutWinnerDecisionFunc( BombingRunDecideWinner )
	AddCallback_EntitiesDidLoad( SetupLevel )
	AddCallback_OnClientConnected( BombingRunInitPlayer )
}

// If no team planted bomb, no one wins.
int function BombingRunDecideWinner()
{
	return TEAM_UNASSIGNED
}

/**
 * Creates bombing zones for the current map, and makes dead players drop their bomb 
 * (if they carry any). 
 * This is called once at the beginning of the game.
 */
void function SetupLevel()
{
	round.zone = BombingZone("A", TEAM_IMC, Vector(992.031, -5351.97, -206), Vector(1567.97, -4200.03, -89.315))

	// terrorist drops the bomb when killed
	AddDeathCallback( "player", void function (entity player, var damageInfo) {
		if (PlayerHasBomb( player )) {
			SetPlayerBombCount (player, 0) // remove bomb from inventory
			round.droppable_bomb = DroppableBomb( player.GetOrigin() ) // spawn bomb on the ground

			// tell everyone he dropped the bomb
			int playerHandle = player.GetEncodedEHandle()
			foreach(player in GetPlayerArray())
			{
				Remote_CallFunction_NonReplay( player, "ServerCallback_AnnounceBombWasDropped", playerHandle )
				SetPlayerBombCount( player, 0 )
			}
		}
	})
}

/**
 * This is triggered at each round start; it will remove bombs eventually left from 
 * previous round, switch bombing zones teams on halftime, reset all players' bomb 
 * count to 0, and drop a bomb on the map if needed.
 */
void function SetupRound()
{
	round.bombHasBeenDefused = false
	if (round.bomb)
		round.bomb.Destroy()
	round.bomb = null

	if (HasSwitchedSides() && !round.hasSwitchedSides)
	{
		round.hasSwitchedSides = true
		// TODO do this for all zones
		round.zone.ToggleTeam()
	}

	// start looking for players who'd want to explode base
	round.zone.CheckForBombPlant()
	
	if (round.droppable_bomb)
		round.droppable_bomb.Destroy()
	round.droppable_bomb = DroppableBomb( <1268.39, -3820.55, -237.67> )

	// reset bomb numbers
	foreach(player in GetPlayerArray())
	{
		SetPlayerBombCount( player, 0 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_BombingRunInitBombIcon", round.droppable_bomb.bomb.GetEncodedEHandle() )
	}
}

/**
 * Sends a chat message to a whole team.
 */
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

// TODO call this for all zones
void function BombingRunInitPlayer( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_BombingRunUpdateZoneRui", round.zone.indicator.GetEncodedEHandle(), 0 )
}

/**
 * Plays a voiceline to all players; each message must be composed of one line 
 * for the team doing the action (e.g. "bomb planted, cool!"), and another line for
 * the other team (e.g. "bomb planted, defuse it!!")
 */
void function PlayDialogueToAllPlayers (int attacker_team, string attacker_message, string defender_message)
{
	foreach(player in GetPlayerArray()) 
	{
		PlayFactionDialogueToPlayer( player.GetTeam() == attacker_team ? attacker_message : defender_message, player )
	}
}

/**
 * Checks if a player currently holds the bomb.
 * Bombs counts are stored in net ints.
 */
bool function PlayerHasBomb( entity player )
{
	if (!IsValid( player ))
		return false
	if (!player.IsPlayer())
		return false

	return player.GetPlayerNetInt( "numSuperRodeoGrenades" ) > 0
}

/**
 * Sets bomb count for a given player.
 * Can be used to give or take bombs.
 */
void function SetPlayerBombCount ( entity player, int bombCount )
{
	player.SetPlayerNetInt( "numSuperRodeoGrenades", bombCount )
}