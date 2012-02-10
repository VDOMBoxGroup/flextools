package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.events.TreeElementEvent;
	import net.vdombox.ide.modules.tree.model.StatesProxy;
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

		private var statesProxy : StatesProxy;

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

			treeElement.vdomObjectAttributesVO = _vdomObjectAttributesVO;
		}

		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			addHandlers();

			if ( treeElementVO && treeElementVO.resourceVO && !treeElementVO.resourceVO.data )
			{
				sendNotification( ApplicationFacade.LOAD_RESOURCE, treeElementVO.resourceVO );
			}

			sendNotification( TypesProxy.GET_TYPE, { typeID: treeElementVO.pageVO.typeVO.id, recipientID: mediatorName } );
			sendNotification( ApplicationFacade.GET_PAGE_ATTRIBUTES, { pageVO: treeElementVO.pageVO, recipientID: mediatorName } );
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( StatesProxy.SELECTED_PAGE_CHANGED );

			interests.push( ApplicationFacade.EXPAND_ALL_TREE_ELEMENTS );
			interests.push( ApplicationFacade.COLLAPSE_ALL_TREE_ELEMENTS );

			interests.push( TypesProxy.TYPE_GETTED + ApplicationFacade.DELIMITER + mediatorName );

			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_GETTED + ApplicationFacade.DELIMITER + mediatorName );
			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_SETTED );
			
			interests.push( ApplicationFacade.APPLICATION_INFORMATION_SETTED );
			//interests.push( ApplicationFacade.SELECTED_TREE_ELEMENT_CHANGED );

			interests.push( ApplicationFacade.PAGE_NAME_SETTED );
			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			

			switch ( name )
			{
				case TypesProxy.TYPE_GETTED + ApplicationFacade.DELIMITER + mediatorName:
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

				case StatesProxy.SELECTED_PAGE_CHANGED:
				{
					if ( statesProxy.selectedPage && statesProxy.selectedPage.id == treeElementVO.pageVO.id )
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
					
				case ApplicationFacade.PAGE_NAME_SETTED:
				{
					var treeElementPageVO : PageVO = body as PageVO;
					
					if (treeElement.treeElementVO && treeElementPageVO.id == treeElement.treeElementVO.pageVO.id)
						treeElement.nameAttribute = treeElementPageVO.name;
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			treeElement.addEventListener( TreeElementEvent.SELECTION, elementSelectionHandler, false, 0, true );
			treeElement.addEventListener( TreeElementEvent.DELETE, deleteRequestHandler, false, 0, true );
			treeElement.addEventListener( TreeElementEvent.SAVE_PAGE_NAME, savePageNameHandler, false, 0, true );
			treeElement.addEventListener( TreeElementEvent.SAVE_PAGE_ATTRIBUTES, savePageAttributesHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			treeElement.removeEventListener( TreeElementEvent.SELECTION, elementSelectionHandler );
			treeElement.removeEventListener( TreeElementEvent.DELETE, deleteRequestHandler );
			treeElement.removeEventListener( TreeElementEvent.SAVE_PAGE_NAME, savePageNameHandler );
			treeElement.removeEventListener( TreeElementEvent.SAVE_PAGE_ATTRIBUTES, savePageAttributesHandler );
		}

		private function elementSelectionHandler( event : TreeElementEvent ) : void
		{
			if ( treeElementVO && treeElementVO.pageVO && statesProxy.selectedPage != treeElementVO.pageVO )
			{
				sendNotification( StatesProxy.SELECTED_TREE_ELEMENT_CHANGE_REQUEST, treeElementVO );
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
		
		private function savePageNameHandler( event : TreeElementEvent ) : void
		{
			sendNotification( ApplicationFacade.SET_PAGE_NAME, treeElement.treeElementVO.pageVO );
		}
		
		private function savePageAttributesHandler( event : TreeElementEvent ) : void
		{
			if ( treeElement.vdomObjectAttributesVO )
			{
				sendNotification( ApplicationFacade.SET_PAGE_ATTRIBUTES,
					treeElement.vdomObjectAttributesVO);
			}
		}
	}
}