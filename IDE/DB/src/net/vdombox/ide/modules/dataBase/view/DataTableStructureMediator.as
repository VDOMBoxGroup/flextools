package net.vdombox.ide.modules.dataBase.view
{
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.ExternalManagerEvent;
	import net.vdombox.ide.common.interfaces.IExternalManager;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.modules.dataBase.events.DataTablesEvents;
	import net.vdombox.ide.modules.dataBase.view.components.DataTableStructure;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class DataTableStructureMediator extends Mediator implements IMediator, IExternalManager
	{
		public static const NAME : String = "DataTableStructureMediator";

		private var dispatcher : EventDispatcher;

		public function DataTableStructureMediator( viewComponent : Object = null )
		{
			var instanceName : String = NAME + viewComponent.editorID;
			super( instanceName, viewComponent );
		}

		private function get dataTableStructure() : DataTableStructure
		{
			return viewComponent as DataTableStructure;
		}

		override public function onRegister() : void
		{
			dispatcher = new EventDispatcher();

			// FIXME: грубый хак. убрать.
			dataTableStructure.externalManager = this as IExternalManager;
			dataTableStructure.addEventListener( DataTablesEvents.UPDATE_STRUCTURE, sendCommit );
		}

		private function sendCommit( event : DataTablesEvents ) : void
		{
			sendNotification( Notifications.COMMIT_DATA_STRUCTURE, { objectVO: dataTableStructure.objectVO, objectID: dataTableStructure.editorID } );
		}

		override public function onRemove() : void
		{
			dispatcher = null;

			dataTableStructure.removeEventListener( DataTablesEvents.UPDATE_STRUCTURE, sendCommit );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( Notifications.REMOTE_CALL_RESPONSE );
			interests.push( Notifications.REMOTE_CALL_RESPONSE_ERROR );
			interests.push( Notifications.COMMIT_STRUCTURE );
			interests.push( Notifications.GET_TABLE_STRUCTURE );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( body.objectVO.id != dataTableStructure.editorID )
				return;

			switch ( name )
			{
				case Notifications.REMOTE_CALL_RESPONSE:
				{
					var event : ExternalManagerEvent = new ExternalManagerEvent( ExternalManagerEvent.CALL_COMPLETE );
					event.result = body.result;
					dispatchEvent( event );

					break;
				}

				case Notifications.REMOTE_CALL_RESPONSE_ERROR:
				{
					dataTableStructure.currentState = "Result";
					dataTableStructure.updateTable();

					break;
				}

				case Notifications.COMMIT_STRUCTURE:
				{
					dataTableStructure.updateTable();

					break;
				}

				case Notifications.GET_TABLE_STRUCTURE:
				{
					sendNotification( Notifications.TABLE_STRUCTURE_GETTED, { objectVO: dataTableStructure.objectVO, result: dataTableStructure.tableStructure } );

					break;
				}
			}
		}


		// FIXME: нада ничего не возвращать.
		public function remoteMethodCall( functionName : String, value : String ) : String
		{
			var objectVO : ObjectVO = dataTableStructure.objectVO as ObjectVO;

			if ( objectVO )
				sendNotification( Notifications.REMOTE_CALL_REQUEST, { objectVO: objectVO, functionName: functionName, value: value } );
			return null;
		}

		// FIXME: неправильное поведение медиатора, ведет себя как EventDispatcher
		public function addEventListener( type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false ) : void
		{
			dispatcher.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}

		// FIXME: неправильное поведение медиатора, ведет себя как EventDispatcher
		public function removeEventListener( type : String, listener : Function, useCapture : Boolean = false ) : void
		{
			dispatcher.removeEventListener( type, listener, useCapture );
		}

		// FIXME: неправильное поведение медиатора, ведет себя как EventDispatcher
		public function dispatchEvent( event : Event ) : Boolean
		{
			return dispatcher.dispatchEvent( event );
		}

		// FIXME: неправильное поведение медиатора, ведет себя как EventDispatcher
		public function hasEventListener( type : String ) : Boolean
		{
			return dispatcher.hasEventListener( type );
		}

		// FIXME: неправильное поведение медиатора, ведет себя как EventDispatcher
		public function willTrigger( type : String ) : Boolean
		{
			return dispatcher.willTrigger( type );
		}
	}
}
