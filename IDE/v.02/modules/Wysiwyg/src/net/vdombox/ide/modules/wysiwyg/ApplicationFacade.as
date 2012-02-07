package net.vdombox.ide.modules.wysiwyg
{
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.modules.Wysiwyg;
	import net.vdombox.ide.modules.wysiwyg.controller.BodyCreatedCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.BodyStopCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.ChangeSelectedObjectRequestCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.ChangeSelectedPageRequestCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.CreateLineLinkingCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.CreateObjectRequestCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.CreatePageRequestCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.EditorCreatedCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.EditorRemovedCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.GetMultiLineCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.GetResourceRequestCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.GetSettingsCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.InitializeSettingsCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.ObjectVisibleCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.OpenCreatePageWindowRequestCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.OpenExternalEditorRequestCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.PageTypeItemRendererCreatedCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.RendererClickedCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.RendererCreatedCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.RendererRemovedCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.RendererTransformedCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.SaveSettingsToProxy;
	import net.vdombox.ide.modules.wysiwyg.controller.SetNewNameObjectCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.SetSettingsCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.SetToolTipCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.StartupCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.TearDownCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.WysiwygGettedCommand;
	import net.vdombox.ide.modules.wysiwyg.controller.XmlPresentationGettedCommand;
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

		public static const DELETE_OBJECT : String = "deleteObject";
		public static const OBJECT_DELETED : String = "objectDeleted";

		public static const RENDERER_CREATED : String = "rendererCreated";
		public static const RENDERER_REMOVED : String = "rendererRemoved";
		
		public static const RENDERER_CLICKED : String = "rendererClicked";
		
		public static const RENDERER_TRANSFORMED : String = "rendererTransformed";
		
//		public static const SELECT_ITEM_REQUEST : String = "selectItemRequest";

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
			
			registerCommand( BODY_STOP, BodyStopCommand );

			registerCommand( SettingsProxy.INITIALIZE_SETTINGS, InitializeSettingsCommand );
			registerCommand( SettingsProxy.GET_SETTINGS, GetSettingsCommand );
			registerCommand( SettingsProxy.SET_SETTINGS, SetSettingsCommand );
			registerCommand( SettingsProxy.SAVE_SETTINGS_TO_PROXY, SaveSettingsToProxy );

			registerCommand( TypesProxy.PROCESS_TYPES_PROXY_MESSAGE, ProcessTypesProxyMessageCommand );
			registerCommand( StatesProxy.PROCESS_STATES_PROXY_MESSAGE, ProcessStatesProxyMessageCommand );
			registerCommand( PROCESS_RESOURCES_PROXY_MESSAGE, ProcessResourcesProxyMessageCommand );
			registerCommand( PROCESS_APPLICATION_PROXY_MESSAGE, ProcessApplicationProxyMessageCommand );
			registerCommand( PROCESS_PAGE_PROXY_MESSAGE, ProcessPageProxyMessageCommand );
			registerCommand( PROCESS_OBJECT_PROXY_MESSAGE, ProcessObjectProxyMessageCommand );

			registerCommand( StatesProxy.CHANGE_SELECTED_PAGE_REQUEST, ChangeSelectedPageRequestCommand );
			registerCommand( StatesProxy.CHANGE_SELECTED_OBJECT_REQUEST, ChangeSelectedObjectRequestCommand );

			registerCommand( OPEN_EXTERNAL_EDITOR_REQUEST, OpenExternalEditorRequestCommand );

			registerCommand( RENDERER_CREATED, RendererCreatedCommand );
			registerCommand( RENDERER_REMOVED, RendererRemovedCommand );

			registerCommand( RENDERER_CLICKED, RendererClickedCommand );
			
			registerCommand( WYSIWYG_GETTED, WysiwygGettedCommand );
			registerCommand( XML_PRESENTATION_GETTED, XmlPresentationGettedCommand );
			
			registerCommand( RENDERER_TRANSFORMED, RendererTransformedCommand );
			registerCommand( SAVE_ATTRIBUTES_REQUEST, RendererTransformedCommand );
			registerCommand( OBJECT_VISIBLE, ObjectVisibleCommand );
//			registerCommand( SELECT_ITEM_REQUEST, SelectItemRequestCommand );

			registerCommand( GET_RESOURCE_REQUEST, GetResourceRequestCommand );
			registerCommand( CREATE_OBJECT_REQUEST, CreateObjectRequestCommand );
					
			registerCommand( EDITOR_CREATED, EditorCreatedCommand );
			registerCommand( EDITOR_REMOVED, EditorRemovedCommand );

			registerCommand( GET_MULTILINE_RESOURCES, GetMultiLineCommand );
			
			registerCommand( TEAR_DOWN, TearDownCommand );
			
			registerCommand( OBJECT_MOVED, CreateLineLinkingCommand );
			
			registerCommand( PAGE_STRUCTURE_GETTED, SetToolTipCommand );
			registerCommand( OBJECT_NAME_SETTED, SetNewNameObjectCommand );
			
			registerCommand( OPEN_CREATE_PAGE_WINDOW_REQUEST, OpenCreatePageWindowRequestCommand );
			registerCommand( PAGE_TYPE_ITEM_RENDERER_CREATED, PageTypeItemRendererCreatedCommand );
			
			registerCommand( CREATE_PAGE_REQUEST, CreatePageRequestCommand );
			
		}
	}
}