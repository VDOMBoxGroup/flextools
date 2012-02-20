package net.vdombox.powerpack.lib.player.control
{
	import mx.controls.Alert;
	import mx.controls.Button;
	
	import net.vdombox.powerpack.lib.player.customize.skins.RoundButtonSkin;
	
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