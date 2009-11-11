package net.vdombox.ide.modules.applicationsManagment.view
{
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.LoggingJunctionMediator;
	import net.vdombox.ide.common.MessageHeaders;
	import net.vdombox.ide.common.PipeNames;
	import net.vdombox.ide.common.UIQueryMessage;
	import net.vdombox.ide.common.UIQueryMessageNames;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;

	public class ApplicationsManagmentJunctionMediator extends LoggingJunctionMediator
	{
		public static const NAME : String = "ApplicationsManagmentJunctionMediator";

		public function ApplicationsManagmentJunctionMediator()
		{
			super( NAME, new Junction());
		}

		override public function handleNotification( note : INotification ) : void
		{
			switch ( note.getName())
			{
				case ApplicationFacade.EXPORT_TOOLSET:
				{
					var toolsetMessage : UIQueryMessage = new UIQueryMessage( UIQueryMessage.SET, UIQueryMessageNames.TOOLSET_UI, UIComponent( note.getBody()));
					junction.sendMessage( PipeNames.STDCORE, toolsetMessage );
					break;
				}
				
				case ApplicationFacade.EXPORT_MAIN_CONTENT:
				{
					var mainContentMessage : UIQueryMessage = new UIQueryMessage( UIQueryMessage.SET, UIQueryMessageNames.MAIN_CONTENT_UI, UIComponent( note.getBody()));
					junction.sendMessage( PipeNames.STDCORE, mainContentMessage );
					break;
				}
				
				default:
					super.handleNotification( note );
			}
		}

		override public function handlePipeMessage( message : IPipeMessage ) : void
		{
			
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			interests.push( ApplicationFacade.EXPORT_TOOLSET );
			interests.push( ApplicationFacade.EXPORT_MAIN_CONTENT );
			return interests;
		}
	}
}