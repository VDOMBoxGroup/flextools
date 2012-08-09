//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	
	import mx.controls.Tree;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.ResourceVOEvent;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.common.view.components.VDOMImage;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.ObjectsTreePanelEvent;
	import net.vdombox.ide.modules.wysiwyg.model.MultiObjectsManipulationProxy;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.VisibleRendererProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectTreePanelItemRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;
	import net.vdombox.ide.modules.wysiwyg.view.components.panels.ObjectsTreePanel;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	/**
	 * 
	 * @author andreev ap
	 */
	public class ObjectsTreePanelMediator extends Mediator implements IMediator
	{
		/**
		 * 
		 * @default 
		 */
		public static const NAME : String = "ObjectsTreePanelMediator";

		/**
		 * 
		 * @param viewComponent
		 */
		public function ObjectsTreePanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
			
		}

		private var _pages : Object;

		private var isActive : Boolean;
		/**
		 *  Array of asked objects/pages to get objectsVO/pageVO
		 *  
		 */
		private var requestQue : Object;

		private var statesProxy : StatesProxy;
		
		private var multiObjectsManipulationProxy : MultiObjectsManipulationProxy;

		private function get renderProxy() : RenderProxy
		{
			return  facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
		}
		
		private var visibleRendererProxy : VisibleRendererProxy;

		private var tempFlag : Boolean = true;
		
		private var sourceID : String;
		private var containerID : String;

		/**
		 * 
		 * @return 
		 */
		public function get currentObjectID() : String
		{
			return statesProxy.selectedObject ? statesProxy.selectedObject.id : null;
		}

		/**
		 * 
		 * @return 
		 */
		public function get currentPageID() : String
		{
			return statesProxy.selectedPage ? statesProxy.selectedPage.id : null;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );
			
			interests.push( Notifications.PAGES_GETTED );
			interests.push( Notifications.PAGE_STRUCTURE_GETTED );
			
			interests.push( Notifications.MODULE_DESELECTED );
			
			interests.push( Notifications.OBJECT_GETTED );
			interests.push( StatesProxy.SELECTED_OBJECT_CHANGED );
			interests.push( StatesProxy.SELECTED_PAGE_CHANGED );
			
			interests.push( Notifications.PAGE_NAME_SETTED );
			interests.push( Notifications.OBJECT_NAME_SETTED );
			
			interests.push( StatesProxy.SELECTED_APPLICATION_CHANGED );
			
			interests.push( Notifications.PAGE_DELETED );
			interests.push( Notifications.PAGE_CREATED);
			
			interests.push( ApplicationFacade.SET_MULTISELECTION_OBJECTS);
			interests.push( ApplicationFacade.UNLOCKED_NULL);
			
			return interests;
		}


		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != Notifications.BODY_START )
				return;

			var pageXML : XML;

			switch ( name )
			{
				case Notifications.BODY_START:
				{
					if ( statesProxy.selectedApplication )
					{
						isActive = true;
						sendNotification( Notifications.GET_PAGES, statesProxy.selectedApplication );

						break;
					}
				}

				case Notifications.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case Notifications.PAGES_GETTED:
				{
					showPages( notification.getBody() as Array );
					
					selectCurrentPage();

					break;
				}

				case Notifications.PAGE_STRUCTURE_GETTED:
				{

					if ( !objectsTreePanel.pages )
						return;

					var pageXMLTree : XML = notification.getBody() as XML;

					if ( pageXMLTree )
					{
						setVisibleForElements( pageXMLTree );
						
					}
					else
					{
						pageXMLTree = new XML();
					}
					
					/*objectsTreePanel.setPageStructure( pageXMLTree );
					
					objectsTreePanel.objectsTree.invalidateList();
					objectsTreePanel.objectsTree.invalidateDisplayList();*/

					pageXML = objectsTreePanel.pages.( @id == pageXMLTree.@id )[ 0 ];
					
					if (pageXML)
					{
						//objectsTreePanel.objectsTree.selectedIndex = -1;
						pageXML.setChildren( new XMLList() ); //TODO: strange construction
						pageXML.appendChild( pageXMLTree.* );
					}

					selectCurrentPage( false );
					break;
				}

				case Notifications.OBJECT_GETTED:
				{
					var objectVO : ObjectVO = body as ObjectVO;

					var requestElement : Object = requestQue ? requestQue[ objectVO.id ] : null;

					if ( requestElement && requestElement[ "open" ] )
						sendNotification( Notifications.OPEN_OBJECT_REQUEST, objectVO );
					else
						sendNotification( StatesProxy.CHANGE_SELECTED_OBJECT_REQUEST, objectVO );

					if (requestQue)
						delete requestQue[ objectVO.id ];

					break;
				}

				case StatesProxy.SELECTED_PAGE_CHANGED:
				{
					selectCurrentPage();

					break;
				}

				case StatesProxy.SELECTED_OBJECT_CHANGED:
				{
					if ( statesProxy.selectedObject )
						objectsTreePanel.selectedObjectID = statesProxy.selectedObject.id;
					else if ( statesProxy.selectedPage )
						objectsTreePanel.selectedPageID = statesProxy.selectedPage.id;
					else
						objectsTreePanel.selectedPageID = "";

					break;
				}
					
				case Notifications.PAGE_NAME_SETTED:
				{
					var pageVO : PageVO = body as PageVO;
					
					objectsTreePanel.setNameByVo( pageVO );
					//sendNotification( Notifications.GET_PAGES, statesProxy.selectedApplication );
					
					break;
				}
					
				case Notifications.OBJECT_NAME_SETTED:
				{
					var _objectVO : ObjectVO = body as ObjectVO;
					
					objectsTreePanel.setNameByVo( _objectVO );
					sendNotification( Notifications.GET_PAGE_SRUCTURE, _objectVO.pageVO );

					break;
				}
					
				case StatesProxy.SELECTED_APPLICATION_CHANGED:
				{
					objectsTreePanel.pages = null;
					sendNotification( Notifications.GET_PAGES, statesProxy.selectedApplication );
					
					break;
				}	
					
				case Notifications.PAGE_DELETED:
				{
					sendNotification( Notifications.GET_PAGES, statesProxy.selectedApplication );
						
					break;
				}
					
				case Notifications.PAGE_CREATED:
				{
					sendNotification( Notifications.GET_PAGES, statesProxy.selectedApplication );
					
					break;
				}
					
				case ApplicationFacade.SET_MULTISELECTION_OBJECTS:
				{
					var selectElements : Object = body;
					var rendererID : String;
					var elementForSelection : XML;
					var elementsForSelection : Array = new Array();
					
					for each ( var rendererBase : RendererBase in selectElements )
					{
						if ( !rendererBase.vdomObjectVO )
							continue;
						
						rendererID = rendererBase.vdomObjectVO.id;
						elementForSelection = objectsTreePanel.pages..object.( @id == rendererID )[ 0 ];
						if ( elementForSelection )
						{
							elementsForSelection.push( elementForSelection );
							objectsTreePanel.openTree( elementForSelection );
						}
					}
					
					if ( elementsForSelection.length > 0 )
						objectsTreePanel.objectsTree.selectedItems = elementsForSelection;
					
					break;
				}
					
				case ApplicationFacade.UNLOCKED_NULL:
				{
					var renderer : RendererBase = body as RendererBase;
					if ( !renderer )
						return;
					
					objectsTreePanel.selectedObjectID = renderer.renderVO.vdomObjectVO.id;
					
					break;
				}
					
			}
		}
		/**
		 * 
		 * @return 
		 */
		public function get objectsTreePanel() : ObjectsTreePanel
		{
			return viewComponent as ObjectsTreePanel;
		}

		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			visibleRendererProxy = facade.retrieveProxy( VisibleRendererProxy.NAME ) as VisibleRendererProxy;
			
			multiObjectsManipulationProxy = facade.retrieveProxy( MultiObjectsManipulationProxy.NAME ) as MultiObjectsManipulationProxy;

			isActive = false;

			requestQue = {};

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			statesProxy = null;

			isActive = false;

			clearData();
		}

		private function addHandlers() : void
		{
			objectsTreePanel.addEventListener( ObjectsTreePanelEvent.CHANGE, changeHandler, false, 0, true );
			objectsTreePanel.addEventListener( ObjectsTreePanelEvent.OPEN, openHandler, false, 0, true );
			objectsTreePanel.addEventListener( ResourceVOEvent.GET_RESOURCE_REQUEST, getResourceRequestHandler, true); 
			objectsTreePanel.addEventListener( ObjectsTreePanelEvent.CREATE_NEW_CLICK, createNewPage, false, 0, true );
			objectsTreePanel.addEventListener( ObjectsTreePanelEvent.EYE_CHANGED, eyeChangeHandler, true, 0, true );
			objectsTreePanel.addEventListener( ObjectsTreePanelEvent.SET_START, startItemRendererHandler, true, 0, true );
			objectsTreePanel.addEventListener( ObjectsTreePanelEvent.DELETE, keyDownDeleteHandler, true, 0, true );
			objectsTreePanel.addEventListener( ObjectsTreePanelEvent.COPY, copyItemRendererHandler, true, 0, true );
			objectsTreePanel.addEventListener( ObjectsTreePanelEvent.PASTE, pasteItemRendererHandler, true, 0, true );
			objectsTreePanel.addEventListener( ObjectsTreePanelEvent.PASTE, pastePageHandler, false, 0, true );
		}
		
		private function startItemRendererHandler(event : ObjectsTreePanelEvent) : void
		{
			var pageID : String = event.pageID;
			if ( _pages.hasOwnProperty( pageID ) )
				sendNotification( Notifications.SET_APPLICATION_INFORMATION, { applicationVO : statesProxy.selectedApplication, pageID : pageID } );
		}
		
		private function eyeChangeHandler( event : ObjectsTreePanelEvent ) : void
		{
			var itemRenderer : ObjectTreePanelItemRenderer = event.target as ObjectTreePanelItemRenderer;
			
			sendNotification( Notifications.OBJECT_VISIBLE, {rendererID : itemRenderer.rendererID, visible : itemRenderer.eyeOpened });
		}
		
		private function getResourceRequestHandler( event : ResourceVOEvent ) : void
		{
			sendNotification( Notifications.GET_RESOURCE_REQUEST, event.target );
		}

		
		/**
		 *  For set selected an object/page need an objectVO/pageVO, this function send request to selected  object/page 
		 *  if objectVO/pageVO already exist, or send request to get objectVO/pageVO to send request to selected  object/page
		 * @return 
		 */
		private function changeHandler( event : ObjectsTreePanelEvent ) : void
		{
			var newPageID : String;
			var newObjectID : String;
			
			if ( objectsTreePanel.selectedItems.length > 1 )
			{
				var objects : Object = [];
				for each ( var objectXML : XML in objectsTreePanel.selectedItems )
				{
					if ( objectXML.name().localName == "page" )
						objects[ objectXML.@id ] = { objectID : objectXML.@id[0].toString(), pageID : objectXML.@id[0].toString() };
					else
						objects[ objectXML.@id ] = { objectID : objectXML.@id[0].toString(), pageID : objectXML.@pageID[0].toString() };
				}
				
				sendNotification( ApplicationFacade.DRAW_MULTISELECTION_OBJECTS, objects );
			}
			else
			{
				newPageID = objectsTreePanel.selectedPageID;
				newObjectID = objectsTreePanel.selectedObjectID;
	
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
	
					sendNotification( Notifications.GET_OBJECT, { pageVO: _pages[ newPageID ], objectID: newObjectID } );
				}
				else if ( newPageID != currentPageID )
				{
					sendNotification( StatesProxy.CHANGE_SELECTED_PAGE_REQUEST, _pages[ newPageID ] );
					sendNotification( Notifications.GET_PAGE_SRUCTURE, _pages[ newPageID ] );
				}
	
				else if ( newPageID == currentPageID && !newObjectID )
				{
					sendNotification( StatesProxy.CHANGE_SELECTED_OBJECT_REQUEST, _pages[ newPageID ] );
				}
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
				sendNotification( Notifications.OPEN_PAGE_REQUEST, _pages[ event.pageID ] );
			}
			else
			{
				if ( !requestQue.hasOwnProperty( event.objectID ) )
					requestQue[ event.objectID ] = { open: true, change: false };
				else
					requestQue[ event.objectID ][ "open" ] = true;

				sendNotification( Notifications.GET_OBJECT, { pageVO: _pages[ event.pageID ], objectID: event.objectID } );
			}
		}

		private function removeHandlers() : void
		{
			objectsTreePanel.removeEventListener( ObjectsTreePanelEvent.CHANGE, changeHandler );
			objectsTreePanel.removeEventListener( ObjectsTreePanelEvent.OPEN, openHandler );
			objectsTreePanel.removeEventListener( ResourceVOEvent.GET_RESOURCE_REQUEST, getResourceRequestHandler, true); 
			objectsTreePanel.removeEventListener( ObjectsTreePanelEvent.CREATE_NEW_CLICK, createNewPage );
			objectsTreePanel.removeEventListener( ObjectsTreePanelEvent.EYE_CHANGED, eyeChangeHandler, true );
			objectsTreePanel.removeEventListener( ObjectsTreePanelEvent.SET_START, startItemRendererHandler, true );
			objectsTreePanel.removeEventListener( ObjectsTreePanelEvent.DELETE, keyDownDeleteHandler, true );
			objectsTreePanel.removeEventListener( ObjectsTreePanelEvent.COPY, copyItemRendererHandler, true );
			objectsTreePanel.removeEventListener( ObjectsTreePanelEvent.PASTE, pasteItemRendererHandler, true );
			objectsTreePanel.removeEventListener( ObjectsTreePanelEvent.PASTE, pastePageHandler );
		}
		
		private function copyItemRendererHandler( event : ObjectsTreePanelEvent ) : void
		{
			if ( objectsTreePanel.selectedItems.length > 1 )
			{
				var objects : Object = [];
				sourceID = "";
				for each ( var objectXML : XML in objectsTreePanel.selectedItems )
				{
					if ( objectXML.name().localName == "page" )
						sourceID += "Vlt+VDOMIDE2+ " + statesProxy.selectedApplication.id + " " + objectXML.@id[0].toString() + " 1^";
					else
						sourceID += "Vlt+VDOMIDE2+ " + statesProxy.selectedApplication.id + " " + objectXML.@id[0].toString() + " 0^";
				}
				sourceID = sourceID.substr(0, sourceID.length - 1 );
			}
			else
			{
				sourceID = "Vlt+VDOMIDE2+ " + statesProxy.selectedApplication.id + " " + event.objectID + " ";
				
				if ( !event.pageID )
					sourceID += "1";
				else
					sourceID += "0";
			}
			
			
			Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, sourceID );
		}
		
		private function pasteItemRendererHandler( event : ObjectsTreePanelEvent ) : void
		{
			containerID = event.objectID;
			
			sourceID = Clipboard.generalClipboard.getData( ClipboardFormats.TEXT_FORMAT ) as String;
			
			var rendererBase : Object =  renderProxy.getRendererByID( containerID );
			
			if ( !rendererBase )
				rendererBase = _pages[ containerID ];
			
			multiObjectsManipulationProxy.pasteObjects( sourceID.split( "^" ), rendererBase );
		}
		
		private function keyDownDeleteHandler(event : ObjectsTreePanelEvent) : void
		{
			var objectID : String = event.objectID;
			var pageID : String = event.pageID;
			
			Alert.setPatametrs( "Delete", "Cancel", VDOMImage.Delete );
			
			var textAlert : String = ResourceManager.getInstance().getString( 'Wysiwyg_General', 'delete_Renderer' );
			
			var flag : Boolean = false;
			
			for each( var item : XML in objectsTreePanel.selectedItems )
			{
				if ( item.@id == objectID )
				{
					flag = true;
					break;
				}
			}
			
			if ( flag && objectsTreePanel.selectedItems.length > 1 )
				textAlert += " " + objectsTreePanel.selectedItems.length.toString()+ " " + ResourceManager.getInstance().getString( 'Wysiwyg_General', 'elements' );
			
			Alert.Show( textAlert + " ?",AlertButton.OK_No, objectsTreePanel.parentApplication, closeHandler);
					
				
			function closeHandler( event : CloseEvent ) : void
			{
				if (event.detail == Alert.YES)
				{					
					if ( flag )
					{						
						for each ( var objectXML : XML in objectsTreePanel.selectedItems )
						{
							if ( objectXML.name().localName == "page" )
								sendNotification( Notifications.DELETE_PAGE, { applicationVO: statesProxy.selectedApplication, pageVO: _pages[ objectXML.@id[0].toString() ] } );
							else
								sendNotification( Notifications.DELETE_OBJECT, { pageVO:  _pages[ objectXML.@pageID[0].toString() ], objectVO: renderProxy.getRendererByID( objectXML.@id[0].toString() ).renderVO.vdomObjectVO } );			
						}		
					}
					else
					{
						if ( pageID )
							sendNotification( Notifications.DELETE_OBJECT, { pageVO: renderProxy.getRendererByID( pageID ).renderVO.vdomObjectVO, objectVO: renderProxy.getRendererByID( objectID ).renderVO.vdomObjectVO } );
						else
							sendNotification( Notifications.DELETE_PAGE, { applicationVO: statesProxy.selectedApplication, pageVO: _pages[objectID] } );
					}
				}
			}
		}
		
		private function pastePageHandler( event : ObjectsTreePanelEvent ) : void
		{
			sourceID = Clipboard.generalClipboard.getData( ClipboardFormats.TEXT_FORMAT ) as String;
			sendNotification( Notifications.COPY_REQUEST, { applicationVO : statesProxy.selectedApplication, sourceID : sourceID } );
		}
		
		private function createNewPage( event : ObjectsTreePanelEvent ) : void
		{
			sendNotification( Notifications.OPEN_CREATE_PAGE_WINDOW_REQUEST, objectsTreePanel );
		}

		private function selectCurrentPage( needGetPageStructure : Boolean = true ) : void
		{
			if ( !statesProxy.selectedPage )
				return;

			if ( statesProxy.selectedObject )
				objectsTreePanel.selectedPageID = statesProxy.selectedObject.id;
			else
				objectsTreePanel.selectedPageID = statesProxy.selectedPage.id;

			if ( !needGetPageStructure )
				return;

			sendNotification( Notifications.GET_PAGE_SRUCTURE, statesProxy.selectedPage );
		}



		private function setVisibleForElements( pageXML : XML) : void
		{
			var xmlList : XMLList = pageXML..object;

			var objectXML : XML;
			var typeID : String;
			var typeProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy ;
			
			var xmlListSort : XMLList = new XMLList();
			
			for each( objectXML in xmlList)
			{
				typeID = objectXML.@typeID;
				var rr : TypeVO = typeProxy.getTypeVObyID( typeID )
				objectXML.@iconID = rr.structureIconID;
				objectXML.@visible = visibleRendererProxy.getVisible(  String(objectXML.@id) );
			}
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
		}
	}
}
