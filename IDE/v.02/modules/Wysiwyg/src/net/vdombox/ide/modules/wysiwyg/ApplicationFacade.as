package net.vdombox.ide.modules.wysiwyg
{
	import net.vdombox.ide.common.controller.Notifications;
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
			sendNotification( Notifications.STARTUP, application );
		}
		
		public static const MULTI_SELECT_START : String = "multiSelectStart";
		public static const MULTI_SELECT_END : String = "multiSelectEnd";

		override protected function initializeController() : void
		{
			super.initializeController();
			registerCommand( Notifications.STARTUP, StartupCommand );

			registerCommand( Notifications.CREATE_TOOLSET, CreateToolsetCommand );
			registerCommand( Notifications.CREATE_SETTINGS_SCREEN, CreateSettingsScreenCommand );

			registerCommand( Notifications.CREATE_BODY, CreateBodyCommand );
			registerCommand( Notifications.BODY_CREATED, BodyCreatedCommand );
			
			registerCommand( Notifications.BODY_STOP, BodyStopCommand );

			registerCommand( SettingsProxy.INITIALIZE_SETTINGS, InitializeSettingsCommand );
			registerCommand( SettingsProxy.GET_SETTINGS, GetSettingsCommand );
			registerCommand( SettingsProxy.SET_SETTINGS, SetSettingsCommand );
			registerCommand( SettingsProxy.SAVE_SETTINGS_TO_PROXY, SaveSettingsToProxy );

			registerCommand( TypesProxy.PROCESS_TYPES_PROXY_MESSAGE, ProcessTypesProxyMessageCommand );
			registerCommand( StatesProxy.PROCESS_STATES_PROXY_MESSAGE, ProcessStatesProxyMessageCommand );
			registerCommand( Notifications.PROCESS_RESOURCES_PROXY_MESSAGE, ProcessResourcesProxyMessageCommand );
			registerCommand( Notifications.PROCESS_APPLICATION_PROXY_MESSAGE, ProcessApplicationProxyMessageCommand );
			registerCommand( Notifications.PROCESS_PAGE_PROXY_MESSAGE, ProcessPageProxyMessageCommand );
			registerCommand( Notifications.PROCESS_OBJECT_PROXY_MESSAGE, ProcessObjectProxyMessageCommand );

			registerCommand( StatesProxy.CHANGE_SELECTED_PAGE_REQUEST, ChangeSelectedPageRequestCommand );
			registerCommand( StatesProxy.CHANGE_SELECTED_OBJECT_REQUEST, ChangeSelectedObjectRequestCommand );

			registerCommand( Notifications.OPEN_EXTERNAL_EDITOR_REQUEST, OpenExternalEditorRequestCommand );

			registerCommand( Notifications.RENDERER_CREATED, RendererCreatedCommand );
			registerCommand( Notifications.RENDERER_REMOVED, RendererRemovedCommand );

			registerCommand( Notifications.RENDERER_CLICKED, RendererClickedCommand );
			
			registerCommand( Notifications.WYSIWYG_GETTED, WysiwygGettedCommand );
			registerCommand( Notifications.XML_PRESENTATION_GETTED, XmlPresentationGettedCommand );
			
			registerCommand( Notifications.RENDERER_TRANSFORMED, RendererTransformedCommand );
			registerCommand( Notifications.SAVE_ATTRIBUTES_REQUEST, RendererTransformedCommand );
			registerCommand( Notifications.OBJECT_VISIBLE, ObjectVisibleCommand );
//			registerCommand( SELECT_ITEM_REQUEST, SelectItemRequestCommand );

			registerCommand( Notifications.GET_RESOURCE_REQUEST, GetResourceRequestCommand );
			registerCommand( Notifications.CREATE_OBJECT_REQUEST, CreateObjectRequestCommand );
					
			registerCommand( Notifications.EDITOR_CREATED, EditorCreatedCommand );
			registerCommand( Notifications.EDITOR_REMOVED, EditorRemovedCommand );

			registerCommand( Notifications.GET_MULTILINE_RESOURCES, GetMultiLineCommand );
			
			registerCommand( Notifications.TEAR_DOWN, TearDownCommand );
			
			registerCommand( Notifications.OBJECT_MOVED, CreateLineLinkingCommand );
			
			registerCommand( Notifications.PAGE_STRUCTURE_GETTED, SetToolTipCommand );
			registerCommand( Notifications.OBJECT_NAME_SETTED, SetNewNameObjectCommand );
			
			registerCommand( Notifications.OPEN_CREATE_PAGE_WINDOW_REQUEST, OpenCreatePageWindowRequestCommand );
			registerCommand( Notifications.PAGE_TYPE_ITEM_RENDERER_CREATED, PageTypeItemRendererCreatedCommand );
			
			registerCommand( Notifications.CREATE_PAGE_REQUEST, CreatePageRequestCommand );
			
		}
	}
}