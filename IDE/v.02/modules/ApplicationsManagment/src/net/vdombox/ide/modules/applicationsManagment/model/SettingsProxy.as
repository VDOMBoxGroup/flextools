package net.vdombox.ide.modules.applicationsManagment.model
{
	import mx.collections.ArrayList;
	
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
		
		private var _settings : SettingsVO;
		private var _defaultSettings : Object;
		
		override public function onRegister() : void
		{
			_defaultSettings = { saveLAstApplication : true, lastApplication : "" };
		}
		
		public function get defaultSettings() : Object
		{
			return _defaultSettings;
		}
		
		public function getSettings() : SettingsVO
		{
			return _settings;
		}
		
		public function setSettings( value : SettingsVO ) : void
		{
			var settingsChanged : Boolean = false
				
			if( !_settings )
			{
				_settings = value;
				settingsChanged = true;
			}
			
			if( _settings.saveLastApplication != value.saveLastApplication )
			{
				_settings.saveLastApplication = value.saveLastApplication;
				settingsChanged = true;
			}
			
			if( _settings.lastApplicationID != value.lastApplicationID )
			{
				_settings.lastApplicationID = value.lastApplicationID;
				settingsChanged = true;
			}
			
			if( settingsChanged )
				sendNotification( ApplicationFacade.SETTINGS_SETTED, _settings );
		}
	}
}
