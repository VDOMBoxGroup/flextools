package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMServerTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
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
					if ( operation == PPMOperationNames.CREATE )
						serverProxy.createApplication( message.getBody() as ApplicationInformationVO );
					
					break;
				}

				case PPMServerTargetNames.APPLICATIONS:
				{
					var applications : Array = serverProxy.applications;

					message.setBody( applications );

					sendNotification( ApplicationFacade.SERVER_PROXY_RESPONSE, message );
					break;
				}
			}
		}
	}
}