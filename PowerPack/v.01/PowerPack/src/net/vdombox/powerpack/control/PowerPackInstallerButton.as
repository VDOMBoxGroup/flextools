package net.vdombox.powerpack.control
{
	import mx.controls.Button;
	
	import net.vdombox.powerpack.customize.skins.GradientButtonSkin;
	
	public class PowerPackInstallerButton extends Button
	{
		public function PowerPackInstallerButton()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			width = 80;
			height = 26;
		}
	}
}