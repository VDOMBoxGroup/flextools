package net.vdombox.ide.core.model
{
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.vo.SettingsVO;
	
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
			{
				_settings.saveLastApplication = rawSettings.saveLastApplication;
			}
			
			if ( rawSettings.hasOwnProperty( "lastApplicationID" ) )
			{
				_settings.lastApplicationID = rawSettings.lastApplicationID;
			}
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
			if ( _settings.lastApplicationID != DEFAULT_LAST_APPLICATION )
				sendNotification( ApplicationFacade.SETTINGS_CHANGED, _settings );
		}
	}
}