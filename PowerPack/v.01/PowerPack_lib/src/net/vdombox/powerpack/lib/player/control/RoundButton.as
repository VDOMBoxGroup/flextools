package net.vdombox.powerpack.lib.player.control
{
	import mx.controls.Alert;
	import mx.controls.Button;
	
	import net.vdombox.powerpack.lib.player.customize.skins.RoundButtonSkin;
	
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