/*******************************************************************************
	GUITreeListEx
	Slightly modified GUITreeList, in this one captions are NOT used as keys.
	So a caption can be use more than once. Also it supports subsubitems.

	Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

	UsUnit Testing Framework
	Copyright (C) 2005, Michiel "El Muerte" Hendriks

	This program is free software; you can redistribute and/or modify
	it under the terms of the Lesser Open Unreal Mod License.
	<!-- $Id: GUITreeListEx.uc,v 1.1 2005/07/20 11:46:18 elmuerte Exp $ -->
*******************************************************************************/

class GUITreeListEx extends GUITreeList;

/**
	Add a new child, if parent is -1 is it a root node
*/
function int AddChild(string Caption, string Value, int ParentIndex, optional bool bEnabled, optional string ExtraInfo)
{
	local int idx;

	if ( !bAllowEmptyItems && Caption == "" )
		return -1;

	if ( !bAllowDuplicateCaption && FindIndex(Caption) != -1 )
		return -1;

	if ((ParentIndex != -1) && !IsValidIndex(ParentIndex))
	{
		warn("Invalid parent index value: "$ParentIndex);
		return -1;
	}

	if ( ParentIndex == -1 )
		// root item
		idx = HardInsert( Elements.Length, Caption, Value, "", 0, true, ExtraInfo );
	else {
		// subitem
		idx = ParentIndex+1;
		if (idx < ItemCount) // find index of last child of parent
		{
			while (idx < ItemCount && Elements[idx].Level > Elements[ParentIndex].Level) idx++;
			if (idx < ItemCount) idx--;
		}
		idx = HardInsert( idx, Caption, Value, Elements[ParentIndex].Caption, Elements[ParentIndex].Level + 1, bEnabled, ExtraInfo );
	}

	if (Elements.Length == 1 && bInitializeList)
		SetIndex(0);
	else if ( bNotify )
		CheckLinkedObjects(Self);

	UpdateVisibleCount();
	if (MyScrollBar != None)
		MyScrollBar.AlignThumb();

	return idx;
}

/**
	original code is broken, didn't allow mulitple children in nested levels
*/
function array<int> GetChildIndexList( int idx, optional bool bNoRecurse )
{
	local array<int> Indexes;
	local int Level;

	if ( IsValidIndex(idx) )
	{
		Level = Elements[idx].Level + 1;
		while ( ++idx < ItemCount )
		{
			if ( Elements[idx].Level < Level )
				break;

            // skip all children
			if ( bNoRecurse && Elements[idx].Level > Level )
			{
                while ( ++idx < ItemCount )
                {
                    if ( Elements[idx].Level <= Level ) // same level as ours (or less)
                    {
                        --idx; // because it will be increased next round in the main while loop
                        break;
                    }
                }
				continue;
			}
			Indexes[Indexes.Length] = idx;
		}
	}

	return Indexes;
}

defaultproperties
{
	bAllowDuplicateCaption=true
}