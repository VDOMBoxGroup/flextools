package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.modules.tree.view.TreeCanvasMediator;
	import net.vdombox.ide.modules.tree.view.components.TreeCanvas;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class LinkagesChangedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var treeCanvasMediator : TreeCanvasMediator = facade.retrieveMediator( TreeCanvasMediator.NAME ) as TreeCanvasMediator;
			
			treeCanvasMediator.createLinkages( notification.getBody() as Array );
		}
	}
}