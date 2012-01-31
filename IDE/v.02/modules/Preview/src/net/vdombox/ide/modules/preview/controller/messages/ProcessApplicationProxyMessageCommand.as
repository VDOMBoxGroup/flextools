package net.vdombox.ide.modules.preview.controller.messages
{
	import net.vdombox.ide.common.controller.names.PPMApplicationTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.modules.preview.ApplicationFacade;
	
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
					sendNotification( ApplicationFacade.PAGES_GETTED, body.pages );
					
					break;
				}
					
				case PPMApplicationTargetNames.SERVER_ACTIONS:
				{
					sendNotification( ApplicationFacade.SERVER_ACTIONS_GETTED, body.serverActions );
					
					break;
				}
					
				case PPMApplicationTargetNames.LIBRARY:
				{
					if( operation == PPMOperationNames.CREATE )
						sendNotification( ApplicationFacade.LIBRARY_CREATED, body.libraryVO );
					if( operation == PPMOperationNames.UPDATE )
						sendNotification( ApplicationFacade.LIBRARY_SAVED, body.libraryVO );
					else if( operation == PPMOperationNames.DELETE )
						sendNotification( ApplicationFacade.LIBRARY_DELETED, body.libraryVO );
					
					break;
				}
					
				case PPMApplicationTargetNames.LIBRARIES:
				{
					sendNotification( ApplicationFacade.LIBRARIES_GETTED, body.libraries );
					
					break;
				}
			}
		}
	}
}