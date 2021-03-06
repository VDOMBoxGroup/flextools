package net.vdombox.ide.modules.applicationsSearch.view
{
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.LogMessage;
	import net.vdombox.ide.common.LoggingJunctionMediator;
	import net.vdombox.ide.common.MessageHeaders;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.PPMServerTargetNames;
	import net.vdombox.ide.common.PipeNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.UIQueryMessage;
	import net.vdombox.ide.common.UIQueryMessageNames;
	import net.vdombox.ide.modules.applicationsSearch.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;

	public class ApplicationsSearchJunctionMediator extends LoggingJunctionMediator
	{
		public static const NAME : String = "ApplicationsSearchJunctionMediator";

		public function ApplicationsSearchJunctionMediator()
		{
			super( NAME, new Junction());
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			interests.push( ApplicationFacade.EXPORT_TOOLSET );
			interests.push( ApplicationFacade.EXPORT_MAIN_CONTENT );
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var pipe : IPipeFitting;
			var type : String = notification.getType();

			switch ( notification.getName())
			{
				case JunctionMediator.ACCEPT_INPUT_PIPE:
				{
					processInputPipe( notification );
					break;
				}

				case JunctionMediator.ACCEPT_OUTPUT_PIPE:
				{
					processOutputPipe( notification );
					break;
				}

				case ApplicationFacade.EXPORT_TOOLSET:
				{
					var toolsetMessage : UIQueryMessage = 
						new UIQueryMessage( UIQueryMessage.SET, UIQueryMessageNames.TOOLSET_UI, UIComponent( notification.getBody()));
					
					junction.sendMessage( PipeNames.STDCORE, toolsetMessage );
					break;
				}

				case ApplicationFacade.EXPORT_MAIN_CONTENT:
				{
					var mainContentMessage : UIQueryMessage = 
						new UIQueryMessage( UIQueryMessage.SET, UIQueryMessageNames.MAIN_CONTENT_UI, UIComponent( notification.getBody()));
					
					junction.sendMessage( PipeNames.STDCORE, mainContentMessage );
					break;
				}
			}

			super.handleNotification( notification );
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
						sendNotification( ApplicationFacade.MODULE_SELECTED );
					else
						sendNotification( ApplicationFacade.MODULE_DESELECTED );
					
					junction.sendMessage( PipeNames.STDCORE, new Message( Message.NORMAL, MessageHeaders.CONNECT_PROXIES_PIPE, multitonKey));
					break;
				}
				case MessageHeaders.PROXIES_PIPE_CONNECTED:
				{
					if( recepientKey == multitonKey )
					{
						junction.sendMessage( PipeNames.STDLOG, new LogMessage(	LogMessage.DEBUG, "Module", MessageHeaders.PROXIES_PIPE_CONNECTED ) );
						
						junction.sendMessage( 
							PipeNames.PROXIESOUT, 
							new ProxiesPipeMessage( PPMOperationNames.READ, PPMPlaceNames.APPLICATION, PPMServerTargetNames.APPLICATION, { test : "test" } )
							);
						
//						junction.sendMessage( PipeNames.STDCORE, new Message( Message.NORMAL, MessageHeaders.DISCONNECT_PROXIES_PIPE, multitonKey ) );
					}
					break;
				}
			}
		}

		public function tearDown() : void
		{
			junction.removePipe( PipeNames.STDIN );
			junction.removePipe( PipeNames.STDCORE );
		}
		
		private function processInputPipe( notification : INotification ) : void
		{
			var pipe : IPipeFitting;
			var type : String = notification.getType() as String;
			
			switch ( type )
			{
				case PipeNames.STDIN:
				{
					pipe = notification.getBody() as IPipeFitting;
					pipe.connect( new PipeListener( this, handlePipeMessage ));
					junction.registerPipe( PipeNames.STDIN, Junction.INPUT, pipe );
					
					break;
				}
				
				case  PipeNames.PROXIESIN:
				{
					pipe = notification.getBody() as IPipeFitting;
					pipe.connect( new PipeListener( this, handlePipeMessage ));
					junction.registerPipe( PipeNames.PROXIESIN, Junction.INPUT, pipe );
					
					break;
				}
			}	
		}
		
		private function processOutputPipe( notification : INotification ) : void
		{
			var pipe : IPipeFitting;
			var type : String = notification.getType() as String;
			
			switch ( type )
			{
				case PipeNames.STDCORE:
				{
					pipe = notification.getBody() as IPipeFitting;
					junction.registerPipe( PipeNames.STDCORE, Junction.OUTPUT, pipe );
					
					break;
				}
					
				case PipeNames.PROXIESOUT:
				{
					pipe = notification.getBody() as IPipeFitting;
					junction.registerPipe( PipeNames.PROXIESOUT, Junction.OUTPUT, pipe );
					
					break;
				}
				
				case PipeNames.STDLOG:
				{
					pipe = notification.getBody() as IPipeFitting;
					junction.registerPipe( PipeNames.STDLOG, Junction.OUTPUT, pipe );
					
					break;
				}
			}
		}
	}
}