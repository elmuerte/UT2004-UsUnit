/*******************************************************************************
    usugui_MainPage
<p>
    Main GUI page
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
    <!-- $Id: usugui_MainPage.uc,v 1.9 2005/09/23 09:23:41 elmuerte Exp $ -->
*******************************************************************************/

class usugui_MainPage extends FloatingWindow;

var automated GUIButton btnStart, btnConfig;
var automated GUIProgressBar pbGlobal, pbLocal;
var automated moEditBox ebCurrentTest, ebStatsChecks, ebStatsFails, ebStatsTime;
var automated GUITreeListBoxEx tlResults;

var color clGreen, clOrange, clRed;

var UsUnitReplicationInfo RI;

var protected array<int> nodeStack;

event HandleParameters(string Param1, string Param2)
{
    if (Param1 == "1") // readonly
    {
        DisableComponent(btnStart);
    }
    foreach AllObjects(class'UsUnitReplicationInfo', RI) break;
    RI.SetGUIPage(self);
    //tlResults.list.OnDrawItem = OnDrawTreeItem;
}

function bool OnstartClick(GUIComponent Sender)
{
    RI.StartTest();
    return true;
}

function OnDrawTreeItem(Canvas Canvas, int Item, float X, float Y, float W, float HT, bool bSelected, bool bPending)
{
    local int val;
    val = int(tlResults.list.elements[Item].value);
    if (val == 0)
    {
        Canvas.SetPos(X, Y);
        Canvas.DrawTileStretched(material'Engine.WhiteTexture', W, HT);
    }
}

///// output modules forwards

function start()
{
    DisableComponent(btnStart);
    ebStatsChecks.SetText("0");
    ebStatsFails.SetText("0");
    ebStatsTime.SetText("0");
    pbGlobal.value = 0;
    pbGlobal.BarColor = clGreen;
    pbLocal.value = 0;
    pbLocal.BarColor = clGreen;
    ebCurrentTest.SetText("");
    pbLocal.value = 10;
    tlResults.List.Clear();
}

function end()
{
    ebCurrentTest.SetText("");
    pbGlobal.value = 100;
    EnableComponent(btnStart);
}

// name + progress
function testBegin(string test)
{
    local int idx;
    if (nodeStack.length > 0) idx = tlResults.listex.AddChild(test, "-1", nodeStack[0], true);
    else idx = tlResults.listex.AddChild(test, "-1", -1, true);
    tlResults.list.End();
    nodeStack.insert(0, 1);
    nodeStack[0] = idx;

    ebCurrentTest.SetText(test);
    pbLocal.BarColor = clGreen;
    pbLocal.value = 0;
}

function testEnd(string test)
{
    pbLocal.value = 100;
    nodeStack.remove(0, 1);
}

function reportCheck(int CheckId, coerce string Message)
{
    local int idx;
    ebStatsChecks.SetText(string(int(ebStatsChecks.GetText())+1));
    idx = tlResults.listex.AddChild(Message, "-1", nodeStack[0], true, string(CheckId));
    tlResults.list.End();
    nodeStack.insert(0, 1);
    nodeStack[0] = idx;
}

function reportLocalProgress(byte progress)
{
    pbLocal.value = progress;
}

function reportFail(int CheckId, int FailCount)
{
    tlResults.list.SetValueAtIndex(nodeStack[0], "0");
    nodeStack.remove(0, 1);
    pbLocal.BarColor = clRed;
    pbGlobal.BarColor = clOrange;
    ebStatsFails.SetText(string(int(ebStatsFails.GetText())+1));
}

function reportPass(int CheckId)
{
    tlResults.list.SetValueAtIndex(nodeStack[0], "1");
    nodeStack.remove(0, 1);
}

function reportError(string Sender, coerce string Message)
{
}

defaultproperties
{
    clGreen=(R=0,G=255,B=0,A=255)
    clOrange=(R=255,G=128,B=0,A=255)
    clRed=(R=255,G=0,B=0,A=255)

    Begin Object Class=GUIProgressBar Name=x_pbGlobal
        Caption="Overal progress:"
        Low=0
        High=100
        Value=0
        StyleName="TextLabel"
        WinWidth=0.96
        WinHeight=0.060000
        WinLeft=0.02
        WinTop=0.30
        BarColor=(R=0,G=255,B=0)
        CaptionWidth=0.25
        bShowValue=false
        bNeverFocus=true
    End Object
    pbGlobal=x_pbGlobal

    Begin Object Class=GUIProgressBar Name=x_pbLocal
        Caption="Progress:"
        Low=0
        High=100
        Value=0
        StyleName="TextLabel"
        WinWidth=0.96
        WinHeight=0.060000
        WinLeft=0.02
        WinTop=0.23
        BarColor=(R=0,G=255,B=0)
        CaptionWidth=0.25
        bShowValue=false
        bNeverFocus=true
    End Object
    pbLocal=x_pbLocal

    Begin Object Class=moEditBox Name=x_ebCurrentTest
        Caption="Current Test:"
        bReadOnly=true
        WinWidth=0.96
        WinHeight=0.060000
        WinLeft=0.02
        WinTop=0.16
        CaptionWidth=0.25
        bNeverFocus=true
    End Object
    ebCurrentTest=x_ebCurrentTest

    Begin Object Class=GUIButton Name=x_btnStart
        Caption="Start"
        WinWidth=0.13
        WinHeight=0.073021
        WinLeft=0.02
        WinTop=0.06
        OnClick=OnstartClick
    End Object
    btnStart=x_btnStart

    Begin Object Class=GUIButton Name=x_btnConfig
        Caption="Configure"
        WinWidth=0.18
        WinHeight=0.073021
        WinLeft=0.15
        WinTop=0.06
    End Object
    btnConfig=x_btnConfig

    Begin Object Class=moEditBox Name=x_ebStatsChecks
        bReadOnly=True
        bVerticalLayout=True
        LabelJustification=TXTA_Center
        ComponentJustification=TXTA_Center
        Caption="Checks"
        WinTop=0.37
        WinLeft=0.02
        WinWidth=0.3
        WinHeight=0.060000
        bNeverFocus=true
    End Object
    ebStatsChecks=x_ebStatsChecks

    Begin Object Class=moEditBox Name=x_ebStatsFails
        bReadOnly=True
        bVerticalLayout=True
        LabelJustification=TXTA_Center
        ComponentJustification=TXTA_Center
        Caption="Fails"
        WinWidth=0.300000
        WinHeight=0.120000
        WinLeft=0.349531
        WinTop=0.370000
        bNeverFocus=true
    End Object
    ebStatsFails=x_ebStatsFails

    Begin Object Class=moEditBox Name=x_ebStatsTime
        bReadOnly=True
        bVerticalLayout=True
        LabelJustification=TXTA_Center
        ComponentJustification=TXTA_Center
        Caption="Time"
        WinWidth=0.300000
        WinHeight=0.120000
        WinLeft=0.679531
        WinTop=0.370000
        bNeverFocus=true
    End Object
    ebStatsTime=x_ebStatsTime

    Begin Object Class=GUITreeListBoxEx Name=x_tlResults
        bVisibleWhenEmpty=true
        WinWidth=0.960000
        WinHeight=0.436302
        WinLeft=0.020000
        WinTop=0.500000
        FontScale=FNS_Small
    End Object
    tlResults=x_tlResults


    WindowName="UsUnit"
    bAllowedAsLast=true
    //bResizeWidthAllowed=false
    //bResizeHeightAllowed=false

    WinWidth=0.75
    WinHeight=0.5
    WinLeft=0.125
    WinTop=0.25
}