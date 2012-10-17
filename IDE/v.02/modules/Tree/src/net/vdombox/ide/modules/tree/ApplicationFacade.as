package net.vdombox.ide.modules.tree
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.SettingsProxy;
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.modules.Tree;
	import net.vdombox.ide.modules.tree.controller.BodyStopCommand;
	import net.vdombox.ide.modules.tree.controller.CreateSettingsScreenCommand;
	import net.vdombox.ide.modules.tree.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.tree.controller.GetSettingsCommand;
	import net.vdombox.ide.modules.tree.controller.GetTreeLevelsCommand;
	import net.vdombox.ide.modules.tree.controller.SaveRequestCommand;
	import net.vdombox.ide.modules.tree.controller.StartupCommand;
	import net.vdombox.ide.modules.tree.controller.TearDownCommand;
	import net.vdombox.ide.modules.tree.controller.UndoRequestCommand;
	import net.vdombox.ide.modules.tree.controller.body.ApplicationStructureGettedCommand;
	import net.vdombox.ide.modules.tree.controller.body.BodyCreatedCommand;
	import net.vdombox.ide.modules.tree.controller.body.CreateBodyCommand;
	import net.vdombox.ide.modules.tree.controller.body.CreatePageRequestCommand;
	import net.vdombox.ide.modules.tree.controller.body.DeletePageRequestCommand;
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
			sendNotification( Notifications.STARTUP, application );
		}

		override protected function initializeController() : void
		{
			super.initializeController();
			registerCommand( Notifications.STARTUP, StartupCommand );

			registerCommand( Notifications.CREATE_TOOLSET, CreateToolsetCommand );
			registerCommand( Notifications.CREATE_SETTINGS_SCREEN, CreateSettingsScreenCommand );
			registerCommand( Notifications.CREATE_BODY, CreateBodyCommand );

			registerCommand( SettingsProxy.INITIALIZE_SETTINGS, InitializeSettingsCommand );
			registerCommand( SettingsProxy.GET_SETTINGS, GetSettingsCommand );
			registerCommand( SettingsProxy.SET_SETTINGS, SetSettingsCommand );
			registerCommand( SettingsProxy.SAVE_SETTINGS_TO_PROXY, SaveSettingsToProxy );

			registerCommand( TypesProxy.PROCESS_TYPES_PROXY_MESSAGE, ProcessTypesProxyMessageCommand );
			registerCommand( Notifications.PROCESS_APPLICATION_PROXY_MESSAGE, ProcessApplicationProxyMessageCommand );
			registerCommand( Notifications.PROCESS_PAGE_PROXY_MESSAGE, ProcessPageProxyMessageCommand );
			registerCommand( StatesProxy.PROCESS_STATES_PROXY_MESSAGE, ProcessStatesProxyMessageCommand );
			registerCommand( Notifications.PROCESS_RESOURCES_PROXY_MESSAGE, ProcessResourcesProxyMessageCommand );

			registerCommand( Notifications.TREE_ELEMENT_CREATED, TreeElementCreatedCommand );
			registerCommand( Notifications.TREE_ELEMENT_REMOVED, TreeElementRemovedCommand );
			
			registerCommand( Notifications.LINKAGE_CREATED, LinkageCreatedCommand );
			registerCommand( Notifications.LINKAGE_REMOVED, LinkageRemovedCommand );

			registerCommand( Notifications.BODY_CREATED, BodyCreatedCommand );
			registerCommand( Notifications.OPEN_CREATE_PAGE_WINDOW_REQUEST, OpenCreatePageWindowRequestCommand );

			registerCommand( Notifications.PAGES_GETTED, PagesGettedCommand );
			registerCommand( Notifications.APPLICATION_STRUCTURE_GETTED, ApplicationStructureGettedCommand );
			
			registerCommand( Notifications.GET_TREE_LEVELS, GetTreeLevelsCommand );

			registerCommand( Notifications.PAGE_TYPE_ITEM_RENDERER_CREATED, PageTypeItemRendererCreatedCommand );

			registerCommand( Notifications.CREATE_PAGE_REQUEST, CreatePageRequestCommand );
			registerCommand( Notifications.DELETE_PAGE_REQUEST, DeletePageRequestCommand );
			
			registerCommand( Notifications.SAVE_REQUEST, SaveRequestCommand );
			registerCommand( Notifications.UNDO_REQUEST, UndoRequestCommand );
			
			registerCommand( Notifications.PAGE_CREATED, PageCreatedCommand );
			registerCommand( Notifications.PAGE_DELETED, PageDeletedCommand );
			
			registerCommand( StatesProxy.SELECTED_TREE_LEVEL_CHANGE_REQUEST, SelectedTreeLevelChangeRequestCommand );
			registerCommand( StatesProxy.SELECTED_TREE_ELEMENT_CHANGE_REQUEST, SelectedTreeElementChangeRequestCommand );
			
			registerCommand( Notifications.OPEN_RESOURCE_SELECTOR_REQUEST, OpenResourceSelectorRequestCommand );
			
			registerCommand( Notifications.BODY_STOP, BodyStopCommand );
			registerCommand( Notifications.TEAR_DOWN, TearDownCommand );
		}
	}
}