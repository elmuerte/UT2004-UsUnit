/*******************************************************************************
	UsUnitReplicationInfo
	used by the UsUnitMutator to communicate between the test runner and user's
	GUI.

	Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

	UsUnit Testing Framework
	Copyright (C) 2005, Michiel "El Muerte" Hendriks

	This program is free software; you can redistribute and/or modify
	it under the terms of the Lesser Open Unreal Mod License.
	<!-- $Id: UsUnitReplicationInfo.uc,v 1.4 2005/06/27 10:07:27 elmuerte Exp $ -->
*******************************************************************************/

class UsUnitReplicationInfo extends ReplicationInfo;

var string MainPageClass;
var usugui_MainPage usuPage;

var class<Output_MutatorGUI> OutputModuleClass;
var Output_MutatorGUI OutputModule;

var TestRunner Runner;

replication
{
	reliable if (Role == ROLE_Authority)
		OpenGUI;
	reliable if (Role < ROLE_Authority)
		SetGUIPage, StartTest, ClientHookOutputModule;
}

/**
	Will be called right after it has been spawned by UsUnitMutator.
	ReadOnly is true when the user can only view
*/
function Initialize(bool ReadOnly)
{
    log("Initialize"@ReadOnly, name);
	OpenGUI(ReadOnly);
}

simulated function OpenGUI(bool ReadOnly)
{
    log("OpenGUI"@ReadOnly, name);
	PlayerController(Owner).ClientOpenMenu(MainPageClass, ReadOnly);
}

/** set the handle to our GUI page */
simulated function SetGUIPage(usugui_MainPage Page)
{
    log("SetGUIPage"@Page, name);
	usuPage = Page;
}

/** start the testing */
simulated function StartTest()
{
    local float OldfDelayedStart;
    log("StartTest", name);

    if (Runner == none) // find an existing runner, mostlikely not present
        foreach AllActors(class'TestRunner', Runner) break;

    if (Runner == none)
    {
        //TODO: make class configurable
        OldfDelayedStart = class'TestRunner'.default.fDelayedStart;
        class'TestRunner'.default.fDelayedStart = -1;
        Runner = spawn(class'TestRunner');
        class'TestRunner'.default.fDelayedStart = OldfDelayedStart;
    }
    HookOutputModule();
    Runner.run();
}

simulated function ClientHookOutputModule()
{
    HookOutputModule();
}

function HookOutputModule()
{
    local TestReporter Reporter;
    log("HookOutputModule", name);
    // add our reporter
    if (OutputModule == none)
    {
        foreach AllActors(class'TestReporter', Reporter) break;
        if (Reporter != none)
            OutputModule = Output_MutatorGUI(Reporter.AddOutputModule(OutputModuleClass));
    }

    OutputModule.RI = self;
}

event Destroyed()
{
    if (OutputModule != none)
    {
        OutputModule.RI = none;
        OutputModule = none;
    }
}

///// output module forwards
//TODO: major todo, objects can't be replicated

simulated function start()
{
    usuPage.start();
}

simulated function end()
{
    usuPage.end();
}

simulated function testBegin(TestBase test)
{
    usuPage.pbGlobal.value = Runner.getProgress();
    usuPage.testBegin(test);
}

simulated function testEnd(TestBase test)
{
    usuPage.testEnd(test);
}

simulated function reportCheck(int CheckId, coerce string Message)
{
    usuPage.reportCheck(CheckId, Message);
}

simulated function reportFail(int CheckId, int FailCount)
{
    usuPage.reportFail(CheckId, FailCount);
}

simulated function reportPass(int CheckId)
{
    usuPage.reportPass(CheckId);
}

simulated function reportError(Object Sender, coerce string Message)
{
    usuPage.reportError(Sender, Message);
}

defaultproperties
{
	MainPageClass="UsUnit.usugui_MainPage"
	OutputModuleClass=class'UsUnit.Output_MutatorGUI'
}