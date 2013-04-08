package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	import net.vdombox.ide.core.view.VIModuleMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ModuleLoadingSuccessfulCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var moduleVO : ModuleVO = notification.getBody() as ModuleVO;

			facade.registerMediator( new VIModuleMediator( moduleVO.module ) );

			sendNotification( ApplicationFacade.CONNECT_MODULE_TO_CORE, moduleVO );
		}
	}
}
