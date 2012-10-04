package net.vdombox.ide.common.events
{
	import flash.events.Event;
	
	import net.vdombox.ide.common.model._vo.PageVO;

	public class PopUpWindowEvent extends Event
	{
		public var base : PageVO;
		public var name : String;
		
		public var detail : Object;
		
		public static var APPLY : String = "apply";
		public static var CANCEL : String = "cancelw";
		public static var CLOSE : String = "popUpClose";
		
		
		public function PopUpWindowEvent(type : String, _base : PageVO = null, _name : String = "", detail : Object = null )
		{
			base = _base;
			name = _name;
			this.detail = detail;
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new PopUpWindowEvent( type, base, name );
		}
	}
}