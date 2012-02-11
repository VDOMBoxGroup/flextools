package net.vdombox.powerpack.control
{
	import mx.controls.Alert;
	import mx.controls.Button;
	
	import net.vdombox.powerpack.customize.skins.RoundButtonSkin;
	
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