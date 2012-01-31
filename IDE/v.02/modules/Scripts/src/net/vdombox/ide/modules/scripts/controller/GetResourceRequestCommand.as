package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.model.SessionProxy;
	
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
			
			if ( !sessionProxy.selectedApplication )
				return;
			
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