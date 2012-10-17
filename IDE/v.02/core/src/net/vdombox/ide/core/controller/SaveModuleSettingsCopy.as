package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.SettingsStorageProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SaveModuleSettingsCopy extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var settingsStorageProxy : SettingsStorageProxy = facade.retrieveProxy( SettingsStorageProxy.NAME ) as SettingsStorageProxy;
			
			var body : Object = notification.getBody();
			
			settingsStorageProxy.saveSettings( "applicationManagerWindow", body );
			
			//sendNotification( ApplicationFacade.SETTINGS_SETTED, body );
		}
	}
}