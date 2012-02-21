package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.tree.model.StructureProxy;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreateLinkageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var structureProxy : StructureProxy = facade.retrieveProxy( StructureProxy.NAME ) as StructureProxy;
			
			var newLinkageVO : LinkageVO = notification.getBody() as LinkageVO;
			
			structureProxy.addLinkage( newLinkageVO );			
		}
	}
}