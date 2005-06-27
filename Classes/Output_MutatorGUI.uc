/*******************************************************************************
	Output_MutatorGUI
	Output module for the Mutator GUI, this will forward all functions to the
	UsUnitReplicationInfo that in turn will forward it to the GUI.

	Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

	UsUnit Testing Framework
	Copyright (C) 2005, Michiel "El Muerte" Hendriks

	This program is free software; you can redistribute and/or modify
	it under the terms of the Lesser Open Unreal Mod License.
	<!-- $Id: Output_MutatorGUI.uc,v 1.1 2005/06/27 10:08:06 elmuerte Exp $ -->
*******************************************************************************/

class Output_MutatorGUI extends ReporterOutputModule;

var UsUnitReplicationInfo RI;

function start()
{
    RI.start();
}

function end()
{
    RI.end();
}

function testBegin(TestBase test)
{
    RI.testBegin(test);
}

function testEnd(TestBase test)
{
    RI.testEnd(test);
}

function reportCheck(int CheckId, coerce string Message)
{
    RI.reportCheck(CheckId, Message);
}

function reportFail(int CheckId, int FailCount)
{
    RI.reportFail(CheckId, FailCount);
}

function reportPass(int CheckId)
{
    RI.reportPass(checkId);
}

function reportError(Object Sender, coerce string Message)
{
    RI.reportError(Sender, Message);
}