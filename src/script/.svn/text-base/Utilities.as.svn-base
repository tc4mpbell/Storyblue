// ActionScript file
package script
{
	import flash.filesystem.*;
	
	import mx.controls.Alert;
	import mx.controls.TextArea;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.managers.IFocusManager;
	import mx.utils.UIDUtil;
	
	import script.Settings;
	
	public class Utilities
	{
		public static function cdata(str:String):XML
		{
		    var x:XML = new XML("<![CDATA[" + str + "]]>");
		    return x;
		}
		
		public static function ResetFocus():void
		{
			//set focus, then back to update cards
			try
			{
				var focused:Object = (FlexGlobals.topLevelApplication as Storyblue).tabsMain.focusManager.getFocus();
				(FlexGlobals.topLevelApplication as Storyblue).tabsMain.focusManager.setFocus(focused as mx.managers.IFocusManagerComponent);
			}
			catch(e)
			{}
		}
		
		public static function GenerateStoryID():String
		{
			return UIDUtil.createUID();
		}
		
		public static function StyleText(text:String):String
		{
			var newText:String = text;
			try
			{
				newText = text.replace(/size="\d+"/gi, "size=\""+ Utilities.Get("FontSize").toString() +"\"");
			}
			catch(e:Error){}
			return newText;
		}
		
		/*
		Handy aliases for the functions in Settings
		*/
		public static  function Set(name:String, val:String):void
		{
			var s:Settings = new Settings();
			
			s.Set(name, val);
		}
		public static function Get(name:String):Object
		{
			var s:Settings = new Settings();
			var o:Object = s.Get(name);
			if(o == null) return null;
			else return o["val"];
		}
		
		public static function SetDefaultDirectory(f:File):void
		{
			var s:Settings = new Settings();
			var defDir:String = "";
			if(f.isDirectory)
				defDir = f.nativePath;
			else
				defDir = f.parent.nativePath;
				
			s.Set("DefaultDir_" + FlexGlobals.topLevelApplication.story.xml.general.@id, defDir);
		}
		public static function GetDefaultDirectory():String
		{
			var defDir:Object = new Settings().Get("DefaultDir_" + FlexGlobals.topLevelApplication.story.xml.general.@id);
			var path:String;
			if(defDir != null)
			{
				path = defDir["val"].toString();
			}
			else
			{
				path = File.documentsDirectory.nativePath;
			}
			return path;
		}
		
		public static function IsSecondVersionStringHigher(firstV:String, secV:String):Boolean
		{
			var split1:Array = firstV.split('.');
			var split2:Array = secV.split('.');
			
			for(var i=0; i<split1.length; i++)
			{
				if(split1[i] < split2[i])
				{
					return true;
				}
				else if(split1[i] > split2[i])
				{
					return false;
				}

			}
			
			if(split2.length > split1.length) return true;
			
			return false;
		}
		
		public static function SetStatus(st:String):void
		{
			(FlexGlobals.topLevelApplication as Storyblue).status = st;
		}
		
		/*public static function get TodaysWordsNode():XML
		{
			var dt:String = new Date().toDateString();
	
			//check if we're already tracking words for today's date
			var todaysWords:XML = mx.core.Application.application.story.xml.general.stats.words.(@date == dt)[0];
			
			if(todaysWords == null)
			{
				//create node
				todaysWords = <words date={dt} count="0" ></words>
				mx.core.Application.application.story.xml.general.stats += todaysWords;
			}
			
			return todaysWords;
		}
		*/
		
		public static function SaveTextFile(path:String, text:String):void
		{
			var fs2:FileStream = new FileStream();  
            var file:File = File.desktopDirectory.resolvePath(path);   
            fs2.open( file, FileMode.WRITE);   
            fs2.writeUTFBytes(text);  
            fs2.close(); 
		}
		
		public static function ShowOverUnRegLimit(type:String):void
		{
			mx.controls.Alert.show("You've reached the "+ type +" limit on the trial version of Storyblue. " + 
					"Purchase now to unlock immediately and keep creating!", "Trial version limit reached");
		}
		
		//shouldn't run this every time...
		public static function Registered():Boolean
		{
			var reg:Boolean = verifySerial(FlexGlobals.topLevelApplication.story.settings.GetName(), 
				FlexGlobals.topLevelApplication.story.settings.GetRegKey());
			
			return reg;
		}
		
		public static function verifySerial(name:String, key:String):Boolean
		{
			var crypto:CryptoCode = new CryptoCode();
			var s:String;// = crypto.encrypt(name+"::especially the mouse");
			
			//do some modifyin'
			name = mx.utils.StringUtil.trim(name);
			key = mx.utils.StringUtil.trim(key);
			
			try
			{
				s = crypto.decrypt(key);
			}catch(ex:Error)
			{
				return false;
			}
			
			//txtRegRes.text = s;
			
			//trace(s);
			
			if(s.indexOf(name)>=0)
			{
				return true;
			}
			else
			{
				return false;
			}
			
			
			//var decKey:ByteArray = new ByteArray()
			//decKey.writeUTFBytes("the world Is a happy place. Of unicorns");
			
			//decrypt from base64
			//var encrypted:ByteArray = com.hurlant.util.Base64.decodeToByteArray(key); //dec.decode(key);
			
			//var bf:com.hurlant.crypto.symmetric.BlowFishKey = new com.hurlant.crypto.symmetric.BlowFishKey(decKey);
			
			//var block:ByteArray = new ByteArray();
			//bf.decrypt(encrypted);
			
			
			//var decrypted:String = bf.toString();
			
			//DO THEY MATCH???
		}
		
		
		public static function stripHtmlTags(html:String, tags:String = ""):String
		{
			//test new method
			/*var textA:TextArea = new TextArea();
			textA.text = html;
			return textA.text;
			*/
			
			
		    var tagsToBeKept:Array = new Array();
		    if (tags.length > 0)
		        tagsToBeKept = tags.split(new RegExp("\\s*,\\s*"));
		 
		    var tagsToKeep:Array = new Array();
		    for (var i:int = 0; i < tagsToBeKept.length; i++)
		    {
		        if (tagsToBeKept[i] != null && tagsToBeKept[i] != "")
		            tagsToKeep.push(tagsToBeKept[i]);
		    }
		 
		    var toBeRemoved:Array = new Array();
		    var tagRegExp:RegExp = new RegExp("<([^>\\s]+)(\\s[^>]+)*>", "g");
		 
		    var foundedStrings:Array = html.match(tagRegExp);
		    for (i = 0; i < foundedStrings.length; i++) 
		    {
		        var tagFlag:Boolean = false;
		        if (tagsToKeep != null) 
		        {
		            for (var j:int = 0; j < tagsToKeep.length; j++)
		            {
		                var tmpRegExp:RegExp = new RegExp("<\/?" + tagsToKeep[j] + "( [^<>]*)*>", "i");
		                var tmpStr:String = foundedStrings[i] as String;
		                if (tmpStr.search(tmpRegExp) != -1) 
		                    tagFlag = true;
		            }
		        }
		        if (!tagFlag)
		            toBeRemoved.push(foundedStrings[i]);
		    }
		    for (i = 0; i < toBeRemoved.length; i++) 
		    {
		        var tmpRE:RegExp = new RegExp("([\+\*\$\/])","g");
		        var tmpRemRE:RegExp = new RegExp((toBeRemoved[i] as String).replace(tmpRE, "\\$1"),"g");
		        html = html.replace(tmpRemRE, "");
		    } 
		    return html;
		}
		
		public static function calculateDays( start:Date, end:Date ) :int 
		{ 
			var daysInMilliseconds:int = 1000*60*60*24 ;
			return Math.ceil(  (end.time - start.time)  / daysInMilliseconds ); 
		} 
		
		public static function date(d:Date):String
		{
			var SEPARATOR:String = "/";
    
	         var mm:String = (d.month + 1).toString();
	         if (mm.length < 2) mm = "0" + mm;
	    
	         var dd:String = d.date.toString();
	         if (dd.length < 2) dd = "0" + dd;
	    
	         var yyyy:String = d.fullYear.toString();
	         return mm + SEPARATOR + dd + SEPARATOR + yyyy;
		}
		
		public static function countWords(str:String):int
		{
			//add space, strip html tags
			var noh:String = stripHtmlTags(str.replace(/<P/ig, " <P")); 
			
			return noh.replace(/'/g,'').split(/\b\w+\b/).length-1;
		}
	}
}














