package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.LogMessage;
	import net.vdombox.ide.common.LoggingJunctionMediator;
	import net.vdombox.ide.common.PPMApplicationTargetNames;
	import net.vdombox.ide.common.PPMObjectTargetNames;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.PPMResourcesTargetNames;
	import net.vdombox.ide.common.PPMStatesTargetNames;
	import net.vdombox.ide.common.PPMTypesTargetNames;
	import net.vdombox.ide.common.PipeNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.SimpleMessage;
	import net.vdombox.ide.common.SimpleMessageHeaders;
	import net.vdombox.ide.common.UIQueryMessage;
	import net.vdombox.ide.common.UIQueryMessageNames;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.vo.SettingsVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;

	public class WysiwygJunctionMediator extends LoggingJunctionMediator
	{
		public static const NAME : String = "WysiwygJunctionMediator";

		public function WysiwygJunctionMediator()
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

			interests.push( ApplicationFacade.EXPORT_TOOLSET );
			interests.push( ApplicationFacade.EXPORT_SETTINGS_SCREEN );
			interests.push( ApplicationFacade.EXPORT_BODY );

			interests.push( ApplicationFacade.RETRIEVE_SETTINGS_FROM_STORAGE );
			interests.push( ApplicationFacade.SAVE_SETTINGS_TO_STORAGE );
			
			interests.push( ApplicationFacade.SELECT_MODULE );

			interests.push( ApplicationFacade.GET_TYPES );
			interests.push( ApplicationFacade.GET_TYPE );
			
			interests.push( ApplicationFacade.GET_SELECTED_APPLICATION );
			
			interests.push( ApplicationFacade.GET_PAGES );
			interests.push( ApplicationFacade.GET_PAGE_SRUCTURE );
			interests.push( ApplicationFacade.GET_OBJECTS );
			interests.push( ApplicationFacade.GET_OBJECT );
			
			interests.push( ApplicationFacade.GET_PAGE_ATTRIBUTES );
			interests.push( ApplicationFacade.GET_OBJECT_ATTRIBUTES );

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

				case ApplicationFacade.SELECT_MODULE:
				{
					message = new SimpleMessage( SimpleMessageHeaders.SELECT_MODULE, null, multitonKey );
					
					junction.sendMessage( PipeNames.STDCORE, message );
					
					break;
				}
					
				case ApplicationFacade.GET_TYPES:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.TYPES, PPMOperationNames.READ, PPMTypesTargetNames.TYPES );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}
					
				case ApplicationFacade.GET_TYPE:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.TYPES, PPMOperationNames.READ, PPMTypesTargetNames.TYPE, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.GET_SELECTED_APPLICATION:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.STATES, PPMOperationNames.READ, PPMStatesTargetNames.SELECTED_APPLICATION );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.GET_PAGES:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.PAGES, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.GET_PAGE_SRUCTURE:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.STRUCTURE, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.GET_OBJECTS:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.OBJECTS, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.GET_OBJECT:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.OBJECT, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
				
				case ApplicationFacade.GET_PAGE_ATTRIBUTES:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.ATTRIBUTES, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.GET_OBJECT_ATTRIBUTES:
				{
					message = new ProxiesPipeMessage( PPMPlaceNames.OBJECT, PPMOperationNames.READ, PPMObjectTargetNames.ATTRIBUTES, body );
					
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

					junction.sendMessage( PipeNames.STDLOG, new LogMessage( LogMessage.DEBUG, "Module",
																			SimpleMessageHeaders.PROXIES_PIPE_CONNECTED ) );

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
					pipe.connect( new PipeListener( this, handleProxiesPipeMessage ) );
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

		private function handleProxiesPipeMessage( message : ProxiesPipeMessage ) : void
		{
			var place : String = message.getPlace();

			switch ( place )
			{
				case PPMPlaceNames.SERVER:
				{
					processServerProxyMessage( message );
					break;
				}

				case PPMPlaceNames.APPLICATION:
				{
					processApplicationProxyMessage( message );
					break;
				}
				
				case PPMPlaceNames.PAGE:
				{
					processPageProxyMessage( message );
					break;
				}
					
				case PPMPlaceNames.OBJECT:
				{
					processObjectProxyMessage( message );
					break;
				}
					
				case PPMPlaceNames.RESOURCES:
				{
					processResourcesProxyMessage( message );
					break;
				}
					
				case PPMPlaceNames.TYPES:
				{
					processTypesProxyMessage( message );
					break;
				}
			}
		}

		private function processServerProxyMessage( message : ProxiesPipeMessage ) : void
		{
			switch ( message.getTarget() )
			{
				case PPMStatesTargetNames.SELECTED_APPLICATION:
				{
					sendNotification( ApplicationFacade.SELECTED_APPLICATION_GETTED, message.getBody() );
				}
			}
		}
		
		private function processApplicationProxyMessage( message : ProxiesPipeMessage ) : void
		{
			switch ( message.getTarget() )
			{
				case PPMApplicationTargetNames.PAGES:
				{
					sendNotification( ApplicationFacade.PAGES_GETTED, message.getBody() );
					
					break;
				}
			}
		}
		
		private function processPageProxyMessage( message : ProxiesPipeMessage ) : void
		{
			switch ( message.getTarget() )
			{
				case PPMPageTargetNames.STRUCTURE:
				{
					sendNotification( ApplicationFacade.PAGE_SRUCTURE_GETTED, message.getBody() );
					
					break;
				}
					
				case PPMPageTargetNames.OBJECT:
				{
					sendNotification( ApplicationFacade.OBJECT_GETTED, message.getBody() );
					
					break;
				}
			}
		}
		
		private function processObjectProxyMessage( message : ProxiesPipeMessage ) : void
		{
			switch ( message.getTarget() )
			{
				case PPMObjectTargetNames.ATTRIBUTES:
				{
					sendNotification( ApplicationFacade.OBJECT_ATTRIBUTES_GETTED, message.getBody() );
					
					break;
				}
			}
		}
		
		private function processTypesProxyMessage( message : ProxiesPipeMessage ) : void
		{
			switch ( message.getTarget() )
			{
				case PPMTypesTargetNames.TYPES:
				{
					sendNotification( ApplicationFacade.TYPES_GETTED, message.getBody() );
					
					break;
				}
					
				case PPMTypesTargetNames.TYPE:
				{
					sendNotification( ApplicationFacade.TYPE_GETTED, message.getBody() );
					
					break;
				}
			}
		}
		
		private function processResourcesProxyMessage( message : ProxiesPipeMessage ) : void
		{
			var operation : String = message.getOperation();

			switch ( message.getTarget() )
			{
				case PPMResourcesTargetNames.RESOURCES:
				{
					if ( operation == PPMOperationNames.READ )
					{
						sendNotification( ApplicationFacade.TYPES_GETTED, message.getBody() );
					}

					break;
				}

				case PPMResourcesTargetNames.RESOURCE:
				{
					if ( operation == PPMOperationNames.READ )
					{

					}

					break;
				}
			}
		}
	}
}