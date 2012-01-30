/**
 * 
 *  This class just stores what options you have for formatting.
 * 
 **/
package org.RTFlex
{
	import mx.utils.StringUtil;
	
	public class Format
	{
		public var underline:Boolean=false;
		public var bold:Boolean=false;
		public var italic:Boolean=false;
		public var strike:Boolean=false;
		
		public var superScript:Boolean=false;
		public var subScript:Boolean=false;
		
		public var makeParagraph:Boolean=false;
		
		public var align:String = "";
		
		public var leftIndent:int=0;
		public var rightIndent:int=0; 
		
		public var font:String = "";
		public var fontSize:int=0; 
		public var color:RGB;
		public var backgroundColor:RGB;
		
		//if defined, this element will become a link to this url
		public var url:String; 
		
		
		public function Format()
		{
		}
		public function formatText(text:String,colorPos:int,backgroundColorPos:int,fontPos:int,safeText:Boolean=true):String{
			var rtf:String = "{";
			if(makeParagraph) rtf+="\\pard";
			
			if(fontPos>0) rtf+="\\f"+fontPos.toString();
			if(backgroundColorPos>0) rtf+="\\cb"+(backgroundColorPos+1).toString();  //Add one because color 0 is null
			if(colorPos>0) rtf+="\\cf"+(colorPos+1).toString(); //yup
			if(fontSize >0) rtf+="\\fs"+(fontSize*2).toString();
			
			switch(align){
				case Align.CENTER:
					rtf+="\\qc";
				break;
				case Align.LEFT:
					rtf+="\\ql";
				break;
				case Align.FULL:
					rtf+="\\qj";
				break;
				case Align.RIGHT:
					rtf+="\\qr";
				break;
			}
			
			if(bold) rtf+="\\b";
			if(italic) rtf+="\\i";
			if(underline) rtf+="\\ul";
			if(strike) rtf+="\\strike";
			if(leftIndent>0) rtf+="\\li"+leftIndent.toString();
			if(rightIndent>0) rtf+="\\ri"+rightIndent.toString();
			if(subScript) rtf+="\\sub";
			if(superScript) rtf+="\\super";
			
			//we don't escape text if there are other elements in it, so set a flag
			if(safeText){
				rtf+=" "+getRTFSafeText(text);
			}else{
				rtf+=text;
			}
			
			if(makeParagraph) rtf+="\\par";
			rtf+="}"
			return rtf;
		}
		
		private function getRTFSafeText(text:String):String{
			var safeText:String = text; 
			if(safeText == null) return ""; //just in case nothing got passed in somehow
			safeText = safeText.split('\\').join('\\\\'); //turn all single back slashes into double
			safeText = safeText.split('{').join('\\{');  
			safeText = safeText.split('}').join('\\}');  
			safeText = safeText.split('~').join('\\~');  
			safeText = safeText.split('-').join('\\-');       
			safeText = safeText.split('_').join('\\_');    
			//turns line breaks into \line commands
			safeText = safeText.split('\n\r').join(' \\line ');		
			safeText = safeText.split('\n').join(' \\line ');  
			safeText = safeText.split('\r').join(' \\line '); 	
			return safeText; 
		}
	}
}