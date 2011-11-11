package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SetNewNameObjectCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var _objectVO : ObjectVO = notification.getBody() as ObjectVO;
			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			var renderObject : RendererBase = renderProxy.getRendererByID( _objectVO.id );
			renderObject.renderVO.vdomObjectVO.name = _objectVO.name;
		}
	}
}