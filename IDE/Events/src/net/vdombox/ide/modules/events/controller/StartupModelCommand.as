package net.vdombox.ide.modules.events.controller
{
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.modules.events.model.MessageProxy;
	import net.vdombox.ide.modules.events.model.VisibleElementProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StartupModelCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			facade.registerProxy( new SettingsProxy() );
			facade.registerProxy( new StatesProxy() );
			facade.registerProxy( new VisibleElementProxy() );
			facade.registerProxy( new TypesProxy() );
			facade.registerProxy( new MessageProxy() );
		}
	}
}
