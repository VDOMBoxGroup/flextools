package net.vdombox.ide.modules.dataBase.view
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	import net.vdombox.ide.modules.dataBase.events.DataTablesEvents;
	import net.vdombox.ide.modules.dataBase.view.components.DataTable;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class DataTableMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "DataTableEditor";
		private var notRegisterDataStructureMediator : Boolean = true;
		private var notRegisterDataEditorMediator : Boolean = true;
		private var notRegisterBaseQueryMediator : Boolean = true;
		
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
			if ( dataTable.objectVO is ObjectVO )
				facade.registerMediator( new DataTableEditorMediator( dataTable.dataEditor ) );
			else 
				registerBaseQueryMediator();
			addHandlers();
			
		}
		
		private function sendCommit( event : DataTablesEvents ) : void
		{
			sendNotification( ApplicationFacade.COMMIT_DATA_STRUCTURE, dataTable.editorID );
		}

		private function addHandlers() : void
		{
			dataTable.DataStructure.addEventListener( FlexEvent.SHOW,  registerDataStructureMediator );
			dataTable.addEventListener( DataTablesEvents.UPDATE_STRUCTURE,  sendCommit );
		}
		
		override public function onRemove() : void
		{
			facade.removeMediator( DataTableEditorMediator.NAME + dataTable.editorID );
			facade.removeMediator( DataTableStructureMediator.NAME + dataTable.editorID );
			facade.removeMediator( DataTableQueryMediator.NAME + dataTable.editorID );
			
			dataTable.removeEventListener( DataTablesEvents.UPDATE_STRUCTURE,  sendCommit );
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
		
		private function registerBaseQueryMediator() : void
		{
			facade.registerMediator( new DataTableQueryMediator( dataTable.baseQuery ) );
		}
	}
}