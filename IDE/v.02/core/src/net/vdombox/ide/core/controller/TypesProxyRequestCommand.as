package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMTypesTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.TypesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class TypesProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var typesProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
			
			var body : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;
			
			var target : String = body.target;
			var operation : String = body.operation;
			
			if( operation != PPMOperationNames.READ )
				return;
			
			switch ( target )
			{
				case PPMTypesTargetNames.TYPES:
				{
					var types : Array //= typesProxy.types;
					
					sendNotification( ApplicationFacade.TYPES_PROXY_RESPONSE, 
						{ operation : body.operation, target : body.target, parameters : types }
					);
					break;
				}
					
				case PPMTypesTargetNames.TYPE:
				{
					
					break;
				}
			}
		}
	}
}