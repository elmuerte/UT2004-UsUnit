// NOTICE: This file was automatically generated by UCPP; do not edit this file manualy.
// #pragma ucpp include private.inc

/*******************************************************************************
    UsUnitWebQueryHandler
<p>
    WebAdmin interface for UsUnit. It allows you to run tests, configure it and
    view the results.
</p>
<p>
    Written by: Michiel "El Muerte" Hendriks &lt;elmuerte@drunksnipers.com&gt;
</p>
<p>
    UsUnit Testing Framework -
    Copyright (C) 2005-2006, Michiel "El Muerte" Hendriks
</p>

    This program is free software; you can redistribute and/or modify
    it under the terms of the Lesser Open Unreal Mod License.
    <!-- $Id: UsUnitWebQueryHandler.uc,v 1.21 2006/01/07 17:00:35 elmuerte Exp $ -->
*******************************************************************************/

// #ifdef HAS_WEBADMIN
class UsUnitWebQueryHandler extends xWebQueryHandler;

/** delay between refreshes (in seconds) */
var config int ResultsRefreshDelay;

var TestRunner Runner;

var UsUnitUtils Utils;

/** the output module class to use */
var class<Output_WebAdmin> OutputModuleClass;
var Output_WebAdmin OutputModule;

/** the urls for the various pages */
var string uri_css, uri_menu, uri_controls, uri_results, uri_about, uri_config,
    uri_testinfo, uri_tools;

// #ifdef HAS_PLAYINFO
/** PlayInfo is used to load and show the settings */
var PlayInfo Settings;

/** our playinfo to HTML converter instance */
var ConvertPlayInfoToHTML PI2HTML;
// #endif

static final function string GetPackageName(string FQN)
{
    return Left(FQN, InStr(FQN, "."));
}

function bool Query(WebRequest Request, WebResponse Response)
{
    if (Runner == none) GetTestRunner();
    if (Utils == none) GetUtils();
    // #ifdef HAS_PLAYINFO
    if ((PI2HTML != none) && PI2HTML.Query(Request, Response, Path $ SkinPath)) return true;
    // #endif
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
            Response.SendCachedFile(Path $ SkinPath $ "/" $uri_css, "text/css");
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
            QueryConfig(Request, Response);
            return true;
        case uri_testinfo:
            QueryTestInfo(Request, Response);
            return true;
        case uri_tools:
            QueryTools(Request, Response);
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
    Response.Subst("uri_testinfo",  uri_testinfo);
    Response.Subst("uri_tools",     uri_tools);
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
        Response.Subst("testinfo_class", string(Runner.TestClasses[i]));
        str @= "<li>"$Runner.TestClasses[i].default.TestName$" (<code>"$string(Runner.TestClasses[i])$"</code>)" $
            Response.LoadParsedUHTM(Path $ SkinPath $ "/" $ "usunit_testinfolink.inc")$"</li>";
    }
    str $= "</ol>";
    if (Runner.TestClasses.length > 0) Response.Subst("tests", str);
        else Response.Subst("tests", "<em>none</em>");

    if (Runner.isRunning()) Response.Subst("startcmd", "disabled=\"disabled\" title=\"Tests are still running\"");
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
    local int i, j;
    local string res, res2, pkgname;
    local array< class<TestBase> > FoundClasses;
    local class<Object> cls;
    local array<string> Errors, Messages;
    local bool bSaveRunnerConfig;

    bSaveRunnerConfig = false;

    if (Runner.isRunning())
    {
       Messages[Messages.length] = "<b>Tests are still running.</b> You can not change the configuration while tests are running.";
    }
    else {
        if (Request.GetVariable("action", "") ~= "find_package")
        {
            res = Request.GetVariable("packagename", "");
            if (res != "")
            {
                i = Utils.FindTestClasses(res, FoundClasses, Level.Game);
                if (i == -1)
                {
                    Errors[Errors.length] = "Package '"$res$"' doesn't exist.";
                }
                else if (i == -2)
                {
                    Messages[Messages.length] = "Package '"$res$"' was already loaded, not all classes might have been found.";
                }
                else if (i == 0)
                {
                    Messages[Messages.length] = "No test classes in the package '"$res$"'.";
                }
                //else for (i = 0; i < FoundClasses.length; i++)
                //  log("> "$FoundClasses[i]);
            }
        }
        if (Request.GetVariable("action", "") ~= "find_single")
        {
            res = Request.GetVariable("classname", "");
            if (res != "") //todo, check FQN
            {
                cls = class<Object>(DynamicLoadObject(res, class'class', true));
                if (cls == none)
                {
                    Errors[Errors.length] = "Class '"$res$"' doesn't exist.";
                }
                else if (class<TestBase>(cls) == none) {
                    Errors[Errors.length] = "Class '"$res$"' is not a valid test class.";
                }
                else {
                    FoundClasses[0] = class<TestBase>(cls);
                    if (! Runner.isValidTestClass(FoundClasses[0]))
                    {
                        Errors[Errors.length] = "Class '"$res$"' is not a valid test class.";
                        FoundClasses.remove(0,1);
                    }
                    else {
                        Utils.AddKnownTestClass(cls);
                    }
                }
            }
            else {
                Errors[Errors.length] = "Not a valid class name '"$res$"'. It should be in the form <em>package.class</em>.";
            }
        }

        if (Request.GetVariable("action", "") ~= "remove")
        {
           for (i = 0; i < Request.GetVariableCount("SelectedTests[]"); i++)
           {
               j = int(Request.GetVariableNumber("SelectedTests[]", i, "-1"));
               if ((j > -1) && Runner.RemoveTestClass(j))
               {
                   bSaveRunnerConfig = true;
               }
               else {
                   Errors[Errors.length] = "Failed to remove test class at "$j$".";
               }
           }
        }

        if (Request.GetVariable("action", "") ~= "add_known")
        {
           for (i = Request.GetVariableCount("KnownTests[]")-1; i >= 0; i--)
           {
               res = Request.GetVariableNumber("KnownTests[]", i, "");
               if ((res != "") && Runner.AddTestClass(res))
               {
                   bSaveRunnerConfig = true;
               }
               else {
                   Errors[Errors.length] = "Failed to add test class '"$res$"'.";
               }
           }
        }
        if (Request.GetVariable("up", "") != "")
        {
           j = int(Request.GetVariable("up", "-1"));
           Runner.MoveTestClass(j, j-1);
           bSaveRunnerConfig = true;
        }
        if (Request.GetVariable("down", "") != "")
        {
           j = int(Request.GetVariable("down", "-1"));
           Runner.MoveTestClass(j+1, j);
           bSaveRunnerConfig = true;
        }



        if (bSaveRunnerConfig) Runner.SaveConfig();
    }
    // end processing //


    DefSubst(Request, Response);
    Response.Subst("title", "Configuration");

    res = "";
    for (i = 0; i < Runner.TestClasses.length; i++)
    {
        Response.Subst("check_name", "SelectedTests[]");
        Response.Subst("check_value", string(i));
        Response.Subst("check_checked", "");
        Response.Subst("check_style", "");
        Response.Subst("check_id", "SelectedTests_"$string(i));
        Response.Subst("check_label", Runner.TestClasses[i].default.TestName$" (<code>"$string(Runner.TestClasses[i])$"</code>)");
        if (i > 0) Response.Subst("updown_up", "");
            else Response.Subst("updown_up", "disabled");
        if (i < Runner.TestClasses.length-1) Response.Subst("updown_down", "");
            else Response.Subst("updown_down", "disabled");
        Response.Subst("updown_id", string(i));
        Response.Subst("testinfo_class", string(Runner.TestClasses[i]));
        res $=
            Response.LoadParsedUHTM(Path $ SkinPath $ "/" $ "usunit_updown.inc") $
            Response.LoadParsedUHTM(Path $ SkinPath $ "/" $ "usunit_checkbox.inc") $
            Response.LoadParsedUHTM(Path $ SkinPath $ "/" $ "usunit_testinfolink.inc") $
            "<br />";
    }
    Response.Subst("selected_tests", res);

    res = "";
    pkgname = "";
    for (i = 0; i < Utils.KnownTestClasses.length; i++)
    {
        if (pkgname != GetPackageName(Utils.KnownTestClasses[i]))
        {
            if (pkgname != "")
            {
                Response.Subst("package_name", pkgname);
                Response.Subst("package_tests", res2);
                res = res $ Response.LoadParsedUHTM(Path $ SkinPath $ "/" $ "usunit_testsbypackage.inc");
            }
            res2 = "";
            pkgname = GetPackageName(Utils.KnownTestClasses[i]);
        }

        Response.Subst("check_name", "KnownTests[]");
        Response.Subst("check_value", Utils.KnownTestClasses[i]);
        Response.Subst("check_checked", "");
        Response.Subst("check_style", "");
        Response.Subst("check_id", "KnownTests_"$string(i));
        Response.Subst("check_label", "<code>"$Utils.KnownTestClasses[i]$"</code>");
        Response.Subst("testinfo_class", Utils.KnownTestClasses[i]);

        for (j = 0; j < FoundClasses.length; j++)
        {
            if (string(FoundClasses[j]) ~= Utils.KnownTestClasses[i])
            {
                Response.Subst("check_style", "new");
                FoundClasses.remove(j, 1);
                break;
            }
        }

        res2 = res2 $
            Response.LoadParsedUHTM(Path $ SkinPath $ "/" $ "usunit_checkbox.inc") $
            Response.LoadParsedUHTM(Path $ SkinPath $ "/" $ "usunit_testinfolink.inc") $
            "<br />";
    }
    if (res2 != "")
    {
        Response.Subst("package_name", pkgname);
        Response.Subst("package_tests", res2);
        res $= Response.LoadParsedUHTM(Path $ SkinPath $ "/" $ "usunit_testsbypackage.inc");
    }
    Response.Subst("known_tests", res);

// #ifdef HAS_PLAYINFO
    if (Settings == none)
        Settings = new class'PlayInfo';
    Settings.Clear();
    Runner.static.FillPlayInfo(Settings);

    Settings.Sort(0);
    if (PI2HTML == none)
        PI2HTML = new class'ConvertPlayInfoToHTML';
    if (Request.GetVariable("action", "") ~= "save_settings") // save
    {
        PI2HTML.ParsePlayInfo(Settings, Response, Path $ SkinPath $ "/", Request);
        Settings.SaveSettings();
    }
    else
        PI2HTML.ParsePlayInfo(Settings, Response, Path $ SkinPath $ "/");
    res = "";
    for (i = 0; i < PI2HTML.Results.length; i++)
        res $= PI2HTML.Results[i];
    Response.Subst("settings", res);
// #endif

    // show messages\errors -- must be last
    res = "";
    for (i = 0; i < Errors.length; i++)
    {
        res $= "<li>"$Errors[i]$"</li>";
    }
    if (res != "")
    {
        Response.Subst("message_title", "Errors");
        Response.Subst("message_class", "errors");
        Response.Subst("message_entries", res);
        Response.Subst("errors", Response.LoadParsedUHTM(Path $ SkinPath $ "/" $ "usunit_messages.inc"));
    }
    else Response.Subst("errors", "");

    res = "";
    for (i = 0; i < Messages.length; i++)
    {
        res $= "<li>"$Messages[i]$"</li>";
    }
    if (res != "")
    {
        Response.Subst("message_title", "Messages");
        Response.Subst("message_class", "messages");
        Response.Subst("message_entries", res);
        Response.Subst("messages", Response.LoadParsedUHTM(Path $ SkinPath $ "/" $ "usunit_messages.inc"));
    }
    else Response.Subst("messages", "");

    ShowPage(Response, uri_config);
}

function QueryTestInfo(WebRequest Request, WebResponse Response)
{
    local string cls, res;
    local class<TestBase> tc;
    local int i;

    DefSubst(Request, Response);
    Response.Subst("title", "Test Information");

    cls = Request.GetVariable("class", "");
    if (cls != "")
        tc = class<TestBase>(DynamicLoadObject(cls, class'Class', true));
    if (tc != none)
    {
        Response.Subst("test_title", tc.default.TestName);
        Response.Subst("test_class", string(tc));
        Response.Subst("test_description", tc.default.TestDescription);
        if (class<TestSuite>(tc) != none)
        {
            for (i = 0; i < class<TestSuite>(tc).default.TestClasses.length; i++)
            {
                Response.Subst("testinfo_class", string(class<TestSuite>(tc).default.TestClasses[i]));
                res $= "<code>" $ string(class<TestSuite>(tc).default.TestClasses[i]) $ "</code>" $
                    Response.LoadParsedUHTM(Path $ SkinPath $ "/" $ "usunit_testinfolink.inc") $
                    "<br />";
            }
            Response.Subst("test_childs", res);
        }
        else {
            Response.Subst("test_childs", "Not a test suite.");
        }
    }
    else {
        Response.Subst("test_title", "<span class=\"errors\">Not a valid test class '"$cls$"'</span>");
    }

    ShowPage(Response, uri_testinfo);
}

function QueryTools(WebRequest Request, WebResponse Response)
{
    local array<string> Messages;
    local string res;
    local int i;

    Response.Subst("title", "Tools");
    if (Request.GetVariable("profiler", "") == "start")
    {
        Level.Game.ConsoleCommand("PROFILESCRIPT START");
        Messages[Messages.length] = "Profiler (re)started.";
    }
    else if (Request.GetVariable("profiler", "") == "stop")
    {
        Level.Game.ConsoleCommand("PROFILESCRIPT STOP");
        Messages[Messages.length] = "Profiler stopped.";
    }
    else if (Request.GetVariable("profiler", "") == "reset")
    {
        Level.Game.ConsoleCommand("PROFILESCRIPT RESET");
        Messages[Messages.length] = "Profiler reset.";
    }



    res = "";
    for (i = 0; i < Messages.length; i++)
    {
        res $= "<li>"$Messages[i]$"</li>";
    }
    if (res != "")
    {
        Response.Subst("message_title", "Messages");
        Response.Subst("message_class", "messages");
        Response.Subst("message_entries", res);
        Response.Subst("messages", Response.LoadParsedUHTM(Path $ SkinPath $ "/" $ "usunit_messages.inc"));
    }
    else Response.Subst("messages", "");
    ShowPage(Response, uri_tools);
}

function GetTestRunner()
{
    local float OldfDelayedStart;
    //log("GetTestRunner", name);

    if (Runner == none) // find an existing runner, mostlikely not present
        foreach Level.AllActors(class'TestRunner', Runner) break;

    if (Runner == none)
    {
        //log("creating new test runner class", name);
        OldfDelayedStart = class'TestRunner'.default.fDelayedStart;
        class'TestRunner'.default.fDelayedStart = -1;
        Runner = Level.spawn(class'TestRunner');
        // restore the delayedstart value for the new class and the default (otherwise the configuration gets skewed)
        Runner.fDelayedStart = OldfDelayedStart;
        class'TestRunner'.default.fDelayedStart = OldfDelayedStart;
    }
    HookOutputModule();
    Runner.Initialize();
}

function HookOutputModule()
{
    local TestReporter Reporter;
    //log("HookOutputModule", name);
    // add our reporter
    if (OutputModule == none)
    {
        foreach Level.AllActors(class'TestReporter', Reporter) break;
        if (Reporter != none)
            OutputModule = Output_WebAdmin(Reporter.AddOutputModule(OutputModuleClass));
    }
}

function GetUtils()
{
    if (Utils == none)
        foreach Level.AllObjects(class'UsUnitUtils', Utils) break;

    if (Utils == none)
    {
        Utils = new class'UsUnitUtils';
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
    uri_testinfo="usunit_testinfo"
    uri_tools="usunit_tools"
}
// #else
// class UsUnitWebQueryHandler extends Object;
// // dummy class when there's no UT200x style webadmin
// #endif
