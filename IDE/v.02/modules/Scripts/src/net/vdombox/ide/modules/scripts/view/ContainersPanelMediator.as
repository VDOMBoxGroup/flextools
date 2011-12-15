package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.TypeVO;
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
			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );
			
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

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					selectCurrentPage();
					
					break;
				}

				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{
					if ( sessionProxy.selectedObject )
						containersPanel.selectedObjectID = sessionProxy.selectedObject.id;
					else if ( sessionProxy.selectedPage )
						containersPanel.selectedPageID = sessionProxy.selectedPage.id;
					else
						containersPanel.selectedPageID = "";
					
					break;

					break;
				}
					
				case ApplicationFacade.PAGES_GETTED:
				{
					var pages : Array = body as Array;

					showPages( pages );
					
					selectCurrentPage();
					
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
						
						
						var pageXML : XML = containersPanel.structure.( @id == structure.@id )[ 0 ];
						pageXML.setChildren( new XMLList() ); //TODO: strange construction
						pageXML.appendChild( structure.* );
						//containersPanel.validateNow();
					}
					break;
				}
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
			//sendNotification( ApplicationFacade.GET_DATA_BASE_TABLES, sessionProxy.selectedPage );
		}
		
		private function showPages( pages : Array ) : void
		{
			var pagesXMLList : XMLList = new XMLList();
			_pages = {};
			
			for ( var i : int = 0; i < pages.length; i++ )
			{
				_pages[ pages[ i ].id ] = pages[ i ];
				
				pagesXMLList += <page id={pages[ i ].id} name={pages[ i ].name} />;
				
			}
			
			containersPanel.structure = pagesXMLList;
			
		}

		private function addHandlers() : void
		{
			containersPanel.addEventListener( ContainersPanelEvent.CONTAINER_CHANGED, containerChangedHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			containersPanel.removeEventListener( ContainersPanelEvent.CONTAINER_CHANGED, containerChangedHandler );
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
			 
			 /*if( pageVO )
				 sendNotification( ApplicationFacade.CHANGE_SELECTED_PAGE_REQUEST, pageVO );
			 else
			 {
				if ( selectedItem.name() == "object" )
				{
					selectedObject = new ObjectVO( sessionProxy.selectedPage, typeVO );
					selectedObject.setID( selectedItem.@id );
				}

				sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, selectedObject );
			 }*/
			 
			 
			 if ( newObject && newObject.@id != currentObjectID )
			 {
				 /*if ( !requestQue )
					 requestQue = {};
				 
				 if ( !requestQue.hasOwnProperty( newTableID ) )
					 requestQue[ newTableID ] = { open: false, change: true };
				 else
					 requestQue[ newTableID ][ "change" ] = true;*/
				 
				 if ( newObject.name() == "object" )
				 {
					 selectedObject = new ObjectVO( sessionProxy.selectedPage, typeVO );
					 selectedObject.setID( newObject.@id );
					 sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, selectedObject );
				 }
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
	}
}