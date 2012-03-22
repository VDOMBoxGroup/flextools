package net.vdombox.powerpack.lib.player.control
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.core.mx_internal;
	
	import net.vdombox.powerpack.lib.player.customize.skins.RoundButtonSkin;
	
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
		
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			super.keyDownHandler(event);
			
			if (!enabled)
				return;
			
			if (event.keyCode == Keyboard.ENTER)
				dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}

	}
}