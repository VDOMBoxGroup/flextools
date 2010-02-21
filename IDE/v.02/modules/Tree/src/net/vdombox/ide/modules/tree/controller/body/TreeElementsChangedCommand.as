package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.modules.tree.view.TreeCanvasMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class TreeElementsChangedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var treeCanvasMediator : TreeCanvasMediator = facade.retrieveMediator( TreeCanvasMediator.NAME ) as TreeCanvasMediator;
			
			treeCanvasMediator.createTreeElements( notification.getBody() as Array );
		}
	}
}