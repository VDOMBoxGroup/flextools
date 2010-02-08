package net.vdombox.ide.modules.tree
{
	import net.vdombox.ide.modules.Tree;
	import net.vdombox.ide.modules.tree.controller.ArrowCreatedCommand;
	import net.vdombox.ide.modules.tree.controller.BodyCreatedCommand;
	import net.vdombox.ide.modules.tree.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.tree.controller.CreatePageRequestCommand;
	import net.vdombox.ide.modules.tree.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.tree.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.tree.controller.GetSettingsCommand;
	import net.vdombox.ide.modules.tree.controller.GetStructureLevelsCommand;
	import net.vdombox.ide.modules.tree.controller.InitializeCommand;
	import net.vdombox.ide.modules.tree.controller.InitializeCompleteCommand;
	import net.vdombox.ide.modules.tree.controller.InitializeSettingsCommand;
	import net.vdombox.ide.modules.tree.controller.OpenCreatePageWindowRequestCommand;
	import net.vdombox.ide.modules.tree.controller.PageTypeItemRendererCreatedCommand;
	import net.vdombox.ide.modules.tree.controller.ProcessApplicationProxyMessageCommand;
	import net.vdombox.ide.modules.tree.controller.ProcessPageProxyMessageCommand;
	import net.vdombox.ide.modules.tree.controller.ProcessResourcesProxyMessageCommand;
	import net.vdombox.ide.modules.tree.controller.ProcessStatesProxyMessageCommand;
	import net.vdombox.ide.modules.tree.controller.ProcessTypesProxyMessageCommand;
	import net.vdombox.ide.modules.tree.controller.SaveSettingsToProxy;
	import net.vdombox.ide.modules.tree.controller.SelectedApplicationGettedCommand;
	import net.vdombox.ide.modules.tree.controller.SetSettingsCommand;
	import net.vdombox.ide.modules.tree.controller.StartupCommand;
	import net.vdombox.ide.modules.tree.controller.TearDownCommand;
	import net.vdombox.ide.modules.tree.controller.TreeElementCreatedCommand;
	
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
		
//		types
		public static const GET_TYPE : String = "getType";
		public static const TYPE_GETTED : String = "typeGetted";
		
		public static const GET_TOP_LEVEL_TYPES : String = "getTopLevelTypes";
		public static const TOP_LEVEL_TYPES_GETTED : String = "topLevelTypesGetted";
		
//		states
		public static const GET_SELECTED_APPLICATION : String = "getSelectedApplication";
		public static const SELECTED_APPLICATION_GETTED : String = "selectedApplicationGetted";
		
		public static const GET_SELECTED_PAGE : String = "getSelectedPage";
		public static const SELECTED_PAGE_GETTED : String = "selectedPageGetted";
		
		public static const SELECTED_PAGE_CHANGED : String = "selectedPageChanged";
		
//		application
		public static const GET_APPLICATION_STRUCTURE : String = "getApplicationStructure";
		public static const APPLICATION_STRUCTURE_GETTED : String = "applicationStructureGetted";
		
		public static const GET_PAGES : String = "getPages";
		public static const PAGES_GETTED : String = "pagesGetted";
		
		public static const CREATE_PAGE : String = "createPage";
		public static const PAGE_CREATED : String = "pageCreated";

//		pages
		public static const GET_PAGE_ATTRIBUTES : String = "getPageAttributes";
		public static const PAGE_ATTRIBUTES_GETTED : String = "pageAttributesGetted";
		
//		resources
		public static const GET_RESOURCE : String = "getResource";
		public static const RESOURCE_GETTED : String = "resourceGetted";
		
//		other
		public static const BODY_SESSION_OBJECT : String = "bodySessionObject";
		
		public static const CREATE_PAGE_REQUEST : String = "createPageRequest";
		
		public static const OPEN_CREATE_PAGE_WINDOW_REQUEST : String = "openCreatePageWindowRequest";
		public static const AUTO_SPACING_REQUEST : String = "autoSpacingRequest";
		public static const EXPAND_ALL_REQUEST : String = "expandAllRequest";
		public static const SHOW_SIGNATURE_REQUEST : String = "showSignatureRequest";
		public static const SAVE_REQUEST : String = "saveRequest";
		
		public static const DELIMITER : String = "/";
		
		public static const STATES : String = "states";
		
		public static const SELECTED_APPLICATION : String = "selectedApplication";
		public static const SELECTED_PAGE : String = "selectedPage";
		
		public static const TREE_ELEMENT_CREATED : String = "treeElementCreated";
		public static const TREE_ELEMENT_SELECTION : String = "treeElementSelection";
		public static const ARROW_CREATED : String = "arrowCreated";
		
		public static const BODY_CREATED : String = "bodyCreated";
		public static const CREATE_PAGE_WINDOW_CREATED : String = "createPageWindowCreated";
		
		public static const OPEN_WINDOW : String = "openWidow";
		public static const CLOSE_WINDOW : String = "closeWidow";
		
		public static const GET_STRUCTURE_LEVELS: String = "getStructureLevels";
		public static const STRUCTURE_LEVELS_GETTED: String = "structureLevelsGetted";
		
//		public static const GET_SELECTED_STRUCTURE_LEVEL: String = "getSelectedStructureLevel";
//		public static const SELECTED_STRUCTURE_LEVEL_GETTED: String = "selectedStructureLevelGetted";
		public static const SELECTED_STRUCTURE_LEVEL_CHANGED: String = "selectedStructureLevelChanged";
		
		public static const PAGE_TYPE_ITEM_RENDERER_CREATED : String = "pageTypeItemRendererCreated";
		
		public static const INITIALIZE_COMPLETE: String = "initializeComplete";
		
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
		
		public function startup( application : Tree ) : void
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
			
			registerCommand( PROCESS_TYPES_PROXY_MESSAGE, ProcessTypesProxyMessageCommand );
			registerCommand( PROCESS_APPLICATION_PROXY_MESSAGE, ProcessApplicationProxyMessageCommand );
			registerCommand( PROCESS_PAGE_PROXY_MESSAGE, ProcessPageProxyMessageCommand );
			registerCommand( PROCESS_STATES_PROXY_MESSAGE, ProcessStatesProxyMessageCommand );
			registerCommand( PROCESS_RESOURCES_PROXY_MESSAGE, ProcessResourcesProxyMessageCommand );
			
			registerCommand( TREE_ELEMENT_CREATED, TreeElementCreatedCommand );
			registerCommand( ARROW_CREATED, ArrowCreatedCommand );
			
			registerCommand( BODY_CREATED, BodyCreatedCommand );
			registerCommand( OPEN_CREATE_PAGE_WINDOW_REQUEST, OpenCreatePageWindowRequestCommand );
			
			registerCommand( SELECTED_APPLICATION_GETTED, SelectedApplicationGettedCommand );
			
			registerCommand( PAGES_GETTED, InitializeCommand );
			
			registerCommand( APPLICATION_STRUCTURE_GETTED, InitializeCommand );
			registerCommand( INITIALIZE_COMPLETE, InitializeCompleteCommand );
			
			registerCommand( GET_STRUCTURE_LEVELS, GetStructureLevelsCommand );
			
			registerCommand( PAGE_TYPE_ITEM_RENDERER_CREATED, PageTypeItemRendererCreatedCommand );
			
			registerCommand( CREATE_PAGE_REQUEST, CreatePageRequestCommand );
			
			registerCommand( TEAR_DOWN, TearDownCommand );
		}
	}
}