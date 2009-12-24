package net.vdombox.ide.modules.applicationsManagment.view
{
	import flash.display.Loader;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.events.CreateApplicationViewEvent;
	import net.vdombox.ide.modules.applicationsManagment.model.vo.NewApplicationPropertiesVO;
	import net.vdombox.ide.modules.applicationsManagment.view.components.CreateApplicationView;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
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

		private var loader : Loader;

		public function get createApplication() : CreateApplicationView
		{
			return viewComponent as CreateApplicationView
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
			var newApplicationProperties : NewApplicationPropertiesVO = new NewApplicationPropertiesVO();
			var iconChooserMediator : IconChooserMediator = facade.retrieveMediator( IconChooserMediator.NAME ) as IconChooserMediator;
			
			newApplicationProperties.name = createApplication.nameField.text;
			newApplicationProperties.description = createApplication.descriptionField.text;
			
			if( iconChooserMediator.selectedIcon )
				newApplicationProperties.icon = iconChooserMediator.selectedIcon;
			else
				newApplicationProperties.icon = iconChooserMediator.defaultIcon;

			sendNotification( ApplicationFacade.CREATE_NEW_APP_SUBMITTED, newApplicationProperties );
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