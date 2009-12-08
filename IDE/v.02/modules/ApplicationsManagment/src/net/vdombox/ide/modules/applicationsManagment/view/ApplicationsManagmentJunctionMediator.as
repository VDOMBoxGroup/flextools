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
	import net.vdombox.ide.common.SimpleMessage;
	import net.vdombox.ide.common.UIQueryMessage;
	import net.vdombox.ide.common.UIQueryMessageNames;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	
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
			super( NAME, new Junction());
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.EXPORT_TOOLSET );
			interests.push( ApplicationFacade.EXPORT_SETTINGS_SCREEN );
			interests.push( ApplicationFacade.EXPORT_BODY );
			
			interests.push( ApplicationFacade.RETRIEVE_SETTINGS );
			interests.push( ApplicationFacade.SAVE_SETTINGS );
			
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
//			var proxiesPipeMessage : ProxiesPipeMessage;
			
			var message : IPipeMessage;
			
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
					message = 
						new UIQueryMessage( UIQueryMessage.SET, UIQueryMessageNames.TOOLSET_UI, UIComponent( body ));
					
					junction.sendMessage( PipeNames.STDCORE, message );
					
					break;
				}
				
				case ApplicationFacade.EXPORT_SETTINGS_SCREEN:
				{
					message = 
						new UIQueryMessage( UIQueryMessage.SET, UIQueryMessageNames.SETTINGS_SCREEN_UI, UIComponent( body ));
					
					junction.sendMessage( PipeNames.STDCORE, message );
					
					break;
				}
					
				case ApplicationFacade.EXPORT_BODY:
				{
					message = 
						new UIQueryMessage( UIQueryMessage.SET, UIQueryMessageNames.BODY_UI, UIComponent( body ));
					
					junction.sendMessage( PipeNames.STDCORE, message );
					
					break;
				}
				
				case ApplicationFacade.RETRIEVE_SETTINGS:
				{
					message = new SimpleMessage( MessageHeaders.RETRIEVE_MODULE_SETTINGS, null, multitonKey );
					
					junction.sendMessage( PipeNames.STDCORE, message );
					
					break;
				}
				
				case ApplicationFacade.SAVE_SETTINGS:
				{
					message = new SimpleMessage( MessageHeaders.SAVE_MODULE_SETTINGS, body, multitonKey );
					
					junction.sendMessage( PipeNames.STDCORE, message );
					
					break;
				}
					
				case ApplicationFacade.GET_APPLICATIONS_LIST:
				{
					message = 
						new ProxiesPipeMessage( PPMPlaceNames.SERVER, PPMOperationNames.READ, PPMServerTargetNames.APPLICATIONS );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
					
				case ApplicationFacade.GET_SELECTED_APPLICATION:
				{
					message = 
						new ProxiesPipeMessage( PPMPlaceNames.SERVER, PPMOperationNames.READ, PPMServerTargetNames.SELECTED_APPLICATION );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
				
				case ApplicationFacade.SET_SELECTED_APPLICATION:
				{
					message = 
						new ProxiesPipeMessage( PPMPlaceNames.SERVER, PPMOperationNames.UPDATE,
												PPMServerTargetNames.SELECTED_APPLICATION, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
				
				case ApplicationFacade.GET_RESOURCE:
				{
					message = 
						new ProxiesPipeMessage( PPMPlaceNames.RESOURCES, PPMOperationNames.READ,
												PPMResourcesTargetNames.RESOURCE, body );
					
					junction.sendMessage( PipeNames.PROXIESOUT, message );
					
					break;
				}
			}

			super.handleNotification( notification );
		}

		override public function handlePipeMessage( message : IPipeMessage ) : void
		{
			var simpleMessage : SimpleMessage = message as SimpleMessage;
			
			var recepientKey : String = simpleMessage.getRecepientKey();
			
			switch ( simpleMessage.getHeader())
			{
				case MessageHeaders.MODULE_SELECTED:
				{
					if( recepientKey == multitonKey )
						sendNotification( ApplicationFacade.MODULE_SELECTED );
					else
						sendNotification( ApplicationFacade.MODULE_DESELECTED );
					
					junction.sendMessage( PipeNames.STDCORE, new SimpleMessage( MessageHeaders.CONNECT_PROXIES_PIPE, null, multitonKey));
					
					break;
				}
				
				case MessageHeaders.PROXIES_PIPE_CONNECTED:
				{
					if( recepientKey != multitonKey )
						return;
					
					junction.sendMessage( PipeNames.STDLOG, new LogMessage(	LogMessage.DEBUG, "Module", MessageHeaders.PROXIES_PIPE_CONNECTED ) );
					
					junction.sendMessage( 
						PipeNames.PROXIESOUT, 
						new ProxiesPipeMessage( PPMOperationNames.READ, PPMPlaceNames.APPLICATION, PPMServerTargetNames.APPLICATION, { test : "test" } )
						);
					
					break;
				}
					
				case MessageHeaders.RETRIEVE_MODULE_SETTINGS:
				{
					if( recepientKey != multitonKey )
						return;
					
					sendNotification( ApplicationFacade.SET_SETTINGS, message.getBody() );
					
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
		
		private function processResourcesProxyMessage( message : ProxiesPipeMessage ) : void
		{
			switch( message.getTarget() )
			{
				case PPMResourcesTargetNames.RESOURCE:
				{
					var resourceVO : ResourceVO = message.getParameters().resourceVO as ResourceVO;
					
					sendNotification( message.getParameters().recepientName + "/" +
									  ApplicationFacade.RESOURCE_GETTED, resourceVO );
					break;
				}
			}
		}
	}
}