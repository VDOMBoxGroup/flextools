package net.vdombox.ide.modules.applicationsManagment.controller
{
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.model.vo.SettingsVO;
	
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
			
			sendNotification( ApplicationFacade.SAVE_SETTINGS_TO_PROXY, settingsVO );
			sendNotification( ApplicationFacade.SAVE_SETTINGS_TO_STORAGE, settings );
		}
	}
}