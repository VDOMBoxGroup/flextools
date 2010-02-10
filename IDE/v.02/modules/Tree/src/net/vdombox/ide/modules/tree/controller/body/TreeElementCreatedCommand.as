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
			var body : Object = notification.getBody();
			
			var viewComponent : TreeElement = body.viewComponent as TreeElement;
			var treeElementVO : TreeElementVO = body.treeElementVO as TreeElementVO;
			
			facade.registerMediator( new TreeElementMediator( viewComponent, treeElementVO ) );
		}
	}
}