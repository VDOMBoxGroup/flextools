package net.vdombox.ide.modules.applicationsManagment.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.events.CreateApplicationViewEvent;
	import net.vdombox.ide.modules.applicationsManagment.view.components.CreateApplicationView;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.TextInput;
	import spark.events.TextOperationEvent;

	public class CreateApplicationViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "CreateApplicationMediator";

		public function CreateApplicationViewMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var newApplicationInformation : Object;

		private var createdApplicationVO : ApplicationVO;

		private var applicationIconResourceVO : ResourceVO;

		public function get createApplication() : CreateApplicationView
		{
			return viewComponent as CreateApplicationView
		}

		override public function onRegister() : void
		{
			initProperties();
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
			resetProperties();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.APPLICATION_CREATED );
			interests.push( ApplicationFacade.RESOURCE_SETTED );
			interests.push( ApplicationFacade.APPLICATION_EDITED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case ApplicationFacade.APPLICATION_CREATED:
				{
					createdApplicationVO = notification.getBody() as ApplicationVO;

					applicationIconResourceVO = new ResourceVO( createdApplicationVO.id );

					applicationIconResourceVO.setData( newApplicationInformation.icon );
					applicationIconResourceVO.setType( "png" );
					applicationIconResourceVO.name = "Application Icon";

					sendNotification( ApplicationFacade.SET_RESOURCE, applicationIconResourceVO );
					sendNotification(ApplicationFacade.CREATE_PAGE_REQUEST, createdApplicationVO );
					break;
				}

				case ApplicationFacade.RESOURCE_SETTED:
				{
					var resourceVO : ResourceVO = notification.getBody() as ResourceVO;

					if ( !resourceVO || applicationIconResourceVO != resourceVO )
						return;

					applicationIconResourceVO = null;

					var applicationInformationVO : ApplicationInformationVO = new ApplicationInformationVO();
					applicationInformationVO.iconID = resourceVO.id;

					sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION, { applicationVO: createdApplicationVO,
										  applicationInformationVO: applicationInformationVO } );
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_EDITED:
				{
					var applicationVO : ApplicationVO = notification.getBody() as ApplicationVO;
					
					if ( applicationVO == createdApplicationVO )
					{
						createdApplicationVO = null;
						sendNotification( ApplicationFacade.CREATE_NEW_APP_COMPLETE, applicationVO );
					}
				}
			}
		}
		
		private function initProperties() : void
		{
			newApplicationInformation = {};
		}
		
		private function resetProperties() : void
		{
			createdApplicationVO = null;
			applicationIconResourceVO = null;
		}
		
		private function addHandlers() : void
		{
			createApplication.addEventListener( FlexEvent.ADD, addHandler );
			createApplication.addEventListener( FlexEvent.REMOVE, removeHandler );

			createApplication.addEventListener( CreateApplicationViewEvent.SAVE, saveHandler );
			createApplication.addEventListener( CreateApplicationViewEvent.CANCEL, cancelHandler );
		}

		private function removeHandlers() : void
		{
			createApplication.removeEventListener( FlexEvent.ADD, addHandler );
			createApplication.removeEventListener( FlexEvent.REMOVE, removeHandler );

			createApplication.removeEventListener( CreateApplicationViewEvent.SAVE, saveHandler );
			createApplication.removeEventListener( CreateApplicationViewEvent.CANCEL, cancelHandler );
		}

		private function addHandler( event : FlexEvent ) : void
		{
			if ( facade.hasMediator( IconChooserMediator.NAME ) )
				facade.removeMediator( IconChooserMediator.NAME );

			facade.registerMediator( new IconChooserMediator( createApplication.iconChooser ) );

			createApplication.nameField.addEventListener( TextOperationEvent.CHANGE, nameField_changeHandler );
		}

		private function removeHandler( event : FlexEvent ) : void
		{
			facade.removeMediator( IconChooserMediator.NAME );

			createApplication.nameField.removeEventListener( TextOperationEvent.CHANGE, nameField_changeHandler );
		}

		private function saveHandler( event : CreateApplicationViewEvent ) : void
		{
			newApplicationInformation.name = createApplication.nameField.text;
			newApplicationInformation.description = createApplication.descriptionField.text;

			var iconChooserMediator : IconChooserMediator = facade.retrieveMediator( IconChooserMediator.NAME ) as IconChooserMediator;

			if ( iconChooserMediator.selectedIcon )
				newApplicationInformation.icon = iconChooserMediator.selectedIcon;
			else
				newApplicationInformation.icon = iconChooserMediator.defaultIcon;


			var applicationInformationVO : ApplicationInformationVO = new ApplicationInformationVO();

			applicationInformationVO.name = newApplicationInformation.name;
			applicationInformationVO.description = newApplicationInformation.description;
			applicationInformationVO.scriptingLanguage = createApplication.languageGroup.selectedValue.toString();

			if ( newApplicationInformation.hasOwnProperty( "name" ) )
				sendNotification( ApplicationFacade.CREATE_APPLICATION, applicationInformationVO );
		}

		private function cancelHandler( event : CreateApplicationViewEvent ) : void
		{
			sendNotification( ApplicationFacade.CREATE_NEW_APP_CANCELED );
		}

		private function nameField_changeHandler( event : TextOperationEvent ) : void
		{
			var nameField : TextInput = event.currentTarget as TextInput;

			if ( nameField.text == "" && createApplication.saveButton.enabled )
				createApplication.saveButton.enabled = false;
			else if ( nameField.text != "" && !createApplication.saveButton.enabled )
				createApplication.saveButton.enabled = true;

		}
	}
}