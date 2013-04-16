package net.vdombox.powerpack.lib.player.control
{
	import mx.controls.Button;
	
	public class BrowseButton extends Button
	{
		public function BrowseButton()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			width = 80;
			height = 25;
			
			super.commitProperties();
		}
	}
}