package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.tree.events.AttributeEvent;
	import net.vdombox.ide.modules.tree.events.PropertiesPanelEvent;
	import net.vdombox.ide.modules.tree.model.StatesProxy;
	import net.vdombox.ide.modules.tree.view.components.PropertiesPanel;
	import net.vdombox.ide.modules.tree.view.components.ResourceSelector;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class PropertiesPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "PropertiesPanelMediator";

		public function PropertiesPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var statesProxy : StatesProxy;

		private var isActive : Boolean;

		public function get propertiesPanel() : PropertiesPanel
		{
			return viewComponent as PropertiesPanel;
		}

		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			isActive = false;

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

			interests.push( StatesProxy.SELECTED_PAGE_CHANGED );

			interests.push( Notifications.PAGE_ATTRIBUTES_GETTED + Notifications.DELIMITER + mediatorName );
			interests.push( Notifications.PAGE_ATTRIBUTES_SETTED + Notifications.DELIMITER + mediatorName );

			interests.push( Notifications.APPLICATION_INFORMATION_SETTED );

			interests.push( Notifications.PAGE_NAME_SETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != Notifications.BODY_START )
				return;

			switch ( name )
			{
				case Notifications.BODY_START:
				{
					if ( statesProxy.selectedApplication )
					{
						isActive = true;
						updateAttributes();

						break;
					}
				}

				case Notifications.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case StatesProxy.SELECTED_PAGE_CHANGED:
				{
					updateAttributes();

					break;
				}

				case Notifications.PAGE_ATTRIBUTES_GETTED + Notifications.DELIMITER + mediatorName:
				{
					propertiesPanel.vdomObjectAttributesVO = body as VdomObjectAttributesVO;

					if ( statesProxy.selectedTreeElement && statesProxy.selectedTreeElement.resourceVO && statesProxy.selectedTreeElement.resourceVO.id && !statesProxy.selectedTreeElement.resourceVO.data )
					{
						sendNotification( Notifications.LOAD_RESOURCE, { resourceVO: statesProxy.selectedTreeElement.resourceVO } )
					}

					propertiesPanel.treeElementVO = statesProxy.selectedTreeElement;

					break;
				}

				case Notifications.PAGE_ATTRIBUTES_SETTED + Notifications.DELIMITER + mediatorName:
				{
					propertiesPanel.vdomObjectAttributesVO = body as VdomObjectAttributesVO;

					break;
				}

				case Notifications.APPLICATION_INFORMATION_SETTED:
				{
					var applicationVO : ApplicationVO = body as ApplicationVO;

					if ( !propertiesPanel.treeElementVO )
						return;

					if ( applicationVO && propertiesPanel.treeElementVO.pageVO && propertiesPanel.treeElementVO.pageVO.id == applicationVO.indexPageID )
						propertiesPanel.makeStartButton.enabled = false;
					else
						propertiesPanel.makeStartButton.enabled = true;

					break;
				}

				case Notifications.PAGE_NAME_SETTED:
				{
					var treeElementPageVO : PageVO = body as PageVO;

					if ( propertiesPanel.treeElementVO && propertiesPanel.treeElementVO.pageVO.id == treeElementPageVO.id )
						propertiesPanel.nameAttribute = treeElementPageVO.name;

					break;
				}

			}
		}

		private function updateAttributes() : void
		{
			propertiesPanel.treeElementVO = null;
			propertiesPanel.vdomObjectAttributesVO = null;

			if ( statesProxy.selectedPage )
				sendNotification( Notifications.GET_PAGE_ATTRIBUTES, { pageVO: statesProxy.selectedPage, recipientID: mediatorName } );
		}

		private function addHandlers() : void
		{
			propertiesPanel.addEventListener( PropertiesPanelEvent.SAVE_PAGE_NAME, savePageNameHandler, false, 0, true );
			propertiesPanel.addEventListener( PropertiesPanelEvent.SAVE_PAGE_ATTRIBUTES, savePageAttributesHandler, false, 0, true );
			propertiesPanel.addEventListener( PropertiesPanelEvent.MAKE_START_PAGE, makeStartPageHandler, false, 0, true );
			propertiesPanel.addEventListener( PropertiesPanelEvent.DELETE_PAGE, deletePageHandler, false, 0, true );
			propertiesPanel.addEventListener( AttributeEvent.SELECT_RESOURCE, selectResourceHandler, true, 0, true );

		}

		private function removeHandlers() : void
		{
			propertiesPanel.removeEventListener( PropertiesPanelEvent.SAVE_PAGE_NAME, savePageNameHandler );
			propertiesPanel.removeEventListener( PropertiesPanelEvent.SAVE_PAGE_ATTRIBUTES, savePageAttributesHandler );
			propertiesPanel.removeEventListener( PropertiesPanelEvent.MAKE_START_PAGE, makeStartPageHandler );
			propertiesPanel.removeEventListener( PropertiesPanelEvent.DELETE_PAGE, deletePageHandler );
			propertiesPanel.removeEventListener( AttributeEvent.SELECT_RESOURCE, selectResourceHandler, true );
		}

		private function clearData() : void
		{
		}

		private function savePageNameHandler( event : PropertiesPanelEvent ) : void
		{
			if ( propertiesPanel.treeElementVO && propertiesPanel.treeElementVO.pageVO )
			{
				sendNotification( Notifications.SET_PAGE_NAME, propertiesPanel.treeElementVO.pageVO );
			}
		}

		private function savePageAttributesHandler( event : PropertiesPanelEvent ) : void
		{
			if ( propertiesPanel.vdomObjectAttributesVO )
			{
				sendNotification( Notifications.SET_PAGE_ATTRIBUTES, propertiesPanel.vdomObjectAttributesVO );

				/*
				   sendNotification( Notifications.SET_PAGE_ATTRIBUTES,
				   { pageVO: propertiesPanel.vdomObjectAttributesVO.vdomObjectVO, pageAttributesVO:
				   propertiesPanel.vdomObjectAttributesVO,
				   recipientID: mediatorName } );
				 */
			}
		}

		private function makeStartPageHandler( event : PropertiesPanelEvent ) : void
		{
			sendNotification( Notifications.SET_APPLICATION_INFORMATION, { applicationVO: propertiesPanel.treeElementVO.pageVO.applicationVO, pageID: propertiesPanel.treeElementVO.pageVO.id } );
		}

		private function deletePageHandler( event : PropertiesPanelEvent ) : void
		{
			if ( propertiesPanel.treeElementVO && propertiesPanel.treeElementVO.pageVO )
				sendNotification( Notifications.DELETE_PAGE_REQUEST, propertiesPanel.treeElementVO.pageVO );
		}

		private function selectResourceHandler( event : AttributeEvent ) : void
		{
			var resourceSelector : ResourceSelector = event.target as ResourceSelector;

			if ( resourceSelector )
				sendNotification( Notifications.OPEN_RESOURCE_SELECTOR_REQUEST, resourceSelector );
		}
	}
}
