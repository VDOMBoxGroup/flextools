package net.vdombox.ide.modules.dataBase.view
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import net.vdombox.ide.common.events.ExternalManagerEvent;
	import net.vdombox.ide.common.interfaces.IExternalManager;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	import net.vdombox.ide.modules.dataBase.model.SessionProxy;
	
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
		private var sessionProxy : SessionProxy;

		override public function onRegister() : void
		{
			dispatcher = new EventDispatcher();
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
		}

		override public function onRemove() : void
		{
			sessionProxy = null;
			dispatcher = null;
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.REMOTE_CALL_RESPONSE );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.REMOTE_CALL_RESPONSE:
				{
					var event : ExternalManagerEvent = new ExternalManagerEvent( ExternalManagerEvent.CALL_COMPLETE );
					event.result = body;
					
					// FIXME: медиатор может посылать оповещения но не Евенты.
					dispatchEvent( event );
					
					break;
				}
			}
		}

		// FIXME: зачем возвращать Стринг если всегда возвращается Нулл?
		public function remoteMethodCall( functionName : String, value : String ) : String
		{
			var objectID : String = sessionProxy.selectedTable ? sessionProxy.selectedTable.id : sessionProxy.selectedBase.id;

			sendNotification( ApplicationFacade.REMOTE_CALL_REQUEST,
							  { applicationVO: sessionProxy.selectedApplication, objectID: objectID, functionName: functionName, value: value } );
			return null;
		}

		// FIXME: неправильное поведение медиатора, ведет себя как Визуальный Обьект
		public function addEventListener( type : String, listener : Function, useCapture : Boolean = false, priority : int = 0,
										  useWeakReference : Boolean = false ) : void
		{
			dispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}

		// FIXME: неправильное поведение медиатора, ведет себя как Визуальный Обьект
		public function removeEventListener( type : String, listener : Function, useCapture : Boolean = false ) : void
		{
			dispatcher.removeEventListener( type, listener, useCapture );
		}

		// FIXME: неправильное поведение медиатора, ведет себя как Визуальный Обьект
		public function dispatchEvent( event : Event ) : Boolean
		{
			return dispatcher.dispatchEvent( event );
		}

		// FIXME: неправильное поведение медиатора, ведет себя как Визуальный Обьект
		public function hasEventListener( type : String ) : Boolean
		{
			return dispatcher.hasEventListener( type );
		}
		
		// FIXME: неправильное поведение медиатора, ведет себя как Визуальный Обьект
		public function willTrigger( type : String ) : Boolean
		{
			return dispatcher.willTrigger( type );
		}
	}
}