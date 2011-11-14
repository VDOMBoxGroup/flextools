package net.vdombox.ide.modules.dataBase.controller
{
	import net.vdombox.ide.modules.dataBase.model.SessionProxy;
	import net.vdombox.ide.modules.dataBase.model.SettingsProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class StartupModelCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			facade.registerProxy( new SessionProxy() );
			facade.registerProxy( new SettingsProxy() );
		}
	}
}