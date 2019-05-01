#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Oshroth"
#define PLUGIN_VERSION "1.2.0"

#define MAX_WEAPON_STRING 80
#define	MAX_WEAPON_SLOTS 6

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>

#pragma newdecls required

EngineVersion g_Game;

public Plugin myinfo = 
{
	name = "[SM] Unlimited Power", 
	author = PLUGIN_AUTHOR, 
	description = "All players start with a Taser", 
	version = PLUGIN_VERSION, 
	url = ""
};

ConVar cvarZeusActive, cvarZeusInfiniteAmmo, cvarTaserAmmo;
bool isZeusActive = true;
bool isInfiniteAmmoActive = false;
int taserAmmo = 1;

//bool hasHookedPlayers = false;

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if (g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");
	}
	CreateConVar("sm_unlimitedpower_version", PLUGIN_VERSION, 
		"Version of 'Unlimited Power'", FCVAR_SPONLY | FCVAR_NOTIFY | FCVAR_REPLICATED | FCVAR_DONTRECORD);
	cvarZeusActive = CreateConVar("sm_unlimitedpower_active", "1", "Everyone starts with Zeus Taser", _, true, 0.0, true, 1.0);
	cvarZeusInfiniteAmmo = CreateConVar("sm_unlimitedpower_infinite_ammo", "0", "Zeus never runs out of ammo(NYI)", _, true, 0.0, true, 1.0);
	cvarTaserAmmo = CreateConVar("sm_unlimitedpower_taser_ammo", "1", "Max taser ammo", _, true, 1.0, true, 254.0);
	
	isZeusActive = cvarZeusActive.BoolValue;
	isInfiniteAmmoActive = cvarZeusInfiniteAmmo.BoolValue;
	taserAmmo = cvarTaserAmmo.IntValue;
	
	cvarZeusActive.AddChangeHook(OnChangedZeusActive);
	cvarZeusInfiniteAmmo.AddChangeHook(OnChangedInfiniteAmmo);
	cvarTaserAmmo.AddChangeHook(OnChangedTaserAmmo);
	
	AutoExecConfig(true, "plugin_unlimited_power");
	
	HookEvent("player_spawn", OnPlayerSpawn);
}

public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!isZeusActive) {
		return Plugin_Continue;
	}
	// Get client from userid in event parameters 
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	// Make sure client is valid 
	if (client == 0) {
		return Plugin_Continue;
	}
	
	if (!IsClientInGame(client)) {
		return Plugin_Continue;
	}
	int teamIndex = GetClientTeam(client);
	if (IsPlayerAlive(client) && (teamIndex == CS_TEAM_CT || teamIndex == CS_TEAM_T)) {
		int taser = GivePlayerItem(client, "weapon_taser");
		if (taser != -1 && taserAmmo != 1) {
			SetEntProp(taser, Prop_Send, "m_iClip1", taserAmmo);
		}
		
	}
	
	return Plugin_Continue;
}

public void OnChangedZeusActive(ConVar convar, const char[] oldValue, const char[] newValue) {
	isZeusActive = cvarZeusActive.BoolValue;
}

public void OnChangedInfiniteAmmo(ConVar convar, const char[] oldValue, const char[] newValue) {
	isInfiniteAmmoActive = cvarZeusInfiniteAmmo.BoolValue;
}

public void OnChangedTaserAmmo(ConVar convar, const char[] oldValue, const char[] newValue) {
	taserAmmo = cvarTaserAmmo.IntValue;
}