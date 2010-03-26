package net.vdombox.ide.modules.events.view
{
	import net.vdombox.ide.common.vo.ApplicationEventsVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	import net.vdombox.ide.modules.events.model.SessionProxy;
	import net.vdombox.ide.modules.events.view.components.WorkArea;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class WorkAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "WorkAreaMediator";

		public function WorkAreaMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var isActive : Boolean;
		private var sessionProxy : SessionProxy;

		public function get workArea() : WorkArea
		{
			return viewComponent as WorkArea;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			isActive = false;

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );

			interests.push( ApplicationFacade.APPLICATION_EVENTS_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;

			switch ( name )
			{
				case ApplicationFacade.BODY_START:
				{
					isActive = true;

					break;
				}

				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					break;
				}

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					if ( sessionProxy.selectedApplication && sessionProxy.selectedPage )
					{
						sendNotification( ApplicationFacade.GET_APPLICATION_EVENTS,
										  { applicationVO: sessionProxy.selectedApplication, pageVO: sessionProxy.selectedPage } );
					}
					break;
				}
					
				case ApplicationFacade.APPLICATION_EVENTS_GETTED:
				{
					workArea.dataProvider = body as ApplicationEventsVO;
					break;
				}	
			}
		}

		private function addHandlers() : void
		{
		}

		private function removeHandlers() : void
		{
		}
	}
}