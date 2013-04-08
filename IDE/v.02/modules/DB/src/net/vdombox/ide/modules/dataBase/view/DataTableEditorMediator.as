package net.vdombox.ide.modules.dataBase.view
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.ExternalManagerEvent;
	import net.vdombox.ide.common.interfaces.IExternalManager;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.modules.dataBase.events.DataTablesEvents;
	import net.vdombox.ide.modules.dataBase.view.components.DataTableEditor;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;


	// FIXME: неправильное поведение медиатора, ведет себя как IEventDispatcher !
	public class DataTableEditorMediator extends Mediator implements IMediator, IExternalManager, IEventDispatcher
	{
		public static const NAME : String = "DataTableEditorMediator";

		private var dispatcher : EventDispatcher;

		public function DataTableEditorMediator( viewComponent : Object = null )
		{
			var instanceName : String = NAME + viewComponent.editorID;

			super( instanceName, viewComponent );
		}

		private function get dataTableEditor() : DataTableEditor
		{
			return viewComponent as DataTableEditor;
		}

		override public function onRegister() : void
		{
			dispatcher = new EventDispatcher();
			dataTableEditor.externalManager = this as IExternalManager;
		}

		private function setExternalManager( event : DataTablesEvents ) : void
		{
			dataTableEditor.externalManager = this as IExternalManager;
		}

		override public function onRemove() : void
		{
			dispatcher = null;
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( Notifications.REMOTE_CALL_RESPONSE );
			interests.push( Notifications.REMOTE_CALL_RESPONSE_ERROR );
			interests.push( Notifications.COMMIT_DATA_STRUCTURE );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( body.hasOwnProperty( "objectVO" ) && body.objectVO.id != dataTableEditor.editorID )
				return;

			switch ( name )
			{
				case Notifications.REMOTE_CALL_RESPONSE:
				{
					var event : ExternalManagerEvent = new ExternalManagerEvent( ExternalManagerEvent.CALL_COMPLETE );
					event.result = body.result;

					dataTableEditor.serverVersion = body.serverVersion;

					dispatchEvent( event );

					break;
				}

				case Notifications.REMOTE_CALL_RESPONSE_ERROR:
				{
					dataTableEditor.currentState = "Result";
					dataTableEditor.resetQueue();

					break;
				}

				case Notifications.COMMIT_DATA_STRUCTURE:
				{
					dataTableEditor.dataGridColumns = null;
					dataTableEditor.updateTable();

					break;
				}
			}
		}

		public function remoteMethodCall( functionName : String, value : String ) : String
		{
			var objectVO : ObjectVO = dataTableEditor.objectVO as ObjectVO;

			if ( objectVO )
				sendNotification( Notifications.REMOTE_CALL_REQUEST, { objectVO: objectVO, functionName: functionName, value: value } );
			return null;
		}

		public function addEventListener( type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false ) : void
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
