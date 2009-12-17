package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMApplicationTargetNames;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ApplicationProxyResponseCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			
			var message : ProxiesPipeMessage;
			
			switch ( notification.getName() )
			{
				case ApplicationFacade.APPLICATION_CHANGED:
				{
					var applicationVO : ApplicationVO = body as ApplicationVO;
					
					if( !applicationVO )
					{
						sendNotification( ApplicationFacade.SEND_TO_LOG, "ApplicationProxyResponseCommand: APPLICATION_CHANGED applicationVO is null." );
						return;
					}
					
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.UPDATE, 
						PPMApplicationTargetNames.INFORMATION, applicationVO );
					
					sendNotification( ApplicationFacade.APPLICATION_PROXY_RESPONSE, message );
					
					break;
				}
			}
		}
	}
}