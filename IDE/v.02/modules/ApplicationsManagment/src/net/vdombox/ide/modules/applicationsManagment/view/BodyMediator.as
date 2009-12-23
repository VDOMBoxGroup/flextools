package net.vdombox.ide.modules.applicationsManagment.view
{
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
			interests.push( ApplicationFacade.NEW_APP_PROPS_CANCELED );
			interests.push( ApplicationFacade.APPLICATION_CREATED );
			interests.push( ApplicationFacade.APPLICATION_EDITED );
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
					body.currentState = "CreateApplicationView";
					
					break;
				}
					
				case ApplicationFacade.NEW_APP_PROPS_SUBMITTED:
				{
					newApplicationsParameters = notification.getBody();
					
					var applicationPropertiesVO : ApplicationPropertiesVO = new ApplicationPropertiesVO();
					
					applicationPropertiesVO.name = newApplicationsParameters.name;
					applicationPropertiesVO.description = newApplicationsParameters.description;
					
					if( newApplicationsParameters.hasOwnProperty( "name" ) )
					{
						sendNotification( ApplicationFacade.CREATE_APPLICATION, applicationPropertiesVO );
					}
					
					break;
				}
					
				case ApplicationFacade.NEW_APP_PROPS_CANCELED:
				{
					body.currentState = "default";
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_CREATED:
				{
					createdApplicationVO = notification.getBody() as ApplicationVO;
					
					resourceVO = new ResourceVO( createdApplicationVO.id );
					
					resourceVO.setData( newApplicationsParameters.icon );
					resourceVO.setType( "png" );
					resourceVO.name = "applicationIcon";
						
					sendNotification( ApplicationFacade.SET_RESOURCE, resourceVO );
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_EDITED:
				{
					body.currentState = "default";
					
					break;
				}
					
				case ApplicationFacade.RESOURCE_SETTED:
				{
					resourceVO = notification.getBody() as ResourceVO;
					
					var appPropertiesVO : ApplicationPropertiesVO = new ApplicationPropertiesVO();
					
					appPropertiesVO.iconID = resourceVO.id;
					
					sendNotification( ApplicationFacade.EDIT_APPLICATION_INFORMATION,
									  { applicationVO : createdApplicationVO, applicationPropertiesVO : appPropertiesVO } );
					
					break;
				}
			}
		}

		private function addEventListeners() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			facade.registerMediator( new EditApplicationViewMediator( body.editApplicationView ));
			facade.registerMediator( new CreateApplicationViewMediator( body.createApplicationView ));
		}
	}
}