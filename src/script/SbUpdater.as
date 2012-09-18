package script
{
	import components.UpdateAvailable;
	
	import flash.desktop.NativeApplication;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	public class SbUpdater
	{
		namespace updNs = "http://ns.adobe.com/air/framework/update/description/1.0";
		use namespace updNs;
		
		public static function CheckForUpdates():void
		{
			var url:String = "http://storyblue.com/update/update-descriptor.xml";
			var req:URLRequest = new URLRequest();
			req.url = url;
			var ldr:URLLoader = new URLLoader();
			ldr.addEventListener(Event.COMPLETE, loadedVersion);
			ldr.load(req);
		}
		
		public static function loadedVersion(ev:Event):void
		{
			var l:URLLoader = URLLoader(ev.target);
			//trace(l.data);
			
			//check to see version vs current version
			
			var appXML:XML = flash.desktop.NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXML.namespace();
			var curVer:String = appXML.ns::versionNumber;
			
			var xml:XML = new XML(l.data);
			
			trace(xml.descendants("version").toXMLString());
			
			var newVer:String = xml.version;
			
			//are we on latest version?
			//if(new Number(curVer) < new Number(newVer))
			if(Utilities.IsSecondVersionStringHigher(curVer, newVer))
			{
				//no, new version available
				var updWin:UpdateAvailable = PopUpManager.createPopUp(FlexGlobals.topLevelApplication.parentDocument, UpdateAvailable, true) as UpdateAvailable;
				PopUpManager.centerPopUp(updWin);
				updWin.txtVersionDetails.text = xml.description;
				updWin.addEventListener(CloseEvent.CLOSE, function(evclose:CloseEvent){PopUpManager.removePopUp(updWin);});
			}
			else
			{
				//mx.controls.Alert.show("on cur version: " + newVer);
				
			}
		}
	}
}