package net.vdombox.ide.core.controller.responses
{
	import net.vdombox.ide.common.PPMApplicationTargetNames;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.core.ApplicationFacade;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ApplicationProxyResponseCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			var message : ProxiesPipeMessage;

			switch ( name )
			{
				case ApplicationFacade.APPLICATION_CHANGED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.UPDATE, PPMApplicationTargetNames.INFORMATION, body );

					break;
				}

				case ApplicationFacade.APPLICATION_PAGES_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.PAGES, body );

					break;
				}
					
				case ApplicationFacade.APPLICATION_STRUCTURE_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.STRUCTURE, body );
					
					break;
				}
				
				case ApplicationFacade.APPLICATION_STRUCTURE_SETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.UPDATE, PPMApplicationTargetNames.STRUCTURE, body );
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_PAGE_CREATED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.CREATE, PPMApplicationTargetNames.PAGE, body );
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_PAGE_DELETED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.DELETE, PPMApplicationTargetNames.PAGE, body );
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_SERVER_ACTIONS_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.SERVER_ACTIONS, body );
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_LIBRARY_CREATED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.CREATE, PPMApplicationTargetNames.LIBRARY, body );
					
					break;
				}
				
				case ApplicationFacade.APPLICATION_LIBRARY_UPDATED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.UPDATE, PPMApplicationTargetNames.LIBRARY, body );
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_LIBRARY_DELETED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.DELETE, PPMApplicationTargetNames.LIBRARY, body );
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_LIBRARIES_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.LIBRARIES, body );
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_EVENTS_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.EVENTS, body );
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_EVENTS_SETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.UPDATE, PPMApplicationTargetNames.EVENTS, body );
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_REMOTE_CALL_GETTED:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.REMOTE_CALL, body );
					
					break;
				}
			}

			if ( message )
				sendNotification( ApplicationFacade.APPLICATION_PROXY_RESPONSE, message );
		}
	}
}