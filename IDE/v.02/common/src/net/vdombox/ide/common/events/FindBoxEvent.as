package net.vdombox.ide.common.events
{
	import flash.events.Event;

	public class FindBoxEvent extends Event
	{
		public static const CLOSE : String = "findClose";
		public static const CREATION_COMPLETE : String = "findBoxCreationComplete";
		
		public static const FIND_TEXT_IN_SELECTED_TYPE : String = "findTextInSelectedType";
		
		public static const ITEM_CLICK : String = "findItemClick";
		
		public function FindBoxEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new FindBoxEvent( type, bubbles, cancelable );
		}
	}
}