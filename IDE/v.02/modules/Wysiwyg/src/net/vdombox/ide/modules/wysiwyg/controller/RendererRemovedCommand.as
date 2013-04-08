package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class RendererRemovedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var pageVO : PageVO = notification.getBody() as PageVO;
			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;

			if ( !( pageVO is PageVO ) )
				return;

			renderProxy.removeRenderersByPage( pageVO );
		}
	}
}
