package net.vdombox.ide.modules.resourceBrowser.controller.messages
{
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMResourcesTargetNames;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.modules.resourceBrowser.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessResourcesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var place : String = message.proxy;
			var operation : String = message.operation;
			var target : String = message.target;

			var body : Object = message.getBody();

			switch ( target )
			{
				case PPMResourcesTargetNames.RESOURCE:
				{
					if ( operation == PPMOperationNames.CREATE )
						sendNotification( ApplicationFacade.RESOURCE_UPLOADED, body );
					else if ( operation == PPMOperationNames.DELETE )
						sendNotification( ApplicationFacade.RESOURCE_DELETED, body );
					else if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.RESOURCE_LOADED, body );
					
					break;
				}
					
				case PPMResourcesTargetNames.RESOURCES:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.RESOURCES_GETTED, body );
					
					break;
				}
			}
		}
	}
}