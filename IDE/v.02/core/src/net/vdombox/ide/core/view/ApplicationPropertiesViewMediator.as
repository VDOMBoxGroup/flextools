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
	import flash.utils.ByteArray;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Image;
	import mx.utils.ObjectUtil;
	
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.ApplicationManagerEvent;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.view.components.ApplicationPropertiesView;
	
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

		private var applicationInformationVO : ApplicationInformationVO;

		private var newApplicationInformation : Object;

		private var newIconResourceVO : ResourceVO;

		private var resourceVO : ResourceVO;

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

			commitProperties();
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

				case ApplicationFacade.EDIT_APPLICATION_PROPERTY:
				{
					applicationPropertiesView.visible = true;

					applicationVO = body as ApplicationVO;

					break;
				}

				case ApplicationFacade.RESOURCE_SETTED:
				{
					resourceVO = body as ResourceVO;

					if ( resourceVO.id == newIconResourceVO.id )
					{
						newIconResourceVO = null;

						applicationInformationVO.iconID = resourceVO.id;

						sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION, { applicationVO: applicationVO,
											  applicationInformationVO: applicationInformationVO } );

						applicationInformationVO = null;
					}

					break;
				}

				case ApplicationFacade.SERVER_APPLICATION_CREATED:
				{
					applicationVO =  body as ApplicationVO
					newIconResourceVO = createIconResourceVO( applicationsIcon.source as ByteArray );

					sendNotification( ApplicationFacade.SET_RESOURCE, newIconResourceVO );
					sendNotification( ApplicationFacade.CREATE_FIRST_PAGE, applicationVO );

					break
				}

				case ApplicationFacade.APPLICATION_INFORMATION_UPDATED:
				{
					sendNotification( ApplicationFacade.OPEN_APPLICATIONS_VIEW );

					break
				}
			}

		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.EDIT_APPLICATION_PROPERTY );

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
		}

		private function get applicationsIcon() : Image
		{
			return applicationPropertiesView.iconChooser.icon;
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

		private function commitProperties() : void
		{
			if ( applicationVO )
				setApplicationVOValue();
			else
				setVoidValue();
		}

		private function createIconResourceVO( icon : ByteArray ) : ResourceVO
		{
			var resourceVO : ResourceVO = new ResourceVO( applicationVO.id );

			resourceVO.name = "Application Icon";
			resourceVO.setData( icon );
			resourceVO.setType( "png" );

			return resourceVO;
		}

		private function getApplicationInformationVO() : ApplicationInformationVO
		{
			var appInfVO : ApplicationInformationVO = new ApplicationInformationVO();

			appInfVO.name = applicationPropertiesView.txtapplicationName.text;
			appInfVO.description = applicationPropertiesView.txtapplicationDescription.text;
			appInfVO.scriptingLanguage = applicationPropertiesView.languageRBGroup.selectedValue.toString();

			return appInfVO;
		}

		private function get iconChooserMediator() : ApplicationsIconViewMediator
		{
			return facade.retrieveMediator( ApplicationsIconViewMediator.NAME ) as ApplicationsIconViewMediator;
		}

		private function removeHandlers() : void
		{
			applicationPropertiesView.removeEventListener( ApplicationManagerEvent.SAVE_INFORMATION, saveInformationHandler );
			applicationPropertiesView.removeEventListener( ApplicationManagerEvent.CANCEL, cancelInformationHandler );
		}

		private function saveInformationHandler( event : ApplicationManagerEvent ) : void
		{
			var newAppIcon : ByteArray;
			applicationInformationVO = getApplicationInformationVO();

			if ( applicationInformationVO.name == "" )
				return;

			// if is editing of  applicationVO
			if ( applicationVO )
			{
				//Icon
				if ( iconChooserMediator.iconChanged )
				{
					newIconResourceVO = createIconResourceVO( iconChooserMediator.selectedIcon );

					sendNotification( ApplicationFacade.SET_RESOURCE, newIconResourceVO );
				}
				else
				{
					sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION, { applicationVO: applicationVO,
										  applicationInformationVO: applicationInformationVO } );
				}
			}
			else // creating new applicationVO
			{
				sendNotification( ApplicationFacade.CREATE_APPLICATION, applicationInformationVO );
			}
		}

		private function get serverProxy() : ServerProxy
		{
			return facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
		}

		private function setApplicationVOValue() : void
		{
			applicationPropertiesView.txtapplicationName.text = applicationVO.name;
			applicationPropertiesView.txtapplicationDescription.text = applicationVO.description;

			if ( applicationVO.scriptingLanguage == "python" )
				applicationPropertiesView.python.selected = true;
			else
				applicationPropertiesView.vbscript.selected = true;

			// set icon 
			applicationPropertiesView.iconChooser.icon.source = null;

			if ( applicationVO.iconID )
			{
				resourceVO = new ResourceVO( applicationVO.id );
				resourceVO.setID( applicationVO.iconID );

				BindingUtils.bindSetter( setIcon, resourceVO, "data", false, true );
			}
		}

		private function setIcon( value : Object ) : void
		{
			if ( value )
				applicationsIcon.source = ObjectUtil.copy( value );
			else
				sendNotification( ApplicationFacade.LOAD_RESOURCE, { resourceVO: resourceVO, recipientKey: mediatorName } );
		}

		private function setVoidValue() : void
		{
			applicationPropertiesView.txtapplicationName.text = "";
			applicationPropertiesView.txtapplicationDescription.text = "";

			applicationsIcon.source = iconChooserMediator.defaultIcon;

			applicationPropertiesView.python.selected = true;
			applicationPropertiesView.vbscript.selected = false;
		}
	}
}
