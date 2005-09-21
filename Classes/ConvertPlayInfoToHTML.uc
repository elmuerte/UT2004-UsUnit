/*******************************************************************************
    ConvertPlayInfoToHTML
    Convert the data in a PlayInfo record to HTML data. This is a more
    generalized implementation than given by the default WebAdmin.

    Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

    UsUnit Testing Framework
    Copyright (C) 2005, Michiel "El Muerte" Hendriks

    This program is free software; you can redistribute and/or modify
    it under the terms of the Lesser Open Unreal Mod License.
    <!-- $Id: ConvertPlayInfoToHTML.uc,v 1.3 2005/09/21 11:29:43 elmuerte Exp $ -->
*******************************************************************************/
class ConvertPlayInfoToHTML extends Object;

/** includes files for various PlayInfo types */
var(Includes) string incEntry, incTypeCheck, incTypeText, incTypeSelect,
    incTypeSelectOption, incGroupBegin, incGroupEnd, incTypeText_NumEdit,
    incNumEditJS;

/** this array will contain the results, one line per entry */
var array<string> Results;

/** prefix for the replacement variables */
const PREFIX = "PI.";

var string IncludePath;

var bool ShowGroups;

var protected bool incNumEditJS_included;

/** return false to not include a variable */
delegate bool ShowProperty(PlayInfo PI, int idx)
{
    return true;
}

/**
    parses the playinfo to HTML (stored in the Results array, will return true
    when succesfull. If WebRequest is provided all submitted variables in the
    request will also be stored (in case they where encountered). filter can
    be used to only show a certain group.
*/
function bool ParsePlayInfo(PlayInfo PI, WebResponse Response, string Path,
    optional WebRequest Request, optional string filter)
{
    local int i;
    local string NewVal, prevGroup;
    local bool unparsed;

    IncludePath = Path;
    Results.length = 0;

    incNumEditJS_included = false;

    for (i = 0; i < PI.Settings.length; i++)
    {
        if (ShowProperty(PI, i) && ((filter == "") || (PI.Settings[i].Grouping ~= filter)))
        {
            if (Request != none)
            {
                if (PI.Settings[i].ArrayDim >= 0)
                {
                    // compose array
                }
                else if (PI.Settings[i].bStruct)
                {
                    // compose struct !?
                }
                else NewVal = class'UTServerAdmin'.static.HTMLDecode(Request.GetVariable(PI.Settings[i].SettingName, "")); //TODO: undefined
                PI.StoreSetting(i, NewVal, PI.Settings[i].Data);
            }
            if (PI.Settings[i].bStruct) continue; // not supported yet?

            unparsed = false;
            NewVal = "";
            switch (PI.Settings[i].RenderType)
            {
                case PIT_Check:
                    renderCheck(PI, i, Response, NewVal);
                    break;
                case PIT_Select:
                    renderSelect(PI, i, Response, NewVal);
                    break;
                case PIT_Text:
                    renderText(PI, i, Response, NewVal);
                    break;
                case PIT_Custom:
                    if (renderCustom(PI, i, Response, NewVal)) break;
                default: unparsed = true; // unable to render this
            }
            if (unparsed) continue;

            if (ShowGroups && (prevGroup != PI.Settings[i].Grouping))
            {
                if (prevGroup != "") Results[Results.length] = Response.LoadParsedUHTM(IncludePath $ incGroupEnd);
                prevGroup = PI.Settings[i].Grouping;
                //Response.Subst(PREFIX$"Grouping", prevGroup); this is already set
                Results[Results.length] = Response.LoadParsedUHTM(IncludePath $ incGroupBegin);
            }

            Response.Subst(PREFIX$"InputField", NewVal);
            Results[Results.length] = Response.LoadParsedUHTM(IncludePath $ incEntry);
        }
    }
    return true;
}

function defaultSubst(PlayInfo PI, int idx, WebResponse Response)
{
    Response.Subst(PREFIX$"ID", repl(PI.Settings[idx].SettingName, ".", "_"));
    Response.Subst(PREFIX$"SettingName", PI.Settings[idx].SettingName);
    Response.Subst(PREFIX$"DisplayName", PI.Settings[idx].DisplayName);
    Response.Subst(PREFIX$"Description", PI.Settings[idx].Description);
    Response.Subst(PREFIX$"Data", PI.Settings[idx].Data);
    Response.Subst(PREFIX$"ExtraPriv", PI.Settings[idx].ExtraPriv);
    Response.Subst(PREFIX$"Grouping", PI.Settings[idx].Grouping);
    Response.Subst(PREFIX$"SecLevel", PI.Settings[idx].SecLevel);
    Response.Subst(PREFIX$"Value", PI.Settings[idx].Value);
    Response.Subst(PREFIX$"Weight", PI.Settings[idx].Weight);
    Response.Subst(PREFIX$"ClassFrom", PI.Settings[idx].ClassFrom);
}

function renderCheck(PlayInfo PI, int idx, WebResponse Response, out string result)
{
    // no such thing as bool arrays
    defaultSubst(PI, idx, Response);
    if (PI.Settings[idx].Value ~= "True") //TODO: use localized string?
        Response.Subst(PREFIX$"Checked", "checked=\"checked\"");
    else
        Response.Subst(PREFIX$"Checked", "");
    result = Response.LoadParsedUHTM(IncludePath $ incTypeCheck);
}

function renderSelect(PlayInfo PI, int idx, WebResponse Response, out string result)
{
}

function renderText(PlayInfo PI, int idx, WebResponse Response, out string result)
{
    local array<string> entries, args;
    local int i;
    local string incfile;

    incfile = incTypeText;

    defaultSubst(PI, idx, Response);
    Response.Subst(PREFIX$"MaxLength", "");
    Response.Subst(PREFIX$"Size", "80");

    Split(PI.Settings[idx].Data, ";", args);
    if (args.Length < 2) args.Length = 2; //set to minimum required number
    if (args[0] != "")
    {
        Response.Subst(PREFIX$"MaxLength", args[0]);
        Response.Subst(PREFIX$"Size", args[0]);
    }
    if (args[1] != "")
    {
        if (!incNumEditJS_included)
        {
            incNumEditJS_included = true;
            Results[Results.length] = Response.LoadParsedUHTM(IncludePath $ incNumEditJS);
        }
        incfile = incTypeText_NumEdit;
        Response.Subst(PREFIX$"Range", args[1]);
    }

    if (PI.Settings[idx].ArrayDim == -1)
    {
        result = result $ Response.LoadParsedUHTM(IncludePath $ incfile);
        return;
    }
    else {
        SplitArray(PI.Settings[idx].Value, entries);
        if (PI.Settings[idx].ArrayDim > 0) entries.length = PI.Settings[idx].ArrayDim;
        else entries[entries.length] = ""; // to add an extra field for dynamic arrays
    }
    for (i = 0; i < entries.length; i++)
    {
        Response.Subst(PREFIX$"ID", repl(PI.Settings[idx].SettingName, ".", "_")$"_"$string(i));
        Response.Subst(PREFIX$"Value", entries[i]);
        result = result $ Response.LoadParsedUHTM(IncludePath $ incfile);
    }
}

function bool renderCustom(PlayInfo PI, int idx, WebResponse Response, out string result)
{
    return false;
}

static function SplitArray(string in, out array<string> res)
{
    local int i;
    local string tmp;
    local bool isStrings;

    isStrings = Left(in, 2) == "(\"";
    in = Mid(in, 1, len(in)-2); // strip ()
    i = InStr(in, ",");
    while (i > 0)
    {
        if (isStrings && InStr(Mid(in, 1), "\"") > i) // a comma inside a string
        {
            i++;
            while (Mid(in, i, 1) != "\"")
            {
                i++;
                if (Mid(in, i, 1) == "\\") i++; // escaped
            }
            i++; // to be on the , spot
        }
        tmp = Left(in, i);
        in = Mid(in, i+1);
        if (isStrings && Left(tmp, 1) == "\"") tmp = Mid(tmp, 1, len(tmp)-2); // strip "
        res[res.length] = tmp;
        i = InStr(in, ",");
    }
    if (isStrings && Left(in, 1) == "\"") in = Mid(in, 1, len(in)-2); // strip "
    res[res.length] = in;
}

defaultProperties
{
    ShowGroups=true

    incEntry="usunit_pi_entry.inc"
    incTypeCheck="usunit_pi_typecheck.inc"
    incTypeText="usunit_pi_typetext.inc"
    incTypeText_NumEdit="usunit_pi_typetext_numedit.inc"
    incNumEditJS="usunit_numedit_js.inc"
    incGroupBegin="usunit_pi_groupbegin.inc"
    incGroupEnd="usunit_pi_groupend.inc"
}
