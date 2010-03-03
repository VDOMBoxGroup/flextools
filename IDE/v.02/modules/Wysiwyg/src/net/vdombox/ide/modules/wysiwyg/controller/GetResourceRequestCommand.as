package net.vdombox.ide.modules.wysiwyg.controller
{
	import com.zavoo.svg.nodes.SVGImageNode;
	
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class GetResourceRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();

			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var resourceVO : ResourceVO;
			
			if( body is SVGImageNode )
			{
				resourceVO = new ResourceVO( sessionProxy.selectedApplication.id );
				resourceVO.setID( body.resourceID );
				
				body.resourceVO = resourceVO;
				
				sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO );
			}
		}
	}
}