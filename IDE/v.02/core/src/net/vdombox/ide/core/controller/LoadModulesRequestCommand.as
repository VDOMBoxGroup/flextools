package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.ModulesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class LoadModulesRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var modulesProxy: ModulesProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
			modulesProxy.loadModules();
		}
	}
}