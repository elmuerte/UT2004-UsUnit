/*******************************************************************************
	ReporterOutputModule
	Base class for output module

	Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

	UsUnit Testing Framework
	Copyright (C) 2005, Michiel "El Muerte" Hendriks

	This program is free software; you can redistribute and/or modify
	it under the terms of the Lesser Open Unreal Mod License.
	<!-- $Id: ReporterOutputModule.uc,v 1.1 2005/06/07 21:32:04 elmuerte Exp $ -->
*******************************************************************************/

class ReporterOutputModule extends Object within TestReporter;

function start();
function end();

function testBegin(TestBase test);
function testEnd(TestBase test);

function reportCheck(int CheckId, coerce string Message);
function reportFail(int CheckId, int FailCount);
function reportPass(int CheckId);

function reportFatalError(TestBase sender, coerce string msg);
function reportWarning(TestSuiteBase sender, coerce string msg);
function reportInfo(TestSuiteBase sender, coerce string msg);
