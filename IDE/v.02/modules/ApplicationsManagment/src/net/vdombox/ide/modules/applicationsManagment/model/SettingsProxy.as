package net.vdombox.ide.modules.applicationsManagment.model
{
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;

	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.model.vo.SettingsVO;

	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class SettingsProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SettingsProxy";

		public function SettingsProxy()
		{
			super( NAME );
		}

		private const DEFAULT_SAVE_LAST_APPLICATION : Boolean = true;

		private const DEFAULT_LAST_APPLICATION : String = "";

		private var _settings : SettingsVO;

		private var saveLastApplicationChangeWatcher : ChangeWatcher;

		private var lastApplicationIDChangeWatcher : ChangeWatcher;

		override public function onRegister() : void
		{
			_settings = new SettingsVO();

			_settings.saveLastApplication = DEFAULT_SAVE_LAST_APPLICATION;
			_settings.lastApplicationID = DEFAULT_LAST_APPLICATION;

			saveLastApplicationChangeWatcher = BindingUtils.bindSetter( settingsChanged, _settings, "saveLastApplication",
																		false, true );

			lastApplicationIDChangeWatcher = BindingUtils.bindSetter( settingsChanged, _settings, "lastApplicationID",
																	  false, true );
		}

		public function get settings() : SettingsVO
		{
			return _settings;
		}

		public function importSettings( rawSettings : Object ) : void
		{
			if ( !rawSettings )
				return;

			if ( rawSettings.hasOwnProperty( "saveLastApplication" ) )
				_settings.saveLastApplication = rawSettings.saveLastApplication;

			if ( rawSettings.hasOwnProperty( "lastApplicationID" ) )
				_settings.lastApplicationID = rawSettings.lastApplicationID;
		}

		public function exportSettings() : Object
		{
			return { saveLastApplication: _settings.saveLastApplication, lastApplicationID: _settings.lastApplicationID };
		}

		public function setSettingsToDefault() : void
		{
			_settings.saveLastApplication = DEFAULT_SAVE_LAST_APPLICATION;
			_settings.lastApplicationID = DEFAULT_LAST_APPLICATION;
		}

		private function settingsChanged( object : Object ) : void
		{
			sendNotification( ApplicationFacade.SETTINGS_CHANGED, _settings );
		}

//		public function setSettings( value : SettingsVO ) : void
//		{
//			var settingsChanged : Boolean = false
//				
//			if( !_settings )
//			{
//				_settings = value;
//				settingsChanged = true;
//			}
//			
//			if( _settings.saveLastApplication != value.saveLastApplication )
//			{
//				_settings.saveLastApplication = value.saveLastApplication;
//				settingsChanged = true;
//			}
//			
//			if( _settings.lastApplicationID != value.lastApplicationID )
//			{
//				_settings.lastApplicationID = value.lastApplicationID;
//				settingsChanged = true;
//			}
//			
//			if( settingsChanged )
//				sendNotification( ApplicationFacade.SETTINGS_CHANGED, _settings );
//		}
	}
}
