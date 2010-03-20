package net.vdombox.ide.modules.events.view
{
	import mx.collections.ArrayList;
	
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	import net.vdombox.ide.modules.events.model.SessionProxy;
	import net.vdombox.ide.modules.events.view.components.EventsPanel;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class EventsPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "EventsPanelMediator";

		public function EventsPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var sessionProxy : SessionProxy;

//		private var currentPage : PageVO;
//		private var currentObject : ObjectVO;

		private var currentTarget : Object;
		private var currentTypeVO : TypeVO;

		private var isActive : Boolean;

		public function get eventsPanel() : EventsPanel
		{
			return viewComponent as EventsPanel;
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

			interests.push( ApplicationFacade.SELECTED_APPLICATION_CHANGED );
			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );

			interests.push( ApplicationFacade.SERVER_ACTIONS_GETTED );

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
				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					break;
				}

				case ApplicationFacade.BODY_START:
				{
					isActive = true;

					break;
				}

				case ApplicationFacade.SERVER_ACTIONS_GETTED:
				{
					showActions( body as Array );
					break;
				}
			}

			commitProperties();
		}

		private function commitProperties() : void
		{
			var newTarget : Object;

			if ( sessionProxy.selectedObject )
				newTarget = sessionProxy.selectedObject;
			else if ( sessionProxy.selectedPage )
				newTarget = sessionProxy.selectedPage;

			if ( !isActive || !newTarget )
			{
				clearData();
				return;
			}

			if ( currentTarget && currentTarget.id == newTarget.id )
				return;

			currentTarget = newTarget;
			currentTypeVO = currentTarget.typeVO;

			eventsPanel.evetsList.dataProvider = new ArrayList( currentTypeVO.events );
			sendNotification( ApplicationFacade.GET_SERVER_ACTIONS, currentTarget );
		}

		private function showActions( serverActions : Array ) : void
		{
			var allActions : Array = currentTypeVO.actions;

			allActions = allActions.concat( serverActions );
			
			eventsPanel.actionsList.dataProvider = new ArrayList( allActions );
		}

		private function clearData() : void
		{
			eventsPanel.evetsList.dataProvider = null;
			eventsPanel.actionsList.dataProvider = null;

			currentTarget = null;
		}

		private function addHandlers() : void
		{
		}

		private function removeHandlers() : void
		{
		}
	}
}