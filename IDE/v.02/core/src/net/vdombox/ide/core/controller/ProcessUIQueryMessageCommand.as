package net.vdombox.ide.core.controller
{
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.controller.messages.UIQueryMessage;
	import net.vdombox.ide.common.controller.names.UIQueryMessageNames;
	import net.vdombox.ide.core.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessUIQueryMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : UIQueryMessage = notification.getBody() as UIQueryMessage;

			var name : String = message.name;
			var recipientKey : String = message.recipientKey;
			var component : UIComponent = message.component;

			switch ( name )
			{
				case UIQueryMessageNames.TOOLSET_UI:
				{
					sendNotification( ApplicationFacade.SHOW_MODULE_TOOLSET, { component: component, recipientKey: recipientKey } );

					break;
				}

				case UIQueryMessageNames.SETTINGS_SCREEN_UI:
				{
					sendNotification( ApplicationFacade.SHOW_MODULE_SETTINGS_SCREEN, { component: component, recipientKey: recipientKey } );

					break;
				}

				case UIQueryMessageNames.BODY_UI:
				{
					
					sendNotification( ApplicationFacade.SHOW_MODULE_BODY, { component: component, recipientKey: recipientKey } );

					break;
				}
			}
		}
	}
}