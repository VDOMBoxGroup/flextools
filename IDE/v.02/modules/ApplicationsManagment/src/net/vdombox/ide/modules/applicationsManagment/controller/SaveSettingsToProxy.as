package net.vdombox.ide.modules.applicationsManagment.controller
{
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SaveSettingsToProxy extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var settingsProxy : SettingsProxy = facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;
			
			var settings : * = notification.getBody();
			
			var settingsVO : SettingsVO = new SettingsVO();
			settingsVO.saveLastApplication = settings.saveLastApplication;
			settingsVO.lastApplicatonID = settings.lastApplicatonID;
			
			settingsProxy.setSettings( settingsVO );
		}
	}
}