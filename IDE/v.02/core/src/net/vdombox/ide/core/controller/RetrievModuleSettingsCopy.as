package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.SettingsProxy;
	import net.vdombox.ide.core.model.SettingsStorageProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class RetrievModuleSettingsCopy extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var settingsStorageProxy : SettingsStorageProxy = facade.retrieveProxy( SettingsStorageProxy.NAME ) as SettingsStorageProxy;
				
			var settings : Object = settingsStorageProxy.loadSettings( "applicationManagerWindow" );
			
			var mediatorName : String = notification.getBody() as String;
			
			var settingsProxy : SettingsProxy = facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;
			
			settingsProxy.importSettings( settings );
			
			sendNotification( ApplicationFacade.SETTINGS_GETTED + "/" + mediatorName, settings )
		}
	}
}