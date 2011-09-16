package net.vdombox.ide.common
{
	public class SimpleMessageHeaders
	{
		//		core to modules
		public static const MODULE_SELECTED : String = "sModuleSelected";
		public static const MODULE_UNSELECTED : String = "moduleUnselected";
		//		modules to core
		public static const SELECT_MODULE : String = "selectModule";
		
		public static const RETRIEVE_SETTINGS_FROM_STORAGE : String = "retrieveSettingsFromStorage";
		public static const SAVE_SETTINGS_TO_STORAGE : String = "saveSettingsToStorage";
		
		public static const CONNECT_PROXIES_PIPE : String = "connectProxiesPipe";
		public static const PROXIES_PIPE_CONNECTED : String = "proxiesPipeConnected";
		
		public static const DISCONNECT_PROXIES_PIPE : String = "disconnectProxiesPipe";
		public static const PROXIES_PIPE_DISCONNECTED : String = "proxiesPipeDisconnected";
		
		public static const OPEN_WINDOW : String = "openWindow";
		public static const CLOSE_WINDOW : String = "closeWindow";
		
		public static const OPEN_BROWSER : String = "openBrowser";
		
		
	}
}