package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.common.vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.events.TreeElementEvent;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.view.components.TreeElement;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class TreeElementMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "TreeElementMediator";

		public function TreeElementMediator( treeElement : TreeElement )
		{
			super( NAME + ApplicationFacade.DELIMITER + treeElement.treeElementVO.id, treeElement );
		}

		private var sessionProxy : SessionProxy;

		private var _vdomObjectAttributesVO : VdomObjectAttributesVO;

		private var _typeVO : TypeVO;

		public function get treeElementVO() : TreeElementVO
		{
			return treeElement ? treeElement.treeElementVO : null;
		}

		public function get treeElement() : TreeElement
		{
			return viewComponent as TreeElement;
		}

		public function set vdomObjectAttributesVO( value : VdomObjectAttributesVO ) : void
		{
			_vdomObjectAttributesVO = value;

			treeElement.description = getAttributeValue( "description" );
			treeElement.title = getAttributeValue( "title" );
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			addHandlers();

			if ( treeElementVO && treeElementVO.resourceVO && !treeElementVO.resourceVO.data )
			{
				sendNotification( ApplicationFacade.LOAD_RESOURCE, treeElementVO.resourceVO );
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

			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );

			interests.push( ApplicationFacade.EXPAND_ALL_TREE_ELEMENTS );
			interests.push( ApplicationFacade.COLLAPSE_ALL_TREE_ELEMENTS );

			interests.push( ApplicationFacade.TYPE_GETTED + ApplicationFacade.DELIMITER + mediatorName );

			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_GETTED + ApplicationFacade.DELIMITER + mediatorName );
			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_SETTED );
			
			interests.push( ApplicationFacade.APPLICATION_INFORMATION_SETTED );
			//interests.push( ApplicationFacade.SELECTED_TREE_ELEMENT_CHANGED );

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
					vdomObjectAttributesVO = body as VdomObjectAttributesVO;

					break;
				}

				case ApplicationFacade.PAGE_ATTRIBUTES_SETTED:
				{
					var newPageAttributesVO : VdomObjectAttributesVO = body as VdomObjectAttributesVO;
					
					if( newPageAttributesVO && newPageAttributesVO.vdomObjectVO.id == treeElementVO.pageVO.id )
						vdomObjectAttributesVO = newPageAttributesVO;
					
					break;
				}

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					if ( sessionProxy.selectedPage == treeElementVO.pageVO )
						treeElement.selected = true;
					else
						treeElement.selected = false;

					break;
				}

				/*case ApplicationFacade.SELECTED_TREE_ELEMENT_CHANGED:
				{
					if ( this.treeElementVO == body as TreeElementVO )
						treeElement.selected = true;
					else
						treeElement.selected = false;
					
					break;
				}*/
					
				case ApplicationFacade.EXPAND_ALL_TREE_ELEMENTS:
				{
					if ( treeElementVO && !treeElementVO.state )
						treeElementVO.state = true;

					break;
				}

				case ApplicationFacade.COLLAPSE_ALL_TREE_ELEMENTS:
				{
					if ( treeElementVO && treeElementVO.state )
						treeElementVO.state = false;

					break;
				}
					
				case ApplicationFacade.APPLICATION_INFORMATION_SETTED:
				{
					var applicationVO : ApplicationVO = body as ApplicationVO;
					
					if( applicationVO && treeElementVO && treeElementVO.pageVO.id == applicationVO.indexPageID )
						treeElement.isIndexPage = true;
					else
						treeElement.isIndexPage = false;
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			treeElement.addEventListener( TreeElementEvent.SELECTION, elementSelectionHandler, false, 0, true );
			treeElement.addEventListener( TreeElementEvent.DELETE, deleteRequestHandler, false, 0, true );
//			treeElement.addEventListener( TreeElementEvent.CREATE_LINKAGE_REQUEST, createLinkageRequestHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			treeElement.removeEventListener( TreeElementEvent.SELECTION, elementSelectionHandler );
			treeElement.removeEventListener( TreeElementEvent.DELETE, deleteRequestHandler );
		}

		private function getAttributeValue( attributeName : String ) : String
		{
			var result : String;

			for each ( var attributeVO : AttributeVO in _vdomObjectAttributesVO.attributes )
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
			if ( treeElementVO && treeElementVO.pageVO && sessionProxy.selectedPage != treeElementVO.pageVO )
			{
				sendNotification( ApplicationFacade.SELECTED_TREE_ELEMENT_CHANGE_REQUEST, treeElementVO );
			}
		}

		private function deleteRequestHandler( event : TreeElementEvent ) : void
		{
			sendNotification( ApplicationFacade.DELETE_PAGE_REQUEST, treeElementVO.pageVO );
		}

		private function createLinkageRequestHandler( event : TreeElementEvent ) : void
		{
//			sendNotification( ApplicationFacade.CREATE_LINKAGE_REQUEST, treeElementVO );
		}
	}
}