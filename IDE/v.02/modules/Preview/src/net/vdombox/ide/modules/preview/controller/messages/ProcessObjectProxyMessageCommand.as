package net.vdombox.ide.modules.preview.controller.messages
{
	import net.vdombox.ide.common.PPMObjectTargetNames;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.modules.preview.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessObjectProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{

			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var place : String = message.proxy;
			var target : String = message.target;
			var operation : String = message.operation;

			switch ( target )
			{
				case PPMObjectTargetNames.SERVER_ACTIONS:
				{
					if( PPMOperationNames.READ )
						sendNotification( ApplicationFacade.SERVER_ACTIONS_GETTED, body.serverActions );
					else if( PPMOperationNames.UPDATE )
						sendNotification( ApplicationFacade.SERVER_ACTIONS_SETTED, body.serverActions );
					
					break;
				}
			}
		}
	}
}