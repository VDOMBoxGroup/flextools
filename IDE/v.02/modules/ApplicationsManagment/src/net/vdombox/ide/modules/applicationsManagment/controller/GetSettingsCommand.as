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
			
			var mediatorName : String = notification.getBody().toString();
			var settingsVO : SettingsVO = settingsProxy.getSettings();
			var notificationName : String = ApplicationFacade.SETTINGS_GETTED;
			
			if ( settingsVO )
			{
				if( mediatorName )
					notificationName = mediatorName + "/" + notificationName;
					
				sendNotification( notificationName, settingsVO );
			}
			else
			{
				sendNotification( ApplicationFacade.RETRIEVE_SETTINGS_FROM_STORAGE );
			}
		}
	}
}