package net.vdombox.editors.parsers
{
	import flash.events.EventDispatcher;
	
	import net.vdombox.editors.HashLibraryArray;
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.ide.common.interfaces.IEventBaseVO;
	
	import ro.victordramba.thread.ThreadsController;

	public class Controller extends EventDispatcher
	{
		protected var fld : ScriptAreaComponent;
		protected var tc : ThreadsController;
		
		public var status : String;
		public var percentReady : Number = 0;
		protected var t0 : Number;
		
		protected var _actionVO : Object;
		
		public function Controller()
		{
		}
		
		public function getTokenByPos( pos : int ) : Token
		{
			return null
		}
		
		public function set actionVO( actVO : Object ) : void
		{
			_actionVO = actVO;
		}
		
		public function get actionVO() : Object
		{
			return _actionVO;
		}
	}
}