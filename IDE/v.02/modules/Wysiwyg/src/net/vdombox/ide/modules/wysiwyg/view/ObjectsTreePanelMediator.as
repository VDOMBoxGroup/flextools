package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.controls.Tree;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
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
					showPages( notification.getBody().pages );

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
					sendNotification( ApplicationFacade.OBJECT_SELECTED, body );
					
					break;
				}
			}
		}

		private function initialize() : void
		{
			addEventListeners();

			objectsTree.labelField = "@name";
			objectsTree.showRoot = true;
		}

		private function addEventListeners() : void
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
				sendNotification( ApplicationFacade.PAGE_SELECTED, _pages[ id ] );
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