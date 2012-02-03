package net.vdombox.ide.modules.tree.view
{
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.SimpleMessageHeaders;
	import net.vdombox.ide.common.controller.messages.LogMessage;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.messages.SimpleMessage;
	import net.vdombox.ide.common.controller.messages.UIQueryMessage;
	import net.vdombox.ide.common.controller.names.PPMApplicationTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMPageTargetNames;
	import net.vdombox.ide.common.controller.names.PPMPlaceNames;
	import net.vdombox.ide.common.controller.names.PPMResourcesTargetNames;
	import net.vdombox.ide.common.controller.names.PPMStatesTargetNames;
	import net.vdombox.ide.common.controller.names.PPMTypesTargetNames;
	import net.vdombox.ide.common.controller.names.PipeNames;
	import net.vdombox.ide.common.controller.names.UIQueryMessageNames;
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.SettingsVO;
	import net.vdombox.ide.common.view.LoggingJunctionMediator;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.StatesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;
	
	public class TreeJunctionMediator extends LoggingJunctionMediator
	{
		public static const NAME : String = "TreeJunctionMediator";

		public function TreeJunctionMediator()
		{
			super( NAME, new Junction() );
		}

		private var statesProxy : StatesProxy;

		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
		}

		override public function onRemove() : void
		{
			statesProxy = null;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.EXPORT_TOOLSET );
			interests.push( ApplicationFacade.EXPORT_SETTINGS_SCREEN );
			interests.push( ApplicationFacade.EXPORT_BODY );

			interests.push( SettingsProxy.RETRIEVE_SETTINGS_FROM_STORAGE );
			interests.push( SettingsProxy.SAVE_SETTINGS_TO_STORAGE );

			interests.push( ApplicationFacade.SELECT_MODULE );

			interests.push( StatesProxy.GET_ALL_STATES );
			interests.push( StatesProxy.SET_ALL_STATES );

			interests.push( ApplicationFacade.GET_RESOURCES );
			interests.push( ApplicationFacade.LOAD_RESOURCE );
			
			interests.push( ApplicationFacade.GET_APPLICATION_STRUCTURE );
			interests.push( ApplicationFacade.SET_APPLICATION_STRUCTURE );
			
			interests.push( ApplicationFacade.SET_APPLICATION_INFORMATION );
			
			interests.push( ApplicationFacade.GET_PAGES );

			interests.push( TypesProxy.GET_TYPE );
			interests.push( TypesProxy.GET_TOP_LEVEL_TYPES );

			interests.push( ApplicationFacade.GET_RESOURCE );

			interests.push( ApplicationFacade.GET_PAGE_ATTRIBUTES );
			interests.push( ApplicationFacade.SET_PAGE_ATTRIBUTES );

			interests.push( ApplicationFacade.SET_PAGE_NAME );
			
			interests.push( ApplicationFacade.OPEN_WINDOW );
			interests.push( ApplicationFacade.CLOSE_WINDOW );

			interests.push( StatesProxy.SET_SELECTED_PAGE );

			interests.push( ApplicationFacade.CREATE_PAGE );
			interests.push( ApplicationFacade.DELETE_PAGE );

			interests.push( ApplicationFacade.SEND_TO_LOG );
			interests.push( ApplicationFacade.BODY_STOP );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var pipe : IPipeFitting;
			var type : String = notification.getType();
			var body : Object = notification.getBody();

			var message : IPipeMessage;

			var pageAttributesRecipientID : String;
			var pageVO : PageVO;
			var pageAttributesSessionName : String; //not used
			var pageAttributesRecipients : Object; //not used

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
					// send self body
					message = new UIQueryMessage( UIQueryMessageNames.BODY_UI, UIComponent( body ), multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );
					
					// tell to IDECore need to connet proxies pipe
					junction.sendMessage( PipeNames.STDCORE, new SimpleMessage( SimpleMessageHeaders.CONNECT_PROXIES_PIPE, null, multitonKey ) );


					break;
				}

				case SettingsProxy.RETRIEVE_SETTINGS_FROM_STORAGE:
				{
					message = new SimpleMessage( SimpleMessageHeaders.RETRIEVE_SETTINGS_FROM_STORAGE, null, multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

					break;
				}

				case SettingsProxy.SAVE_SETTINGS_TO_STORAGE:
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

				case StatesProxy.GET_ALL_STATES:
				{
					message = new ProxyMessage( PPMPlaceNames.STATES, PPMOperationNames.READ, PPMStatesTargetNames.ALL_STATES, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case StatesProxy.SET_ALL_STATES:
				{
					message = new ProxyMessage( PPMPlaceNames.STATES, PPMOperationNames.UPDATE, PPMStatesTargetNames.ALL_STATES, body );
					
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

				case ApplicationFacade.GET_RESOURCES:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ, PPMResourcesTargetNames.RESOURCES, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.LOAD_RESOURCE:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ, PPMResourcesTargetNames.RESOURCE, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.GET_APPLICATION_STRUCTURE:
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.STRUCTURE, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}
					
				case ApplicationFacade.SET_APPLICATION_STRUCTURE:
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.UPDATE, PPMApplicationTargetNames.STRUCTURE, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.SET_APPLICATION_INFORMATION:
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.UPDATE, PPMApplicationTargetNames.INFORMATION, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}

				case ApplicationFacade.GET_PAGES:
				{
					
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.PAGES, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case TypesProxy.GET_TYPE:
				{
					var typeRecipientID : String = body.recipientID;
					var typeID : String = body.typeID;

					var typesSessionName : String = PPMPlaceNames.TYPES + ApplicationFacade.DELIMITER + PPMOperationNames.READ +
						ApplicationFacade.DELIMITER + PPMTypesTargetNames.TYPE;

					var typeRecipients : Object = statesProxy.getObject( typesSessionName );

					if ( !typeRecipients.hasOwnProperty( typeID ) )
						typeRecipients[ typeID ] = [];

					typeRecipients[ typeID ].push( typeRecipientID );

					message = new ProxyMessage( PPMPlaceNames.TYPES, PPMOperationNames.READ, PPMTypesTargetNames.TYPE, typeID );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case TypesProxy.GET_TOP_LEVEL_TYPES:
				{
					message = new ProxyMessage( PPMPlaceNames.TYPES, PPMOperationNames.READ, PPMTypesTargetNames.TOP_LEVEL_TYPES, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.GET_RESOURCE:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ, PPMResourcesTargetNames.RESOURCE, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.GET_PAGE_ATTRIBUTES:
				{
					pageAttributesRecipientID = body.recipientID;
					pageVO = body.pageVO;
					
					pageAttributesSessionName = PPMPlaceNames.PAGE + ApplicationFacade.DELIMITER + PPMOperationNames.READ +
						ApplicationFacade.DELIMITER + PPMPageTargetNames.ATTRIBUTES;
					
					pageAttributesRecipients = statesProxy.getObject( pageAttributesSessionName );

					if ( !pageAttributesRecipients.hasOwnProperty( pageVO.id ) )
						pageAttributesRecipients[ pageVO.id ] = [];

					pageAttributesRecipients[ pageVO.id ].push( pageAttributesRecipientID );

					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.ATTRIBUTES, pageVO );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.SET_PAGE_ATTRIBUTES:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.UPDATE, PPMPageTargetNames.ATTRIBUTES, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}
					
				case ApplicationFacade.SET_PAGE_NAME:
				{
					if ( body is PageVO )
						message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.UPDATE, PPMPageTargetNames.NAME, body );
					
					if ( message )
						junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}

				case StatesProxy.SET_SELECTED_PAGE:
				{
					message = new ProxyMessage( PPMPlaceNames.STATES, PPMOperationNames.UPDATE, PPMStatesTargetNames.SELECTED_PAGE, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.CREATE_PAGE:
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.CREATE, PPMApplicationTargetNames.PAGE, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.DELETE_PAGE:
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.DELETE, PPMApplicationTargetNames.PAGE, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.SEND_TO_LOG:
				{
					message = new LogMessage( LogMessage.DEBUG, multitonKey, body.toString() );

					junction.sendMessage( PipeNames.STDLOG, message );

					break;
				}

				case ApplicationFacade.BODY_STOP :
				{
					junction.sendMessage( PipeNames.STDCORE,
						new SimpleMessage( SimpleMessageHeaders.DISCONNECT_PROXIES_PIPE, null, multitonKey ) );
				
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
					if ( recipientKey != multitonKey )
						return;
				
//					sendNotification( ApplicationFacade.MODULE_SELECTED );
//					junction.sendMessage( PipeNames.STDCORE, new SimpleMessage( SimpleMessageHeaders.CONNECT_PROXIES_PIPE, null, multitonKey ) );

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

					sendNotification( SettingsProxy.SAVE_SETTINGS_TO_PROXY, settingsVO );

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
			junction.removePipe( PipeNames.STDOUT );
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

		private function handleProxyMessage( message : ProxyMessage ) : void
		{
			var place : String = message.proxy;

			switch ( place )
			{
				case PPMPlaceNames.SERVER:
				{
					sendNotification( ApplicationFacade.PROCESS_SERVER_PROXY_MESSAGE, message );
					break;
				}

				case PPMPlaceNames.TYPES:
				{
					sendNotification( TypesProxy.PROCESS_TYPES_PROXY_MESSAGE, message );
					break;
				}

				case PPMPlaceNames.RESOURCES:
				{
					sendNotification( ApplicationFacade.PROCESS_RESOURCES_PROXY_MESSAGE, message );
					break;
				}

				case PPMPlaceNames.STATES:
				{
					sendNotification( StatesProxy.PROCESS_STATES_PROXY_MESSAGE, message );
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
			}
		}
	}
}