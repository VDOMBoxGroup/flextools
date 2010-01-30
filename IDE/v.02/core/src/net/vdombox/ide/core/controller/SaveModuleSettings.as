package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.SimpleMessage;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.SettingsStorageProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SaveModuleSettings extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var settingsStorageProxy : SettingsStorageProxy = facade.retrieveProxy( SettingsStorageProxy.NAME ) as SettingsStorageProxy;

			var simpleMessage : SimpleMessage = notification.getBody() as SimpleMessage;

			settingsStorageProxy.saveSettings( simpleMessage.getRecipientKey(), simpleMessage.getBody());
			
			simpleMessage.setAnswerFlag( true )
			sendNotification( ApplicationFacade.MODULE_SETTINGS_SETTED, simpleMessage );
		}
	}
}