package net.vdombox.powerpack.lib.extendedapi.controls
{
	import flash.geom.Point;
	
	import mx.controls.TextArea;
	import mx.core.IUITextField;

	public class SuperTextArea extends TextArea
	{
		public function SuperTextArea()
		{
			super();
		}
		
		public function get field():IUITextField
		{
			return super.textField;
		}
		
		public function getPointForIndex(index:int):Point
		{
			var curLine : int = 0;
			
			while (true)
			{
				if (curLine >= field.numLines)
				{
					curLine --;
					break;
				}
				
				var lineOffset : int = field.getLineOffset(curLine);
				
				if (index <= lineOffset)
				{
					if (index < lineOffset)
						curLine --;
					
					break;
				}
				
				curLine ++;
			}
			
			var lineHeight : Number = field.getLineMetrics(curLine).height;
			var lineWidth : Number = field.getLineMetrics(curLine).width;
			
			var letterWidth : Number = lineWidth ? Math.floor(lineWidth / field.getLineText(curLine).length) + 1 : 0;
			
			var distX : Number = 5;
			var distY : Number = 5 + lineHeight;
			
			var x : Number = ( index - field.getLineOffset(curLine) ) * letterWidth + distX;
			var y : Number = curLine * lineHeight + distY;
			
			return new Point(x , y);
		}
		
	}
}