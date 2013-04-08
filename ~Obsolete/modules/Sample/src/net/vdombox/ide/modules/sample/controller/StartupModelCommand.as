package net.vdombox.ide.modules.sample.controller
{
	import net.vdombox.ide.modules.sample.model.SessionProxy;
	import net.vdombox.ide.modules.sample.model.SettingsProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class StartupModelCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
//			регистрация прокси, используемых при работе модуля.
			facade.registerProxy( new SessionProxy() );
			facade.registerProxy( new SettingsProxy() );
		}
	}
}