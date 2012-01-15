package net.vdombox.powerpack.control
{
	import mx.controls.Alert;
	import mx.controls.Button;
	
	import net.vdombox.powerpack.customize.skins.RoundButtonSkin;
	import net.vdombox.powerpack.lib.extendedapi.containers.SuperAlert;
	
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
		}
	}
}