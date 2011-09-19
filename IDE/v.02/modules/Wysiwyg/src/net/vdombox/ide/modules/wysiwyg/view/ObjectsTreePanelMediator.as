//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.Event;
	
	import mx.controls.Tree;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.ObjectsTreePanelEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.model.TypesProxy;
	import net.vdombox.ide.modules.wysiwyg.model.VisibleRendererProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectTreePanelItemRenderer;
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

		private var isActive : Boolean;

		private var requestQue : Object;

		private var sessionProxy : SessionProxy;
		
		private var visibleRendererProxy : VisibleRendererProxy;

		private var tempFlag : Boolean = true;

		public function get currentObjectID() : String
		{
			return sessionProxy.selectedObject ? sessionProxy.selectedObject.id : null;
		}

		public function get currentPageID() : String
		{
			return sessionProxy.selectedPage ? sessionProxy.selectedPage.id : null;
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
					
					selectCurrentPage();

					break;
				}

				case ApplicationFacade.PAGE_STRUCTURE_GETTED:
				{

					if ( !objectsTreePanel.pages )
						return;

					var pageXMLTree : XML = notification.getBody() as XML;

					if ( !pageXMLTree )
						pageXMLTree = new XML();
					else
					{
						var xmlList : XMLList = pageXMLTree..object;;
						var objectXML : XML;
						var typeID : String;
						var typeProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy ;
						
						for each( objectXML in xmlList)
						{
							typeID = objectXML.@typeID;
							objectXML.@iconID = typeProxy.getTypeVObyID( typeID ).structureIconID;
							objectXML.@visible = visibleRendererProxy.getVisible(  String(objectXML.@id) );
						}
					}

					pageXML = objectsTreePanel.pages.( @id == pageXMLTree.@id )[ 0 ];
					if (pageXML)
					{
						pageXML.setChildren( new XMLList() ); //TODO: strange construction
						pageXML.appendChild( pageXMLTree.* );
					}

					selectCurrentPage( false );
					break;
				}

				case ApplicationFacade.OBJECT_GETTED:
				{
					trace ("[ObjTreePanelMediator] OBJECT_GETTED");
					var objectVO : ObjectVO = body as ObjectVO;

					var requestElement : Object = requestQue ? requestQue[ objectVO.id ] : null;

					if ( requestElement && requestElement[ "open" ] )
						sendNotification( ApplicationFacade.OPEN_OBJECT_REQUEST, objectVO );
					else
						sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, objectVO );

					if (requestQue)
						delete requestQue[ objectVO.id ];

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
						objectsTreePanel.selectedObjectID = sessionProxy.selectedObject.id;
					else if ( sessionProxy.selectedPage )
						objectsTreePanel.selectedPageID = sessionProxy.selectedPage.id;
					else
						objectsTreePanel.selectedPageID = "";

					break;
				}
					
				case ApplicationFacade.PAGE_NAME_SETTED:
				{
					var pageVO : PageVO = body as PageVO;
					
					if ( sessionProxy.selectedPage )
					{
						objectsTreePanel.selectedItem.@name = pageVO.name;
					}
					
					break;
				}
					
				case ApplicationFacade.OBJECT_NAME_SETTED:
				{
					var _objectVO : ObjectVO = body as ObjectVO;
					
					if ( sessionProxy.selectedObject && objectsTreePanel.selectedItem )
					{
						objectsTreePanel.selectedItem.@name = _objectVO.name;
					}
					
					break;
				}
			}
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
			
			interests.push( ApplicationFacade.PAGE_NAME_SETTED );
			interests.push( ApplicationFacade.OBJECT_NAME_SETTED );
			
//			interests.push( ApplicationFacade.OBJECT_DELETED );
//			interests.push( ApplicationFacade.OBJECT_CREATED );

			return interests;
		}

		public function get objectsTreePanel() : ObjectsTreePanel
		{
			return viewComponent as ObjectsTreePanel;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			visibleRendererProxy = facade.retrieveProxy( VisibleRendererProxy.NAME ) as VisibleRendererProxy;

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

		private function addHandlers() : void
		{
			objectsTreePanel.addEventListener( ObjectsTreePanelEvent.CHANGE, changeHandler, false, 0, true );
			objectsTreePanel.addEventListener( ObjectsTreePanelEvent.OPEN, openHandler, false, 0, true );
			objectsTreePanel.addEventListener( "TreeItemRendererComplete", loadResourceRequestHandler, true, 0, false );
			objectsTreePanel.addEventListener( ObjectsTreePanelEvent.EYE_CHANGED, eyeChangeHandler, true, 0, true );
			
		}
		
		private function eyeChangeHandler( event : ObjectsTreePanelEvent ) : void
		{
			var itemRenderer : ObjectTreePanelItemRenderer = event.target as ObjectTreePanelItemRenderer;
			
			sendNotification( ApplicationFacade.OBJECT_VISIBLE, {rendererID : itemRenderer.rendererID, visible : event.visible });
		}
		
		private function loadResourceRequestHandler( event : Event ) : void
		{
			var itemRenderer : ObjectTreePanelItemRenderer = event.target as ObjectTreePanelItemRenderer;
			sessionProxy  = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var resourceVO : ResourceVO;
			resourceVO = new ResourceVO( sessionProxy.selectedApplication.id );
			resourceVO.setID( itemRenderer.resourceID );
			itemRenderer.resourceVO = resourceVO;
			
			sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO );
		}

		private function changeHandler( event : ObjectsTreePanelEvent ) : void
		{
			var newPageID : String = objectsTreePanel.selectedPageID;
			var newObjectID : String = objectsTreePanel.selectedObjectID;

			if ( !_pages.hasOwnProperty( newPageID ) )
				return;

			if ( newObjectID && newObjectID != currentObjectID )
			{
				if ( !requestQue )
					requestQue = {};

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
				
				sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, _pages[ newPageID ] );
			}
		}

//		
		private function clearData() : void
		{
			objectsTreePanel.pages = null;
			requestQue = null;
		}

		private function getPageXML( id : String ) : XML
		{
			for each ( var page : XML in objectsTreePanel.pages )
			{
				if ( page.@id == id )
					return page;
			}

			return null;
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

		private function removeHandlers() : void
		{
			objectsTreePanel.removeEventListener( ObjectsTreePanelEvent.CHANGE, changeHandler );
			objectsTreePanel.removeEventListener( ObjectsTreePanelEvent.OPEN, openHandler );
			objectsTreePanel.removeEventListener( "TreeItemRendererComplete", loadResourceRequestHandler, true );
			objectsTreePanel.removeEventListener( ObjectsTreePanelEvent.EYE_CHANGED, eyeChangeHandler, true );
		}

		private function selectCurrentPage( needGetPageStructure : Boolean = true ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			if ( !sessionProxy.selectedPage )
				return;

			if ( sessionProxy.selectedObject )
				objectsTreePanel.selectedPageID = sessionProxy.selectedObject.id;
			else
				objectsTreePanel.selectedPageID = sessionProxy.selectedPage.id;

			if ( !needGetPageStructure )
				return;

			sendNotification( ApplicationFacade.GET_PAGE_SRUCTURE, sessionProxy.selectedPage );
			//ApplicationFacade.PAGE_STRUCTURE_GETTED, objectsTreePanel.pages

			//objectsTreePanel.selectedItem = getPageXML(objectsTreePanel.selectedPageID);
			//objectsTreePanel.selectedObjectID
			//if( int(objectsTreePanel.selectedObjectID) >= 0 && objectsTreePanel.selectedObjectID )
			//objectsTreePanel.objectsTree.scrollToIndex(objectsTreePanel.selectedObjectID);// objectsTree.selectedIndex);
//				objectsTreePanel.selectedItem = getPageXML(sessionProxy.selectedPage.id);
//				objectsTreePanel.validateNow();
//				objectsTreePanel.scrollToIndex(objectsTree.selectedIndex);
		}




		private function showPages( pages : Array ) : void
		{
			var pagesXMLList : XMLList = new XMLList();
			_pages = {};

			for ( var i : int = 0; i < pages.length; i++ )
			{
				_pages[ pages[ i ].id ] = pages[ i ];

				pagesXMLList += <page id={pages[ i ].id} name={pages[ i ].name} typeID={pages[ i ].typeVO.id}  iconID={pages[ i ].typeVO.structureIconID}  />;
			}

			objectsTreePanel.pages = pagesXMLList;

//			var sessionProxy   : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;


		}
	}
}
