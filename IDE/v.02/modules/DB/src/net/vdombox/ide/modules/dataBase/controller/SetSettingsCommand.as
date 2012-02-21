package net.vdombox.ide.modules.dataBase.controller
{
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.common.model._vo.SettingsVO;
	import net.vdombox.ide.common.controller.Notifications;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SetSettingsCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var settingsVO : SettingsVO = notification.getBody() as SettingsVO;
			var settings : Object = 
				{ 
					saveLastApplication : settingsVO.saveLastApplication, 
					lastApplicationID : settingsVO.lastApplicationID
				};
			
			sendNotification( SettingsProxy.SAVE_SETTINGS_TO_PROXY, settingsVO );
			sendNotification( SettingsProxy.SAVE_SETTINGS_TO_STORAGE, settings );
		}
	}
}