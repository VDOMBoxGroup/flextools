package net.vdombox.ide.modules.applicationsManagment.model.vo
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
	}
}