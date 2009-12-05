package net.vdombox.ide.modules.applicationsManagment.view
{
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.LogMessage;
	import net.vdombox.ide.common.LoggingJunctionMediator;
	import net.vdombox.ide.common.MessageHeaders;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.PPMResourcesTargetNames;
	import net.vdombox.ide.common.PPMServerTargetNames;
	import net.vdombox.ide.common.PipeNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.UIQueryMessage;
	import net.vdombox.ide.common.UIQueryMessageNames;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeMessage;
	import org.puremvc.as3.multicore.utilities.pipes.messages.Message;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.Junction;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.JunctionMediator;
	import org.puremvc.as3.multicore.utilities.pipes.plumbing.PipeListener;

	public class ApplicationsManagmentJunctionMediator extends LoggingJunctionMediator
	{
		public static const NAME : String = "ApplicationsManagmentJunctionMediator";

		public function ApplicationsManagmentJunctionMediator()
		{
			super( NAME, new Junction());
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.EXPORT_TOOLSET );
			interests.push( ApplicationFacade.EXPORT_SETTINGS_SCREEN );
			interests.push( ApplicationFacade.EXPORT_BODY );
			
			interests.push( ApplicationFacade.GET_APPLICATIONS_LIST );
			interests.push( ApplicationFacade.GET_SELECTED_APPLICATION );
			interests.push( ApplicationFacade.SET_SELECTED_APPLICATION );
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
						new UIQueryMessage( UIQueryMessage.SET, UIQueryMessageNames.TOOLSET_UI, UIComponent( notification.getBody()));
					
					junction.sendMessage( PipeNames.STDCORE, toolsetMessage );
					break;
				}
				
				case ApplicationFacade.EXPORT_SETTINGS_SCREEN:
				{
					var settingsScreenMessage : UIQueryMessage = 
						new UIQueryMessage( UIQueryMessage.SET, UIQueryMessageNames.SETTINGS_SCREEN_UI, UIComponent( notification.getBody()));
					
					junction.sendMessage( PipeNames.STDCORE, settingsScreenMessage );
					break;
				}
					
				case ApplicationFacade.EXPORT_BODY:
				{
					var bodyMessage : UIQueryMessage = 
						new UIQueryMessage( UIQueryMessage.SET, UIQueryMessageNames.BODY_UI, UIComponent( notification.getBody()));
					
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
					
				case MessageHeaders.PROXIES_PIPE_CONNECTED:
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
			var place : String = message.place;
			
			switch ( place ) 
			{
				case PPMPlaceNames.SERVER:
				{
					processServerProxyMessage( message );
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
			switch( message.target )
			{
				case PPMServerTargetNames.APPLICATIONS:
				{
					sendNotification( ApplicationFacade.APPLICATIONS_LIST_GETTED, message.parameters );
					break;
				}
				
				case PPMServerTargetNames.SELECTED_APPLICATION:
				{
					sendNotification( ApplicationFacade.SELECTED_APPLICATION_CHANGED, message.parameters );
					break;
				}
			}
		}
		
		private function processResourcesProxyMessage( message : ProxiesPipeMessage ) : void
		{
			switch( message.target )
			{
				case PPMResourcesTargetNames.RESOURCE:
				{
					sendNotification( message.parameters.recepientName + "/" +
									  ApplicationFacade.RESOURCE_GETTED, message.parameters );
					break;
				}
			}
		}
	}
}