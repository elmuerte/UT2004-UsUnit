/*******************************************************************************
    UsUnitReplicationInfo
    used by the UsUnitMutator to communicate between the test runner and user's
    GUI.

    Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

    UsUnit Testing Framework
    Copyright (C) 2005, Michiel "El Muerte" Hendriks

    This program is free software; you can redistribute and/or modify
    it under the terms of the Lesser Open Unreal Mod License.
    <!-- $Id: UsUnitReplicationInfo.uc,v 1.3 2005/06/24 16:28:58 elmuerte Exp $ -->
*******************************************************************************/

class UsUnitReplicationInfo extends ReplicationInfo;

var class<usugui_MainPage> MainPageClass;
var usugui_MainPage MainPage;

replication
{
    reliable if (Role == ROLE_Authority)
        OpenGUI;
}

/**
    Will be called right after it has been spawned by UsUnitMutator.
    ReadOnly is true when the user can only view
*/
function Initialize(bool ReadOnly)
{
}

simulated function OpenGUI()
{
    PlayerController(Owner).ClientOpenMenu(string(MainPageClass));
}

defaultproperties
{

}