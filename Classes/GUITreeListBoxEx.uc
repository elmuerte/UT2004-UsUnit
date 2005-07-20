/*******************************************************************************
	GUITreeListBoxEx
	Uses the GUITreeListEx as list.

	Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

	UsUnit Testing Framework
	Copyright (C) 2005, Michiel "El Muerte" Hendriks

	This program is free software; you can redistribute and/or modify
	it under the terms of the Lesser Open Unreal Mod License.
	<!-- $Id: GUITreeListBoxEx.uc,v 1.1 2005/07/20 11:46:18 elmuerte Exp $ -->
*******************************************************************************/

class GUITreeListBoxEx extends GUITreeListBox;

var	GUITreeListEx ListEx;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	ListEx = GUITreeListEx(List);
}

defaultproperties
{
	DefaultListClass="UsUnit.GUITreeListEx"
}