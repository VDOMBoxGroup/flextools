package net.vdombox.object_editor.event
{
	import flash.events.Event;

	public class ScriptAreaComponenrEvent extends Event
	{
		public static const TEXT_CHANGE : String = "scriptAreaComponentTextChange";
		
		public var detail : Object;
		
		public function ScriptAreaComponenrEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false, detail : Object = null )
		{
			super( type, bubbles, cancelable );
			this.detail = detail;
		}
		
		override public function clone() : Event
		{
			return new ScriptAreaComponenrEvent( type, bubbles, cancelable, detail );
		}
	}
}