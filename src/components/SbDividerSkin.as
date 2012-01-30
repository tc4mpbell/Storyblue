package components
{
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	
	import mx.skins.ProgrammaticSkin;
	
	public class SbDividerSkin extends ProgrammaticSkin
	{
		public function SbDividerSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var divwidth:Number = getStyle("dividerThickness");
			if (divwidth == 0)
			{
				divwidth = 5;
			}
			
			graphics.clear();
			graphics.beginFill(0x555555, 1.0);
			
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox( unscaledWidth, unscaledHeight, Math.PI / 2, 0, 0);
			var spreadMethod:String = SpreadMethod.PAD;
			
			graphics.beginGradientFill(flash.display.GradientType.LINEAR, [0xDDDDDD, 0x444444], [1,1], [0,255],matrix);
			graphics.drawRect(-(parent.height / 2), -(divwidth / 2), parent.height, divwidth);
			graphics.endFill();
		}
	}
}