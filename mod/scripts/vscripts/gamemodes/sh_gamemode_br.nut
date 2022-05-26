global function BRMode_Init

global const GAMEMODE_BR = "br"

void function BRMode_Init() {
    AddCallback_OnCustomGamemodesInit( CreateGamemode )	
	AddCallback_OnRegisteringCustomNetworkVars( BRRegisterNetworkVars )
}

void function CreateGamemode() {
    GameMode_Create( GAMEMODE_BR )
    GameMode_SetName( GAMEMODE_BR, "#GAMEMODE_BR" )
    GameMode_SetDesc( GAMEMODE_BR, "#GAMEMODE_BR_DESC" )
    
    // No titans so use titan thing for batteries
	GameMode_AddScoreboardColumnData( GAMEMODE_BR, "#SCOREBOARD_PILOT_KILLS", PGS_PILOT_KILLS, 2)
	GameMode_AddScoreboardColumnData( GAMEMODE_BR, "Bombs planted", PGS_TITAN_KILLS, 2 )
    // Green because batteries are green.. idk
	GameMode_SetColor( GAMEMODE_BR, [56, 181, 34, 255] )

    // Clueless Surely this'll work
	GameMode_SetDefaultTimeLimits( GAMEMODE_BR, 3, 0 )
	GameMode_SetDefaultScoreLimits( GAMEMODE_BR, 5, 0 )
	GameMode_SetEvacEnabled( GAMEMODE_BR, false )
    
    // IDK what this is but it works
    GameMode_SetGameModeAnnouncement( GAMEMODE_BR, "gnrc_modeDesc" )

    AddPrivateMatchMode( GAMEMODE_BR )

    #if SERVER
    GameMode_AddServerInit( GAMEMODE_BR, _BR_Init )
    GameMode_SetPilotSpawnpointsRatingFunc( GAMEMODE_BR, RateSpawnpoints_Generic )
    #elseif CLIENT
    GameMode_AddClientInit( GAMEMODE_BR, Cl_BR_Init )
    #endif
}

void function BRRegisterNetworkVars()
{
	if ( GAMETYPE != GAMEMODE_BR )
		return

	Remote_RegisterFunction( "ServerCallback_AnnounceBombPlanted" )
    Remote_RegisterFunction( "ServerCallback_AnnounceEnemyBaseNearby" )
    Remote_RegisterFunction( "ServerCallback_BombingRunUpdateZoneRui" )
}