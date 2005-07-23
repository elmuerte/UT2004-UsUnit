/*******************************************************************************
    usugui_MainPage
    Configure page

    Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

    UsUnit Testing Framework
    Copyright (C) 2005, Michiel "El Muerte" Hendriks

    This program is free software; you can redistribute and/or modify
    it under the terms of the Lesser Open Unreal Mod License.
    <!-- $Id: usugui_Configure.uc,v 1.1 2005/07/23 12:49:32 elmuerte Exp $ -->
*******************************************************************************/

class usugui_Configure extends FloatingWindow;

defaultproperties
{
    WindowName="UsUnit - Configuration"
    bAllowedAsLast=true
    //bResizeWidthAllowed=false
    //bResizeHeightAllowed=false

    WinWidth=0.75
    WinHeight=0.5
    WinLeft=0.125
    WinTop=0.25
}