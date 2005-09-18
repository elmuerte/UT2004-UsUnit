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
	<!-- $Id: TestRunner.uc,v 1.8 2005/09/18 09:49:51 elmuerte Exp $ -->
*******************************************************************************/

class TestRunner extends TestSuiteBase;

/** tests to execute */
var() protected config array<string> Tests;

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
	Initialize();
	Reporter.start();
	super.run();
}

protected function internalRun()
{
	super.internalRun();
	if (!bRunning)
	{
		Reporter.end();
		log("Finished running tests. Success rate = "$string(int(round((Reporter.Stats.TotalCheck-Reporter.Stats.TotalFail)*100/Reporter.Stats.TotalCheck)))$"%", 'UsUnit');
	}
}

function Initialize()
{
	if (TestClasses.length == 0) InitializeTestClasses();
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
			//TODO: no log guarantee
			//reporter.reportError(self, "'"$Tests[i]$"' is not a valid TestCase or TestSuite class");
		}
	}
}

/** Add a test class, used for on-the-fly configuration */
function bool AddTestClass(string classname)
{
	local class<TestBase> tb;
	if (classname == "") return false;
	tb = class<TestBase>(DynamicLoadObject(classname, class'Class', true));
	if (tb != none)
	{
		TestClasses[TestClasses.length] = tb;
		Tests[Tests.length] = string(tb);
		return true;
	}
	else {
		log("'"$classname$"' is not a valid TestCase or TestSuite class", 'UsUnit');
		//reporter.reportError(self, "'"$Tests[i]$"' is not a valid TestCase or TestSuite class");
		return false;
	}
}

/** Remove a test class (index in the TestClasses array) */
function bool RemoveTestClass(int idx)
{
	local class<TestBase> tb;
	local int j, skipCount;
	if ((idx < 0) || (idx > TestClasses.length)) return false;
	tb = TestClasses[idx];
	for (j = 0; j < idx; j++)
	{
		if (TestClasses[j] == tb) skipCount++;
	}
	for (j = 0; j < Tests.Length; j++)
	{
		if (Tests[j] ~= string(tb))
		{
			skipCount--;
			if (skipCount == -1) break;
		}
	}
	if (skipCount == -1)
	{
		TestClasses.remove(idx, 1);
		if (TestInstances.length > idx) TestInstances.remove(idx, 1);
		Tests.remove(j, 1);
		log("Removed test class '"$string(tb)$"' at index "$idx$" and config index "$j, 'UsUnit');
		return true;
	}
	return false;
}

/**
	Move a test class, this will also move the configured class name in the
	Tests array (index in the TestClasses array)
*/
function MoveTestClass(int currentIdx, int newIdx)
{
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
