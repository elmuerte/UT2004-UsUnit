/*******************************************************************************
	TestSuiteBase
	...

	Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

	UsUnit Testing Framework
	Copyright (C) 2005, Michiel "El Muerte" Hendriks

	This program is free software; you can redistribute and/or modify
	it under the terms of the Lesser Open Unreal Mod License.
	<!-- $Id: TestSuiteBase.uc,v 1.5 2005/06/21 20:19:30 elmuerte Exp $ -->
*******************************************************************************/

class TestSuiteBase extends TestBase abstract;

/** the whole TestSuite fails when a single test failed */
var(Suite) config bool bBreakOnFail;

/** the tests to run, in order of appearance */
var(Suite) array< class<TestBase> > TestClasses;

/** spawned instances of the tests */
var protected array<TestBase> TestInstances;
/** current position in the tests */
var protected int currentIndex;
/** set to true when this suite is active */
var protected bool bRunning;
/** test suite was aborted because */
var protected bool bAborted;

/** runs the test suites. */
function run()
{
	if (bRunning)
	{
		//TODO: warning
		return;
	}
	bRunning = true;
	bAborted = false;
	TestInstances.Length = TestClasses.Length;
	currentIndex = 0;
	enable('Tick');
}

/** this function actually does the work */
protected function internalRun()
{
	if (currentIndex >= TestClasses.length)
	{
		TestComplete(Self);
		bRunning = false;
		return;
	}

	if (!isValidTestClass(TestClasses[currentIndex]))
	{
		//TODO: generate error\warning?
		Reporter.reportError(self, TestClasses[currentIndex]@"is not a valid test class");
		++currentIndex;
		enable('Tick');
		return;
	}
	if (TestInstances[currentIndex] == none)
	{
		TestInstances[currentIndex] = spawn(TestClasses[currentIndex], self);
	}
	Reporter.push(TestInstances[currentIndex]);
	TestInstances[currentIndex].ResetStats();
	TestInstances[currentIndex].TestComplete = completedTest;
	TestInstances[currentIndex].setUp();
	++Checks;
	Clock(TestInstances[currentIndex].TestTime);
	TestInstances[currentIndex].run();
}

/** will be called when a test was completed */
protected function completedTest(TestBase Sender)
{
	if (currentIndex >= TestClasses.length)
	{
		Error("currentIndex >= Tests.length");
		TestComplete(Self); // to make sure it'll continue
		return;
	}
	UnClock(Sender.TestTime);
	Sender.tearDown();
	if (Sender.Failed > 0)
	{
		++Failed;
		if (bBreakOnFail)
		{
			// TODO: warning
			log("Failed a test, aborting suite", 'UsUnit');
			bAborted = true;
			Reporter.pop(Sender);
			TestComplete(Self);
			bRunning = false;
			return;
		}
	}
	Reporter.pop(Sender);
	++currentIndex;
	enable('Tick');
}

/**
	we use the tick event to go to the next test instance, this is to reduce the
	stack size.
*/
event Tick(float Delta)
{
	disable('Tick');
	if (bRunning) internalRun();
}

/** returns true if the testclass is a valid test class */
function bool isValidTestClass(class<TestBase> testClass)
{
	if (ClassIsChildOf(testClass, class'TestCase')) return true;
	if (ClassIsChildOf(testClass, class'TestSuite')) return true;
	return false;
}

function byte getProgress()
{
	return currentIndex / TestClasses.Length;
}

function bool isRunning() { return bRunning; }
function bool isAborted() { return bAborted; }

defaultproperties
{
	bBreakOnFail=true
}
