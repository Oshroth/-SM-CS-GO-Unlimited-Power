#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Oshroth"
#define PLUGIN_VERSION "1.1"

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

ConVar cvarZeusActive, cvarZeusInfiniteAmmo;
bool isZeusActive = true;
bool isInfiniteAmmoActive = false;

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");	
	}
	
	cvarZeusActive = CreateConVar("sm_unlimited_power_active", "1", "Everyone starts with Zeus Taser");
	cvarZeusInfiniteAmmo = CreateConVar("sm_unlimited_power_infinite_ammo", "0", "Zeus never runs out of ammo");
	
	isZeusActive = cvarZeusActive.BoolValue;
	isInfiniteAmmoActive = cvarZeusInfiniteAmmo.BoolValue;
	
	cvarZeusActive.AddChangeHook(OnChangedZeusActive);
	cvarZeusInfiniteAmmo.AddChangeHook(OnChangedInfiniteAmmo);
	
	AutoExecConfig(true, "plugin_unlimited_power");
	
	HookEvent("player_spawn", OnPlayerSpawn);
}

public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{ 
	//LogAction(0, 0, "OnPlayerSpawn IsActive:%b", isZeusActive);
	if(!isZeusActive) {
		return Plugin_Continue;
	}
	// Get client from userid in event parameters 
	int client = GetClientOfUserId(event.GetInt("userid")); 
	
	// Make sure client is valid 
	if (client == 0) {
		//LogAction(0, 0, "OnPlayerSpawn Client not set");
		return Plugin_Continue;
	}
		
	if (!IsClientInGame(client)) {
		//LogAction(0, 0, "OnPlayerSpawn Client not in game");
		return Plugin_Continue;
	}
	int teamIndex = GetClientTeam(client);
	//LogAction(0, 0, "OnPlayerSpawn Client:%d Team:%d", client, teamIndex);
	if (IsPlayerAlive(client) && (teamIndex == CS_TEAM_CT || teamIndex == CS_TEAM_T)) { 
		//LogAction(0, 0, "OnPlayerSpawn Client:%d Give Weapon", client);
		GivePlayerItem(client, "weapon_taser"); 
	} 
	
	return Plugin_Continue; 
}

public void OnChangedZeusActive(ConVar convar, const char[] oldValue, const char[] newValue) {
	isZeusActive = cvarZeusActive.BoolValue;
	//LogAction(0, 0, "OnChangedZeusActive %b", cvarZeusActive.BoolValue);
}

public void OnChangedInfiniteAmmo(ConVar convar, const char[] oldValue, const char[] newValue) {
	isInfiniteAmmoActive = cvarZeusInfiniteAmmo.BoolValue;
	if (isInfiniteAmmoActive) {}
}