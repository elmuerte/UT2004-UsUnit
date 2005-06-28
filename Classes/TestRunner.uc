/*******************************************************************************
	TestRunner
	This will run all registered TestCases and\or TestSuites. This is actually
	an implementation of TestSuite. However, any subclass of this class
	will not be executed as an actual test.

	Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

	UsUnit Testing Framework
	Copyright (C) 2005, Michiel "El Muerte" Hendriks

	This program is free software; you can redistribute and/or modify
	it under the terms of the Lesser Open Unreal Mod License.
	<!-- $Id: TestRunner.uc,v 1.6 2005/06/28 09:44:58 elmuerte Exp $ -->
*******************************************************************************/

class TestRunner extends TestSuiteBase;

/** tests to execute */
var() config array<string> Tests;

/**
	Number of seconds to wait before executing run() (after the event
	PostBeginPlay() is called). If the number is negative nothing is done at
	all, run() will have to be called manually.
*/
var() config float fDelayedStart;

/** reporter class to use */
var class<TestReporter> ReporterClass;

function run()
{
	log("Starting tests", 'UsUnit');
	if (TestClasses.length == 0) InitializeTestClasses();
	Reporter.start();
	super.run();
}

protected function internalRun()
{
	super.internalRun();
	if (!bRunning)
	{
		Reporter.end();
		log("Finished running tests", 'UsUnit');
	}
}

/** resolve the strings to classnames */
protected function InitializeTestClasses()
{
	local int i;
	local class<TestBase> tb;
	for (i = 0; i < Tests.Length; i++)
	{
		tb = class<TestBase>(DynamicLoadObject(Tests[i], class'Class', true));
		if (tb != none) TestClasses[TestClasses.length] = tb;
		else {
			log("'"$Tests[i]$"' is not a valid TestCase or TestSuite class", 'UsUnit');
			reporter.reportError(self, "'"$Tests[i]$"' is not a valid TestCase or TestSuite class");
		}
	}
}

event PreBeginPlay()
{
	Reporter = spawn(ReporterClass);
	super.PreBeginPlay();
}

event PostBeginPlay()
{
	super.PostBeginPlay();
	if (fDelayedStart > 0) SetTimer(fDelayedStart, false);
	else if (fDelayedStart == 0) run();
}

defaultproperties
{
	ReporterClass=class'TestReporter';
	bBreakOnFail=false
	fDelayedStart=0.0
	TestName="Test Runner"
	TestDescription="Runs the registered tests cases and suites; This is not an actual test."
}
