package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.view.LinkageMediator;
	import net.vdombox.ide.modules.tree.view.components.Linkage;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class LinkageCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();

			var viewComponent : Linkage = body.viewComponent as Linkage;
			var linkageVO : LinkageVO = body.linkageVO as LinkageVO;

			facade.registerMediator( new LinkageMediator( viewComponent, linkageVO ) );
		}
	}
}