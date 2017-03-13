/*  SM BullFightmod
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#pragma semicolon 1
#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdktools_sound>
#include <sdkhooks>


#define PLUGIN_VERSION "v3.0"


new Handle:sm_bf_noblock_enable		 = INVALID_HANDLE;
new Handle:sm_bullfightmod_enable;

new bool:sonidosi[MAXPLAYERS+1] = true;

new g_offsCollisionGroup = -1;

public Plugin:myinfo =
{
	name = "SM BullFightmod",
	author = "Franc1sco Steam: franug",
	description = "Original Mod of bullfighting for CSS",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/franug"
};

public OnPluginStart()
{
	CreateConVar("sm_bullfightmod", PLUGIN_VERSION, "version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	sm_bullfightmod_enable = CreateConVar("sm_bullfightmod_enable", "1", "Enables/disables all features of the plugin.", FCVAR_NONE, true, 0.0, true, 1.0);
	sm_bf_noblock_enable = CreateConVar("sm_bf_noblock_enable", "1", "Enable or disable integrated removing of player vs player collisions (noblock): 0 - disable, 1 - enable");

	g_offsCollisionGroup = FindSendPropOffs("CBaseEntity", "m_CollisionGroup");

        //RegConsoleCmd("sm_reglas", DOMenuBF);
        RegConsoleCmd("sm_rules", DOMenuBF);
        RegConsoleCmd("sm_mugir", Mugido);

        RegConsoleCmd("sm_torero", ToreroS);

	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
	HookEvent("round_start", Event_RoundStart);
}

public OnConfigsExecuted()
{
        AddFileToDownloadsTable("sound/toros/torero.mp3");
	PrecacheSound( "toros/torero.mp3", true);

        AddFileToDownloadsTable("sound/toros/pasodoble_dance.mp3");
	PrecacheSound( "toros/pasodoble_dance.mp3", true);

        AddFileToDownloadsTable("sound/toros/mugido1.mp3");
	PrecacheSound( "toros/mugido1.mp3", true);

        AddFileToDownloadsTable("sound/toros/mugido2.mp3");
	PrecacheSound( "toros/mugido2.mp3", true);

        AddFileToDownloadsTable("sound/toros/mugido3.mp3");
	PrecacheSound( "toros/mugido3.mp3", true);
}

public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
  if (GetConVarInt(sm_bullfightmod_enable) == 1)
  {
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) != 1)
	{

	        if (GetConVarInt(sm_bf_noblock_enable) == 1)
		       UnblockEntity(client);


		new wepIdx;

		// strip all weapons
		for (new s = 0; s < 4; s++)
		{
			if ((wepIdx = GetPlayerWeaponSlot(client, s)) != -1)
			{
				RemovePlayerItem(client, wepIdx);
				RemoveEdict(wepIdx);
			}
		}

		// if player == T
		if (GetClientTeam(client) == 2)
		{
			//GivePlayerItem(client, "weapon_knife");
	                SetEntityGravity(client, 4.0);
	                SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.1);
		}
		//if player == CT
		else if (GetClientTeam(client) == 3)
		{
		           GivePlayerItem(client, "weapon_knife");
	                   SetEntityGravity(client, 1.0);
	                   SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		}
	}
  }
}

//BlockEntity(client)
//{
//	SetEntData(client, g_offsCollisionGroup, 5, 4, true);
//}

UnblockEntity(client)
{
	SetEntData(client, g_offsCollisionGroup, 2, 4, true);
}

public OnClientPutInServer(client)
{
  if (GetConVarInt(sm_bullfightmod_enable) == 1)
  {
   SDKHook(client, SDKHook_OnTakeDamage, OnCuernoDamage);
   SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
  }
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
  if (GetConVarInt(sm_bullfightmod_enable) == 1)
  {
        //EmitSoundToAll("toros/torero.mp3");
        SonidoT();

        //PrintToChatAll("\x03Escribe \x04!reglas \x03en el chat para leer las reglas de este mod."); // español
        //PrintToChatAll("\x03Escribe \x04!torero \x03para desactivarte el sonido ambiente."); // español

        PrintToChatAll("\x03Type \x04!rules \x03for show the rules of this mod."); //english
        PrintToChatAll("\x03Type \x04!torero \x03for disable/enable the ambient sound."); // english
  }
}

public Action:SonidoT()
{
      new number = GetRandomInt(1, 2);

      for (new i = 1; i < GetMaxClients(); i++)
      {
	if (IsValidClient(i))
	{
            if(sonidosi[i])
            {
               switch (number)
               {
			case 1:
			{
                            EmitSoundToClient(i, "toros/torero.mp3");
			}
			case 2:
			{
                            EmitSoundToClient(i, "toros/pasodoble_dance.mp3");
			}
                }
            }
        }
      }
}

public Action:DOMenuBF(client,args)
{
  if (GetConVarInt(sm_bullfightmod_enable) == 1)
  {
    DID(client);
  }
}

public Action:DID(clientId) 
{
    new Handle:menu = CreateMenu(DIDMenuHandler);
    SetMenuTitle(menu, "BULLFIGHTMOD");
    AddMenuItem(menu, "option1", "Reglas de los toros (bullfighting rules)");
    AddMenuItem(menu, "option2", "Reglas de los toreros (bullfighters rules)");
    SetMenuExitButton(menu, true);
    DisplayMenu(menu, clientId, MENU_TIME_FOREVER);
    
    
    return Plugin_Handled;
}

public DIDMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
    if ( action == MenuAction_Select ) 
    {
        new String:info[32];
        
        GetMenuItem(menu, itemNum, info, sizeof(info));
        
        if ( strcmp(info,"option1") == 0 ) 
        {
            
            {
                DID1(client);

            }
            
        }
        
        else if ( strcmp(info,"option2") == 0 ) 
        {
            {
                DID2(client);
            }
            
        }
       
    }
}

public Action:DID1(clientId) 
{
    new Handle:menu = CreateMenu(DIDMenuHandler1);
    SetMenuTitle(menu, "REGLAS DE LOS TOROS");
    AddMenuItem(menu, "option1", "No entrar a zonas restringidas (not to enter restricted areas)");
    AddMenuItem(menu, "option2", "No girar como una peonza (not spin like a top)");
    SetMenuExitButton(menu, true);
    DisplayMenu(menu, clientId, MENU_TIME_FOREVER);
    
    
    return Plugin_Handled;
}

public DIDMenuHandler1(Handle:menu, MenuAction:action, client, itemNum) 
{
    if ( action == MenuAction_Select ) 
    {
        new String:info[32];
        
        GetMenuItem(menu, itemNum, info, sizeof(info));
        
       
        if ( strcmp(info,"option1") == 0 ) 
        {
            {
                PrintToChat(client, "\x04No entrar a zonas restringidas (not to enter restricted areas)");
                DID1(client);
            }
            
        }

        else if ( strcmp(info,"option2") == 0 ) 
        {
            {
                PrintToChat(client, "\x04No girar como una peonza (not spin like a top)");
                DID1(client);
            }
            
        }

    }
}

public Action:DID2(clientId) 
{
    new Handle:menu = CreateMenu(DIDMenuHandler2);
    SetMenuTitle(menu, "REGLAS DE LOS TOREROS");
    AddMenuItem(menu, "option1", "No campear en zonas restringidas al toro (No camping in restricted areas of the bull)");
    AddMenuItem(menu, "option2", "Dejar salir al toro (Letting off the bull)");
    SetMenuExitButton(menu, true);
    DisplayMenu(menu, clientId, MENU_TIME_FOREVER);
    
    
    return Plugin_Handled;
}

public DIDMenuHandler2(Handle:menu, MenuAction:action, client, itemNum) 
{
    if ( action == MenuAction_Select ) 
    {
        new String:info[32];
        
        GetMenuItem(menu, itemNum, info, sizeof(info));
        
        if ( strcmp(info,"option1") == 0 ) 
        {
            
            {
                PrintToChat(client, "\x04No campear en zonas restringidas al toro (No camping in restricted areas of the bull)");
                DID2(client);

            }
            
        }
        
        else if ( strcmp(info,"option2") == 0 ) 
        {
            {
                PrintToChat(client, "\x04Dejar salir al toro (Letting off the bull)");
                DID2(client);
            }
            
        }
       
    }
}

public OnClientPostAdminCheck(client)
{
  if (GetConVarInt(sm_bullfightmod_enable) == 1)
  {
        DID(client);
        //PrintToChat(client, "\x03Servidor con \x04BullfightMod");
        PrintToChat(client, "\x03Server with  \x04SM BullfightMod");
        //PrintToChat(client, "\x03Escribe \x04!reglas \x03en el chat para leer las reglas de este mod.");
        sonidosi[client] = true;
  }
}


public IsValidClient( client ) 
{ 
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
        return false; 
     
    return true; 
}

public Action:OnCuernoDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{

    if (GetClientTeam(victim) == 2)
    {
      if(damagetype == DMG_GENERIC || damagetype == DMG_FALL || damagetype == DMG_BURN)
      {
            if(!attacker || !IsValidClient(attacker))
            {
               return Plugin_Handled;
            }
      }
    }

    if(!attacker || !IsValidClient(attacker))
        return Plugin_Continue;


    if (GetClientTeam(attacker) == 2)
    {
          if (GetClientTeam(victim) == 3)
          {
//               PrintToChat(attacker, "\x04No usar armas (do not use guns)");
               return Plugin_Handled;
          }
    }
    else if (GetClientTeam(attacker) == 3)
    {
          if (GetClientTeam(victim) == 2)
          {
               	new number = GetRandomInt(1, 3);
		switch (number)
		{
			case 1:
			{
			   new Float:pos[3];
			   GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
			   EmitSoundToAll("toros/mugido1.mp3", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
			case 2:
			{
			   new Float:pos[3];
			   GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
			   EmitSoundToAll("toros/mugido2.mp3", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
			case 3:
			{
			   new Float:pos[3];
			   GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
			   EmitSoundToAll("toros/mugido3.mp3", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
                }

          }
    }
    return Plugin_Continue;
}


public Action:Mugido(client,args)
{
  if (GetConVarInt(sm_bullfightmod_enable) == 1)
  {
        if (GetClientTeam(client) == 2)
        {
                new number = GetRandomInt(1, 3);
		switch (number)
		{
			case 1:
			{
			   new Float:pos[3];
			   GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
			   EmitSoundToAll("toros/mugido1.mp3", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
			case 2:
			{
			   new Float:pos[3];
			   GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
			   EmitSoundToAll("toros/mugido2.mp3", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
			case 3:
			{
			   new Float:pos[3];
			   GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
			   EmitSoundToAll("toros/mugido3.mp3", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
                }
        }
        else if (GetClientTeam(client) == 3)
        {
           PrintToChat(client, "Este comando es solo para toros (command only for T)");
        }
  }
}

public Action:ToreroS(client,args)
{
  if (sonidosi[client])
  {
    sonidosi[client] = false;
    //PrintToChat(client, "Sonido ambiente desactivado");
    PrintToChat(client, "Ambient sound disable");
  }
  else if (!sonidosi[client])
  {
    sonidosi[client] = true;
    //PrintToChat(client, "Sonido ambiente activado");
    PrintToChat(client, "Ambient sound enable");
  }
}

//
//               damage = 0.0;
//               return Plugin_Changed;

public Action:OnWeaponCanUse(client, weapon)
{
  if (GetClientTeam(client) == 2)
  {
           // block switching to weapon other than knife
      decl String:sClassname[32];
      GetEdictClassname(weapon, sClassname, sizeof(sClassname));
      if (!StrEqual(sClassname, "weapon_knife"))
          return Plugin_Handled;
  }
  return Plugin_Continue;
}