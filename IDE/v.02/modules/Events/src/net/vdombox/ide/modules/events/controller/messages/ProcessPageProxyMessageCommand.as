package net.vdombox.ide.modules.events.controller.messages
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMPageTargetNames;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.controller.Notifications;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessPageProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var place : String = message.proxy;
			var target : String = message.target;
			var operation : String = message.operation;

			var pageVO : PageVO = body.pageVO as PageVO;
			
			switch ( target )
			{
				case PPMPageTargetNames.SERVER_ACTIONS_LIST:
				{
					sendNotification( Notifications.SERVER_ACTIONS_LIST_GETTED, body.serverActions as Array );
					
					break;
				}
					
				case PPMPageTargetNames.SERVER_ACTIONS:
				{
					if( PPMOperationNames.READ )
						sendNotification( Notifications.SERVER_ACTIONS_GETTED, body );
					else if( PPMOperationNames.UPDATE )
						sendNotification( Notifications.SERVER_ACTIONS_SETTED, body.serverActions );
					
					break;
				}
					
				case PPMPageTargetNames.SERVER_ACTION:
				{
					sendNotification( Notifications.GET_SERVER_ACTIONS_REQUEST );
					sendNotification( Notifications.GET_APPLICATION_EVENTS,
						{ applicationVO: statesProxy.selectedApplication, pageVO: statesProxy.selectedPage } );
					
					break;
				}	
					
				case PPMPageTargetNames.XML_PRESENTATION:
				{
					break;
				}
					
				case PPMPageTargetNames.OBJECT:
				{
					if ( operation == PPMOperationNames.READ )
					{
						sendNotification( Notifications.OBJECT_GETTED, body.objectVO );
					}

					break;
				}

				case PPMPageTargetNames.STRUCTURE:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( Notifications.PAGE_STRUCTURE_GETTED, body );

					break;
				}
			}
		}
	}
}