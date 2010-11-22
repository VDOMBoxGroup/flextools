package net.vdombox.ide.modules.sample.controller.messages
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMTypesTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessTypesProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;

			switch ( target )
			{
				case PPMTypesTargetNames.TYPES:
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