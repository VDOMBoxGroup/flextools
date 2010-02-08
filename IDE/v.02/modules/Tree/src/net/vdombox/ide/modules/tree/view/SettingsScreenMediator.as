package net.vdombox.ide.modules.tree.view
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.vo.SettingsVO;
	import net.vdombox.ide.modules.tree.view.components.SettingsScreen;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class SettingsScreenMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "SettingsScreenMediator";
		
		public function SettingsScreenMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		private var settingsVO : SettingsVO;
		
		override public function onRegister() : void
		{
			addHandlers();
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( NAME + ApplicationFacade.DELIMITER + ApplicationFacade.SETTINGS_GETTED );
			interests.push( ApplicationFacade.SETTINGS_CHANGED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			settingsVO = notification.getBody() as SettingsVO;
		}
		
		private function get settingsScreen() : SettingsScreen
		{
			return viewComponent as SettingsScreen;
		}
		
		private function addHandlers() : void
		{
			settingsScreen.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			settingsScreen.addEventListener( "performOK", performOKHandler );
		}
		
		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( ApplicationFacade.GET_SETTINGS, NAME );
		}
		
		private function performOKHandler( event : Event ) : void
		{			
			sendNotification( ApplicationFacade.SET_SETTINGS, settingsVO );
		}
	}
}