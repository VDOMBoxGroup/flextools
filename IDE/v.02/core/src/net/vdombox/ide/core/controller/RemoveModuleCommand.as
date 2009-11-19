package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	import net.vdombox.ide.core.view.VIModuleMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class RemoveModuleCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var moduleVO : ModuleVO = notification.getBody() as ModuleVO;

			sendNotification( ApplicationFacade.DISCONNECT_MODULE_TO_CORE, moduleVO );

			var moduleMediator : VIModuleMediator = facade.retrieveMediator( moduleVO.moduleID ) as VIModuleMediator;
			moduleMediator.tearDown();
			facade.removeMediator( moduleVO.moduleID );
		}
	}
}