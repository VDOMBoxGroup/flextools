package net.vdombox.ide.common.controller
{
	public class Notifications
	{
		
//////////////////////////////////////////////////WYSIWYG/////////////////////////////////////////		
		
		//		main
		public static const STARTUP : String = "startup";
		
		public static const CREATE_TOOLSET : String = "createToolset";
		public static const CREATE_SETTINGS_SCREEN : String = "createSettingsScreen";
		
		public static const CREATE_BODY  : String = "createBody";
		public static const BODY_CREATED : String = "bodyCreated";
		
		public static const BODY_START : String = "bodyStart";
		public static const BODY_STOP  : String = "bodyStop";
		
		public static const EXPORT_TOOLSET : String = "exportToolset";
		public static const EXPORT_SETTINGS_SCREEN : String = "exportSettingsScreen";
		public static const EXPORT_BODY : String = "exportBody";
		
		//		selection
		public static const CHECK_SAVE_IN_WORKAREA : String = "checkSaveInWorkArea";
		public static const SAVE_IN_WORKAREA_CHECKED : String = "saveInWorkAreaChecked";
		
		public static const SELECT_MODULE     : String = "selectModule";
		public static const MODULE_SELECTED   : String = "moduleSelected";
		public static const MODULE_DESELECTED : String = "moduleDeselected";
		
		public static const PIPES_READY : String = "pipesReady";
		
		//		tear down
		public static const TEAR_DOWN : String = "tearDown";
		
		//		pipe messages
		public static const PROCESS_SERVER_PROXY_MESSAGE : String = "processServerProxyMessage";
		public static const PROCESS_RESOURCES_PROXY_MESSAGE : String = "processResourcesProxyMessage";
		public static const PROCESS_APPLICATION_PROXY_MESSAGE : String = "processApplicationProxyMessage";
		public static const PROCESS_PAGE_PROXY_MESSAGE : String = "processPageProxyMessage";
		public static const PROCESS_OBJECT_PROXY_MESSAGE : String = "processObjectProxyMessage";
		
		//		resources
		public static const GET_RESOURCES : String = "getResources";
		public static const RESOURCES_GETTED : String = "resourcesGetted";
		
		public static const SET_RESOURCE 	: String = "setResource";
		public static const RESOURCE_SETTED : String = "resourceSetted"; //not used because they do not need to show at once
		
		public static const DELETE_RESOURCE : String = "deleteResource";
		
		public static const LOAD_RESOURCE 	: String = "loadResource";
		public static const RESOURCE_LOADED	: String = "resourceLoaded"; //not used
		public static const MODIFY_RESOURCE : String = "modifyResource";
		
		//		icon
		public static const GET_ICON	: String = "getIcon";
		public static const ICON_GETTED : String = "iconGetted";
		
		//		pages
		public static const GET_PAGES : String = "getPages";
		public static const PAGES_GETTED : String = "pagesGetted";
		public static const GET_PAGE_SRUCTURE : String = "getPageStructure";
		public static const PAGE_STRUCTURE_GETTED : String = "pageStructureGetted";
		
		public static const GET_TOP_LEVEL_TYPES : String = "getTopLevelTypes";
		public static const TOP_LEVEL_TYPES_GETTED : String = "topLevelTypesGetted";
		
		public static const DELETE_PAGE : String = "deletePage";
		public static const PAGE_DELETED : String = "pageDeleted";
		
		public static const CREATE_PAGE_REQUEST : String = "createPageRequest";
		public static const CREATE_PAGE : String = "createPage";
		public static const PAGE_CREATED : String = "pageCreated";
		
		//		objects
		public static const GET_OBJECT : String = "getObject";
		public static const OBJECT_GETTED : String = "objectGetted";
		public static const GET_OBJECTS : String = "getObjects";
		public static const OBJECTS_GETTED : String = "objectsGetted";
		public static const OBJECT_MOVED : String = "objectMoved";
		public static const OBJECT_VISIBLE : String = "objectVisible";
		
		//		attributes
		public static const GET_PAGE_ATTRIBUTES : String = "getPageAttributes";
		public static const PAGE_ATTRIBUTES_GETTED : String = "pageAttributesGetted";
		
		public static const GET_OBJECT_ATTRIBUTES : String = "getObjectAttributes";
		public static const OBJECT_ATTRIBUTES_GETTED : String = "objectAttributesGetted";
		public static const GET_MULTILINE_RESOURCES : String = "getMultiLineResources";
		
		//		objectsTree notifications
		public static const OPEN_PAGE_REQUEST : String = "openPageRequest";
		public static const OPEN_OBJECT_REQUEST : String = "openObjectRequest";
		
		//		editors
		public static const EDITOR_CREATED : String = "editorCreated";
		public static const EDITOR_REMOVED : String = "editorRemoved";
		
		//		other
		public static const SET_OBJECT_NAME : String = "setObjectName";
		public static const DELIMITER : String = "/";
		public static const STATES : String = "states";
		
		public static const GET_WYSIWYG : String = "getWYSIWYG";
		public static const WYSIWYG_GETTED : String = "WYSIWYGGetted";
		
		public static const GET_XML_PRESENTATION : String = "getXMLPresentation";
		public static const XML_PRESENTATION_GETTED : String = "XMLPresentationGetted";
		
		public static const SET_XML_PRESENTATION : String = "setXMLPresentation";
		public static const XML_PRESENTATION_SETTED : String = "XMLPresentationSetted";
		
		public static const RENDER_DATA_CHANGED : String = "renderDataChanged";
		
		public static const CREATE_OBJECT_REQUEST : String = "createObjectRequest";
		public static const CREATE_OBJECT : String = "createObject";
		public static const OBJECT_CREATED : String = "objectCreated";
		
		public static const DELETE_OBJECT_REQUEST : String = "deleteObjectRequest";
		public static const DELETE_OBJECT : String = "deleteObject";
		public static const OBJECT_DELETED : String = "objectDeleted";
		
		public static const RENDERER_CREATED : String = "rendererCreated";
		public static const RENDERER_REMOVED : String = "rendererRemoved";
		public static const ALL_RENDERERS_REMOVED : String = "allRenderersRemoved";
		
		public static const RENDERER_CLICKED : String = "rendererClicked";
		
		public static const RENDERER_TRANSFORMED : String = "rendererTransformed";
		
		public static const GET_RESOURCE_REQUEST : String = "getResourceRequest";
		public static const OPEN_RESOURCE_SELECTOR_REQUEST : String = "openResourceSelectorRequest";
		public static const OPEN_EXTERNAL_EDITOR_REQUEST : String = "openExternalEditorRequest";
		public static const SAVE_ATTRIBUTES_REQUEST : String = "saveAttributesRequest";
		
		public static const CURRENT_ATTRIBUTE_CHANGED : String = "currentAttributeChanged";
		
		public static const UPDATE_ATTRIBUTES : String = "updateAttributes";
		public static const ATTRIBUTES_UPDATED : String = "attributesUpdated";
		
		public static const REMOTE_CALL_REQUEST : String = "remoteCallRequest";
		public static const REMOTE_CALL_RESPONSE : String = "remoteСallResponse";
		
		public static const PAGE_NAME_SETTED : String = "pageNameSetted";
		public static const OBJECT_NAME_SETTED : String = "objectNameSetted";
		
		public static const LINE_LIST_GETTED : String = "lineListGetted";
		
		public static const OPEN_CREATE_PAGE_WINDOW_REQUEST : String = "openCreatePageWindowRequest";
		public static const PAGE_TYPE_ITEM_RENDERER_CREATED : String = "pageTypeItemRendererCreated";
		
		
		// Copy
		public static const COPY_REQUEST : String = "copy";
		
		
		// Undo
		public static const UNDO : String = "undo";
		public static const REDO : String = "redo";
		
		// Error
		public static const ERROR_GETTED : String = "errorGetted";
		
		public static const WRITE_ERROR : String = "writeError";
		
		//multiObjects
		
		public static const MULTI_OBJECTS_POSITION_SAVING : String = "multiObjectsStartPositionSaving";
		public static const MULTI_OBJECTS_POSITION_SAVED : String = "multiObjectsStartPositionSaved";
		
		
//////////////////////////////////////////////////TREE/////////////////////////////////////////////
		
		
		//		application
		public static const GET_APPLICATION_STRUCTURE : String = "getApplicationStructure";
		public static const APPLICATION_STRUCTURE_GETTED : String = "applicationStructureGetted";
		
		public static const SET_APPLICATION_STRUCTURE : String = "setApplicationStructure";
		public static const APPLICATION_STRUCTURE_SETTED : String = "applicationStructureSetted";
		
		public static const SET_APPLICATION_INFORMATION : String = "setApplicationInformation";
		public static const APPLICATION_INFORMATION_SETTED : String = "applicationInformationSetted";
		
		
		//		pages
		
		public static const SET_PAGE_ATTRIBUTES : String = "setPageAttributes";
		public static const PAGE_ATTRIBUTES_SETTED : String = "pageAttributesSetted";
		
		public static const SET_PAGE_NAME : String = "setPageName";
		//		resources
		public static const GET_RESOURCE : String = "getResource";
		
		//		other
		
		public static const DELETE_PAGE_REQUEST : String = "deletePageRequest";
		
		public static const SAVE_REQUEST : String = "saveRequest";
		public static const UNDO_REQUEST : String = "undoRequest";
		
		public static const TREE_ELEMENT_CREATED : String = "treeElementCreated";
		public static const TREE_ELEMENT_REMOVED : String = "treeElementRemoved";
		
		public static const CREATE_LINKAGE : String = "createLinkage";
		
		public static const LINKAGE_CREATED : String = "linkageCreated";
		public static const LINKAGE_REMOVED : String = "linkageRemoved";
		
		public static const TREE_ELEMENTS_CHANGED : String = "treeElementsChanged";
		public static const TREE_ELEMENT_ADD : String = "treeElementAdd";
		
		public static const LINKAGES_CHANGED : String = "linkagesChanged";	
		public static const LINKAGES_INDEX_UPDATE : String = "linkagesIndexUpdate";	
		
		public static const CREATE_PAGE_WINDOW_CREATED : String = "createPageWindowCreated";
		
		public static const GET_TREE_LEVELS : String = "getTreeLevels";
		public static const TREE_LEVELS_GETTED : String = "treeLevelsGetted";
		
		public static const EXPAND_ALL_TREE_ELEMENTS : String = "expandAllTreeElements";
		public static const COLLAPSE_ALL_TREE_ELEMENTS : String = "collapseAllTreeElements";
		
		public static const SHOW_SIGNATURE : String = "showSignature";
		public static const HIDE_SIGNATURE : String = "hideSignature";
		
		public static const CHECK_SIGNATURE : String = "checkSignature";
		public static const SIGNATURE_CHECKED : String = "signatureChecked";
		
		public static const SEND_TO_LOG : String = "sendToLog";
		
		public static const SAVE_CHANGED : String = "saveChanged";
		
		
////////////////////////////////////////////////////Scripts/////////////////////////////////
		
		public static const GET_STRUCTURE : String = "getStructure";
		public static const STRUCTURE_GETTED : String = "structureGetted";
		public static const STRUCTURE_FOR_FIND_GETTED : String = "structureForFindGetted";
		public static const STRUCTURE_GETTED_REQUEST : String = "structureGettedRequest";
		
		public static const GET_GLOBAL_ACTIONS : String = "getGlobalActions";
		public static const GLOBAL_ACTIONS_GETTED : String = "globalActionsGetted";
		public static const GLOBAL_ACTIONS_GETTED_FOR_FIND : String = "globalActionsGettedForFind";
		
		public static const GET_SCRIPT_REQUEST : String = "getScriptRequest";
		
		public static const GET_SERVER_ACTIONS_REQUEST : String = "getServerActionsRequest";
		public static const GET_SERVER_ACTIONS : String = "getServerActions";
		public static const SERVER_ACTIONS_GETTED : String = "serverActionsGetted";
		
		public static const GET_ALL_SERVER_ACTIONS : String = "getAllServerActions";
		public static const ALL_SERVER_ACTIONS_GETTED : String = "allServerActionsGetted";
		
		public static const SET_SERVER_ACTIONS : String = "setServerActions";
		public static const SERVER_ACTIONS_SETTED : String = "serverActionsSetted";
		
		public static const SET_SERVER_ACTION : String = "setServerAction";
		
		public static const GET_SERVER_ACTION : String = "getServerAction";
		public static const SERVER_ACTION_GETTED : String = "serverActionGetted";
		
		public static const CREATE_SERVER_ACTION : String = "createServerAction";
		public static const SERVER_ACTION_CREATED : String = "serverActionCrteated";
		
		public static const DELETE_SERVER_ACTION : String = "deleteServerAction";
		public static const SERVER_ACTION_DELETED : String = "serverActionDeleted";
		
		public static const RENAME_SERVER_ACTION : String = "renameServerAction";
		public static const SERVER_ACTION_RENAMED : String = "serverActionRenamed";
		
		public static const GET_LIBRARY : String = "getLibrary";
		public static const LIBRARY_GETTED : String = "libraryGetted";
		
		public static const GET_LIBRARIES : String = "getLibraries";
		public static const LIBRARIES_GETTED : String = "librariesGetted";
		public static const LIBRARIES_GETTED_FOR_FIND : String = "librariesGettedForFind";
		
		public static const SCRIPT_CHECKED: String = "scriptChecked";
		
		public static const GET_GLOBAL_ACTION : String = "getGlobalAction";
		public static const GLOBAL_ACTION_GETTED : String = "globalActionGetted";
		
		public static const SELECTED_TAB_CHANGED : String = "selectedTabChanged";
		
		public static const DELETE_TAB : String = "deleteTab";
		public static const DELETE_TAB_BY_ACTIONVO : String = "deleteTabByActionVO";
		
		public static const ACTION : String = "action";
		public static const LIBRARY : String = "library";
		
		public static const CREATE_SCRIPT_REQUEST : String = "createScriptRequest";
		public static const SAVE_SCRIPT_REQUEST : String = "saveScriptRequest";
		
		public static const CREATE_LIBRARY : String = "createLibrary";
		public static const LIBRARY_CREATED : String = "libraryCreated";
		
		public static const SAVE_LIBRARY : String = "saveLibrary";
		public static const LIBRARY_SAVED : String = "librarySaved";
		
		public static const SAVE_GLOBAL_ACTION : String = "saveGlobalAction";
		public static const GLOBAL_ACTION_SAVED : String = "globalActionSaved";
		
		public static const DELETE_LIBRARY_REQUEST : String = "deleteLibraryRequest";
		
		public static const DELETE_LIBRARY : String = "deleteLibrary";
		public static const LIBRARY_DELETED : String = "libraryDeleted";
		
		public static const OPEN_ONLOAD_SCRIPT : String = "openOnloadScript";
		
		public static const CHANGE_SELECTED_SCRIPT : String = "changeSelectedScript";
		
		public static const OPEN_FIND_SCRIPT : String = "openFindScript";
		public static const OPEN_FIND_GLOBAL_SCRIPT : String = "openFindGlobalScript";
		public static const OPEN_RENAME_IN_SCRIPT : String = "openRenameInScript";
		
		public static const RENAME_IN_ACTION : String = "renameInAction";
		
		public static const GET_PAGES_STRUCTURE : String = "getPagesStructure";
		public static const PAGES_STRUCTURE_GETTED : String = "pagesStructureGetted";
		
		public static const HASH_LIBRARIES_CHANGE : String = "hashLibrariesChange";
		
		
		
//////////////////////////////////////////ResourceBrowser/////////////////////////////////////////////
		
		public static const UPLOAD_RESOURCE : String = "uploadResources";
		public static const RESOURCE_UPLOADED : String = "resourceUploaded";
		
		public static const DELETE_RESOURCE_REQUEST : String = "deleteResourceRequest";
		public static const RESOURCE_DELETED : String = "resourceDeleted";
		
		public static const ALL_TABS_DELETED : String = "allTabsDeleted";
		
		
///////////////////////////////////////////Preview////////////////////////////////////////////////////////////
		

///////////////////////////////////////////Events/////////////////////////////////////////////////////////////
		
		public static const GET_SERVER_ACTIONS_LIST 	: String = "getServerActionsList";
		public static const SERVER_ACTIONS_LIST_GETTED 	: String = "serverActionsListGetted";
		
		public static const GET_APPLICATION_EVENTS 		: String = "getApplicationEvents";
		public static const APPLICATION_EVENTS_GETTED 	: String = "applicationEventsGetted";
		
		public static const SET_APPLICATION_EVENTS 		: String = "setApplicationEvents";
		public static const APPLICATION_EVENTS_SETTED 	: String = "applicationEventsSetted";
		
		public static const GET_CHILDREN_ELEMENTS 	: String = "getChildrenElements";
		public static const CHILDREN_ELEMENTS_GETTED 	: String = "childrenElementsGetted";
		
		public static const SET_MESSAGE : String = "setMessage";
		
		public static const UNDO_REDO_GETTED : String = "undoRedoGetted";
		
		
		public static const GET_USED_ACTIONS : String = "getUsedActions";
		public static const SET_USED_ACTIONS : String = "setUsedActions";
		public static const SET_SELECTED_ACTION : String = "setSelectedAction";
		
		public static const CREATE_SELECTED_ACTION : String = "createSelectedAction";
		
///////////////////////////////////////////DataBases//////////////////////////////////////////////////////////////
		
		//		table panel
		public static const GET_DATA_BASES : String = "getDataBases";
		public static const DATA_BASES_GETTED : String = "dataBasesGetted";
		
		public static const GET_DATA_BASE_TABLES : String = "getDataBaseTables";
		public static const DATA_BASE_TABLES_GETTED : String = "dataBaseTablesGetted";
		
		public static const CHANGE_SELECTED_DATA_BASE_REQUEST : String = "changeSelectedDataBaseRequest";
		
		public static const GET_PAGE : String = "getPage";
		public static const PAGE_GETTED : String = "pageGetted";
		public static const GET_TABLE : String = "getTable";
		public static const TABLE_GETTED : String = "tableGetted";
		
		
		//		other		
		public static const TABLE_CREATED : String = "tableCreated";
		
		
		//		removecall
		public static const REMOTE_CALL_RESPONSE_ERROR : String = "removeCallResponseError";
		
		public static const COMMIT_DATA_STRUCTURE : String = "commitDataStructure";
		public static const COMMIT_STRUCTURE : String = "commitStructure";
		
		public static const GET_TABLE_STRUCTURE : String = "getTableStructure";
		public static const TABLE_STRUCTURE_GETTED : String = "tableStructureGetted";
	}
}