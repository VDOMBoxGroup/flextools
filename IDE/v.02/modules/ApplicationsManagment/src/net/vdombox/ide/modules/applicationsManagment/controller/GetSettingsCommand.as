package net.vdombox.ide.modules.applicationsManagment.controller
{
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.model.SettingsProxy;
	import net.vdombox.ide.modules.applicationsManagment.model.vo.SettingsVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class GetSettingsCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var settingsProxy : SettingsProxy = facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;
			var settingsVO : SettingsVO = settingsProxy.getSettings();
			
			if ( settingsVO )
			{
				sendNotification( ApplicationFacade.SETTINGS_GETTED, settingsVO );
			}
			else
			{
				sendNotification( ApplicationFacade.RETRIEVE_SETTINGS );
			}
		}
	}
}