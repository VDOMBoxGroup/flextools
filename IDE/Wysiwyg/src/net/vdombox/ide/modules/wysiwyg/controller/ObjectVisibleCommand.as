package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.VisibleRendererProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ObjectVisibleCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody() as Object;
			var _rendererID : String = body.rendererID as String;
			var _visible : Boolean = body.visible as Boolean;

			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			var visibleRendererProxy : VisibleRendererProxy = facade.retrieveProxy( VisibleRendererProxy.NAME ) as VisibleRendererProxy;

			visibleRendererProxy.setVisible( _rendererID, _visible );
			renderProxy.setVisibleRenderer( _rendererID, _visible );

		}
	}
}
