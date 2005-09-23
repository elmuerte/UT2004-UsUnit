/*******************************************************************************
    usugui_MainPage
<p>
    Configure page
</p>
<p>
    Written by: Michiel "El Muerte" Hendriks &lt;elmuerte@drunksnipers.com&gt;
</p>
<p>
    UsUnit Testing Framework -
    Copyright (C) 2005, Michiel "El Muerte" Hendriks
</p>

    This program is free software; you can redistribute and/or modify
    it under the terms of the Lesser Open Unreal Mod License.
    <!-- $Id: usugui_Configure.uc,v 1.2 2005/09/23 09:23:41 elmuerte Exp $ -->
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