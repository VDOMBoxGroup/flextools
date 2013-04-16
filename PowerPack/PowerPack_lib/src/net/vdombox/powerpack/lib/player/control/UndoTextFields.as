package net.vdombox.powerpack.lib.player.control
{
	import flash.events.Event;
	import flash.text.TextField;
	
	import gearsandcogs.text.UndoTextFields;
	
	public class UndoTextFields extends gearsandcogs.text.UndoTextFields
	{
		public function UndoTextFields()
		{
			super();
		}
		
		override protected function onTextChange(event:Event):void
		{
			var textField:TextField = event.target as TextField;
			
			if (!textField) {
				return;
			}
			
			var data:Object = getData(textField);
			
			if (!data || !data.lastValue || !data.lastSelection || !data.lastAction)
				return;
			
			super.onTextChange(event);
		}
	}
}