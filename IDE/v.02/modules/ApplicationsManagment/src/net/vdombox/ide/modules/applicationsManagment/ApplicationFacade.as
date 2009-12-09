package net.vdombox.ide.modules.applicationsManagment
{
	import net.vdombox.ide.modules.ApplicationsManagment;
	import net.vdombox.ide.modules.applicationsManagment.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.GetSettingsCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.InitializeSettingsCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.SetSettingsCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.StartupCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.TearDownCommand;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class ApplicationFacade extends Facade implements IFacade
	{
		public static const STARTUP : String = "startup";
		
		public static const CREATE_TOOLSET : String = "createToolset";
		public static const CREATE_SETTINGS_SCREEN : String = "createSettingsScreen";
		public static const CREATE_BODY : String = "createBody";
		
		public static const EXPORT_TOOLSET : String = "exportToolset";
		public static const EXPORT_SETTINGS_SCREEN : String = "exportSettingsScreen";
		public static const EXPORT_BODY : String = "exportBody";
		
//		settings
		public static const INITIALIZE_SETTINGS : String = "initializeSettings";
		
		public static const GET_SETTINGS : String = "getSettings";
		public static const SET_SETTINGS : String = "setSettings";
		
		public static const SETTINGS_GETTED : String = "settingsGetted";
		public static const SETTINGS_SETTED : String = "settingsSetted";
		
		public static const RETRIEVE_SETTINGS_FROM_STORAGE : String = "retrieveSettingsFromStorage";
		public static const SAVE_SETTINGS_TO_STORAGE : String = "saveSettingsToStorage";
		public static const SAVE_SETTINGS_TO_PROXY : String = "saveSettingsToProxy";
		
//		selection
		public static const MODULE_SELECTED : String = "moduleSelected";
		public static const MODULE_DESELECTED : String = "moduleDeselected";
		
		public static const CONNECT_PROXIES_PIPE : String = "connectProxiesPipe";
		
		public static const GET_SELECTED_APPLICATION : String = "getSelectedApplication";
		public static const SET_SELECTED_APPLICATION : String = "setSelectedApplication";
		public static const SELECTED_APPLICATION_CHANGED : String = "selectedApplicationChanged";
		
		public static const GET_APPLICATIONS_LIST : String = "getApplicationsList";
		public static const APPLICATIONS_LIST_GETTED : String = "applicationsListGetted";
		
		public static const GET_RESOURCE : String = "getResource";
		public static const RESOURCE_GETTED : String = "resourceGetted";
		
		public static const TEAR_DOWN : String = "tearDown";
		
		public static function getInstance( key : String ) : ApplicationFacade
		{
			if ( instanceMap[ key ] == null )
				instanceMap[ key ] = new ApplicationFacade( key );
			return instanceMap[ key ] as ApplicationFacade;
		}

		public function ApplicationFacade( key : String )
		{
			super( key );
		}
		
		public function startup( application : ApplicationsManagment ) : void
		{
			sendNotification( STARTUP, application );
		}
		
		override protected function initializeController( ) : void 
		{
			super.initializeController();
			registerCommand( STARTUP, StartupCommand );
			registerCommand( CREATE_TOOLSET, CreateToolsetCommand );
			registerCommand( CREATE_SETTINGS_SCREEN, CreateSettingsScreenCommand );
			registerCommand( CREATE_BODY, CreateBodyCommand );
			registerCommand( GET_SETTINGS, GetSettingsCommand );
			registerCommand( SET_SETTINGS, SetSettingsCommand );
			registerCommand( INITIALIZE_SETTINGS, InitializeSettingsCommand );
			registerCommand( TEAR_DOWN, TearDownCommand );
		}
	}
}