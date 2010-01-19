package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.core.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class PageProxyResponseCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			var message : ProxiesPipeMessage;
			
			switch ( name )
			{
				case ApplicationFacade.OBJECT_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.OBJECT, body );
					
					break;
				}
				
				case ApplicationFacade.OBJECTS_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.OBJECTS, body );
					
					break;
				}
				case ApplicationFacade.PAGE_STRUCTURE_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.STRUCTURE, body );
					
					break;
				}
			}
			
			if ( message )
				sendNotification( ApplicationFacade.PAGE_PROXY_RESPONSE, message );
		}
	}
}