package net.vdombox.object_editor.event
{
	import flash.events.Event;

	public class PopupEvent extends Event
	{
		
		public static var CANCEL : String = "popupCancel";
		public static var APPLY : String = "popupApply";
		
		public function PopupEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new PopupEvent( type, bubbles, cancelable );
		}
	}
}