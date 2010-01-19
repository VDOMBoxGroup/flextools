package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMTypesTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.TypesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class TypesProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var typesProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			
			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;
			
			var body : Object = message.getBody();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();
			
			if( operation != PPMOperationNames.READ )
				return;
			
			switch ( target )
			{
				case PPMTypesTargetNames.TYPES:
				{
					message.setBody( typesProxy.types );
					
					sendNotification( ApplicationFacade.TYPES_PROXY_RESPONSE, message );
					break;
				}
					
				case PPMTypesTargetNames.TYPE:
				{
					var type : TypeVO = typesProxy.getType( body.toString() );
					
					message.setBody( type );
					
					sendNotification( ApplicationFacade.TYPES_PROXY_RESPONSE, message );
					
					break;
				}
			}
		}
	}
}