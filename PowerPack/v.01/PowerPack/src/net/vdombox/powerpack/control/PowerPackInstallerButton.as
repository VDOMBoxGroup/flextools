package net.vdombox.powerpack.control
{
	import mx.controls.Alert;
	import mx.controls.Button;
	
	import net.vdombox.powerpack.customize.skins.GradientButtonSkin;
	import net.vdombox.powerpack.lib.extendedapi.containers.SuperAlert;
	
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