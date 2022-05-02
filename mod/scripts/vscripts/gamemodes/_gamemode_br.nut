untyped
global function _BR_Init
global function SendTeamMessage
global function PlayDialogueToAllPlayers
global bool IS_BR = false

global struct Match {
	bool bombHasBeenDefused
	var bomb = null
	var zone = null
}

global Match round

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

void function SetupLevel()
{
	round.zone = BombingZone("A", TEAM_IMC, Vector(992.031, -5351.97, -206), Vector(1567.97, -4200.03, -89.315))
}

void function SetupRound()
{
	round.bombHasBeenDefused = false
	if (round.bomb)
		round.bomb.Destroy()
	round.bomb = null

	round.zone.CheckForBombPlant()
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

// TODO call this for all zones
void function BombingRunInitPlayer( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_BombingRunUpdateZoneRui", round.zone.indicator.GetEncodedEHandle(), 0 )
}

void function PlayDialogueToAllPlayers (int attacker_team, string attacker_message, string defender_message)
{
	foreach(player in GetPlayerArray()) 
	{
		PlayFactionDialogueToPlayer( player.GetTeam() == attacker_team ? attacker_message : defender_message, player )
	}
}