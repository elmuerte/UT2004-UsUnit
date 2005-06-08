/*******************************************************************************
	TestReported
	Generates the reports

	Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

	UsUnit Testing Framework
	Copyright (C) 2005, Michiel "El Muerte" Hendriks

	This program is free software; you can redistribute and/or modify
	it under the terms of the Lesser Open Unreal Mod License.
	<!-- $Id: TestReporter.uc,v 1.4 2005/06/08 20:17:19 elmuerte Exp $ -->
*******************************************************************************/
class TestReporter extends Info config(UsUnit);

/** test stack */
var protected array< TestBase > Stack;

/** output modules to use */
var config array<string> OutputClasses;

/** list of output modules */
var array<ReporterOutputModule> OutputModules;

event PreBeginPlay()
{
	local int i;
	local class<ReporterOutputModule> omc;
	local ReporterOutputModule om;

	super.PreBeginPlay();
	for (i = 0; i < OutputClasses.Length; i++)
	{
		omc = class<ReporterOutputModule>(DynamicLoadObject(OutputClasses[i], class'Class', true));
		if (omc != none)
		{
			om = new(self) omc;
			OutputModules[OutputModules.length] = om;
		}
		else {
			warn("'"$OutputClasses[i]$"' is not a valid ReporterOutputModule class");
		}
	}
}

function start()
{
	OutputModules[0].start();
}

function end()
{
	OutputModules[0].end();
}

/** push a test on the stack */
function push(TestBase item)
{
	Stack.insert(0, 1);
	Stack[0] = item;
	OutputModules[0].testBegin(item); //TODO: improve
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
		// call testEnd for every item
	}
	OutputModules[0].testEnd(item); //TODO: improve
	Stack.remove(0, i+1);
}

function reportCheck(int CheckId, coerce string Message)
{
    OutputModules[0].reportCheck(CheckId, Message);
	//logf(StrRepeat("  ", stack.length)$"["$string(stack[stack.length-1].class)$"] #"$string(CheckId)$" :"@Message);
}

function reportFail(int CheckId, int FailCount)
{
    OutputModules[0].reportFail(CheckId, FailCount);
	//logf(StrRepeat("  ", stack.length)$"> FAILED");
}

function reportPass(int CheckId)
{
    OutputModules[0].reportPass(CheckId);
	//logf(StrRepeat("  ", stack.length)$"> Success");
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

final static function string PadLeft(coerce string base, coerce string padchar, int length)
{
    while (len(base) < length) base = padchar$base;
    return base;
}

defaultproperties
{
	OutputClasses[0]="UsUnit.Output_HTML"
}