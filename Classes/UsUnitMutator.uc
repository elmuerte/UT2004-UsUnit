/*******************************************************************************
    UsUnitMutator
<p>
    Mutator to start the test runner. It comes with a GUI. Start it with the
    console command: `mutate usunit`
</p>
<p>
    Written by: Michiel "El Muerte" Hendriks &lt;elmuerte@drunksnipers.com&gt;
</p>
<p>
    UsUnit Testing Framework -
    Copyright (C) 2005, Michiel "El Muerte" Hendriks
</p>

    This program is free software; you can redistribute and/or modify
    it under the terms of the Lesser Open Unreal Mod License.
    <!-- $Id: UsUnitMutator.uc,v 1.11 2005/09/23 09:23:41 elmuerte Exp $ -->
*******************************************************************************/

class UsUnitMutator extends Mutator;

//TODO: limit to one user

/** replication info class to be used to handle the communication */
var class<UsUnitReplicationInfo> ReplicationInfoClass;

// the user that controlls the testing, others can only view
var protected PlayerController ActiveUser;

function Mutate(string MutateString, PlayerController Sender)
{
    if (MutateString ~= "usunit")
    {
        OpenInterface(sender);
    }
    else super.Mutate(MutateString, Sender);
}



function OpenInterface(PlayerController Sender)
{
    local UsUnitReplicationInfo RepInfo;
    if (ActiveUser == none)
    {
        ActiveUser = Sender;
    }
    foreach Sender.ChildActors(class'UsUnitReplicationInfo', RepInfo) break;
    if (RepInfo == none)
    {
        RepInfo = spawn(ReplicationInfoClass, Sender);
        RepInfo.Initialize(ActiveUser != Sender);
    }
    else RepInfo.OpenGUI(ActiveUser != Sender);
}

defaultproperties
{
    FriendlyName="UsUnit"
    Description="(BETA!) Provides an alternative method to start UsUnit tests; it also has a fancy GUI. WARNING: this mutator works only for a single user environment."
    GroupName="Tests"

    ReplicationInfoClass=class'UsUnitReplicationInfo'
}