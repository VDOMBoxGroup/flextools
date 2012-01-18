package net.vdombox.ide.modules.dataBase.view
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	import net.vdombox.ide.modules.dataBase.events.TableElementEvent;
	import net.vdombox.ide.modules.dataBase.view.components.TableElement;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class TableElementMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "TableElementMediator";
		
		public function TableElementMediator(viewComponent : Object = null )
		{
			var instanceName : String = NAME + viewComponent.objectID;
			
			super( instanceName, viewComponent );
		}
		
		public function get tableElement() : TableElement
		{
			return viewComponent as TableElement;
		}
		
		override public function onRegister() : void
		{
			addHandlers();
			
			sendNotification( ApplicationFacade.GET_OBJECT_ATTRIBUTES, tableElement.objectVO);
			sendNotification( ApplicationFacade.REMOTE_CALL_REQUEST, { objectVO: tableElement.objectVO, functionName: "get_structure", value: "" } );
		}
		
		override public function onRemove() : void
		{
			removeHandlers();
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.OBJECT_ATTRIBUTES_GETTED );
			interests.push( ApplicationFacade.OBJECT_NAME_SETTED );
			interests.push( ApplicationFacade.REMOTE_CALL_RESPONSE );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			var objectVO : ObjectVO;
			
			if ( body is ObjectVO )
				objectVO = body as ObjectVO;
			else if ( body.hasOwnProperty("objectVO") )
				objectVO = body.objectVO as ObjectVO;
			
			if ( !objectVO || objectVO.id != tableElement.objectID )
				return;
			
			switch ( name )
			{
				case ApplicationFacade.OBJECT_ATTRIBUTES_GETTED:
				{
					tableElement.attributesVO = body.vdomObjectAttributesVO as VdomObjectAttributesVO;
					break;
				}
					
				case ApplicationFacade.REMOTE_CALL_RESPONSE:
				{
					try 
					{
						var queryResult : XML = new XML( body.result );
						var tableStructureXML : XML = new XML( queryResult.Result.tablestructure.table.header );
						
						tableElement.setTableHeaders( tableStructureXML );
					}
					catch (err:Error) 
					{
						
					}
					
					break;
				}
					
				case ApplicationFacade.OBJECT_NAME_SETTED:
				{
					tableElement.objectVO = objectVO;
					
					break;
				}	
			}
		}
		
		private function addHandlers() : void
		{
			tableElement.addEventListener( TableElementEvent.CHANGE, updateTableInfo );
			tableElement.addEventListener( TableElementEvent.NAME_CHANGE, updateTableName );
			tableElement.addEventListener( TableElementEvent.GO_TO_TABLE, sendGetTable );
			tableElement.addEventListener( TableElementEvent.DELETE, deleteTable );
		}
		
		private function removeHandlers() : void
		{
			tableElement.removeEventListener( TableElementEvent.CHANGE, updateTableInfo );
			tableElement.removeEventListener( TableElementEvent.NAME_CHANGE, updateTableName );
			tableElement.removeEventListener( TableElementEvent.GO_TO_TABLE, sendGetTable );
			tableElement.removeEventListener( TableElementEvent.DELETE, deleteTable );
		}
		
		private function updateTableInfo( event : TableElementEvent ) : void
		{
			
		}
		
		private function updateTableName( event : TableElementEvent ) : void
		{
			sendNotification( ApplicationFacade.SET_OBJECT_NAME, tableElement.objectVO );
		}
		
		private function sendGetTable( event : TableElementEvent ) : void
		{
			sendNotification( ApplicationFacade.GET_TABLE, { pageVO: tableElement.objectVO.pageVO, objectID: tableElement.objectID } );
		}
		
		private function deleteTable( event : TableElementEvent ) : void
		{
			sendNotification( ApplicationFacade.DELETE_OBJECT, { pageVO: tableElement.objectVO.pageVO, objectVO: tableElement.objectVO } );
		}
	}
}