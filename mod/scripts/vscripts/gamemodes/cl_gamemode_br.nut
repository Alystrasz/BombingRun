global function Cl_BR_Init
global function ServerCallback_AnnounceBombPlanted
global function ServerCallback_AnnounceEnemyBaseNearby


void function Cl_BR_Init() {

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