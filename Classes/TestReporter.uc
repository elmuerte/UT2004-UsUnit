/*******************************************************************************
    TestReporter
<p>
    Generates the reports
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
    <!-- $Id: TestReporter.uc,v 1.11 2005/09/23 09:23:41 elmuerte Exp $ -->
*******************************************************************************/
class TestReporter extends Info config(UsUnit);

/** test stack */
var protected array< TestBase > Stack;

/** output modules to use */
var config array<string> OutputClasses;

/** create log errors when a check fails, can be used by program to extract and find checks that failed */
var config bool bGenerateLogErrors;

/** list of output modules */
var protected array<ReporterOutputModule> OutputModules;

/** will be used to report the file+check line when the last check failed */
var protected string LastCheckMsg;

var localized string PIText[2], PIDesc[2];

struct StatsStruct
{
    var float TotalTime;
    var int TotalTests;
    var int TotalCheck;
    var int TotalFail;
};
/** statistics of the last test cycle */
var StatsStruct Stats;

event PreBeginPlay()
{
    local int i;
    local class<ReporterOutputModule> omc;

    super.PreBeginPlay();
    for (i = 0; i < OutputClasses.Length; i++)
    {
        omc = class<ReporterOutputModule>(DynamicLoadObject(OutputClasses[i], class'Class', true));
        if (omc != none)
        {
            AddOutputModule(omc);
        }
        else {
            warn("'"$OutputClasses[i]$"' is not a valid ReporterOutputModule class");
        }
    }
}

// Add a runtime output module
function ReporterOutputModule AddOutputModule(class<ReporterOutputModule> omc)
{
    local ReporterOutputModule om;
    om = new(self) omc;
    OutputModules.length = OutputModules.length+1;
    OutputModules[OutputModules.length-1] = om;
    return om;
}

function bool RemoveOutputModule(ReporterOutputModule om)
{
    //TODO:
    return false;
}

/** called when the total test starts */
function start()
{
    local int i;
    Stats.TotalCheck = 0;
    Stats.TotalFail = 0;
    Stats.TotalTests = 0;
    Stats.TotalTime = 0;
    Stack.length = 0;
    for (i = 0; i < OutputModules.length; i++)
        OutputModules[i].start();
}

/** called when all tests are finish */
function end()
{
    local int i;
    for (i = 0; i < OutputModules.length; i++)
        OutputModules[i].end();
    if (stack.length > 0)
    {
        reportError(self, "Stack corruption, stack not empty at the end of the test cycle");
        return;
    }
}

/** push a test on the stack */
function push(TestBase item)
{
    local int i;
    if (item.IsA('TestCase'))
        Stats.TotalTests++;
    Stack.insert(0, 1);
    Stack[0] = item;
    for (i = 0; i < OutputModules.length; i++)
        OutputModules[i].testBegin(item);
}

/** pop a test from the stack */
function pop(TestBase item)
{
    if (stack.length == 0)
    {
        reportError(self, "Stack corruption, tried to pop "$string(item)$" off an empty stack");
        return;
    }
    while (Stack[0] != item)
    {
        reportError(self, "Stack corruption, forced pop of "$string(Stack[0]));
        _pop();

        if (stack.length == 0)
        {
            reportError(self, "Stack corruption, tried to pop "$string(item)$" off an empty stack");
            return;
        }
    }
    _pop();
}

/** the actual pop; this assumes item is on top of the stack  */
protected function _pop()
{
    local int i;
    if (Stack[0].IsA('TestCase'))
    {
        Stats.TotalTime += Stack[0].TestTime;
    }
    for (i = 0; i < OutputModules.length; i++)
        OutputModules[i].testEnd(Stack[0]);
    Stack.remove(0, 1);
}

function reportCheck(int CheckId, coerce string Message)
{
    local int i;
    Stats.TotalCheck++;
    LastCheckMsg = Message;
    for (i = 0; i < OutputModules.length; i++)
        OutputModules[i].reportCheck(CheckId, Message);
}

function reportFail(int CheckId, int FailCount)
{
    local int i;
    Stats.TotalFail++;
    i = InStr(LastCheckMsg, chr(3));
    if ((i > -1) && (bGenerateLogErrors))
    {
       Log(Mid(LastCheckMsg, i+1)$" : UsUnit Check failed: "$Left(LastCheckMsg, i), 'Error');
    }
    for (i = 0; i < OutputModules.length; i++)
        OutputModules[i].reportFail(CheckId, FailCount);
}

function reportPass(int CheckId)
{
    local int i;
    for (i = 0; i < OutputModules.length; i++)
        OutputModules[i].reportPass(CheckId);
}

function reportError(Object Sender, coerce string Message)
{
    local int i;
    for (i = 0; i < OutputModules.length; i++)
        OutputModules[i].reportError(Sender, Message);
}

final static function string StrRepeat(coerce string str, int count)
{
    local string res;
    while (--count >= 0) res $= str;
    return res;
}

final static function string PadLeft(coerce string base, coerce string padchar, int length)
{
    while (len(base) < length) base = padchar$base;
    return base;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
    super.FillPlayInfo(PlayInfo);
    PlayInfo.AddSetting("Test Reporter", "bGenerateLogErrors", default.PIText[0], 0, 1, "CHECK");
    PlayInfo.AddSetting("Test Reporter", "OutputClasses", default.PIText[0], 0, 1, "CUSTOM");
}

static event string GetDescriptionText(string PropName)
{
    switch (PropName)
    {
        case "bGenerateLogErrors": return default.PIDesc[0];
        case "OutputClasses": return default.PIDesc[1];
    }
    return "";
}

defaultproperties
{
    bGenerateLogErrors=true
    OutputClasses[0]="UsUnit.Output_HTML"

    PIText[0]="Generate Log Errors"
    PIDesc[0]="Create error log entries about the failed check. Only works well when the filename and line number are included in the check message."
    PIText[1]="Output Classes"
    PIDesc[1]="The output classes to use on startup."
}
