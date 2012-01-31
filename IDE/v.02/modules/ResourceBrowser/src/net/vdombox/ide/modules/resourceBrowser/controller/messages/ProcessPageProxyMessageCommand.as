package net.vdombox.ide.modules.resourceBrowser.controller.messages
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessPageProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var place : String = message.proxy;
			var target : String = message.target;
			var operation : String = message.operation;

//			switch ( target )
//			{
//				case PPMPageTargetNames.:
//				{
//
//					if ( operation == PPMOperationNames.READ )
//					
//					break;
//				}
//			}
		}
	}
}