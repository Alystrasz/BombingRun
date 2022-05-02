global function Cl_BR_Init
global function ServerCallback_AnnounceBombPlanted
global function ServerCallback_AnnounceEnemyBaseNearby
global function ServerCallback_BombingRunUpdateZoneRui

struct {
	var zoneARui
	var zoneBRui
} file


void function Cl_BR_Init() {
	AddCallback_OnClientScriptInit( BombingRunCreateRui )
}

void function BombingRunCreateRui( entity player )
{
	file.zoneARui = CreateCockpitRui( $"ui/cp_hardpoint_marker.rpak", 200 )
	file.zoneBRui = CreateCockpitRui( $"ui/cp_hardpoint_marker.rpak", 200 )
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
