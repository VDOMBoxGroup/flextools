package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class ModuleUnloadingStartCommand extends SimpleCommand
	{
		override public function execute(notification:INotification):void
		{
			var moduleVO : ModuleVO = notification.getBody() as ModuleVO;
			
			if( moduleVO && moduleVO.moduleID )
			{
				sendNotification( ApplicationFacade.DISCONNECT_MODULE_TO_CORE, moduleVO )
				sendNotification( ApplicationFacade.DISCONNECT_MODULE_TO_PROXIES, moduleVO.moduleID );
			}
		}
	}
}