package net.vdombox.ide.modules.dataBase.events
{
	import flash.events.Event;
	
	import net.vdombox.ide.common.vo.PageVO;

	public class PopUpWindowEvent extends Event
	{
		public var base : PageVO;
		public var name : String;
		
		public static var APPLY : String = "apply";
		public static var CANCEL : String = "cancelw";
		
		
		public function PopUpWindowEvent(type : String, _base : PageVO = null, _name : String = "" )
		{
			base = _base;
			name = _name;
			super( type, bubbles, cancelable );
		}
		
		override public function clone() : Event
		{
			return new PopUpWindowEvent( type, base, name );
		}
	}
}