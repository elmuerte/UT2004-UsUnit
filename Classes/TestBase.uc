/*******************************************************************************
	TestBase
	Base class for TestSuite and TestCase to make it easier for TestRunner

	Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

	UsUnit Testing Framework
	Copyright (C) 2005, Michiel "El Muerte" Hendriks

	This program is free software; you can redistribute and/or modify
	it under the terms of the Lesser Open Unreal Mod License.
	<!-- $Id: TestBase.uc,v 1.3 2005/06/08 20:17:19 elmuerte Exp $ -->
*******************************************************************************/

class TestBase extends Info abstract config(UsUnit);

/** the current version of this test unit */
var const string USUNIT_VERSION;

/** A short name for this test, used in the output */
var() const string TestName;
/** A description for this test. */
var() const string TestDescription;

/** number of check()s called */
var(Stats) protected int Checks;
/** number of check()s failed */
var(Stats) protected int Failed;
/** number of fatal errors */
var(Stats) protected int FatalError;
/** number of seconds it took from run() to TestComplete() */
var(Stats) float TestTime;

/** handle to the test reporter */
var protected TestReporter Reporter;

/** call this when all tests within this class are complete */
delegate TestComplete(TestBase Sender);

/**
	Entry function to execute the tests. Override this method to call your
	test functions.
*/
function run();

/**
	If you need to initialize items before the test is run do it in this
	function.
*/
function setUp();

/**
	This function is used for cleanup. Called after the test was completed.
	Use it to reset everything your test has set up (so it has a good start
	the next time the test is run).
*/
function tearDown();

/** return the current progress in percentages; return 255 for 'undefined' */
function byte getProgress() { return 255; }

/**
	Reset the internal statistics. Called before runTests() or setUp() are called.
*/
final function ResetStats()
{
	Checks = 0;
	Failed = 0;
	FatalError = 0;
	TestTime = 0;
}
/** accessor for the Checks statistics */
final function int getNumChecks() { return Checks; }
/** accessor for the Failed statistics */
final function int getNumFailed() { return Failed; }
/** return a percentage of the successful tests */
final function byte getSuccessPct() { return round((Checks-Failed)*100/Checks); }

/** initialize some core variables */
event PreBeginPlay()
{
	if (Reporter == none) foreach AllActors(class'TestReporter', Reporter) break;
	super.PreBeginPlay();
}

defaultproperties
{
    USUNIT_VERSION="0.0.5"
}