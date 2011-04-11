package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.events.AttributeEvent;
	import net.vdombox.ide.modules.tree.events.PropertiesPanelEvent;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
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

		private var sessionProxy : SessionProxy;

		private var isActive : Boolean;

		public function get propertiesPanel() : PropertiesPanel
		{
			return viewComponent as PropertiesPanel;
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

			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );

			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_GETTED + ApplicationFacade.DELIMITER + mediatorName );
			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_SETTED + ApplicationFacade.DELIMITER + mediatorName );
			
			interests.push( ApplicationFacade.APPLICATION_INFORMATION_SETTED );

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
						updateAttributes();
						
						break;
					}
				}

				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					updateAttributes();

					break;
				}

				case ApplicationFacade.PAGE_ATTRIBUTES_GETTED + ApplicationFacade.DELIMITER + mediatorName:
				{
					propertiesPanel.vdomObjectAttributesVO = body as VdomObjectAttributesVO;

					if ( sessionProxy.selectedTreeElement && sessionProxy.selectedTreeElement.resourceVO &&
						sessionProxy.selectedTreeElement.resourceVO.id && !sessionProxy.selectedTreeElement.resourceVO.data )
					{
						sendNotification( ApplicationFacade.LOAD_RESOURCE, { resourceVO : sessionProxy.selectedTreeElement.resourceVO } )
					}
						propertiesPanel.treeElementVO = sessionProxy.selectedTreeElement;

					break;
				}

				case ApplicationFacade.PAGE_ATTRIBUTES_SETTED + ApplicationFacade.DELIMITER + mediatorName:
				{
					trace("PAGE_ATTRIBUTES_SETTED")
					propertiesPanel.vdomObjectAttributesVO = body as VdomObjectAttributesVO;

					break;
				}
					
				case ApplicationFacade.APPLICATION_INFORMATION_SETTED:
				{
					var applicationVO : ApplicationVO = body as ApplicationVO;
					
					if( !propertiesPanel.treeElementVO )
						return;
					
					if( applicationVO && propertiesPanel.treeElementVO.pageVO && propertiesPanel.treeElementVO.pageVO.id == applicationVO.indexPageID )
						propertiesPanel.makeStartButton.enabled = false;
					else
						propertiesPanel.makeStartButton.enabled = true;
					
					break;
				}
			}
		}
		
		private function updateAttributes():void
		{
			propertiesPanel.treeElementVO = null;
			propertiesPanel.vdomObjectAttributesVO = null
			
			if ( sessionProxy.selectedPage )
				sendNotification( ApplicationFacade.GET_PAGE_ATTRIBUTES, { pageVO: sessionProxy.selectedPage, recipientID: mediatorName } );
		}

		private function addHandlers() : void
		{
			propertiesPanel.addEventListener( PropertiesPanelEvent.SAVE_PAGE_ATTRIBUTES, savePageAttributesHandler, false, 0, true );
			propertiesPanel.addEventListener( PropertiesPanelEvent.MAKE_START_PAGE, makeStartPageHandler, false, 0, true );
			propertiesPanel.addEventListener( PropertiesPanelEvent.DELETE_PAGE, deletePageHandler, false, 0, true );
			propertiesPanel.addEventListener( AttributeEvent.SELECT_RESOURCE, selectResourceHandler, true, 0, true );

		}

		private function removeHandlers() : void
		{
			propertiesPanel.removeEventListener( PropertiesPanelEvent.SAVE_PAGE_ATTRIBUTES, savePageAttributesHandler );
			propertiesPanel.removeEventListener( PropertiesPanelEvent.MAKE_START_PAGE, makeStartPageHandler );
			propertiesPanel.removeEventListener( PropertiesPanelEvent.DELETE_PAGE, deletePageHandler );
			propertiesPanel.removeEventListener( AttributeEvent.SELECT_RESOURCE, selectResourceHandler, true );
		}

		private function clearData() : void
		{
		}

		private function savePageAttributesHandler( event : PropertiesPanelEvent ) : void
		{
			if ( propertiesPanel.vdomObjectAttributesVO )
			{
				sendNotification( ApplicationFacade.SET_PAGE_ATTRIBUTES,
					propertiesPanel.vdomObjectAttributesVO);
				
				/*sendNotification( ApplicationFacade.SET_PAGE_ATTRIBUTES,
					{ pageVO: propertiesPanel.vdomObjectAttributesVO.vdomObjectVO, pageAttributesVO: propertiesPanel.vdomObjectAttributesVO,
						recipientID: mediatorName } );*/
			}
		}

		private function makeStartPageHandler( event : PropertiesPanelEvent ) : void
		{
			var applicationVO : ApplicationVO; 
				
				try
				{
					applicationVO = propertiesPanel.treeElementVO.pageVO.applicationVO;
				}
				catch( error : Error )
				{}
			
			if( applicationVO )
			{
				var applicationInformationVO : ApplicationInformationVO = new ApplicationInformationVO();
				
				applicationInformationVO.indexPageID = propertiesPanel.treeElementVO.pageVO.id;
				
				applicationInformationVO.name = applicationVO.name;
				applicationInformationVO.description = applicationVO.description;
				applicationInformationVO.iconID = applicationVO.iconID;
				applicationInformationVO.scriptingLanguage = applicationVO.scriptingLanguage;
				
				sendNotification( ApplicationFacade.SET_APPLICATION_INFORMATION, { applicationVO : applicationVO, applicationInformationVO : applicationInformationVO } );
			}
				
		}

		private function deletePageHandler( event : PropertiesPanelEvent ) : void
		{
			if ( propertiesPanel.treeElementVO && propertiesPanel.treeElementVO.pageVO )
				sendNotification( ApplicationFacade.DELETE_PAGE_REQUEST, propertiesPanel.treeElementVO.pageVO );
		}

		private function selectResourceHandler( event : AttributeEvent ) : void
		{
			var resourceSelector : ResourceSelector = event.target as ResourceSelector;

			if ( resourceSelector )
				sendNotification( ApplicationFacade.OPEN_RESOURCE_SELECTOR_REQUEST, resourceSelector );
		}
	}
}