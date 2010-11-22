//Value Object настроек модуля
package net.vdombox.ide.modules.sample.model.vo
{
	public class SettingsVO
	{
		public function SettingsVO( settings : Object = null )
		{
			if( settings.hasOwnProperty( "first" ) )
				first = settings[ "first" ];
			
			if( settings.hasOwnProperty( "second" ) )
				second = settings[ "second" ];
		}
		
		public var first : Boolean;
		public var second : String;
		
		public function copy() : SettingsVO
		{
			var settingsVO : SettingsVO = new SettingsVO();
			
			settingsVO.first = first;
			settingsVO.second = second;
			
			return settingsVO;
		}
	}
}