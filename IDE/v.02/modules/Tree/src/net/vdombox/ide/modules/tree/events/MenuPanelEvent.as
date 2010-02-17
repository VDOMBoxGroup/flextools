package net.vdombox.ide.modules.tree.events
{
	import flash.events.Event;

	public class MenuPanelEvent extends Event
	{
		public static var CREATE_PAGE : String = "createPage";
		public static var AUTO_SPACING : String = "autoSpacing";
		public static var EXPAND_ALL : String = "expandAll";
		public static var SHOW_SIGNATURE : String = "showSignature";
		public static var UNDO : String = "undo";
		public static var SAVE : String = "save";

		public function MenuPanelEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new MenuPanelEvent( type, bubbles, cancelable );
		}
	}
}