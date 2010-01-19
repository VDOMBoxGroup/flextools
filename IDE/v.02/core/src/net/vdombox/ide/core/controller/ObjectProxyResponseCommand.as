package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMObjectTargetNames;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.core.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class ObjectProxyResponseCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			var message : ProxiesPipeMessage;
			
			switch ( name )
			{
				case ApplicationFacade.OBJECT_ATTRIBUTES_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.OBJECT, PPMOperationNames.READ, PPMObjectTargetNames.ATTRIBUTES, body );
					
					break;
				}
			}
			
			if ( message )
				sendNotification( ApplicationFacade.OBJECT_PROXY_RESPONSE, message );
		}
	}
}