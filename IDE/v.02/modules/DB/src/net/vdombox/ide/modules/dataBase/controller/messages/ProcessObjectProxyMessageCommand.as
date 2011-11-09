package net.vdombox.ide.modules.dataBase.controller.messages
{
	import net.vdombox.ide.common.ProxyMessage;
	
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

//			switch ( target )
//			{
//				case PPMObjectTargetNames.:
//				{
//					if ( operation == PPMOperationNames.READ )
//						
//					break;
//				}
//			}
		}
	}
}