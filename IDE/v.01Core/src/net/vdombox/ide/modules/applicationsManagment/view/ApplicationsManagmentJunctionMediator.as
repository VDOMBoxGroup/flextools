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
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;

	public class ApplicationsManagmentJunctionMediator extends LoggingJunctionMediator
	{
		public static const NAME : String = "ApplicationsManagmentJunctionMediator";

		public function ApplicationsManagmentJunctionMediator()
		{
			super( NAME, new Junction());
		}

		override public function handleNotification( note : INotification ) : void
		{
			var pipe : IPipeFitting;
			var type : String = type = note.getType();

			switch ( note.getName())
			{
				case JunctionMediator.ACCEPT_INPUT_PIPE:
				{
					if ( type == PipeNames.STDIN )
					{
						pipe = note.getBody() as IPipeFitting;
						pipe.connect( new PipeListener( this, handlePipeMessage ));
						junction.registerPipe( PipeNames.STDIN, Junction.INPUT, pipe );

						return;
					}

					break;
				}

				case JunctionMediator.ACCEPT_OUTPUT_PIPE:
				{
					if ( type == PipeNames.STDCORE )
					{
						pipe = note.getBody() as IPipeFitting;
						junction.registerPipe( PipeNames.STDCORE, Junction.OUTPUT, pipe );

						//It does not need to be handled by super.
						return;
					}

					break;
				}

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
			}

			/*
			 * Use super for any notifications that do not need special
			 * consideration.
			 */
			super.handleNotification( note );
		}

		override public function handlePipeMessage( message : IPipeMessage ) : void
		{
			var recepientKey : String = message.getBody().toString();
			
			switch ( message.getHeader())
			{
				case MessageHeaders.MODULE_SELECTED:
				{
					var toolsetMediator : ToolsetMediator = facade.retrieveMediator( ToolsetMediator.NAME ) as ToolsetMediator;
					
					if( recepientKey == multitonKey )
						toolsetMediator.selected = true;
					else
						toolsetMediator.selected = false;
				}
			}
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			interests.push( ApplicationFacade.EXPORT_TOOLSET );
			interests.push( ApplicationFacade.EXPORT_MAIN_CONTENT );
			return interests;
		}

		public function tearDown() : void
		{
			junction.removePipe( PipeNames.STDIN );
			junction.removePipe( PipeNames.STDCORE );
		}
	}
}