package net.vdombox.ide.modules.tree.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.tree.events.LevelsFilterPanelEvent;
	import net.vdombox.ide.modules.tree.model.StatesProxy;
	import net.vdombox.ide.modules.tree.view.components.LevelsFilterPanel;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class LevelsPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LevelsPanelMediator";

		public function LevelsPanelMediator( viewComponent : LevelsFilterPanel )
		{
			super( NAME, viewComponent );
		}

		private var statesProxy : StatesProxy;

		private var isActive : Boolean;

		public function get levelsPanel() : LevelsFilterPanel
		{
			return viewComponent as LevelsFilterPanel;
		}

		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			isActive = false;

			addHandlers();
		}

		override public function onRemove() : void
		{
			statesProxy = null;
			
			removeHandlers();

			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );

			interests.push( Notifications.TREE_LEVELS_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != Notifications.BODY_START )
				return;

			switch ( name )
			{
				case Notifications.BODY_START:
				{
					if ( statesProxy.selectedApplication )
					{
						isActive = true;
						
						sendNotification( Notifications.GET_TREE_LEVELS );

						break;
					}
				}

				case Notifications.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case Notifications.TREE_LEVELS_GETTED:
				{
					levelsPanel.dataProvider = body as Array;

					sendNotification( StatesProxy.SELECTED_TREE_LEVEL_CHANGE_REQUEST, levelsPanel.currentStructureLevel );
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			levelsPanel.addEventListener( LevelsFilterPanelEvent.CURRENT_LEVEL_CHANGED, changeHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			levelsPanel.removeEventListener( LevelsFilterPanelEvent.CURRENT_LEVEL_CHANGED, changeHandler );
		}

		private function clearData() : void
		{
			levelsPanel.dataProvider = null;
		}

		private function changeHandler( event : Event ) : void
		{
			sendNotification( StatesProxy.SELECTED_TREE_LEVEL_CHANGE_REQUEST, levelsPanel.currentStructureLevel );
		}
	}
}