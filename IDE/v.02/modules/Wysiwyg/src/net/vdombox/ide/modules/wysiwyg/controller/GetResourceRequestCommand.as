package net.vdombox.ide.modules.wysiwyg.controller
{
	import com.zavoo.svg.nodes.SVGImageNode;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.model.ResourcesProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.itemrenderer.ObjectTreePanelItemRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class GetResourceRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object ;
			var statesProxy : StatesProxy;
			var resourceVO : ResourceVO;
		
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			if ( !statesProxy.selectedApplication )
				return;
			
			resourceVO = new ResourceVO( statesProxy.selectedApplication.id );
			
			body   = notification.getBody();
			
			
			if ( body.hasOwnProperty( "resourceID" ) &&  body.hasOwnProperty( "resourceVO" ) )
			{
				resourceVO.setID( body[ "resourceID" ] );
				body[ "resourceVO" ] = resourceVO;
				
				sendNotification( Notifications.LOAD_RESOURCE, resourceVO );
			}
			
			return;
		}
	}
}
