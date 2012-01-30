package script
{
	import flash.net.registerClassAlias;
	
	import mx.containers.Form;
	import mx.utils.ObjectUtil;
	
	import org.RTFlex.Format;
	import org.RTFlex.RGB;
	import org.RTFlex.RTF;
	import org.alivepdf.colors.RGBColor;
	import org.alivepdf.html.HTMLTag;

	/*
		RtfConverter: Converts from HTML to RTF using RTFlex
	*/
	public class HtmlToRtfConverter
	{
		public function HtmlToRtfConverter()
		{
			/*
				Plan: Need to parse HTML into bits that I can pass to RTFlex.
			*/
		}
		
		
		// Function stolen from AlivePDF.PDF :)
		protected function parseTags ( myXML:XML ):Array
		{	
			var aTags:Array = new Array();
			var children:XMLList = myXML.children();
			var returnedTags:Array;
			var lng:int = children.length();
			var subLng:int;
			
			for( var i : int=0; i < lng; i++ )
			{	
				if ( children[i].name() != null )
				{	
					aTags.push( new org.alivepdf.html.HTMLTag ('<'+children[i].name()+'>', children[i].attributes(), "") );
					
					returnedTags = parseTags ( children[i] );
					subLng = returnedTags.length;
					
					for ( var j : int = 0; j < subLng; j++ )
						aTags.push( returnedTags[j] );
					
					aTags.push( new HTMLTag ('</'+children[i].name()+'>', children[i].attributes(), "") );
					
				} else 
					
					aTags.push( new HTMLTag ("none", new XMLList(), children[i] ) );
			}
			return aTags;
		}
		
		public function ConvertToRtf(hText:String):RTF
		{
			var currentLine:Array = [];// = "";
			var doc:RTF = new RTF();
			var format:Format = new Format();
			
			var formats:Array = [];
			formats.push(format);
			
			var prevTextColor:RGB = new RGB(0,0,0);
			format.color = prevTextColor;
			
			var startPara:Boolean = false;
			//var justEndedPara:int = 0;
			//var fragmentCount:int = 0;
			//var addedFragPara:Boolean = false;
			var inPara:Boolean = false;
			var numParas:int = 0;
			
			var s     : String     = findAndReplace ("\r",'',hText);
			
			flash.net.registerClassAlias("org.RTFlex.Format", Format);
			
			// Strip all \n's as we don't use them - use <br /> tag for returns
			s = findAndReplace("\n",'', s);  
			//
			var aTaggedString:Array = parseTags(new XML( "<html>"+s+"</html>" ));
			var lng:int = aTaggedString.length;
			
			//Loop through each item in array
			for ( var k=0; k < lng; k++ )
			{
				//Handle any tags and if unknown then handle as text    
				switch ( aTaggedString[k].tag.toUpperCase() )
				{	
					//Process Tags
					case "<TEXTFORMAT>":
						break;
					case "</TEXTFORMAT>":
						formats.pop();
						format = new Format();//formats[formats.length - 1];
						formats.push(format);
						break;
					case "<P>":
						startPara = true;
						//inPara = true;
						//format.fragment = false;
						
						
						for each ( attr in HTMLTag(aTaggedString[k]).attrs )
						{	
							switch ( String ( attr.name() ).toUpperCase() )
							{	
								case "ALIGN": 
									format.align = String ( attr ).charAt(0);
									//textAlign = String ( attr ).charAt(0);
									break;
								default:
									break;
							}
						}
						break;
					case "</P>":
						//inPara = false;
						//renderLine(currentLine,textAlign);
						//for(var i:int = 0; i<currentLine.length; i++)
						///{
							//doc.writeText(currentLine[i], format);
						//}
						
						//var f:Format = new Format();
						//f.makeParagraph = true;
						//doc.writeText("", f);
						
						
						doc.addLineBreak(); //tc debug
						
						currentLine = [];//     = "";
						//format.align = "";
						
						
						//TC /2 added because RichText adds an extra <p> in between paragraphs.
						//lineBreak ( pHeight/2 );
						
						break;
					case "<FONT>":
						format = Format( ObjectUtil.copy(format) );	
						formats.push(format);
						
						format.fragment = true;
						
						for each ( var attr:XML in HTMLTag(aTaggedString[k]).attrs )
						{
							switch ( String ( attr.name() ).toUpperCase() )
							{	
								case "FACE":
									// TODO: Add Font Face Support
									var fontFamily:String = attr; //TC
									
									//some filtering - TC
									if(fontFamily.indexOf("Times") >= 0 || fontFamily.indexOf("Georgia") >= 0)
										fontFamily = "Times New Roman";
									
									format.font = fontFamily;
									
									break;
								case "SIZE":
									//fs = parseInt( String ( attr ) );
									//fontSizePt =
									format.fontSize =  parseInt( String ( attr ) );
									break;
								case "COLOR":
									var rgb:RGBColor = org.alivepdf.colors.RGBColor.hexStringToRGBColor( String ( attr ) );
									
									prevTextColor = format.color;
									format.changed_color = true;
									
									format.color  = new RGB(rgb.r, rgb.g, rgb.b);
									//fontColor
									break;
								case "LETTERSPACING":
									
									//cs = parseInt( String ( attr ) );
									break;
								case "KERNING":
									// TODO
									break;
								default:
									break;
							}
						}
						break;
					case "</FONT>":
						
						//format = Format( ObjectUtil.copy(format) );		
						//format.color = prevTextColor;
						
						formats.pop();
						format = formats[formats.length - 1];
						
						break;
					case "<B>":
						//fontBold = true;
						format = Format( ObjectUtil.copy(format) );	
						formats.push(format);
						format.bold = format.fragment = true;
						break;
					case "</B>":

						formats.pop();
						format = formats[formats.length - 1];
						//format = Format( ObjectUtil.copy(format) );		
						//format.bold = false;
						break;
					case "<I>":
						format = Format( ObjectUtil.copy(format) );	
						formats.push(format);
						format.italic = true;
						format.fragment = true;
						break;
					case "</I>":
						//format.italic = false;
						formats.pop();
						format = formats[formats.length - 1];
						break;
					case "<U>":
						format = Format( ObjectUtil.copy(format) );	
						formats.push(format);
						format.underline = format.fragment = true;
						break;
					case "</U>":
						formats.pop();
						format = formats[formats.length - 1];
						break;
					case "<BR>":
						// Both cases will set line break to true.  It is typically entered as <br /> 
						// but the parser converts this to a start and end tag
						//lineBreak ( pHeight );
						
						doc.addLineBreak();
					case "</BR>":
					default:
						//Process text 
						//currentLine.push(aTaggedString[k].value); //TODO
						if(aTaggedString[k].value != "") aTaggedString[k].value += " ";
						
						format.doubleSpace = true;//startPara;
						
						//TC debug
						//format.makeParagraph = startPara;
						
						/*if(fragmentCount == 0 && format.fragment && !addedFragPara && !startPara)
						{
							format.startParagraph = true;
							addedFragPara = true;
						}
						
						if(format.fragment) 
							fragmentCount++;
						
						if(addedFragPara && (startPara || (fragmentCount > 0 && !format.fragment)))
						{
							fragmentCount = 0;
							format.endParagraph = true;
							addedFragPara = false;
						}*/
						
						
						/*
						//if we're in a paragraph, don't start. if not, start?
						var justStarted:Boolean = false;
						if(startPara && !inPara || (!inPara && numParas < 1))
						{
							if(inPara) format.endPreviousParagraph = true;
							
							format.startParagraph = true;
							numParas ++;
							inPara = true;
							
							justStarted = true;
							
							//format = Format( ObjectUtil.copy(format) );	
							//formats.push(format);
						}
						
						
						
						//if we're writing a new para block, end last paragraph.
						if(!justStarted && startPara && inPara || (inPara && numParas > 0 && startPara))
						{
							//formats.pop();
							//format = formats[formats.length - 1];
							
							numParas--;
							format.endParagraph = true;
							inPara = false;
						}
						*/
						startPara = false;
						
						var txt:String = aTaggedString[k].value;
						
						doc.writeText(txt, format);
						
						break;
				}
			}
			
			return doc;
		}
		
		protected function findAndReplace ( search:String, replace:String, source:String ):String
		{
			return source.split(search).join(replace);
		}
	}
}