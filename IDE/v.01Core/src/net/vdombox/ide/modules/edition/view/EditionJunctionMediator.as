package net.vdombox.ide.modules.edition.view
{
	import net.vdombox.ide.common.LoggingJunctionMediator;
	import net.vdombox.ide.common.UIQueryMessage;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;

	public class EditionJunctionMediator extends LoggingJunctionMediator
	{
		public static const NAME : String = "ApplicationsManagmentJunctionMediator";

		public function EditionJunctionMediator()
		{
			super( NAME, new Junction() );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
//			interests.push(ApplicationFacade.EXPORT_FEED_WINDOW);
			return interests;
		}

		override public function handleNotification( note : INotification ) : void
		{

			switch ( note.getName())
			{								
				default:
					super.handleNotification( note );

			}
		}

		override public function handlePipeMessage( message : IPipeMessage ) : void
		{
			if ( message is UIQueryMessage )
			{
				//switch ( UIQueryMessage(message).name )
				//{
				//	default:
				//		break;
				//}
			}
		}
	}
}