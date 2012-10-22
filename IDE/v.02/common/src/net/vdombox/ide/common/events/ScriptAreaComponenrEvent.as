package net.vdombox.ide.common.events
{
	import flash.events.Event;

	public class ScriptAreaComponenrEvent extends Event
	{
		public static const TEXT_INPUT : String = "scriptAreaComponentTextInput";
		public static const TEXT_CHANGE : String = "scriptAreaComponentTextChange";
		public static const GO_TO_DEFENITION : String = "scriptAreaComponentGoToDefenition";
		public static const RENAME : String = "scriptAreaComponentRename";
		public static const GLOBAL_RENAME : String = "scriptAreaComponentGlobalRename";
		public static const PRESS_NAVIGATION_KEY : String = "scriptAreaComponentPressNavigetionKey";
		
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