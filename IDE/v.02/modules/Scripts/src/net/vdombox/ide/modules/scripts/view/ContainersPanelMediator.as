package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.common.view.components.itemrenderers.ObjectsTreePanelItemRenderer;
	import net.vdombox.ide.common.events.ObjectsTreePanelEvent;
	import net.vdombox.ide.common.events.ResourceVOEvent;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.events.ContainersPanelEvent;
	import net.vdombox.ide.modules.scripts.model.SessionProxy;
	import net.vdombox.ide.modules.scripts.view.components.ContainersPanel;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ContainersPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ContainersPanelMediator";

		public function ContainersPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var types : Array;
		private var _pages : Object;

		private var currentPageVO : PageVO;
		private var currentObjectVO : ObjectVO;

		private var sessionProxy : SessionProxy;

		private var isActive : Boolean;

		private var isPageChanged : Boolean;
		private var isObjectChanged : Boolean;

		public function get containersPanel() : ContainersPanel
		{
			return viewComponent as ContainersPanel;
		}

		override public function onRegister() : void
		{
			isActive = false;

			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.TYPES_GETTED );
			interests.push( ApplicationFacade.STRUCTURE_GETTED );
			
			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			
			interests.push( ApplicationFacade.PAGES_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;

			switch ( name )
			{
				case ApplicationFacade.BODY_START:
				{
					if ( sessionProxy.selectedApplication )
					{
						isActive = true;
						sendNotification( ApplicationFacade.GET_TYPES );
					}

					break;
				}

				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case ApplicationFacade.TYPES_GETTED:
				{
					types = body as Array;
					break;
				}
					
				case ApplicationFacade.PAGES_GETTED:
				{
					var pages : Array = body as Array;

					showPages( pages );
					
					selectCurrentPage();
					
					/*if ( containersPanel.selectedObjectID )
						sendNotification( ApplicationFacade.GET_STRUCTURE, { pageVO: sessionProxy.selectedPage } );
					else if ( containersPanel.selectedPageID )
						sendNotification( ApplicationFacade.GET_PAGE, { applicationVO : sessionProxy.selectedApplication, pageID : dataTablesTree.selectedPageID } );
					*/
					break;
				}

				case ApplicationFacade.STRUCTURE_GETTED:
				{
					if ( !containersPanel.structure )
						return;
					
					var structure : XML = body as XML;
					if ( !structure )
						structure = new XML();
					else
					{
						var typeVO : TypeVO;
						
						var objects : XMLList = structure..object;
						
						var i : uint;
						
						for ( i = 0; i < objects.length(); i++ )
						{
							typeVO = getTypeByID( objects[ i ].@typeID );
							if ( typeVO.container == 1 )
							{
								delete objects[ i ];
								i--;
							}
						}
						
						//containersPanel.structure = structure;
						setVisibleForElements( structure );
						
						var pageXML : XML = containersPanel.structure.( @id == structure.@id )[ 0 ];
						pageXML.setChildren( new XMLList() ); //TODO: strange construction
						pageXML.appendChild( structure.* );
						selectCurrentPage( false );
					}
					break;
				}
					
				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					sendNotification( ApplicationFacade.GET_STRUCTURE, { pageVO: sessionProxy.selectedPage } );
					
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
				//				trace("typeID: " + typeID+ " visible: " + objectXML.@visible)
			}
		}
		
		private function selectCurrentPage( needGetPageStructure : Boolean = true ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			if ( !sessionProxy.selectedPage )
				return;
			
			if ( sessionProxy.selectedObject )
				containersPanel.selectedPageID = sessionProxy.selectedObject.id;
			else
				containersPanel.selectedPageID = sessionProxy.selectedPage.id;
			
			if ( !needGetPageStructure )
				return;
			
			sendNotification( ApplicationFacade.GET_STRUCTURE, { pageVO: sessionProxy.selectedPage } );
		}
		
		private function showPages( pages : Array ) : void
		{
			var pagesXMLList : XMLList = new XMLList();
			_pages = {};
			
			for ( var i : int = 0; i < pages.length; i++ )
			{
				_pages[ pages[ i ].id ] = pages[ i ];
				
				pagesXMLList += <page id={pages[ i ].id} name={pages[ i ].name} iconID={pages[ i ].typeVO.structureIconID} />;
				
			}
			
			containersPanel.structure = pagesXMLList;
			
		}

		private function addHandlers() : void
		{
			containersPanel.addEventListener( ContainersPanelEvent.CONTAINER_CHANGED, containerChangedHandler, false, 0, true );
			containersPanel.addEventListener( ObjectsTreePanelEvent.DOUBLE_CLICK, openOnloadScript, true, 0, true );
			containersPanel.addEventListener(ResourceVOEvent.GET_RESOURCE_REQUEST, getResourceRequestHandler, true); 
		}

		private function removeHandlers() : void
		{
			containersPanel.removeEventListener( ContainersPanelEvent.CONTAINER_CHANGED, containerChangedHandler );
			containersPanel.removeEventListener( ObjectsTreePanelEvent.DOUBLE_CLICK, openOnloadScript, true );
			containersPanel.removeEventListener(ResourceVOEvent.GET_RESOURCE_REQUEST, getResourceRequestHandler, true); 
		}

		private function clearData() : void
		{
			currentPageVO = null;
			currentObjectVO = null;
			
			containersPanel.structure = null;
		}

		private function getTypeByID( typeID : String ) : TypeVO
		{
			var result : TypeVO;
			var typeVO : TypeVO;

			for each ( typeVO in types )
			{
				if ( typeVO.id == typeID )
				{
					result = typeVO;
					break;
				}
			}

			return result;
		}
		
		public function get currentObjectID() : String
		{
			return sessionProxy.selectedObject ? sessionProxy.selectedObject.id : null;
		}
		
		public function get currentPageID() : String
		{
			return sessionProxy.selectedPage ? sessionProxy.selectedPage.id : null;
		}

		private function containerChangedHandler( event : ContainersPanelEvent ) : void
		{
			var newPage : XML = containersPanel.selectedPage;
			var newObject : XML = containersPanel.selectedObject;
			
			trace("Page : " + newPage.@name);
			if ( newObject )
				trace("Object : " + newObject.@name);
			
			var selectedObject : ObjectVO;
			
			var typeVO : TypeVO;

			if( !newPage )
				return;
			
			if ( newObject )
				typeVO = getTypeByID( newObject.@typeID )
			else
				typeVO = getTypeByID( newPage.@typeID )
				 
			 var pageVO : PageVO = null;
			 if ( _pages.hasOwnProperty( newPage.@id ) )
				 pageVO = _pages[newPage.@id];;
			 
			 
			 
			 if ( newObject && newObject.@id != currentObjectID &&  newObject.name() == "object" )
			 {
				selectedObject = new ObjectVO( sessionProxy.selectedPage, typeVO );
				selectedObject.setID( newObject.@id );
				sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, selectedObject );
			 }
			 else if ( newPage.@id != currentPageID )
			 {
				 sendNotification( ApplicationFacade.CHANGE_SELECTED_PAGE_REQUEST, pageVO );
				 if ( newObject && newObject.name() == "object" )
				 {
					 selectedObject = new ObjectVO( sessionProxy.selectedPage, typeVO );
					 selectedObject.setID( newObject.@id );
					 sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, selectedObject );
				 }
				
			 }
			 else if ( !newObject )
			 {
				 sendNotification( ApplicationFacade.CHANGE_SELECTED_PAGE_REQUEST, pageVO );
			 }
			
		}
		
		private function openOnloadScript( event : ObjectsTreePanelEvent ) : void
		{
			var treeItemRenderer : ObjectsTreePanelItemRenderer = event.target as ObjectsTreePanelItemRenderer;
			if ( treeItemRenderer )
			{
				sendNotification( ApplicationFacade.OPEN_ONLOAD_SCRIPT, treeItemRenderer.objectID );
			}
		}
		
		private function getResourceRequestHandler( event : ResourceVOEvent ) : void
		{
			sendNotification( ApplicationFacade.GET_RESOURCE_REQUEST, event.target );
		}
	}
}