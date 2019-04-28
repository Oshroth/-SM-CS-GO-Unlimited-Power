#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Oshroth"
#define PLUGIN_VERSION "1.2.0b2"

#define MAX_WEAPON_STRING 80

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

//bool hasHookedPlayers = false;

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");	
	}
	CreateConVar("sm_unlimitedpower_version", PLUGIN_VERSION, 
	"Version of 'Unlimited Power'", FCVAR_SPONLY | FCVAR_NOTIFY | FCVAR_REPLICATED | FCVAR_DONTRECORD);
	cvarZeusActive = CreateConVar("sm_unlimitedpower_active", "1", "Everyone starts with Zeus Taser", _, true, 0.0, true, 1.0);
	cvarZeusInfiniteAmmo = CreateConVar("sm_unlimitedpower_infinite_ammo", "0", "Zeus never runs out of ammo", _, true, 0.0, true, 1.0);
	
	isZeusActive = cvarZeusActive.BoolValue;
	isInfiniteAmmoActive = cvarZeusInfiniteAmmo.BoolValue;
	
	cvarZeusActive.AddChangeHook(OnChangedZeusActive);
	cvarZeusInfiniteAmmo.AddChangeHook(OnChangedInfiniteAmmo);
	
	AutoExecConfig(true, "plugin_unlimited_power");
	
	HookEvent("player_spawn", OnPlayerSpawn);
	//HookEvent("round_end", OnRoundEnd);
	//HookEvent("round_start", OnRoundStart);
	
	/*if (isInfiniteAmmoActive) {
		if (!hasHookedPlayers)
		{
			HookPlayers(true);
			
			hasHookedPlayers = true;
		}
	}*/
}

/*public void OnMapStart()
{
	CleanUpHooks();
}

public void OnMapEnd()
{
	CleanUpHooks();
}*/

public Action OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{ 
	if(!isZeusActive) {
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
		GivePlayerItem(client, "weapon_taser"); 
	} 
	
	return Plugin_Continue; 
}

/*public void OnClientPutInServer(int client)
{
	if (hasHookedPlayers)
	{
		SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
	}
}

public void OnClientDisconnect(int client)
{
	if(IsClientInGame(client))
	{
		if (hasHookedPlayers)
		{
			SDKUnhook(client, SDKHook_WeaponDrop, OnWeaponDrop);
		}
	}
}*/

/*public Action OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	LogMessage("OnRoundStart");
	PrintToChatAll("Event_RoundStart");
		
	return Plugin_Continue;
}

public Action OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	LogMessage("OnRoundEnd");
	PrintToChatAll("Event_RoundEnd");
	
	//CheckZeusRoundStatus();
	
	return Plugin_Continue;
}*/

/*void CheckZeusRoundStatus()
{
	if (isInfiniteAmmoActive) {
		if (!hasHookedPlayers) {
			HookPlayers(true);
			hasHookedPlayers = true;
		}
	} else {
		if (hasHookedPlayers) {
			HookPlayers(false);
			hasHookedPlayers = false;
		}
	}
}*/
public Action CS_OnCSWeaponDrop(int client, int weapon) {
	PrintToChat(client, "OnWeaponDrop");
	if(!(isZeusActive && isInfiniteAmmoActive)) {
		return Plugin_Continue;
	}
	
	if (!IsValidEntity(weapon))
	{
		return Plugin_Continue;
	}
	
	char sWeapon[MAX_WEAPON_STRING];
	PrintToChat(client, "Dropping Weapon");
	GetEntityClassname(weapon, sWeapon, sizeof(sWeapon));
	
	if (StrEqual(sWeapon, "weapon_taser", false))
	{
		PrintToChat(client, "Weapon is Taser");
		AcceptEntityInput(weapon, "kill");
	}
	
	return Plugin_Continue;
}

/*void CleanUpHooks() {
	PrintToChatAll("Clean Up Hooks");
	if (hasHookedPlayers) {
		for (int i = 1; i <= MaxClients; i++) {
			if (IsClientInGame(i)) {
				SDKUnhook(i, SDKHook_WeaponDrop, OnWeaponDrop);
			}
		}
	}
	hasHookedPlayers = false;
}*/

/*void HookPlayers(bool mode)
{
	PrintToChatAll("Hook Players %d", mode);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (mode)
			{
				SDKHook(i, SDKHook_WeaponDrop, OnWeaponDrop);
			}
			else
			{
				SDKUnhook(i, SDKHook_WeaponDrop, OnWeaponDrop);
			}
		}
	}
}*/

/*void ClearTimer(Handle timer)
{
	if (timer != INVALID_HANDLE)
	{
		KillTimer(timer);
		timer = INVALID_HANDLE;
	}
}*/

public void OnChangedZeusActive(ConVar convar, const char[] oldValue, const char[] newValue) {
	isZeusActive = cvarZeusActive.BoolValue;
}

public void OnChangedInfiniteAmmo(ConVar convar, const char[] oldValue, const char[] newValue) {
	isInfiniteAmmoActive = cvarZeusInfiniteAmmo.BoolValue;
	/*if (isInfiniteAmmoActive) {
		if (!hasHookedPlayers)
		{
			HookPlayers(true);
			
			hasHookedPlayers = true;
		}
	} else {
		HookPlayers(false);
		hasHookedPlayers = false;
	}*/
}