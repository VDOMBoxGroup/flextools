package net.vdombox.ide.common.events
{
	import flash.events.Event;

	import mx.core.IVisualElement;

	public class TabEvent extends Event
	{
		public static const ELEMENT_ADD : String = "element_Add";

		public static const ELEMENT_REMOVE : String = "element_Remove";

		public function TabEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false, element : IVisualElement = null, index : int = -1 )
		{
			super( type, bubbles, cancelable );

			this.element = element;
			this.index = index;
		}

		public var index : int;

		public var element : IVisualElement;

		override public function clone() : Event
		{
			return new TabEvent( type, bubbles, cancelable, element, index );
		}
	}
}
