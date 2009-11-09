package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.view.VIModuleMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class ModuleLoadedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var module : VIModule= notification.getBody() as VIModule;
			sendNotification( ApplicationFacade.CONNECT_MODULE_TO_CORE, module );
			facade.registerMediator( new VIModuleMediator( module ) );
			sendNotification( ApplicationFacade.MODULE_READY, module );
		}
	}
}