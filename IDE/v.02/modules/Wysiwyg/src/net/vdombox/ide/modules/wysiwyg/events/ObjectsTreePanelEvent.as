package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;
	
	public class ObjectsTreePanelEvent extends Event
	{
		public static var CHANGE : String = "otpe_change";
		public static var DOUBLE_CLICK : String = "otpe_doubleClick";
		
		public function ObjectsTreePanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new ObjectsTreePanelEvent( type, bubbles, cancelable );
		}
	}
}