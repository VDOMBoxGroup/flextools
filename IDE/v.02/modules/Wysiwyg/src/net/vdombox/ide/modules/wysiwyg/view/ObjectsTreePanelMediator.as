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
			interests.push( ApplicationFacade.OBJECTS_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName())
			{
				case ApplicationFacade.PAGES_GETTED:
				{	
					showPages( notification.getBody().pages );

					break;
				}
					
				case ApplicationFacade.OBJECTS_GETTED:
				{	
					
					
					break;
				}
			}
		}

		private function initialize() : void
		{
			addEventListeners();

			objectsTree.labelField = "@name";
		}

		private function addEventListeners() : void
		{
			objectsTree.addEventListener( ListEvent.CHANGE, objectsTree_ChangeHandler );
		}

		private function showPages( pages : Array ) : void
		{
			var pageXMLList : XMLList = new XMLList();
			_pages = {};
			
			for ( var i : int = 0; i < pages.length; i++ )
			{
				_pages[ pages[ i ].id ] = pages[ i ];
				pageXMLList += <page id={ pages[ i ].id } typeID={ pages[ i ].typeID } name={ pages[ i ].name } />
			}

			objectsTree.dataProvider = pageXMLList;
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			initialize();
		}

		private function objectsTree_ChangeHandler( event : ListEvent ) : void
		{
			var item : XML = event.itemRenderer.data as XML;
			var id : String = item.@id;
			
			sendNotification( ApplicationFacade.GET_OBJECTS, _pages[ id ] );
		}
	}
}