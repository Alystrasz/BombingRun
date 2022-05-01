untyped
global function _BR_Init
global function SendTeamMessage
global bool IS_BR = false

global struct Match {
	bool bombHasBeenDefused
	var bomb = null
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

	// instanciation test
	var zone = BombingZone("A", Vector(992.031, -5351.97, -206), Vector(1567.97, -4200.03, -89.315))
	zone.CheckForBombPlant()
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
