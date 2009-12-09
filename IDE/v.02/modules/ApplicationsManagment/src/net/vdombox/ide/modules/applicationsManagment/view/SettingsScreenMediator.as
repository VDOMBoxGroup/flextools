package net.vdombox.ide.modules.applicationsManagment.view
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.model.vo.SettingsVO;
	import net.vdombox.ide.modules.applicationsManagment.view.components.SettingsScreen;
	
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
		
		override public function onRegister() : void
		{
			addEventListeners();
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( NAME + "/" + ApplicationFacade.SETTINGS_GETTED );
			interests.push( ApplicationFacade.SETTINGS_SETTED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var settingsVO : SettingsVO = notification.getBody() as SettingsVO;
			settingsScreen.saveLastApplication.selected = settingsVO.saveLastApplication;
		}
		
		private function get settingsScreen() : SettingsScreen
		{
			return viewComponent as SettingsScreen;
		}
		
		private function addEventListeners() : void
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
			sendNotification( ApplicationFacade.SET_SETTINGS, NAME );
		}
	}
}