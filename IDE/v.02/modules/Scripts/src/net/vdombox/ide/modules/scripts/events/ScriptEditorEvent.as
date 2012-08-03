package net.vdombox.ide.modules.scripts.events
{
	import flash.events.Event;
	
	public class ScriptEditorEvent extends Event
	{
		public static var SAVE : String = "save";
		public static var OPEN_FIND : String = "openFind";
		public static var OPEN_FIND_GLOBAL : String = "openFindGlobal";
		
		public static var SAVED : String = "actionSaved";
		public static var NOT_SAVED : String = "actionNotSaved";
		
		public static var SCRIPT_EDITOR_ADDED : String = "scriptEditorAdded";
		
		public static var OPEN_PREFERENCES : String = "openPreferences";
		
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