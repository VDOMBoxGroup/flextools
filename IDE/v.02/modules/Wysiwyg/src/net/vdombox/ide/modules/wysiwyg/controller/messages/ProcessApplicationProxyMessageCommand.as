package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMApplicationTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.modules.wysiwyg.model.MultiObjectsManipulationProxy;

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
						sendNotification( Notifications.PAGES_GETTED, body.pages );

					break;
				}

				case PPMApplicationTargetNames.PAGE:
				{
					if ( operation == PPMOperationNames.CREATE )
						sendNotification( Notifications.PAGE_CREATED, body );
					else if ( operation == PPMOperationNames.DELETE )
						sendNotification( Notifications.PAGE_DELETED, body );

					break;
				}

				case PPMApplicationTargetNames.COPY:
				{
					var multiObjectsManipulationProxy : MultiObjectsManipulationProxy = facade.retrieveProxy( MultiObjectsManipulationProxy.NAME ) as MultiObjectsManipulationProxy;

					if ( multiObjectsManipulationProxy.hasNextObjectForPaste() )
						multiObjectsManipulationProxy.pasteNextObject();

					sendNotification( Notifications.GET_PAGES, body );

					break;
				}

				case PPMApplicationTargetNames.COPY_ERROR:
				{
					multiObjectsManipulationProxy = facade.retrieveProxy( MultiObjectsManipulationProxy.NAME ) as MultiObjectsManipulationProxy;

					if ( multiObjectsManipulationProxy.hasNextObjectForPaste() )
						multiObjectsManipulationProxy.pasteNextObject();
				}

				case PPMApplicationTargetNames.REMOTE_CALL:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( Notifications.REMOTE_CALL_RESPONSE, body.result );

					break;
				}
			}
		}
	}
}
