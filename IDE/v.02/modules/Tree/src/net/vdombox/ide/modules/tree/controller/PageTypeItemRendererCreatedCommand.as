package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.modules.tree.view.PageTypeItemRendererMediator;
	import net.vdombox.ide.modules.tree.view.components.PageTypeItemRenderer;
	
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