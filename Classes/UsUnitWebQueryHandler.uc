/*******************************************************************************
    UsUnitWebQueryHandler
    Web Query handler

    Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

    UsUnit Testing Framework
    Copyright (C) 2005, Michiel "El Muerte" Hendriks

    This program is free software; you can redistribute and/or modify
    it under the terms of the Lesser Open Unreal Mod License.
    <!-- $Id: UsUnitWebQueryHandler.uc,v 1.1 2005/07/23 12:49:32 elmuerte Exp $ -->
*******************************************************************************/

class UsUnitWebQueryHandler extends xWebQueryHandler;

var string uri_css, uri_menu, uri_controls;

function bool Query(WebRequest Request, WebResponse Response)
{
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
	Response.Subst("uri_controls", 	uri_controls);
	Response.Subst("VERSION",       class'TestBase'.default.USUNIT_VERSION);
}

function QueryControls(WebRequest Request, WebResponse Response)
{
    DefSubst(Request, Response);
   	ShowPage(Response, uri_controls);
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