package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.AttributeVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.common.view.components.VDOMImage;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.AttributeEvent;
	import net.vdombox.ide.modules.wysiwyg.events.ObjectAttributesPanelEvent;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.AttributeBase;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.ResourceSelector;
	import net.vdombox.ide.modules.wysiwyg.view.components.panels.ObjectAttributesPanel;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.ResourceSelectorWindow;
	import net.vdombox.ide.modules.wysiwyg.view.skins.MultilineWindowSkin;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.RichEditableText;

	public class ObjectAttributesPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ObjectAttributesMediator";

		public function ObjectAttributesPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var statesProxy : StatesProxy;
		
		private var renderProxy : RenderProxy;

		private var isActive : Boolean;
		
		private var savedAttributesVO : VdomObjectAttributesVO;

		public function get objectAttributesPanel() : ObjectAttributesPanel
		{
			return viewComponent as ObjectAttributesPanel;
		}

		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			renderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;

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

			interests.push( StatesProxy.SELECTED_OBJECT_CHANGED );
			interests.push( StatesProxy.SELECTED_PAGE_CHANGED );

			interests.push( Notifications.PAGE_ATTRIBUTES_GETTED );
			interests.push( Notifications.OBJECT_ATTRIBUTES_GETTED );
			
			interests.push( Notifications.PAGE_NAME_SETTED );
			interests.push( Notifications.OBJECT_NAME_SETTED );
			
			interests.push( ApplicationFacade.MULTI_SELECT_START );
			interests.push( ApplicationFacade.MULTI_SELECT_END );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != Notifications.BODY_START )
				return;

			var vdomObjectAttributesVO : VdomObjectAttributesVO;
			
			var attributesRenderer : IList = new ArrayCollection();
			var attributeBase : Object;

			switch ( name )
			{
				case Notifications.BODY_START:
				{
					if ( statesProxy.selectedApplication )
					{
						isActive = true;

						if ( statesProxy.selectedObject )
							sendNotification( Notifications.GET_OBJECT_ATTRIBUTES, statesProxy.selectedObject );
						else if ( statesProxy.selectedPage )
							sendNotification( Notifications.GET_PAGE_ATTRIBUTES, statesProxy.selectedPage );

						break;
					}
				}

				case Notifications.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case StatesProxy.SELECTED_OBJECT_CHANGED:
				{
					if ( statesProxy.selectedObject )
						sendNotification( Notifications.GET_OBJECT_ATTRIBUTES, statesProxy.selectedObject );
					else if ( statesProxy.selectedPage )
						sendNotification( Notifications.GET_PAGE_ATTRIBUTES, statesProxy.selectedPage );
					else
						clearData();

					break;
				}

				case StatesProxy.SELECTED_PAGE_CHANGED:
				{
					if ( statesProxy.selectedPage  )
						sendNotification( Notifications.GET_PAGE_ATTRIBUTES, statesProxy.selectedPage );
					else
						clearData();

					break;
				}

				case Notifications.PAGE_ATTRIBUTES_GETTED:
				{
					if ( statesProxy.selectedObject )
						break;
					
					vdomObjectAttributesVO = body as VdomObjectAttributesVO;

					if ( statesProxy.selectedPage && vdomObjectAttributesVO &&
						statesProxy.selectedPage.id == vdomObjectAttributesVO.vdomObjectVO.id )
					{
						objectAttributesPanel.attributesVO = vdomObjectAttributesVO;
					}

					break;
				}

				case Notifications.OBJECT_ATTRIBUTES_GETTED:
				{
					vdomObjectAttributesVO = body as VdomObjectAttributesVO;

					if ( statesProxy.selectedObject && vdomObjectAttributesVO &&
						statesProxy.selectedObject.id == vdomObjectAttributesVO.vdomObjectVO.id )
					{
						objectAttributesPanel.attributesVO = vdomObjectAttributesVO;
					}

					break;
				}
					
				case Notifications.PAGE_NAME_SETTED:
				{
					objectAttributesPanel.attributesVO = objectAttributesPanel.attributesVO;
					break;
				}
					
				case Notifications.OBJECT_NAME_SETTED:
				{
					objectAttributesPanel.attributesVO = objectAttributesPanel.attributesVO;
					break;
				}
					
				case ApplicationFacade.MULTI_SELECT_START:
				{
					if ( objectAttributesPanel.attributesVO )
					{
					    savedAttributesVO = objectAttributesPanel.attributesVO.clone();
					    objectAttributesPanel.attributesVO = null;
					}
					break;
				}
					
				case ApplicationFacade.MULTI_SELECT_END:
				{
					objectAttributesPanel.attributesVO = savedAttributesVO;;
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			objectAttributesPanel.addEventListener( ObjectAttributesPanelEvent.SAVE_REQUEST, saveRequestHandler, true, 0, true );
			objectAttributesPanel.addEventListener( ObjectAttributesPanelEvent.DELETE_REQUEST, deleteRequestHandler, false, 0, true );
			objectAttributesPanel.addEventListener( ObjectAttributesPanelEvent.CURRENT_ATTRIBUTE_CHANGED, currentAttributeChangedHandler, true, 0,
				true );
			objectAttributesPanel.addEventListener( AttributeEvent.SELECT_RESOURCE, selectResourceHandler, true, 0, true );
			objectAttributesPanel.addEventListener( AttributeEvent.CHOSE_RESOURCES_IN_MULTILINE, getResourcesAndPagesHandler, true, 0, true );
			objectAttributesPanel.addEventListener( AttributeEvent.OPEN_EXTERNAL, openExternalHandler, true, 0, true );
			objectAttributesPanel.addEventListener( AttributeEvent.ERROR2, errorHandler, true, 0, true );
		}

		private function removeHandlers() : void
		{
			objectAttributesPanel.removeEventListener( ObjectAttributesPanelEvent.SAVE_REQUEST, saveRequestHandler, true );
			objectAttributesPanel.removeEventListener( ObjectAttributesPanelEvent.DELETE_REQUEST, deleteRequestHandler );
			objectAttributesPanel.removeEventListener( ObjectAttributesPanelEvent.CURRENT_ATTRIBUTE_CHANGED, currentAttributeChangedHandler, true );
			objectAttributesPanel.removeEventListener( AttributeEvent.SELECT_RESOURCE, selectResourceHandler, true );
			objectAttributesPanel.removeEventListener( AttributeEvent.CHOSE_RESOURCES_IN_MULTILINE, getResourcesAndPagesHandler, true );
			objectAttributesPanel.removeEventListener( AttributeEvent.OPEN_EXTERNAL, openExternalHandler, true );
			objectAttributesPanel.removeEventListener( AttributeEvent.ERROR2, errorHandler, true );
		}

		private function clearData() : void
		{
			objectAttributesPanel.attributesVO = null;
		}

		private function saveRequestHandler( event : ObjectAttributesPanelEvent ) : void
		{
			//objectAttributesPanel.attributesVO;
			var attributeRander : AttributeBase = event.target as AttributeBase;
			
			if ( objectAttributesPanel.attributesVO.vdomObjectVO )
			{
				var renderBase : RendererBase = renderProxy.getRendererByVO( objectAttributesPanel.attributesVO.vdomObjectVO );
				if ( renderBase && renderBase.editableComponent && renderBase.editableComponent is RichEditableText && renderBase.typeVO.name == "text" )
				{
					var attributeVO : AttributeVO;
					var attr : Array = objectAttributesPanel.attributesVO.attributes;
					for each ( attributeVO in attr )
					{
						if ( attributeVO.name == "value" )
						{
							attributeVO.value = renderBase.editableComponent.text;
							break;
						}
					}
				}
			}
			if ( attributeRander.objectVO )
				sendNotification( Notifications.SET_OBJECT_NAME, attributeRander.objectVO );
			else
				sendNotification( Notifications.SAVE_ATTRIBUTES_REQUEST, objectAttributesPanel.attributesVO );
		}

		private function deleteRequestHandler( event : ObjectAttributesPanelEvent ) : void
		{
			var componentName : String = statesProxy.selectedObject.typeVO.displayName;
			
			Alert.setPatametrs( "Delete", "Cancel", VDOMImage.Delete );
			
			Alert.Show( "Are you sure want to delete " + componentName + " ?",AlertButton.OK_No, objectAttributesPanel.parentApplication, closeHandler);
		}
		
		private function closeHandler(event : CloseEvent) : void
		{
			if (event.detail == Alert.YES)
			{
				if ( statesProxy.selectedPage && statesProxy.selectedObject )
					sendNotification( Notifications.DELETE_OBJECT, { pageVO: statesProxy.selectedPage, objectVO: statesProxy.selectedObject } );
			}
		}

		private function currentAttributeChangedHandler( event : ObjectAttributesPanelEvent ) : void
		{
			var attributeDescription : Object;

			try
			{
				attributeDescription = objectAttributesPanel.attributesList.selectedItem;
			}
			catch ( error : Error )
			{
			}

			sendNotification( Notifications.CURRENT_ATTRIBUTE_CHANGED, attributeDescription );
		}

		private function openExternalHandler( event : AttributeEvent ) : void
		{
			sendNotification( Notifications.OPEN_EXTERNAL_EDITOR_REQUEST, event.target );
		}
		
		private function errorHandler( event : AttributeEvent ) : void
		{
			sendNotification( Notifications.WRITE_ERROR, { applicationVO: statesProxy.selectedApplication, content: event.value } );
		}

		private function selectResourceHandler( event : AttributeEvent ) : void
		{
			var resourceSelector : ResourceSelector = event.target as ResourceSelector;
			var resourceSelectorWindow : ResourceSelectorWindow = new ResourceSelectorWindow();
			
			var resourceSelectorWindowMediator : ResourceSelectorWindowMediator = new ResourceSelectorWindowMediator( resourceSelectorWindow );
			
			facade.registerMediator( resourceSelectorWindowMediator );
				
			resourceSelectorWindow.value = resourceSelector.value;
				
			resourceSelectorWindow.addEventListener( Event.CHANGE, applyHandler);
				
			WindowManager.getInstance().addWindow(resourceSelectorWindow, UIComponent(resourceSelector.parentApplication), true);
				
			function applyHandler (event: Event):void
			{
				resourceSelector.value = (event.target as ResourceSelectorWindow).value;
//				resourceSelectorWindow.dispatchEvent( new ResourceVOEvent( ResourceVOEvent.CLOSE ) );
			}		
		}
		
		private function getResourcesAndPagesHandler( event : AttributeEvent ) : void
		{
			sendNotification( Notifications.GET_MULTILINE_RESOURCES, event.target );
		}
	}
}