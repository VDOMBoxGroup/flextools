package net.vdombox.ide.modules.dataBase.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.events.ResourceVOEvent;
	import net.vdombox.ide.modules.dataBase.model.StatesProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	import net.vdombox.ide.modules.dataBase.events.DataTablesEvents;
	import net.vdombox.ide.modules.dataBase.events.PopUpWindowEvent;
	import net.vdombox.ide.modules.dataBase.view.components.DataTablesTree;
	import net.vdombox.ide.modules.dataBase.view.components.windows.CreateNewObjectWindow;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class DataTablesTreeMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "DataTablesTreeMediator";
		
		private var isActive : Boolean;
		private var statesProxy : StatesProxy;
		private var typesProxy : TypesProxy;
		
		private var _dataBases : Object;
		private var requestQue : Object;
		
		private var typeVO : TypeVO;
		
		private var componentName : String;
		
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
			return statesProxy.selectedObject ? statesProxy.selectedObject.id : null;
		}
		
		public function get currentBaseID() : String
		{
			return statesProxy.selectedPage ? statesProxy.selectedPage.id : null;
		}
		
		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			typesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			isActive = false;
			addHandlers();
		}
		
		override public function onRemove() : void
		{
			dataTablesTree.removeEventListener( DataTablesEvents.CHANGE, changeHandler );
			dataTablesTree.removeEventListener( DataTablesEvents.SELECT_CONTEXT_ITEM_NEW, createNewPageOrObject );
			dataTablesTree.removeEventListener( ResourceVOEvent.GET_RESOURCE_REQUEST, getResourceRequestHandler ); 
			
			statesProxy = null;
			
			isActive = false;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );
			interests.push( ApplicationFacade.DATA_BASES_GETTED );
			interests.push( ApplicationFacade.DATA_BASE_TABLES_GETTED );
			interests.push( StatesProxy.SELECTED_PAGE_CHANGED );
			interests.push( ApplicationFacade.TABLE_GETTED );
			interests.push( StatesProxy.SELECTED_OBJECT_CHANGED );
			interests.push( TypesProxy.TOP_LEVEL_TYPES_GETTED );
			interests.push( ApplicationFacade.PAGE_CREATED );
			interests.push( ApplicationFacade.OBJECT_CREATED );
			interests.push( ApplicationFacade.OBJECT_NAME_SETTED );
			interests.push( ApplicationFacade.PAGE_NAME_SETTED );
			
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
					if ( statesProxy.selectedApplication )
					{
						isActive = true;
						sendNotification( ApplicationFacade.GET_DATA_BASES, statesProxy.selectedApplication );
						
						dataTablesTree.createContextMenu();
						dataTablesTree.setNewContextSubMenu( typesProxy.types );
						
						break;
					}
				}
					
				case ApplicationFacade.BODY_STOP:
				{
					
					isActive = false;
					dataTablesTree.dataBases = null;
						
					break;
				
				}
					
				case ApplicationFacade.DATA_BASES_GETTED:
				{
					showPages( notification.getBody() as Array );
					
					sendNotification( ApplicationFacade.GET_DATA_BASE_TABLES, statesProxy.selectedPage );
					
					if ( !statesProxy.selectedPage )
					{
						for each ( var pageVO : PageVO in _dataBases )
						{
							sendNotification( ApplicationFacade.CHANGE_SELECTED_DATA_BASE_REQUEST, pageVO );
							sendNotification( ApplicationFacade.GET_PAGE, { applicationVO : statesProxy.selectedApplication, pageID : pageVO.id } );
							sendNotification( ApplicationFacade.GET_DATA_BASE_TABLES, pageVO );
							break;
						}
					}
					else if ( statesProxy.selectedObject && _dataBases[ statesProxy.selectedPage.id ] )
					{
						sendNotification( ApplicationFacade.GET_TABLE, { pageVO: _dataBases[ statesProxy.selectedPage.id ], objectID: statesProxy.selectedObject.id } );
					}
					else
					{
						sendNotification( ApplicationFacade.GET_PAGE, { applicationVO : statesProxy.selectedApplication, pageID : statesProxy.selectedPage.id } );
						sendNotification( ApplicationFacade.GET_DATA_BASE_TABLES, statesProxy.selectedPage );
					}
					break;
				}
					
				case ApplicationFacade.DATA_BASE_TABLES_GETTED:
				{
					if ( !dataTablesTree.dataBases )
						return;
					
					var pageXMLTree : XML = notification.getBody() as XML;
					
					if ( pageXMLTree )
					{
						if ( pageXMLTree.@typeID == "753ea72c-475d-4a29-96be-71c522ca2097" )
							setVisibleForElements( pageXMLTree );
					}
					else
					{
						pageXMLTree = new XML();
					}
					
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
					
					sendNotification( StatesProxy.CHANGE_SELECTED_OBJECT_REQUEST, objectVO );
					
					break;
				}
					
				case StatesProxy.SELECTED_OBJECT_CHANGED:
				{
					if ( statesProxy.selectedObject )
						dataTablesTree.selectedObjectID = statesProxy.selectedObject.id;
					else if ( statesProxy.selectedPage )
						dataTablesTree.selectedPageID = statesProxy.selectedPage.id;
					else
						dataTablesTree.selectedPageID = "";
					
					break;
				}
					
				case StatesProxy.SELECTED_PAGE_CHANGED:
				{
					selectCurrentPage();
					
					break;
				}
					
				case TypesProxy.TOP_LEVEL_TYPES_GETTED:
				{
					var typesVO : Array = body as Array;
					var itemVO : TypeVO;
					
					for each ( itemVO in typesVO )
					{
						if ( itemVO.id == "753ea72c-475d-4a29-96be-71c522ca2097" )
						{
							typeVO = itemVO;
							break;
						}
					}
					
					if ( !typeVO )
						return;
					
					if ( statesProxy.selectedApplication )
					{
						sendNotification( ApplicationFacade.CREATE_PAGE,
							{ applicationVO: statesProxy.selectedApplication, typeVO: typeVO } );				
					}		
						
					break;
				}
					
				case ApplicationFacade.PAGE_CREATED:
				{
					if ( componentName == "" || !componentName )
					{
						sendNotification( ApplicationFacade.GET_DATA_BASES, statesProxy.selectedApplication );
					}
					else
					{
						var _pageVO : PageVO = body.pageVO;
					
						if ( !_pageVO )
							return;
					
						_pageVO.name = componentName;
						
						componentName = "";
						
						sendNotification( ApplicationFacade.SET_OBJECT_NAME, _pageVO );
					}
					
					break;
				}	
					
				case ApplicationFacade.OBJECT_CREATED:
				{
					if ( componentName == "" || !componentName )
					{
						sendNotification( ApplicationFacade.GET_DATA_BASE_TABLES, body.pageVO );
						sendNotification( ApplicationFacade.TABLE_CREATED, { pageVO : body.pageVO } );
					}
					else
					{
						body.name = componentName;
						
						componentName = "";
					
						sendNotification( ApplicationFacade.SET_OBJECT_NAME, body );
					}
					break;
				}	
					
				case ApplicationFacade.OBJECT_NAME_SETTED:
				{
					sendNotification( ApplicationFacade.GET_DATA_BASE_TABLES, body.pageVO );
					sendNotification( ApplicationFacade.TABLE_CREATED, { pageVO : body.pageVO } );
					
					break;
				}	
					
				case ApplicationFacade.PAGE_NAME_SETTED:
				{
					sendNotification( ApplicationFacade.GET_DATA_BASES, statesProxy.selectedApplication );
					
					break;
				}
			}
		}
		
		private function setVisibleForElements( pageXML : XML) : void
		{
			var xmlList : XMLList = pageXML..object;
			var objectXML : XML;
			var typeID : String;
			var typeProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy ;
			
			for each( objectXML in xmlList)
			{
				typeID = objectXML.@typeID;
				var rr : TypeVO = typeProxy.getTypeVObyID( typeID )
				objectXML.@iconID = rr.structureIconID;
			}
		}
		
		private function addHandlers() : void
		{
			dataTablesTree.addEventListener( DataTablesEvents.CHANGE, changeHandler, false, 0, true );
			dataTablesTree.addEventListener( DataTablesEvents.SELECT_CONTEXT_ITEM_NEW, createNewPageOrObject, false, 0, true );
			dataTablesTree.addEventListener( ResourceVOEvent.GET_RESOURCE_REQUEST, getResourceRequestHandler, true ); 
		}
		
		private function createNewPageOrObject( event : DataTablesEvents ) : void
		{
			createNew( event.content );
		}
		
		private function createNew( object : Object ) : void
		{
			if ( object is TypeVO )
			{
				var _typeVO : TypeVO = object as TypeVO;
				
				var createNewObjectWindow : CreateNewObjectWindow = new CreateNewObjectWindow();
				
				createNewObjectWindow.title = "New " + _typeVO.displayName;
				createNewObjectWindow.typeVO = _typeVO;
				
				createNewObjectWindow.addEventListener( PopUpWindowEvent.APPLY, applyHandler );
				createNewObjectWindow.addEventListener( PopUpWindowEvent.CANCEL, cancelHandler );
				
				if ( _typeVO.container != 3 )
				{
					for each ( var dataBase : Object in _dataBases )
					{
						createNewObjectWindow.dataBases.addItem( dataBase );
					}
				}
				
				WindowManager.getInstance().addWindow(createNewObjectWindow, dataTablesTree as UIComponent, true);
				
				function applyHandler( event : PopUpWindowEvent ) : void
				{
					componentName = event.name;
					
					if ( _typeVO.container == 3 )
					{
						if ( !typeVO )
							sendNotification( TypesProxy.GET_TOP_LEVEL_TYPES );
						else if ( statesProxy.selectedApplication )
						{
							sendNotification( ApplicationFacade.CREATE_PAGE,
								{ applicationVO: statesProxy.selectedApplication, typeVO: typeVO } );				
						}
					}
					else
					{
						var attributes : Array = [];
						
						if ( !event.base || !_typeVO )
							return;
						
						attributes.push( new AttributeVO( "left", "0" ) );
						attributes.push( new AttributeVO( "top", "0" ) );
						
						sendNotification( ApplicationFacade.CREATE_OBJECT, { pageVO: event.base, attributes: attributes, typeVO: _typeVO } );
					}
					WindowManager.getInstance().removeWindow( createNewObjectWindow );
					
				}
				
				function cancelHandler( event : PopUpWindowEvent ) : void
				{
					WindowManager.getInstance().removeWindow( createNewObjectWindow );
				}
			}
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
				
				if ( newTableID )
					sendNotification( ApplicationFacade.GET_TABLE, { pageVO: _dataBases[ newBaseID ], objectID: newTableID } );
				else
					sendNotification( ApplicationFacade.GET_PAGE, { applicationVO : statesProxy.selectedApplication, pageID : newBaseID } );
			}
			else if ( !newTableID )
			{
				sendNotification( ApplicationFacade.GET_PAGE, { applicationVO : statesProxy.selectedApplication, pageID : newBaseID } );
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
			if ( !statesProxy.selectedPage )
				return;
			
			dataTablesTree.selectedPageID = statesProxy.selectedObject ? statesProxy.selectedObject.id : statesProxy.selectedPage.id;
			
			
			if ( !needGetPageStructure )
				return;
			
			sendNotification( ApplicationFacade.GET_DATA_BASE_TABLES, statesProxy.selectedPage );
		}
		
		private function getResourceRequestHandler( event : ResourceVOEvent ) : void
		{
			sendNotification( ApplicationFacade.GET_RESOURCE_REQUEST, event.target );
		}
	}
}