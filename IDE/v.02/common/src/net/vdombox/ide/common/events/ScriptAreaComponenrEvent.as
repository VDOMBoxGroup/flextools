package net.vdombox.ide.common.events
{
	import flash.events.Event;

	public class ScriptAreaComponenrEvent extends Event
	{
		public static const TEXT_INPUT : String = "scriptAreaComponentTextInput";
		
		public function ScriptAreaComponenrEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new ScriptAreaComponenrEvent( type, bubbles, cancelable );
		}
	}
}