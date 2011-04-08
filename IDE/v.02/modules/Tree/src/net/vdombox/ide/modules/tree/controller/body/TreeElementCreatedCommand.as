package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.view.TreeElementMediator;
	import net.vdombox.ide.modules.tree.view.components.TreeElement;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class TreeElementCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var treeElement : TreeElement = notification.getBody() as TreeElement;
			facade.registerMediator( new TreeElementMediator( treeElement ) );
		}
	}
}