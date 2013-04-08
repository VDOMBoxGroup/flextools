package net.vdombox.ide.modules.sample.controller.messages
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMStatesTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.modules.sample.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessStatesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var message : ProxyMessage = notification.getBody() as ProxyMessage;
			
			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;
			
			switch ( target )
			{
				case PPMStatesTargetNames.ALL_STATES:
				{
					if( operation == PPMOperationNames.READ )
					{
					}
					
					break;
				}
				
				case PPMStatesTargetNames.SELECTED_APPLICATION:
				{
					if( operation == PPMOperationNames.READ )
					{
					}
					
					break;
				}
					
				case PPMStatesTargetNames.SELECTED_PAGE:
				{
					if( operation == PPMOperationNames.READ )
					{
					}
					
					break;
				}
					
				case PPMStatesTargetNames.SELECTED_OBJECT:
				{
					if( operation == PPMOperationNames.READ )
					{
					}
					
					break;
				}
			}
		}
	}
}