package net.vdombox.ide.common
{
	public class MessageHeaders
	{
		//		core to modules
		public static const MODULE_SELECTED : String = "moduleSelected";
		public static const MODULE_UNSELECTED : String = "moduleUnselected";
		//		modules to core
		public static const SELECT_MODULE : String = "selectModule";
		
		public static const RETRIEVE_SETTINGS : String = "retrieveSettings";
		public static const SAVE_SETTINGS : String = "saveSettings";
		
		public static const CONNECT_PROXIES_PIPE : String = "connectProxiesPipe";
		public static const PROXIES_PIPE_CONNECTED : String = "proxiesPipeConnected";
		
		public static const DISCONNECT_PROXIES_PIPE : String = "disconnectProxiesPipe";
		public static const PROXIES_PIPE_DISCONNECTED : String = "proxiesPipeDisconnected";
	}
}