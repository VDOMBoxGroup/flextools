package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.SettingsProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SettingsChangedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var settingsProxy : SettingsProxy = facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;
			var settingsObject : Object = settingsProxy.exportSettings();
			
			sendNotification( ApplicationFacade.SAVE_MODULE_SETTINGS2, settingsObject );
		}
	}
}