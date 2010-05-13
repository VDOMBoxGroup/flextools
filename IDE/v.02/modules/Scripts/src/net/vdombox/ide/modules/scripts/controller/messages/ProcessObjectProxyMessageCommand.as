package net.vdombox.ide.modules.scripts.controller.messages
{
	import net.vdombox.ide.common.PPMObjectTargetNames;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessObjectProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{

			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var body : Object = message.getBody();
			var place : String = message.getPlace();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();

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