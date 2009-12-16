package net.vdombox.ide.modules.applicationsManagment.view
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class BodyMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BodyMediator";

		public function BodyMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var newApplicationsParameters : Object;
		
		public function get body() : Body
		{
			return viewComponent as Body;
		}
		
		override public function onRegister() : void
		{
			addEventListeners();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.OPEN_CREATE_APPLICATION_VIEW );
			interests.push( ApplicationFacade.NEW_APP_PROPS_SUBMITTED );
			interests.push( ApplicationFacade.APPLICATION_CREATED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case ApplicationFacade.OPEN_CREATE_APPLICATION_VIEW:
				{
					body.viewStack.selectedIndex = 1;
					
					break;
				}
					
				case ApplicationFacade.NEW_APP_PROPS_SUBMITTED:
				{
					newApplicationsParameters = notification.getBody();
					
					if( newApplicationsParameters.hasOwnProperty( "name" ) )
					{
						sendNotification( ApplicationFacade.CREATE_APPLICATION );
					}
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_CREATED:
				{
					sendNotification( 
						ApplicationFacade.SET_RESOURCE, { application : notification.getBody(), icon : newApplicationsParameters.icon }
					);
					
					break;
				}
			}
		}

		private function addEventListeners() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			body.addEventListener( "cancelCreateApplication", cancelCreateApplicationHandler )
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			facade.registerMediator( new ApplicationPropertiesMediator( body.applicationProperties ));
			facade.registerMediator( new ApplicationsListMediator( body.applicationsList ));
			facade.registerMediator( new CreateApplicationMediator( body.createApplicationView ));
		}
		
		private function cancelCreateApplicationHandler( event : Event ) : void
		{
			body.viewStack.selectedIndex = 0;
		}
	}
}