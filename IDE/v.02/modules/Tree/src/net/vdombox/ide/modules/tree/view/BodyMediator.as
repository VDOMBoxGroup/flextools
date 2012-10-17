package net.vdombox.ide.modules.tree.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.tree.model.StatesProxy;
	import net.vdombox.ide.modules.tree.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class BodyMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BodyMediator";

		public function BodyMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var statesProxy : StatesProxy;

		private var isAllStatesGetted : Boolean;
		private var isPagesGetted : Boolean;
		private var isApplicationStructureGetted : Boolean;
		
		private var isBodyStarted : Boolean;

		public function get body() : Body
		{
			return viewComponent as Body;
		}

		override public function onRegister() : void
		{
			isAllStatesGetted = false;
			isPagesGetted = false;
			isApplicationStructureGetted = false;
			isBodyStarted = false;

			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			addHandlers();
		}

		override public function onRemove() : void
		{
			isAllStatesGetted = false;
			isPagesGetted = false;
			isApplicationStructureGetted = false;

			isBodyStarted = false;
			
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( StatesProxy.ALL_STATES_GETTED );
			interests.push( Notifications.PAGES_GETTED );
			interests.push( Notifications.APPLICATION_STRUCTURE_GETTED );
			interests.push( StatesProxy.SELECTED_APPLICATION_CHANGED );

			interests.push( Notifications.PIPES_READY );
			interests.push( Notifications.MODULE_DESELECTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var messageName : String = notification.getName();
			var messageBody : Object = notification.getBody();

			switch ( notification.getName() )
			{
				case Notifications.PIPES_READY:
				{
					sendNotification( StatesProxy.GET_ALL_STATES );

					break;
				}
				
				case StatesProxy.SELECTED_APPLICATION_CHANGED:
				{
					isAllStatesGetted = true;
					
					if ( statesProxy.selectedApplication )
					{
						sendNotification( Notifications.GET_PAGES, statesProxy.selectedApplication );
						sendNotification( Notifications.GET_APPLICATION_STRUCTURE, statesProxy.selectedApplication );
					}
					
					checkConditions();
					
					break;
				}
					
				case StatesProxy.ALL_STATES_GETTED:
				{
					isAllStatesGetted = true;

					if ( statesProxy.selectedApplication )
					{
						sendNotification( Notifications.GET_PAGES, statesProxy.selectedApplication );
						sendNotification( Notifications.GET_APPLICATION_STRUCTURE, statesProxy.selectedApplication );
					}

					checkConditions();

					break;
				}

				case Notifications.PAGES_GETTED:
				{
					isPagesGetted = true;

					checkConditions();

					break;
				}

				case Notifications.APPLICATION_STRUCTURE_GETTED:
				{
					isApplicationStructureGetted = true;

					checkConditions();

					break;
				}

				case Notifications.MODULE_DESELECTED:
				{
					isAllStatesGetted = false;
					isApplicationStructureGetted = false;
					isPagesGetted = false;

					sendNotification( Notifications.BODY_STOP );
					
					isBodyStarted = false;

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function removeHandlers() : void
		{
			body.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( Notifications.BODY_CREATED, body );

			checkConditions();
		}

		private function checkConditions() : void
		{
			if ( isAllStatesGetted && isPagesGetted && isApplicationStructureGetted && body.initialized && !isBodyStarted )
			{
				isBodyStarted = true;
				sendNotification( Notifications.BODY_START );
			}
		}
	}
}