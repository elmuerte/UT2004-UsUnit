/*******************************************************************************
    ReporterOutputModule
<p>
    Base class for output module
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
    <!-- $Id: ReporterOutputModule.uc,v 1.4 2005/09/23 09:23:41 elmuerte Exp $ -->
*******************************************************************************/

class ReporterOutputModule extends Object within TestReporter;

/** test cycle begin */
function start();
/** test cycle end */
function end();

/** a new TestCase or TestSuite */
function testBegin(TestBase test);
/** TestCase or TestSuite was completed */
function testEnd(TestBase test);

/** a check() is performed */
function reportCheck(int CheckId, coerce string Message);
/** the check failed */
function reportFail(int CheckId, int FailCount);
/** the check passed */
function reportPass(int CheckId);

/** an error message */
function reportError(Object Sender, coerce string Message);

