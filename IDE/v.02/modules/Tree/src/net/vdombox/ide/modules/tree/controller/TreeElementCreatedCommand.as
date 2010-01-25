package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.StructureObjectVO;
	import net.vdombox.ide.modules.tree.view.TreeElementMediator;
	import net.vdombox.ide.modules.tree.view.components.TreeElement;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class TreeElementCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			
			var viewComponent : TreeElement = body.viewComponent as TreeElement;
			var structureObjectVO : StructureObjectVO = body.structureObjectVO as StructureObjectVO;
			var pageVO : PageVO = body.pageVO as PageVO;
			
			facade.registerMediator( new TreeElementMediator( viewComponent, pageVO, structureObjectVO ) );
		}
	}
}