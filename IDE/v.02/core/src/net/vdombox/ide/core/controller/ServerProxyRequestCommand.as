package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMServerTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ServerProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ServerProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			
			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;
			
			var target : String = message.getTarget();
			var operation : String = message.getOperation();
			
			switch ( target )
			{
				case PPMServerTargetNames.APPLICATION:
				{
					if( operation == PPMOperationNames.CREATE )
						serverProxy.createApplication();
					
					break;
				}
					
				case PPMServerTargetNames.APPLICATIONS:
				{
					var applications : Array = serverProxy.applications;
					
					message.setBody( applications );
					
					sendNotification( ApplicationFacade.SERVER_PROXY_RESPONSE, message );
					break;
				}
				
				case PPMServerTargetNames.SELECTED_APPLICATION:
				{
					var selectedApplication : ApplicationVO;
					
					if( operation == PPMOperationNames.READ )
					{
						selectedApplication = serverProxy.selectedApplication;
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
						selectedApplication = message.getBody() as ApplicationVO;
						serverProxy.selectedApplication = selectedApplication;
					}
					
					message.setBody( selectedApplication );
					
					sendNotification( ApplicationFacade.SERVER_PROXY_RESPONSE, message );
					
					break;
				}
			}
		}
	}
}