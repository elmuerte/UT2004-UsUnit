/*******************************************************************************
    UsUnitWebQueryHandler
    Web Query handler

    Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

    UsUnit Testing Framework
    Copyright (C) 2005, Michiel "El Muerte" Hendriks

    This program is free software; you can redistribute and/or modify
    it under the terms of the Lesser Open Unreal Mod License.
    <!-- $Id: UsUnitWebQueryHandler.uc,v 1.3 2005/08/02 08:12:21 elmuerte Exp $ -->
*******************************************************************************/

class UsUnitWebQueryHandler extends xWebQueryHandler;

var TestRunner Runner;

var string uri_css, uri_menu, uri_controls;

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
    }
    return false;
}

function DefSubst(WebRequest Request, WebResponse Response)
{
    Response.Subst("uri_css",       uri_css);
    Response.Subst("uri_menu",      uri_menu);
    Response.Subst("uri_controls",  uri_controls);
    Response.Subst("VERSION",       class'TestBase'.default.USUNIT_VERSION);
}

function QueryControls(WebRequest Request, WebResponse Response)
{
    local string str;
    local int i;

    if (Request.GetVariable("cmd") == "start" && !Runner.isRunning()) Runner.run();

    DefSubst(Request, Response);

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
    //local TestReporter Reporter;
    log("HookOutputModule", name);
    // add our reporter
    /*
    if (OutputModule == none)
    {
        foreach Level.AllActors(class'TestReporter', Reporter) break;
        if (Reporter != none)
            OutputModule = Output_MutatorGUI(Reporter.AddOutputModule(OutputModuleClass));
    }
    */
}

defaultproperties
{
    DefaultPage="usunit_frame"
    Title="UsUnit"
    NeededPrivs=""

    uri_css="usunit.css"
    uri_menu="usunit_menu"
    uri_controls="usunit_controls"
}