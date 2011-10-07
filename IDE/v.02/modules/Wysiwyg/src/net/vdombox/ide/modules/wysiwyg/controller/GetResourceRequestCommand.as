package net.vdombox.ide.modules.wysiwyg.controller
{
	import com.zavoo.svg.nodes.SVGImageNode;
	
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.ResourcesProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectTreePanelItemRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class GetResourceRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object ;
			var sessionProxy : SessionProxy;
			var resourceVO : ResourceVO;
		
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			resourceVO = new ResourceVO( sessionProxy.selectedApplication.id );
			
			body   = notification.getBody();
			
			
			if ( body.hasOwnProperty( "resourceID" ) &&  body.hasOwnProperty( "resourceVO" ) )
			{
				resourceVO.setID( body[ "resourceID" ] );
				body[ "resourceVO" ] = resourceVO;
				
				sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO );
			}
			
			return;
			
			
			
		}
	}
}
