/*******************************************************************************
    Output_MutatorGUI
<p>
    Output module for the Mutator GUI, this will forward all functions to the
    UsUnitReplicationInfo that in turn will forward it to the GUI.
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
    <!-- $Id: Output_MutatorGUI.uc,v 1.4 2005/09/23 09:23:41 elmuerte Exp $ -->
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
    RI.testBegin(string(test.class));
}

function testEnd(TestBase test)
{
    RI.testEnd(string(test.class));
}

function reportCheck(int CheckId, coerce string Message)
{
    local string file;
    RI.reportLocalProgress(Stack[0].getProgress());
    Divide(message, chr(3), message, file);
    RI.reportCheck(CheckId, Message);
    //TODO: report file
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
    RI.reportError(string(Sender.class), Message);
}