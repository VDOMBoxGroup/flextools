package net.vdombox.ide.modules.tree.events
{
	import flash.events.Event;

	public class WorkAreaEvent extends Event
	{
		public static var CREATE_PAGE : String = "createPage";
		public static var CREATE_LINKAGE : String = "createLinkage";
		public static var AUTO_SPACING : String = "autoSpacing";
		
		public static var EXPAND_ALL : String = "expandAll";
		public static var COLLAPSE_ALL : String = "collapseAll";
		
		public static var SHOW_SIGNATURE : String = "showSignature";
		public static var HIDE_SIGNATURE : String = "hideSignature";
		
		public static var UNDO : String = "undo";
		public static var SAVE : String = "save";

		public function WorkAreaEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true )
		{
			super( type, bubbles, cancelable );
		}

		override public function clone() : Event
		{
			return new WorkAreaEvent( type, bubbles, cancelable );
		}
	}
}