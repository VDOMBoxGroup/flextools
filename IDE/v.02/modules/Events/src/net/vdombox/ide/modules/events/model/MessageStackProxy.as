package net.vdombox.ide.modules.events.model
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.events.view.components.UndoStackItem;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class MessageStackProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "MessageStackProxy";
		
		private var _pageVO : PageVO
		private var _stack : Array;
		private var _index : int;
		
		public function get length() : int
		{
			return _stack.length;
		}
		
		public function MessageStackProxy( objectComponent : PageVO )
		{
			_pageVO = objectComponent;
			
			var instanceName : String = NAME + _pageVO.id;
			
			super( instanceName );
			
			_stack = new Array();
			_index = -1;
		}
		
		public function push( message : ProxyMessage ) : void
		{
			if ( _index < _stack.length - 1 )
				_stack.splice(_index + 1, _stack.length - 1 - _index);
			
			_stack.push( new UndoStackItem( message ) );
			_index = _stack.length - 1;0
		}
		
		public function undo() : ProxyMessage
		{
			if ( _index > 0 )
				return _stack[--_index].undo();
			
			return null;
		}
		
		public function redo() : ProxyMessage
		{
			if ( _index >= -1 && _index < _stack.length - 1 )
				return _stack[++_index].redo();
			
			return null;
		}
		
		public function removeAll() : void
		{
			_stack.splice(0, _stack.length );
			_index = -1;
		}
	}
}