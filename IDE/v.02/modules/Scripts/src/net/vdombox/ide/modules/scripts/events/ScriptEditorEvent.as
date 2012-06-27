package net.vdombox.ide.modules.scripts.events
{
	import flash.events.Event;
	
	public class ScriptEditorEvent extends Event
	{
		public static var SAVE : String = "save";
		public static var OPEN_FIND : String = "openFind";
		
		public static var SAVED : String = "actionSaved";
		public static var NOT_SAVED : String = "actionNotSaved";
		
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