package net.vdombox.ide.common.events
{
	import flash.events.Event;

	public class ObjectsTreePanelEvent extends Event
	{
		
		public static const DOUBLE_CLICK : String = 'treeDoubleClick';
		
		public function ObjectsTreePanelEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new ObjectsTreePanelEvent( type, bubbles, cancelable );
		}
	}
}