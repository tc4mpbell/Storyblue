
import air.update.ApplicationUpdaterUI;
import air.update.events.UpdateEvent;

import components.GoalsAndCharts;

import flash.display.NativeMenuItem;
import flash.display.StageDisplayState;
import flash.events.ContextMenuEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.filesystem.File;
import flash.system.Capabilities;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;

import gearsandcogs.text.UndoTextFields;

import mx.binding.utils.ChangeWatcher;
import mx.controls.Alert;
import mx.controls.List;
import mx.controls.listClasses.*;
import mx.controls.treeClasses.*;
import mx.core.Application;
import mx.core.FlexGlobals;
import mx.events.FlexEvent;
import mx.events.FlexNativeMenuEvent;
import mx.events.IndexChangedEvent;
import mx.events.ListEvent;
import mx.events.ResizeEvent;

import script.*;

public var story:Story = new Story();
public var events:Events = new Events();

private var listContextMenu:ContextMenu = null;

public var appUpd:ApplicationUpdaterUI;

private var invokedWithPath:String = "";

[Bindable]
public var doAutoSave:Boolean = true;

private function onAppInvoke(evt:InvokeEvent):void
{
	var path:String = evt.arguments[0];
	if(path!=null && path!="")
	{
		story.Document.loadFile(new flash.filesystem.File(path));
		
		invokedWithPath = path;
//		startupDoc = path;
		//mx.controls.Alert.show("loading: " + path);
		//
	}
	//invokedWithPath = "hehejhe";
	
	if(invokedWithPath == "")
	{
		events.OpenProjectManager();
	}

}
/*
function GetChapterText():String
{
	//don't unsave because of this change...
	var saved:Boolean = (mx.core.Application.application as Storyblue).story.Document.Saved;
	
	var newText:String = Utilities.StyleText(story.xml.text.chapter.(@title==story.CurrentChapter.@title)[0]);
	
	if(saved)
		story.Document.Saved = true;
	
	return newText;
}*/

function app_complete():void
{	
	/*appUpd = new ApplicationUpdaterUI();
	appUpd.configurationFile = new File("app:/config/update.xml");
	appUpd.addEventListener(ErrorEvent.ERROR, onUpdateError);
	appUpd.addEventListener(UpdateEvent.INITIALIZED, onUpdate);
	
	appUpd.addEventListener(UpdateEvent.BEFORE_INSTALL, update_beforeInstall);
	
	appUpd.isCheckForUpdateVisible = false;
	appUpd.isFileUpdateVisible = false;
	appUpd.isInstallUpdateVisible = false;

	appUpd.initialize();*/
	events.CheckForUpdates();
}
function onUpdateError(evt:ErrorEvent):void
{
	mx.controls.Alert.show(evt.text);
}

function update_beforeInstall(evt:UpdateEvent):void
{
	events.app_Quit(evt as Event);
}


private function app_exiting(evt:Event)
{
	events.app_Quit(evt);
} 

//
function goFullScreen():void
{
	this.nativeWindow.maximize();//.stage.displayState = flash.display.StageDisplayState.FULL_SCREEN_INTERACTIVE;
}

function app_init(evt:Event):void
{
	story = new Story();
	//events = new Events();
}

function app_loaded(evt:Event):void
{
	
	//RubenG -- Center the application window on startup
	
	nativeWindow.x = (Capabilities.screenResolutionX - nativeWindow.width) / 2;
	nativeWindow.y = (Capabilities.screenResolutionY - nativeWindow.height) / 2;
	
	this.nativeApplication.addEventListener(Event.EXITING, app_exiting);
	
	btnStoryInfo.addEventListener(MouseEvent.CLICK, showStoryStats);
	
	//BindingUtils.bindSetter(updateWordCount, rteWriter, "text");
	
	rteWriter.addEventListener(Event.CHANGE, rteWriter_change);
	rteWriter.addEventListener(FlexEvent.CREATION_COMPLETE, rteWriter_load);
	rteWriter.addEventListener(FocusEvent.FOCUS_OUT, rteWriter_focusOut);
	
	tabsMain.addEventListener(IndexChangedEvent.CHANGE, tabChanged);
	
	//mx.core.Application.application.panelWrite.addEventListener("minimize", new Events().panelWrite_minimize);
	treeChapters.addEventListener("dragEnter", DragDrop.chapters_DragEnter);
	treeChapters.addEventListener("dragOver", DragDrop.chapters_DragOver);
	treeChapters.addEventListener("dragDrop", DragDrop.chapters_DragDrop);
	treeChapters.addEventListener("dragComplete", DragDrop.chapters_DragComplete);	
	treeChapters.contextMenu = ChapterTreeContextMenu;//.addEventListener(FlexEvent.INITIALIZE, chapterList_Load);
	
	btnAddChar.addEventListener(MouseEvent.CLICK, script.Events.addChar_Click);
	btnAddScene.addEventListener(MouseEvent.CLICK, script.Events.addScene_Click);
	btnAddNote.addEventListener(MouseEvent.CLICK, script.Events.addNote_Click);
	
	btnAddChapter.addEventListener(MouseEvent.CLICK, events.addChapter_Click);
	
	//set up planning nodes menu!
	listContextMenu = PlanningListContextMenu;
	
	textNote.enabled = false;
	textNoteTitle.enabled = false;
	rteWriter.enabled = false;
	rteWriter.textArea.enabled = false;
	txtChapTitle.enabled = false;
	
	textNote.addEventListener(FocusEvent.FOCUS_OUT, events.textNote_change);
	textNoteTitle.addEventListener(FocusEvent.FOCUS_OUT, events.textNoteTitle_focusOut);
	textNote.addEventListener(TextEvent.TEXT_INPUT, setUnsaved );
	
	rteWriter.textArea.addEventListener(TextEvent.TEXT_INPUT, setUnsaved);
	
	txtChapTitle.addEventListener(FocusEvent.FOCUS_OUT, events.chapterTitle_change);
	
	btnStoryInfo.addEventListener(MouseEvent.CLICK, events.storyInfo_Click);
	
	btnDeleteCard.addEventListener(MouseEvent.CLICK, btnDeleteCard_click);
	lnkDelChap.addEventListener(MouseEvent.CLICK, lnkDelChap_click);
	
	if(!Utilities.Registered())
	{
		Events.StartRegisterNagTimer();
	}
	
	
	//Auto Save: only can do if we've saved at least once.
	
	var settings = new Settings();
	if(settings.Get("AutoSaveSbProject") == null || settings.Get("AutoSaveSbProject")['val'] == "true")
	{
		doAutoSave = true;
		Events.StartAutoSaveTimer();
	}
	else
	{
		doAutoSave = false;
	}
	
}

private function setUnsaved(ev:Event)
{
	if(story.Document.Saved)
		story.Document.Saved = false;
}

private function richTextEditor_resize(evt:ResizeEvent):void
{
	/*if(rteWriter.width > 900)
	{
		rteWriter.textArea.setStyle("paddingLeft", (rteWriter.width-900)/2);
		rteWriter.textArea.setStyle("paddingRight", (rteWriter.width-900)/2);
	}
	else
	{
		rteWriter.textArea.setStyle("paddingLeft", 10);
		rteWriter.textArea.setStyle("paddingRight", 10);
	}*/
}


function storyTitle_change(evt:Event):void
{
	story.xml.general.@title = txtTitle.text; 
	
	this.title = txtTitle.text + " - Storyblue";
	
	story.Document.Saved = false;
}

function showStoryStats(evt:Event):void
{
	//var numChars:int = story.xml.cards.card.(@type=='character').length();
	//var numScenes:int = story.xml.cards.card.(@type=='scene').length();
	//var numNotes:int = story.xml.cards.card.(@type=='note').length();
	
	//var chapterWords:int = Utilities.countWords(rteWriter.text);
	//var totalWords:int = story.TotalWordCount;
	
}


function  rteWriter_change(evt:Event):void
{
	//story.TodaysWordCount = Utilities.countWords(rteWriter.text);
	//story.TotalWordCount.toString();
	try
	{
		//if don't have <text> nodes, add that.
		
		//TC 11/28/11 If rteWriter is set to bind to that xml property, this will break in Windows (AIR 3) and continually scroll to the top.
		(story.xml.text.chapter.(@title==story.CurrentChapter.@title)[0] as XML).children()[0] = Utilities.cdata(rteWriter.htmlText);
	}
	catch(e:Error){
	}
	
}
function  rteWriter_focusOut(evt:FocusEvent):void
{
	
	//story.xml.text.chapter.(@title==story.CurrentChapter.@title)[0] = Utilities.cdata(rteWriter.htmlText);
}
function rteWriter_load(evt:Event):void
{
	//rteWriter.htmlText = story.xml.text.chapter.(@title==story.CurrentChapter.@title)[0];
}

private function tabChanged(evt:IndexChangedEvent):void
{
	if(evt.newIndex == 1) //if goals tab
	{
		goalsAndCharts.loadList();
	}
}


private function get ChapterTreeContextMenu():ContextMenu
{
	//create menu
	var cm:ContextMenu = new ContextMenu();
	var addChap:NativeMenuItem = new NativeMenuItem("Add Chapter");
	addChap.addEventListener(Event.SELECT, events.addChapter_Click);
	cm.customItems.push(addChap);
	
	cm.addEventListener(flash.events.ContextMenuEvent.MENU_SELECT, chapterListMenu_Open);
	
	return cm;
}

private function chapterListMenu_Open(event:ContextMenuEvent):void
{
	var _list:List = event.contextMenuOwner as List;
	var cm:ContextMenu = event.currentTarget as ContextMenu;
	
    var obj:InteractiveObject = event.mouseTarget;
    var item:XML;
    do
    {
        if (obj is mx.controls.treeClasses.TreeItemRenderer) {
            item = (obj as mx.controls.treeClasses.TreeItemRenderer).data as XML;
            _list.selectedItem = item;
            
            if(cm.customItems.length > 1)
            	cm.customItems.shift();
            	
            var cmiDel:ContextMenuItem = new ContextMenuItem("Delete " + item.@title);
            cmiDel.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, deleteChapterMenuItem_Select);
            cm.customItems.unshift(cmiDel);
           	
            return;
        }
       
        obj = obj.parent;
    }while (obj.parent);
}
private var chapToDel:String = null;
private function deleteChapterMenuItem_Select(evt:ContextMenuEvent):void
{
	var cmi:ContextMenuItem = evt.currentTarget as ContextMenuItem;
	chapToDel = cmi.label.replace(/Delete /, "");	
	
	deleteChapter();
}

private function lnkDelChap_click(ev:MouseEvent):void
{
	if(story.CurrentChapter != null)
	{
		chapToDel = story.CurrentChapter.@title;
		deleteChapter();
	}
		
}

private function deleteChapter()
{
	var node:XML = FlexGlobals.topLevelApplication.story.xml.chapters.chapter.(@title==chapToDel)[0];
	
	var alertText:String = "Are you sure you want to delete \"" + chapToDel + "\"?";
	var isFolder:Boolean = true;
	if(node == null) 	//chapter scene
	{
		isFolder = false;
		alertText += "\nThis won't delete the original scene, just remove it from the chapter.";
		node = FlexGlobals.topLevelApplication.story.xml.chapters.chapter.chapterScene.(@title==chapToDel)[0];
	}
	
	mx.controls.Alert.show(alertText, "Confirm delete", 
					Alert.YES|Alert.CANCEL, null, function(ev:mx.events.CloseEvent):void
					{
						if(ev.detail == Alert.YES)
						{
							//remove item from list
							if(chapToDel!=null)
							{
								
								//if folder
								if(isFolder)
								{
									delete FlexGlobals.topLevelApplication.story.xml.chapters.chapter.(@title==chapToDel)[0];
									delete FlexGlobals.topLevelApplication.story.xml.text.chapter.(@title==chapToDel)[0];
									FlexGlobals.topLevelApplication.story.CurrentChapter = null;
									
									FlexGlobals.topLevelApplication.story.Count["CHAPTERS"]--;
								}
								else
								{
									//chap item
									delete FlexGlobals.topLevelApplication.story.xml.chapters.chapter.chapterScene.(@title==chapToDel)[0];
								}
								FlexGlobals.topLevelApplication.story.Document.Saved = false;
								chapToDel = null;
							}
						}
					}
				);
}


function get PlanningListContextMenu():ContextMenu
{
	if(listContextMenu == null)
	{
		//create menu
		var cm:ContextMenu = new ContextMenu();
		
		var addChar:NativeMenuItem = new NativeMenuItem("Add Character");
		var addScene:NativeMenuItem = new NativeMenuItem("Add Scene");
		var addNote:NativeMenuItem = new NativeMenuItem("Add Note");
		
		addChar.addEventListener(Event.SELECT, Events.addChar_Click);
		addScene.addEventListener(Event.SELECT, Events.addScene_Click);
		addNote.addEventListener(Event.SELECT, Events.addNote_Click);
		
		cm.customItems.push(addChar);
		cm.customItems.push(addScene);
		cm.customItems.push(addNote);
		
		//add to lists
		//listScenes.contextMenu = cm;
		//listNotes.contextMenu = cm;
		//listChars.contextMenu = cm;
		return cm;
	}
	else
	{
		return listContextMenu;
	}
}

private function planningListContextMenu_Open(event:ContextMenuEvent):void
{
	var _list:List = event.contextMenuOwner as List;
	var cm:ContextMenu = event.currentTarget as ContextMenu;
	
    var obj:InteractiveObject = event.mouseTarget;
    var item:XML;
    do
    {
        if (obj is mx.controls.listClasses.ListItemRenderer) {
            item = (obj as mx.controls.listClasses.ListItemRenderer).data as XML;
            _list.selectedItem = item;
            
            if(cm.customItems.length > 3)
            	cm.customItems.shift();
            	
            var cmiDel:ContextMenuItem = new ContextMenuItem("Delete " + item.@title);
            cmiDel.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, deleteMenuItem_Select);
            cm.customItems.unshift(cmiDel);
           	
            return;
        }
       
        obj = obj.parent;
    }while (obj.parent);
    
    //cmi.caption = "Some Context Item";
    //cmi.enabled = false;
}

private var itemToDel:String = null;
private function deleteMenuItem_Select(evt:ContextMenuEvent):void
{
	var cmi:ContextMenuItem = evt.currentTarget as ContextMenuItem;
	itemToDel = cmi.label.replace(/Delete /, "");
	
	deleteCard();
}

private function btnDeleteCard_click(evt:MouseEvent)
{
	if(story.CurrentNode != null)
	{
		itemToDel = story.CurrentNode.@title;
		deleteCard();
	}
}

private function deleteCard():void
{
	if(itemToDel != null)
	{
		mx.controls.Alert.show("Are you sure you want to delete \"" + itemToDel + "\"?", "Confirm delete", 
						Alert.YES|Alert.CANCEL, null, function(ev:mx.events.CloseEvent)
						{
							if(ev.detail == Alert.YES)
							{
								if(itemToDel!=null)
								{
									story.DeleteNode(itemToDel);
									itemToDel = null;
								}
							}
						}
					);
	}
}

function scenes_loaded(evt:Event):void
{
	listScenes.contextMenu = PlanningListContextMenu;
	
	listScenes.contextMenu.addEventListener(flash.events.ContextMenuEvent.MENU_SELECT, planningListContextMenu_Open);
	
}
function chars_loaded(evt:Event):void
{
	listChars.contextMenu = PlanningListContextMenu;
	listChars.contextMenu.addEventListener(flash.events.ContextMenuEvent.MENU_SELECT, planningListContextMenu_Open);
}

function notes_loaded(evt:Event):void
{
	listNotes.contextMenu = PlanningListContextMenu;
	listNotes.contextMenu.addEventListener(flash.events.ContextMenuEvent.MENU_SELECT, planningListContextMenu_Open);
}

function menuMain_ItemClick(evt:FlexNativeMenuEvent)
{
	switch(evt.label)
	{
		case "New":
			story.Document.New();
		break;
		case "Open File...":
			story.Document.Load();
		break;
		case "Recent Projects":
			events.OpenProjectManager();
		break;
		case "Save":
			story.Document.Save();
		break;
		case "Save as...":
			story.Document.SaveAs();
		break;
		case "Export Story to RTF":
			story.Document.showSaveAsDialog(story.Document.rtfExportFile_selected, story.xml.general.@title + ".rtf");//.ExportStoryToPDF();
			break;
		case "Export Story to PDF":
			story.Document.showSaveAsDialog(story.Document.pdfExportFile_selected, story.xml.general.@title + ".pdf");//.ExportStoryToPDF();
		break;
		case "Export Story to HTML":
			story.Document.showSaveAsDialog(story.Document.htmlExportFile_selected, story.xml.general.@title + ".html");
			//story.Document.ExportStoryToHTML();
		break;
		case "Export Characters/Scenes/Notes to HTML":
			story.Document.showSaveAsDialog(story.Document.htmlExportCards_selected, story.xml.general.@title + " -- Notes.html");
			//story.Document.ExportNotesToHTML();
		break;
		case "Exit":
			var e:Event = new Event(Event.EXITING);
			this.nativeApplication.dispatchEvent(e);
		break;
		
		/*case "Undo":
			this.nativeApplication.undo();
			break;
		case "Redo":
			this.nativeApplication.redo();
			break;*/
		
		case "Copy":
			this.nativeApplication.copy();
		break;
		case "Cut":
			this.nativeApplication.cut();
		break;
		case "Paste":
			this.nativeApplication.paste();
		break;
		case "Select All":
			this.nativeApplication.selectAll();
		break;
		
		case "Auto-save":
			var sett:Settings = new Settings();
			if(!evt.nativeMenuItem.checked)//"true")	//stop
			{
				doAutoSave = false;
				Events.StopAutoSaveTimer();
				sett.Set("AutoSaveSbProject", "false");
			}
			else
			{
				doAutoSave = true;
				Events.StartAutoSaveTimer();
				sett.Set("AutoSaveSbProject", "true");
			}
		break;
		
		case "Full-screen":
			if(evt.nativeMenuItem.checked)
			{
				goFullScreen();
			}
			else
			{
				this.nativeWindow.restore();
			}
		break;
		
		case "Help":
			events.ShowHelp();
		break;
		case "Register":
			events.ShowRegister();
		break;
		case "Check for updates":
			events.CheckForUpdates();
		break;
		case "About Storyblue":
			events.ShowAbout();
		break;
	}
}

private function keyEquivalentModifiers(item:Object):Array
{
	//var isWin:Boolean = (Capabilities.os.indexOf("Windows") >= 0);
	var isMac:Boolean = (Capabilities.os.indexOf("Mac OS") >= 0);
	
	var result:Array = new Array();
	
	var keyEquivField:String = menu.keyEquivalentField;
	var altKeyField:String;
	var ctrlKeyField:String;
	var shiftKeyField:String;
	if (item is XML)
	{
		altKeyField = "@altKey";
		ctrlKeyField = "@ctrlKey";
		shiftKeyField = "@shiftKey";
	}
	else if (item is Object)
	{
		altKeyField = "altKey";
		ctrlKeyField = "ctrlKey";
		shiftKeyField = "shiftKey";
	}
	
	if (item[keyEquivField] == null || item[keyEquivField].length == 0)
	{
		return result;
	}
	
	if (item[altKeyField] != null && item[altKeyField] == true)
	{
		if (!isMac)
		{
			result.push(Keyboard.ALTERNATE);
		}
	}
	
	if (item[ctrlKeyField] != null && item[ctrlKeyField] == true)
	{
		if (!isMac)
		{
			result.push(Keyboard.CONTROL);
		}
		else if (isMac)
		{
			result.push(Keyboard.COMMAND);
		}
	}
	
	if (item[shiftKeyField] != null && item[shiftKeyField] == true)
	{
		result.push(Keyboard.SHIFT);
	}
	
	return result;
}


function chapterNode_ItemClick(e:ListEvent)
{
	script.Events.chapterNode_ItemClick(e);
}

function node_ItemClick(e:ListEvent)
{
	events.node_ItemClick(e);
}
/*
function notes_Change(e:ListEvent)
{
	events.notes_Change(e);
}*/