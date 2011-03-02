package net.vdombox.ide.common.vo
{
	/**
	* The ApplicationEventsVO is Visual Object of VDOM Application.
	* ApplicationEventsVO is contained in VDOM Application. 
	*/		
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
		
		public function getEventsXML() : XML
		{
			var result : XML = <Events />;
			
			var event : Object;
			var eventXML : XML;
			var actionVO : Object;
			
			for each ( event in events )
			{
				eventXML = event.eventVO.toXML();
				
				for each( actionVO in event.actions )
				{
					eventXML.appendChild( <Action ID={ actionVO.id } /> );
				}
				
				result.appendChild( eventXML );
			}
			
			return result;
		}
		
		public function getClientActionsXML() : XML
		{
			var result : XML = <ClientActions />;
			
			var clientActionXML : XML;
			var clientActionVO : ClientActionVO;
			
			for each ( clientActionVO in clientActions )
			{
				clientActionXML = clientActionVO.toXML();
				result.appendChild( clientActionXML );
			}
			
			return result;
		}
		
		public function getServerActionsXML() : XML
		{
			var result : XML = <ServerActions />;
			
			var serverActionXML : XML;
			var serverActionVO : ServerActionVO;
			
			for each ( serverActionVO in serverActions )
			{
				serverActionXML = serverActionVO.toXML();
				result.appendChild( serverActionXML );
			}
			
			return result;
		}
	}
}