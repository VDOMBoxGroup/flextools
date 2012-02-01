package net.vdombox.ide.modules.events.controller.messages
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMObjectTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessObjectProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{

			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			
			var target : String = message.target;
			var operation : String = message.operation;

			switch ( target )
			{
				case PPMObjectTargetNames.SERVER_ACTIONS_LIST:
				{
					sendNotification( ApplicationFacade.SERVER_ACTIONS_LIST_GETTED, body.serverActions as Array );
					
					break;
				}
					
				case PPMObjectTargetNames.SERVER_ACTIONS:
				{
					if( PPMOperationNames.READ )
						sendNotification( ApplicationFacade.SERVER_ACTIONS_GETTED, body );
					else if( PPMOperationNames.UPDATE )
						sendNotification( ApplicationFacade.SERVER_ACTIONS_SETTED, body.serverActions );
					
					break;
				}
					
				case PPMObjectTargetNames.SERVER_ACTION:
				{
					sendNotification( ApplicationFacade.GET_SERVER_ACTIONS_REQUEST );
					sendNotification( ApplicationFacade.GET_APPLICATION_EVENTS,
						{ applicationVO: statesProxy.selectedApplication, pageVO: statesProxy.selectedPage } );
					
					break;
				}	
			}
		}
	}
}