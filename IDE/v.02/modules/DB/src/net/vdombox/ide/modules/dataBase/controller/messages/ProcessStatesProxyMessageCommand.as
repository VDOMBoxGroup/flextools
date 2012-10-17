package net.vdombox.ide.modules.dataBase.controller.messages
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMStatesTargetNames;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.modules.dataBase.model.StatesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessStatesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;
			
			var body : Object = message.getBody();
			var place : String = message.proxy;
			var target : String = message.target;
			var operation : String = message.operation;
			
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			switch ( target )
			{
				case PPMStatesTargetNames.ALL_STATES:
				{
					statesProxy.setStates( body );
					sendNotification( StatesProxy.ALL_STATES_GETTED, body );
					
					break;
				}
					
				case PPMStatesTargetNames.SELECTED_APPLICATION:
				{
					var selectedApplication : ApplicationVO = body as ApplicationVO;
					statesProxy.selectedApplication = selectedApplication;
					
					break;
				}
			}
		}
	}
}