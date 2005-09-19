/*******************************************************************************
    ConvertPlayInfoToHTML
    Convert the data in a PlayInfo record to HTML data. This is a more
    generalized implementation than given by the default WebAdmin.

    Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

    UsUnit Testing Framework
    Copyright (C) 2005, Michiel "El Muerte" Hendriks

    This program is free software; you can redistribute and/or modify
    it under the terms of the Lesser Open Unreal Mod License.
    <!-- $Id: ConvertPlayInfoToHTML.uc,v 1.1 2005/09/19 09:29:10 elmuerte Exp $ -->
*******************************************************************************/
class ConvertPlayInfoToHTML extends Object;

/** includes files for various PlayInfo types */
var(Includes) string incEntry, incTypeCheck, incTypeRadio, incTypeText,
    incTypePassword, incTypeSelect, incTypeSelectOption;

/** this array will contain the results, one line per entry */
var array<string> Results;

/** */
delegate bool ShowProperty(PlayInfo PI, idx)
{
    return true;
}

/**
    parses the playinfo to HTML (stored in the Results array, will return true
    when succesfull. If WebRequest is provided all submitted variables in the
    request will also be stored (in case they where encountered). filter can
    be used to only show a certain group.
*/
function bool ParsePlayInfo(PlayInfo PI, WebResponse Response,
    optional WebRequest Request, optional string filter)
{
    local int i;

    Result.length == 0;
    for (i = 0; i < PI.Settings; i++)
    {
        if (ShowProperty(PI, i) && ((filter == "") || (PI.Settings[i].Grouping ~= filter)))
        {
            switch (PI.Settings[i].RenderType)
            {
                case PIT_Check:
                    renderCheck(PI, i, Response);
                    break;
                case PIT_Select:
                    renderSelect(PI, i, Response);
                    break;
                case PIT_Text:
                    renderText(PI, i, Response);
                    break;
                case PIT_Custom:
                    if (renderCustom(PI, i, Response)) break;
                else continue; // unable to render this
            }
        }
    }
    return true;
}

function renderCheck(PlayInfo PI, int idx, WebResponse Response);

function renderSelect(PlayInfo PI, int idx, WebResponse Response);

function renderText(PlayInfo PI, int idx, WebResponse Response);

function renderCustom(PlayInfo PI, int idx, WebResponse Response)
{
    return false;
}

defaultProperties
{

}
