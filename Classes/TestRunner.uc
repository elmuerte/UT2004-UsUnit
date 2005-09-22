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
    <!-- $Id: TestRunner.uc,v 1.12 2005/09/22 13:59:21 elmuerte Exp $ -->
*******************************************************************************/

class TestRunner extends TestSuiteBase;

/** tests to execute */
var() protected config array<string> Tests;

/** contains displacents between Tests and TestClasses. TestClasses.idx -> Tests.idx */
var protected array<int> Displacement;

/**
    Number of seconds to wait before executing run() (after the event
    PostBeginPlay() is called). If the number is negative nothing is done at
    all, run() will have to be called manually.
*/
var() config float fDelayedStart;

/** reporter class to use */
var class<TestReporter> ReporterClass;

var localized string PIText[2], PIDesc[2];

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
        if (tb != none)
        {
            Displacement[TestClasses.length] = i;
            TestClasses[TestClasses.length] = tb;
        }
        else {
            log("'"$Tests[i]$"' is not a valid TestCase or TestSuite class", 'UsUnit');
            //TODO: no log guarantee
            //reporter.reportError(self, "'"$Tests[i]$"' is not a valid TestCase or TestSuite class");
        }
    }
    TestInstances.length = TestClasses.length;
}

/** Add a test class, used for on-the-fly configuration */
function bool AddTestClass(string classname)
{
    local class<TestBase> tb;
    if (classname == "") return false;
    tb = class<TestBase>(DynamicLoadObject(classname, class'Class', true));
    if (tb != none)
    {
        Displacement[TestClasses.length] = Tests.length;
        TestClasses[TestClasses.length] = tb;
        TestInstances.length = TestClasses.length;
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
    local int i;
    if ((idx < 0) || (idx > TestClasses.length)) return false;
    tb = TestClasses[idx];
    if (Tests[Displacement[idx]] ~= string(tb))
    {
        TestClasses.remove(idx, 1);
        if (TestInstances.length > idx) TestInstances.remove(idx, 1);
        Tests.remove(Displacement[idx], 1);
        Displacement.remove(idx, 1);
        for (i = idx; i < Displacement.length; i++) Displacement[i] = Displacement[i]-1;
        log("Removed test class '"$string(tb)$"' at index "$idx$" and config index "$Displacement[idx], 'UsUnit');
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
    local int tcidx, tnidx;
    local string tmp;

    if ((newIdx < 0) || (newIdx >= TestClasses.length)) return;
    tcidx = Displacement[currentIdx];
    tnidx = Displacement[newIdx];
    log("Move test class from "$currentIdx$" to "$newIdx$" (config: "$tcidx$"->"$tnidx$")", 'UsUnit');
    if (currentIdx > newIdx) currentIdx++;
    TestClasses.insert(newIdx, 1);
    TestClasses[newIdx] = TestClasses[currentIdx];
    TestClasses.remove(currentIdx, 1);
    TestInstances.insert(newIdx, 1);
    TestInstances[newIdx] = TestInstances[currentIdx];
    TestInstances.remove(currentIdx, 1);
    // use a dirty swap because of displacements
    tmp = Tests[tnidx];
    Tests[tnidx] = Tests[tcidx];
    Tests[tcidx] = tmp;
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

static function FillPlayInfo(PlayInfo PlayInfo)
{
    super.FillPlayInfo(PlayInfo);
    PlayInfo.AddSetting("Test Runner", "fDelayedStart", default.PIText[0], 0, 1, "TEXT", "10;-1.0:3600.0");
    PlayInfo.AddSetting("Test Runner", "bBreakOnFail", default.PIText[1], 0, 1, "CHECK");
    default.ReporterClass.static.FillPlayInfo(PlayInfo);
}

static event string GetDescriptionText(string PropName)
{
    switch (PropName)
    {
        case "fDelayedStart": return default.PIDesc[0];
        case "bBreakOnFail": return default.PIDesc[1];
    }
	return "";
}

defaultproperties
{
    ReporterClass=class'TestReporter'
    bBreakOnFail=false
    fDelayedStart=0.0
    TestName="Test Runner"
    TestDescription="Runs the registered tests cases and suites; This is not an actual test."

    PIText[0]="Delayed Start"
    PIDesc[0]="Number of seconds to wait before starting the runner when it is not created interactively (e.g. not via webadmin or mutator). -1 completely disables the auto start."
    PIText[1]="Break On Fail"
    PIDesc[1]="Discontinue testing when a single test case did not have a 100% succesful result."
}
