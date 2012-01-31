package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.utils.Dictionary;
	
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.SimpleMessageHeaders;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
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
	import net.vdombox.ide.common.view.LoggingJunctionMediator;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.MessageProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
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
		
		private var messageProxy : MessageProxy;

		override public function onRegister() : void
		{
			recipients = new Dictionary( true );
			messageProxy = facade.retrieveProxy( MessageProxy.NAME ) as MessageProxy;
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

			interests.push( TypesProxy.GET_TYPES );

			interests.push( ApplicationFacade.GET_RESOURCES );
			interests.push( ApplicationFacade.SET_RESOURCE );
			interests.push( ApplicationFacade.DELETE_RESOURCE );
			interests.push( ApplicationFacade.LOAD_RESOURCE );
			interests.push( ApplicationFacade.MODIFY_RESOURCE );
			
			interests.push( ApplicationFacade.GET_ICON );

			interests.push( ApplicationFacade.GET_PAGES );
			interests.push( ApplicationFacade.GET_PAGE_SRUCTURE );
			interests.push( ApplicationFacade.GET_OBJECTS );
			interests.push( ApplicationFacade.GET_OBJECT );

			interests.push( ApplicationFacade.GET_PAGE_ATTRIBUTES );
			interests.push( ApplicationFacade.GET_OBJECT_ATTRIBUTES );

			interests.push( ApplicationFacade.GET_WYSIWYG );

			interests.push( ApplicationFacade.GET_XML_PRESENTATION );
			interests.push( ApplicationFacade.SET_XML_PRESENTATION );

			interests.push( ApplicationFacade.CREATE_OBJECT );
			interests.push( ApplicationFacade.DELETE_OBJECT );

			interests.push( ApplicationFacade.REMOTE_CALL_REQUEST );
			interests.push( ApplicationFacade.UPDATE_ATTRIBUTES );
		
			interests.push( ApplicationFacade.BODY_STOP );
			interests.push( SessionProxy.GET_SELECTED_PAGE );
			
			interests.push( ApplicationFacade.SET_OBJECT_NAME );
			
			interests.push( ApplicationFacade.COPY_REQUEST );
			
			interests.push( ApplicationFacade.WRITE_ERROR );
			interests.push( ApplicationFacade.DELETE_PAGE );
			interests.push( ApplicationFacade.GET_TOP_LEVEL_TYPES );
			interests.push( ApplicationFacade.CREATE_PAGE );
			
			interests.push( ApplicationFacade.UNDO );
			interests.push( ApplicationFacade.REDO );

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

				case TypesProxy.GET_TYPES:
				{
					message = new ProxyMessage( PPMPlaceNames.TYPES, PPMOperationNames.READ, PPMTypesTargetNames.TYPES );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.GET_RESOURCES:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ, PPMResourcesTargetNames.RESOURCES, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}
					
				case ApplicationFacade.SET_RESOURCE:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.CREATE, PPMResourcesTargetNames.RESOURCE, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}

				case ApplicationFacade.DELETE_RESOURCE:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.DELETE, PPMResourcesTargetNames.RESOURCE, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}

				case ApplicationFacade.LOAD_RESOURCE:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ, PPMResourcesTargetNames.RESOURCE, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}
					
				case ApplicationFacade.GET_ICON:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ, PPMResourcesTargetNames.ICON, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}

				case ApplicationFacade.MODIFY_RESOURCE:
				{
					message = new ProxyMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.UPDATE, PPMResourcesTargetNames.RESOURCE, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.GET_PAGES:
				{
					
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.PAGES, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.GET_PAGE_SRUCTURE:
				{
					
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.STRUCTURE, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.GET_OBJECTS:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.OBJECTS, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.GET_OBJECT:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.OBJECT, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.GET_PAGE_ATTRIBUTES:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.ATTRIBUTES, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.GET_OBJECT_ATTRIBUTES:
				{
					message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.READ, PPMObjectTargetNames.ATTRIBUTES, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.GET_WYSIWYG:
				{
					if ( body is PageVO )
						message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.WYSIWYG, body );
					else if ( body is ObjectVO )
						message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.READ, PPMObjectTargetNames.WYSIWYG, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.GET_XML_PRESENTATION:
				{
					
					if ( body.hasOwnProperty( "pageVO" ) )
						message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.READ, PPMPageTargetNames.XML_PRESENTATION, body );
					else if ( body.hasOwnProperty( "objectVO" ) )
						message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.READ, PPMObjectTargetNames.XML_PRESENTATION, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.SET_XML_PRESENTATION:
				{
					if ( body.vdomObjectVO is PageVO )
						message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.UPDATE, PPMPageTargetNames.XML_PRESENTATION, body );
					else if ( body.vdomObjectVO is ObjectVO )
						message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.UPDATE, PPMObjectTargetNames.XML_PRESENTATION, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.CREATE_OBJECT:
				{
					if ( body.hasOwnProperty( "pageVO" ) )
						message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.CREATE, PPMPageTargetNames.OBJECT, body );
					else if ( body.hasOwnProperty( "objectVO" ) )
						message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.CREATE, PPMObjectTargetNames.OBJECT, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.DELETE_OBJECT:
				{
					message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.DELETE, PPMPageTargetNames.OBJECT, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					messageProxy.removeAll( body.pageVO as PageVO );

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

				case ApplicationFacade.REMOTE_CALL_REQUEST:
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.REMOTE_CALL, body );

					junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}

				case ApplicationFacade.UPDATE_ATTRIBUTES:
				{
					if ( VdomObjectAttributesVO(body).vdomObjectVO is PageVO )
					{
						message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.UPDATE, PPMPageTargetNames.ATTRIBUTES, body );
						messageProxy.push( body.vdomObjectVO, message as ProxyMessage );				
					} else if ( VdomObjectAttributesVO(body).vdomObjectVO is ObjectVO )
					{
						message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.UPDATE, PPMObjectTargetNames.ATTRIBUTES, body );
						messageProxy.push( body.vdomObjectVO.pageVO, message as ProxyMessage );
					}

					if ( message )
						junction.sendMessage( PipeNames.PROXIESOUT, message );

					break;
				}
					
				case ApplicationFacade.SET_OBJECT_NAME:
				{
					if ( body is PageVO )
						message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.UPDATE, PPMPageTargetNames.NAME, body );
					else if ( body is ObjectVO )
						message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.UPDATE, PPMObjectTargetNames.NAME, body );
					
					if ( message )
						junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.COPY_REQUEST :
				{
					if ( body.hasOwnProperty( "pageVO" ) )
						message = new ProxyMessage( PPMPlaceNames.PAGE, PPMOperationNames.CREATE, PPMPageTargetNames.COPY, body );
					else if ( body.hasOwnProperty( "objectVO" ) )	
						message = new ProxyMessage( PPMPlaceNames.OBJECT, PPMOperationNames.CREATE, PPMObjectTargetNames.COPY, body );
					else
						message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.CREATE, PPMApplicationTargetNames.COPY, body );
					if ( message )
						junction.sendMessage( PipeNames.PROXIESOUT, message );
					break;
				}
					
				case ApplicationFacade.BODY_STOP :
				{
					junction.sendMessage( PipeNames.STDCORE,
						new SimpleMessage( SimpleMessageHeaders.DISCONNECT_PROXIES_PIPE, null, multitonKey ) );
					
					break;
				}
					
				case ApplicationFacade.WRITE_ERROR :
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.READ, PPMApplicationTargetNames.ERROR, body );
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case SessionProxy.GET_SELECTED_PAGE :
				{
					message = new ProxyMessage( PPMPlaceNames.STATES, PPMOperationNames.READ, PPMStatesTargetNames.SELECTED_PAGE, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					break;
				}
					
				case ApplicationFacade.DELETE_PAGE:
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.DELETE, PPMApplicationTargetNames.PAGE, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					messageProxy.removeAll( body.pageVO as PageVO );
					
					break;
				}
					
				case ApplicationFacade.GET_TOP_LEVEL_TYPES:
				{
					message = new ProxyMessage( PPMPlaceNames.TYPES, PPMOperationNames.READ, PPMTypesTargetNames.TOP_LEVEL_TYPES, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.CREATE_PAGE:
				{
					message = new ProxyMessage( PPMPlaceNames.APPLICATION, PPMOperationNames.CREATE, PPMApplicationTargetNames.PAGE, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.UNDO:
				{
					message = messageProxy.getUndo( body as PageVO );
					
					if ( message )
						junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.REDO:
				{
					message = messageProxy.getRedo( body as PageVO );
					
					if ( message )
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
			
			if ( recipientKey != multitonKey )
				return;

			switch ( simpleMessage.getHeader() )
			{
				case SimpleMessageHeaders.MODULE_SELECTED:
				{
//					sendNotification( ApplicationFacade.MODULE_SELECTED );
//					junction.sendMessage( PipeNames.STDCORE, new SimpleMessage( SimpleMessageHeaders.CONNECT_PROXIES_PIPE, null, multitonKey ) );

					break;
				}

				case SimpleMessageHeaders.PROXIES_PIPE_CONNECTED:
				{
					junction.sendMessage( PipeNames.STDLOG,
						new LogMessage( LogMessage.DEBUG, multitonKey, SimpleMessageHeaders.PROXIES_PIPE_CONNECTED ) );

					sendNotification( ApplicationFacade.PIPES_READY );
					break;
				}

				case SimpleMessageHeaders.RETRIEVE_SETTINGS_FROM_STORAGE:
				{
					var settingsVO : SettingsVO = new SettingsVO( simpleMessage.getBody() );

					sendNotification( ApplicationFacade.SAVE_SETTINGS_TO_PROXY, settingsVO );

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
			//junction.removePipe( PipeNames.STDOUT ); not used
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
			
			var proxy : String = message.proxy;
			var now:Date = new Date();
			trace("                                       "+ now.toLocaleTimeString()+"   <<- "+message.proxy +"  "+message.operation +"  "+  message.target);

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
	}
}