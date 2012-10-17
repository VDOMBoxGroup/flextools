package net.vdombox.ide.modules.dataBase.view
{
	import mx.events.FlexEvent;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.view.components.windows.NameObjectWindow;
	import net.vdombox.ide.modules.dataBase.events.DataTablesEvents;
	import net.vdombox.ide.modules.dataBase.view.components.DataTable;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class DataTableMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "DataTableEditor";
		private var notRegisterDataStructureMediator : Boolean = true;
		private var notRegisterDataEditorMediator : Boolean = true;
		private var notRegisterBaseQueryMediator : Boolean = true;
		
		private var typesProxy : TypesProxy;
		
		private var componentName : String;
		
		
		public function DataTableMediator( viewComponent : Object = null )
		{
			var instanceName : String = NAME + viewComponent.editorID;
			super( instanceName, viewComponent );
		}
		
		private function get dataTable () : DataTable
		{
			return viewComponent as DataTable;
		}
		
		override public function onRegister() : void
		{
			typesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			
			if ( dataTable.objectVO is ObjectVO )
				facade.registerMediator( new DataTableEditorMediator( dataTable.dataEditor ) );
			else 
				registerBaseMediator();
			
			addHandlers();
			
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( Notifications.OBJECT_CREATED );
			interests.push( Notifications.OBJECT_NAME_SETTED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			
			switch ( name )
			{					
				case Notifications.OBJECT_CREATED:
				{
					if ( componentName == "" || !componentName )
					{
						sendNotification( Notifications.GET_DATA_BASE_TABLES, body.pageVO );
					}
					else
					{
						body.name = componentName;
						
						componentName = "";
						
						sendNotification( Notifications.SET_OBJECT_NAME, body );
					}
					break;
				}	
					
				case Notifications.OBJECT_NAME_SETTED:
				{
					sendNotification( Notifications.GET_DATA_BASE_TABLES, body.pageVO );
					
					break;
				}	
			}
		}
		
		private function sendCommitEditor( event : DataTablesEvents ) : void
		{
			sendNotification( Notifications.COMMIT_DATA_STRUCTURE, { objectVO : dataTable.objectVO, objectID: dataTable.editorID } );
		}
		
		private function sendCommitSttructure( event : DataTablesEvents ) : void
		{
			sendNotification( Notifications.COMMIT_STRUCTURE, { objectVO : dataTable.objectVO, objectID: dataTable.editorID } );
		}

		private function addHandlers() : void
		{
			dataTable.DataStructure.addEventListener( FlexEvent.SHOW,  registerDataStructureMediator );
			dataTable.addEventListener( DataTablesEvents.UPDATE_DATA,  sendCommitEditor );
			dataTable.addEventListener( DataTablesEvents.UPDATE_STRUCTURE,  sendCommitSttructure );
			dataTable.addEventListener( DataTablesEvents.NEW_BASE,  newBaseHandler );
			dataTable.addEventListener( DataTablesEvents.NEW_TABLE,  newTableHandler );
			dataTable.addEventListener( DataTablesEvents.GO_TO_BASE,  goToBaseHandler );
		}
		
		override public function onRemove() : void
		{
			facade.removeMediator( DataTableEditorMediator.NAME + dataTable.editorID );
			facade.removeMediator( DataTableStructureMediator.NAME + dataTable.editorID );
			facade.removeMediator( DataTableQueryMediator.NAME + dataTable.editorID );
			facade.removeMediator( BaseVisualEditorMediator.NAME + dataTable.editorID );
			
			dataTable.removeEventListener( DataTablesEvents.UPDATE_DATA,  sendCommitEditor );
			dataTable.removeEventListener( DataTablesEvents.UPDATE_STRUCTURE,  sendCommitEditor );
			dataTable.removeEventListener( DataTablesEvents.NEW_BASE,  newBaseHandler );
			dataTable.removeEventListener( DataTablesEvents.NEW_TABLE,  newTableHandler );
			dataTable.removeEventListener( DataTablesEvents.GO_TO_BASE,  goToBaseHandler );
		}
		
		private function registerDataStructureMediator( event : FlexEvent ) : void
		{
			dataTable.DataStructure.removeEventListener( FlexEvent.SHOW,  registerDataStructureMediator );
			if ( notRegisterDataStructureMediator )
			{
				notRegisterDataStructureMediator = false;
				facade.registerMediator( new DataTableStructureMediator( dataTable.DataStructure ) );
			}
			
		}
		
		private function registerBaseMediator() : void
		{
			facade.registerMediator( new BaseVisualEditorMediator( dataTable.baseVisual ) );
			facade.registerMediator( new DataTableQueryMediator( dataTable.baseQuery ) );
		}
		
		private function newBaseHandler( event : DataTablesEvents ) : void
		{
			/*sendNotification( Notifications.CREATE_PAGE,
				{ applicationVO: sessionProxy.selectedApplication, typeVO: dataTable.objectVO.typeVO } );		*/
		}
		
		private function newTableHandler( event : DataTablesEvents ) : void
		{
			
			var createNewObjectWindow : NameObjectWindow = new NameObjectWindow( "", ResourceManager.getInstance().getString( "DataBase_General", "renaem_table_window_title" ) );	
			createNewObjectWindow.title = ResourceManager.getInstance().getString( 'DataBase_General', 'data_table_new_table' );
			createNewObjectWindow.addEventListener( PopUpWindowEvent.APPLY, applyHandler );
			createNewObjectWindow.addEventListener( PopUpWindowEvent.CANCEL, cancelHandler );
			
			WindowManager.getInstance().addWindow(createNewObjectWindow, dataTable, true);
			
			function applyHandler( event : PopUpWindowEvent ) : void
			{
				componentName = event.name;
				
				var attributes : Array = [];
				
				attributes.push( new AttributeVO( "left", "0" ) );
				attributes.push( new AttributeVO( "top", "0" ) );
				
				
				sendNotification( Notifications.CREATE_OBJECT, { pageVO: dataTable.objectVO, attributes: attributes, typeVO: typesProxy.tableType } );		
				WindowManager.getInstance().removeWindow( createNewObjectWindow );
			}
			
			function cancelHandler( event : PopUpWindowEvent ) : void
			{
				WindowManager.getInstance().removeWindow( createNewObjectWindow );
			}
		}
		
		private function goToBaseHandler( event : DataTablesEvents ) : void
		{		
			sendNotification( Notifications.GET_PAGE, { applicationVO : dataTable.objectVO.pageVO.applicationVO, pageID : dataTable.objectVO.pageVO.id } );
		}
	}
}