package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ObjectVisibleCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var _rendererID : String = notification.getBody() as String;
			
			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			renderProxy.setVisibleRenderer( _rendererID );
			
		}
	}
}