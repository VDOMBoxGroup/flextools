//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.events.FlexEvent;

	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.main.Body;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;


	/**
	 *
	 * @author andreev ap
	 */
	public class BodyMediator extends Mediator implements IMediator
	{
		/**
		 *
		 * @default
		 */
		public static const NAME : String = "BodyMediator";

		/**
		 *
		 * @param viewComponent
		 */
		public function BodyMediator( viewComponent : Body )
		{
			super( NAME, viewComponent );
		}

		private var isAllStatesGetted : Boolean;

		private var isBodyStarted : Boolean;

		private var isTypesChanged : Boolean;

		/**
		 *
		 * @return
		 */
		public function get body() : Body
		{
			return viewComponent as Body;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case Notifications.PIPES_READY:
				{
					sendNotification( StatesProxy.GET_ALL_STATES );
					sendNotification( TypesProxy.GET_TYPES );

					break;
				}

				case StatesProxy.ALL_STATES_GETTED:
				{
					isAllStatesGetted = true;

					checkConditions();

					break;
				}

				case TypesProxy.TYPES_CHANGED:
				{
					isTypesChanged = true;

					checkConditions();

					break;
				}

				case Notifications.MODULE_DESELECTED:
				{
					isAllStatesGetted = false;
					isTypesChanged = false;

					sendNotification( Notifications.BODY_STOP );

					isBodyStarted = false;

					break;
				}
			}
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( StatesProxy.ALL_STATES_GETTED );
			interests.push( TypesProxy.TYPES_CHANGED );

			interests.push( Notifications.PIPES_READY );
			interests.push( Notifications.MODULE_DESELECTED );

			return interests;
		}

		override public function onRegister() : void
		{
			isBodyStarted = false;

			isAllStatesGetted = false;

			isTypesChanged = false;

			addHandlers();
		}

		override public function onRemove() : void
		{
			isBodyStarted = false;

			isAllStatesGetted = false;

			isTypesChanged = false;

			removeHandlers();
		}

		private function addHandlers() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function checkConditions() : void
		{
			if ( isAllStatesGetted && isTypesChanged && body.initialized && !isBodyStarted )
			{
				isBodyStarted = true;
				sendNotification( Notifications.BODY_START );
			}
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( Notifications.BODY_CREATED, body );

			checkConditions();
		}

		private function removeHandlers() : void
		{
			body.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}
	}
}


