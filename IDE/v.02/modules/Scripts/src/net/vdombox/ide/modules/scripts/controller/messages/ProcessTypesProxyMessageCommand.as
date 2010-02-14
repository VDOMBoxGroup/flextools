package net.vdombox.ide.modules.scripts.controller.messages
{
	import net.vdombox.ide.common.PPMTypesTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessTypesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
//			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var place : String = message.getPlace();
			var operation : String = message.getOperation();
			var target : String = message.getTarget();

			var body : Object = message.getBody();

			switch ( target )
			{
				case PPMTypesTargetNames.TYPES:
				{
					sendNotification( net.vdombox.ide.modules.scripts.ApplicationFacade.TYPES_GETTED, body );

					break;
				}
			}
		}
	}
}