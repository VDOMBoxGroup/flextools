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

	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.ApplicationManagerWindowEvent;
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

		private var applicationInformationVO : ApplicationInformationVO;

		private var applicationVO : ApplicationVO;

		private var newApplicationInformation : Object;

		private var newIconResourceVO : ResourceVO;

		public function get applicationPropertiesView() : ApplicationPropertiesView
		{
			return viewComponent as ApplicationPropertiesView;
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
					// if body "null" then cratin new Application

					applicationPropertiesView.visible = true;
					applicationPropertiesView.invalidateProperties();

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
					var newAppIcon : ByteArray;

					applicationVO = body as ApplicationVO;

					// get icon, selected or default
					newAppIcon = iconChooserMediator.selectedIcon ? iconChooserMediator.selectedIcon : iconChooserMediator.defaultIcon;

					newIconResourceVO = createIconResourceVO( newAppIcon );

					sendNotification( ApplicationFacade.SET_RESOURCE, newIconResourceVO );
					sendNotification( ApplicationFacade.CREATE_FIRST_PAGE, applicationVO );

					break
				}
				case ApplicationFacade.APPLICATION_INFORMATION_UPDATED:
				{
					applicationVO = null
//					applicationPropertiesView.visible = false;
					sendNotification( ApplicationFacade.OPEN_APPLICATIONS_VIEW );



					break
				}
			}
			commitProperties();
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
			facade.registerMediator( new IconChooserMediator( applicationPropertiesView.iconChooser ) );

			addHandlers();
		}

		override public function onRemove() : void
		{
			facade.removeMediator( IconChooserMediator.NAME );

			removeHandlers();
		}

		private function addHandlers() : void
		{
			applicationPropertiesView.addEventListener( ApplicationManagerWindowEvent.CANCEL, cancelInformationHandler );

			applicationPropertiesView.addEventListener( ApplicationManagerWindowEvent.SAVE_INFORMATION, saveInformationHandler );
		}

		private function cancelInformationHandler( event : ApplicationManagerWindowEvent ) : void
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

		private function get serverProxy() : ServerProxy
		{
			return facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
		}

		private function commitProperties() : void
		{
			if ( applicationVO )
			{
				applicationPropertiesView.txtapplicationName.text = applicationVO.name;
				applicationPropertiesView.txtapplicationDescription.text = applicationVO.description;

				if ( applicationVO.scriptingLanguage == "python" )
					applicationPropertiesView.python.selected = true;
				else
					applicationPropertiesView.vbscript.selected = true;

				applicationPropertiesView.iconChooser.selectedIcon.source = null;

				if ( applicationVO.iconID )
				{
					var resourceVO : ResourceVO = new ResourceVO( applicationVO.id );
					resourceVO.setID( applicationVO.iconID );

					sendNotification( ApplicationFacade.LOAD_RESOURCE, { resourceVO: resourceVO, recipientKey: mediatorName } );
				}
			}
			else
			{
				applicationPropertiesView.txtapplicationName.text = "";
				applicationPropertiesView.txtapplicationDescription.text = "";
				applicationPropertiesView.iconChooser.selectedIcon.source = null;

				applicationPropertiesView.python.selected = true;
				applicationPropertiesView.vbscript.selected = false;
			}

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

		private function get iconChooserMediator() : IconChooserMediator
		{
			return facade.retrieveMediator( IconChooserMediator.NAME ) as IconChooserMediator;
		}

		private function removeHandlers() : void
		{
			applicationPropertiesView.removeEventListener( ApplicationManagerWindowEvent.SAVE_INFORMATION, saveInformationHandler );
			applicationPropertiesView.removeEventListener( ApplicationManagerWindowEvent.CANCEL, cancelInformationHandler );
		}

		private function saveInformationHandler( event : ApplicationManagerWindowEvent ) : void
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

		private function setIcon( value : * ) : void
		{
			applicationPropertiesView.iconChooser.selectedIcon.source = value;
		}
	}
}
