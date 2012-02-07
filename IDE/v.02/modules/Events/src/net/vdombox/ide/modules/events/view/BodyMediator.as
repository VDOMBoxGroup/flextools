package net.vdombox.ide.modules.events.view
{
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	import net.vdombox.ide.modules.events.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class BodyMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BodyMediator";

		public function BodyMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var isReady : Boolean;

		public function get body() : Body
		{
			return viewComponent as Body;
		}

		override public function onRegister() : void
		{
			isReady = false;

			addHandlers();
		}

		override public function onRemove() : void
		{
			isReady = false;

			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( StatesProxy.ALL_STATES_GETTED );

			interests.push( ApplicationFacade.PIPES_READY );
			interests.push( ApplicationFacade.MODULE_DESELECTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName())
			{
				case ApplicationFacade.PIPES_READY:
				{
					sendNotification( StatesProxy.GET_ALL_STATES );
					sendNotification( TypesProxy.GET_TYPES );

					break;
				}

				case StatesProxy.ALL_STATES_GETTED:
				{
					isReady = true;

					checkConditions();

					break;
				}

				case ApplicationFacade.MODULE_DESELECTED:
				{
					isReady = false;
					
					sendNotification( ApplicationFacade.BODY_STOP );

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
			if ( isReady && body.initialized )
				sendNotification( ApplicationFacade.BODY_START );
		}
	}
}