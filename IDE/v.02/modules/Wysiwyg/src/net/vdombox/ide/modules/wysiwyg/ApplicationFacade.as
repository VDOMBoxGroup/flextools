package net.vdombox.ide.modules.wysiwyg
{
	import net.vdombox.ide.modules.Wysiwyg;
	import net.vdombox.ide.modules.wysiwyg.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.GetSettingsCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.InitializeSettingsCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.SaveSettingsToProxy;
	import net.vdombox.ide.modules.wysiwyg.controller.SetSettingsCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.StartupCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.TearDownCommand;
	
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
		
//		application
		public static const GET_SELECTED_APPLICATION : String = "getSelectedApplication";
		public static const SELECTED_APPLICATION_GETTED: String = "selectedApplicationGetted";
		
//		resources
		public static const GET_RESOURCES : String = "getResources";
		public static const RESOURCES_GETTED : String = "resourcesGetted";

		public static const LOAD_RESOURCE : String = "loadResource";
		public static const RESOURCE_LOADED : String = "resourceLoadded";
		
		public static const SET_RESOURCES : String = "setResources";
		public static const RESOURCE_SETTED : String = "resourceSetted";
		
		public static const DELETE_RESOURCE : String = "deleteResource";
		public static const RESOURCE_DELETED : String = "resourceDeleted";

		
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
		
		public function startup( application : Wysiwyg ) : void
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