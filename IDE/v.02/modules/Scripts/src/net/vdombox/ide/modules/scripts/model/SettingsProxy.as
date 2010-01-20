package net.vdombox.ide.modules.scripts.model
{
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.model.vo.SettingsVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class SettingsProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SettingsProxy";

		public function SettingsProxy()
		{
			super( NAME );
		}

		private var _settings : SettingsVO;

		private var _defaultSettings : SettingsVO;

		override public function onRegister() : void
		{
			_defaultSettings = new SettingsVO( { testSetting: "test setting" } );
		}

		public function get defaultSettings() : SettingsVO
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

			_settings = value;
			settingsChanged = true;

			if ( settingsChanged )
				sendNotification( ApplicationFacade.SETTINGS_CHANGED, _settings );
		}
	}
}
