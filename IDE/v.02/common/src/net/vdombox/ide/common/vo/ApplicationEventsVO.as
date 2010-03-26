package net.vdombox.ide.common.vo
{
	public class ApplicationEventsVO
	{
		public function ApplicationEventsVO( pageVO : PageVO )
		{
			_pageVO = pageVO;
			
			events = [];
			clientActions = [];
			serverActions = [];
		}
		
		public var events : Array;
		public var clientActions : Array;
		public var serverActions : Array;
		
		private var _pageVO : PageVO;
		
		public function get pageVO () : PageVO
		{
			return _pageVO;
		}
	}
}