package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.tree.view.TreeElementMediator;
	import net.vdombox.ide.modules.tree.view.components.TreeElement;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class TreeElementRemovedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var treeElement : TreeElement = notification.getBody() as TreeElement;

			if ( treeElement && treeElement.treeElementVO )
				facade.removeMediator( TreeElementMediator.NAME + Notifications.DELIMITER + treeElement.treeElementVO.id );
		}
	}
}
