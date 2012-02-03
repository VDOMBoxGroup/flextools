package net.vdombox.ide.common.model._vo
{
	public class SettingsVO
	{
		public function SettingsVO( settings : Object = null )
		{
			if( settings.hasOwnProperty( "saveLastApplication" ) )
				saveLastApplication = settings[ "saveLastApplication" ];
			
			if( settings.hasOwnProperty( "lastApplicationID" ) )
				lastApplicationID = settings[ "lastApplicationID" ];
		}
		
		public var saveLastApplication : Boolean;
		
		public var lastApplicationID : String;
		
		public function copy() : SettingsVO
		{
			var settingsVO : SettingsVO = new SettingsVO();
			
			settingsVO.saveLastApplication = saveLastApplication;
			settingsVO.lastApplicationID = lastApplicationID;
			
			return settingsVO;
		}
		
		public function toObject() : Object
		{
			var object : Object = {};
			
			for ( var setting : String in this )
			{
				object[ setting ] = this[ setting ];
			}
			
			return object;
		}
	}
}