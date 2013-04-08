package net.vdombox.ide.modules.dataBase.controller.messages
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMObjectTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;

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

			switch ( target )
			{
				case PPMObjectTargetNames.REMOTE_CALL:
				{
					if ( operation == PPMOperationNames.READ )
					{
						if ( body.hasOwnProperty( "result" ) )
							sendNotification( Notifications.REMOTE_CALL_RESPONSE, body );
						else
							sendNotification( Notifications.REMOTE_CALL_RESPONSE_ERROR, body );
					}

					break;
				}

				case PPMObjectTargetNames.ATTRIBUTES:
				{
					var vdomObjectAttributesVO : VdomObjectAttributesVO = body.vdomObjectAttributesVO as VdomObjectAttributesVO;

					sendNotification( Notifications.OBJECT_ATTRIBUTES_GETTED, body );


					break;
				}

				case PPMObjectTargetNames.NAME:
				{
					if ( operation == PPMOperationNames.UPDATE )
					{
						sendNotification( Notifications.OBJECT_NAME_SETTED, body );
					}
					break;
				}
			}
		}
	}
}
