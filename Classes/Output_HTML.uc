/*******************************************************************************
	Output_HTML
	Writes the test results to an HTML file.

	Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

	UsUnit Testing Framework
	Copyright (C) 2005, Michiel "El Muerte" Hendriks

	This program is free software; you can redistribute and/or modify
	it under the terms of the Lesser Open Unreal Mod License.
	<!-- $Id: Output_HTML.uc,v 1.2 2005/06/08 20:17:19 elmuerte Exp $ -->
*******************************************************************************/

class Output_HTML extends ReporterOutputModule;

var protected FileLog html;
var protected string indent;

struct StatsStruct
{
    var float TotalTime;
    var int TotalTests;
    var int TotalCheck;
    var int TotalFail;
};
var protected StatsStruct Stats;

event Created()
{
    html = spawn(class'FileLog');
}

function start()
{
	html.OpenLog("UsUnit_report", "html", true);
	Stats.TotalCheck = 0;
	Stats.TotalFail = 0;
	Stats.TotalTests = 0;
	Stats.TotalTime = 0;
	_head();
}

function end()
{
    _footer();
	html.CloseLog();
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
        Stats.TotalTests++;
        cssClass = "test";
        hLevel = "3";
    }
	html.Logf(indent$"<table>");
	html.Logf(indent$"<tr>");
	html.Logf(indent$"    <td class=\""$cssClass$"\"><h"$hLevel$">"$test.TestName$" <span class=\"uclass\">"$string(test.class)$"</span></h"$hLevel$">");
	if (test.TestDescription != "")	html.Logf(indent$"    <p>"$test.TestDescription$"</p>");
	if (Test.IsA('TestCase')) html.Logf(indent$"    <table>");
}

function testEnd(TestBase test)
{
    if (Test.IsA('TestCase'))
    {
        Stats.TotalTime += test.TestTime;
        html.Logf(indent$"    </table>");
        html.Logf(indent$"    <p class=\"testStats\">Time: "$string(test.TestTime)$" sec; Success: "$string(test.getSuccessPct())$"%</p>");
    }
    else if (Test.IsA('TestSuite'))
    {
        //html.Logf(indent$"    <p class=\"testStats\">Time: "$string(test.TestTime)$" sec; Success: "$string(test.getSuccessPct())$"%</p>");
    }
	html.Logf(indent$"    </td>");
	html.Logf(indent$"</tr>");
	html.Logf(indent$"</table>");
    indent = StrRepeat("    ", Stack.length-2);
}

function reportCheck(int CheckId, coerce string Message)
{
    Stats.TotalCheck++;
    html.Logf(indent$"    <tr>");
    html.Logf(indent$"        <td class=\"check"$string(int(CheckId % 2))$"\"><span class=\"checkid\">"$string(CheckId)$")</span> "$Message$"</td>");
}

function reportFail(int CheckId, int FailCount)
{
    Stats.TotalFail++;
    html.Logf(indent$"        <td class=\"fail\">FAIL</td>");
    html.Logf(indent$"    </tr>");
}

function reportPass(int CheckId)
{
    html.Logf(indent$"        <td class=\"pass\">PASS</td>");
    html.Logf(indent$"    </tr>");
}

function reportFatalError(TestBase sender, coerce string msg);
function reportWarning(TestSuiteBase sender, coerce string msg);
function reportInfo(TestSuiteBase sender, coerce string msg);


function _head()
{
    local string date;
    date = Level.Year$"-"$Right("0"$Level.Month, 2)$"-"$Right("0"$Level.Day, 2)@Right("0"$Level.Hour, 2)$":"$Right("0"$Level.Minute, 2)$":"$Right("0"$Level.Second, 2);
    html.Logf("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">");
    html.Logf("<html xml:lang=\"en\">");
    html.Logf("<head>");
    html.Logf("    <title>UsUnit Report - "$date$"</title>");
    html.Logf("    <meta name=\"generator\"/ content=\"$Id: Output_HTML.uc,v 1.2 2005/06/08 20:17:19 elmuerte Exp $\">");
	_style();
    html.Logf("</head>");
    html.Logf("<body>");
    html.Logf("<h1>UsUnit Report: "$date$"</h1>");
}

function _style()
{
    html.Logf("    <style type=\"text/css\">");
    html.Logf("    BODY { font-family: sans-serif; background-color: #F2F2F2; font-size: 12px; color: black; }");
    html.Logf("    H1 { font-size: 24px; }");
    html.Logf("    TABLE { width: 100%; }");
    html.Logf("    TD { font-size: 14px; }");
    html.Logf("    TD.suite { background-color: Gray; }");
    html.Logf("    H2 { font-size: 18px; margin: 1px; }");
    html.Logf("    H3 { font-size: 16px; margin: 1px; }");
    html.Logf("    TD.test { background-color: Silver; }");
    html.Logf("    SPAN.uclass { font-family: monospace; font-size: 14px; font-weight: normal; }");
    html.Logf("    P { margin: 0px; margin-left: 2px; }");
    html.Logf("    P.testStats { margin-right: 2px; text-align: right; font-size: 12px; }");
    html.Logf("    TD.check0, TD.check1 { font-size: 14px; font-weight: normal; }");
    html.Logf("    TD.check0 { background-color: #D6D6D6; }");
    html.Logf("    TD.check1 { background-color: #E6E6E6; }");
    html.Logf("    SPAN.checkid { font-family: monospace; }");
    html.Logf("    .pass, .fail { text-align: center; font-weight: bold; font-size: 12px; width: 100px; }");
    html.Logf("    .pass { background-color: Lime; }");
    html.Logf("    .fail { background-color: Red; }");
    html.Logf("    TABLE.stats { width: auto; border: 2px solid gray; margin: 5px; margin-left: 50px; }");
    html.Logf("    TH { background-color: gray; color: white; }");
    html.Logf("    TD.field { background-color: #dddddd; padding: 0px 2px 0px 2px; }");
    html.Logf("    TD.value { font-family: monospace; text-align: right; }");
    html.Logf("    </style>");
}

function _footer()
{
    _stats();
    html.Logf("<hr />");
    html.Logf("<address>Report made by <a href=\"\">UsUnit</a> ("$class'TestBase'.default.USUNIT_VERSION$")</address>");
    html.Logf("</body>");
    html.Logf("</html>");
}

function _stats()
{
    html.Logf("<table class=\"stats\">");
    html.Logf("<tr>");
    html.Logf("    <th colspan=\"2\">Stats</th>");
    html.Logf("</tr>");
    html.Logf("<tr>");
    html.Logf("    <td class=\"field\">Total Time:</td>");
    html.Logf("    <td class=\"value\">"$string(Stats.TotalTime)$" sec</td>");
    html.Logf("</tr>");
    html.Logf("<tr>");
    html.Logf("    <td class=\"field\">Total Tests:</td>");
    html.Logf("    <td class=\"value\">"$string(Stats.TotalTests)$"</td>");
    html.Logf("</tr>");
    html.Logf("<tr>");
    html.Logf("    <td class=\"field\">Success:</td>");
    html.Logf("    <td class=\"value\">"$string(int(round((Stats.TotalCheck-Stats.TotalFail)*100/Stats.TotalCheck)))$"%</td>");
    html.Logf("</tr>");
    html.Logf("</table>");
}