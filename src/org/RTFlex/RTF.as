/**
 * 
 * 
 * RTFlex, ALPHA 0.012, first build
 * 
 * By Jonathan Rowny on 1/30/2009, www.jonathanrowny.com/code/
 * 
 **/

package org.RTFlex
{
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	
	public class RTF
	{
		//Options
		public var pageNumbering:Boolean;
		public var marginLeft:int = 1800;
		public var marginRight:int = 1800;
		public var marginBottom:int = 1440;
		public var marginTop:int = 1440;
		
		public var language:String = Language.ENG_US;
		
		public var columns:int=0; //columns?
		public var columnLines:Boolean=false; //lines between columns
		
		public var orientation:Boolean = Orientation.PORTRAIT; 
				
		
		//stores the elemnts
		private var elements:Array;
		//stores the colors
		private var colorTable:Array;
		//stores the fonts
		private var fontTable:Array;
			
		public function RTF():void
		{ 
			elements = new Array();
			colorTable = new Array();
			fontTable = new Array();
		}  
		
		/** 
		 * 
		 * Document modifiers 
		 * 
		 **/
		public function writeText(text:String,format:Format=null,groupName:String=null):void{
			if(!format){
				format = new Format();
			}
			checkTables(format);
			var fontPos:int = fontTable.indexOf(format.font); //should return -1 if not found
			var colorPos:int = colorTable.indexOf(format.color); 
			var backgroundColorPos:int = colorTable.indexOf(format.backgroundColor);
			
			//might change this to pass only the relevant number
			var element:TextElement = new TextElement(text,format,colorPos,backgroundColorPos,fontPos);
			if(groupName && groupIndex(groupName)>=0){
				GroupElement(elements[groupIndex(groupName)]).addElement(element);
			}else{
				elements.push(element);
			}
		} 
		
		public function addTableElement(table:TableElement):void{
			elements.push(table);
		}
		public function addTextGroup(name:String,format:Format):void{
			if(groupIndex(name)<0){//make sure we don't have duplicate groups!
				checkTables(format);
				var fontPos:int = fontTable.indexOf(format.font);
				var colorPos:int = colorTable.indexOf(format.color);
				var backgroundColorPos:int = colorTable.indexOf(format.backgroundColor);
				var formatGroup:GroupElement = new GroupElement(name,format,colorPos,backgroundColorPos,fontPos);
				elements.push(formatGroup);
			}
		}
		
		//page break
		public function addPage(groupName:String=null):void{
			if(groupName && groupIndex(groupName)>=0){
				GroupElement(elements[groupIndex(groupName)]).addElement("\\page");
			}else{ 
				elements.push(" \\page ");
			}
		}
		//line break
		public function addLineBreak(groupName:String=null):void{
			if(groupName && groupIndex(groupName)>=0){
				GroupElement(elements[groupIndex(groupName)]).addElement("\\line");
			}else{
				elements.push(" \\line ");
			}
		}
		//tab
		public function addTab(groupName:String=null):void{
			if(groupName && groupIndex(groupName)>=0){
				GroupElement(elements[groupIndex(groupName)]).addElement("\\tab");
			}else{
				elements.push(" \\tab ");
			}
		}
		
		
		/**
		 * 
		 * RTFlex Utils
		 * 
		 **/
		 private function groupIndex(name:String):Number{
		 	for(var j:int=0;j<elements.length;j++){
				if(elements[j] is GroupElement && GroupElement(elements[j]).name==name){
					return j;
					break;
				}
			}
			return -1;
		 }
		 private function checkTables(format:Format):void{
		 	var fontPos:int = fontTable.indexOf(format.font);
			var colorPos:int = colorTable.indexOf(format.color);
			var backgroundColorPos:int = colorTable.indexOf(format.backgroundColor);
			if(fontPos<0 && format.font.length>0){ 
				fontTable.push(format.font); 
			}
			if(colorPos<0&&format.color!=null){
				colorTable.push(format.color);
			}
			if(backgroundColorPos<0&&format.backgroundColor!=null){
				colorTable.push(format.backgroundColor);
			}
		 }
		 
		 //gneerates the color table
		 private function createColorTable():String{
		 	var table:String = "{\\colortbl;";
		 	var rgb:RGB;
		 	for(var c:int=0;c<colorTable.length;c++){
		 		rgb = colorTable[c] as RGB;
		 		table+="\\red"+rgb.red+
		 			   "\\green"+rgb.green+
		 			   "\\blue"+rgb.blue+";";
		 	}
		 	table+="}"; 
		 	return table;
		 }
		 private function createFontTable():String{
		 	var table:String = "{\\fonttbl";
		 	if(fontTable.length==0){
		 		table+="{\\f0 "+Fonts.ARIAL+"}"; //if no fonts are defined, use arial
		 	}else{			 	
			 	for(var f:int=0;f<fontTable.length;f++){
			 		table+="{\\f"+f+" "+fontTable[f]+";}";
			 	}
		 	}
			table+="}";
		 	return table; 	
		 }
		 private function createDocument():String{
		 	var output:String = "{\\rtf1\\ansi\\deff0";
		 	if(orientation == Orientation.LANDSCAPE) output+="\\landscape";
		 	//margins
		 	if(marginLeft > 0) output+="\\margl"+marginLeft.toString();
		 	if(marginRight > 0) output+="\\margr"+marginRight.toString();
		 	if(marginTop > 0) output+="\\margt"+marginTop.toString();
		 	if(marginBottom > 0) output+="\\margb"+marginBottom.toString();
		 	output+="\\deflang"+language;
		 	//create tables
		 	output+=createColorTable();
		 	output+=createFontTable();
		 	//other options	 	
		 	if(pageNumbering) output+="{\\header\\pard\\qr\\plain\\f0\\chpgn\\par}";
		 	if(columns > 0) output+="\\cols"+columns.toString();
		 	if(columnLines) output+="\\linebetcol";
		 	 
		 	//outputs the elements
		 	for(var i:int=0;i<elements.length;i++){
		 		if(elements[i] is GroupElement){
		 			output+=GroupElement(elements[i]).getRTFCode();
		 		}else if(elements[i] is TextElement){
		 			output+=TextElement(elements[i]).getRTFCode();
		 		}else if(elements[i] is TableElement){
		 			output+=TableElement(elements[i]).getRTFCode();
		 		}else if(elements[i] is String){
		 			output+=elements[i];
		 		}
		 	}
		 	
		 	output+="}"; 
			
			output = output.replace(/\s+/g, " "); //TC: Strip multiple spaces
			
		 	return output;
		 }
		 
		/**
		 * 
		 * This is based on what is in AlivePDF because it seems to work well.
		 * I did not do events on start and stop because hopefully it's 
		 * light weight enough... I'll probably do that later.. maybe.
		 * 
		 **/ 
		public function save ( method:String, url:String='', downloadMethod:String='inline', fileName:String='generated.rtf', frame:String="_blank" ):*
		{
			
			if ( method == Method.LOCAL ){
				var buffer:ByteArray = new ByteArray();
				buffer.writeMultiByte(createDocument(),"ansi");
				return buffer;
			}else{ 

				var header:URLRequestHeader = new URLRequestHeader ("Content-type", "application/octet-stream");
				var myRequest:URLRequest = new URLRequest ( url+'?name='+fileName+'&method='+downloadMethod );
	
				myRequest.requestHeaders.push (header);
				myRequest.method = URLRequestMethod.POST;
				myRequest.data = save( Method.LOCAL );
	
				navigateToURL( myRequest, frame );

				return null;
			}
		}
	}
}