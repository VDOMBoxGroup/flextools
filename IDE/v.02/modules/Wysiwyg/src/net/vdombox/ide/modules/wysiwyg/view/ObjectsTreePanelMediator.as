package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.controls.Tree;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.ObjectsTreePanelEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.panels.ObjectsTreePanel;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ObjectsTreePanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ObjectsTreePanelMediator";

		public function ObjectsTreePanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var _pages : Object;

		private var tempFlag : Boolean = true;
		
		private var sessionProxy : SessionProxy;

		private var isActive : Boolean;

		private var requestQue : Object;

		public function get objectsTreePanel() : ObjectsTreePanel
		{
			return viewComponent as ObjectsTreePanel;
		}

		public function get currentPageID() : String
		{
			return sessionProxy.selectedPage ? sessionProxy.selectedPage.id : null;
		}

		public function get currentObjectID() : String
		{
			return sessionProxy.selectedObject ? sessionProxy.selectedObject.id : null;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			isActive = false;

			requestQue = {};

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			sessionProxy = null;
			
			isActive = false;
			
			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.PAGES_GETTED );
			interests.push( ApplicationFacade.PAGE_STRUCTURE_GETTED );

			interests.push( ApplicationFacade.MODULE_DESELECTED );

			interests.push( ApplicationFacade.OBJECT_GETTED );
			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );
			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );

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

						sendNotification( ApplicationFacade.GET_PAGES, sessionProxy.selectedApplication );

						break;
					}
				}

				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case ApplicationFacade.PAGES_GETTED:
				{
					showPages( notification.getBody() as Array );

					break;
				}

				case ApplicationFacade.PAGE_STRUCTURE_GETTED:
				{
					if ( !objectsTreePanel.pages )
						return;

					var pageXMLTree : XML = notification.getBody() as XML;

					if ( !pageXMLTree )
						pageXMLTree = new XML();

					pageXML = objectsTreePanel.pages.( @id == pageXMLTree.@id )[ 0 ];
					pageXML.setChildren( new XMLList() ); //TODO: strange construction
					pageXML.appendChild( pageXMLTree.* );

					break;
				}

				case ApplicationFacade.OBJECT_GETTED:
				{
					var objectVO : ObjectVO = body as ObjectVO;

					var requestElement : Object = requestQue[ objectVO.id ];

					if ( requestElement && requestElement[ "open" ] )
						sendNotification( ApplicationFacade.OPEN_OBJECT_REQUEST, objectVO );
					else
						sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, objectVO );

					delete requestQue[ objectVO.id ];

					break;
				}

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					if ( sessionProxy.selectedPage )
						objectsTreePanel.selectedPageID = sessionProxy.selectedPage.id;
					else
						objectsTreePanel.selectedPageID = "";

					break;
				}

				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{
					if ( sessionProxy.selectedObject )
						objectsTreePanel.selectedObjectID = sessionProxy.selectedObject.id;
					else if ( sessionProxy.selectedPage )
						objectsTreePanel.selectedPageID = sessionProxy.selectedPage.id;
					else
						objectsTreePanel.selectedPageID = "";

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			objectsTreePanel.addEventListener( ObjectsTreePanelEvent.CHANGE, changeHandler, false, 0, true );
			objectsTreePanel.addEventListener( ObjectsTreePanelEvent.OPEN, openHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			objectsTreePanel.removeEventListener( ObjectsTreePanelEvent.CHANGE, changeHandler );
			objectsTreePanel.removeEventListener( ObjectsTreePanelEvent.OPEN, openHandler );
		}

		private function showPages( pages : Array ) : void
		{
			var pagesXMLList : XMLList = new XMLList();
			_pages = {};

			for ( var i : int = 0; i < pages.length; i++ )
			{
				_pages[ pages[ i ].id ] = pages[ i ];

				pagesXMLList +=
					<page id={pages[ i ].id} name={pages[ i ].name} typeID={pages[ i ].typeVO.id}/>;
			}

			objectsTreePanel.pages = pagesXMLList;
			
			//selectCurrentPage();		
		}
	
		private function selectCurrentPage( ) : void
		{
			var sessionProxy   : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			if( sessionProxy.selectedPage )
			{
				sendNotification( ApplicationFacade.GET_PAGE_SRUCTURE, sessionProxy.selectedPage );
				objectsTreePanel.selectedPageID = sessionProxy.selectedPage.id
				//ApplicationFacade.PAGE_STRUCTURE_GETTED, objectsTreePanel.pages
				
					//objectsTreePanel.selectedItem = getPageXML(objectsTreePanel.selectedPageID);
				//objectsTreePanel.selectedObjectID
				//if( int(objectsTreePanel.selectedObjectID) >= 0 && objectsTreePanel.selectedObjectID )
					//objectsTreePanel.objectsTree.scrollToIndex(objectsTreePanel.selectedObjectID);// objectsTree.selectedIndex);
//				objectsTreePanel.selectedItem = getPageXML(sessionProxy.selectedPage.id);
//				objectsTreePanel.validateNow();
//				objectsTreePanel.scrollToIndex(objectsTree.selectedIndex);
			}
			else
			{
				trace("Error: not selected Page in Event Modul");
			}
		}
		
		private function getPageXML( id : String ) : XML
		{			
			for each ( var page:XML in objectsTreePanel.pages)
			{
				if (page.@id == id)
					return page;
			}
			
			trace("Error: not exist page in objectsTree");
			return null;
		}

//		
		private function clearData() : void
		{
			objectsTreePanel.pages = null;
			requestQue = null;
		}

		private function changeHandler( event : ObjectsTreePanelEvent ) : void
		{
			var newPageID : String = objectsTreePanel.selectedPageID;
			var newObjectID : String = objectsTreePanel.selectedObjectID;

			if ( !_pages.hasOwnProperty( newPageID ) )
				return;
			
			if ( newObjectID && newObjectID != currentObjectID )
			{
				if ( !requestQue.hasOwnProperty( newObjectID ) )
					requestQue[ newObjectID ] = { open: false, change: true };
				else
					requestQue[ newObjectID ][ "change" ] = true;

				sendNotification( ApplicationFacade.GET_OBJECT, { pageVO: _pages[ newPageID ], objectID: newObjectID } );
			}
			else if ( newPageID != currentPageID )
			{
				sendNotification( ApplicationFacade.GET_PAGE_SRUCTURE, _pages[ newPageID ] );
				sendNotification( ApplicationFacade.CHANGE_SELECTED_PAGE_REQUEST, _pages[ newPageID ] );
			}

			else if ( newPageID == currentPageID && !newObjectID )
			{
				sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, null );
			}
		}

		private function openHandler( event : ObjectsTreePanelEvent ) : void
		{
			if ( !event.pageID || !_pages.hasOwnProperty( event.pageID ) )
				return;

			if ( !event.objectID )
			{
				sendNotification( ApplicationFacade.OPEN_PAGE_REQUEST, _pages[ event.pageID ] );
			}
			else
			{
				if ( !requestQue.hasOwnProperty( event.objectID ) )
					requestQue[ event.objectID ] = { open: true, change: false };
				else
					requestQue[ event.objectID ][ "open" ] = true;

				sendNotification( ApplicationFacade.GET_OBJECT, { pageVO: _pages[ event.pageID ], objectID: event.objectID } );
			}
		}
	}
}