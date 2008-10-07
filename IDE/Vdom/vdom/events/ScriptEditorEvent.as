package vdom.events
{
	import flash.events.Event;

	public class ScriptEditorEvent extends Event
	{
		public static const SET_NAME:String = 'setName';
		
		public var scriptName:String;
		
		public function ScriptEditorEvent(type:String, scriptName:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.scriptName = scriptName;
		}
		
	}
}