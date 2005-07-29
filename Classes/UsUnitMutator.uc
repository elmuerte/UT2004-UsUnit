/*******************************************************************************
    UsUnitMutator
    Mutator to start the test runner. It comes with a GUI. Start it with the
    console command: `mutate usunit`

    Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

    UsUnit Testing Framework
    Copyright (C) 2005, Michiel "El Muerte" Hendriks

    This program is free software; you can redistribute and/or modify
    it under the terms of the Lesser Open Unreal Mod License.
    <!-- $Id: UsUnitMutator.uc,v 1.8 2005/07/29 06:40:35 elmuerte Exp $ -->
*******************************************************************************/

class UsUnitMutator extends Mutator;

//TODO: limit to one user

/** replication info class to be used to handle the communication */
var class<UsUnitReplicationInfo> ReplicationInfoClass;

// the user that controlls the testing, others can only view
var protected PlayerController ActiveUser;

function Mutate(string MutateString, PlayerController Sender)
{
    local UsUnitUtils utils;
    local string pkgname;
    local array< class<TestBase> > classes;
    local int i;

    Divide(mutatestring, " ", mutatestring, pkgname);

    if (MutateString ~= "usunit")
    {
        OpenInterface(sender);
    }
    else if (MutateString ~= "findtests")
    {
        utils = new class'UsUnitUtils';
        log("FindTestClasses = "$utils.FindTestClasses(pkgname, classes, Level.Game));
        for (i = 0; i < classes.length; i++)
        {
            log(classes[i]);
        }
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
    Description="Provides an alternative method to start UsUnit tests; it also has a fancy GUI. WARNING: this mutator works only for a single user environment."
    GroupName="Tests"

    ReplicationInfoClass=class'UsUnitReplicationInfo'
}