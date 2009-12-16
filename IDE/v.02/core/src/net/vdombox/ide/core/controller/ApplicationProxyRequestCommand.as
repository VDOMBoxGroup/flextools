package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ApplicationPropertiesVO;
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
			
			var ppMessage : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;
			
			var body : Object = ppMessage.getBody();
			
			var applicationVO : ApplicationVO = body.applicationVO as ApplicationVO;
			
			var applicationProxy : ApplicationProxy = serverProxy.getApplicationProxy( applicationVO );
			
			switch ( ppMessage.getOperation() )
			{
				case PPMOperationNames.UPDATE:
				{
					var applicationPropertiesVO : ApplicationPropertiesVO = body.applicationPropertiesVO;
					applicationProxy.changeApplicationProperties( applicationPropertiesVO );
					
					break;
				}
			}
		}
	}
}