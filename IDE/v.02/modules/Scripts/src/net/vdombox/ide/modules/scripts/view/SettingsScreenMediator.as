package net.vdombox.ide.modules.scripts.view
{
	import flash.events.Event;

	import mx.events.FlexEvent;

	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.common.model._vo.SettingsVO;
	import net.vdombox.ide.modules.scripts.view.components.SettingsScreen;

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
			addEventListeners();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( NAME + "/" + SettingsProxy.SETTINGS_GETTED );
			interests.push( SettingsProxy.SETTINGS_CHANGED );

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

		private function addEventListeners() : void
		{
			settingsScreen.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
			settingsScreen.addEventListener( "performOK", performOKHandler );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( SettingsProxy.GET_SETTINGS, NAME );
		}

		private function performOKHandler( event : Event ) : void
		{
			sendNotification( SettingsProxy.SET_SETTINGS, settingsVO );
		}
	}
}
