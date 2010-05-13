package net.vdombox.ide.modules.scripts.events
{
	import flash.events.Event;
	
	public class ScriptEditorEvent extends Event
	{
		public static var SAVE : String = "save";
		
		public function ScriptEditorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone() : Event
		{
			return new ScriptEditorEvent( type, bubbles, cancelable );
		}
	}
}