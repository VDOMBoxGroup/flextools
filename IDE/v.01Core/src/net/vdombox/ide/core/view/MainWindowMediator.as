package net.vdombox.ide.core.view
{
	import mx.collections.ArrayList;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.LocaleProxy;
	import net.vdombox.ide.core.model.ModulesProxy;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	import net.vdombox.ide.core.view.components.MainWindow;
	
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

		private var currentModuleCategory : String;

		private var loadedModules : Object;

		private var localeProxy : LocaleProxy;

		private var modulesList : Array;

		private var modulesOrder : Array;

		private var modulesProxy : ModulesProxy;

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var selectedModuleID : String = "";

		override public function handleNotification( note : INotification ) : void
		{
			switch ( note.getName())
			{
				case ApplicationFacade.MODULE_READY:
				{
					var moduleVO : ModuleVO = note.getBody() as ModuleVO;
					loadedModules[ moduleVO.moduleID ] = moduleVO;
					modulesOrder.push( moduleVO );
					getModule();
					break;
				}

				case ApplicationFacade.SHOW_TOOLSET:
				{
					toolsetBar.addElement( note.getBody() as IVisualElement );
					break;
				}

				case ApplicationFacade.SHOW_MAIN_CONTENT:
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
			return [ ApplicationFacade.MODULE_READY, ApplicationFacade.SHOW_TOOLSET, ApplicationFacade.SHOW_MAIN_CONTENT, ApplicationFacade.CHANGE_SELECTED_MODULE ];
		}

		override public function onRegister() : void
		{
			modulesProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
			localeProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;

			loadedModules = {};
			modulesOrder = [];

			addEventListeners();
		}

		private function addEventListeners() : void
		{
			mainWindow.addEventListener( FlexEvent.CREATION_COMPLETE, mainWindow_creationCompleteHandler );
		}

		private function cleanup() : void
		{
			var moduleForUnload : ModuleVO;

			for ( var i : int = 0; i < modulesOrder.length; i++ )
			{
				moduleForUnload = modulesOrder[ i ];

				sendNotification( ApplicationFacade.REMOVE_MODULE, moduleForUnload );
			}

			toolsetBar.removeAllElements();
			mainWindow.removeAllElements();
		}

		private function getModule() : void
		{
			if ( modulesList.length > 0 )
			{
				var module : ModuleVO = modulesList.shift();
				sendNotification( ApplicationFacade.LOAD_MODULE, module );
				return;
			}

			placeToolsets();
			selectModule();

		}

		private function get mainWindow() : MainWindow
		{
			return viewComponent as MainWindow;
		}

		private function mainWindow_creationCompleteHandler( event : FlexEvent ) : void
		{
			var modulesCategories : Array = modulesProxy.categories;
			var tabBar : ButtonBar = mainWindow.tabBar;

			tabBar.addEventListener( IndexChangeEvent.CHANGE, tabBar_indexChangeEvent );

			tabBar.labelField = "name";
			tabBar.dataProvider = new ArrayList( modulesCategories );
			tabBar.selectedIndex = 0;

			showModulesByCategory( modulesCategories[ 0 ].name );
		}

		private function placeToolsets() : void
		{
			toolsetBar.removeAllElements();

			if ( loadedModules.length == 0 )
				return;

			for each ( var item : ModuleVO in modulesOrder )
			{
				item.body.getToolset();
			}

			return;
		}

		private function selectModule( moduleID : String = "" ) : void
		{
			var moduleVO : ModuleVO;
			if ( moduleID == "" )
			{
				moduleVO = modulesOrder[ 0 ] as ModuleVO;

				moduleID = ModuleVO( modulesOrder[ 0 ]).moduleID;
				moduleVO.body.getMainContent();
			}
			else
			{
				moduleVO = loadedModules[ moduleID ] as ModuleVO;
				moduleVO.body.getMainContent();
			}

			selectedModuleID = moduleID;
			sendNotification( ApplicationFacade.SELECTED_MODULE_CHANGED, selectedModuleID );
		}

		private function showModulesByCategory( categoryName : String ) : void
		{
			cleanup();

			modulesList = modulesProxy.getModulesList( categoryName );

			currentModuleCategory = categoryName;

			loadedModules = {};
			modulesOrder = [];

			getModule();
		}

		private function tabBar_indexChangeEvent( event : IndexChangeEvent ) : void
		{
			var categoryName : String = event.target.selectedItem.name as String;

			showModulesByCategory( categoryName );
		}

		private function get toolsetBar() : Group
		{
			return mainWindow.toolsetBar;
		}
	}
}