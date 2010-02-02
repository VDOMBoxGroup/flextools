package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.view.ArrowMediator;
	import net.vdombox.ide.modules.tree.view.components.Arrow;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ArrowCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();

			var viewComponent : Arrow = body.viewComponent as Arrow;
			var linkageVO : LinkageVO = body.linkageVO as LinkageVO;

			facade.registerMediator( new ArrowMediator( viewComponent, linkageVO ) );
		}
	}
}