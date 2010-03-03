package net.vdombox.ide.modules.wysiwyg.view
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.AttributeEvent;
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectAttributesPanel;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ObjectAttributesPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ObjectAttributesMediator";

		public function ObjectAttributesPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var selectedPageVO : PageVO;
		private var selectedObjectVO : ObjectVO;

		public function get objectAttributesPanel() : ObjectAttributesPanel
		{
			return viewComponent as ObjectAttributesPanel;
		}

		override public function onRegister() : void
		{
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.MODULE_DESELECTED );

			interests.push( ApplicationFacade.PAGE_SELECTED );
			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );
			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );

			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_GETTED );
			interests.push( ApplicationFacade.OBJECT_ATTRIBUTES_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.MODULE_DESELECTED:
				{
					objectAttributesPanel.attributesVO = null;
					objectAttributesPanel.saveButton.enabled = false;
					objectAttributesPanel.deleteButton.enabled = false;

					break;
				}

				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{
					selectedObjectVO = body as ObjectVO;

					if ( selectedObjectVO )
					{
						sendNotification( ApplicationFacade.GET_OBJECT_ATTRIBUTES, selectedObjectVO );
					}
					else if ( selectedPageVO )
					{
						sendNotification( ApplicationFacade.GET_PAGE_ATTRIBUTES, selectedPageVO );
					}
					else
					{
						objectAttributesPanel.attributesVO = null;
						objectAttributesPanel.saveButton.enabled = false;
						objectAttributesPanel.deleteButton.enabled = false;
					}

					break;
				}

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					selectedPageVO = body as PageVO;

					sendNotification( ApplicationFacade.GET_PAGE_ATTRIBUTES, selectedPageVO );

					break;
				}

				case ApplicationFacade.PAGE_ATTRIBUTES_GETTED:
				{
					objectAttributesPanel.saveButton.enabled = true;
					objectAttributesPanel.deleteButton.enabled = false;
					objectAttributesPanel.attributesVO = body;

					break;
				}

				case ApplicationFacade.OBJECT_ATTRIBUTES_GETTED:
				{
					objectAttributesPanel.saveButton.enabled = true;
					objectAttributesPanel.deleteButton.enabled = true;
					objectAttributesPanel.attributesVO = body;

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			objectAttributesPanel.addEventListener( AttributeEvent.SELECT_RESOURCE, selectResourceHandler, true, 0, true );
			objectAttributesPanel.addEventListener( AttributeEvent.OPEN_EXTERNAL, openExternalHandler, true, 0, true );
		}

		private function removeHandlers() : void
		{
			objectAttributesPanel.removeEventListener( AttributeEvent.SELECT_RESOURCE, selectResourceHandler, true );
			objectAttributesPanel.removeEventListener( AttributeEvent.OPEN_EXTERNAL, openExternalHandler, true );
		}

		
		private function openExternalHandler( event : AttributeEvent ) : void
		{
			sendNotification( ApplicationFacade.OPEN_EXTERNAL_EDITOR_REQUEST, event.target );
		}
		
		private function selectResourceHandler( event : AttributeEvent ) : void
		{
			sendNotification( ApplicationFacade.OPEN_RESOURCE_SELECTOR_REQUEST, event.target );
		}
	}
}