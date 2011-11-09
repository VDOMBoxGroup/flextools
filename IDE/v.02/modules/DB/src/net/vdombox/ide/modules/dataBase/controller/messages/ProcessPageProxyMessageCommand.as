package net.vdombox.ide.modules.dataBase.controller.messages
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	
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

			switch ( target )
			{
				case PPMPageTargetNames.OBJECT:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.TABLE_GETTED, body.objectVO );
					
					break;
				}
				
				case PPMPageTargetNames.STRUCTURE:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.DATA_BASE_TABLES_GETTED, body );
				
					break;
				}
					
					
			}
		}
	}
}