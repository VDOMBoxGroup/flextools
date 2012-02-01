package net.vdombox.ide.modules.events.controller.messages
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMTypesTargetNames;
	import net.vdombox.ide.common.model.SessionProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessTypesProxyMessageCommand extends SimpleCommand
	{	
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var typesProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			
			var message : ProxyMessage = notification.getBody() as ProxyMessage;
			
			var operation : String = message.operation;
			var target : String = message.target;
			
			var body : Object = message.getBody();
			
			switch ( target )
			{
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