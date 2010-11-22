/*
Реализация фасада
*/

package net.vdombox.ide.modules.sample
{
	import net.vdombox.ide.modules.Sample;
	import net.vdombox.ide.modules.sample.controller.BodyStopCommand;
	import net.vdombox.ide.modules.sample.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.sample.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.sample.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.sample.controller.GetSettingsCommand;
	import net.vdombox.ide.modules.sample.controller.InitializeSettingsCommand;
	import net.vdombox.ide.modules.sample.controller.SaveSettingsToProxy;
	import net.vdombox.ide.modules.sample.controller.SetSettingsCommand;
	import net.vdombox.ide.modules.sample.controller.StartupCommand;
	import net.vdombox.ide.modules.sample.controller.TearDownCommand;
	import net.vdombox.ide.modules.sample.controller.messages.ProcessApplicationProxyMessageCommand;
	import net.vdombox.ide.modules.sample.controller.messages.ProcessObjectProxyMessageCommand;
	import net.vdombox.ide.modules.sample.controller.messages.ProcessPageProxyMessageCommand;
	import net.vdombox.ide.modules.sample.controller.messages.ProcessResourcesProxyMessageCommand;
	import net.vdombox.ide.modules.sample.controller.messages.ProcessStatesProxyMessageCommand;
	import net.vdombox.ide.modules.sample.controller.messages.ProcessTypesProxyMessageCommand;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class ApplicationFacade extends Facade implements IFacade
	{
		
/*		
		Блок констант, используемых при уведомлениях (Notifications)
*/		
		
//		main
		public static const STARTUP : String = "startup";

		public static const CREATE_TOOLSET : String = "createToolset";
		public static const CREATE_SETTINGS_SCREEN : String = "createSettingsScreen";

		public static const CREATE_BODY : String = "createBody";
		public static const BODY_CREATED : String = "bodyCreated";
		
		public static const BODY_START : String = "bodyStart";
		public static const BODY_STOP : String = "bodyStop";

		public static const EXPORT_TOOLSET : String = "exportToolset";
		public static const EXPORT_SETTINGS_SCREEN : String = "exportSettingsScreen";
		public static const EXPORT_BODY : String = "exportBody";

//		selection
		public static const SELECT_MODULE : String = "selectModule";
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

//		pipe messages
		public static const PROCESS_SERVER_PROXY_MESSAGE : String = "processServerProxyMessage";
		public static const PROCESS_TYPES_PROXY_MESSAGE : String = "processTypesProxyMessage";
		public static const PROCESS_STATES_PROXY_MESSAGE : String = "processStatesProxyMessage";
		public static const PROCESS_RESOURCES_PROXY_MESSAGE : String = "processResourcesProxyMessage";
		public static const PROCESS_APPLICATION_PROXY_MESSAGE : String = "processApplicationProxyMessage";
		public static const PROCESS_PAGE_PROXY_MESSAGE : String = "processPageProxyMessage";
		public static const PROCESS_OBJECT_PROXY_MESSAGE : String = "processObjectProxyMessage";

//		types
		public static const GET_TYPES : String = "getTypes";
		public static const TYPES_CHANGED : String = "typesChanged";

//		resources
		public static const GET_RESOURCES : String = "getResources";
		public static const RESOURCES_GETTED : String = "resourcesGetted";

		public static const LOAD_RESOURCE : String = "loadResource";
		public static const MODIFY_RESOURCE : String = "modifyResource";

//		states	
		public static const GET_ALL_STATES : String = "getAllStates";
		public static const ALL_STATES_GETTED : String = "allStatesGetted";

		public static const SET_ALL_STATES : String = "setAllStates";
		public static const ALL_STATES_SETTED : String = "allStatesSetted";

		public static const SELECTED_APPLICATION_CHANGED : String = "selectedApplicationChanged";
		public static const SELECTED_PAGE_CHANGED : String = "selectedPageChanged";
		public static const SELECTED_OBJECT_CHANGED : String = "selectedObjectChanged";

//		pages
		public static const GET_PAGES : String = "getPages";
		public static const PAGES_GETTED : String = "pagesGetted";
		public static const GET_PAGE_SRUCTURE : String = "getPageStructure";
		public static const PAGE_STRUCTURE_GETTED : String = "pageStructureGetted";

//		реализация Singleton
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

//		"запуск" модуля
		public function startup( application : Sample ) : void
		{
			sendNotification( STARTUP, application );
		}

//		инициализация контроллеров, вызывается срау после создания ApplicationFacade
		override protected function initializeController() : void
		{
			super.initializeController();
			
//			регистраия команд при вызове соответствующих уведомлений
			registerCommand( STARTUP, StartupCommand );

			registerCommand( CREATE_TOOLSET, CreateToolsetCommand );
			registerCommand( CREATE_SETTINGS_SCREEN, CreateSettingsScreenCommand );
			registerCommand( CREATE_BODY, CreateBodyCommand );
			
			registerCommand( BODY_STOP, BodyStopCommand );

			registerCommand( INITIALIZE_SETTINGS, InitializeSettingsCommand );
			registerCommand( GET_SETTINGS, GetSettingsCommand );
			registerCommand( SET_SETTINGS, SetSettingsCommand );
			registerCommand( SAVE_SETTINGS_TO_PROXY, SaveSettingsToProxy );

			registerCommand( PROCESS_TYPES_PROXY_MESSAGE, ProcessTypesProxyMessageCommand );
			registerCommand( PROCESS_STATES_PROXY_MESSAGE, ProcessStatesProxyMessageCommand );
			registerCommand( PROCESS_RESOURCES_PROXY_MESSAGE, ProcessResourcesProxyMessageCommand );
			registerCommand( PROCESS_APPLICATION_PROXY_MESSAGE, ProcessApplicationProxyMessageCommand );
			registerCommand( PROCESS_PAGE_PROXY_MESSAGE, ProcessPageProxyMessageCommand );
			registerCommand( PROCESS_OBJECT_PROXY_MESSAGE, ProcessObjectProxyMessageCommand );

			registerCommand( TEAR_DOWN, TearDownCommand );
		}
	}
}