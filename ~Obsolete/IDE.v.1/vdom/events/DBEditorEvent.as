package vdom.events
{
	import flash.events.Event;

	public class DBEditorEvent extends Event
	{
		public static const DONE:String = 'done_click';
		
		public var XMLData:XML;
		
		public function DBEditorEvent(type:String, xmlData:XML, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.XMLData = xmlData;
		}		
	}
}