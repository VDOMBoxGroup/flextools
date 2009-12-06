package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.SettingsStorageProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SaveModuleSettings extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var settingsStorageProxy : SettingsStorageProxy = facade.retrieveProxy( SettingsStorageProxy.NAME ) as SettingsStorageProxy;
			var settings : Object = notification.getBody();
			settingsStorageProxy.saveSettings( settings.moduleID, settings.settings );
			var d : * = settingsStorageProxy.loadSettings( settings.moduleID );
		}
	}
}