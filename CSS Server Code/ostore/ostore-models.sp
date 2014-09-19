#include <sourcemod>
#include <sdktools>

new mikuModelIndex;

public Plugin:myinfo =
{
	name = "OStore models",
	author = "Hao",
	description = "OStore models",
	version = "1.0",
	url = ""
};

public OnPluginStart()
{
	RegConsoleCmd("miku", Command_Miku);
	RegConsoleCmd("beam", Command_Beam);
}

public Action:Command_Miku(client, args)
{
	SetEntityModel(client, "models/player/hhp227/miku/miku.mdl");
	PrintToChat(client, "* 你现在是 miku 了");
	return Plugin_Handled;
}

public Action:Command_Beam(client, args)
{
	TE_SetupBeamFollow(client, mikuModelIndex, 0, 2.0, 10.0, 10.0, 10, {255,255,0,255});
	TE_SendToAll();
	return Plugin_Handled;
}

public OnMapStart()
{
	mikuModelIndex = PrecacheModel("models/player/hhp227/miku/miku.mdl");
	
	// miku
	AddFileToDownloadsTable("models/player/hhp227/miku/miku.mdl");
	AddFileToDownloadsTable("models/player/hhp227/miku/miku.phy");
	AddFileToDownloadsTable("models/player/hhp227/miku/miku.vvd");
	AddFileToDownloadsTable("models/player/hhp227/miku/miku.dx80.vtx");
	AddFileToDownloadsTable("models/player/hhp227/miku/miku.dx90.vtx");
	AddFileToDownloadsTable("models/player/hhp227/miku/miku.sw.vtx");
	AddFileToDownloadsTable("models/player/hhp227/miku/miku.xbox.vtx");
	AddFileToDownloadsTable("materials/models/player/hhp227/miku/miku_xx_tx_head_01.vtf");
	AddFileToDownloadsTable("materials/models/player/hhp227/miku/miku_xx_tx_head_01.vmt");
	AddFileToDownloadsTable("materials/models/player/hhp227/miku/miku_xx_tx_body_01.vtf");
	AddFileToDownloadsTable("materials/models/player/hhp227/miku/miku_xx_tx_body_01.vmt");
}