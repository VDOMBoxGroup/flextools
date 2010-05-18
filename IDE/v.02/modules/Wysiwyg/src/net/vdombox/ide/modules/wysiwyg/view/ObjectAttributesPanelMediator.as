package net.vdombox.ide.modules.wysiwyg.view
{
	import net.vdombox.ide.common.vo.ObjectAttributesVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageAttributesVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.AttributeEvent;
	import net.vdombox.ide.modules.wysiwyg.events.ObjectAttributesPanelEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
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

		private var sessionProxy : SessionProxy;
		
		private var isActive : Boolean;
		
		public function get objectAttributesPanel() : ObjectAttributesPanel
		{
			return viewComponent as ObjectAttributesPanel;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
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

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

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
			
			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;
			
			switch ( name )
			{
				case ApplicationFacade.BODY_START:
				{
					if ( sessionProxy.selectedApplication )
					{
						isActive = true;
						
						if( sessionProxy.selectedObject )
							sendNotification( ApplicationFacade.GET_OBJECT_ATTRIBUTES, sessionProxy.selectedObject );
						else if( sessionProxy.selectedPage )
							sendNotification( ApplicationFacade.GET_PAGE_ATTRIBUTES, sessionProxy.selectedPage );
						
						break;
					}
				}
					
				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;
					
					clearData();
					
					break;
				}
					
				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{
					if ( sessionProxy.selectedObject )
						sendNotification( ApplicationFacade.GET_OBJECT_ATTRIBUTES, sessionProxy.selectedObject );
					else if ( sessionProxy.selectedPage )
						sendNotification( ApplicationFacade.GET_PAGE_ATTRIBUTES, sessionProxy.selectedPage );
					else
						clearData();

					break;
				}

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					if ( sessionProxy.selectedPage )
						sendNotification( ApplicationFacade.GET_PAGE_ATTRIBUTES, sessionProxy.selectedPage );
					else
						clearData();

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
			objectAttributesPanel.addEventListener( ObjectAttributesPanelEvent.SAVE_REQUEST, saveRequestHandler, false, 0, true );
			objectAttributesPanel.addEventListener( ObjectAttributesPanelEvent.DELETE_REQUEST, deleteRequestHandler, false, 0, true );
			objectAttributesPanel.addEventListener( ObjectAttributesPanelEvent.CURRENT_ATTRIBUTE_CHANGED, currentAttributeChangedHandler, false, 0, true );
			objectAttributesPanel.addEventListener( AttributeEvent.SELECT_RESOURCE, selectResourceHandler, true, 0, true );
			objectAttributesPanel.addEventListener( AttributeEvent.OPEN_EXTERNAL, openExternalHandler, true, 0, true );
		}

		private function removeHandlers() : void
		{
			objectAttributesPanel.removeEventListener( ObjectAttributesPanelEvent.SAVE_REQUEST, saveRequestHandler )
			objectAttributesPanel.removeEventListener( ObjectAttributesPanelEvent.DELETE_REQUEST, deleteRequestHandler )
			objectAttributesPanel.addEventListener( ObjectAttributesPanelEvent.CURRENT_ATTRIBUTE_CHANGED, currentAttributeChangedHandler );
			objectAttributesPanel.removeEventListener( AttributeEvent.SELECT_RESOURCE, selectResourceHandler, true );
			objectAttributesPanel.removeEventListener( AttributeEvent.OPEN_EXTERNAL, openExternalHandler, true );
		}
		
		private function clearData() : void
		{
			objectAttributesPanel.attributesVO = null;
			objectAttributesPanel.saveButton.enabled = false;
			objectAttributesPanel.deleteButton.enabled = false;
		}
		
		private function saveRequestHandler( event : ObjectAttributesPanelEvent ) : void
		{
			var attributes : Array;
			
			if ( objectAttributesPanel.attributesVO is ObjectAttributesVO )
			{
				var objectAttributesVO : ObjectAttributesVO = objectAttributesPanel.attributesVO as ObjectAttributesVO;
				
				attributes = objectAttributesVO.getChangedAttributes();
				
				if( attributes && attributes.length > 0 )
					sendNotification( ApplicationFacade.SAVE_ATTRIBUTES_REQUEST, objectAttributesVO );
			}
			else if ( objectAttributesPanel.attributesVO is PageAttributesVO )
			{
				var pageAttributesVO : PageAttributesVO = objectAttributesPanel.attributesVO as PageAttributesVO;
				
				attributes = pageAttributesVO.getChangedAttributes();
				
				if( attributes && attributes.length > 0 )
					sendNotification( ApplicationFacade.SAVE_ATTRIBUTES_REQUEST, pageAttributesVO );
			}	
			
		}

		private function deleteRequestHandler( event : ObjectAttributesPanelEvent ) : void
		{
			if( sessionProxy.selectedPage && sessionProxy.selectedObject )
				sendNotification( ApplicationFacade.DELETE_OBJECT, { pageVO: sessionProxy.selectedPage, objectVO: sessionProxy.selectedObject } );
		}

		private function currentAttributeChangedHandler( event : ObjectAttributesPanelEvent ) : void
		{
			var attributeDescription : Object;
			
			try
			{
				attributeDescription = objectAttributesPanel.attributesList.selectedItem;
			}
			catch( error : Error )
			{
			}
			
			sendNotification( ApplicationFacade.CURRENT_ATTRIBUTE_CHANGED, attributeDescription );
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