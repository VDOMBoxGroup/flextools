//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.core.view
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Image;
	import mx.events.FlexEvent;
	import mx.utils.ObjectUtil;
	
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.ApplicationManagerEvent;
	import net.vdombox.ide.core.events.IconChooserEvent;
	import net.vdombox.ide.core.model.GalleryProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.vo.GalleryItemVO;
	import net.vdombox.ide.core.view.components.ApplicationPropertiesView;
	import net.vdombox.ide.core.view.components.ApplicationsIconsChoosWindow;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	public class ApplicationPropertiesViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "CreateEditApplicationViewMediator";

		public function ApplicationPropertiesViewMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var _applicationVO : ApplicationVO;

		private var _applicationInformationVO : ApplicationInformationVO;

		private  var applicationsIconsChoosWindow : ApplicationsIconsChoosWindow;
		
		private var iconChanged : Boolean = false;

		private var newApplicationInformation : Object;

//		private var newIconResourceVO : ResourceVO;


		public function get applicationPropertiesView() : ApplicationPropertiesView
		{
			return viewComponent as ApplicationPropertiesView;
		}

		
		
		public function get applicationVO() : ApplicationVO
		{
			return _applicationVO;
		}

		public function set applicationVO( value : ApplicationVO ) : void
		{
			_applicationVO = value;
			
			iconChanged = false;
			
			commitProperties();
			
			setApplicationIcon();
		}
		
		public function get defaultIcon() : ByteArray
		{
			var galleryItemVO : GalleryItemVO = galleryProxy.items[0] as GalleryItemVO;
			
			return ObjectUtil.copy( galleryItemVO.content ) as ByteArray;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			var resourceVO : ResourceVO;

			switch ( notification.getName() )
			{

				case ApplicationFacade.OPEN_APPLICATIONS_VIEW:
				{
					applicationPropertiesView.visible = false;

					break;
				}

				case ApplicationFacade.OPEN_APPLICATION_PROPERTY_VIEW:
				{
					applicationPropertiesView.visible = true;

					applicationVO = body as ApplicationVO;

					break;
				}

				case ApplicationFacade.RESOURCE_SETTED:
				{
					resourceVO = body as ResourceVO;

//					newIconResourceVO = null;

					var newApplicationInformationVO : ApplicationInformationVO = applicationInformationVO;
					
					newApplicationInformationVO.iconID = resourceVO.id;

					sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION, { applicationVO: applicationVO,
											  applicationInformationVO: newApplicationInformationVO } );

					break;
				}

				case ApplicationFacade.SERVER_APPLICATION_CREATED:
				{
					applicationVO =  body as ApplicationVO;

					sendNotification( ApplicationFacade.SET_RESOURCE, newResourceVO );
					
					sendNotification( ApplicationFacade.CREATE_FIRST_PAGE, applicationVO );

					break
				}

				case ApplicationFacade.APPLICATION_INFORMATION_UPDATED:
				{
					applicationVO =  body as ApplicationVO
					sendNotification( ApplicationFacade.OPEN_APPLICATIONS_VIEW, applicationVO );
					
					applicationVO = null;

					break
				}
			}

		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.OPEN_APPLICATION_PROPERTY_VIEW );

			interests.push( ApplicationFacade.RESOURCE_SETTED );

			interests.push( ApplicationFacade.OPEN_APPLICATIONS_VIEW );

			interests.push( ApplicationFacade.SERVER_APPLICATION_CREATED );

			interests.push( ApplicationFacade.APPLICATION_INFORMATION_UPDATED );

			return interests;
		}

		override public function onRegister() : void
		{
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		private function addHandlers() : void
		{
			applicationPropertiesView.addEventListener( ApplicationManagerEvent.CANCEL, cancelInformationHandler );

			applicationPropertiesView.addEventListener( ApplicationManagerEvent.SAVE_INFORMATION, saveInformationHandler );
			
			applicationPropertiesView.selectIcon.addEventListener(MouseEvent.CLICK, openIconListHandler);
		}
		
		private function cancelInformationHandler( event : ApplicationManagerEvent ) : void
		{
			canselView();
		}

		private function canselView() : void
		{
			if ( serverProxy.applications.length > 0 )
				sendNotification( ApplicationFacade.OPEN_APPLICATIONS_VIEW );
			else
				NativeApplication.nativeApplication.exit();
		}
		
		private function closeIconListHandler( event : Event ) : void
		{			
			applicationsIconsChoosWindow.removeEventListener( Event.CLOSE, closeIconListHandler );
			
			applicationsIconsChoosWindow.removeEventListener( IconChooserEvent.SELECT_ICON, selectIconHandler );
			
			applicationsIconsChoosWindow.removeEventListener( FlexEvent.CREATION_COMPLETE, createCompleteIconListHandler );
		}

		private function commitProperties() : void
		{
			applicationPropertiesView.txtapplicationName.text = applicationVO ? applicationVO.name : "";
			applicationPropertiesView.txtapplicationDescription.text = applicationVO ? applicationVO.description : "";
			
			if ( applicationVO && applicationVO.scriptingLanguage == "python" )
				applicationPropertiesView.python.selected = true;
			else
				applicationPropertiesView.vscript.selected = true;
			
			// set icon 
			applicationPropertiesView.iconChooser.source = defaultIcon;
		}
		
		
		private function setApplicationIcon() : void
		{
			if ( !applicationVO )
				return;
				
			if ( !applicationVO.iconID )
				return;
			
			var resourceVO : ResourceVO = new ResourceVO( applicationVO.id );;
			
			resourceVO.setID( applicationVO.iconID );
			applicationPropertiesView.iconChooser.resourceVO = resourceVO;

			sendNotification( ApplicationFacade.LOAD_RESOURCE, { resourceVO: resourceVO, recipientKey: mediatorName } );
		}
		
		private function createCompleteIconListHandler( event : FlexEvent ) : void
		{	
			applicationsIconsChoosWindow.dataProvider =  galleryProxy.items;
		}

		private function get newResourceVO( ) : ResourceVO
		{
			var icon : ByteArray = applicationPropertiesView.iconChooser.source  as ByteArray;
			var resourceVO : ResourceVO = new ResourceVO( applicationVO.id );

			resourceVO.name = "Application Icon";
			resourceVO.setData( icon );
			resourceVO.setType( "png" );

			return resourceVO;
		}
		
		private function get galleryProxy() : GalleryProxy
		{
			return facade.retrieveProxy( GalleryProxy.NAME ) as GalleryProxy;
		}

		
		private function openIconListHandler( event : MouseEvent ) : void
		{
			applicationsIconsChoosWindow = new ApplicationsIconsChoosWindow();
			
			applicationsIconsChoosWindow.addEventListener( Event.CLOSE, closeIconListHandler, false, 0, true );
			
			applicationsIconsChoosWindow.addEventListener( IconChooserEvent.SELECT_ICON, selectIconHandler, false, 0, true );
			
			applicationsIconsChoosWindow.addEventListener( FlexEvent.CREATION_COMPLETE, createCompleteIconListHandler, false, 0, true );
			
			
			WindowManager.getInstance().addWindow( applicationsIconsChoosWindow, applicationPropertiesView, true );
		}

		private function removeHandlers() : void
		{
			applicationPropertiesView.removeEventListener( ApplicationManagerEvent.SAVE_INFORMATION, saveInformationHandler );
			applicationPropertiesView.removeEventListener( ApplicationManagerEvent.CANCEL, cancelInformationHandler );
		}

		private function saveInformationHandler( event : ApplicationManagerEvent ) : void
		{
			var newAppIcon : ByteArray;

			if ( applicationInformationVO.name == "" )
				return;

			// if is editing of  applicationVO
			if ( applicationVO )
			{
				//Icon
				if ( iconChanged )
					sendNotification( ApplicationFacade.SET_RESOURCE, newResourceVO );
				else
					sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION, { applicationVO: applicationVO,
										  applicationInformationVO: applicationInformationVO } );
			}
			else // creating new applicationVO
			{
				sendNotification( ApplicationFacade.CREATE_APPLICATION, applicationInformationVO );
			}
		}
		
		
		
		private function selectIconHandler(event : IconChooserEvent) : void
		{
			iconChanged = true;

			applicationPropertiesView.iconChooser.source = applicationsIconsChoosWindow.imageSource
		}

		private function get serverProxy() : ServerProxy
		{
			return facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
		}


		private function get applicationInformationVO():ApplicationInformationVO
		{
			var appInfVO : ApplicationInformationVO = new ApplicationInformationVO();
			
			appInfVO.name = applicationPropertiesView.txtapplicationName.text;
			appInfVO.description = applicationPropertiesView.txtapplicationDescription.text;
			appInfVO.scriptingLanguage = applicationPropertiesView.languageRBGroup.selectedValue.toString();
			
			return appInfVO;
		}
	}
}
