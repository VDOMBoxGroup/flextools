package net.vdombox.ide.modules.dataBase.controller.messages
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMTypesTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.model.vo.TypeVO;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	import net.vdombox.ide.modules.dataBase.model.TypesProxy;
	
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
					sendNotification( ApplicationFacade.TOP_LEVEL_TYPES_GETTED, body );
						
					break;
				}
						
				case PPMTypesTargetNames.TYPES:
				{
					if( operation == PPMOperationNames.READ )
						typesProxy.types = body as Array;
						
					break;
				}
			}
		}
	}
}