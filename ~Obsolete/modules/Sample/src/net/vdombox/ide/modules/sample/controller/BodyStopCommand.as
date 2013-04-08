//Вызывается, если пользователь выбрал другой модуль в качестве текущего. 
package net.vdombox.ide.modules.sample.controller
{
	import net.vdombox.ide.modules.sample.model.SessionProxy;
	import net.vdombox.ide.modules.sample.model.SettingsProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class BodyStopCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var settingsProxy : SettingsProxy = facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;
			
//			очистка прокси (сброс в начальные значения)
			sessionProxy.cleanup();
			settingsProxy.cleanup();
		}
	}
}