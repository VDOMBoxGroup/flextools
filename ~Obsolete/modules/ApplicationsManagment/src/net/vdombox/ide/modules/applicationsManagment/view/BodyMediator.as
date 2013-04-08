package net.vdombox.ide.modules.applicationsManagment.view
{
	import flash.utils.Timer;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
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
			interests.push( ApplicationFacade.CREATE_NEW_APP_COMPLETE );
			interests.push( ApplicationFacade.CREATE_NEW_APP_CANCELED );
			interests.push( ApplicationFacade.APPLICATION_CREATED );
			interests.push( ApplicationFacade.APPLICATION_EDITED );
			interests.push( ApplicationFacade.RESOURCE_SETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var applicationInformationVO : ApplicationInformationVO;
			var resourceVO : ResourceVO;

			switch ( notification.getName() )
			{
				case ApplicationFacade.OPEN_CREATE_APPLICATION_VIEW:
				{
					body.currentState = "CreateApplicationView";

					break;
				}

				case ApplicationFacade.CREATE_NEW_APP_COMPLETE:
				{
					body.currentState = "default";

					break;
				}

				case ApplicationFacade.CREATE_NEW_APP_CANCELED:
				{
					body.currentState = "default";

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
			facade.registerMediator( new EditApplicationViewMediator( body.editApplicationView ) );
			facade.registerMediator( new CreateApplicationViewMediator( body.createApplicationView ) );
		}
	}
}