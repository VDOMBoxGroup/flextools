package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.collections.IViewCursor;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;
	import mx.controls.Tree;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectsTreePanel;
	
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
		
		private var selectedObject : ObjectVO;

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
			if ( !objectsTreePanel.initialized )
				objectsTreePanel.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			else
				initialize();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.PAGES_GETTED );
			interests.push( ApplicationFacade.PAGE_SRUCTURE_GETTED );
			
			interests.push( ApplicationFacade.MODULE_DESELECTED );

			interests.push( ApplicationFacade.OBJECT_GETTED );
			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );
			
			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			switch ( name )
			{
				case ApplicationFacade.PAGES_GETTED:
				{	
					showPages( notification.getBody() as Array );

					break;
				}
					
				case ApplicationFacade.PAGE_SRUCTURE_GETTED:
				{	
					var pageXMLTree : XML = notification.getBody() as XML;
					var pageXML : XML;
					
					pageXML = pagesXMLList.( @id == pageXMLTree.@id )[ 0 ];
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
					sendNotification( ApplicationFacade.OBJECT_SELECTED_REQUEST, body );
					
					break;
				}
					
				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{	
					if( selectedObject == body )
						return;
					
					var element : XML = pagesXMLList..object.( @id == body.id )[ 0 ];
					
					if( element )
					{
						openTree( element );
						objectsTree.selectedItem = element;
						objectsTree.scrollToIndex( objectsTree.selectedIndex );
					}
					
					
					break;
				}
			}
		}

		private function openTree(item:Object):void
		{
			//			trace('openTree');
			var parentItem:Object = XML(item).parent();
			if (parentItem)
			{
				openTree(parentItem);
				objectsTree.expandItem(parentItem, true, false);
				objectsTree.validateNow();
			}
		}
		
		private function initialize() : void
		{
			addHandlers();

			objectsTree.labelField = "@name";
			objectsTree.showRoot = true;
		}

		private function addHandlers() : void
		{
			objectsTree.addEventListener( ListEvent.CHANGE, objectsTree_ChangeHandler );
		}

		private function showPages( pages : Array ) : void
		{
			pagesXMLList  = new XMLList();
			_pages = {};
			
			for ( var i : int = 0; i < pages.length; i++ )
			{
				_pages[ pages[ i ].id ] = pages[ i ];
				pagesXMLList += <page id={ pages[ i ].id } name={ pages[ i ].name } typeID={ pages[ i ].typeVO.id }/>
			}

			objectsTree.dataProvider = pagesXMLList;
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			initialize();
		}

		private function objectsTree_ChangeHandler( event : ListEvent ) : void
		{
			var item : XML = event.itemRenderer.data as XML;
			var id : String = item.@id;
			
			if( item.name() == "page" )
			{
				sendNotification( ApplicationFacade.GET_PAGE_SRUCTURE, _pages[ id ] );
				sendNotification( ApplicationFacade.CHANGE_SELECTED_PAGE_REQUEST, _pages[ id ] );
			}
			else if ( item.name() == "object" )
			{
				var pageID : String
				var parent : XML = item.parent();
				
				while( parent )
				{
					if( parent.name() != "page" )
					{
						parent = parent.parent();
						continue;
					}
					
					pageID = parent.@id;
					parent = null;
				}
					
				sendNotification( ApplicationFacade.GET_OBJECT, { pageVO : _pages[ pageID ], objectID : id } );
			}
		}
		
		
	}
}