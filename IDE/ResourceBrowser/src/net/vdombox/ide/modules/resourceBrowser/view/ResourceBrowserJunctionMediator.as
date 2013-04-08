package net.vdombox.ide.modules.resourceBrowser.view
{
	import flash.utils.Dictionary;

	import mx.core.UIComponent;

	import net.vdombox.ide.common.SimpleMessageHeaders;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.controller.messages.LogMessage;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.messages.SimpleMessage;
	import net.vdombox.ide.common.controller.messages.UIQueryMessage;
	import net.vdombox.ide.common.controller.names.PPMApplicationTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMPlaceNames;
	import net.vdombox.ide.common.controller.names.PPMResourcesTargetNames;
	import net.vdombox.ide.common.controller.names.PPMStatesTargetNames;
	import net.vdombox.ide.common.controller.names.PipeNames;
	import net.vdombox.ide.common.controller.names.UIQueryMessageNames;
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.common.model._vo.SettingsVO;
	import net.vdombox.ide.common.view.LoggingJunctionMediator;
	import net.vdombox.ide.modules.resourceBrowser.model.StatesProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;

	public class ResourceBrowserJunctionMediator extends LoggingJunctionMediator
	{
		public static const NAME : String = "ResourceBrowserJunctionMediator";

		public function ResourceBrowserJunctionMediator()
		{
			super( NAME, new Junction() );
		}

		private var recipients : Dictionary;

		override public function onRegister() : void
		{
			recipients = new Dictionary( true );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();


			interests.push( Notifications.BODY_STOP );
			interests.push( Notifications.EXPORT_TOOLSET );
			interests.push( Notifications.EXPORT_SETTINGS_SCREEN );
			interests.push( Notifications.EXPORT_BODY );

			interests.push( SettingsProxy.RETRIEVE_SETTINGS_FROM_STORAGE );
			interests.push( SettingsProxy.SAVE_SETTINGS_TO_STORAGE );

			interests.push( Notifications.SELECT_MODULE );

			interests.push( StatesProxy.GET_ALL_STATES );
			interests.push( StatesProxy.SET_ALL_STATES );

			interests.push( Notifications.GET_RESOURCES );
			interests.push( Notifications.LOAD_RESOURCE );
			interests.push( Notifications.UPLOAD_RESOURCE );
			interests.push( Notifications.DELETE_RESOURCE );
			interests.push( Notifications.GET_ICON );

			interests.push( Notifications.WRITE_ERROR );

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
				case Notifications.BODY_STOP:
				{
					junction.sendMessage( PipeNames.STDCORE, new SimpleMessage( SimpleMessageHeaders.DISCONNECT_PROXIES_PIPE, null, multitonKey ) );

					break;
				}

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

				case Notifications.GET_RESOURCES:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ, PPMResourcesTargetNames.RESOURCES, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case Notifications.LOAD_RESOURCE:
				{
					var recipientKey : String;
					var resourceVO : ResourceVO;

					if ( body is ResourceVO )
					{
						resourceVO = body as ResourceVO;
					}
					else
					{
						recipientKey = body.recipientKey;
						resourceVO = body.resourceVO as ResourceVO;

						if ( !recipients[ resourceVO ] )
							recipients[ resourceVO ] = [];

						recipients[ resourceVO ].push( recipientKey );
					}

					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ, PPMResourcesTargetNames.RESOURCE, resourceVO );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case Notifications.UPLOAD_RESOURCE:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.CREATE, PPMResourcesTargetNames.RESOURCE, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case Notifications.DELETE_RESOURCE:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.DELETE, PPMResourcesTargetNames.RESOURCE, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case Notifications.GET_ICON:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ, PPMResourcesTargetNames.ICON, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case Notifications.WRITE_ERROR:
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.ERROR, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

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
						sendNotification( Notifications.MODULE_SELECTED );
						junction.sendMessage( PipeNames.STDCORE, new SimpleMessage( SimpleMessageHeaders.CONNECT_PROXIES_PIPE, null, multitonKey ) );
					}
					else
					{
						sendNotification( Notifications.MODULE_DESELECTED );
						junction.sendMessage( PipeNames.STDCORE, new SimpleMessage( SimpleMessageHeaders.DISCONNECT_PROXIES_PIPE, null, multitonKey ) );
					}

					break;
				}

				case SimpleMessageHeaders.PROXIES_PIPE_CONNECTED:
				{
					if ( recipientKey != multitonKey )
						return;

					junction.sendMessage( PipeNames.STDLOG, new LogMessage( LogMessage.DEBUG, "Module", SimpleMessageHeaders.PROXIES_PIPE_CONNECTED ) );

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
				case PPMPlaceNames.RESOURCES:
				{
					sendNotification( Notifications.PROCESS_RESOURCES_PROXY_MESSAGE, message );

					break;
				}

				case PPMPlaceNames.STATES:
				{
					sendNotification( StatesProxy.PROCESS_STATES_PROXY_MESSAGE, message );

					break;
				}
			}
		}
	}
}
