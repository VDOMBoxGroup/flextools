package net.vdombox.ide.modules.events.view
{
	import mx.controls.Tree;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	import net.vdombox.ide.modules.events.model.SessionProxy;
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
		
		private var sessionProxy : SessionProxy;
		
		private var _pages : Object;
		
		private var selectedObject : ObjectVO;
		private var selectedPage : PageVO;
		
		[Bindable]
		private var pagesXMLList : XMLList;
		
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
			objectsTree.labelField = "@name";
			objectsTree.showRoot = true;
			
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
		}
		
		override public function onRemove() : void
		{
			
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );
			
			interests.push( ApplicationFacade.PAGES_GETTED );
			interests.push( ApplicationFacade.PAGE_STRUCTURE_GETTED );
			
			interests.push( ApplicationFacade.OBJECT_GETTED );
			
			interests.push( ApplicationFacade.MODULE_DESELECTED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			var pageXML : XML;
			
			switch ( name )
			{
				case ApplicationFacade.BODY_START:
				{
					if( sessionProxy.selectedApplication )
						sendNotification( ApplicationFacade.GET_PAGES, sessionProxy.selectedApplication );
					
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
					
					pageXML = pagesXMLList.( @id == pageXMLTree.@id )[ 0 ];
					pageXML.setChildren( new XMLList() );
					pageXML.appendChild( pageXMLTree.* );
					
					break;
				}
					
				case ApplicationFacade.MODULE_DESELECTED:
				{
					objectsTree.dataProvider = null;
					break;
				}
					
				case ApplicationFacade.OBJECT_GETTED:
				{
					selectedObject = body as ObjectVO;
//					sendNotification( ApplicationFacade.OBJECT_SELECTED_REQUEST, body );
					
					break;
				}
			}
		}
		
		private function openTree( item : Object ) : void
		{
			//			trace('openTree');
			var parentItem : Object = XML( item ).parent();
			if ( parentItem )
			{
				openTree( parentItem );
				objectsTree.expandItem( parentItem, true, false );
				objectsTree.validateNow();
			}
		}
		
		private function addHandlers() : void
		{
			objectsTree.addEventListener( ListEvent.CHANGE, objectsTree_ChangeHandler, false, 0, true);
		}
		
		private function removeHandlers() : void
		{
			objectsTree.removeEventListener( ListEvent.CHANGE, objectsTree_ChangeHandler );
		}
		
		private function showPages( pages : Array ) : void
		{
			pagesXMLList = new XMLList();
			_pages = {};
			
			for ( var i : int = 0; i < pages.length; i++ )
			{
				_pages[ pages[ i ].id ] = pages[ i ];
				pagesXMLList +=
					<page id={pages[ i ].id} name={pages[ i ].name} typeID={pages[ i ].typeVO.id}/>
			}
			
			objectsTree.dataProvider = pagesXMLList;
		}
		
		private function objectsTree_ChangeHandler( event : ListEvent ) : void
		{
			var item : XML = event.itemRenderer.data as XML;
			var id : String = item.@id;
			
			if ( item.name() == "page" )
			{
				sendNotification( ApplicationFacade.GET_PAGE_SRUCTURE, _pages[ id ] );
//				sendNotification( ApplicationFacade.CHANGE_SELECTED_PAGE_REQUEST, _pages[ id ] );
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
	}
}