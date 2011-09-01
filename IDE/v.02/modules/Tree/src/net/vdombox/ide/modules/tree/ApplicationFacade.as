package net.vdombox.ide.modules.tree
{
	import net.vdombox.ide.modules.Tree;
	import net.vdombox.ide.modules.tree.controller.BodyStopCommand;
	import net.vdombox.ide.modules.tree.controller.CreateLinkageCommand;
	import net.vdombox.ide.modules.tree.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.tree.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.tree.controller.GetSettingsCommand;
	import net.vdombox.ide.modules.tree.controller.GetTreeLevelsCommand;
	import net.vdombox.ide.modules.tree.controller.SaveRequestCommand;
	import net.vdombox.ide.modules.tree.controller.SelectedPageGettedCommand;
	import net.vdombox.ide.modules.tree.controller.StartupCommand;
	import net.vdombox.ide.modules.tree.controller.TearDownCommand;
	import net.vdombox.ide.modules.tree.controller.UndoRequestCommand;
	import net.vdombox.ide.modules.tree.controller.body.ApplicationStructureGettedCommand;
	import net.vdombox.ide.modules.tree.controller.body.BodyCreatedCommand;
	import net.vdombox.ide.modules.tree.controller.body.CreateBodyCommand;
	import net.vdombox.ide.modules.tree.controller.body.CreatePageRequestCommand;
	import net.vdombox.ide.modules.tree.controller.body.DeletePageRequestCommand;
	import net.vdombox.ide.modules.tree.controller.body.ExpandAllRequestCommand;
	import net.vdombox.ide.modules.tree.controller.body.LinkageCreatedCommand;
	import net.vdombox.ide.modules.tree.controller.body.LinkageRemovedCommand;
	import net.vdombox.ide.modules.tree.controller.body.OpenCreatePageWindowRequestCommand;
	import net.vdombox.ide.modules.tree.controller.body.OpenResourceSelectorRequestCommand;
	import net.vdombox.ide.modules.tree.controller.body.PageCreatedCommand;
	import net.vdombox.ide.modules.tree.controller.body.PageDeletedCommand;
	import net.vdombox.ide.modules.tree.controller.body.PageTypeItemRendererCreatedCommand;
	import net.vdombox.ide.modules.tree.controller.body.PagesGettedCommand;
	import net.vdombox.ide.modules.tree.controller.body.SelectedTreeElementChangeRequestCommand;
	import net.vdombox.ide.modules.tree.controller.body.SelectedTreeLevelChangeRequestCommand;
	import net.vdombox.ide.modules.tree.controller.body.TreeElementCreatedCommand;
	import net.vdombox.ide.modules.tree.controller.body.TreeElementRemovedCommand;
	import net.vdombox.ide.modules.tree.controller.messages.ProcessApplicationProxyMessageCommand;
	import net.vdombox.ide.modules.tree.controller.messages.ProcessPageProxyMessageCommand;
	import net.vdombox.ide.modules.tree.controller.messages.ProcessResourcesProxyMessageCommand;
	import net.vdombox.ide.modules.tree.controller.messages.ProcessStatesProxyMessageCommand;
	import net.vdombox.ide.modules.tree.controller.messages.ProcessTypesProxyMessageCommand;
	import net.vdombox.ide.modules.tree.controller.settings.InitializeSettingsCommand;
	import net.vdombox.ide.modules.tree.controller.settings.SaveSettingsToProxy;
	import net.vdombox.ide.modules.tree.controller.settings.SetSettingsCommand;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class ApplicationFacade extends Facade implements IFacade
	{
//		main
		public static const STARTUP : String = "startup";

		public static const CREATE_TOOLSET : String = "createToolset";
		public static const CREATE_SETTINGS_SCREEN : String = "createSettingsScreen";
		
		/**
		 * the notification  for send body of IDEModule to IDECore 
		 */		
		public static const CREATE_BODY : String = "createBody";
		public static const BODY_CREATED : String = "bodyCreated";
		
		public static const BODY_START : String = "bodyStart";
		public static const BODY_STOP : String = "bodyStop";

		public static const EXPORT_TOOLSET : String = "exportToolset";
		public static const EXPORT_SETTINGS_SCREEN : String = "exportSettingsScreen";
		public static const EXPORT_BODY : String = "exportBody";

//		selection
		public static const SELECT_MODULE : String = "selectModule";
		
		/**
		 *  the notification for selected IDEModule toolset Button 
		 */		
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
		public static const GET_ALL_STATES : String = "getAllStates";
		public static const ALL_STATES_GETTED : String = "allStatesGetted";
		
		public static const SET_ALL_STATES : String = "setAllStates";
		public static const ALL_STATES_SETTED : String = "allStatesSetted";
		
		public static const SELECTED_APPLICATION_CHANGED : String = "selectedApplicationChanged";
		
//		public static const CHANGE_SELECTED_PAGE_REQUEST : String = "changeSelectedPageRequest";
		public static const SET_SELECTED_PAGE : String = "setSelectedPage";
		public static const SELECTED_PAGE_CHANGED : String = "selectedPageChanged";
		
//		public static const CHANGE_SELECTED_OBJECT_REQUEST : String = "changeSelectedObjectRequest";
		public static const SET_SELECTED_OBJECT : String = "setSelectedObject";
		public static const SELECTED_OBJECT_CHANGED : String = "selectedObjectChanged";
		
		public static const SELECTED_TREE_ELEMENT_CHANGE_REQUEST : String = "selectedTreeElementChangeRequest";
		public static const SELECTED_TREE_ELEMENT_CHANGED : String = "selectedTreeElementChanged";
		

//		resources
		public static const GET_RESOURCES : String = "getResources";
		public static const RESOURCES_GETTED : String = "resourcesGetted";
		
		public static const LOAD_RESOURCE : String = "loadResource";
		
//		application
		public static const GET_APPLICATION_STRUCTURE : String = "getApplicationStructure";
		public static const APPLICATION_STRUCTURE_GETTED : String = "applicationStructureGetted";

		public static const SET_APPLICATION_STRUCTURE : String = "setApplicationStructure";
		public static const APPLICATION_STRUCTURE_SETTED : String = "applicationStructureSetted";
		
		public static const SET_APPLICATION_INFORMATION : String = "setApplicationInformation";
		public static const APPLICATION_INFORMATION_SETTED : String = "applicationInformationSetted";
		
		public static const GET_PAGES : String = "getPages";
		public static const PAGES_GETTED : String = "pagesGetted";

		public static const CREATE_PAGE : String = "createPage";
		public static const PAGE_CREATED : String = "pageCreated";
		
		public static const DELETE_PAGE : String = "deletePage";
		public static const PAGE_DELETED : String = "pageDeleted";

//		pages
		public static const GET_PAGE_ATTRIBUTES : String = "getPageAttributes";
		public static const PAGE_ATTRIBUTES_GETTED : String = "pageAttributesGetted";
		
		public static const SET_PAGE_ATTRIBUTES : String = "setPageAttributes";
		public static const PAGE_ATTRIBUTES_SETTED : String = "pageAttributesSetted";

		public static const SET_PAGE_NAME : String = "setPageName";
		public static const PAGE_NAME_SETTED : String = "pageNameSetted";
//		resources
		public static const GET_RESOURCE : String = "getResource";

//		other
		public static const DELIMITER : String = "/";
		public static const STATES : String = "states";
		
//		public static const SELECTED_APPLICATION : String = "selectedApplication";
//		public static const SELECTED_TREE_ELEMENT : String = "selectedTreeElement";
		public static const SELECTED_TREE_LEVEL : String = "selectedTreeLevel";
		
		public static const CREATE_PAGE_REQUEST : String = "createPageRequest";
		public static const DELETE_PAGE_REQUEST : String = "deletePageRequest";
//		public static const CREATE_LINKAGE_REQUEST : String = "createLinkageRequest";

		public static const OPEN_CREATE_PAGE_WINDOW_REQUEST : String = "openCreatePageWindowRequest";
//		public static const AUTO_SPACING_REQUEST : String = "autoSpacingRequest";
//		public static const EXPAND_ALL_REQUEST : String = "expandAllRequest";
//		public static const SHOW_SIGNATURE_REQUEST : String = "showSignatureRequest";
		public static const SAVE_REQUEST : String = "saveRequest";
		public static const UNDO_REQUEST : String = "undoRequest";
		
		public static const TREE_ELEMENT_CREATED : String = "treeElementCreated";
		public static const TREE_ELEMENT_REMOVED : String = "treeElementRemoved";
		
		public static const CREATE_LINKAGE : String = "createLinkage";
		
		public static const LINKAGE_CREATED : String = "linkageCreated";
		public static const LINKAGE_REMOVED : String = "linkageRemoved";
		
//		public static const TREE_ELEMENT_SELECTION : String = "treeElementSelection";
		
//		public static const SELECTED_TREE_ELEMENT_CHANGED : String = "selectedTreeElementChanged";

		public static const OPEN_RESOURCE_SELECTOR_REQUEST : String = "openResourceSelectorRequest";
		
		public static const TREE_ELEMENTS_CHANGED : String = "treeElementsChanged";
		public static const TREE_ELEMENT_ADD : String = "treeElementAdd";
		
		public static const LINKAGES_CHANGED : String = "linkagesChanged";		
		
		public static const CREATE_PAGE_WINDOW_CREATED : String = "createPageWindowCreated";

		public static const OPEN_WINDOW : String = "openWidow";
		public static const CLOSE_WINDOW : String = "closeWidow";

		public static const GET_TREE_LEVELS : String = "getTreeLevels";
		public static const TREE_LEVELS_GETTED : String = "treeLevelsGetted";

		public static const SELECTED_TREE_LEVEL_CHANGE_REQUEST : String = "selectedTreeLevelChangeRequest";
		public static const SELECTED_TREE_LEVEL_CHANGED : String = "selectedTreeLevelChanged";

		public static const PAGE_TYPE_ITEM_RENDERER_CREATED : String = "pageTypeItemRendererCreated";
		
		public static const EXPAND_ALL_TREE_ELEMENTS : String = "expandAllTreeElements";
		public static const COLLAPSE_ALL_TREE_ELEMENTS : String = "collapseAllTreeElements";
		
		public static const SHOW_SIGNATURE : String = "showSignature";
		public static const HIDE_SIGNATURE : String = "hideSignature";
		
		public static const SEND_TO_LOG : String = "sendToLog";

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

		override protected function initializeController() : void
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
			registerCommand( TREE_ELEMENT_REMOVED, TreeElementRemovedCommand );
			
			registerCommand( LINKAGE_CREATED, LinkageCreatedCommand );
			registerCommand( LINKAGE_REMOVED, LinkageRemovedCommand );

			registerCommand( BODY_CREATED, BodyCreatedCommand );
			registerCommand( OPEN_CREATE_PAGE_WINDOW_REQUEST, OpenCreatePageWindowRequestCommand );

			registerCommand( PAGES_GETTED, PagesGettedCommand );
			registerCommand( APPLICATION_STRUCTURE_GETTED, ApplicationStructureGettedCommand );
			
			registerCommand( GET_TREE_LEVELS, GetTreeLevelsCommand );

			registerCommand( PAGE_TYPE_ITEM_RENDERER_CREATED, PageTypeItemRendererCreatedCommand );

			registerCommand( CREATE_PAGE_REQUEST, CreatePageRequestCommand );
			registerCommand( DELETE_PAGE_REQUEST, DeletePageRequestCommand );
			
			registerCommand( SAVE_REQUEST, SaveRequestCommand );
			registerCommand( UNDO_REQUEST, UndoRequestCommand );
			
			registerCommand( PAGE_CREATED, PageCreatedCommand );
			registerCommand( PAGE_DELETED, PageDeletedCommand );
			
//			registerCommand( EXPAND_ALL_REQUEST, ExpandAllRequestCommand );

//			registerCommand( LINKAGES_CHANGED, LinkagesChangedCommand );
			
			registerCommand( SELECTED_TREE_LEVEL_CHANGE_REQUEST, SelectedTreeLevelChangeRequestCommand );
			registerCommand( SELECTED_TREE_ELEMENT_CHANGE_REQUEST, SelectedTreeElementChangeRequestCommand );
			
			registerCommand( OPEN_RESOURCE_SELECTOR_REQUEST, OpenResourceSelectorRequestCommand );
			
			registerCommand( BODY_STOP, BodyStopCommand );
			registerCommand( TEAR_DOWN, TearDownCommand );
		}
	}
}