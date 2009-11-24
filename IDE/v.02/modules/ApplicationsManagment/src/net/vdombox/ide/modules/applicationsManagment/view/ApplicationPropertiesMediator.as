package net.vdombox.ide.modules.applicationsManagment.view
{
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.view.components.ApplicationProperties;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ApplicationPropertiesMediator extends Mediator implements IMediator
	{
		public function ApplicationPropertiesMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		public const NAME : String = "ApplicationPropertiesMediator";

		private var selectedApplicationID : String;

		override public function onRegister() : void
		{

		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SELECTED_APPLICATION_CHANGED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName())
			{
				case ApplicationFacade.SELECTED_APPLICATION_CHANGED:
				{
					var applicationVO : Object = notification.getBody();
					var newSelectedApplicationID : String = applicationVO.id;
					
					if ( newSelectedApplicationID == selectedApplicationID )
					{
						return;
					}
					else if ( newSelectedApplicationID == "" )
					{
						applicationProperties.visible = false;
					}
					else
					{
						applicationProperties.applicationName.text = applicationVO.name;
						applicationProperties.applicationDescription.text = applicationVO.description;
						
					}
					break;
				}
			}
		}

		private function get applicationProperties() : ApplicationProperties
		{
			return viewComponent as ApplicationProperties;
		}
	}
}