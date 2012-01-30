/**
 * 
 *  GroupElement stores a group of elements which should be formatted by it's format... inheritence of the 
 *  format isn't working yet.  
 * 
 **/
package org.RTFlex
{
	import mx.utils.StringUtil;
	
	
	public class TableElement
	{
		
		public var rows:Number=0;
		public var cols:Number=0;
		private var tableRows:Array;
		
		public function TableElement(rows:Number,cols:Number)
		{
			this.rows=rows;
			this.cols=cols;
			this.tableRows = new Array();
		}
		public function addRow(row:Array):void{
			tableRows.push(row);
		}
		public function getRTFCode():String{
			var rtf:String = "\\par";
			
			for(var i:int = 0;i<rows;i++){
				if(tableRows[i]!=null &&tableRows[i] is Array){
					 rtf+="\\trowd\\trautofit1\\intbl";
					 //now do the first \cellx things
					 for(var j:int=0;j<cols;j++){
					 	rtf+="\\clbrdrt\\brdrs\\brdrw10\\clbrdrl\\brdrs\\brdrw10\\clbrdrb\\brdrs\\brdrw10\\clbrdrr\\brdrs\\brdrw10";
					 	rtf+="\\cellx"+(j+1).toString();
					 }
					 //now create the content
					 rtf+="{";
					 for(var c:int=0;c<cols;c++){
					 	if(tableRows[i][c]!=null){
					 		rtf+= StringUtil.trim(getRTFSafeText(tableRows[i][c]));
					 	}
					 	rtf+="\\cell ";
					 } 
					 rtf+=" }";
					 //now for some reason we need to do part of it over again, I think it's for backwards compatibility
					 rtf+="{\\trowd\\trautofit1\\intbl";
					 for(var x:int=0;x<cols;x++){
					 	rtf+="\\cellx"+(x+1).toString();
					 } 
					 rtf+="\\row }";
				} 					
			}
			rtf+="\\pard";
			return rtf;
		}
		private function getRTFSafeText(text:String):String{
			var safeText:String = text;
			safeText.split('\\').join('\\\\'); //turn all single back slashes into double
			safeText.split('{').join('\\{'); 
			safeText.split('}').join('\\}'); 
			safeText.split('~').join('\\~'); 
			safeText.split('-').join('\\-'); 
			safeText.split('_').join('\\_'); 			
			return safeText;
		}
	}
}