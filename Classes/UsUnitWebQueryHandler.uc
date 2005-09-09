/*******************************************************************************
    UsUnitWebQueryHandler
    Web Query handler. ALPHA

    Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

    UsUnit Testing Framework
    Copyright (C) 2005, Michiel "El Muerte" Hendriks

    This program is free software; you can redistribute and/or modify
    it under the terms of the Lesser Open Unreal Mod License.
    <!-- $Id: UsUnitWebQueryHandler.uc,v 1.7 2005/09/09 20:41:25 elmuerte Exp $ -->
*******************************************************************************/

class UsUnitWebQueryHandler extends xWebQueryHandler;

/** delay between refreshes (in seconds) */
var config int ResultsRefreshDelay;

var TestRunner Runner;

/** the output module class to use */
var class<Output_WebAdmin> OutputModuleClass;
var Output_WebAdmin OutputModule;

/** the urls for the various pages */
var string uri_css, uri_menu, uri_controls, uri_results, uri_about, uri_config;

function bool Query(WebRequest Request, WebResponse Response)
{
    if (Runner == none) GetTestRunner();
    switch (Mid(Request.URI, 1))
    {
        case DefaultPage:
            DefSubst(Request, Response);
            ShowPage(Response, DefaultPage);
            return true;
        case uri_menu:
            DefSubst(Request, Response);
            ShowPage(Response, uri_menu);
            return true;
        case uri_css:
            Response.SendCachedFile(Path$"/"$uri_css, "text/css");
            return true;
        case uri_controls:
            QueryControls(Request, Response);
            return true;
        case uri_results:
            QueryResults(Request, Response);
            return true;
        case uri_about:
            DefSubst(Request, Response);
            Response.Subst("title", "About");
            ShowPage(Response, uri_about);
            return true;
        case uri_config:
            DefSubst(Request, Response);
            QueryConfig(Request, Response);
            return true;
    }
    return false;
}

function DefSubst(WebRequest Request, WebResponse Response)
{
    Response.Subst("uri_css",       uri_css);
    Response.Subst("uri_menu",      uri_menu);
    Response.Subst("uri_controls",  uri_controls);
    Response.Subst("uri_results",   uri_results);
    Response.Subst("uri_config",    uri_config);
    Response.Subst("uri_about",     uri_about);
    Response.Subst("title",         "");
    Response.Subst("VERSION",       class'TestBase'.default.USUNIT_VERSION);
}

function QueryControls(WebRequest Request, WebResponse Response)
{
    local string str;
    local int i;

    if (Request.GetVariable("cmd") == "start" && !Runner.isRunning())
    {
        Runner.run();
        Response.Redirect(Path$"/"$uri_results$"#end");
        return;
    }

    DefSubst(Request, Response);
    Response.Subst("title", "Controls");

    str $= "<ol>";
    for (i = 0; i < Runner.TestClasses.length; i++)
    {
        str @= "<li>"$Runner.TestClasses[i].default.TestName$" (<code>"$string(Runner.TestClasses[i])$"</code>)</li>";
    }
    str $= "</ol>";
    if (Runner.TestClasses.length > 0) Response.Subst("tests", str);
        else Response.Subst("tests", "<em>none</em>");

    if (Runner.isRunning()) Response.Subst("startcmd", "disabled=\"disabled\"");
    else Response.Subst("startcmd", "");

    ShowPage(Response, uri_controls);
}

function QueryResults(WebRequest Request, WebResponse Response)
{
    local int i;
    DefSubst(Request, Response);
    if (Runner.isRunning())
    {
        Response.HTTPResponse("HTTP/1.1 200 Ok");
        Response.HTTPHeader("Refresh: "$string(ResultsRefreshDelay));
    }

    if ((OutputModule != none) && (OutputModule.timestamp != ""))
        Response.Subst("title", "Results - "$OutputModule.timestamp);
    else
        Response.Subst("title", "Results");
    Response.IncludeUHTM(Path $ SkinPath $ "/" $ "usunit_header.inc");

    if (OutputModule != none)
    {
        if (OutputModule.timestamp == "") Response.SendText("<p><em>No test results available</em></p>");
        for (i = 0; i < OutputModule.lines.length; i++)
        {
            Response.SendText(OutputModule.lines[i]);
        }
        if (Runner.isRunning()) Response.SendText(OutputModule.closure());
    }

    Response.SendText("<a name=\"end\"></a>");
    Response.IncludeUHTM(Path $ SkinPath $ "/" $ "usunit_footer.inc");
}

function QueryConfig(WebRequest Request, WebResponse Response)
{
    local int i;
    local string res;

    DefSubst(Request, Response);
    Response.Subst("title", "Configuration");

    res = "";
    for (i = 0; i < Runner.TestClasses.length; i++)
    {
        Response.Subst("check_name", "SelectedTests_"$string(i));
        Response.Subst("check_value", string(Runner.TestClasses[i]));
        Response.Subst("check_checked", "");
        Response.Subst("check_id", string(i));
        Response.Subst("check_label", Runner.TestClasses[i].default.TestName$" (<code>"$string(Runner.TestClasses[i])$"</code>)");
        res = res$Response.LoadParsedUHTM(Path $ SkinPath $ "/" $ "usunit_checkbox.inc");
    }
    Response.Subst("selected_tests", res);

    ShowPage(Response, uri_config);
}

function GetTestRunner()
{
    local float OldfDelayedStart;
    log("GetTestRunner", name);

    if (Runner == none) // find an existing runner, mostlikely not present
        foreach Level.AllActors(class'TestRunner', Runner) break;

    if (Runner == none)
    {
        log("creating new test runner class", name);
        OldfDelayedStart = class'TestRunner'.default.fDelayedStart;
        class'TestRunner'.default.fDelayedStart = -1;
        Runner = Level.spawn(class'TestRunner');
        class'TestRunner'.default.fDelayedStart = OldfDelayedStart;
    }
    HookOutputModule();
    Runner.Initialize();
}

function HookOutputModule()
{
    local TestReporter Reporter;
    log("HookOutputModule", name);
    // add our reporter
    if (OutputModule == none)
    {
        foreach Level.AllActors(class'TestReporter', Reporter) break;
        if (Reporter != none)
            OutputModule = Output_WebAdmin(Reporter.AddOutputModule(OutputModuleClass));
    }
}

defaultproperties
{
    OutputModuleClass=class'Output_WebAdmin'
    ResultsRefreshDelay=2

    DefaultPage="usunit_frame"
    Title="UsUnit"
    NeededPrivs=""

    uri_css="usunit.css"
    uri_menu="usunit_menu"
    uri_controls="usunit_controls"
    uri_results="usunit_results"
    uri_config="usunit_config"
    uri_about="usunit_about"
}