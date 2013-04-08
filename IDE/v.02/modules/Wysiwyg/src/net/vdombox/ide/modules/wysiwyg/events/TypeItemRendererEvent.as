package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;

	public class TypeItemRendererEvent extends Event
	{
		public static var DATA_CHANGE : String = "itemRendererDataChange";

		public static var ADD_IN_USER_CATIGORY : String = "addInUserCategory";

		public static var DELET_IN_USER_CATIGORY : String = "delInUserCategory";

		public static var DOUBLE_CLICK : String = "typeItemRendererDoubleClick";

		public function TypeItemRendererEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new TypeItemRendererEvent( type, bubbles, cancelable );
		}
	}
}
