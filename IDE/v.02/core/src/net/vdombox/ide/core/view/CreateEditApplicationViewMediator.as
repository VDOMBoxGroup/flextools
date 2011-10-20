//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.core.view
{
	import flash.utils.ByteArray;
	import mx.binding.utils.BindingUtils;
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.ApplicationManagerWindowEvent;
	import net.vdombox.ide.core.view.components.CreateEditApplicationView;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class CreateEditApplicationViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "CreateEditApplicationViewMediator";

		public function CreateEditApplicationViewMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var applicationInformationVO : ApplicationInformationVO;

		private var applicationVO : ApplicationVO;

		private var newApplicationInformation : Object;

		private var newIconResourceVO : ResourceVO;

		public function get createEditApplicationView() : CreateEditApplicationView
		{
			return viewComponent as CreateEditApplicationView;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			var resourceVO : ResourceVO;

			switch ( notification.getName() )
			{
				case ApplicationFacade.EDIT_APPLICATION_PROPERTY:
				{
					// if body "null" then cratin new Application

					createEditApplicationView.visible = true;
					createEditApplicationView.invalidateProperties();

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

//				case ApplicationFacade.CLOSE_APPLICATION_MANAGER:
//				{
//					facade.removeMediator( mediatorName );
//
//					break;
//				}

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
					createEditApplicationView.visible = false;
					sendNotification( ApplicationFacade.GET_APPLICATIONS_LIST );

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
//			interests.push( ApplicationFacade.CLOSE_APPLICATION_MANAGER );
			interests.push( ApplicationFacade.SERVER_APPLICATION_CREATED );
			interests.push( ApplicationFacade.APPLICATION_INFORMATION_UPDATED );

			return interests;
		}

		override public function onRegister() : void
		{
			facade.registerMediator( new IconChooserMediator( createEditApplicationView.iconChooser ) );

			addHandlers();
		}

		override public function onRemove() : void
		{
			facade.removeMediator( IconChooserMediator.NAME );

			removeHandlers();
		}

		private function addHandlers() : void
		{
			createEditApplicationView.addEventListener( ApplicationManagerWindowEvent.SAVE_INFORMATION, saveInformationHandler );
			createEditApplicationView.addEventListener( ApplicationManagerWindowEvent.CANCEL, cancelInformationHandler );
		}

		private function cancelInformationHandler( event : ApplicationManagerWindowEvent ) : void
		{
			createEditApplicationView.visible = false;

			sendNotification( ApplicationFacade.GET_APPLICATIONS_LIST );
		}

		private function commitProperties() : void
		{
			if ( applicationVO )
			{
				createEditApplicationView.txtapplicationName.text = applicationVO.name;
				createEditApplicationView.txtapplicationDescription.text = applicationVO.description;

				if ( applicationVO.scriptingLanguage == "python" )
					createEditApplicationView.python.selected = true;
				else
					createEditApplicationView.vbscript.selected = true;

				createEditApplicationView.iconChooser.selectedIcon.source = null;

				if ( applicationVO.iconID )
				{
					var resourceVO : ResourceVO = new ResourceVO( applicationVO.id );
					resourceVO.setID( applicationVO.iconID );

					sendNotification( ApplicationFacade.LOAD_RESOURCE, { resourceVO: resourceVO, recipientKey: mediatorName } );
				}
			}
			else
			{
				createEditApplicationView.txtapplicationName.text = "";
				createEditApplicationView.txtapplicationDescription.text = "";
				createEditApplicationView.iconChooser.selectedIcon.source = null;

				createEditApplicationView.python.selected = true;
				createEditApplicationView.vbscript.selected = false;
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

			appInfVO.name = createEditApplicationView.txtapplicationName.text;
			appInfVO.description = createEditApplicationView.txtapplicationDescription.text;
			appInfVO.scriptingLanguage = createEditApplicationView.languageRBGroup.selectedValue.toString();

			return appInfVO;
		}

		private function get iconChooserMediator() : IconChooserMediator
		{
			return facade.retrieveMediator( IconChooserMediator.NAME ) as IconChooserMediator;
		}

		private function removeHandlers() : void
		{
			createEditApplicationView.removeEventListener( ApplicationManagerWindowEvent.SAVE_INFORMATION, saveInformationHandler );
			createEditApplicationView.removeEventListener( ApplicationManagerWindowEvent.CANCEL, cancelInformationHandler );
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
			createEditApplicationView.iconChooser.selectedIcon.source = value;
		}
	}
}