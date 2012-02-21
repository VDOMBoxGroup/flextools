package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.ExternalManagerEvent;
	import net.vdombox.ide.common.interfaces.IExternalManager;
	import net.vdombox.ide.common.model.StatesProxy;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ExternalManagerMediator extends Mediator implements IMediator, IEventDispatcher, IExternalManager
	{
		public static const NAME : String = "ExternalManagerMediator";

		public function ExternalManagerMediator() : void
		{
			super( NAME );
		}

		private var dispatcher : EventDispatcher;
		private var statesProxy : StatesProxy;

		override public function onRegister() : void
		{
			dispatcher = new EventDispatcher();
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
		}

		override public function onRemove() : void
		{
			statesProxy = null;
			dispatcher = null;
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( Notifications.REMOTE_CALL_RESPONSE );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case Notifications.REMOTE_CALL_RESPONSE:
				{
					var event : ExternalManagerEvent = new ExternalManagerEvent( ExternalManagerEvent.CALL_COMPLETE );
					event.result = body;
					dispatchEvent( event );
					
					break;
				}
			}
		}

		public function remoteMethodCall( functionName : String, value : String ) : String
		{
			var objectID : String = statesProxy.selectedObject ? statesProxy.selectedObject.id : statesProxy.selectedPage.id;

			sendNotification( Notifications.REMOTE_CALL_REQUEST,
							  { applicationVO: statesProxy.selectedApplication, objectID: objectID, functionName: functionName, value: value } );
			return null;
		}

		public function addEventListener( type : String, listener : Function, useCapture : Boolean = false, priority : int = 0,
										  useWeakReference : Boolean = false ) : void
		{
			dispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}

		public function removeEventListener( type : String, listener : Function, useCapture : Boolean = false ) : void
		{
			dispatcher.removeEventListener( type, listener, useCapture );
		}

		public function dispatchEvent( event : Event ) : Boolean
		{
			return dispatcher.dispatchEvent( event );
		}

		public function hasEventListener( type : String ) : Boolean
		{
			return dispatcher.hasEventListener( type );
		}

		public function willTrigger( type : String ) : Boolean
		{
			return dispatcher.willTrigger( type );
		}
	}
}