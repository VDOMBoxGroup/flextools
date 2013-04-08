package vdom.events
{
	import flash.events.Event;

	public class EventEditorEvent extends Event
	{
		public static const DATA_CHANGED:String = 'dataChanged';
		
		public var dataEvent:Object;
		public var dataAction:Object;
		public var objID:String;
		
		public function EventEditorEvent(type:String, dataEvent:Object=null, dataAction:Object=null, objID:String='', bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.dataEvent = dataEvent;
			this.dataAction = dataAction;
			this.objID = objID;
		}
		
	}
}