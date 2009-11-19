package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.model.ModulesProxy;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class LoadModuleCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var moduleVO : ModuleVO = notification.getBody() as ModuleVO;
			
			var modulesProxy : ModulesProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
			modulesProxy.loadModule( moduleVO );
		}
	}
}