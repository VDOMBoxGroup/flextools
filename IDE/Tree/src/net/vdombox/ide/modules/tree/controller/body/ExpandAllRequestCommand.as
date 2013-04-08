package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.modules.tree.model.StructureProxy;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ExpandAllRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var structureProxy : StructureProxy = facade.retrieveProxy( StructureProxy.NAME ) as StructureProxy;
			var isExpand : Boolean = notification.getBody() as Boolean;


			var treeElements : Array = structureProxy.treeElements;
			var treeElementVO : TreeElementVO;

			for each ( treeElementVO in treeElements )
			{
				treeElementVO.state = isExpand;
			}
		}
	}
}
