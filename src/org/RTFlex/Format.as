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
		
		public var changed_color = false;
		
		public var superScript:Boolean=false;
		public var subScript:Boolean=false;
		
		public var makeParagraph:Boolean=false;
		public var startParagraph:Boolean = false;
		public var endParagraph:Boolean = false;
		public var endPreviousParagraph:Boolean = false;
		
		public var align:String = "";
		
		public var leftIndent:int=0;
		public var rightIndent:int=0; 
		
		public var font:String = "";
		public var fontSize:int=0; 
		public var color:RGB;
		public var backgroundColor:RGB;
		
		public var doubleSpace:Boolean = false;
		public var fragment:Boolean = false;
		
		//if defined, this element will become a link to this url
		public var url:String; 
		
		
		public function Format()
		{
		}
		public function formatText(text:String,colorPos:int,backgroundColorPos:int,fontPos:int,safeText:Boolean=true):String{
			var rtf:String = "";
			
			if(startParagraph)// && !makeParagraph)
			{
				//We're writing the start of a line with user styles. Need to wrap it in par tags.
				rtf+="{\\pard";
				if(doubleSpace) rtf += "\\sl480\\slmult1";
				
				//rtf += " START OF THE LINE ";
			}
			
			//TC allow for inner sentence fragments
			//if(!fragment || makeParagraph) 
			//	rtf += "{";
			
			if(makeParagraph) 
			{
				//rtf +=  " STARTING A PARA ";
				rtf+="\\pard";
				if(doubleSpace) rtf += "\\sl480\\slmult1\\fi8";
			}
			
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
			
			//TC End bold/italic/underline
			if(bold) rtf+="\\b0";
			if(italic) rtf+="\\i0";
			if(underline) rtf+="\\ul0";
			
			if(changed_color) rtf += "\\cf0";
			
			if(makeParagraph) 
			{
				rtf+="\\par";
				//rtf +=  " ENDING A PARA ";
			}
			//if(!fragment || makeParagraph) rtf+="}";
				
			//add to front, if need to end a para
			if(endParagraph)//makeParagraph && !justEndedParagraph && fragment && rtf.length != 0)
			{
				//if the last block wasn't a paragraph, was a block with user styles. End that one.
				rtf += "\\par}";
			}
			
			if(endPreviousParagraph)//makeParagraph && !justEndedParagraph && fragment && rtf.length != 0)
			{
				//if the last block wasn't a paragraph, was a block with user styles. End that one.
				rtf = "\\par}" + rtf;
			}
			
			rtf = rtf.replace("*** CHAP TEXT ***", "{\\pard\\sl480\\slmult1")
				.replace("*** END CHAP TEXT ***", "\\par}");
				//.replace("*** CHAP TITLE ***", "{\\pard\\sl480\\slmult1")
				//.replace("*** END CHAP TITLE ***", "\\par}");
				
			return rtf;
		}
		
		private function getRTFSafeText(text:String):String{
			var safeText:String = text; 
			if(safeText == null) return ""; //just in case nothing got passed in somehow
			safeText = safeText.split('\\').join('\\\\'); //turn all single back slashes into double
			safeText = safeText.split('{').join('\\{');  
			safeText = safeText.split('}').join('\\}');  
			safeText = safeText.split('~').join('\\~');  
			//safeText = safeText.split('-').join('\\-');       /* TC: is this needed? */  
			safeText = safeText.split('_').join('\\_');    
			//turns line breaks into \line commands
			safeText = safeText.split('\n\r').join(' \\line ');		
			safeText = safeText.split('\n').join(' \\line ');  
			safeText = safeText.split('\r').join(' \\line '); 
			return safeText; 
		}
	}
}