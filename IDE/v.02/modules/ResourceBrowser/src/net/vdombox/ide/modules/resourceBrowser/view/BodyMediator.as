package net.vdombox.ide.modules.resourceBrowser.view
{
	import mx.events.FlexEvent;

	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.resourceBrowser.model.StatesProxy;
	import net.vdombox.ide.modules.resourceBrowser.view.components.Body;

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

		public var selectedResource : ResourceVO;

		public var selectedApplication : ApplicationVO;

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

			interests.push( Notifications.PIPES_READY );
			interests.push( Notifications.MODULE_DESELECTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case Notifications.PIPES_READY:
				{
					sendNotification( StatesProxy.GET_ALL_STATES );

					break;
				}

				case StatesProxy.ALL_STATES_GETTED:
				{
					isReady = true;

					checkConditions();

					break;
				}

				case Notifications.MODULE_DESELECTED:
				{
					isReady = false;

					sendNotification( Notifications.BODY_STOP );

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			body.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function checkConditions() : void
		{
			if ( isReady && body.initialized )
				sendNotification( Notifications.BODY_START );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( Notifications.BODY_CREATED, body );

			checkConditions();
		}
	}
}
