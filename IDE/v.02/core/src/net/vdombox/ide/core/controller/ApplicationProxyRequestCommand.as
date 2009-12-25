package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.core.model.ApplicationProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ApplicationProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			
			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;
			
			var body : Object = message.getBody();
			
			var applicationVO : ApplicationVO = body.applicationVO as ApplicationVO;
			
			var applicationProxy : ApplicationProxy = serverProxy.getApplicationProxy( applicationVO );
			
			switch ( message.getOperation() )
			{
				case PPMOperationNames.UPDATE:
				{
					var applicationInformationVO : ApplicationInformationVO = body.applicationInformationVO;
					applicationProxy.changeApplicationInformation( applicationInformationVO );
					
					break;
				}
			}
		}
	}
}