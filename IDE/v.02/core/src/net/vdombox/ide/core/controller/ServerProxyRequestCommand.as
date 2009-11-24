package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMServerTargetNames;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.vo.ApplicationVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ServerProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			
			var body : Object = notification.getBody();
			
			var target : String = body.target;
			
			switch ( target )
			{
				case PPMServerTargetNames.APPLICATIONS:
				{
					var applications : Array = serverProxy.applications;
					
					sendNotification( ApplicationFacade.SERVER_PROXY_RESPONSE, 
						{ operation : body.operation, target : body.target, parameters : applications }
					);
					break;
				}
				
				case PPMServerTargetNames.SELECTED_APPLICATION:
				{
					var selectedApplication : ApplicationVO = serverProxy.selectedApplication;
					
					sendNotification( ApplicationFacade.SERVER_PROXY_RESPONSE, 
						{ operation : body.operation, target : target, parameters : selectedApplication }
					);
					break;
				}
			}
			
			
		}
	}
}