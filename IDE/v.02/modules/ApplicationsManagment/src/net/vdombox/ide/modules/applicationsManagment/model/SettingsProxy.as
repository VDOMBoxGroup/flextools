package net.vdombox.ide.modules.applicationsManagment.model
{
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
		private var _defaultSettings : SettingsVO;
		
		public function get defaultSettings() : SettingsVO
		{
			return _defaultSettings;
		}
		
		public function getSettings() : SettingsVO
		{
			return _settings;
		}
		
		public function setSettings( value : SettingsVO ) : void
		{
			if( _settings !== value )
			{
				_settings = value;
				sendNotification( ApplicationFacade.SETTINGS_GETTED, _settings );
			}
			
		}
	}
}