global function Cl_BR_Init
global function ServerCallback_AnnounceBombPlanted
global function ServerCallback_AnnounceBombWasDropped
global function ServerCallback_AnnounceEnemyBaseNearby
global function ServerCallback_BombingRunInitBombIcon
global function ServerCallback_BombingRunUpdateZoneRui
global function ServerCallback_BombCanBePlantedHint
global function ServerCallback_BombCanBePlantedHintHide
global function ServerCallback_YouHaveTheBomb
global function UpdateBombsCount

struct {
	var zoneARui
	var zoneBRui
	var bombRui
	var bombIconRui
} file


void function Cl_BR_Init() {
	AddCallback_OnClientScriptInit( BombingRunCreateRui )
}

void function BombingRunCreateRui( entity player )
{
	file.zoneARui = CreateCockpitRui( $"ui/cp_hardpoint_marker.rpak", 200 )
	file.zoneBRui = CreateCockpitRui( $"ui/cp_hardpoint_marker.rpak", 200 )
	file.bombRui = CreateCockpitRui( $"ui/super_rodeo_hud.rpak" )
}

void function ServerCallback_AnnounceBombPlanted()
{	
	AnnouncementData announcement = Announcement_Create( "#GAMEMODE_BR_BOMB_PLANTED_TITLE" )
	Announcement_SetSubText( announcement, "#GAMEMODE_BR_BOMB_PLANTED_TEXT" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}

void function ServerCallback_AnnounceBombWasDropped( int playerHandle )
{
	entity player = GetEntityFromEncodedEHandle( playerHandle )
	if (!IsValid(player))
		return

	AnnouncementData announcement = Announcement_Create( "#GAMEMODE_BR_BOMB_DROPPED_TITLE" )
	Announcement_SetSubText( announcement, player.GetPlayerName() + " " + Localize( "#GAMEMODE_BR_BOMB_DROPPED_TEXT" ))
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 )
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}

void function ServerCallback_AnnounceEnemyBaseNearby()
{	
	AnnouncementData announcement = Announcement_Create( "#GAMEMODE_BR_BASE_NEARBY_TITLE" )
	Announcement_SetSubText( announcement, "#GAMEMODE_BR_BASE_NEARBY_TEXT" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 ) //Be higher priority than Titanfall ready indicator etc
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}

void function ServerCallback_YouHaveTheBomb()
{	
	AnnouncementData announcement = Announcement_Create( "#GAMEMODE_BR_YOU_HAVE_BOMB_TITLE" )
	Announcement_SetSubText( announcement, "#GAMEMODE_BR_YOU_HAVE_BOMB_TEXT" )
	Announcement_SetTitleColor( announcement, <1,0,0> )
	Announcement_SetPurge( announcement, true )
	Announcement_SetPriority( announcement, 200 )
	Announcement_SetSoundAlias( announcement, SFX_HUD_ANNOUNCE_QUICK )
	Announcement_SetStyle( announcement, ANNOUNCEMENT_STYLE_QUICK )
	AnnouncementFromClass( GetLocalViewPlayer(), announcement )
}

void function ServerCallback_BombingRunUpdateZoneRui( int zoneHandle, int id )
{
	entity zone = GetEntityFromEncodedEHandle( zoneHandle )
	if (!IsValid(zone))
		return

	var rui
	if ( id == 0 )
		rui = file.zoneARui
	else 
		rui = file.zoneBRui

	RuiSetInt( rui, "hardpointId", id )
	RuiTrackFloat3( rui, "pos", zone, RUI_TRACK_OVERHEAD_FOLLOW )
	RuiSetInt( rui, "viewerTeam", GetLocalClientPlayer().GetTeam() )
	RuiTrackInt( rui, "hardpointTeamRelation", zone, RUI_TRACK_TEAM_RELATION_VIEWPLAYER )
	RuiSetBool( rui, "isVisible", true )
}

void function ServerCallback_BombingRunInitBombIcon( int bombHandle )
{
	entity bomb = GetEntityFromEncodedEHandle( bombHandle )
	if (!IsValid(bomb))
		return

	if (file.bombIconRui)
	{
		RuiDestroyIfAlive( file.bombIconRui )
	}

	var rui = CreateCockpitRui( $"ui/fra_battery_icon.rpak" )
	RuiTrackFloat3( rui, "pos", bomb, RUI_TRACK_OVERHEAD_FOLLOW )
	RuiSetImage( rui, "imageName", $"rui/hud/gametype_icons/last_titan_standing/bomb_neutral" )
	RuiSetBool( rui, "isVisible", true )

	file.bombIconRui = rui

	thread BombIconThink( bomb );
}

void function BombIconThink (entity bomb)
{
	string ownerName = ""
	var rui = file.bombIconRui

	OnThreadEnd(
		function() : ( rui )
		{
			RuiDestroyIfAlive( rui );
		}
	)

	bool found = false;
	while( true )
	{
		if (!IsValid(bomb)) return;
		entity owner = bomb.GetOwner()

		if (!found && IsValid( owner ))
		{
			// Bomb carrier does not need to see bomb icon
			if ( owner == GetLocalViewPlayer() )
				return;

			found = true;
			owner.EndSignal( "OnDeath" )
			RuiSetImage( 
				file.bombIconRui, 
				"imageName", 
				owner.GetTeam() == GetLocalViewPlayer().GetTeam() 
					? $"rui/hud/gametype_icons/raid/bomb_icon_friendly"
					: $"rui/hud/gametype_icons/raid/bomb_icon_enemy" 
			)
		}

		wait 0.2
	}
}

void function UpdateBombsCount( entity player, int old, int new, bool actuallyChanged )
{
	if ( IsLobby() )
		return
	if ( player != GetLocalViewPlayer() )
		return

	RuiSetInt( file.bombRui, "batteryCount", new )
}

void function ServerCallback_BombCanBePlantedHint()
{
	AddPlayerHint( 90.0, 0.5, $"", "Hold %use% to plant the bomb." )
}

void function ServerCallback_BombCanBePlantedHintHide()
{
	HidePlayerHint( "Hold %use% to plant the bomb." )
}
