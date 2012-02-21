package net.vdombox.ide.modules.events.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Tree;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.events.ResourceVOEvent;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.events.model.MessageProxy;
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

		private var statesProxy : StatesProxy;

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

			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
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

			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );

			interests.push( Notifications.PAGES_GETTED );
			interests.push( Notifications.PAGE_STRUCTURE_GETTED );

			interests.push( Notifications.OBJECT_GETTED );
			
			interests.push( Notifications.GET_CHILDREN_ELEMENTS );
			
			interests.push( Notifications.SAVE_IN_WORKAREA_CHECKED );
			interests.push( Notifications.APPLICATION_EVENTS_SETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			var pageXML : XML;

			if ( !isActive && name != Notifications.BODY_START )
				return;

			switch ( name )
			{
				case Notifications.BODY_START:
				{
					if ( statesProxy.selectedApplication )
					{
						isActive = true;
						treePanelCreateCompleted = false;
						sendNotification( Notifications.GET_PAGES, statesProxy.selectedApplication );

						break;
					}
				}

				case Notifications.BODY_STOP:
				{
					isActive = false;
					
					var messageProxy : MessageProxy = facade.retrieveProxy( MessageProxy.NAME ) as MessageProxy;
					messageProxy.removeAll( _pages );

					clearData();

					break;
				}

				case Notifications.PAGES_GETTED:
				{
					showPages( notification.getBody() as Array );

					break;
				}

				case Notifications.PAGE_STRUCTURE_GETTED:
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
					if ( !pagesXMLList )
						return;
				
					currentPageXML = pagesXMLList.( @id == pageXMLTree.@id )[ 0 ];
					currentPageXML.setChildren( new XMLList() );
					currentPageXML.appendChild( pageXMLTree.* );

					//objectsTree.validateNow();
					selectCurrentPage( false );
					
					if ( !treePanelCreateCompleted )
					{
						treePanelCreateCompleted = true;
						sendNotification( Notifications.STRUCTURE_GETTED );
					}
					
					
					break;
				}

				case Notifications.OBJECT_GETTED:
				{
					selectedObject = body as ObjectVO;
					sendNotification( StatesProxy.CHANGE_SELECTED_OBJECT_REQUEST, selectedObject );

					break;
				}
					
				case Notifications.GET_CHILDREN_ELEMENTS:
				{
					sendNotification( Notifications.CHILDREN_ELEMENTS_GETTED, objectsTreePanel.selectedObject );
					
					break;
				}
					
				case Notifications.SAVE_IN_WORKAREA_CHECKED:
				{
					if ( body.object != this )
						return;
					
					if ( ( body.saved as Boolean ) )
						changeFunction();
					else
					{
						Alert.Show( ResourceManager.getInstance().getString( 'Events_General', 'save_the_changes' ), AlertButton.OK_No, objectsTreePanel.parentApplication, alertHandler );
					}
					return;
				}
					
				case Notifications.APPLICATION_EVENTS_SETTED:
				{
					if ( needChangePage )
					{
						needChangePage = false;
						changeFunction();
					}
					
					break;
				}
			}
		}
		
		private var needChangePage : Boolean = false;
		
		private function alertHandler( event : CloseEvent ) : void
		{
			if (event.detail == Alert.YES)
			{
				needChangePage = true;
				sendNotification( Notifications.SAVE_CHANGED );
			}
			else
				changeFunction();
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
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			if( statesProxy.selectedPage )
			{
				if ( statesProxy.selectedObject )
					objectsTreePanel.selectedPageID = statesProxy.selectedObject.id;
				else
					objectsTreePanel.selectedPageID = statesProxy.selectedPage.id;
				
				if ( !needGetPageStructure )
					return;
				
				sendNotification( StatesProxy.SELECTED_PAGE_CHANGED, statesProxy.selectedPage);
				sendNotification( Notifications.GET_PAGE_SRUCTURE, statesProxy.selectedPage );
				
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

		private var item : XML;
		
		private function objectsTree_ChangeHandler( event : ListEvent ) : void
		{
			item = event.itemRenderer.data as XML;
			
			var id : String = item.@id;
			
			if ( item.name() == "page" )
			{
				if( currentPageXML )
					delete currentPageXML.*;
				
				if ( id != currentPageXML.@id )
					sendNotification( Notifications.CHECK_SAVE_IN_WORKAREA, this );
				else
					changeFunction();
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
				
				sendNotification( Notifications.GET_OBJECT, { pageVO: _pages[ pageID ], objectID: id } );
			}
			
			
		}
		
		private function changeFunction() : void
		{
			var id : String = item.@id;
			
			sendNotification( StatesProxy.CHANGE_SELECTED_PAGE_REQUEST, _pages[ id ] );
			sendNotification( Notifications.GET_PAGE_SRUCTURE, _pages[ id ] );
		}
		
		private function getResourceRequestHandler( event : ResourceVOEvent ) : void
		{
			sendNotification( Notifications.GET_RESOURCE_REQUEST, event.target );
		}
	}
}