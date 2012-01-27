package net.vdombox.ide.modules.events.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Tree;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import net.vdombox.ide.common.events.ResourceVOEvent;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	import net.vdombox.ide.modules.events.model.SessionProxy;
	import net.vdombox.ide.modules.events.model.VisibleElementProxy;
	import net.vdombox.ide.modules.events.view.components.EventElement;
	import net.vdombox.ide.modules.events.view.components.ObjectsTreePanel;
	
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

		private var isActive : Boolean;

		private var sessionProxy : SessionProxy;

		private var _pages : Object;

		private var selectedObject : ObjectVO;
		private var selectedPage : PageVO;

		[Bindable]
		private var pagesXMLList : XMLList;
		
		private var currentPageXML : XML;
		
		private var visibleElementProxy : VisibleElementProxy;
		
		private var treePanelCreateCompleted : Boolean = false;

		public function get objectsTreePanel() : ObjectsTreePanel
		{
			return viewComponent as ObjectsTreePanel;
		}

		public function get objectsTree() : Tree
		{
			return objectsTreePanel.objectsTree as Tree;
		}

		override public function onRegister() : void
		{
			isActive = false;

			objectsTree.labelField = "@name";
			objectsTree.showRoot = true;

			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			visibleElementProxy = facade.retrieveProxy( VisibleElementProxy.NAME ) as VisibleElementProxy;
			
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

			interests.push( ApplicationFacade.PAGES_GETTED );
			interests.push( ApplicationFacade.PAGE_STRUCTURE_GETTED );

			interests.push( ApplicationFacade.OBJECT_GETTED );
			
			interests.push( ApplicationFacade.GET_CHILDREN_ELEMENTS );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			var pageXML : XML;

			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;

			switch ( name )
			{
				case ApplicationFacade.BODY_START:
				{
					if ( sessionProxy.selectedApplication )
					{
						isActive = true;
						treePanelCreateCompleted = false;
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
					var pageXMLTree : XML = notification.getBody() as XML;
					
					if ( pageXMLTree )
					{
						setVisibleForElements( pageXMLTree );
						
					}
					else
					{
						pageXMLTree = new XML();
					}

					// XXX: doun on quck switch (pagesXMLList == null)
					currentPageXML = pagesXMLList.( @id == pageXMLTree.@id )[ 0 ];
					currentPageXML.setChildren( new XMLList() );
					currentPageXML.appendChild( pageXMLTree.* );

					//objectsTree.validateNow();
					selectCurrentPage( false );
					
					if ( !treePanelCreateCompleted )
					{
						treePanelCreateCompleted = true;
						sendNotification( ApplicationFacade.STRUCTURE_GETTED );
					}
					
					
					break;
				}

				case ApplicationFacade.OBJECT_GETTED:
				{
					selectedObject = body as ObjectVO;
					sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, selectedObject );

					break;
				}
					
				case ApplicationFacade.GET_CHILDREN_ELEMENTS:
				{
					sendNotification( ApplicationFacade.CHILDREN_ELEMENTS_GETTED, objectsTreePanel.selectedObject );
					
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
				var typeVO : TypeVO = typeProxy.getTypeVObyID( typeID )
				objectXML.@iconID = typeVO.structureIconID;
				//				trace("typeID: " + typeID+ " visible: " + objectXML.@visible)
			}
		}

		private function clearData() : void
		{
			objectsTreePanel.structure = null;
			pagesXMLList = null;
			_pages = null;
		}

		private function addHandlers() : void
		{
			objectsTree.addEventListener( ListEvent.CHANGE, objectsTree_ChangeHandler, false, 0, true );
			objectsTreePanel.addEventListener(ResourceVOEvent.GET_RESOURCE_REQUEST, getResourceRequestHandler, true); 
		}

		private function removeHandlers() : void
		{
			objectsTree.removeEventListener( ListEvent.CHANGE, objectsTree_ChangeHandler );
			objectsTreePanel.removeEventListener(ResourceVOEvent.GET_RESOURCE_REQUEST, getResourceRequestHandler, true); 
		}
		

		private function showPages( pages : Array ) : void
		{
			pagesXMLList = new XMLList();
			_pages = {};

			for ( var i : int = 0; i < pages.length; i++ )
			{
				_pages[ pages[ i ].id ] = pages[ i ];
				pagesXMLList +=
					<page id={pages[ i ].id} name={pages[ i ].name} typeID={pages[ i ].typeVO.id} iconID={pages[ i ].typeVO.structureIconID}/>
			}

			objectsTreePanel.structure = pagesXMLList;

			selectCurrentPage();
		}
		
		private function selectCurrentPage(  needGetPageStructure : Boolean = true  ) : void
		{
			var sessionProxy   : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			if( sessionProxy.selectedPage )
			{
				if ( sessionProxy.selectedObject )
					objectsTreePanel.selectedPageID = sessionProxy.selectedObject.id;
				else
					objectsTreePanel.selectedPageID = sessionProxy.selectedPage.id;
				
				if ( !needGetPageStructure )
					return;
				
				sendNotification( ApplicationFacade.SELECTED_PAGE_CHANGED, sessionProxy.selectedPage);
				sendNotification( ApplicationFacade.GET_PAGE_SRUCTURE, sessionProxy.selectedPage );
				
			}
			else
			{
				trace("Error: not selected Page in Event Modul");
			}
		}
		
		private function getPageXML( id : String ) : XML
		{	
			for each ( var page:XML in objectsTree.dataProvider)
			{
				if (page.@id == id)
					return page;
			}
			
			return null;
		}

		private function objectsTree_ChangeHandler( event : ListEvent ) : void
		{
			var item : XML = event.itemRenderer.data as XML;
			var id : String = item.@id;

			if ( item.name() == "page" )
			{
				if( currentPageXML )
					delete currentPageXML.*;
				
				sendNotification( ApplicationFacade.CHANGE_SELECTED_PAGE_REQUEST, _pages[ id ] );
				sendNotification( ApplicationFacade.GET_PAGE_SRUCTURE, _pages[ id ] );
			}
			else if ( item.name() == "object" )
			{
				var pageID : String
				var parent : XML = item.parent();

				while ( parent )
				{
					if ( parent.name() != "page" )
					{
						parent = parent.parent();
						continue;
					}

					pageID = parent.@id;
					parent = null;
				}

				sendNotification( ApplicationFacade.GET_OBJECT, { pageVO: _pages[ pageID ], objectID: id } );
			}
			
		}
		
		private function getResourceRequestHandler( event : ResourceVOEvent ) : void
		{
			sendNotification( ApplicationFacade.GET_RESOURCE_REQUEST, event.target );
		}
	}
}