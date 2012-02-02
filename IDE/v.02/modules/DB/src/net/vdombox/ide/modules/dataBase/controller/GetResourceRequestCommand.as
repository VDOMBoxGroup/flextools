package net.vdombox.ide.modules.dataBase.controller
{
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	
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
				
				sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO );
			}
			
			return;
		}
	}
}