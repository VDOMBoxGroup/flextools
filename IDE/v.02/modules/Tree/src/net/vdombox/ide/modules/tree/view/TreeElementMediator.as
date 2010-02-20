package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.PageAttributesVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.events.TreeElementEvent;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.view.components.TreeElement;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class TreeElementMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "TreeElementMediator";

		public function TreeElementMediator( viewComponent : Object, treeElementVO : TreeElementVO )
		{
			super( NAME + ApplicationFacade.DELIMITER + treeElementVO.id, viewComponent );

			_treeElementVO = treeElementVO;
		}

		private var _pageVO : PageVO;

		private var _treeElementVO : TreeElementVO;

		private var _pageAttributesVO : PageAttributesVO;

		private var _typeVO : TypeVO;

		public function get treeElementVO() : TreeElementVO
		{
			return _treeElementVO;
		}

		public function get treeElement() : TreeElement
		{
			return viewComponent as TreeElement;
		}

		public function set pageAttributesVO( value : PageAttributesVO ) : void
		{
			_pageAttributesVO = value;
			
			treeElement.description = getAttributeValue( "description" );
			treeElement.title = getAttributeValue( "title" );
		}
		
		override public function onRegister() : void
		{
			addHandlers();

			treeElement.treeElementVO = _treeElementVO;

			if ( treeElementVO.resourceID )
			{
				var resourceVO : ResourceVO = new ResourceVO( treeElementVO.pageVO.applicationVO.id );
				resourceVO.setID( treeElementVO.resourceID );
				treeElement.pageResource = resourceVO;

				sendNotification( ApplicationFacade.GET_RESOURCE, resourceVO );
			}

			sendNotification( ApplicationFacade.GET_TYPE, { typeID: treeElementVO.pageVO.typeVO.id, recipientID: mediatorName } );
			sendNotification( ApplicationFacade.GET_PAGE_ATTRIBUTES, { pageVO: treeElementVO.pageVO, recipientID: mediatorName } );
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SELECTED_TREE_ELEMENT_CHANGED );
			interests.push( ApplicationFacade.TYPE_GETTED + ApplicationFacade.DELIMITER + mediatorName );
			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_GETTED + ApplicationFacade.DELIMITER + mediatorName );
			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_SETTED + ApplicationFacade.DELIMITER + mediatorName );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.TYPE_GETTED + ApplicationFacade.DELIMITER + mediatorName:
				{
					_typeVO = body as TypeVO;

					var resourceVO : ResourceVO = new ResourceVO( _typeVO.id );
					resourceVO.setID( _typeVO.iconID );
					treeElement.typeResource = resourceVO;
					treeElement.typeName = _typeVO.displayName;

					sendNotification( ApplicationFacade.GET_RESOURCE, resourceVO );

					break;
				}

				case ApplicationFacade.PAGE_ATTRIBUTES_GETTED + ApplicationFacade.DELIMITER + mediatorName:
				{
					pageAttributesVO = body as PageAttributesVO;
					
					break;
				}
					
				case ApplicationFacade.SELECTED_TREE_ELEMENT_CHANGED:
				{
					if ( body == treeElementVO )
						treeElement.selected = true;
					else
						treeElement.selected = false;
				}
			}
		}

		private function addHandlers() : void
		{
			treeElement.addEventListener( TreeElementEvent.ELEMENT_SELECTION, elementSelectionHandler, false, 0, true );
			treeElement.addEventListener( TreeElementEvent.DELETE_REQUEST, deleteRequestHandler, false, 0, true );
			treeElement.addEventListener( TreeElementEvent.CREATE_LINKAGE_REQUEST, createLinkageRequestHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			treeElement.removeEventListener( TreeElementEvent.ELEMENT_SELECTION, elementSelectionHandler );
			treeElement.removeEventListener( TreeElementEvent.DELETE_REQUEST, deleteRequestHandler );
		}

		private function getAttributeValue( attributeName : String ) : String
		{
			var result : String;

			for each ( var attributeVO : AttributeVO in _pageAttributesVO.attributes )
			{
				if ( attributeVO.name == attributeName )
				{
					result = attributeVO.value;
					break;
				}
			}

			return result;
		}

		private function elementSelectionHandler( event : TreeElementEvent ) : void
		{
			sendNotification( ApplicationFacade.TREE_ELEMENT_SELECTION, treeElementVO );
		}
		
		private function deleteRequestHandler( event : TreeElementEvent ) : void
		{
			sendNotification( ApplicationFacade.DELETE_PAGE_REQUEST, treeElementVO.pageVO );
		}
		
		private function createLinkageRequestHandler( event : TreeElementEvent ) : void
		{
			sendNotification( ApplicationFacade.CREATE_LINKAGE_REQUEST, treeElementVO );
		}
	}
}