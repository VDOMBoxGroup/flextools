package net.vdombox.ide.modules.events.view
{
	import mx.core.UIComponent;

	import net.vdombox.ide.common.SimpleMessageHeaders;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.controller.messages.LogMessage;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.messages.SimpleMessage;
	import net.vdombox.ide.common.controller.messages.UIQueryMessage;
	import net.vdombox.ide.common.controller.names.PPMApplicationTargetNames;
	import net.vdombox.ide.common.controller.names.PPMObjectTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMPageTargetNames;
	import net.vdombox.ide.common.controller.names.PPMPlaceNames;
	import net.vdombox.ide.common.controller.names.PPMResourcesTargetNames;
	import net.vdombox.ide.common.controller.names.PPMStatesTargetNames;
	import net.vdombox.ide.common.controller.names.PPMTypesTargetNames;
	import net.vdombox.ide.common.controller.names.PipeNames;
	import net.vdombox.ide.common.controller.names.UIQueryMessageNames;
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.ApplicationEventsVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.SettingsVO;
	import net.vdombox.ide.common.view.LoggingJunctionMediator;
	import net.vdombox.ide.modules.events.model.MessageProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;

	public class EventsJunctionMediator extends LoggingJunctionMediator
	{
		public static const NAME : String = "EventsJunctionMediator";

		private var messageProxy : MessageProxy;

		public function EventsJunctionMediator()
		{
			super( NAME, new Junction() );
		}

		override public function onRegister() : void
		{
			messageProxy = facade.retrieveProxy( MessageProxy.NAME ) as MessageProxy;
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( Notifications.EXPORT_TOOLSET );
			interests.push( Notifications.EXPORT_SETTINGS_SCREEN );
			interests.push( Notifications.EXPORT_BODY );

			interests.push( SettingsProxy.RETRIEVE_SETTINGS_FROM_STORAGE );
			interests.push( SettingsProxy.SAVE_SETTINGS_TO_STORAGE );

			interests.push( Notifications.SELECT_MODULE );

			interests.push( StatesProxy.GET_ALL_STATES );
			interests.push( StatesProxy.SET_ALL_STATES );

			interests.push( StatesProxy.SET_SELECTED_PAGE );
			interests.push( StatesProxy.SET_SELECTED_OBJECT );

			interests.push( Notifications.GET_SERVER_ACTIONS_LIST );

			interests.push( Notifications.GET_APPLICATION_EVENTS );
			interests.push( Notifications.SET_APPLICATION_EVENTS );

			interests.push( Notifications.GET_PAGE_SRUCTURE );

			interests.push( Notifications.GET_PAGES );

			interests.push( Notifications.GET_OBJECT );
			interests.push( Notifications.BODY_STOP );

			interests.push( Notifications.LOAD_RESOURCE );
			interests.push( TypesProxy.GET_TYPES );

			interests.push( Notifications.GET_SERVER_ACTIONS );

			interests.push( Notifications.UNDO );
			interests.push( Notifications.REDO );

			interests.push( Notifications.SET_MESSAGE );

			interests.push( Notifications.SAVE_IN_WORKAREA_CHECKED );

			interests.push( Notifications.CREATE_SERVER_ACTION );

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

				case Notifications.EXPORT_TOOLSET:
				{
					message = new UIQueryMessage( UIQueryMessageNames.TOOLSET_UI, UIComponent( body ), multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

					break;
				}

				case Notifications.EXPORT_SETTINGS_SCREEN:
				{
					message = new UIQueryMessage( UIQueryMessageNames.SETTINGS_SCREEN_UI, UIComponent( body ), multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

					break;
				}

				case Notifications.EXPORT_BODY:
				{
					message = new UIQueryMessage( UIQueryMessageNames.BODY_UI, UIComponent( body ), multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

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

				case Notifications.SELECT_MODULE:
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

				case StatesProxy.SET_SELECTED_PAGE:
				{
					message = new ProxyMessage( PPMPlaceNames.STATES, PPMOperationNames.UPDATE, PPMStatesTargetNames.SELECTED_PAGE, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case StatesProxy.SET_SELECTED_OBJECT:
				{
					message = new ProxyMessage( PPMPlaceNames.STATES, PPMOperationNames.UPDATE, PPMStatesTargetNames.SELECTED_OBJECT, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case Notifications.GET_PAGES:
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.PAGES, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case Notifications.GET_OBJECT:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.OBJECT, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case Notifications.GET_APPLICATION_EVENTS:
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.EVENTS, body );
					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case Notifications.SET_APPLICATION_EVENTS:
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.UPDATE, PPMApplicationTargetNames.EVENTS, body );
					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case Notifications.GET_PAGE_SRUCTURE:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.STRUCTURE, body );
					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case Notifications.GET_SERVER_ACTIONS_LIST:
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

				case Notifications.BODY_STOP:
				{
					junction.sendMessage( PipeNames.STDCORE, new SimpleMessage( SimpleMessageHeaders.DISCONNECT_PROXIES_PIPE, null, multitonKey ) );

					break;
				}

				case Notifications.LOAD_RESOURCE:
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

				case Notifications.GET_SERVER_ACTIONS:
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

				case Notifications.UNDO:
				{
					if ( messageProxy.hasUndo( body as PageVO ) )
						sendNotification( Notifications.UNDO_REDO_GETTED, messageProxy.getUndo( body as PageVO ) );

					break;
				}

				case Notifications.REDO:
				{
					if ( messageProxy.hasRedo( body as PageVO ) )
						sendNotification( Notifications.UNDO_REDO_GETTED, messageProxy.getRedo( body as PageVO ) );

					break;
				}

				case Notifications.SET_MESSAGE:
				{
					messageProxy.push( body.pageVO, body as ApplicationEventsVO );

					break;
				}

				case Notifications.SAVE_IN_WORKAREA_CHECKED:
				{
					if ( !body.object )
					{
						message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.SAVED, body );

						if ( message )
							junction.sendMessage( PipeNames.PROXIESOUT, message );
					}

					break;
				}

				case Notifications.CREATE_SERVER_ACTION:
				{
					if ( body.hasOwnProperty( "objectVO" ) )
						message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.CREATE, PPMObjectTargetNames.SERVER_ACTION, body );
					else if ( body.hasOwnProperty( "pageVO" ) )
						message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.CREATE, PPMPageTargetNames.SERVER_ACTION, body );

					if ( message )
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

					junction.sendMessage( PipeNames.STDLOG, new LogMessage( LogMessage.DEBUG, multitonKey, SimpleMessageHeaders.PROXIES_PIPE_CONNECTED ) );

					sendNotification( Notifications.PIPES_READY );

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

		public function handleProxyMessage( message : ProxyMessage ) : void
		{
			var proxy : String = message.proxy;

			switch ( proxy )
			{
				case PPMPlaceNames.APPLICATION:
				{
					sendNotification( Notifications.PROCESS_APPLICATION_PROXY_MESSAGE, message );

					break;
				}

				case PPMPlaceNames.PAGE:
				{
					sendNotification( Notifications.PROCESS_PAGE_PROXY_MESSAGE, message );

					break;
				}

				case PPMPlaceNames.OBJECT:
				{
					sendNotification( Notifications.PROCESS_OBJECT_PROXY_MESSAGE, message );

					break;
				}

				case PPMPlaceNames.TYPES:
				{
					sendNotification( TypesProxy.PROCESS_TYPES_PROXY_MESSAGE, message );

					break;
				}

				case PPMPlaceNames.STATES:
				{
					sendNotification( StatesProxy.PROCESS_STATES_PROXY_MESSAGE, message );

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
