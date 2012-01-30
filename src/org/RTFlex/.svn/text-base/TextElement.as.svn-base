/**
 * 
 *  This class holds some text wrapped in formatting. The format is stored in thef ormat object. 
 * 
 **/
package org.RTFlex
{
	
	public class TextElement
	{
		public var text:String;
		public var format:Format;
		
		//positions in tables
		private var _colorPos:int;
		private var _backgroundColorPos:int;
		private var _fontPos:int;
		
		public function TextElement(text:String,format:Format,colorPos:int,backgroundColorPos:int,fontPos:int):void
		{
			this.text=text; 
			this.format=format;
			_colorPos=colorPos;
			_backgroundColorPos=backgroundColorPos;
			_fontPos=fontPos;
		}
				
		
		public function getRTFCode():String{
			return format.formatText(text,_colorPos,_backgroundColorPos,_fontPos);
		}
	}
}