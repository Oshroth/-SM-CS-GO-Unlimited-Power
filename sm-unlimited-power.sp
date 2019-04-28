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

ConVar sm_zeus_active, sm_zeus_infinite_ammo;
bool IsZeusActive = true;
bool IsInfiniteAmmoActive = false;

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");	
	}
	
	sm_zeus_active = CreateConVar("sm_zeus_active", "1", "Give Zeus tazers to everyone");
	sm_zeus_infinite_ammo = CreateConVar("sm_zeus_infinite_ammo", "0", "Zeus never runs out of ammo (NYI)");
	
	sm_zeus_active.AddChangeHook(OnChangedZeusActive);
	sm_zeus_infinite_ammo.AddChangeHook(OnChangedInfiniteAmmo);
	
	AutoExecConfig(true, "plugin_givezeus");
	
	HookEvent("player_spawn", OnPlayerSpawn);
}

public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{ 
	//LogAction(0, 0, "OnPlayerSpawn IsActive:%b", IsZeusActive);
	if(!IsZeusActive) {
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

public void OnConfigsExecuted() {
	//LogAction(0, 0, "OnConfigExecuted ZeusActive %b", sm_zeus_active.BoolValue);
	IsZeusActive = sm_zeus_active.BoolValue;
	IsInfiniteAmmoActive = sm_zeus_infinite_ammo.BoolValue;
}

public void OnChangedZeusActive(ConVar convar, const char[] oldValue, const char[] newValue) {
	IsZeusActive = sm_zeus_active.BoolValue;
	//LogAction(0, 0, "OnChangedZeusActive %b", sm_zeus_active.BoolValue);
}

public void OnChangedInfiniteAmmo(ConVar convar, const char[] oldValue, const char[] newValue) {
	IsInfiniteAmmoActive = sm_zeus_infinite_ammo.BoolValue;
	if (IsInfiniteAmmoActive) {}
}