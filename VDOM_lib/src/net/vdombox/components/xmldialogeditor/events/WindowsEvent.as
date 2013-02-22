package net.vdombox.components.xmldialogeditor.events
{
	import flash.events.Event;

	public class WindowsEvent extends Event
	{
		public static const APPLY : String = "windowsEventApply";
		public static const CLOSE : String = "windowsEventClose";
		
		public function WindowsEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone() : Event
		{
			return new WindowsEvent( type, bubbles, cancelable );
		}
	}
}