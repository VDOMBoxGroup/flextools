package vdom.events
{
	import flash.events.Event;

	public class EventEditorEvent extends Event
	{
		public static const DATA_CHANGED:String = 'dataChanged';
		
		public var data:Object;
		public var objID:String;
		
		public function EventEditorEvent(type:String, data:Object=null, objID:String='', bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
			this.objID = objID;
		}
		
	}
}