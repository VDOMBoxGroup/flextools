package net.vdombox.ide.modules.dataBase.controller.messages
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMTypesTargetNames;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.common.controller.Notifications;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessTypesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;
			
			var typesProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			
			var body : Object = message.getBody();
			var place : String = message.proxy;
			var target : String = message.target;
			var operation : String = message.operation;

			switch ( target )
			{
				case PPMTypesTargetNames.TOP_LEVEL_TYPES:
				{
					sendNotification( TypesProxy.TOP_LEVEL_TYPES_GETTED, body );
						
					break;
				}
						
				case PPMTypesTargetNames.TYPES:
				{
					if( operation == PPMOperationNames.READ )
						typesProxy.dbtypes = body as Array;
						
					break;
				}
			}
		}
	}
}