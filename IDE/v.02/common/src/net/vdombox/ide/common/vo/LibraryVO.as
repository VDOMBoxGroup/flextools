package net.vdombox.ide.common.vo
{
	/**
	 * The LibraryVO is Visual Object of VDOM Library.
	 * Library used by the Application. 
	 */	
	public class LibraryVO
	{
		public function LibraryVO( name : String, applicationVO : ApplicationVO )
		{
			_name = name;
			_applicationVO = applicationVO;
		}
		
		public var script : String;
		
		private var _name : String;
		private var _applicationVO : ApplicationVO;
		
		public function get name() : String
		{
			return _name;
		}
		
		public function get applicationVO() : ApplicationVO
		{
			return _applicationVO;
		}
	}
}