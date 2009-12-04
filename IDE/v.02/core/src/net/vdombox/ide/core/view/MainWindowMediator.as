package net.vdombox.ide.core.view
{
	import flash.events.MouseEvent;

	import mx.collections.ArrayList;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.LocalesProxy;
	import net.vdombox.ide.core.model.ModulesProxy;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	import net.vdombox.ide.core.model.vo.ModulesCategoryVO;
	import net.vdombox.ide.core.view.components.MainWindow;
	import net.vdombox.ide.core.view.components.SettingsWindow;
	import net.vdombox.utils.WindowManager;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	import spark.components.ButtonBar;
	import spark.components.Group;
	import spark.events.IndexChangeEvent;

	[ResourceBundle( "ApplicationManagment" )]
	public class MainWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "MainScreenMediator";

		public function MainWindowMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var currentModuleCategory : ModulesCategoryVO;

		private var loadedModules : Object;

//		private var localeProxy : LocaleProxy;

		private var modulesList : Array;

		private var modulesOrder : Array;

		private var modulesProxy : ModulesProxy;

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var windowManager : WindowManager = WindowManager.getInstance();

		private var selectedModuleID : String = "";

		override public function handleNotification( note : INotification ) : void
		{
			switch ( note.getName())
			{
				case ApplicationFacade.SHOW_MODULE_TOOLSET:
				{
					toolsetBar.addElement( note.getBody() as IVisualElement );
					break;
				}

				case ApplicationFacade.SHOW_MODULE_BODY:
				{
					mainWindow.addElement( note.getBody() as IVisualElement );
					break;
				}

				case ApplicationFacade.CHANGE_SELECTED_MODULE:
				{
					var newSelectedModuleID : String = note.getBody() as String;
					selectModule( newSelectedModuleID );
					break;
				}
			}
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.SHOW_MODULE_TOOLSET );
			interests.push( ApplicationFacade.SHOW_MODULE_BODY );
			interests.push( ApplicationFacade.CHANGE_SELECTED_MODULE );

			return interests;
		}

		override public function onRegister() : void
		{
			modulesProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
//			localeProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;

//			loadedModules = {};
//			modulesOrder = [];

			addEventListeners();
		}

		override public function onRemove() : void
		{
			removeEventListeners();
		}

		public function openWindow() : void
		{
			windowManager.addWindow( mainWindow );
		}

		public function closeWindow() : void
		{
			windowManager.removeWindow( mainWindow );
		}

		private function removeEventListeners() : void
		{
			mainWindow.removeEventListener( FlexEvent.CREATION_COMPLETE, mainWindow_creationCompleteHandler );
		}

		private function addEventListeners() : void
		{
			mainWindow.addEventListener( FlexEvent.CREATION_COMPLETE, mainWindow_creationCompleteHandler );
		}

		private function get mainWindow() : MainWindow
		{
			return viewComponent as MainWindow;
		}

		private function get toolsetBar() : Group
		{
			return mainWindow.toolsetBar;
		}

		private function cleanup() : void
		{
			var moduleForUnload : ModuleVO;

			for ( var i : int = 0; i < modulesOrder.length; i++ )
			{
				moduleForUnload = modulesOrder[ i ];

//				sendNotification( ApplicationFacade.REMOVE_MODULE, moduleForUnload );
			}

			toolsetBar.removeAllElements();
			mainWindow.removeAllElements();
		}

		private function getModule() : void
		{
			if ( modulesList.length > 0 )
			{
				var module : ModuleVO = modulesList.shift();
//				sendNotification( ApplicationFacade.LOAD_MODULE, module );
				return;
			}

			placeToolsets();
			selectModule();

		}

		private function mainWindow_creationCompleteHandler( event : FlexEvent ) : void
		{
			var modulesCategories : Array = modulesProxy.categories;
			var tabBar : ButtonBar = mainWindow.tabBar;

			tabBar.addEventListener( IndexChangeEvent.CHANGE, tabBar_indexChangeEvent );
			mainWindow.settingsButton.addEventListener( MouseEvent.CLICK, settingsButton_clickHandler );


			tabBar.labelField = "name";
			tabBar.dataProvider = new ArrayList( modulesCategories );
			tabBar.selectedIndex = 0;

			showModulesByCategory( modulesCategories[ 0 ] as ModulesCategoryVO );
		}

		private function placeToolsets() : void
		{
			toolsetBar.removeAllElements();

			if ( loadedModules.length == 0 )
				return;

			for each ( var item : ModuleVO in modulesOrder )
			{
				item.module.getToolset();
			}

			return;
		}

		private function selectModule( moduleID : String = "" ) : void
		{
			mainWindow.removeAllElements();
			var moduleVO : ModuleVO;
			if ( moduleID == "" )
			{
				moduleVO = modulesOrder[ 0 ] as ModuleVO;

				moduleID = ModuleVO( modulesOrder[ 0 ]).moduleID;
				moduleVO.module.getBody();
			}
			else
			{
				moduleVO = loadedModules[ moduleID ] as ModuleVO;
				moduleVO.module.getBody();
			}

			selectedModuleID = moduleID;
			sendNotification( ApplicationFacade.SELECTED_MODULE_CHANGED, selectedModuleID );
		}

		private function showModulesByCategory( categoryVO : ModulesCategoryVO ) : void
		{
			cleanup();

			modulesList = modulesProxy.getModulesListByCategory( categoryVO );

			currentModuleCategory = categoryVO;

			loadedModules = {};
			modulesOrder = [];

			getModule();
		}

		private function tabBar_indexChangeEvent( event : IndexChangeEvent ) : void
		{
			var categoryVO : ModulesCategoryVO = event.target.selectedItem as ModulesCategoryVO;

			showModulesByCategory( categoryVO );
		}

		private function settingsButton_clickHandler( event : MouseEvent ) : void
		{
			var settingsWindow : SettingsWindow = new SettingsWindow();
			facade.registerMediator( new SettingsWindowMediator( settingsWindow ));

			windowManager.addWindow( settingsWindow, mainWindow, true );
		}
	}
}