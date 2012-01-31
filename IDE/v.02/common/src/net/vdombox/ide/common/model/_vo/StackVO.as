package net.vdombox.ide.common.model._vo
{
	public class StackVO
	{
		private var _stack : Array;
		private var _index : int;
		
		public function StackVO()
		{
			_stack = new Array();
			_index = -1;
		}
		
		public function add( stackItem : Object ) : void
		{
			_stack.push( stackItem );
			_index++;
		}
		
		public function undo() : Object
		{
			if ( _index < 0 )
				return null;
			
			return _stack[ _index ];
			_index--;
		}
		
		public function redo() : Object
		{
			if ( _index < 0 || _index == _stack.length - 1 )
				return null;
			
			return _stack[ _index ];
			_index++;
		}
	}
}