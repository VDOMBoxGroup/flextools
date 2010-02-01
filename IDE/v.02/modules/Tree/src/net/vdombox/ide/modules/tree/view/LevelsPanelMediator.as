package net.vdombox.ide.modules.tree.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.events.LevelsFilterPanelEvent;
	import net.vdombox.ide.modules.tree.model.vo.StructureLevelVO;
	import net.vdombox.ide.modules.tree.view.components.LevelsFilterPanel;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class LevelsPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LevelsPanelMediator";
		
		public function LevelsPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		public function get levelsPanel() : LevelsFilterPanel
		{
			return viewComponent as LevelsFilterPanel;
		}
		
		override public function onRegister() : void
		{
			addEventListeners();
			
			sendNotification( ApplicationFacade.GET_STRUCTURE_LEVELS );
		}
		
		override public function onRemove() : void
		{
			removeEventListeners();
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.STRUCTURE_LEVELS_GETTED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			switch ( name )
			{
				case ApplicationFacade.STRUCTURE_LEVELS_GETTED:
				{
					levelsPanel.dataProvider = body as Array;
					levelsPanel.currentStructureLevel = body[ 0 ] as StructureLevelVO;
					
					break;
				}
			}
		}
		
		private function addEventListeners() : void
		{
			levelsPanel.addEventListener( LevelsFilterPanelEvent.CURRENT_LEVEL_CHANGED, changeHandler );
		}
		
		private function removeEventListeners() : void
		{
			
		}
		
		private function changeHandler( event : Event ) : void
		{
			sendNotification( ApplicationFacade.SELECTED_STRUCTURE_LEVEL_CHANGED, levelsPanel.currentStructureLevel );
		}
	}
}