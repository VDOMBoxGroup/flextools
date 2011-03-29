package net.vdombox.ide.modules.applicationsManagment.view
{
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.LogMessage;
	import net.vdombox.ide.common.LoggingJunctionMediator;
	import net.vdombox.ide.common.PPMApplicationTargetNames;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.PPMResourcesTargetNames;
	import net.vdombox.ide.common.PPMServerTargetNames;
	import net.vdombox.ide.common.PPMStatesTargetNames;
	import net.vdombox.ide.common.PPMTypesTargetNames;
	import net.vdombox.ide.common.PipeNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.SimpleMessage;
	import net.vdombox.ide.common.SimpleMessageHeaders;
	import net.vdombox.ide.common.UIQueryMessage;
	import net.vdombox.ide.common.UIQueryMessageNames;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.model.SessionProxy;
	import net.vdombox.ide.modules.applicationsManagment.model.vo.SettingsVO;
	
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
			super( NAME, new Junction() );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.EXPORT_TOOLSET );
			interests.push( ApplicationFacade.EXPORT_SETTINGS_SCREEN );
			interests.push( ApplicationFacade.EXPORT_BODY );

			interests.push( ApplicationFacade.SAVE_SETTINGS_TO_STORAGE );
			interests.push( ApplicationFacade.RETRIEVE_SETTINGS_FROM_STORAGE );

			interests.push( ApplicationFacade.GET_APPLICATIONS_LIST );
			interests.push( ApplicationFacade.GET_SELECTED_APPLICATION );
			interests.push( ApplicationFacade.SET_SELECTED_APPLICATION );

			interests.push( ApplicationFacade.LOAD_RESOURCE );
			interests.push( ApplicationFacade.SET_RESOURCE );

			interests.push( ApplicationFacade.CREATE_APPLICATION );
			interests.push( ApplicationFacade.EDIT_APPLICATION_INFORMATION );
			
			interests.push( ApplicationFacade.CREATE_PAGE );
			interests.push( ApplicationFacade.GET_TYPES );

			return interests;
		}

		/**
		 * Create a message to sent to <b>VDOM Core</b> 
		 * @param notification
		 * 
		 */		
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
					message = new UIQueryMessage( UIQueryMessageNames.TOOLSET_UI, UIComponent( body ),
												  multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

					break;
				}

				case ApplicationFacade.EXPORT_SETTINGS_SCREEN:
				{
					message = new UIQueryMessage( UIQueryMessageNames.SETTINGS_SCREEN_UI, UIComponent( body ),
												  multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

					break;
				}

				case ApplicationFacade.EXPORT_BODY:
				{
					message = new UIQueryMessage( UIQueryMessageNames.BODY_UI, UIComponent( body ), multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

					break;
				}

				case ApplicationFacade.RETRIEVE_SETTINGS_FROM_STORAGE:
				{
					message = new SimpleMessage( SimpleMessageHeaders.RETRIEVE_SETTINGS_FROM_STORAGE,
												 null, multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

					break;
				}

				case ApplicationFacade.SAVE_SETTINGS_TO_STORAGE:
				{
					message = new SimpleMessage( SimpleMessageHeaders.SAVE_SETTINGS_TO_STORAGE, body,
												 multitonKey );

					junction.sendMessage( PipeNames.STDCORE, message );

					break;
				}

				case ApplicationFacade.GET_APPLICATIONS_LIST:
				{
					message = new ProxyMessage( PPMPlaceNames.SERVER, PPMOperationNames.READ, PPMServerTargetNames.APPLICATIONS );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.GET_SELECTED_APPLICATION:
				{
					message = new ProxyMessage( PPMPlaceNames.STATES, PPMOperationNames.READ, PPMStatesTargetNames.SELECTED_APPLICATION );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.SET_SELECTED_APPLICATION:
				{
					message = new ProxyMessage( PPMPlaceNames.STATES, PPMOperationNames.UPDATE,
													  PPMStatesTargetNames.SELECTED_APPLICATION, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.CREATE_APPLICATION:
				{
					message = new ProxyMessage( PPMPlaceNames.SERVER, PPMOperationNames.CREATE,
													  PPMServerTargetNames.APPLICATION, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.EDIT_APPLICATION_INFORMATION:
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.UPDATE,
													  PPMApplicationTargetNames.INFORMATION, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.LOAD_RESOURCE:
				{
					var recipientKey : String;
					var resourceVO : ResourceVO;
					
					var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
					var recipients : Object = sessionProxy.getObject( PPMPlaceNames.RESOURCES );
					
					if ( body is ResourceVO )
					{
						resourceVO = body as ResourceVO;
					}
					else
					{
						recipientKey = body.recipientKey;
						resourceVO = body.resourceVO as ResourceVO;

						if ( !recipients.hasOwnProperty( resourceVO.id ) )
							recipients[ resourceVO.id ] = [];

						recipients[ resourceVO.id ].push( recipientKey );
					}

					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ,
													  PPMResourcesTargetNames.RESOURCE, resourceVO );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.SET_RESOURCE:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.CREATE,
													  PPMResourcesTargetNames.RESOURCE, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}
					
				case ApplicationFacade.CREATE_PAGE:
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.CREATE,
													PPMApplicationTargetNames.PAGE, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
				case ApplicationFacade.GET_TYPES:
				{
					message = new ProxyMessage( PPMPlaceNames.TYPES, PPMOperationNames.READ,
						PPMTypesTargetNames.TYPES, body );
					
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
						sendNotification( ApplicationFacade.MODULE_SELECTED );
						junction.sendMessage( PipeNames.STDCORE, new SimpleMessage( SimpleMessageHeaders.CONNECT_PROXIES_PIPE,
																					null, multitonKey ) );
					}
					else
					{
						sendNotification( ApplicationFacade.MODULE_DESELECTED );
						junction.sendMessage( PipeNames.STDCORE, new SimpleMessage( SimpleMessageHeaders.DISCONNECT_PROXIES_PIPE,
																					null, multitonKey ) );
					}

					break;
				}

				case SimpleMessageHeaders.PROXIES_PIPE_CONNECTED:
				{
					if ( recipientKey != multitonKey )
						return;

					junction.sendMessage( PipeNames.STDLOG, new LogMessage( LogMessage.DEBUG, multitonKey,
																			SimpleMessageHeaders.PROXIES_PIPE_CONNECTED ) );

					sendNotification( ApplicationFacade.PIPES_READY );

					break;
				}

				case SimpleMessageHeaders.RETRIEVE_SETTINGS_FROM_STORAGE:
				{
					if ( recipientKey != multitonKey )
						return;

					sendNotification( ApplicationFacade.SETTINGS_FROM_STORAGE_RETRIEVED, simpleMessage.getBody() );

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

		
		/**
		 * Get a message  from the <b>VDOM Core</b> and operates it.
		 * 
		 * @param message
		 * 
		 */		
		private function handleProxyMessage( message : ProxyMessage ) : void
		{
			var proxy : String = message.proxy;

			switch ( proxy )
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
					
				case PPMPlaceNames.APPLICATION:
				{
					sendNotification( ApplicationFacade.PROCESS_APPLICATION_PROXY_MESSAGE, message );
					
					break;
				}

				case PPMPlaceNames.RESOURCES:
				{
					sendNotification( ApplicationFacade.PROCESS_RESOURCE_PROXY_MESSAGE, message );
					
					break;
				}
				case PPMPlaceNames.TYPES:
				{
					sendNotification( ApplicationFacade.PROCESS_TYPES_PROXY_MESSAGE, message );
					
					break;
				}
			}
		}
	}
}