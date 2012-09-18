package flex.utils.ui
{
	import flash.display.Graphics;
	
	import mx.containers.DividedBox;
	import mx.containers.dividedBoxClasses.BoxDivider;
	import mx.core.UIComponent;
	
	
	/**
	 *  The alpha value for the background behind the dividers.
	 *  A value of <code>0.0</code> means completely transparent
	 *  and a value of <code>1.0</code> means completely opaque.
	 *  @default 1
	 */
	[Style(name="dividerBackgroundAlpha", type="Number", inherit="no")]
	
	/**
	 *  Background color of behind the dividers
	 *  @default 0x000000
	 */
	[Style(name="dividerBackgroundColor", type="uint", format="Color", inherit="no")]
	
	
	[IconFile("DividedBox.png")]
	
	/**
	 * Extends the mx.containers.DividedBox class to add the dividerBackgroundAlpha and
	 * dividerBackgroundColor styles.  These styles fill in the background behind each divider.
	 * 
	 * @author Chris Callendar
	 * @date April 20th, 2010
	 */ 
	public class DividedBox extends mx.containers.DividedBox
	{
		
		public function DividedBox() {
			super();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			super.updateDisplayList(w, h);
			
			// fill in behind each divider
			var dividerCount:int = numDividers;
			if (dividerCount > 0) {
				var bgColor:uint = getStyle("dividerBackgroundColor");
				var bgAlpha:Number = getStyle("dividerBackgroundAlpha");
				if (isNaN(bgAlpha) || (bgAlpha < 0) && (bgAlpha > 1)) { 
					bgAlpha = 1;
				}
				// use the divider's parent (dividerLayer) to paint the background
				var g:Graphics = (getDividerAt(0).parent as UIComponent).graphics;
				g.clear();
				for (var i:int = 0; i < dividerCount; i++) {
					var divider:BoxDivider = getDividerAt(i);
					g.beginFill(bgColor, bgAlpha);
					g.drawRect(divider.x, divider.y, divider.width, divider.height);
					g.endFill();
				}
			}
			
		}
		
	}
}