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
	
	import net.vdombox.ide.common.model.vo.AttributeVO;
	import net.vdombox.ide.common.model.vo.ObjectVO;
	import net.vdombox.ide.common.model.vo.PageVO;
	import net.vdombox.ide.common.model.vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.AttributeEvent;
	import net.vdombox.ide.modules.wysiwyg.events.ObjectAttributesPanelEvent;
	import net.vdombox.ide.modules.wysiwyg.events.ResourceVOEvent;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.AttributeBase;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.ResourceSelector;
	import net.vdombox.ide.modules.wysiwyg.view.components.panels.ObjectAttributesPanel;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.ResourceSelectorWindow;
	import net.vdombox.ide.modules.wysiwyg.view.skins.MultilineWindowSkin;
	import net.vdombox.utils.WindowManager;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.common.view.AlertButton;
	
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

		private var sessionProxy : SessionProxy;
		
		private var renderProxy : RenderProxy;

		private var isActive : Boolean;

		public function get objectAttributesPanel() : ObjectAttributesPanel
		{
			return viewComponent as ObjectAttributesPanel;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
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

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );
			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );

			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_GETTED );
			interests.push( ApplicationFacade.OBJECT_ATTRIBUTES_GETTED );
			
			interests.push( ApplicationFacade.PAGE_NAME_SETTED );
			interests.push( ApplicationFacade.OBJECT_NAME_SETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;

			var vdomObjectAttributesVO : VdomObjectAttributesVO;
			
			var attributesRenderer : IList = new ArrayCollection();
			var attributeBase : Object;

			switch ( name )
			{
				case ApplicationFacade.BODY_START:
				{
					if ( sessionProxy.selectedApplication )
					{
						isActive = true;

						if ( sessionProxy.selectedObject )
							sendNotification( ApplicationFacade.GET_OBJECT_ATTRIBUTES, sessionProxy.selectedObject );
						else if ( sessionProxy.selectedPage )
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
					if ( sessionProxy.selectedPage  )
						sendNotification( ApplicationFacade.GET_PAGE_ATTRIBUTES, sessionProxy.selectedPage );
					else
						clearData();

					break;
				}

				case ApplicationFacade.PAGE_ATTRIBUTES_GETTED:
				{
					if ( sessionProxy.selectedObject )
						break;
					
					vdomObjectAttributesVO = body as VdomObjectAttributesVO;

					if ( sessionProxy.selectedPage && vdomObjectAttributesVO &&
						sessionProxy.selectedPage.id == vdomObjectAttributesVO.vdomObjectVO.id )
					{
						objectAttributesPanel.attributesVO = body as VdomObjectAttributesVO;
					}

					break;
				}

				case ApplicationFacade.OBJECT_ATTRIBUTES_GETTED:
				{
					vdomObjectAttributesVO = body as VdomObjectAttributesVO;

					if ( sessionProxy.selectedObject && vdomObjectAttributesVO &&
						sessionProxy.selectedObject.id == vdomObjectAttributesVO.vdomObjectVO.id )
					{
						objectAttributesPanel.attributesVO = vdomObjectAttributesVO;
					}

					break;
				}
					
				case ApplicationFacade.PAGE_NAME_SETTED:
				{
					objectAttributesPanel.attributesVO = objectAttributesPanel.attributesVO;
					break;
				}
					
				case ApplicationFacade.OBJECT_NAME_SETTED:
				{
					objectAttributesPanel.attributesVO = objectAttributesPanel.attributesVO;
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			objectAttributesPanel.addEventListener( ObjectAttributesPanelEvent.SAVE_REQUEST, saveRequestHandler, true, 0, true );
			objectAttributesPanel.addEventListener( ObjectAttributesPanelEvent.DELETE_REQUEST, deleteRequestHandler, false, 0, true );
			objectAttributesPanel.addEventListener( ObjectAttributesPanelEvent.CURRENT_ATTRIBUTE_CHANGED, currentAttributeChangedHandler, false, 0,
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
			objectAttributesPanel.removeEventListener( ObjectAttributesPanelEvent.CURRENT_ATTRIBUTE_CHANGED, currentAttributeChangedHandler );
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
			if ( sessionProxy.selectedObject )
			{
				var renderBase : RendererBase = renderProxy.getRendererByVO( sessionProxy.selectedObject );
				if ( renderBase && renderBase.editableComponent && renderBase.editableComponent is RichEditableText && renderBase.typeVO.name == "text" )
				{
					var attributeVO : AttributeVO;
					for each ( attributeVO in objectAttributesPanel.attributesVO.attributes )
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
				sendNotification( ApplicationFacade.SET_OBJECT_NAME, attributeRander.objectVO );
			else
				sendNotification( ApplicationFacade.SAVE_ATTRIBUTES_REQUEST, objectAttributesPanel.attributesVO );
		}

		private function deleteRequestHandler( event : ObjectAttributesPanelEvent ) : void
		{
			var componentName : String = sessionProxy.selectedObject.typeVO.displayName;
			
			Alert.noLabel = "Cancel";
			Alert.yesLabel = "Delete";
			
			Alert.Show( "Are you sure want to delete " + componentName + " ?",AlertButton.OK_No, objectAttributesPanel.parentApplication, closeHandler);
		}
		
		private function closeHandler(event : CloseEvent) : void
		{
			if (event.detail == Alert.YES)
			{
				if ( sessionProxy.selectedPage && sessionProxy.selectedObject )
					sendNotification( ApplicationFacade.DELETE_OBJECT, { pageVO: sessionProxy.selectedPage, objectVO: sessionProxy.selectedObject } );
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

			sendNotification( ApplicationFacade.CURRENT_ATTRIBUTE_CHANGED, attributeDescription );
		}

		private function openExternalHandler( event : AttributeEvent ) : void
		{
			sendNotification( ApplicationFacade.OPEN_EXTERNAL_EDITOR_REQUEST, event.target );
		}
		
		private function errorHandler( event : AttributeEvent ) : void
		{
			sendNotification( ApplicationFacade.WRITE_ERROR, { applicationVO: sessionProxy.selectedApplication, content: event.value } );
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
			sendNotification( ApplicationFacade.GET_MULTILINE_RESOURCES, event.target );
		}
	}
}