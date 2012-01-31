package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMPlaceNames;
	import net.vdombox.ide.common.controller.names.PPMTypesTargetNames;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.TypesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class GetTypesCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var typesProxy : TypesProxy = facade.retrieveProxy( TypesProxy.NAME ) as TypesProxy;
					
			var message : ProxyMessage =  new ProxyMessage( PPMPlaceNames.TYPES, PPMOperationNames.READ,
				PPMTypesTargetNames.TYPES, typesProxy.types );
			
			sendNotification( TypesProxy.TYPES_PROXY_RESPONSE, message );
			
		}
	}
}