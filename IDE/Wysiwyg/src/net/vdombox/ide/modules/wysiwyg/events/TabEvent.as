package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.display.DisplayObject;
	import flash.events.Event;

	public class TabEvent extends Event
	{
		public static const OBJECT_ADD : String = "objectAdd";

		public static const OBJECT_REMOVE : String = "objectRemove";

		public function TabEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true, object : DisplayObject = null, index : int = -1 )
		{
			super( type, bubbles, cancelable );

			this.object = object;
			this.index = index;
		}

		public var index : int;

		public var object : DisplayObject;

		override public function clone() : Event
		{
			return new TabEvent( type, bubbles, cancelable, object, index );
		}
	}
}
