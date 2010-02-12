package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.StructureProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PageDeletedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var structureProxy : StructureProxy = facade.retrieveProxy( StructureProxy.NAME ) as StructureProxy;
			var pageVO : PageVO = notification.getBody().pageVO as PageVO;
			
			if( !pageVO )
			{
				sendNotification( ApplicationFacade.SEND_TO_LOG, Object(this).constructor.toString );
			}
			
			structureProxy.deleteTreeElementByVO( pageVO );
		}
	}
}