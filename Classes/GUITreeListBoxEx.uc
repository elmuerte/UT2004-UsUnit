/*******************************************************************************
    GUITreeListBoxEx
<p>
    Uses the GUITreeListEx as list.
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
    <!-- $Id: GUITreeListBoxEx.uc,v 1.2 2005/09/23 09:23:41 elmuerte Exp $ -->
*******************************************************************************/

class GUITreeListBoxEx extends GUITreeListBox;

/** handle to the GUITreeListEx instance */
var GUITreeListEx ListEx;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.Initcomponent(MyController, MyOwner);
    ListEx = GUITreeListEx(List);
}

defaultproperties
{
    DefaultListClass="UsUnit.GUITreeListEx"
}