package net.vdombox.ide.modules.dataBase.view
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	import net.vdombox.ide.modules.dataBase.events.DataTablesEvents;
	import net.vdombox.ide.modules.dataBase.model.SessionProxy;
	import net.vdombox.ide.modules.dataBase.model.TypesProxy;
	import net.vdombox.ide.modules.dataBase.view.components.BaseVisualEditor;
	import net.vdombox.ide.modules.dataBase.view.components.DataTable;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class DataTableMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "DataTableEditor";
		private var notRegisterDataStructureMediator : Boolean = true;
		private var notRegisterDataEditorMediator : Boolean = true;
		private var notRegisterBaseQueryMediator : Boolean = true;
		
		private var sessionProxy : SessionProxy;
		private var typesProxy : TypesProxy;
		
		
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
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			typesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			
			if ( dataTable.objectVO is ObjectVO )
				facade.registerMediator( new DataTableEditorMediator( dataTable.dataEditor ) );
			else 
				registerBaseMediator();
			
			addHandlers();
			
		}
		
		private function sendCommitEditor( event : DataTablesEvents ) : void
		{
			sendNotification( ApplicationFacade.COMMIT_DATA_STRUCTURE, { objectVO : dataTable.objectVO, objectID: dataTable.editorID } );
		}
		
		private function sendCommitSttructure( event : DataTablesEvents ) : void
		{
			sendNotification( ApplicationFacade.COMMIT_STRUCTURE, { objectVO : dataTable.objectVO, objectID: dataTable.editorID } );
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
			sendNotification( ApplicationFacade.CREATE_PAGE,
				{ applicationVO: sessionProxy.selectedApplication, typeVO: dataTable.objectVO.typeVO } );		
		}
		
		private function newTableHandler( event : DataTablesEvents ) : void
		{
			var attributes : Array = [];
			
			attributes.push( new AttributeVO( "left", "0" ) );
			attributes.push( new AttributeVO( "top", "0" ) );
			
			
			sendNotification( ApplicationFacade.CREATE_OBJECT, { pageVO: dataTable.objectVO, attributes: attributes, typeVO: typesProxy.tableType } );		
		}
		
		private function goToBaseHandler( event : DataTablesEvents ) : void
		{		
			sendNotification( ApplicationFacade.GET_PAGE, { applicationVO : sessionProxy.selectedApplication, pageID : dataTable.objectVO.pageVO.id } );
		}
	}
}