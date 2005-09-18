/*******************************************************************************
	Output_HTMLBase
	Writes the test results to an HTML. The actual writing og the output to
	something should be implemented by a subclass.

	Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

	UsUnit Testing Framework
	Copyright (C) 2005, Michiel "El Muerte" Hendriks

	This program is free software; you can redistribute and/or modify
	it under the terms of the Lesser Open Unreal Mod License.
	<!-- $Id: Output_HTMLBase.uc,v 1.2 2005/09/18 09:49:51 elmuerte Exp $ -->
*******************************************************************************/

class Output_HTMLBase extends ReporterOutputModule abstract;

var protected string indent;

/** the actual output */
function Logf(coerce string line);

function start()
{
	_head();
}

function end()
{
	_footer();
}

function testBegin(TestBase test)
{
	local string cssClass, hLevel;
	indent = StrRepeat("    ", Stack.length-1);
	if (Test.IsA('TestSuite'))
	{
		cssClass = "suite";
		hLevel = "2";
	}
	else if (Test.IsA('TestCase'))
	{
		cssClass = "test";
		hLevel = "3";
	}
	Logf(indent$"<table>");
	Logf(indent$"<tr>");
	Logf(indent$"    <td class=\""$cssClass$"\"><h"$hLevel$">"$test.TestName$" <span class=\"uclass\">"$string(test.class)$"</span></h"$hLevel$">");
	if (test.TestDescription != "") Logf(indent$"    <p>"$test.TestDescription$"</p>");
	if (Test.IsA('TestCase')) Logf(indent$"    <table>");
}

function testEnd(TestBase test)
{
	if (Test.IsA('TestCase'))
	{
		Logf(indent$"    </table>");
		Logf(indent$"    <p class=\"testStats\">Time: "$string(int(round(test.TestTime*1000)))$" ms; Success: "$string(test.getSuccessPct())$"%</p>");
	}
	else if (Test.IsA('TestSuite'))
	{
		Logf(indent$"    <p class=\"testStats\">");
		if (TestSuite(Test).isAborted()) Logf("<em>Test suite was aborted because a test failed</em>;");
		Logf(indent$"Success: "$string(test.getSuccessPct())$"%</p>");
	}
	Logf(indent$"    </td>");
	Logf(indent$"</tr>");
	Logf(indent$"</table>");
	indent = StrRepeat("    ", Stack.length-2);
}

function reportCheck(int CheckId, coerce string Message)
{
	local int i;
	i = InStr(Message, chr(3));
	if (i > -1)
	{
	   Message = Left(Message, i)$"<br /><span class=\"file\">"$Mid(Message, i+1)$"</span>";
	}
	Logf(indent$"    <tr>");
	Logf(indent$"        <td class=\"check"$string(int(CheckId % 2))$"\"><span class=\"checkid\">"$string(CheckId)$")</span> "$Message$"</td>");
}

function reportFail(int CheckId, int FailCount)
{
	Logf(indent$"        <td class=\"fail\">FAIL</td>");
	Logf(indent$"    </tr>");
}

function reportPass(int CheckId)
{
	Logf(indent$"        <td class=\"pass\">PASS</td>");
	Logf(indent$"    </tr>");
}

function reportFatalError(TestBase sender, coerce string msg);
function reportWarning(TestSuiteBase sender, coerce string msg);
function reportInfo(TestSuiteBase sender, coerce string msg);


function _head()
{
	local string date;
	date = Level.Year$"-"$Right("0"$Level.Month, 2)$"-"$Right("0"$Level.Day, 2)@Right("0"$Level.Hour, 2)$":"$Right("0"$Level.Minute, 2)$":"$Right("0"$Level.Second, 2);
	Logf("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">");
	Logf("<html xml:lang=\"en\">");
	Logf("<head>");
	Logf("    <title>UsUnit Report - "$date$"</title>");
	Logf("    <meta name=\"generator\"/ content=\"$Id: Output_HTMLBase.uc,v 1.2 2005/09/18 09:49:51 elmuerte Exp $\">");
	_style();
	Logf("</head>");
	Logf("<body>");
	Logf("<h1>UsUnit Report: "$date$"</h1>");
}

function _style()
{
	Logf("    <style type=\"text/css\">");
	Logf("    BODY { font-family: sans-serif; background-color: #F2F2F2; font-size: 12px; color: black; }");
	Logf("    H1 { font-size: 24px; }");
	Logf("    TABLE { width: 100%; }");
	Logf("    TD { font-size: 14px; }");
	Logf("    TD.suite { background-color: #999999; }");
	Logf("    H2 { font-size: 18px; margin: 1px; }");
	Logf("    H3 { font-size: 16px; margin: 1px; }");
	Logf("    TD.test { background-color: Silver; }");
	Logf("    SPAN.uclass { font-family: monospace; font-size: 14px; font-weight: normal; }");
	Logf("    P { margin: 0px; margin-left: 2px; }");
	Logf("    P.testStats { margin-right: 2px; text-align: right; font-size: 12px; }");
	Logf("    TD.check0, TD.check1 { font-size: 14px; font-weight: normal; }");
	Logf("    TD.check0 { background-color: #D6D6D6; }");
	Logf("    TD.check1 { background-color: #E6E6E6; }");
	Logf("    SPAN.checkid { font-family: monospace; }");
	Logf("    SPAN.file { font-family: monospace; padding-left: 25px; }");
	Logf("    .pass, .fail { text-align: center; font-weight: bold; font-size: 12px; width: 100px; }");
	Logf("    .pass { background-color: Lime; }");
	Logf("    .fail { background-color: Red; }");
	Logf("    TABLE.stats { width: auto; border: 2px solid gray; margin: 5px; margin-left: 50px; }");
	Logf("    TH { background-color: gray; color: white; }");
	Logf("    TD.field { background-color: #dddddd; padding: 0px 2px 0px 2px; }");
	Logf("    TD.value { font-family: monospace; text-align: right; }");
	Logf("    </style>");
}

function _footer()
{
	_stats();
	Logf("<hr />");
	Logf("<address>Report made by <a href=\"http://wiki.beyondunreal.com/wiki/UsUnit\">UsUnit</a> ("$class'TestBase'.default.USUNIT_VERSION$")</address>");
	Logf("</body>");
	Logf("</html>");
}

function _stats()
{
	Logf("<table class=\"stats\">");
	Logf("<tr>");
	Logf("    <th colspan=\"2\">Stats</th>");
	Logf("</tr>");
	Logf("<tr>");
	Logf("    <td class=\"field\">Total Time:</td>");
	Logf("    <td class=\"value\">"$string(int(round(Stats.TotalTime*1000)))$" ms</td>");
	Logf("</tr>");
	Logf("<tr>");
	Logf("    <td class=\"field\">Total Tests:</td>");
	Logf("    <td class=\"value\">"$string(Stats.TotalTests)$"</td>");
	Logf("</tr>");
	Logf("<tr>");
	Logf("    <td class=\"field\">Success:</td>");
	Logf("    <td class=\"value\">"$string(int(round((Stats.TotalCheck-Stats.TotalFail)*100/Stats.TotalCheck)))$"%</td>");
	Logf("</tr>");
	Logf("</table>");
}
