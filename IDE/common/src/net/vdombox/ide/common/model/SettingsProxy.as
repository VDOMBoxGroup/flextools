package net.vdombox.ide.common.model
{
	import net.vdombox.ide.common.model._vo.SettingsVO;

	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class SettingsProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SettingsProxy";

		public static const INITIALIZE_SETTINGS : String = "initializeSettings";

		public static const GET_SETTINGS : String = "getSettings";

		public static const SET_SETTINGS : String = "setSettings";

		public static const SETTINGS_GETTED : String = "settingsGetted";

		public static const SETTINGS_CHANGED : String = "settingsChanged";

		public static const RETRIEVE_SETTINGS_FROM_STORAGE : String = "retrieveSettingsFromStorage";

		public static const SAVE_SETTINGS_TO_STORAGE : String = "saveSettingsToStorage";

		public static const SAVE_SETTINGS_TO_PROXY : String = "saveSettingsToProxy";

		public function SettingsProxy()
		{
			super( NAME );
		}

		private var _settings : SettingsVO;

		private var _defaultSettings : Object;

		override public function onRegister() : void
		{
			_defaultSettings = { saveLAstApplication: true, lastApplication: "" };
		}

		public function get defaultSettings() : Object
		{
			return _defaultSettings;
		}

		public function getSettings() : SettingsVO
		{
			if ( _settings )
				return _settings.copy();
			else
				return null;
		}

		public function setSettings( value : SettingsVO ) : void
		{
			var settingsChanged : Boolean = false

			if ( !_settings )
			{
				_settings = value;
				settingsChanged = true;
			}

			if ( _settings.saveLastApplication != value.saveLastApplication )
			{
				_settings.saveLastApplication = value.saveLastApplication;
				settingsChanged = true;
			}

			if ( _settings.lastApplicationID != value.lastApplicationID )
			{
				_settings.lastApplicationID = value.lastApplicationID;
				settingsChanged = true;
			}

			if ( settingsChanged )
				sendNotification( SETTINGS_CHANGED, _settings );
		}
	}
}
