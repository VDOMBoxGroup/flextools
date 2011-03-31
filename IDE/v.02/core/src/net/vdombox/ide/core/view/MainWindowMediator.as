package net.vdombox.ide.core.view
{
	import flash.display.Screen;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	
	import mx.collections.ArrayList;
	import mx.core.IVisualElement;
	import mx.events.AIREvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.MainWindowEvent;
	import net.vdombox.ide.core.model.ModulesProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.SessionProxy;
	import net.vdombox.ide.core.model.StatesProxy;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	import net.vdombox.ide.core.model.vo.ModulesCategoryVO;
	import net.vdombox.ide.core.view.components.MainWindow;
	import net.vdombox.ide.core.view.components.SettingsWindow;
	import net.vdombox.ide.core.view.managers.PopUpWindowManager;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.ButtonBar;
	import spark.components.Group;
	import spark.events.IndexChangeEvent;
	import spark.skins.spark.ButtonSkin;

	public class MainWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "MainScreenMediator";

		public function MainWindowMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );			
		}
		
		private var currentModuleCategory : ModulesCategoryVO;

		private var modulesList : Array;

		private var modulesProxy : ModulesProxy;

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var windowManager : WindowManager = WindowManager.getInstance();

		private var selectedModuleID : String = "";

		public function get mainWindow() : MainWindow
		{
			return viewComponent as MainWindow;
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SHOW_MODULE_TOOLSET );
			interests.push( ApplicationFacade.SHOW_MODULE_BODY );
			interests.push( ApplicationFacade.CHANGE_SELECTED_MODULE );
			interests.push( StatesProxy.SELECTED_APPLICATION_CHANGED );
			
//			interests.push( ApplicationFacade.CLOSE_SETTINGS_WINDOW );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			switch ( notification.getName() )
			{
				case ApplicationFacade.SHOW_MODULE_TOOLSET:
				{
					toolsetBar.addElement( body.component as IVisualElement );
					break;
				}

				case ApplicationFacade.SHOW_MODULE_BODY:
				{
					mainWindow.addElement( body.component as IVisualElement );
					break;
				}

				case ApplicationFacade.CHANGE_SELECTED_MODULE:
				{
					var newSelectedModuleID : String = body as String;
					var moduleVO : ModuleVO = modulesProxy.getModuleByID( newSelectedModuleID );

					selectModule( moduleVO );
					break;
				}
					
				case StatesProxy.SELECTED_APPLICATION_CHANGED:
				{
					initTitle();
					break;
				}
				
//				
			}
		}

		override public function onRegister() : void
		{
			addHandlers();

			modulesProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		public function openWindow() : void
		{
			windowManager.addWindow( mainWindow );
			
//			init();
		}
		
		private function initUser():void
		{
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			mainWindow.username = serverProxy.authInfo.username;
		}
		
		private function initTitle():void
		{
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var title: String =  "";			
			
			title =  serverProxy.authInfo.hostname + "  -  VDOM IDE v.2.0.1.002";
			
			if (statesProxy.selectedApplication)
			{
				title = statesProxy.selectedApplication.name +"  @  "+ title;
				
			}
			mainWindow.title = title
		}

		public function closeWindow() : void
		{
			windowManager.removeWindow( mainWindow );
		}

		private function get toolsetBar() : Group
		{
			return mainWindow.toolsetBar;
		}

		private function addHandlers() : void
		{
			mainWindow.addEventListener( FlexEvent.CREATION_COMPLETE, mainWindow_creationCompleteHandler, false, 0, true );
			mainWindow.addEventListener( MainWindowEvent.LOGOUT, logoutHandler, false, 0, true );
			
		}

		private function removeHandlers() : void
		{
			mainWindow.removeEventListener( FlexEvent.CREATION_COMPLETE, mainWindow_creationCompleteHandler );
			mainWindow.removeEventListener( MainWindowEvent.LOGOUT, logoutHandler );
		}

		private function cleanup() : void
		{
			toolsetBar.removeAllElements();
			mainWindow.removeAllElements();
		}

		private function placeToolsets() : void
		{
			toolsetBar.removeAllElements();

			if ( modulesList.length == 0 )
				return;

			for ( var i : int = 0; i < modulesList.length; i++ )
			{
				var moduleVO : ModuleVO = modulesList[ i ];

				if ( moduleVO.module.hasToolset )
					moduleVO.module.getToolset();
			}
		}

		private function selectModule( moduleVO : ModuleVO = null ) : void
		{
			mainWindow.removeAllElements();
			
			for each(var modVO:ModuleVO in modulesList )
			{
				modVO.module.deSelect();
			}

			if ( !moduleVO )
			{
				moduleVO = modulesList[ 0 ] as ModuleVO;
				moduleVO.module.getBody();
			}
			else
			{
				moduleVO.module.getBody();
			}

			selectedModuleID = moduleVO.moduleID;
// todo: delete
			sendNotification( ApplicationFacade.SELECTED_MODULE_CHANGED, moduleVO );
		}

		private function showModulesByCategory( categoryVO : ModulesCategoryVO ) : void
		{
			cleanup();

			modulesList = modulesProxy.getModulesListByCategory( categoryVO );

			currentModuleCategory = categoryVO;

			if ( modulesList.length == 0 )
				return;

//			for ( var i : int = 0; i < modulesList.length; i++ )
//			{
//				sendNotification( ApplicationFacade.CONNECT_MODULE_TO_CORE, modulesList[ i ] );
//			}

			placeToolsets();
		}

		private function mainWindow_creationCompleteHandler( event : FlexEvent ) : void
		{
			
			var modulesCategories : Array = modulesProxy.categories;
			var tabBar : ButtonBar = mainWindow.tabBar;

			tabBar.addEventListener( IndexChangeEvent.CHANGE, tabBar_indexChangeEvent );
//			mainWindow.settingsButton.addEventListener( MouseEvent.CLICK, settingsButton_clickHandler );

			tabBar.labelField = "name";
			tabBar.dataProvider = new ArrayList( modulesCategories );
			tabBar.selectedIndex = 0;

			var categoryVO : ModulesCategoryVO = tabBar.selectedItem as ModulesCategoryVO;

			showModulesByCategory( categoryVO );
			selectModule();
			mainWindow.tabBar.callLater( mainWindow.tabBar.drawFocus, [ false ] );
			
			initUser();
			initTitle();
		}

		private function logoutHandler( event : MainWindowEvent ) : void
		{
			cleanup();
			sendNotification( ApplicationFacade.REQUEST_FOR_SIGNOUT );
		}
			
		private function tabBar_indexChangeEvent( event : IndexChangeEvent ) : void
		{
			var categoryVO : ModulesCategoryVO = event.target.selectedItem as ModulesCategoryVO;

			showModulesByCategory( categoryVO );
			selectModule();
			mainWindow.tabBar.callLater( mainWindow.tabBar.drawFocus, [ false ] );
		}

		private function settingsButton_clickHandler( event : MouseEvent ) : void
		{
			if ( facade.hasMediator( SettingsWindowMediator.NAME ) )
				facade.removeMediator( SettingsWindowMediator.NAME );

			var settingsWindow : SettingsWindow = new SettingsWindow();
			facade.registerMediator( new SettingsWindowMediator( settingsWindow ) );

			windowManager.addWindow( settingsWindow, mainWindow, true );
		}
	}
}