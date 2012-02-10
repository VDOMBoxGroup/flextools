package net.vdombox.ide.modules.tree
{
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.common.model.TypesProxy;
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
	import net.vdombox.ide.modules.tree.model.StatesProxy;
	
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

//		pipe messages
		public static const PROCESS_SERVER_PROXY_MESSAGE : String = "processServerProxyMessage";
		public static const PROCESS_RESOURCES_PROXY_MESSAGE : String = "processResourcesProxyMessage";
		public static const PROCESS_APPLICATION_PROXY_MESSAGE : String = "processApplicationProxyMessage";
		public static const PROCESS_PAGE_PROXY_MESSAGE : String = "processPageProxyMessage";
		
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
		
		public static const CREATE_PAGE_REQUEST : String = "createPageRequest";
		public static const DELETE_PAGE_REQUEST : String = "deletePageRequest";

		public static const OPEN_CREATE_PAGE_WINDOW_REQUEST : String = "openCreatePageWindowRequest";
		public static const SAVE_REQUEST : String = "saveRequest";
		public static const UNDO_REQUEST : String = "undoRequest";
		
		public static const TREE_ELEMENT_CREATED : String = "treeElementCreated";
		public static const TREE_ELEMENT_REMOVED : String = "treeElementRemoved";
		
		public static const CREATE_LINKAGE : String = "createLinkage";
		
		public static const LINKAGE_CREATED : String = "linkageCreated";
		public static const LINKAGE_REMOVED : String = "linkageRemoved";

		public static const OPEN_RESOURCE_SELECTOR_REQUEST : String = "openResourceSelectorRequest";
		
		public static const TREE_ELEMENTS_CHANGED : String = "treeElementsChanged";
		public static const TREE_ELEMENT_ADD : String = "treeElementAdd";
		
		public static const LINKAGES_CHANGED : String = "linkagesChanged";		
		
		public static const CREATE_PAGE_WINDOW_CREATED : String = "createPageWindowCreated";

		public static const OPEN_WINDOW : String = "openWidow";
		public static const CLOSE_WINDOW : String = "closeWidow";

		public static const GET_TREE_LEVELS : String = "getTreeLevels";
		public static const TREE_LEVELS_GETTED : String = "treeLevelsGetted";

		public static const PAGE_TYPE_ITEM_RENDERER_CREATED : String = "pageTypeItemRendererCreated";
		
		public static const EXPAND_ALL_TREE_ELEMENTS : String = "expandAllTreeElements";
		public static const COLLAPSE_ALL_TREE_ELEMENTS : String = "collapseAllTreeElements";
		
		public static const SHOW_SIGNATURE : String = "showSignature";
		public static const HIDE_SIGNATURE : String = "hideSignature";
		
		public static const SEND_TO_LOG : String = "sendToLog";
		
		
		public static const CHECK_SAVE_IN_WORKAREA : String = "checkSaveInWorkArea";
		public static const SAVE_IN_WORKAREA_CHECKED : String = "saveInWorkAreaChecked";
		
		public static const SAVE_CHANGED : String = "saveChanged";
		
		

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

			registerCommand( SettingsProxy.INITIALIZE_SETTINGS, InitializeSettingsCommand );
			registerCommand( SettingsProxy.GET_SETTINGS, GetSettingsCommand );
			registerCommand( SettingsProxy.SET_SETTINGS, SetSettingsCommand );
			registerCommand( SettingsProxy.SAVE_SETTINGS_TO_PROXY, SaveSettingsToProxy );

			registerCommand( TypesProxy.PROCESS_TYPES_PROXY_MESSAGE, ProcessTypesProxyMessageCommand );
			registerCommand( PROCESS_APPLICATION_PROXY_MESSAGE, ProcessApplicationProxyMessageCommand );
			registerCommand( PROCESS_PAGE_PROXY_MESSAGE, ProcessPageProxyMessageCommand );
			registerCommand( StatesProxy.PROCESS_STATES_PROXY_MESSAGE, ProcessStatesProxyMessageCommand );
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
			
			registerCommand( StatesProxy.SELECTED_TREE_LEVEL_CHANGE_REQUEST, SelectedTreeLevelChangeRequestCommand );
			registerCommand( StatesProxy.SELECTED_TREE_ELEMENT_CHANGE_REQUEST, SelectedTreeElementChangeRequestCommand );
			
			registerCommand( OPEN_RESOURCE_SELECTOR_REQUEST, OpenResourceSelectorRequestCommand );
			
			registerCommand( BODY_STOP, BodyStopCommand );
			registerCommand( TEAR_DOWN, TearDownCommand );
		}
	}
}