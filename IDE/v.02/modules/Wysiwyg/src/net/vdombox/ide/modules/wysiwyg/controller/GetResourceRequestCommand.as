package net.vdombox.ide.modules.wysiwyg.controller
{
	import com.zavoo.svg.nodes.SVGImageNode;

	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.ResourcesProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class GetResourceRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object               = notification.getBody();

			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var resourceVO : ResourceVO;
			resourceVO = new ResourceVO( sessionProxy.selectedApplication.id );

			if ( body is SVGImageNode )
			{
				var svgImageNode : SVGImageNode = body as SVGImageNode;

				resourceVO.setID( svgImageNode.resourceID );
				svgImageNode.resourceVO = resourceVO;

				sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO );
			}
			else if ( body is RendererBase )
			{
				var rendererBase : RendererBase = body as RendererBase;

				resourceVO.setID( rendererBase.resourceID );
				rendererBase.resourceVO = resourceVO;

				sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO );
			}
		}
	}
}
