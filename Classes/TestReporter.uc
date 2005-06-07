/*******************************************************************************
	TestReported
	Generates the reports

	Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

	UsUnit Testing Framework
	Copyright (C) 2005, Michiel "El Muerte" Hendriks

	This program is free software; you can redistribute and/or modify
	it under the terms of the Lesser Open Unreal Mod License.
	<!-- $Id: TestReporter.uc,v 1.3 2005/06/07 21:31:19 elmuerte Exp $ -->
*******************************************************************************/
class TestReporter extends Info config(UsUnit);

/** test stack */
var protected array< TestBase > Stack;

/** output modules to use */
var config array<string> OutputClass;

/** list of output modules */
var array<ReporterOutputModule> OutputModules;

event PreBeginPlay()
{
    local int i;
    local class<ReporterOutputModule> omc;
    local ReporterOutputModule om;

    super.PreBeginPlay();
    for (i = 0; i < OutputClass.Length; i++)
    {
        omc = class<ReporterOutputModule>(DynamicLoadObject(OutputClass[i], class'Class', true));
        if (omc != none)
        {
            om = new(self) omc;
            OutputModules[OutputModules.length] = om;
        }
        else {
            warn("'"$OutputClass[i]$"' is not a valid ReporterOutputModule class");
        }
    }
}

/** push a test on the stack */
function push(TestBase item)
{
	log(">>>"@"["$string(item.class)$"]"@item.TestName, 'UsUnit');
	Stack.insert(0, 1);
	Stack[0] = item;
}

/** pop a test from the stack */
function pop(TestBase item)
{
	local int i;
	i = 0;
	while (Stack[i] != item) i++;
	if (i > 0)
	{
		//TODO: report stack corruption
	}
	Stack.remove(0, i+1);
	log("<<<"@"["$string(item.class)$"]"@item.TestName, 'UsUnit');
}

function reportCheck(int CheckId, coerce string Message)
{
	logf(StrRepeat("  ", stack.length)$"["$string(stack[stack.length-1].class)$"] #"$string(CheckId)$" :"@Message);
}

function reportFail(int CheckId, int FailCount)
{
	logf(StrRepeat("  ", stack.length)$"> FAILED");
}

function reportPass(int CheckId)
{
	logf(StrRepeat("  ", stack.length)$"> Success");
}

protected function logf(coerce string Text)
{
	log(Text, 'UsUnit');
}

final static function string StrRepeat(coerce string str, int count)
{
	local string res;
	while (--count >= 0) res $= str;
	return res;
}

defaultproperties
{
    OutputClass[0]="UsUnit.Output_HTML"
}