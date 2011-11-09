package net.vdombox.ide.modules.dataBase.controller
{
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	import net.vdombox.ide.modules.dataBase.model.SettingsProxy;
	import net.vdombox.ide.modules.dataBase.model.vo.SettingsVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class InitializeSettingsCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			var settingeProxy : SettingsProxy = facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;
			var settings : Object = settingeProxy.defaultSettings;
			
			var settingsVO : SettingsVO = new SettingsVO( settings );
			
			settingeProxy.setSettings( settingsVO );
			sendNotification( ApplicationFacade.SAVE_SETTINGS_TO_STORAGE, settings );
		}
	}
}