package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.controller.names.PPMApplicationTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	
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
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.PAGES_GETTED, body.pages );
					
					break;
				}
					
				case PPMApplicationTargetNames.PAGE:
				{
					if ( operation == PPMOperationNames.CREATE )
						sendNotification( ApplicationFacade.PAGE_CREATED, body );
					else if ( operation == PPMOperationNames.DELETE )
						sendNotification( ApplicationFacade.PAGE_DELETED, body );
					
					break;
				}
					
				case PPMApplicationTargetNames.COPY:
				{
					sendNotification( ApplicationFacade.GET_PAGES, body );
					
					break;
				}
					
				case PPMApplicationTargetNames.REMOTE_CALL:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.REMOTE_CALL_RESPONSE, body.result );
					
					break;
				}
			}
		}
	}
}