package net.vdombox.ide.modules.wysiwyg
{
	import net.vdombox.ide.modules.Wysiwyg;
	import net.vdombox.ide.modules.wysiwyg.controller.BodyCreatedCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.ChangeSelectedPageRequestCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.CreateObjectRequestCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.GetResourceRequestCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.GetSettingsCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.InitializeSettingsCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.ItemCreatedCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.ItemRemovedCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.SelectItemRequestCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.ItemTransformedCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.ObjectSelectedRequestCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.OpenExternalEditorRequestCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.OpenResourceSelectorRequestCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.SaveAttributesRequestCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.SaveSettingsToProxy;
	import net.vdombox.ide.modules.wysiwyg.controller.SetSettingsCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.StartupCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.TearDownCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.messages.ProcessApplicationProxyMessageCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.messages.ProcessObjectProxyMessageCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.messages.ProcessPageProxyMessageCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.messages.ProcessResourcesProxyMessageCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.messages.ProcessStatesProxyMessageCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.messages.ProcessTypesProxyMessageCommand;

	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class ApplicationFacade extends Facade implements IFacade
	{
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

		public static const CHANGE_SELECTED_PAGE_REQUEST : String = "changeSelectedPageRequest";
		public static const SET_SELECTED_PAGE : String = "setSelectedPage";
		public static const SELECTED_PAGE_CHANGED : String = "selectedPageChanged";

		public static const CHANGE_SELECTED_OBJECT_REQUEST : String = "changeSelectedObjectRequest";
		public static const SET_SELECTED_OBJECT : String = "setSelectedObject";
		public static const SELECTED_OBJECT_CHANGED : String = "selectedObjectChanged";

//		pages
		public static const GET_PAGES : String = "getPages";
		public static const PAGES_GETTED : String = "pagesGetted";
		public static const GET_PAGE_SRUCTURE : String = "getPageStructure";
		public static const PAGE_STRUCTURE_GETTED : String = "pageStructureGetted";
		public static const SELECT_PAGE : String = "selectPage";
		public static const PAGE_SELECTED : String = "pageSelected";

//		objects
		public static const GET_OBJECT : String = "getObject";
		public static const OBJECT_GETTED : String = "objectGetted";
		public static const SELECT_OBJECT : String = "selectObject";
		public static const OBJECT_SELECTED : String = "objectSelected";
		public static const GET_OBJECTS : String = "getObjects";
		public static const OBJECTS_GETTED : String = "objectsGetted";

//		attributes
		public static const GET_PAGE_ATTRIBUTES : String = "getPageAttributes";
		public static const PAGE_ATTRIBUTES_GETTED : String = "pageAttributesGetted";

		public static const GET_OBJECT_ATTRIBUTES : String = "getObjectAttributes";
		public static const OBJECT_ATTRIBUTES_GETTED : String = "objectAttributesGetted";

//		other
		public static const DELIMITER : String = "/";
		public static const STATES : String = "states";

		public static const GET_PAGE_WYSIWYG : String = "getPageWYSIWYG";
		public static const GET_OBJECT_WYSIWYG : String = "getObjectWYSIWYG";

		public static const GET_XML_PRESENTATION : String = "getXMLPresentation";
		public static const XML_PRESENTATION_GETTED : String = "XMLPresentationGetted";
		
		public static const SET_XML_PRESENTATION : String = "setXMLPresentation";
		public static const XML_PRESENTATION_SETTED : String = "XMLPresentationSetted";
		
		public static const RENDER_DATA_CHANGED : String = "renderDataChanged";

		public static const CREATE_OBJECT_REQUEST : String = "createObjectRequest";
		public static const CREATE_OBJECT : String = "createObject";
		public static const OBJECT_CREATED : String = "objectCreated";

		public static const DELETE_OBJECT : String = "deleteObject";
		public static const OBJECT_DELETED : String = "objectDeleted";

		public static const ITEM_CREATED : String = "itemCreated";
		public static const ITEM_REMOVED : String = "itemRemoved";
		public static const ITEM_TRANSFORMED : String = "itemTransformed";
		public static const SELECT_ITEM_REQUEST : String = "selectItemRequest";
		public static const OBJECT_SELECTED_REQUEST : String = "objectSelectedRequest";

		public static const GET_RESOURCE_REQUEST : String = "getResourceRequest";
		public static const OPEN_RESOURCE_SELECTOR_REQUEST : String = "openResourceSelectorRequest";
		public static const OPEN_EXTERNAL_EDITOR_REQUEST : String = "openExternalEditorRequest";
		public static const SAVE_ATTRIBUTES_REQUEST : String = "saveAttributesRequest";
		
		public static const CURRENT_ATTRIBUTE_CHANGED : String = "currentAttributeChanged";

		public static const UPDATE_ATTRIBUTES : String = "updateAttributes";
		public static const ATTRIBUTES_UPDATED : String = "attributesUpdated";

		public static const REMOTE_CALL_REQUEST : String = "remoteCallRequest";
		public static const REMOTE_CALL_RESPONSE : String = "remoteСallResponse";

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

		override protected function initializeController() : void
		{
			super.initializeController();
			registerCommand( STARTUP, StartupCommand );

			registerCommand( CREATE_TOOLSET, CreateToolsetCommand );
			registerCommand( CREATE_SETTINGS_SCREEN, CreateSettingsScreenCommand );

			registerCommand( CREATE_BODY, CreateBodyCommand );
			registerCommand( BODY_CREATED, BodyCreatedCommand );

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

			registerCommand( CHANGE_SELECTED_PAGE_REQUEST, ChangeSelectedPageRequestCommand );

			registerCommand( OPEN_RESOURCE_SELECTOR_REQUEST, OpenResourceSelectorRequestCommand );
			registerCommand( OPEN_EXTERNAL_EDITOR_REQUEST, OpenExternalEditorRequestCommand );
			registerCommand( SAVE_ATTRIBUTES_REQUEST, SaveAttributesRequestCommand );

			registerCommand( ITEM_CREATED, ItemCreatedCommand );
			registerCommand( ITEM_REMOVED, ItemRemovedCommand );
			registerCommand( SELECT_ITEM_REQUEST, SelectItemRequestCommand );
			registerCommand( OBJECT_SELECTED_REQUEST, ObjectSelectedRequestCommand );

			registerCommand( GET_RESOURCE_REQUEST, GetResourceRequestCommand );
			registerCommand( CREATE_OBJECT_REQUEST, CreateObjectRequestCommand );

			registerCommand( ITEM_TRANSFORMED, ItemTransformedCommand );

			registerCommand( TEAR_DOWN, TearDownCommand );
		}
	}
}