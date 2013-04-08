/*Данная прокси используется для "локального" хранения настроек, т.е. внутри модуля, также настройки модуля могут сохранятся
у пользователся при помощи инструментов IDE Core.*/
package net.vdombox.ide.modules.sample.model
{
	import mx.collections.ArrayList;
	
	import net.vdombox.ide.modules.sample.ApplicationFacade;
	import net.vdombox.ide.modules.sample.model.vo.SettingsVO;
	
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
//			устанавливает настройки по умолчанию
			_defaultSettings = { first : true, second : "" };
		}
		
		public function get defaultSettings() : Object
		{
			return _defaultSettings;
		}
		
//		текущие настройки
		public function getSettings() : SettingsVO
		{
			if( _settings )
				return _settings.copy();
			else
				return null;
		}
		
//		установка настроек
		public function setSettings( value : SettingsVO ) : void
		{
			var settingsChanged : Boolean = false
				
			if( !_settings )
			{
				_settings = value;
				settingsChanged = true;
			}
			
			if( _settings.first != value.first )
			{
				_settings.first = value.first;
				settingsChanged = true;
			}
			
			if( _settings.second != value.second )
			{
				_settings.second = value.second;
				settingsChanged = true;
			}
			
			if( settingsChanged )
				sendNotification( ApplicationFacade.SETTINGS_CHANGED, _settings );
		}
		
		public function cleanup() : void
		{
			_settings = null;
		}
	}
}
