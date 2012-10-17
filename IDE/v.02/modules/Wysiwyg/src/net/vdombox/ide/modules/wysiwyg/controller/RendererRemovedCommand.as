package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class RendererRemovedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var renderer : IRenderer = notification.getBody() as IRenderer;
			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;

			renderProxy.removeRenderer( renderer );
		}
	}
}