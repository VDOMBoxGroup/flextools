package net.vdombox.ide.modules.preview.view
{
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.LogMessage;
	import net.vdombox.ide.common.LoggingJunctionMediator;
	import net.vdombox.ide.common.PPMApplicationTargetNames;
	import net.vdombox.ide.common.PPMObjectTargetNames;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.PPMStatesTargetNames;
	import net.vdombox.ide.common.PPMTypesTargetNames;
	import net.vdombox.ide.common.PipeNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.SimpleMessage;
	import net.vdombox.ide.common.SimpleMessageHeaders;
	import net.vdombox.ide.common.UIQueryMessage;
	import net.vdombox.ide.common.UIQueryMessageNames;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.preview.ApplicationFacade;
	import net.vdombox.ide.modules.preview.model.vo.SettingsVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;

	public class ScriptsJunctionMediator extends LoggingJunctionMediator
	{
		public static const NAME : String = "ScriptsJunctionMediator";

		public function ScriptsJunctionMediator()
		{
			super( NAME, new Junction() );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.EXPORT_TOOLSET );
			interests.push( ApplicationFacade.SELECT_MODULE );
			interests.push( ApplicationFacade.OPEN_WINDOW );
			interests.push( ApplicationFacade.CLOSE_WINDOW );

			 

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var pipe : IPipeFitting;
			var type : String = notification.getType();
			var body : Object = notification.getBody();

			var message : IPipeMessage;

			switch ( notification.getName() )
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
					message = new UIQueryMessage( UIQueryMessageNames.TOOLSET_UI, UIComponent( body ), multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

					break;
				}

			
		
				case ApplicationFacade.OPEN_WINDOW:
				{
					message = new SimpleMessage( SimpleMessageHeaders.OPEN_WINDOW, null, multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

					break;
				}

				case ApplicationFacade.CLOSE_WINDOW:
				{
					message = new SimpleMessage( SimpleMessageHeaders.CLOSE_WINDOW, body, multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

					break;
				}

				case ApplicationFacade.SELECT_MODULE:
				{
					message = new SimpleMessage( SimpleMessageHeaders.OPEN_BROWSER, null, multitonKey );
					
					junction.sendMessage( PipeNames.STDCORE, message );
					
					break;
				}	
		
		
		
		
		
		
					}

			super.handleNotification( notification );
		}

		override public function handlePipeMessage( message : IPipeMessage ) : void
		{
			var simpleMessage : SimpleMessage = message as SimpleMessage;

			var recipientKey : String = simpleMessage.getRecipientKey();

			switch ( simpleMessage.getHeader() )
			{
				case SimpleMessageHeaders.MODULE_SELECTED:
				{
					if ( recipientKey == multitonKey )
					{
//						junction.sendMessage( PipeNames.STDCORE, new SimpleMessage( SimpleMessageHeaders.CONNECT_PROXIES_PIPE, null, multitonKey ) );
					}
					else
					{
//						sendNotification( ApplicationFacade.MODULE_DESELECTED );
//						junction.sendMessage( PipeNames.STDCORE,
//											  new SimpleMessage( SimpleMessageHeaders.DISCONNECT_PROXIES_PIPE, null, multitonKey ) );
					}

					break;
				}

				case SimpleMessageHeaders.PROXIES_PIPE_CONNECTED:
				{
					if ( recipientKey != multitonKey )
						return;

					junction.sendMessage( PipeNames.STDLOG,
										  new LogMessage( LogMessage.DEBUG, multitonKey, SimpleMessageHeaders.PROXIES_PIPE_CONNECTED ) );

					sendNotification( ApplicationFacade.PIPES_READY );
					break;
				}

			}
		}

		public function handleProxyMessage( message : ProxyMessage ) : void
		{
			var place : String = message.proxy;

			switch ( place )
			{
				case PPMPlaceNames.SERVER:
				{
					sendNotification( ApplicationFacade.PROCESS_SERVER_PROXY_MESSAGE, message );

					break;
				}

				case PPMPlaceNames.STATES:
				{
					sendNotification( ApplicationFacade.PROCESS_STATES_PROXY_MESSAGE, message );

					break;
				}

				case PPMPlaceNames.TYPES:
				{
					sendNotification( ApplicationFacade.PROCESS_TYPES_PROXY_MESSAGE, message );

					break;
				}

				case PPMPlaceNames.APPLICATION:
				{
					sendNotification( ApplicationFacade.PROCESS_APPLICATION_PROXY_MESSAGE, message );

					break;
				}

				case PPMPlaceNames.PAGE:
				{
					sendNotification( ApplicationFacade.PROCESS_PAGE_PROXY_MESSAGE, message );

					break;
				}

				case PPMPlaceNames.OBJECT:
				{
					sendNotification( ApplicationFacade.PROCESS_OBJECT_PROXY_MESSAGE, message );

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
					pipe.connect( new PipeListener( this, handlePipeMessage ) );
					junction.registerPipe( PipeNames.STDIN, Junction.INPUT, pipe );

					break;
				}

				case PipeNames.PROXIESIN:
				{
					pipe = notification.getBody() as IPipeFitting;
					pipe.connect( new PipeListener( this, handleProxyMessage ) );
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

				case PipeNames.STDLOG:
				{
					pipe = notification.getBody() as IPipeFitting;
					junction.registerPipe( PipeNames.STDLOG, Junction.OUTPUT, pipe );

					break;
				}

				case PipeNames.PROXIESOUT:
				{
					pipe = notification.getBody() as IPipeFitting;
					junction.registerPipe( PipeNames.PROXIESOUT, Junction.OUTPUT, pipe );

					break;
				}
			}
		}
	}
}