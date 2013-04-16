package net.vdombox.powerpack.lib.player.control
{
	import mx.controls.Button;
	import mx.core.mx_internal;
	
	use namespace mx_internal;
	
	public class RoundButton extends Button
	{
		public function RoundButton()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			width = 80;
			height = 30;
			
			super.commitProperties();
		}
		
	}
}