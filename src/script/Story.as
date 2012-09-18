package script
{
	import mx.collections.XMLListCollection;
	import mx.containers.Accordion;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import script.story.StoryFile;
	
	public class Story
	{
		public var settings:Settings;
		
		public function get StoryID():String
		{
			if(xml.general.attribute("id") == null || xml.general.attribute("id") == "")
				xml.general.@id = Utilities.GenerateStoryID();
			
			return xml.general.attribute("id");
		}
		
		public var unregLimit = {
			CHARACTER: 5,
			SCENE: 5,
			NOTE: 5,
			CHAPTER: 3
		};
		
		public var Count = {
			CHARACTER: 0,
			SCENE: 0,
			NOTE: 0,
			CHAPTER: 0
		}
		
		private var _app:Storyblue = null;
		private function get app():Storyblue
		{
			
			if(_app == null)
				_app = FlexGlobals.topLevelApplication as Storyblue;
			return _app;
		}
		
		//member vars
		//public var app:Storyblue;
		
		public var Document:StoryFile;
		
		private var newCharNum:int = 1;
		private var newSceneNum:int = 1;
		private var newNoteNum:int = 1;
		
		private var startDate:Date;
		public function get StartDate():Date
		{
			if(startDate == null)
			{
				if(settings.Get("StartDate_" + StoryID) == null)
				{
					settings.Set("StartDate_" + StoryID, new Date().toDateString());
					startDate = new Date();
				}
				
				startDate = new Date(Date.parse(settings.Get("StartDate_" + StoryID)["val"]));
			}
			return startDate;
		}
		public function set StartDate(val:Date):void
		{
			startDate = val;
		}
		
		private var _currentChapter:XML;
		[Bindable]
		public function get CurrentChapter():XML
		{
			return _currentChapter;
		}
		public function set CurrentChapter(val:XML):void
		{
			//enable story textboxes
			if(val!=null)
			{
				app.rteWriter.enabled = true;
				app.rteWriter.textArea.enabled = true;
				app.txtChapTitle.enabled = true;
				
				app.lnkDelChap.enabled = true;
				
				app.rteWriter.textArea.setFocus();
				//(app.rteWriter.textArea as mx.controls.TextArea).alpha = 100;
				
				//app.rteWriter.htmlText = "heloo";
				
				var html:String = (xml.text.chapter.(@title==val.@title)[0] as XML).children()[0];
				(xml.text.chapter.(@title==val.@title)[0] as XML).children()[0] = Utilities.StyleText(html);
			}
			else
			{
				app.rteWriter.enabled = false;
				app.rteWriter.textArea.enabled = false;
				app.rteWriter.textArea.text = "";
				app.txtChapTitle.enabled = false;
				app.lnkDelChap.enabled = false;
			}
			
			_currentChapter = val;
			
			app.chapterTextBox.executeChildBindings(true);
		}
		
		public var lastNode:XML;
		public var _currentNode:XML;
		[Bindable]
		public function get CurrentNode():XML
		{
			return _currentNode;
		}
		public function set CurrentNode(value:XML):void
		{
			if(value == null)
			{
				FlexGlobals.topLevelApplication.btnDeleteCard.enabled = false;
				FlexGlobals.topLevelApplication.textNote.enabled = false;
				FlexGlobals.topLevelApplication.textNoteTitle.enabled = false;
				FlexGlobals.topLevelApplication.textNoteTitle.prompt = "";
				FlexGlobals.topLevelApplication.btnAddChar.setFocus();
			}
			else
			{
				lastNode = _currentNode;
				
				FlexGlobals.topLevelApplication.btnDeleteCard.enabled = true;
				
				//enable note textboxes
				FlexGlobals.topLevelApplication.textNote.enabled = true;
				FlexGlobals.topLevelApplication.textNoteTitle.enabled = true;
				FlexGlobals.topLevelApplication.textNoteTitle.setFocus();
				//set other list's selected indexes to -1
				
				//find currently open list in accordion.
				var curListIx:int = FlexGlobals.topLevelApplication.accPlan.selectedIndex;
				
				var sc = FlexGlobals.topLevelApplication.listScenes;
				var no = FlexGlobals.topLevelApplication.listNotes;
				//var no = Application.application.treeNotes;
				var ch = FlexGlobals.topLevelApplication.listChars;
				
				if(curListIx == 0) //characters
				{
					FlexGlobals.topLevelApplication.lblCardTitle.text = "Character Name";
					//-1 on scenes, notes
					if(no!=null) no.selectedIndex = -1;
					if(sc!=null) sc.selectedIndex = -1;
				}
				else if(curListIx == 1)	//scenes
				{
					FlexGlobals.topLevelApplication.lblCardTitle.text = "Scene Title";
					//-1 on chars, notes
					if(no!=null) no.selectedIndex = -1;
					if(ch!=null) ch.selectedIndex = -1;
				}
				else if(curListIx == 2)	//notes
				{
					FlexGlobals.topLevelApplication.lblCardTitle.text = "Note Title";
					//-1 on scenes, chars
					if(ch!=null) ch.selectedIndex = -1;
					if(sc!=null) sc.selectedIndex = -1;
				}
			}
			
			_currentNode = value;
		}
		
		[Bindable]
		public var xml:XML;
		
		/*[Bindable]
		public var cards:XML;
		
		[Bindable]
		public var chapters:XML;// 		= ["hello"];*/
		
		[Bindable]
		public var chaptersData:XMLListCollection;
		
		//[Bindable]
		//public var notesData:XMLListCollection;
		
		public function Story()
		{
			Document = new StoryFile(this);
			
			Init();
			
			settings = new Settings();
			
			/*if(app.startupDoc != null && app.startupDoc != "")
			{
				Document.loadFile(new flash.filesystem.File(app.startupDoc));
			}*/
			
			Document.Saved = true;
		}
		
		//Initialize new story with default data
		public function Init(storyXml:XML = null):void
		{
			if(storyXml == null)
			{
				xml = <story>
					<general id="" title="Untitled Story" author="">
						<stats>
							
						</stats>
						<goals>
							
						</goals>
					</general>
					<cards>
						<card type="character" title="Sample Character">
							{Utilities.cdata("Describe your character here; Role in the story, physical appearance, personality, and " + 
									"whatever else you care to keep track of!")}
						</card>
						<card type="scene" title="Sample Scene" isBranch="false">
							{Utilities.cdata("A scene is a self-contained story event. Each scene should move your plot forward, either directly or indirectly.")}</card>
						<card type="note" title="Sample Note" isBranch="false">
							{Utilities.cdata("Notes contain anything you want to keep track of, from your world's political system to descriptions of your settings.")}</card>
					</cards>
					<chapters>
						<chapter isBranch="true" title="Sample Chapter" />
					</chapters>
					<text>
						<chapter title="Sample Chapter">
							{Utilities.cdata("<P ALIGN='LEFT'><FONT FACE='Georgia' style='font-size: 14px' size='14' COLOR='#000000' LETTERSPACING='0' KERNING='0'><i>Drag-and-drop your scenes into the relevant chapter folder on the left, then easily refer " + 
									"back to your scene notes while writing your chapter here.</i></FONT></P>")}
						</chapter>
					</text>
				</story>
			}
			else
			{
				xml = storyXml;
			}
			
			/*<story>
				<general title="Chronicles of Storyland" author="Taylor C Campbell, Ph.D">
					<stats>
						<words date="" count=""></words>
						<words date="" count="1"></words>
					</stats>
				</general>
				<reg name="" dateActivated="" serial="" />
				<cards>
					<card type="character" title="Bob">{Utilities.cdata("Hello world, this is Bob's card.")}</card>
					<card type="character" title="Alex">{Utilities.cdata("Alex's card!")}</card>
					<card type="character" title="Jeff" />
					
					<card type="scene" title="World" isBranch="false">{Utilities.cdata("The World is a crazy place. Yep.")}</card>
					<card type="scene" title="Mars" isBranch="false" />
					<card type="scene" title="Earth" isBranch="false" />
					
					<card type="note" title="Religion" />
					<card type="note" title="Politics" />
					<card type="note" title="Love" />
				</cards>
				<chapters>
					<chapter isBranch='true' title="Chapter 1">
					</chapter>
					<chapter isBranch='true' title="Chapter 2">
					</chapter>
				</chapters>
				<text>
					<chapter title="Chapter 1">
						{Utilities.cdata("Chapter 1 text!")}
					</chapter>
					<chapter title="Chapter 2">
						{Utilities.cdata("Lorem ipsum <doler> sumat!")}
					</chapter>
				</text>
				
			</story>
			*/
			chaptersData = new XMLListCollection(xml.chapters.chapter);
			//notesData = new XMLListCollection(xml.notes.note);
			CurrentNode = null;
			CurrentChapter = null;//xml.chapters.chapter[0];
			Document.Saved = true;
			
			newCharNum=1;
			newSceneNum=1;
			newNoteNum=1;
			
			Count["CHARACTER"] = (xml.cards.card.(@type=='character') as XMLList).length();
			Count["SCENE"] = (xml.card.cards.(@type=='scene') as XMLList).length();
			Count["NOTE"] = (xml.card.cards.(@type=='note') as XMLList).length();
			Count["CHAPTER"] = (xml.chapters.chapter as XMLList).length();;
			
			//UpdateTotalWordCount();
			
			try
			{
				app.textNote.enabled = false;
				app.textNoteTitle.enabled = false;
				app.rteWriter.enabled = false;
				app.rteWriter.textArea.enabled = false;
				app.txtChapTitle.enabled = false;
				
				app.title = xml.general.@title + " - Storyblue";	
				
				if(!Utilities.Registered())
					app.title = app.title + " - Trial";
			}
			catch(e:Error){}
		}
		
		public function UpdateCardTitle(note:XML, title:String):void
		{
			
			var oldTitle:String = note.@title;
			
			xml.cards.card.(@title == oldTitle).@title = title;
			
			//if a chapter card exists with this name, update it too!
			xml.chapters..chapter.chapterScene.(@title == oldTitle).@title = title;
			Document.Saved = false;
			
		}
		
		public function UpdateCard(note:XML, text:String):void
		{
			var oldText:String = ""; 
			try
			{
				oldText = (xml.cards.card.(@title == note.@title)[0] as XML).text();
			}catch(e:Error){}
			
			if(text!=oldText)
			{
				xml.cards.card.(@title == note.@title)[0] = <card type={note.@type} title={note.@title}>{Utilities.cdata(text)}</card>	//Utilities.cdata(text);
				Document.Saved = false;
			}
		}
		
		/*
			Returns false if this card title exists in any list already, or is blank
		*/
		public function cardTitleValid(title:String):Boolean
		{
			if(title.length == 0)
			{
				return false;	
			}
			else if((xml..card.(@title == title) as XMLList).length() > 0)
			{
				return false;
			}
			
			return true;
		}
		
		public function UpdateChapterTitle(chap:XML, title:String):void
		{
			var oldTitle:String = chap.@title;
			
			xml.chapters..chapter.(@title == oldTitle)[0].@title = title;
			xml.text..chapter.(@title == oldTitle)[0].@title = title;
			Document.Saved = false;
		}
		
		public function AddChapter(name:String):Boolean
		{
			var nl:String = name.toLowerCase();
			
			var x:XMLList = xml.chapters.chapter.(attribute("title").toString().toLowerCase() == nl);
			//check: not blank, doesn't already exist
			if(name.length == 0) 
				mx.controls.Alert.show("Please enter a non-blank chapter title!", "Problem creating chapter");
			else if( x[0] != null)
				mx.controls.Alert.show("You already have a chapter named \"" + name + "\"! " + 
						"\nPlease name this one something different.", "Problem creating chapter");
			else
			{
				var newChap:XML = <chapter isBranch="true" title={name} />
				xml.chapters.appendChild(newChap);
				
				//chapter text node
				var newChapTxt:XML = <chapter title={name}>{Utilities.cdata("")}</chapter>
				xml.text.appendChild(newChapTxt);
				
				
				chaptersData = new XMLListCollection(xml.chapters.chapter);
				
				CurrentChapter = newChap;
				app.rteWriter.htmlText = ""; //make sure doesn't retain prev card text or something
				
				Document.Saved = false;
				Count["CHAPTER"]++;
				
				app.status = "Added chapter \"" + name + "\"";
				
				return true; //good.
			}
			return false;
		}
		
		public function AddNode(type:String):void
		{
			Document.Saved = false; //change!
			
			var node:XML;
			
			var name:String = "Untitled " + type;
			//if(type == "character" || type == "scene")
			//{
				
			//}
			//else if(type == "note")
			//{
			//	node = <note title={name} isBranch='true'></note>
			//	xml.cards.notes.appendChild(node);
			//}
			
			var acc:Accordion = FlexGlobals.topLevelApplication.accPlan;

			var ev:ListEvent = new ListEvent("change");
	
			switch(type)
			{
				case "character":
					if(acc.selectedIndex != 0) acc.selectedIndex = 0;
					//Application.application.listChars.selectedIndex = (xml.cards.card.(@type == type) as XMLList).length();
					
					//Application.application.listChars.dispatchEvent(ev);
					name += " " + newCharNum++;
					break;
				case "scene":
					if(acc.selectedIndex != 1) acc.selectedIndex = 1;
					//Application.application.listScenes.selectedItem = (xml.cards.card.(@type == type) as XMLList).length();
					//Application.application.listScenes.dispatchEvent(ev);
					name += " " + newSceneNum++;
					break;
				case "note":
					if(acc.selectedIndex != 2) acc.selectedIndex = 2;
					//Application.application.listNotes.selectedItem = (xml.cards.card.(@type == type) as XMLList).length();
					//Application.application.listNotes.dispatchEvent(ev);
					name += " " + newNoteNum++;
					break;
			}
			
			node = <card type={type} title={name}></card>
			xml.cards.appendChild(node);
			
			CurrentNode = node;
			//incr count
			Count[type.toUpperCase()]++;
			
			app.status = "Added " + type;
		}
		
		public function DeleteNode(title:String):void
		{
			//remove item from list
			if(title!=null)
			{
				//get type 
				var type:String = FlexGlobals.topLevelApplication.story.xml.cards.card.(@title==title)[0].@type;
				
				delete FlexGlobals.topLevelApplication.story.xml.cards.card.(@title==title)[0];
				FlexGlobals.topLevelApplication.story.Document.Saved = false;
				CurrentNode = null;
				
				//decr count
				Count[type.toUpperCase()]--;
			}
		}
		
		/*[Bindable]
		public function get TodaysWordCount():int
		{
			var todaysWords:XML = Utilities.TodaysWordsNode;
			if(todaysWords != null)
				return todaysWords.@count;
			else
				return 0;
		}
		
		public function set TodaysWordCount(num:int):void
		{
			var todaysWords:XML = Utilities.TodaysWordsNode;
			
			todaysWords.@count = num;
		}*/
		
		private var _totalWordCount:int = 0;
		[Bindable]
		public function get TotalWordCount():int
		{
			var c:int = 0;
			
			for each(var x:XML in xml.text.chapter)
			{
				c += Utilities.countWords(x.text());
			}
			_totalWordCount = c;
			
			return _totalWordCount;
		}
		/*public function set TotalWordCount(val:int):void
		{
			_totalWordCount = val;
		}
		
		public function UpdateTotalWordCount():void
		{
			var c:int = 0;
			
			for each(var x:XML in xml.text.chapter)
			{
				c += Utilities.countWords(x.text());
			}
			
			TotalWordCount = c;
		}*/
	}
}