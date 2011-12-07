package net.vdombox.ide.modules.dataBase.view
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import net.vdombox.ide.common.events.ExternalManagerEvent;
	import net.vdombox.ide.common.interfaces.IExternalManager;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	import net.vdombox.ide.modules.dataBase.events.DataTablesEvents;
	import net.vdombox.ide.modules.dataBase.model.SessionProxy;
	import net.vdombox.ide.modules.dataBase.view.components.DataTableStructure;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class DataTableStructureMediator extends Mediator implements IMediator, IExternalManager
	{
		public static const NAME : String = "DataTableStructureMediator";
		
		private var dispatcher : EventDispatcher;
		private var sessionProxy : SessionProxy;
		
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
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			dataTableStructure.externalManager = this as IExternalManager;
			dataTableStructure.addEventListener( DataTablesEvents.UPDATE_STRUCTURE,  sendCommit );
		}
		
		private function sendCommit( event : DataTablesEvents ) : void
		{
			sendNotification( ApplicationFacade.COMMIT_DATA_STRUCTURE, dataTableStructure.editorID );
		}
		
		override public function onRemove() : void
		{
			sessionProxy = null;
			dispatcher = null;
			dataTableStructure.removeEventListener( DataTablesEvents.UPDATE_STRUCTURE,  sendCommit );
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
					dispatchEvent( event );
					
					break;
				}
			}
		}
		
		public function remoteMethodCall( functionName : String, value : String ) : String
		{
			var objectID : String = sessionProxy.selectedTable ? sessionProxy.selectedTable.id : sessionProxy.selectedBase.id;
			
			
			sendNotification( ApplicationFacade.REMOTE_CALL_REQUEST,
				{ applicationVO: sessionProxy.selectedApplication, objectID: objectID, functionName: functionName, value: value } );
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