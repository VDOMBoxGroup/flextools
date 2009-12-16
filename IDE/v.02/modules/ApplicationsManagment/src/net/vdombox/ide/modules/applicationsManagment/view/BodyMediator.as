package net.vdombox.ide.modules.applicationsManagment.view
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationPropertiesVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
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
		
		private var createdApplicationVO : ApplicationVO
		
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
			interests.push( ApplicationFacade.RESOURCE_SETTED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var resourceVO : ResourceVO;
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
					createdApplicationVO = notification.getBody() as ApplicationVO;
					
					resourceVO = new ResourceVO();
					resourceVO.ownerID = createdApplicationVO.id;
					resourceVO.data = newApplicationsParameters.icon;
						
					sendNotification( ApplicationFacade.SET_RESOURCE, resourceVO );
					
					break;
				}
					
				case ApplicationFacade.RESOURCE_SETTED:
				{
					resourceVO = notification.getBody() as ResourceVO;
					
					var appPropertiesVO : ApplicationPropertiesVO = new ApplicationPropertiesVO();
					
					appPropertiesVO.name = newApplicationsParameters.name;
					appPropertiesVO.description = newApplicationsParameters.description;
					appPropertiesVO.iconID = resourceVO.resourceID;
					
					sendNotification( ApplicationFacade.EDIT_APPLICATION,
									  { applicationVO : createdApplicationVO, applicationPropertiesVO : appPropertiesVO } );
					
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