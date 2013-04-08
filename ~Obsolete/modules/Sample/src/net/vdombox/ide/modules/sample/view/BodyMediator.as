package net.vdombox.ide.modules.sample.view
{
	import mx.events.FlexEvent;

	import net.vdombox.ide.modules.sample.ApplicationFacade;
	import net.vdombox.ide.modules.sample.view.components.main.Body;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class BodyMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BodyMediator";

		public function BodyMediator( viewComponent : Body )
		{
			super( NAME, viewComponent );
		}

		private var isBodyStarted : Boolean;

		private var isAllStatesGetted : Boolean;

		public function get body() : Body
		{
			return viewComponent as Body;
		}

		override public function onRegister() : void
		{
			isBodyStarted = false;

			isAllStatesGetted = false;

			addHandlers();
		}

		override public function onRemove() : void
		{
			isBodyStarted = false;

			isAllStatesGetted = false;

			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.ALL_STATES_GETTED );
			interests.push( ApplicationFacade.TYPES_CHANGED );

			interests.push( ApplicationFacade.PIPES_READY );
			interests.push( ApplicationFacade.MODULE_DESELECTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case ApplicationFacade.PIPES_READY:
				{
					sendNotification( ApplicationFacade.GET_ALL_STATES );
					sendNotification( ApplicationFacade.GET_TYPES );

					break;
				}

				case ApplicationFacade.ALL_STATES_GETTED:
				{
					isAllStatesGetted = true;

					checkConditions();

					break;
				}

				case ApplicationFacade.MODULE_DESELECTED:
				{
					isAllStatesGetted = false;

					sendNotification( ApplicationFacade.BODY_STOP );

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
			sendNotification( ApplicationFacade.BODY_CREATED, body );

			checkConditions();
		}

		private function checkConditions() : void
		{
			if ( isAllStatesGetted && body.initialized && !isBodyStarted )
			{
				isBodyStarted = true;
				sendNotification( ApplicationFacade.BODY_START );
			}
		}
	}
}