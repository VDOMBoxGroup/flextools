package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.tree.model.vo.StructureElementVO;
	import net.vdombox.ide.modules.tree.view.TreeElementMediator;
	import net.vdombox.ide.modules.tree.view.components.TreeElementz;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class TreeElementCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			
			var viewComponent : TreeElementz = body.viewComponent as TreeElementz;
			var structureElementVO : StructureElementVO= body.structureElementVO as StructureElementVO;
			var pageVO : PageVO = body.pageVO as PageVO;
			
			facade.registerMediator( new TreeElementMediator( viewComponent, pageVO, structureElementVO ) );
		}
	}
}