package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.vo.SettingsVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class GetSettingsCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var settingsProxy : SettingsProx = facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;
			
			var mediatorName : String = notification.getBody().toString();
			var settingsVO : SettingsVO = settingsProxy.settings;
			
			var notificationName : String = ApplicationFacade.SETTINGS_GETTED;
			
			if ( mediatorName )
				notificationName = notificationName + "/" + mediatorName;
			
			sendNotification( notificationName, settingsVO );
		}
	}
}