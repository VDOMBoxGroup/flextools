package net.vdombox.ide.core.controller.requests
{
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMTypesTargetNames;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.TypesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	/**
	 * @flowerModelElementId _DB1i4EomEeC-JfVEe_-0Aw
	 */
	public class TypesProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var typesProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			
			var message : ProxyMessage = notification.getBody() as ProxyMessage;
			
			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;
			
			if( operation != PPMOperationNames.READ )
				return;
			
			switch ( target )
			{
				case PPMTypesTargetNames.TYPES:
				{
					message.setBody( typesProxy.types );
					
					sendNotification( TypesProxy.TYPES_PROXY_RESPONSE, message );
					break;
				}
					
				case PPMTypesTargetNames.TOP_LEVEL_TYPES:
				{
					var types : Array = typesProxy.topLevelTypes;
					
					message.setBody( types );
					
					sendNotification( TypesProxy.TYPES_PROXY_RESPONSE, message );
					
					break;
				}
					
				case PPMTypesTargetNames.TYPE:
				{
					var type : TypeVO = typesProxy.getType( body.toString() );
					
					message.setBody( type );
					
					sendNotification( TypesProxy.TYPES_PROXY_RESPONSE, message );
					
					break;
				}
			}
		}
	}
}