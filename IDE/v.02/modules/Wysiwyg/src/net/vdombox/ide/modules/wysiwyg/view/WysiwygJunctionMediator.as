package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.LogMessage;
	import net.vdombox.ide.common.LoggingJunctionMediator;
	import net.vdombox.ide.common.SimpleMessageHeaders;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.PPMResourcesTargetNames;
	import net.vdombox.ide.common.PPMServerTargetNames;
	import net.vdombox.ide.common.PPMTypesTargetNames;
	import net.vdombox.ide.common.PipeNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.SimpleMessage;
	import net.vdombox.ide.common.UIQueryMessage;
	import net.vdombox.ide.common.UIQueryMessageNames;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;

	public class WysiwygJunctionMediator extends LoggingJunctionMediator
	{
		public static const NAME : String = "WysiwygJunctionMediator";

		public function WysiwygJunctionMediator()
		{
			super( NAME, new Junction());
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.EXPORT_TOOLSET );
			interests.push( ApplicationFacade.EXPORT_BODY );
			
			interests.push( ApplicationFacade.GET_APPLICATIONS_LIST );
			interests.push( ApplicationFacade.GET_SELECTED_APPLICATION );
			interests.push( ApplicationFacade.SET_SELECTED_APPLICATION );
			interests.push( ApplicationFacade.GET_TYPES );
			interests.push( ApplicationFacade.GET_RESOURCE );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var pipe : IPipeFitting;
			var type : String = notification.getType();
			var body : Object = notification.getBody();
			var proxiesPipeMessage : ProxiesPipeMessage;

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
						new UIQueryMessage( UIQueryMessageNames.TOOLSET_UI, UIComponent( notification.getBody()), multitonKey );
					
					junction.sendMessage( PipeNames.STDCORE, toolsetMessage );
					break;
				}

				case ApplicationFacade.EXPORT_BODY:
				{
					var bodyMessage : UIQueryMessage = 
						new UIQueryMessage( UIQueryMessageNames.BODY_UI, UIComponent( notification.getBody()), multitonKey );
					
					junction.sendMessage( PipeNames.STDCORE, bodyMessage );
					break;
				}
				
				case ApplicationFacade.GET_APPLICATIONS_LIST:
				{
					proxiesPipeMessage = 
						new ProxiesPipeMessage( PPMOperationNames.READ, PPMPlaceNames.SERVER, PPMServerTargetNames.APPLICATIONS );
					
					junction.sendMessage( PipeNames.PROXIESOUT, proxiesPipeMessage );
					break;
				}
					
				case ApplicationFacade.GET_SELECTED_APPLICATION:
				{
					proxiesPipeMessage = 
						new ProxiesPipeMessage( PPMOperationNames.READ, PPMPlaceNames.SERVER, PPMServerTargetNames.SELECTED_APPLICATION );
					
					junction.sendMessage( PipeNames.PROXIESOUT, proxiesPipeMessage );
					break;
				}
				
				case ApplicationFacade.SET_SELECTED_APPLICATION:
				{
					proxiesPipeMessage = 
						new ProxiesPipeMessage( PPMOperationNames.UPDATE, PPMPlaceNames.SERVER, 
												PPMServerTargetNames.SELECTED_APPLICATION, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, proxiesPipeMessage );
					break;
				}
				
				case ApplicationFacade.GET_TYPES:
				{
					proxiesPipeMessage = 
						new ProxiesPipeMessage( PPMOperationNames.READ, PPMPlaceNames.TYPES, 
							PPMTypesTargetNames.TYPES, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, proxiesPipeMessage );
					break;
				}
					
				case ApplicationFacade.GET_RESOURCE:
				{
					proxiesPipeMessage = 
						new ProxiesPipeMessage( PPMOperationNames.READ, PPMPlaceNames.RESOURCES, 
												PPMResourcesTargetNames.RESOURCE, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, proxiesPipeMessage );
					break;
				}
			}

			super.handleNotification( notification );
		}

		override public function handlePipeMessage( message : IPipeMessage ) : void
		{
			var simpleMessage : SimpleMessage = message as SimpleMessage;
			
			var recepientKey : String = simpleMessage.getRecepientKey();
			
			switch ( message.getHeader())
			{
				case SimpleMessageHeaders.MODULE_SELECTED:
				{
					var toolsetMediator : ToolsetMediator = facade.retrieveMediator( ToolsetMediator.NAME ) as ToolsetMediator;
					
					if( recepientKey == multitonKey )
						sendNotification( ApplicationFacade.MODULE_SELECTED );
					else
						sendNotification( ApplicationFacade.MODULE_DESELECTED );
					
					junction.sendMessage( PipeNames.STDCORE, new Message( Message.NORMAL, SimpleMessageHeaders.CONNECT_PROXIES_PIPE, multitonKey));
					break;
				}
				
				case SimpleMessageHeaders.PROXIES_PIPE_CONNECTED:
				{
					if( recepientKey == multitonKey )
					{
						junction.sendMessage( PipeNames.STDLOG, new LogMessage(	LogMessage.DEBUG, "Module", SimpleMessageHeaders.PROXIES_PIPE_CONNECTED ) );
						
						junction.sendMessage( 
							PipeNames.PROXIESOUT, 
							new ProxiesPipeMessage( PPMOperationNames.READ, PPMPlaceNames.APPLICATION, PPMServerTargetNames.APPLICATION, { test : "test" } )
							);
						
//						junction.sendMessage( PipeNames.STDCORE, new Message( Message.NORMAL, MessageHeaders.DISCONNECT_PROXIES_PIPE, multitonKey ) );
					}
					break;
				}
					
				case SimpleMessageHeaders.PROXIES_PIPE_CONNECTED:
				{
					
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
					pipe.connect( new PipeListener( this, handleProxiesPipeMessage ));
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
				
				case PPMPlaceNames.TYPES:
				{
					processTypesProxyMessage( message );
					break;
				}
				
				case PPMPlaceNames.RESOURCES:
				{
					processResourcesProxyMessage( message );
					break;
				}
			}
		}
		
		private function processServerProxyMessage( message : ProxiesPipeMessage ) : void
		{
			switch( message.getTarget() )
			{
				case PPMServerTargetNames.APPLICATIONS:
				{
					sendNotification( ApplicationFacade.APPLICATIONS_LIST_GETTED, message.getParameters() );
					break;
				}
				
				case PPMServerTargetNames.SELECTED_APPLICATION:
				{
					sendNotification( ApplicationFacade.SELECTED_APPLICATION_CHANGED, message.getParameters() );
					break;
				}
			}
		}
		
		private function processTypesProxyMessage( message : ProxiesPipeMessage ) : void
		{
			switch( message.getTarget() )
			{
				case PPMTypesTargetNames.TYPES:
				{
					sendNotification( ApplicationFacade.TYPES_GETTED, message.getParameters() );
					break;
				}
			}
		}
		
		private function processResourcesProxyMessage( message : ProxiesPipeMessage ) : void
		{
			switch( message.getTarget() )
			{
				case PPMResourcesTargetNames.RESOURCE:
				{
					sendNotification( message.getParameters().recepientName + "/" +
									  ApplicationFacade.RESOURCE_GETTED, message.getParameters() );
					break;
				}
			}
		}
	}
}