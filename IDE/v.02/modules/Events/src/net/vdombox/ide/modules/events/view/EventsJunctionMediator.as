package net.vdombox.ide.modules.events.view
{
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.controller.messages.LogMessage;
	import net.vdombox.ide.common.view.LoggingJunctionMediator;
	import net.vdombox.ide.common.controller.names.PPMApplicationTargetNames;
	import net.vdombox.ide.common.controller.names.PPMObjectTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMPageTargetNames;
	import net.vdombox.ide.common.controller.names.PPMPlaceNames;
	import net.vdombox.ide.common.controller.names.PPMResourcesTargetNames;
	import net.vdombox.ide.common.controller.names.PPMStatesTargetNames;
	import net.vdombox.ide.common.controller.names.PPMTypesTargetNames;
	import net.vdombox.ide.common.controller.names.PipeNames;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.messages.SimpleMessage;
	import net.vdombox.ide.common.SimpleMessageHeaders;
	import net.vdombox.ide.common.controller.messages.UIQueryMessage;
	import net.vdombox.ide.common.controller.names.UIQueryMessageNames;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	import net.vdombox.ide.modules.events.model.SessionProxy;
	import net.vdombox.ide.modules.events.model.vo.SettingsVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;

	public class EventsJunctionMediator extends LoggingJunctionMediator
	{
		public static const NAME : String = "EventsJunctionMediator";

		public function EventsJunctionMediator()
		{
			super( NAME, new Junction() );
		}

		private var sessionProxy : SessionProxy;
		
		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
		}
		
		override public function onRemove() : void
		{
			sessionProxy = null;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.EXPORT_TOOLSET );
			interests.push( ApplicationFacade.EXPORT_SETTINGS_SCREEN );
			interests.push( ApplicationFacade.EXPORT_BODY );

			interests.push( ApplicationFacade.RETRIEVE_SETTINGS_FROM_STORAGE );
			interests.push( ApplicationFacade.SAVE_SETTINGS_TO_STORAGE );

			interests.push( ApplicationFacade.SELECT_MODULE );

			interests.push( ApplicationFacade.GET_ALL_STATES );
			interests.push( ApplicationFacade.SET_ALL_STATES );
			
			interests.push( ApplicationFacade.SET_SELECTED_PAGE );
			interests.push( ApplicationFacade.SET_SELECTED_OBJECT );
			
			interests.push( ApplicationFacade.GET_SERVER_ACTIONS_LIST );
			
			interests.push( ApplicationFacade.GET_APPLICATION_EVENTS );
			interests.push( ApplicationFacade.SET_APPLICATION_EVENTS );
			
			interests.push( ApplicationFacade.GET_PAGE_SRUCTURE );

			interests.push( ApplicationFacade.GET_PAGES );
			
			interests.push( ApplicationFacade.GET_OBJECT );
			interests.push( ApplicationFacade.BODY_STOP );
			
			interests.push( ApplicationFacade.LOAD_RESOURCE );
			interests.push( TypesProxy.GET_TYPES );
			
			interests.push( ApplicationFacade.OPEN_WINDOW );
			interests.push( ApplicationFacade.CLOSE_WINDOW );
			
			interests.push( ApplicationFacade.GET_SERVER_ACTIONS );
			interests.push( ApplicationFacade.SET_SERVER_ACTIONS );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var pipe : IPipeFitting;
			var type : String = notification.getType();
			var body : Object = notification.getBody();

			var message : IPipeMessage;
			
			var placeName : String;
			var targetName : String;

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

				case ApplicationFacade.EXPORT_SETTINGS_SCREEN:
				{
					message = new UIQueryMessage( UIQueryMessageNames.SETTINGS_SCREEN_UI, UIComponent( body ), multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

					break;
				}

				case ApplicationFacade.EXPORT_BODY:
				{
					message = new UIQueryMessage( UIQueryMessageNames.BODY_UI, UIComponent( body ), multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );
					
					junction.sendMessage( PipeNames.STDCORE, new SimpleMessage( SimpleMessageHeaders.CONNECT_PROXIES_PIPE, null, multitonKey ) );

					break;
				}

				case ApplicationFacade.RETRIEVE_SETTINGS_FROM_STORAGE:
				{
					message = new SimpleMessage( SimpleMessageHeaders.RETRIEVE_SETTINGS_FROM_STORAGE, null, multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

					break;
				}

				case ApplicationFacade.SAVE_SETTINGS_TO_STORAGE:
				{
					message = new SimpleMessage( SimpleMessageHeaders.SAVE_SETTINGS_TO_STORAGE, body, multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

					break;
				}

				case ApplicationFacade.SELECT_MODULE:
				{
					message = new SimpleMessage( SimpleMessageHeaders.SELECT_MODULE, null, multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

					break;
				}

				case ApplicationFacade.GET_ALL_STATES:
				{
					message = new ProxyMessage( PPMPlaceNames.STATES, PPMOperationNames.READ, PPMStatesTargetNames.ALL_STATES, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}
					
				case ApplicationFacade.SET_ALL_STATES:
				{
					message = new ProxyMessage( PPMPlaceNames.STATES, PPMOperationNames.UPDATE, PPMStatesTargetNames.ALL_STATES, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}

				case ApplicationFacade.SET_SELECTED_PAGE:
				{					
					message = new ProxyMessage( PPMPlaceNames.STATES, PPMOperationNames.UPDATE, PPMStatesTargetNames.SELECTED_PAGE, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.SET_SELECTED_OBJECT:
				{
					message = new ProxyMessage( PPMPlaceNames.STATES, PPMOperationNames.UPDATE, PPMStatesTargetNames.SELECTED_OBJECT, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.GET_PAGES:
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.PAGES, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}
					
				case ApplicationFacade.GET_OBJECT:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.OBJECT, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.GET_APPLICATION_EVENTS:
				{
					message = new ProxyMessage(  PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.EVENTS, body );
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.SET_APPLICATION_EVENTS:
				{
					message = new ProxyMessage(  PPMPlaceNames.APPLICATION, PPMOperationNames.UPDATE, PPMApplicationTargetNames.EVENTS, body );
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.GET_PAGE_SRUCTURE:
				{
					message = new ProxyMessage(  PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.STRUCTURE, body );
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.GET_SERVER_ACTIONS_LIST:
				{
					
					if ( body is ObjectVO )
					{
						placeName = PPMPlaceNames.OBJECT;
						targetName = PPMObjectTargetNames.SERVER_ACTIONS_LIST;
					}
					else if ( body is PageVO )
					{
						placeName = PPMPlaceNames.PAGE;
						targetName = PPMPageTargetNames.SERVER_ACTIONS_LIST
					}
					
					if ( placeName && targetName )
					{
						message = new ProxyMessage( placeName, PPMOperationNames.READ, targetName, body );
						junction.sendMessage( PipeNames.PROXIESOUT, message );
					}
					
					break;
				}
					
				case ApplicationFacade.BODY_STOP :
				{
					junction.sendMessage( PipeNames.STDCORE,
						new SimpleMessage( SimpleMessageHeaders.DISCONNECT_PROXIES_PIPE, null, multitonKey ) );
					
					break;
				}		
					
				case ApplicationFacade.LOAD_RESOURCE:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ, PPMResourcesTargetNames.RESOURCE, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case TypesProxy.GET_TYPES:
				{
					message = new ProxyMessage( PPMPlaceNames.TYPES, PPMOperationNames.READ, PPMTypesTargetNames.TYPES );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.OPEN_WINDOW:
				{
					message = new SimpleMessage( SimpleMessageHeaders.OPEN_WINDOW, body, multitonKey );
					
					junction.sendMessage( PipeNames.STDCORE, message );
					
					break;
				}
					
				case ApplicationFacade.CLOSE_WINDOW:
				{
					message = new SimpleMessage( SimpleMessageHeaders.CLOSE_WINDOW, body, multitonKey );
					
					junction.sendMessage( PipeNames.STDCORE, message );
					
					break;
				}
					
				case ApplicationFacade.GET_SERVER_ACTIONS:
				{
					
					if ( body is ObjectVO )
					{
						placeName = PPMPlaceNames.OBJECT;
						targetName = PPMObjectTargetNames.SERVER_ACTIONS;
					}
					else if ( body is PageVO )
					{
						placeName = PPMPlaceNames.PAGE;
						targetName = PPMPageTargetNames.SERVER_ACTIONS;
					}
					
					if ( placeName && targetName )
					{
						message = new ProxyMessage( placeName, PPMOperationNames.READ, targetName, body );
						junction.sendMessage( PipeNames.PROXIESOUT, message );
					}
					
					break;
				}
					
				case ApplicationFacade.SET_SERVER_ACTIONS:
				{
					if ( body.hasOwnProperty( "objectVO" ) )
						message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.UPDATE, PPMObjectTargetNames.SERVER_ACTIONS_LIST, body );
					else if ( body.hasOwnProperty( "pageVO" ) )
						message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.UPDATE, PPMPageTargetNames.SERVER_ACTIONS_LIST, body );
					
					if( message )
						junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break
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
					if ( recipientKey != multitonKey )
						return;

					
//					junction.sendMessage( PipeNames.STDCORE, new SimpleMessage( SimpleMessageHeaders.CONNECT_PROXIES_PIPE, null, multitonKey ) );
//					
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

				case SimpleMessageHeaders.RETRIEVE_SETTINGS_FROM_STORAGE:
				{
					if ( recipientKey != multitonKey )
						return;

					var settingsVO : SettingsVO = new SettingsVO( simpleMessage.getBody() );

					sendNotification( ApplicationFacade.SAVE_SETTINGS_TO_PROXY, settingsVO );

					break;
				}
			}
		}

		public function handleProxyMessage( message : ProxyMessage ) : void
		{
			var proxy : String = message.proxy;

			switch ( proxy )
			{
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

				case PPMPlaceNames.RESOURCES:
				{
					sendNotification( ApplicationFacade.PROCESS_RESOURCES_PROXY_MESSAGE, message );

					break;
				}

				case PPMPlaceNames.TYPES:
				{
					sendNotification( TypesProxy.PROCESS_TYPES_PROXY_MESSAGE, message );

					break;
				}

				case PPMPlaceNames.STATES:
				{
					sendNotification( ApplicationFacade.PROCESS_STATES_PROXY_MESSAGE, message );

					break;
				}
			}
		}

		public function tearDown() : void
		{
			junction.removePipe( PipeNames.PROXIESIN );
			junction.removePipe( PipeNames.PROXIESOUT );
			junction.removePipe( PipeNames.STDCORE );
			junction.removePipe( PipeNames.STDIN );
			junction.removePipe( PipeNames.STDLOG );
			//junction.removePipe( PipeNames.STDOUT );
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