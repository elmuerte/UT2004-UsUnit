// NOTICE: This file was automatically generated by UCPP; do not edit this file manualy.
// #pragma ucpp include private.inc

/*******************************************************************************
    UsUnitUtils
    Utility class

    Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

    UsUnit Testing Framework
    Copyright (C) 2005, Michiel "El Muerte" Hendriks

    This program is free software; you can redistribute and/or modify
    it under the terms of the Lesser Open Unreal Mod License.
    <!-- $Id: UsUnitUtils.uc,v 1.13 2005/09/12 07:57:00 elmuerte Exp $ -->
*******************************************************************************/

class UsUnitUtils extends Object config(UsUnit);

/** cached list with known subclasses */
var config array<string> KnownTestClasses;

event Created()
{
    /*
    local int i;
    log("UsUnitUtils::Created", 'UsUnit');
    for (i = KnownTestClasses.length-1; i >= 0; i--)
    {
        log("> "$KnownTestClasses[i], 'UsUnit');
    }
    */
}

function AddKnownTestClass(coerce string cls, optional bool bDontSave)
{
    local int i;
    //TODO: improve search
    for (i = 0; i < KnownTestClasses.length; i++)
    {
        if (KnownTestClasses[i] == cls) return;
        if (KnownTestClasses[i] > cls) break;
    }
    KnownTestClasses.insert(i, 1);
    KnownTestClasses[i] = cls;
    if (!bDontSave) SaveConfig();
}

/**
    Returns a list of available test classes in the given package.
    GameInfo is required for certain functions.
    Notice: this function is an extreme hack, and doesn't always work as it should. USE WITH CAUTION.
*/
function int FindTestClasses(string package, out array< class<TestBase> > results, GameInfo GI)
{
// #ifdef UE25
    local Object o;
    local class<TestBase> c;
    local int res;

    if (InStr(caps(string(class)), caps(package$".")) != -1) return 0;
    if (package == "") return -1;
    if (!PackageExists(package, GI)) return -1;

    if (InStr(Caps(GI.ConsoleCommand("obj linkers")), "(PACKAGE "$caps(package)$")") > -1)
    {
        Warn("Package ("$package$") already loaded, not all test classes might be found.");
        res = -2;
    }

    // AllDataObject fails if the package doesn't exist (e.g. major crash)

    // find all correct classes in this package
    // this only works when the package hasn't been loaded yet, if it was loaded
    // not all classes would show up (only the classes that have been loaded once)
    results.length = 0;
    foreach GI.AllDataObjects(class'Object', o, package)
    {
        if (o.IsA('class'))
        {
            c = class<TestBase>(o);
            if (c == none) continue;
            if (ClassIsChildOf(c, class'TestCase') || ClassIsChildOf(c, class'TestSuite'))
            {
                results[results.length] = c;
                AddKnownTestClass(c, true);
            }
        }
    }
    if (results.length > 0) SaveConfig();
    if (res < 0) return res;
    return results.length;
// #else
    // return -1;
// #endif
}

/**
    return true when the given code package exists
*/
function bool PackageExists(string package, GameInfo GI)
{
// #ifdef UE25
    local string s;

    // Doing the following to check if a package doesn't work because then
    // the classes can't be found
    //DynamicLoadObject(package$".dummy", class'class', true);
    //if (InStr(Caps(GI.ConsoleCommand("obj linkers")), "(PACKAGE "$caps(package)$")") == -1) return -1;

    s = Caps(GI.ConsoleCommand("dir *.u"));
    return (InStr(s, caps(package)$".U") > 1);
// #else
    // return false;
// #endif
}
