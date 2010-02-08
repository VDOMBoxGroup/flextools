package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.PageAttributesVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.events.TreeElementEvent;
	import net.vdombox.ide.modules.tree.model.vo.StructureElementVO;
	import net.vdombox.ide.modules.tree.view.components.TreeElement;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class TreeElementMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "TreeElementMediator";

		public function TreeElementMediator( viewComponent : Object, pageVO : PageVO, structureElementVO : StructureElementVO )
		{
			super( NAME + ApplicationFacade.DELIMITER + pageVO.id, viewComponent );

			_pageVO = pageVO;

			_structureElementVO = structureElementVO ? structureElementVO : new StructureElementVO( pageVO.id );
		}

		private var _pageVO : PageVO;

		private var _structureElementVO : StructureElementVO;

		private var _pageAttributesVO : PageAttributesVO;

		private var _typeVO : TypeVO;

		public function get pageVO() : PageVO
		{
			return _pageVO;
		}

		public function get structureElementVO() : StructureElementVO
		{
			return _structureElementVO;
		}

		public function get treeElement() : TreeElement
		{
			return viewComponent as TreeElement;
		}

		override public function onRegister() : void
		{
			addHandlers();

			treeElement.structureElementVO = structureElementVO;

			if ( structureElementVO.resourceID )
			{
				var resourceVO : ResourceVO = new ResourceVO( pageVO.applicationID );
				resourceVO.setID( structureElementVO.resourceID );
				treeElement.pageResource = resourceVO;

				sendNotification( ApplicationFacade.GET_RESOURCE, resourceVO );
			}

			sendNotification( ApplicationFacade.GET_TYPE, { typeID: pageVO.typeID, recipientID: mediatorName } );
			sendNotification( ApplicationFacade.GET_PAGE_ATTRIBUTES, { pageVO: pageVO, recipientID: mediatorName } );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SELECTED_PAGE_GETTED );
			interests.push( ApplicationFacade.TYPE_GETTED + ApplicationFacade.DELIMITER + mediatorName );
			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_GETTED + ApplicationFacade.DELIMITER + mediatorName );

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
					_pageAttributesVO = body as PageAttributesVO;

					treeElement.description = getAttributeValue( "description" );
					treeElement.title = getAttributeValue( "title" );
					break;
				}

				case ApplicationFacade.SELECTED_PAGE_GETTED:
				{
					if( body == pageVO )
						treeElement.selected = true;
					else
						treeElement.selected = false;
				}
			}
		}

		private function addHandlers() : void
		{
			treeElement.addEventListener( TreeElementEvent.ELEMENT_SELECTION, elementSelectionHandler );
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
			sendNotification( ApplicationFacade.TREE_ELEMENT_SELECTION, pageVO );
		}
	}
}