package net.vdombox.ide.modules.dataBase.controller.messages
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMPageTargetNames;
	import net.vdombox.ide.common.model.StatesProxy;
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
					else if ( operation == PPMOperationNames.CREATE )
					{
						sendNotification( ApplicationFacade.OBJECT_CREATED, body.objectVO );
					}
					else if ( operation == PPMOperationNames.DELETE )
					{
						sendNotification( ApplicationFacade.GET_OBJECTS, body.pageVO );
						sendNotification( ApplicationFacade.OBJECT_DELETED, body.objectVO );
						sendNotification( ApplicationFacade.GET_DATA_BASE_TABLES, body.pageVO );
					}
					break;
				}
					
				case PPMPageTargetNames.OBJECTS:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.OBJECTS_GETTED, body );

					break;
				}
				
				case PPMPageTargetNames.STRUCTURE:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.DATA_BASE_TABLES_GETTED, body );
				
					break;
				}
					
				case PPMPageTargetNames.REMOTE_CALL:
				{
					if ( operation == PPMOperationNames.READ )
					{
						if ( body.hasOwnProperty("result") )
							sendNotification( ApplicationFacade.REMOTE_CALL_RESPONSE, body );
						else
							sendNotification( ApplicationFacade.REMOTE_CALL_RESPONSE_ERROR, body );
					}
					
					break;
				}
					
				case PPMPageTargetNames.NAME:
				{
					if ( operation == PPMOperationNames.UPDATE )
					{
						sendNotification( ApplicationFacade.PAGE_NAME_SETTED, body );
					}
					break;
				}
					
					
			}
		}
	}
}