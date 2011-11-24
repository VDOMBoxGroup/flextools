package net.vdombox.ide.modules.dataBase.view
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.modules.dataBase.view.components.DataTable;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class DataTableMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "DataTableEditor";
		private var notRegisterDataStructureMediator : Boolean = true;
		
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
			addHandlers();
		}
		
		override public function onRemove() : void
		{
			facade.removeMediator( DataTableEditorMediator.NAME + dataTable.editorID );
			facade.removeMediator( DataTableStructureMediator.NAME + dataTable.editorID );
			dataTable.removeEventListener( FlexEvent.CREATION_COMPLETE, registerDataTadleMediators );
		}
		
		private function addHandlers() : void
		{
			dataTable.addEventListener( FlexEvent.CREATION_COMPLETE, registerDataTadleMediators );
			dataTable.DataStructure.addEventListener( FlexEvent.SHOW,  registerDataStructureMediator );
		}
		
		private function registerDataStructureMediator( event : FlexEvent ) : void
		{
			if ( notRegisterDataStructureMediator )
			{
				notRegisterDataStructureMediator = false;
				facade.registerMediator( new DataTableStructureMediator( dataTable.DataStructure ) );
			}
			
		}
		
		private function registerDataTadleMediators( event : FlexEvent ) : void
		{
			facade.registerMediator( new DataTableEditorMediator( dataTable.dataEditor ) );
		}
	}
}