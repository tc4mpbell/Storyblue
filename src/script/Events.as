package script
{
	import components.AboutStoryblue;
	import components.AddChapter;
	import components.ProjectManager;
	import components.RegNagScreen;
	import components.Registration;
	import components.StoryInfo;
	import components.StoryblueHelp;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.TimerEvent;
	import flash.net.*;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.controls.List;
	import mx.controls.Tree;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	public class Events extends EventDispatcher
	{
		private var _app = null;
		private function get app():Storyblue
		{
			if(_app == null)
				_app = FlexGlobals.topLevelApplication as Storyblue;
			
			return _app;
		}
		
		public function Events():void
		{
			//app = mx.core.Application.application as Storyblue;
		}
		
		public static var AutoSaveTimer:Timer;
		public static function StartAutoSaveTimer():void
		{
			AutoSaveTimer = new Timer(500000);
			AutoSaveTimer.addEventListener(TimerEvent.TIMER, function():void
			{
				if(FlexGlobals.topLevelApplication.story.Document.path != "")
				{
					//already saved
					FlexGlobals.topLevelApplication.story.Document.Save();
					FlexGlobals.topLevelApplication.status = "Auto-saved at " + new Date().toLocaleTimeString();
				}
			});
			AutoSaveTimer.start();
		}
		public static function StopAutoSaveTimer():void
		{
			if(AutoSaveTimer != null)
				AutoSaveTimer.stop();
		}
		
		public static var NagTimer:Timer;
		public static function StartRegisterNagTimer():void
		{
			NagTimer = new Timer(800000);
			NagTimer.addEventListener(TimerEvent.TIMER, function():void
			{
				Events.ShowRegisterNagScreen();
			});
			NagTimer.start();
		}
		public static function StopRegisterNagTimer():void
		{
			NagTimer.stop();
		}
		
		static var regNagWinShowing:Boolean = false;
		public static function ShowRegisterNagScreen():void
		{
			if(!regNagWinShowing)
			{
				var nagWin:RegNagScreen = PopUpManager.createPopUp(FlexGlobals.topLevelApplication.parentDocument, RegNagScreen, true) as RegNagScreen;
				PopUpManager.centerPopUp(nagWin);
				regNagWinShowing = true;
				nagWin.addEventListener(Event.CLOSE, function(){
					PopUpManager.removePopUp(nagWin);
					regNagWinShowing = false;
				});
				
			}
		}
		
		var helpWin:StoryblueHelp;
		public function ShowHelp():void
		{
			helpWin = PopUpManager.createPopUp(FlexGlobals.topLevelApplication.parentDocument, StoryblueHelp, true) as StoryblueHelp;
			PopUpManager.centerPopUp(helpWin);
			helpWin.addEventListener(Event.CLOSE, helpWin_CloseDialog);
		}
		public function helpWin_CloseDialog(evt:CloseEvent):void
		{
			PopUpManager.removePopUp(helpWin);
		}
		
		var registerWin:Registration;
		public function ShowRegister():void
		{
			//show popup
			registerWin = PopUpManager.createPopUp(FlexGlobals.topLevelApplication.parentDocument, Registration, true) as Registration;
			PopUpManager.centerPopUp(registerWin);
			registerWin.addEventListener(Event.CLOSE, registerWin_CloseDialog);
		}
		public function registerWin_CloseDialog(evt:CloseEvent):void
		{
			PopUpManager.removePopUp(registerWin);
		}
		
		
		var aboutWin:AboutStoryblue;
		public function ShowAbout():void
		{
			//show popup
			aboutWin = PopUpManager.createPopUp(FlexGlobals.topLevelApplication.parentDocument, AboutStoryblue, true) as AboutStoryblue;
			PopUpManager.centerPopUp(aboutWin);
			aboutWin.addEventListener(Event.CLOSE, aboutWin_CloseDialog);
		}
		public function aboutWin_CloseDialog(evt:CloseEvent):void
		{
			PopUpManager.removePopUp(aboutWin);
		}
		
		public function CheckForUpdates():void
		{
			//go to storyblue.com/updates?v=curVersion
			/*var url:String = "http://storyblue.com/updates.php?v=curVersion";
			var req:URLRequest = new URLRequest(url);
			flash.net.navigateToURL(req);*/
			
			SbUpdater.CheckForUpdates();
			
			/*
			if(!app.story.Document.Saved)
			{
				Alert.show("Updating Storyblue may restart the application; Do you want to save your current project first?", 
					"Save before update?", Alert.YES|Alert.NO, null, 
					function(evt:CloseEvent){
						if(evt.detail == Alert.YES)
						{
							//save before
							app.story.Document.Save(CheckForUpdates);
						}
						else
						{
							mx.core.Application.application.appUpd.checkNow();
						}
					});
			}
			else
			{
				mx.core.Application.application.appUpd.checkNow();
			}*/
		}
		
		public function chapterTitle_change(evt:Event):void
		{
			//{story.xml..chapter.(@title==story.CurrentChapter.@title)[0].@title = txtChapTitle.text}
			//app = 
			app.story.UpdateChapterTitle(app.story.CurrentChapter, app.txtChapTitle.text);
		}
		
		public function textNote_change(evt:Event):void
		{
			//app = mx.core.Application.application as Storyblue;
			app.story.UpdateCard(app.story.CurrentNode, app.textNote.text);
		}
		
		var titleErrorWin:Alert = null;
		public function textNoteTitle_focusOut(evt:FocusEvent):void
		{
			//app = mx.core.Application.application as Storyblue;
			var t:String = app.textNoteTitle.text;
			if(titleErrorWin == null && app.story.CurrentNode != null && t != app.story.CurrentNode.@title)
			{
				if(app.story.cardTitleValid(t))
				{
					var curNode:XML = app.story.CurrentNode;
					app.story.UpdateCardTitle(curNode, t);
				}
				else if(t != "") //if non-empty, must be a duplicate: force change.
				{
					evt.preventDefault();
					Alert.show("Card title already exists as a character, scene or note! Please change the card title.", 
						"Error changing title");
				}
				else	//title is blank
				{
					if(app.textNoteTitle.prompt.length > 0)
					{
						app.textNoteTitle.text = app.textNoteTitle.prompt;
					}
					else
					{
						evt.preventDefault();
						var btnW:Number = Alert.buttonWidth;
						Alert.buttonWidth = 120;
						Alert.cancelLabel = "Remove card";
						Alert.okLabel = "Enter title";
						titleErrorWin = Alert.show("Card title must not be blank! Please specify a title for this card.", 
							"Error changing title", Alert.OK|Alert.CANCEL, null, titleError_Close);
						Alert.cancelLabel = "Cancel";
						Alert.okLabel = "OK";
						Alert.buttonWidth = btnW;
					}
					
					//Alert.show(t);
					
					//app.story.CurrentNode = app.story.xml.cards.card.(@title == "Untitled scene")[0];
				}
			}
		}
		
		private function titleError_Close(evt:CloseEvent):void
		{
			//if OK, return focus to title
			//if Cancel, since new node (blank title), delete
			if(evt.detail == Alert.OK)
			{
				//kewl.
			}
			else if (evt.detail == Alert.CANCEL)
			{
				//remove card
				//Application.application.listChars.setFocus();
				if(app.story.CurrentNode != null) 
				{
					if(app.story.CurrentNode.@title == "" || app.story.CurrentNode.@title == "Untitled " + app.story.CurrentNode.@type)
					{
						FlexGlobals.topLevelApplication.story.DeleteNode(app.story.CurrentNode.@title);
					}
					else
					{
						app.textNoteTitle.text = app.story.CurrentNode.@title;
					}
				}
				
			}
			titleErrorWin = null;
		}
		
		/*
		 Switch chapters.
		*/
		public static function chapterNode_ItemClick(evt:ListEvent):void
		{
			//mx.controls.Alert.show("chap");
			var node:XML = (evt.target as mx.controls.Tree).selectedItem as XML;
			if(node != null && node.attribute("isBranch")[0] == null)	//not folder...
			{
				var app:Storyblue = FlexGlobals.topLevelApplication as Storyblue;
				
				//select Scene accordion
				FlexGlobals.topLevelApplication.accPlan.selectedIndex = 1;
				
				var x:Boolean = app.listScenes.findString(node.@title);
				
				//update current node
				app.story.CurrentNode = app.listScenes.selectedItem as XML;
				
				//update curr chapter
				//app.story.CurrentChapter = node.parent() as XML;
				FlexGlobals.topLevelApplication.story.CurrentChapter = node.parent() as XML;
			}
			else if(node!=null && node.attribute("isBranch")[0] != null)	//is a folder
			{
				//mx.core.Application.application.rteWriter.htmlText = "";
				
				FlexGlobals.topLevelApplication.story.CurrentChapter = node as XML;
				//app.story.CurrentChapter = node as XML;
			}
			//upd text
			
			//TC 11/28/11 Reenabled.
			//AIR 3.0 brought back bug on Windows where the textarea would forever scroll back to the top when typing.
			//This is b/c on change we update the binding source, and apparently that loops back and updated the text area,resetting
			//scroll position. 
			//This might have its own drawbacks, but for now, manually set the chapter text when clicking a node.
			FlexGlobals.topLevelApplication.rteWriter.htmlText = FlexGlobals.topLevelApplication.story.xml.text.chapter.(@title==FlexGlobals.topLevelApplication.story.CurrentChapter.@title)[0];
		}
		
		/*public function notes_Change(e:ListEvent):void
		{
			var node:XML = (e.target as Tree).selectedItem as XML;
			if(node.attribute("isBranch") == null)
			{
				//card
				app.story.CurrentNode = node;
				app.textNoteTitle.setFocus();
			}
			else
			{
				//folder
			}
			if(node!=null)
				app.status = "Editing note \""+ node.@title + "\"";
		}
		*/
		public function node_ItemClick(evt:ListEvent):void
		{
			var node:XML = (evt.target as List).selectedItem as XML;
			
			if(node == null)
			{
				(evt.target as List).selectedIndex = evt.rowIndex;
				node = (evt.target as List).selectedItem as XML;
			}
			
			
			if(node!=null)
			{
				//update current node
				app.story.CurrentNode = node;
				
				app.textNoteTitle.setFocus();

			}
			if(node!=null)
				app.status = "Editing " + node.@type + " \""+ node.@title + "\"";
		}
		
		public function panelWrite_minimize(evt:Event):void
		{
			/*var panelWrite:CollapsiblePanel = app.panelWrite;//evt.currentTarget as CollapsiblePanel;
			var panelPlan:CollapsiblePanel = app.panelPlan;
			
			if(panelPlan.collapsed)
			{
				panelPlan.setStyle("height", 100);//.collapsed = false;//toggleCollapsed();//.dispatchEvent(new Event("restore"));
				panelPlan.invalidateSize();
				panelPlan.invalidateDisplayList();
			}
			
			//panelWrite.setStyle("height", 30);//.height(30);// = 30;//panelWrite.headerHeight;
			//panelWrite.collapsed = true;*/
			
		}
		
		public static function addChar_Click(evt:Event):void
		{
			var s:Storyblue = FlexGlobals.topLevelApplication as Storyblue;
			if(Utilities.Registered() || s.story.Count["CHARACTER"] <= s.story.unregLimit["CHARACTER"])
			{
				s.lblCardTitle.text = "Character Name";
				FlexGlobals.topLevelApplication.story.AddNode("character");
			}
			else
				Utilities.ShowOverUnRegLimit("character");
		}
		public static function addScene_Click(evt:Event):void
		{
			var s:Storyblue = FlexGlobals.topLevelApplication as Storyblue;
			if(Utilities.Registered() || s.story.Count["SCENE"] <= s.story.unregLimit["SCENE"])
			{
				s.lblCardTitle.text = "Scene Title";
				FlexGlobals.topLevelApplication.story.AddNode("scene");
			}
			else
				Utilities.ShowOverUnRegLimit("scene");
		}
		public static function addNote_Click(evt:Event):void
		{
			var s:Storyblue = FlexGlobals.topLevelApplication as Storyblue;
			if(Utilities.Registered() || s.story.Count["NOTE"] <= s.story.unregLimit["NOTE"])
			{
				s.lblCardTitle.text = "Note Title";
				FlexGlobals.topLevelApplication.story.AddNode("note");
			}
			else
				Utilities.ShowOverUnRegLimit("note");
		}
		
		private var addChapWin:AddChapter;
		
		public function addChapter_Click(evt:Event):void
		{
			var s:Storyblue = FlexGlobals.topLevelApplication as Storyblue;
			if(Utilities.Registered() || s.story.Count["CHAPTER"] <= s.story.unregLimit["CHAPTER"])
			{
				//show popup
				addChapWin = PopUpManager.createPopUp(FlexGlobals.topLevelApplication.parentDocument, AddChapter, true) as AddChapter;
				PopUpManager.centerPopUp(addChapWin);
				addChapWin.addEventListener(Event.CLOSE, addChapter_CloseDialog);
			}
			else
				Utilities.ShowOverUnRegLimit("note");
		}
		public function addChapter_CloseDialog(evt:CloseEvent):void
		{
			PopUpManager.removePopUp(addChapWin);
			//evt.
		}
		
		private var storyInfoWin:StoryInfo;
		public function storyInfo_Click(evt:Event):void
		{
			//mx.core.Application.application.story.UpdateTotalWordCount();
			
			storyInfoWin = PopUpManager.createPopUp(FlexGlobals.topLevelApplication.parentDocument, StoryInfo, true) as StoryInfo;
			PopUpManager.centerPopUp(storyInfoWin);
			
			storyInfoWin.addEventListener(Event.CLOSE, function(ev:Event) { PopUpManager.removePopUp(storyInfoWin); });
		}
		
		public function app_Quit(evt:Event):void
		{
			Utilities.ResetFocus();
			
			//check if saved before quitting
			if(!app.story.Document.Saved)
			{
				//cancel default
				evt.preventDefault();
			
				Alert.show("Do you want to save this story before quitting?", "Save this story first?", 
					Alert.YES|Alert.NO|Alert.CANCEL, null, saveFirstBeforeQuit_click);
			}
			else
			{
				//just quit!
				//mx.core.Application.application.nativeApplication.exit();
				Quit();
			}
		}
		private function saveFirstBeforeQuit_click(evt:CloseEvent):void
		{
			if( evt.detail == Alert.YES)	//save 
			{
				app.story.Document.Save(Quit);
			}
			else if (evt.detail != Alert.CANCEL)
			{
				Quit();
			}
		}
		
		public function Quit():void
		{
			var closingEvent:Event = new Event(Event.CLOSING,true,true); 
		    dispatchEvent(closingEvent); 
		    if(!closingEvent.isDefaultPrevented()){ 
		        app.nativeWindow.close(); 
		    } 
			FlexGlobals.topLevelApplication.nativeApplication.exit();
		}
		
		
		private var projManWin:ProjectManager;
		//private var projManWinOpen:Boolean = false;
		public function OpenProjectManager():void
		{
			
			if(!projManWin || !projManWin.isPopUp) 
			{
				projManWin = PopUpManager.createPopUp(FlexGlobals.topLevelApplication.parentDocument, 
					components.ProjectManager, true) as components.ProjectManager;
				projManWin.addEventListener(Event.CLOSE, function(ev:Event):void { 
					
					PopUpManager.removePopUp(projManWin);
				});
			
				PopUpManager.centerPopUp(projManWin);
			}
		}
		
	}
}