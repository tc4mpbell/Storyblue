package script.story
{
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.managers.FocusManager;
	import mx.managers.IFocusManagerComponent;
	import mx.utils.UIDUtil;
	
	import org.RTFlex.Method;
	import org.RTFlex.RTF;
	
	import script.GoalsAndWords;
	import script.HtmlToRtfConverter;
	import script.Settings;
	import script.Story;
	
	
	public class StoryFile
	{
		import flash.events.Event;
		import flash.filesystem.*;
		import flash.net.FileFilter;
		import mx.collections.XMLListCollection;
		import mx.core.Application;
		import mx.controls.Alert;
		
		import script.Utilities;

		
		//PDF stuff
		import org.alivepdf.pdf.PDF;
		import org.alivepdf.saving.*;
		//import org.alivepdf.saving.Method;   
        import org.alivepdf.fonts.*;   
        import org.alivepdf.pages.Page;   
        import org.alivepdf.display.Display;   
        import org.alivepdf.layout.*; 
        
        import flash.utils.ByteArray;
		
		
		private var story:Story;
		
		private var _path:String;
		public function set path(val:String):void
		{
			_path = val;
		}
		public function get path():String
		{
			return _path;
		}
		private var saved:Boolean;
		
		//hacky vars for synchronicity
		private var funcAfterSaveDialog:Function = null;
		
		private var goalsAndWords:GoalsAndWords;
		
		public function StoryFile(_story:Story)
		{
			path = "";
			story = _story;
			saved = true;
			
			goalsAndWords = new GoalsAndWords();
		}

		public function SetRecent(id:String, name:String, filepath:String, date:Date):void
		{
			try
			{
				var db:Settings = new Settings();
				db.AddProject(id, name, filepath, date);
			}
			catch(ex:Error){}
		}

		
		public function Save(f:Function = null):void
		{
			//Utilities.ResetFocus();
			
			if(path == "") //never saved
			{
				SaveAs(f);
			}
			else	//already been saved
			{
				saveFile(path);
				if(f!=null)
					f();
				
				Utilities.SetStatus("Saved at "+ new Date().toLocaleTimeString());
			}
		}
		
		
		public function SaveAs(f:Function = null) : void
		{
			var file:File = new File(Utilities.GetDefaultDirectory());
			file = file.resolvePath("Untitled.storyblue");
			file.addEventListener(Event.SELECT, saveAs_selected);
			file.browseForSave("Save to folder...");
			
			if(f!=null)
			{
				funcAfterSaveDialog = f;
			}
		}
		
		private function saveAs_selected(evt:Event) :void
		{
			var path:String = File(evt.currentTarget).nativePath;
			if(path.indexOf('.storyblue') < 0)
			{
				//doesn't have extension; append
				path += '.storyblue';
			}
			
			saveFile(path);
			
			Utilities.SetStatus("Saved at "+ new Date().toLocaleTimeString());
			
			if(funcAfterSaveDialog != null)
			{
				funcAfterSaveDialog();
				funcAfterSaveDialog = null;
			}
		}
		private function saveFile(filePath:String, xml:XML = null):void
		{
			//create XML file of cards, save to text file.
			
			var newFile:File = new File(filePath);
			
			/*var x:XML = <story>
						</story>
			
			x.cards += story.xml.cards;
			x.chapters += story.xml.chapters;*/
			var x:XML = (xml == null) ? story.xml : xml;
			
			trace (x.general.attribute("id").length());
			//get ID if doesn't exist
			if(x.general.@id.toString() == "")
			{
				x.general.@id = Utilities.GenerateStoryID();
			}
			
			//update todays word count
			try
			{
				var settings:Settings = new Settings();
				
				trace(new Date().toTimeString());
				var curTotalWords:int = story.TotalWordCount;
				trace(new Date().toTimeString());
				
				//var todayWords:object = goalsAndWords.GetDay(new Date(), x.general.@id);
				if(settings.Get("WordCount_" + x.general.@id) != null)
				{
					var allTimeWords:int = parseInt(settings.Get("WordCount_" + x.general.@id)["val"]);
					if(allTimeWords != curTotalWords)
					{
						var diff:int =  curTotalWords - allTimeWords;
						
						//if todays word count exists, get and add diff
						//otherwise, just add diff
						var todayWords:Object = goalsAndWords.GetDay(new Date(), x.general.@id);
						if(todayWords == null)
						{
							goalsAndWords.UpdateDayWords(new Date(), diff, x.general.@id);
						}
						else
						{
							//increment by diff
							goalsAndWords.UpdateDayWords(new Date(), diff + parseInt(todayWords["word_count"]), x.general.@id);
						}
						
						//Alert.show("added words: " + diff.toString());
						
						//dbg
						//Alert.show("todays words: " + goalsAndWords.GetDay(new Date(), x.general.@id)["word_count"]);
						
						settings.Set("WordCount_" + x.general.@id, curTotalWords.toString());
					}
				}
				else //WordCount for this story is null, so assume new story
				{
					settings.Set("WordCount_" + x.general.@id, curTotalWords.toString());
					goalsAndWords.UpdateDayWords(new Date(), curTotalWords, x.general.@id);
				}
				
				//store date we started writing this story
				if(settings.Get("StartDate_" + x.general.@id) == null)
				{
					settings.Set("StartDate_" + x.general.@id, new Date().toDateString());
				}
				
			}
			catch(err:Error)
			{}
			
		    var str:String = x.toXMLString();
		    //if (!newFile.exists)
		    //{
		        var stream:FileStream = new FileStream();
		        stream.open(newFile, FileMode.WRITE);
		        stream.writeUTFBytes(str);
		        stream.close();
		    //}
		    
		    path = newFile.nativePath;
		    
		    Saved = true;
		    
		    //Save call: add/update in recent projects here.
			SetRecent(x.general.@id, x.general.@title, path, new Date());
			
		}
		
		public function New():void
		{
			if(!Saved) 	//if this project is unsaved...
			{
				Alert.show("Do you want to save this story first?", "Save this story first?", 
					Alert.YES|Alert.NO|Alert.CANCEL, null, saveFirstBeforeNew_click);
			}
			else
			{
				createNewStory();
			}
		}
import mx.core.FlexGlobals;
import mx.utils.UIDUtil;




		private function saveFirstBeforeNew_click(evt:CloseEvent):void
		{
			if( evt.detail == Alert.YES)	//save 
			{
				Save(createNewStory); 	//save, passing createNew function as arg to be called when save is complete.
			}
			else if(evt.detail != Alert.CANCEL)
			{
				createNewStory();
			}
		}
		private function createNewStory():void
		{
			//reset chapters, cards
			story.Init();
			path = "";
			FlexGlobals.topLevelApplication.tabsMain.selectedIndex = 0;
		}
		
		private var fileToLoad:File = null;
		public function Load(file:File = null):void
		{
			if(file!=null) fileToLoad = file;
			
			if(!Saved) 	//if this project is unsaved...
			{
				Alert.show("Do you want to save this story first?", "Save this story first?", 
					Alert.YES|Alert.NO|Alert.CANCEL, null, saveFirstBeforeLoad_click);
			}
			else if(fileToLoad == null)
			{
				showLoadFileDialog();
			}
			else if(fileToLoad!=null)
			{
				loadFile(fileToLoad);
				fileToLoad = null;
			}
		}
		private function saveFirstBeforeLoad_click(evt:CloseEvent)
		{
			if( evt.detail == Alert.YES)	//save 
			{
				Save(Load);
			}
			else if (evt.detail != Alert.CANCEL)
			{
				//showLoadFileDialog();
				Saved = true;
				Load();
			}
		}
		
		public function showLoadFileDialog():void
		{
			var file:File = new File(Utilities.GetDefaultDirectory());
			//file = File.documentsDirectory;
			file.addEventListener(Event.SELECT, load_selected);
			var filter:FileFilter = new FileFilter("Storyblue or NovelPlanner", "*.storyblue;*.novel");
			//var npfilter:FileFilter = new FileFilter("NovelPlanner (*.novel)", "*.novel");
			file.browseForOpen("", [filter]);	
		}
		
		public function load_selected(evt:Event) :void
		{
			loadFile(evt.currentTarget as File);
		}
		
		var loadingFileAt:String = null;
		public function loadFile(f:File):void
		{
			var file:File = File(f);
			var loadPath:String = file.nativePath;
			loadingFileAt = loadPath;
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			var storyXml:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close();
			
			//is this a valid file? Is it a NovelPlanner file?
			if(isNovelPlannerFile(storyXml))
			{
				Alert.yesLabel = "Convert & open";
				var btnW:Number = Alert.buttonWidth;
				Alert.buttonWidth = 120;
				Alert.show("It looks like this file was created with NovelPlanner. " + 
						"We can convert a copy to Storyblue format and open it; would you like to do that now?", 
						"Open NovelPlanner file?", Alert.YES|Alert.CANCEL, null, convertNovelPlanner_click);
				Alert.yesLabel = "Yes";
				Alert.buttonWidth = btnW;
			}
			else if(!validStoryXML(storyXml))
			{
				Alert.show("The file you selected is not a valid Storyblue file.", "Error loading file");
			}
			else
			{
				//set up info!
				story.Init(storyXml);
				
				var arrGoals : Array = [];
				var arrWordCount : Array = [];
				
				if (!story.xml.hasOwnProperty("version"))
				{
					delete story.xml.general.*;
					var versionNode : XML = <version>1.0.0</version>;
					story.xml.appendChild(versionNode);
					
					var statsNode : XML = <stats></stats>;
					story.xml.general.appendChild(statsNode);
					
					var goalsNode : XML = <goals></goals>;
					story.xml.general.stats += goalsNode;
					
					arrGoals = goalsAndWords.retrieveAllGoalsFromDB();
					arrWordCount = goalsAndWords.retrieveAllWordcountsFromDB();
				}
				
				if (arrGoals!=null)
				{
					for (var i:int = 0; i < arrGoals.length; i++)
					{
						var goalNode:XML = <goal id={arrGoals[i].story_id} name={arrGoals[i].name} word_goal={arrGoals[i].word_goal} period_in_days={arrGoals[i].period_in_days} start_date={arrGoals[i].start_date} end_date={arrGoals[i].end_date} />
						story.xml.general.goals.appendChild(goalNode);
					}
				}
				
				if (arrWordCount!=null)
				{
					for (var j:int = 0; j< arrWordCount.length; j++)
					{
						var wordsNode:XML =  <words id={UIDUtil.createUID()} story_id={arrWordCount[j].story_id} word_count={arrWordCount[j].word_count} date={arrWordCount[j].date} />
						story.xml.general.stats.appendChild(wordsNode);
					}
				}
				
				story.chaptersData = new XMLListCollection(story.xml.chapters.chapter);
				
				FlexGlobals.topLevelApplication.listChars.invalidateList();
				FlexGlobals.topLevelApplication.tabsMain.selectedIndex = 0;
				
				path = loadPath;
				
				//recent
				SetRecent(story.xml.general.@id, story.xml.general.@title, path, null);
				
				//get ID if doesn't exist
				if(story.xml.general.attribute("id").length() <= 0)
				{
					story.xml.general.@id = Utilities.GenerateStoryID();
				}
				//set word count if not set
				var settings:Settings = new Settings();
				var curTotalWords:int = story.TotalWordCount;
				if(settings.Get("WordCount_" + story.xml.general.@id) == null)
					settings.Set("WordCount_" + story.xml.general.@id, curTotalWords.toString());
				
				//set default directory
				Utilities.SetDefaultDirectory(f);
			}
		}
		
		private function convertNovelPlanner_click(evt:CloseEvent):void
		{
			if(evt.detail == Alert.YES)
			{
				ConvertNovelPlannerFile(loadingFileAt);
				loadingFileAt = null;
			}
			else
			{
				//cancel load.
			}
		}
		
		private function isNovelPlannerFile(xml:XML):Boolean
		{
			if(xml.name() == "novel" && xml.characters != null)
				return true;
			return false;
		}
		
		private function validStoryXML(xml:XML):Boolean
		{
			if(xml.general != null && xml.cards != null && xml.chapters != null && xml.text != null)
				return true;
				
			return false;
		}
		
		
		
		
		public function get Saved():Boolean
		{
			return saved;
		}
		public function set Saved(s:Boolean):void
		{
			try
			{
				var title:String = FlexGlobals.topLevelApplication.title;
				if(!s)
				{
					if(title.charAt(0) != "*")
						FlexGlobals.topLevelApplication.title = "*" + title; 
				}
				else
				{
					if(title.charAt(0) == "*")
						FlexGlobals.topLevelApplication.title = title.substring(1);
				}
			}catch(e:Error){
				trace(e.message);
			}
			trace(s);
			//mx.controls.Alert.show("saved: " + s.toString());
			saved = s;
		}
		
		public function showSaveAsDialog(callback:Function, title:String):void
		{
			var file:File = new File(Utilities.GetDefaultDirectory());
			file = file.resolvePath(title);//File.documentsDirectory.resolvePath(title);//story.xml.general.@title + ".pdf");
			file.addEventListener(Event.SELECT, callback);//pdfExportFile_selected);
			file.browseForSave("Save to folder...");
		}
		
		public function pdfExportFile_selected(evt:Event) :void
		{
			ExportStoryToPDF(File(evt.currentTarget).nativePath);
		}
		
		public function rtfExportFile_selected(evt:Event) :void
		{
			ExportRTF(File(evt.currentTarget).nativePath);
		}
		
		public function ExportRTF(path:String):void
		{
			var text:String = "";
			
			//title page
			var bookTitle:String = "<TEXTFORMAT><P><FONT SIZE=\"36\">"+story.xml.general.@title+"</FONT></P></TEXTFORMAT>" + 
				"<TEXTFORMAT><P><FONT SIZE='18'>"+story.xml.general.@author+"</FONT></P></TEXTFORMAT><BR></BR><BR></BR>";
			
			var allText:String = "";
			allText += bookTitle;
			
			//loop through chapters, for correct position
			for each(var chapPos:XML in story.xml.chapters.chapter)
			{
				var chap:XML = story.xml.text.chapter.(@title == chapPos.@title)[0];
				//chapter heading
				var title:String = "<BR></BR><BR></BR><TEXTFORMAT><P><FONT SIZE=\"24\">"
					+ chap.@title
					+ "</FONT></P></TEXTFORMAT><BR></BR>";
				
			
				var pattern:RegExp = new RegExp("SIZE=\"([0-9]{1,2})\"", "g");
				
				text = title + "*** CHAP TEXT ***" + chap.text().toString() + "*** END CHAP TEXT ***";//.replace(pattern, "style=\"font-size: $1px\" size=\"$1\"");
				text = text.replace(/<[^\/>]*>([\s]?)*<\/[^>]*>/, "");
				//text = text.replace("</P>", "</P>\\n");
				
				allText += text;
			}
			
			
			var conv:HtmlToRtfConverter = new HtmlToRtfConverter();
			var rtf:RTF = conv.ConvertToRtf(allText);
			
			var fs:FileStream = new FileStream();  
			
			//make sure ends with .pdf
			if(path.indexOf(".rtf") < 0)
			{
				path = path + ".rtf";
			}
			
			var file:File = new File(path);//File.desktopDirectory.resolvePath(path);   
			fs.open( file, FileMode.WRITE);   
			var bytes:ByteArray = rtf.save(org.RTFlex.Method.LOCAL);   
			fs.writeBytes(bytes);   
			fs.close(); 
		}
		
		public function ExportStoryToPDF(path:String):void
		{
			try
			{
				//create PDF
				var pdf:PDF;
				var file:File;
				
				pdf = new PDF( Orientation.PORTRAIT, Unit.MM, Size.A4);
				pdf.setDisplayMode(Display.FULL_PAGE, Layout.SINGLE_PAGE);
	
				var f:IFont = new org.alivepdf.fonts.CoreFont(FontFamily.TIMES);
				pdf.setFont(f,12);
	
				var text:String = "";
				
				//title page
				var bookTitle:String = "<BR /><BR /><BR /><BR /><BR /><BR /><BR />" + 
						"<TEXTFORMAT><P><FONT SIZE=\"56\">"+story.xml.general.@title+"</FONT></P></TEXTFORMAT><BR /><BR />" + 
						"<TEXTFORMAT><P><FONT SIZE='18'>"+story.xml.general.@author+"</FONT></P></TEXTFORMAT>" + 
						"<BR /><BR /><BR /><BR /><BR /><BR />";
				pdf.addPage();
				pdf.writeFlashHtmlText(16, bookTitle, null);
				
				
				var allText:String = "";
				allText += bookTitle;
				
				//loop through chapters, for correct position
				for each(var chapPos:XML in story.xml.chapters.chapter)
				{
					var chap:XML = story.xml.text.chapter.(@title == chapPos.@title)[0];
					//chapter heading
					var title:String = "<BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><BR /><TEXTFORMAT><P><FONT SIZE=\"24\">"
						+ chap.@title
						+ "</FONT></P></TEXTFORMAT><BR /><BR /><BR /><BR /><BR /><BR />";
					
					pdf.addPage();
					
					var pattern:RegExp = new RegExp("SIZE=\"([0-9]{1,2})\"", "g");
	
					text = title + chap.text().toString().replace(pattern, "style=\"font-size: $1px\" size=\"$1\"");
					text = text.replace(/<[^\/>]*>([\s]?)*<\/[^>]*>/, "");
					//text = text.replace("</P>", "</P>\\n");
					pdf.writeFlashHtmlText(10, text, null);
					
					allText += text;
				}
				
				//debug
				//ExportRTF(path.replace("pdf","rtf"));//, allText);
	
				//make sure ends with .pdf
				if(path.indexOf(".pdf") < 0)
				{
					path = path + ".pdf";
				}
				
				var fs:FileStream = new FileStream();  
				
	            file = new File(path);//File.desktopDirectory.resolvePath(path);   
	            fs.open( file, FileMode.WRITE);   
	            var bytes:ByteArray = pdf.save(org.alivepdf.saving.Method.LOCAL);   
	            fs.writeBytes(bytes);   
	            fs.close(); 
			}
			catch(e:Error)
			{
				mx.controls.Alert.show("Error exporting PDF: " + e.message);
			}

		}
		
	
		
		public function htmlExportFile_selected(evt:Event) :void
		{
			ExportStoryToHTML(File(evt.currentTarget).nativePath);
		}
		
		public function ExportStoryToHTML(path:String):void
		{
			
			var allText:String = "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\"/></head>" + 
					"<body><div style='margin:0 auto;width:650px;line-height:2em;'>";
			
			var text:String = "";
			
			//title page
			var bookTitle:String = "<BR />" + 
					"<P><FONT SIZE=\"48\" style='font-size:48px;'>"+story.xml.general.@title+"</FONT></P><BR /><BR />" + 
					"<P><FONT SIZE=\"18\" style='font-size:18px;'>"+story.xml.general.@author+"</FONT></P>" + 
					"<BR /><BR />";
			allText+=bookTitle;
			
			for each(var chapPos:XML in story.xml.chapters.chapter)
			{
				var chap:XML = story.xml.text.chapter.(@title == chapPos.@title)[0];
			
				//chapter heading
				var title:String = "<hr /><BR /><BR />" + 
						"<P><FONT SIZE=\"24\">"+chap.@title+"</FONT></P><BR /><BR />";
				text = title + chap.text().toString();
				//text = text
				allText += text;
			}
			allText += "</div></body></html>";
			
			var pattern:RegExp = new RegExp("SIZE=\"([0-9]{1,2})\"", "g");
			allText = allText.replace(pattern, "style=\"font-size: $1px\" size=\"$1\"");
			allText = allText.replace(/<[^\/>]*>([\s]?)*<\/[^>]*>/g, "");;
		
            Utilities.SaveTextFile(path, allText);
		}
		
		public function htmlExportCards_selected(evt:Event) :void
		{
			ExportCardsToHTML(File(evt.currentTarget).nativePath);
		}
		
		public function ExportCardsToHTML(path:String):void
		{
			var html:String = "<html><head><title>Storyblue Notes: " + story.xml.general.@title + "</title></head>" + 
					"<body style='font-family:arial, helvetica, sans-serif;font-size:14px;margin:40px 0;'><div style='margin:0 auto;width:750px;'><h1>"+ story.xml.general.@title+"</h1>" + 
					"<h3>Characters, Scenes, and Notes</h3><br />" + 
					"<b>Sections:</b>" + 
					"<ul>" + 
					"<li><a href='#characters'>Characters</a></li>" + 
					"<li><a href='#scenes'>Scenes</a></li>" + 
					"<li><a href='#notes'>Notes</a></li></ul>" + 
					"<hr />";
			
			var ch:XML;
			var alt:Boolean;
			
			//characters
			html += "<h2><a name='characters'>Characters</a></h2><table cellpadding='4'>";
			for each(ch in story.xml.cards.card.(@type=="character"))
			{
				html += "<tr><td width='20%' valign='top' bgcolor='"+ (alt?"#ddd":"#fff") +"'><b>"
					+ ch.@title +
					"</b></td><td bgcolor='"+ (alt?"#ddd":"#fff") +"'>" + ch.text() + "</td></tr>";
				alt = !alt;
			}
			html += "</table><hr />";
			
			//scenes
			html += "<h2><a name='scenes'>Scenes</a></h2><table cellpadding='4'>";
			for each(ch in story.xml.cards.card.(@type=="scene"))
			{
				html += "<tr><td width='20%' valign='top' bgcolor='"+ (alt?"#ddd":"#fff") +"'><b>"
					+ ch.@title +
					"</b></td><td bgcolor='"+ (alt?"#ddd":"#fff") +"'>" + ch.text() + "</td></tr>";
				alt = !alt;
			}
			html += "</table>";
			
			//notes
			html += "<h2><a name='notes'>Notes</a></h2><table cellpadding='4'>";
			for each(ch in story.xml.cards.card.(@type=="note"))
			{
				html += "<tr><td width='20%' valign='top' bgcolor='"+ (alt?"#ddd":"#fff") +"'><b>"
					+ ch.@title +
					"</b></td><td bgcolor='"+ (alt?"#ddd":"#fff") +"'>" + ch.text() + "</td></tr>";
				alt = !alt;
			}
			html += "</table>";
			
			html += "</div></body></html>";
			
			Utilities.SaveTextFile(path, html);
		}
		
		/*
		public function ExportNotesToPDF()
		{
			//create PDF
		}*/
		
		public function ConvertNovelPlannerFile(path:String)
		{
			//save new .storyblue file
			var file:File = new File(path);
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			var npXml:XML = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close();
			
			var sbXml:XML = <story>
					<general title="" author="">
						<stats>
							
						</stats>
						<goals>
							
						</goals>
					</general>
					<cards></cards>
					<chapters></chapters>
					<text></text>
				</story>
			
			//title & author
			sbXml.general.@title = npXml.@title;
			sbXml.general.@author = npXml.@author;
			
			//convert characters
			for each(var character:XML in npXml.characters.character)
			{
				var node:XML = <card type="character" title={character.@name}>{Utilities.cdata(character.text())}</card>
				sbXml.cards.appendChild(node);
			}
			//convert scenes
			for each(var scene:XML in npXml.scenes.scene)
			{
				var node:XML = <card type="scene" title={scene.@name}>{Utilities.cdata(scene.text())}</card>
				sbXml.cards.appendChild(node);
			}
			//convert notes
			for each(var note:XML in npXml.other.other)
			{
				var node:XML = <card type="note" title={note.@name}>{Utilities.cdata(note.text())}</card>
				sbXml.cards.appendChild(node);
			}
			
			//convert chapters
			for each(var chap:XML in npXml.chapters.chapter)
			{
				var node:XML = <chapter isBranch="true" title={chap.@name} />
				var txt:XML = <chapter title={chap.@name} />
				
				//scenes to chapters
				for each(var chapScene:XML in chap.chapterItem)
				{
					if(npXml.scenes.scene.(@id == chapScene.@id).length() > 0)
					{
						var scNode:XML = npXml.scenes.scene.(@id == chapScene.@id)[0];
						var scTitle:String = scNode.@name;
						
						var sbNode:XML = <chapterScene type="scene" title={scTitle} />
						node.appendChild(sbNode);
					}
				}
				
				sbXml.chapters.appendChild(node);
				sbXml.text.appendChild(txt);
			}
			
			var newPath:String = file.nativePath.replace(/.novel/, ".storyblue");
			saveFile(newPath, sbXml);
			loadFile(new File(newPath));
		}
		
	}
}