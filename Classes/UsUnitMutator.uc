/*******************************************************************************
    UsUnitMutator
    Mutator to start the test runner. It comes with a GUI. Start it with the
    console command: `mutate usunit`

    Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

    UsUnit Testing Framework
    Copyright (C) 2005, Michiel "El Muerte" Hendriks

    This program is free software; you can redistribute and/or modify
    it under the terms of the Lesser Open Unreal Mod License.
    <!-- $Id: UsUnitMutator.uc,v 1.3 2005/06/24 16:28:58 elmuerte Exp $ -->
*******************************************************************************/

class UsUnitMutator extends Mutator;

//TODO: limit to one user

/** replication info class to be used to handle the communication */
var class<UsUnitReplicationInfo> ReplicationInfoClass;

var protected PlayerController ActiveUser;

function Mutate(string MutateString, PlayerController Sender)
{
    local UsUnitReplicationInfo RepInfo;
    if (MutateString ~= "usunit")
    {
        RepInfo = spawn(ReplicationInfoClass, Sender);
        if (ActiveUser == none)
        {
            ActiveUser = Sender;
        }
        //TODO: ...
    }
    else super.Mutate(MutateString, Sender);
}

defaultproperties
{
    FriendlyName="UsUnit"
    Description="Provides an alternative method to start UsUnit tests; it also has a fancy GUI. WARNING: this mutator works only for a single user environment."
    GroupName="Tests"

    ReplicationInfoClass=class'UsUnitReplicationInfo'
}