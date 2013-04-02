package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.SimpleMessageHeaders;
	import net.vdombox.ide.common.controller.messages.SimpleMessage;
	import net.vdombox.ide.core.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessSimpleMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : SimpleMessage = notification.getBody() as SimpleMessage;

			var header : String = message.getHeader() as String;
			var recipientKey : String = message.getRecipientKey();
			var body : Object = message.getBody();

			switch ( header )
			{
				case SimpleMessageHeaders.SELECT_MODULE:
				{
					sendNotification( ApplicationFacade.CHANGE_SELECTED_MODULE, recipientKey );
					break;
				}
				case SimpleMessageHeaders.CONNECT_PROXIES_PIPE:
				{
					sendNotification( ApplicationFacade.CONNECT_MODULE_TO_PROXIES, recipientKey );
					break;
				}
				case SimpleMessageHeaders.DISCONNECT_PROXIES_PIPE:
				{
					sendNotification( ApplicationFacade.DISCONNECT_MODULE_TO_PROXIES, recipientKey );
					break;
				}

				case SimpleMessageHeaders.RETRIEVE_SETTINGS_FROM_STORAGE:
				{
					sendNotification( ApplicationFacade.RETRIEVE_MODULE_SETTINGS, message );
					break;
				}

				case SimpleMessageHeaders.SAVE_SETTINGS_TO_STORAGE:
				{
					sendNotification( ApplicationFacade.SAVE_MODULE_SETTINGS, message );
					break;
				}
					
				case SimpleMessageHeaders.OPEN_BROWSER:
				{
					sendNotification( ApplicationFacade.OPEN_PAGE_IN_EXTERNAL_BROWSER );
					break;
				}
					
				case SimpleMessageHeaders.GET_APPLICATIONS_HOSTS:
				{
					sendNotification( ApplicationFacade.SHOW_APPLICATIONS_HOSTS, body );
					break;
				}
			}
		}
	}
}