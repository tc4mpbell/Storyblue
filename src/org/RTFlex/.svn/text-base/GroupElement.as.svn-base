/**
 * 
 *  GroupElement stores a group of elements which should be formatted by it's format... inheritence of the 
 *  format isn't working yet.  
 * 
 **/
package org.RTFlex
{
	
	public class GroupElement
	{
		
		
		public var name:String;
		public var format:Format;
		
		//
		private var _colorPos:int;
		private var _backgroundColorPos:int;
		private var _fontPos:int;
		
		private var elements:Array;
		
		public function GroupElement(name:String,format:Format,colorPos:int,backgroundColorPos:int,fontPos:int)
		{
			elements = new Array();
			this.name=name;
			this.format=format;
			_colorPos=colorPos;
			_backgroundColorPos=backgroundColorPos;
			_fontPos=fontPos; 
		}
		public function addElement(element:*):void{//can be a string (command) or TextElemetn
			elements.push(element);
		}
		public function getRTFCode():String{
			return format.formatText(getElementOutput(),_colorPos,_backgroundColorPos,_fontPos,false); //safe text already done in getlementoutput()
		}
		private function getElementOutput():String{
			var rtf:String="";
			//outputs the elements
		 	for(var i:int=0;i<elements.length;i++){
		 		if(elements[i] is TextElement){
		 			rtf+=TextElement(elements[i]).getRTFCode();
		 		}else if(elements[i] is String){
		 			rtf+=elements[i];
		 		}
		 	}
		 	return rtf;
		}
		
		
		
	}
}