package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.common.view.components.itemrenderers.PageTypeItemRenderer;
	import net.vdombox.ide.modules.tree.view.PageTypeItemRendererMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PageTypeItemRendererCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var pageTypeItemRenderer : PageTypeItemRenderer = notification.getBody() as PageTypeItemRenderer;

			facade.registerMediator( new PageTypeItemRendererMediator( pageTypeItemRenderer ) );
		}
	}
}
