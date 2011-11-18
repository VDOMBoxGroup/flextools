package net.vdombox.ide.modules.dataBase.view
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	import net.vdombox.ide.modules.dataBase.events.DataTablesEvents;
	import net.vdombox.ide.modules.dataBase.model.SessionProxy;
	import net.vdombox.ide.modules.dataBase.view.components.DataTablesTree;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class DataTablesTreeMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "DataTablesTreeMediator";
		
		private var isActive : Boolean;
		private var sessionProxy : SessionProxy;
		
		private var _dataBases : Object;
		private var requestQue : Object;
		
		public function DataTablesTreeMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		public function get dataTablesTree() : DataTablesTree
		{
			return viewComponent as DataTablesTree;
		}
		
		public function get currentTableID() : String
		{
			return sessionProxy.selectedTable ? sessionProxy.selectedTable.id : null;
		}
		
		public function get currentBaseID() : String
		{
			return sessionProxy.selectedBase ? sessionProxy.selectedBase.id : null;
		}
		
		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			isActive = false;
			addHandlers();
		}
		
		override public function onRemove() : void
		{
			sessionProxy = null;
			
			isActive = false;
		}
		
		private function addHandlers() : void
		{
			dataTablesTree.addEventListener( DataTablesEvents.CHANGE, changeHandler, false, 0, true );
			
		}
		
		private function changeHandler( event : DataTablesEvents ) : void
		{
			var newBaseID : String = dataTablesTree.selectedPageID;
			var newTableID : String = dataTablesTree.selectedObjectID;
			
			if ( !_dataBases.hasOwnProperty( newBaseID ) )
				return;
			
			if ( newTableID && newTableID != currentTableID )
			{
				if ( !requestQue )
					requestQue = {};
				
				
				if ( !requestQue.hasOwnProperty( newTableID ) )
					requestQue[ newTableID ] = { open: false, change: true };
				else
					requestQue[ newTableID ][ "change" ] = true;
				
				sendNotification( ApplicationFacade.GET_TABLE, { pageVO: _dataBases[ newBaseID ], objectID: newTableID } );
			}
			else if ( newBaseID != currentBaseID )
			{
				sendNotification( ApplicationFacade.CHANGE_SELECTED_DATA_BASE_REQUEST, _dataBases[ newBaseID ] );
				sendNotification( ApplicationFacade.GET_DATA_BASE_TABLES, _dataBases[ newBaseID ] );
			}
				
			else if ( newBaseID == currentBaseID && !newTableID )
			{
				
				//sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, _pages[ newPageID ] );
			}
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.DATA_BASES_GETTED );
			interests.push( ApplicationFacade.DATA_BASE_TABLES_GETTED );
			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			interests.push( ApplicationFacade.TABLE_GETTED);
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;
			
			var pageXML : XML;
			
			switch ( name )
			{
				case ApplicationFacade.BODY_START:
				{
					if ( sessionProxy.selectedApplication )
					{
						isActive = true;
						sendNotification( ApplicationFacade.GET_DATA_BASES, sessionProxy.selectedApplication );
						
						break;
					}
				}
					
				case ApplicationFacade.DATA_BASES_GETTED:
				{
					showPages( notification.getBody() as Array );
					
					selectCurrentPage();
					
					break;
				}
					
				case ApplicationFacade.DATA_BASE_TABLES_GETTED:
				{
					if ( !dataTablesTree.dataBases )
						return;
					
					var pageXMLTree : XML = notification.getBody() as XML;
					
					if ( !pageXMLTree )
						pageXMLTree = new XML();
					
					pageXML = dataTablesTree.dataBases.( @id == pageXMLTree.@id )[ 0 ];
					
					if (pageXML)
					{
						pageXML.setChildren( new XMLList() ); //TODO: strange construction
						pageXML.appendChild( pageXMLTree.* );
					}
					
					selectCurrentPage( false );
					break;
				}
					
				case ApplicationFacade.TABLE_GETTED:
				{
					var objectVO : ObjectVO = body as ObjectVO;
					
					sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, objectVO );
					
					break;
				}
					
				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					selectCurrentPage();
					
					break;
				}
			}
		}
		
		
		private function showPages( dataBases : Array ) : void
		{
			var pagesXMLList : XMLList = new XMLList();
			_dataBases = {};
			
			for ( var i : int = 0; i < dataBases.length; i++ )
			{
				if ( dataBases[ i ].typeVO.id == "753ea72c-475d-4a29-96be-71c522ca2097" )
				{
					_dataBases[ dataBases[ i ].id ] = dataBases[ i ];
				
					pagesXMLList += <page id={dataBases[ i ].id} name={dataBases[ i ].name} typeID={dataBases[ i ].typeVO.id}  iconID={dataBases[ i ].typeVO.structureIconID}  />;
				}
			}
			
			dataTablesTree.dataBases = pagesXMLList;
		}
		
		private function selectCurrentPage( needGetPageStructure : Boolean = true ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			if ( !sessionProxy.selectedBase )
				return;
			
			if ( sessionProxy.selectedTable )
				dataTablesTree.selectedPageID = sessionProxy.selectedTable.id;
			else
				dataTablesTree.selectedPageID = sessionProxy.selectedBase.id;
			
			if ( !needGetPageStructure )
				return;
			
			sendNotification( ApplicationFacade.GET_DATA_BASE_TABLES, sessionProxy.selectedBase );
		}
	}
}