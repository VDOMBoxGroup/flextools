package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.StatesProxy;
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.modules.tree.model.StructureProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class StartupModelCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			facade.registerProxy( new StatesProxy() );
			facade.registerProxy( new SettingsProxy() );
			facade.registerProxy( new StructureProxy() );
		}
	}
}