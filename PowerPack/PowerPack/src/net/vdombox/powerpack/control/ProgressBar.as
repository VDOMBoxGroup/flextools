package net.vdombox.powerpack.control
{
	import mx.controls.ProgressBar;
	import mx.core.mx_internal;
	
	public class ProgressBar extends mx.controls.ProgressBar
	{
		use namespace mx_internal; 
		
		public function ProgressBar()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var labelTextWidth : int = _labelField.width-10;
			var len : int;
			if ( _labelField.textWidth > labelTextWidth )
			{
				while ( _labelField.textWidth > labelTextWidth )
				{
					len = _labelField.text.length;
					_labelField.text = _labelField.text.substr(0, len-1);
				}
				
				_labelField.text += "...";
			}
		}
		
		
	}
}