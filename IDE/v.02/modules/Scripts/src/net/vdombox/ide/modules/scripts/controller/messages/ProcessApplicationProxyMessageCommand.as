package net.vdombox.ide.modules.scripts.controller.messages
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMApplicationTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessApplicationProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;

			var applicationVO : ApplicationVO;

			if ( body is ApplicationVO )
				applicationVO = body as ApplicationVO;
			else if ( body.hasOwnProperty( "applicationVO" ) )
				applicationVO = body.applicationVO as ApplicationVO;
			else
				throw new Error( "no application VO" );

			switch ( target )
			{
				case PPMApplicationTargetNames.PAGES:
				{
					sendNotification( Notifications.PAGES_GETTED, body.pages );
					
					break;
				}
					
				case PPMApplicationTargetNames.SERVER_ACTIONS:
				{
					sendNotification( Notifications.SERVER_ACTIONS_GETTED, body );
					
					break;
				}
					
				case PPMApplicationTargetNames.LIBRARY:
				{
					if( operation == PPMOperationNames.CREATE )
						sendNotification( Notifications.LIBRARY_CREATED, body.libraryVO );
					if( operation == PPMOperationNames.UPDATE )
						sendNotification( Notifications.LIBRARY_SAVED, body.libraryVO );
					else if( operation == PPMOperationNames.DELETE )
						sendNotification( Notifications.LIBRARY_DELETED, body.libraryVO );
					
					break;
				}
					
				case PPMApplicationTargetNames.LIBRARIES:
				{
					sendNotification( Notifications.LIBRARIES_GETTED, body.libraries );
					
					break;
				}
					
				case PPMApplicationTargetNames.SERVER_ACTIONS_LIST:
				{
					sendNotification( Notifications.GLOBAL_ACTIONS_GETTED, body );
					
					break;
				}
			}
		}
	}
}