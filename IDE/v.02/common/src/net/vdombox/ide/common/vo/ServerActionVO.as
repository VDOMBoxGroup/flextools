package net.vdombox.ide.common.vo
{
	public class ServerActionVO
	{
		public function ServerActionVO( id : String, container : Object )
		{
			_container = container;
		}

		public var name : String;
		
		public var script : String;
		
		public var language : String;
		
		private var _container : Object;
	
		public function get container() : Object
		{
			return _container;
		}
	}		
}