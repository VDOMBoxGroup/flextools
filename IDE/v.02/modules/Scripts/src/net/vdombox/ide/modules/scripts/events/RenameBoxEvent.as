package net.vdombox.ide.modules.scripts.events
{
	import flash.events.Event;

	public class RenameBoxEvent extends Event
	{
		public static const RENAME_IN_ACTION : String = "renameInAction";
		public static const FIND_IN_SERVER_SCRIPTS : String = "findInServerScripts";
		public static const CREATION_COMPLETE : String = "renameBoxCreationComplete";
		public static const DOUBLE_CLICK : String = "renameDoubleClick";
		public static const CLOSE : String = "renameClose";
		
		public var detail : Object;
		
		public function RenameBoxEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false , detail : Object = null)
		{
			super( type, bubbles, cancelable );
			this.detail = detail;
		}
		
		override public function clone() : Event
		{
			return new RenameBoxEvent( type, bubbles, cancelable );
		}
	}
}