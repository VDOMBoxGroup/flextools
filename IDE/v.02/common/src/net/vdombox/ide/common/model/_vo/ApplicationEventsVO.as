package net.vdombox.ide.common.model._vo
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

		public function get pageVO() : PageVO
		{
			return _pageVO;
		}

		public function copy() : ApplicationEventsVO
		{
			var copyApplicationEventsVO : ApplicationEventsVO = new ApplicationEventsVO( _pageVO );

			var copyEvents : Array = new Array();

			for each ( var element : Object in events )
			{
				var copyElement : Object = [];
				var actions : Array = new Array();
				for ( var i : int = 0; i < element.actions.length; i++ )
				{
					actions.push( element.actions[ i ].clone() );
				}
				var eventVO : EventVO = element.eventVO.clone();
				copyElement.actions = actions;
				copyElement.eventVO = eventVO;

				copyEvents.push( copyElement );
			}

			copyApplicationEventsVO.events = copyEvents;

			var copyClientActions : Array = new Array;

			for each ( var elementCA : ClientActionVO in clientActions )
			{
				copyClientActions.push( elementCA.clone() );
			}

			copyApplicationEventsVO.clientActions = copyClientActions;

			var copyServerActions : Array = new Array;

			for each ( var elementSA : ServerActionVO in serverActions )
			{
				copyServerActions.push( elementSA.clone() );
			}

			copyApplicationEventsVO.serverActions = copyServerActions;

			return copyApplicationEventsVO;
		}

		public function getServetActionByID( actionID : String ) : ServerActionVO
		{
			var serverAction : ServerActionVO;
			for each ( serverAction in serverActions )
			{
				if ( serverAction.id == actionID )
					return serverAction;
			}
			return null;
		}

		public function getEventsXML() : XML
		{
			var result : XML = <Events/>;

			var event : Object;
			var eventXML : XML;
			var actionVO : Object;

			for each ( event in events )
			{
				eventXML = event.eventVO.toXML();

				for each ( actionVO in event.actions )
				{
					eventXML.appendChild( <Action ID={actionVO.id}/> );
				}

				result.appendChild( eventXML );
			}

			return result;
		}

		public function getClientActionsXML() : XML
		{
			var result : XML = <ClientActions/>;

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
			var result : XML = <ServerActions/>;

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
