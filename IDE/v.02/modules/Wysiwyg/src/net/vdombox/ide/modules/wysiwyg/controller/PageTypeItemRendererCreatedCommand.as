package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.components.PageTypeItemRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.PageTypeItemRendererMediator;
	
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