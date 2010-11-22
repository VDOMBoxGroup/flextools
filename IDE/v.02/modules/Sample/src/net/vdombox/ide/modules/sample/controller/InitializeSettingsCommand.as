//Используется для инициализации настроек (значения по умолчанию). Вызывается, если IDE Core запросило настройки по умолчанию.
package net.vdombox.ide.modules.sample.controller
{
	import net.vdombox.ide.modules.sample.ApplicationFacade;
	import net.vdombox.ide.modules.sample.model.SettingsProxy;
	import net.vdombox.ide.modules.sample.model.vo.SettingsVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class InitializeSettingsCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			var settingeProxy : SettingsProxy = facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;
			
//			создание settingsVO с настройками по умолчанию.			
			var settings : Object = settingeProxy.defaultSettings;
			var settingsVO : SettingsVO = new SettingsVO( settings );
			
			settingeProxy.setSettings( settingsVO );
			
//			вызов уведомления для сохраниения в IDE Core
			sendNotification( ApplicationFacade.SAVE_SETTINGS_TO_STORAGE, settings );
		}
	}
}