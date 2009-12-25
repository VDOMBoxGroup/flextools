package net.vdombox.ide.modules.applicationsManagment
{
	import net.vdombox.ide.modules.ApplicationsManagment;
	import net.vdombox.ide.modules.applicationsManagment.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.GetSettingsCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.InitializeSettingsCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.SaveSettingsToProxy;
	import net.vdombox.ide.modules.applicationsManagment.controller.SetSettingsCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.StartupCommand;
	import net.vdombox.ide.modules.applicationsManagment.controller.TearDownCommand;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class ApplicationFacade extends Facade implements IFacade
	{
//		main
		public static const STARTUP : String = "startup";
		
		public static const CREATE_TOOLSET : String = "createToolset";
		public static const CREATE_SETTINGS_SCREEN : String = "createSettingsScreen";
		public static const CREATE_BODY : String = "createBody";
		
		public static const EXPORT_TOOLSET : String = "exportToolset";
		public static const EXPORT_SETTINGS_SCREEN : String = "exportSettingsScreen";
		public static const EXPORT_BODY : String = "exportBody";
		
//		selection
		public static const MODULE_SELECTED : String = "moduleSelected";
		public static const MODULE_DESELECTED : String = "moduleDeselected";
		
		public static const PIPES_READY : String = "pipesReady";

//		tear down
		public static const TEAR_DOWN : String = "tearDown";		
		
//		settings
		public static const INITIALIZE_SETTINGS : String = "initializeSettings";
		
		public static const GET_SETTINGS : String = "getSettings";
		public static const SET_SETTINGS : String = "setSettings";
		
		public static const SETTINGS_GETTED : String = "settingsGetted";
		public static const SETTINGS_CHANGED : String = "settingsChanged";
		
		public static const RETRIEVE_SETTINGS_FROM_STORAGE : String = "retrieveSettingsFromStorage";
		public static const SAVE_SETTINGS_TO_STORAGE : String = "saveSettingsToStorage";
		public static const SAVE_SETTINGS_TO_PROXY : String = "saveSettingsToProxy";
		
		public static const OPEN_CREATE_APPLICATION_VIEW : String = "openCreateApplicationView";
		
		public static const CREATE_NEW_APP_COMPLETE: String = "createNewAppComplete";
		public static const CREATE_NEW_APP_CANCELED: String = "createNewAppCanceled";
		
		public static const CREATE_APPLICATION : String = "createApplication";
		public static const APPLICATION_CREATED : String = "applicationCreated";
		
		public static const EDIT_APPLICATION_INFORMATION : String = "editApplicationInformation";
		public static const APPLICATION_EDITED : String = "ApplicationEdited";
		
//		application	
		public static const GET_SELECTED_APPLICATION : String = "getSelectedApplication";
		public static const SET_SELECTED_APPLICATION : String = "setSelectedApplication";
		public static const SELECTED_APPLICATION_CHANGED : String = "selectedApplicationChanged";
		
		public static const GET_APPLICATIONS_LIST : String = "getApplicationsList";
		public static const APPLICATIONS_LIST_GETTED : String = "applicationsListGetted";
		
//		resources
		public static const LOAD_RESOURCE : String = "loadResource";
		public static const RESOURCE_LOADED : String = "resourceLoaded";

		public static const SET_RESOURCE : String = "setResource";
		public static const RESOURCE_SETTED : String = "resourceSetted";
		
		
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
			
			registerCommand( INITIALIZE_SETTINGS, InitializeSettingsCommand );
			registerCommand( GET_SETTINGS, GetSettingsCommand );
			registerCommand( SET_SETTINGS, SetSettingsCommand );
			registerCommand( SAVE_SETTINGS_TO_PROXY, SaveSettingsToProxy );
			
			registerCommand( TEAR_DOWN, TearDownCommand );
		}
	}
}