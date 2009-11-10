package net.vdombox.ide.core.view
{
	import mx.collections.ArrayList;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.VIModule;
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

		private var localeProxy : LocaleProxy;

		private var modulesProxy : ModulesProxy;

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var moduleList : Array;
		
		private var currentModuleCategory : String;

		private var loadedModules : Array;


		override public function onRegister() : void
		{
			modulesProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
			localeProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;

			addEventListeners();
		}

		override public function listNotificationInterests() : Array
		{
			return [
				ApplicationFacade.MODULE_READY,
				ApplicationFacade.SHOW_TOOLSET
			];
		}

		override public function handleNotification( note : INotification ) : void
		{
			switch ( note.getName())
			{
				case ApplicationFacade.MODULE_READY:
				{
					var module : VIModule = note.getBody() as VIModule;
					loadedModules.push( module );
					getModule();
					break;
				}
				
				case ApplicationFacade.SHOW_TOOLSET:
				{
					toolsetBar.addElement( note.getBody() as IVisualElement );
				}
			}
		}

		private function get mainWindow() : MainWindow
		{
			return viewComponent as MainWindow;
		}
		
		private function get toolsetBar() : Group
		{
			return mainWindow.toolsetBar;
		}
		
		private function addEventListeners() : void
		{
			mainWindow.addEventListener( FlexEvent.CREATION_COMPLETE, mainWindow_creationCompleteHandler );
		}
		
		private function showModulesByCategory( categoryName : String ) : void
		{	
			toolsetBar.removeAllElements();
			
			moduleList = modulesProxy.getModulesList( categoryName );
			
			currentModuleCategory = categoryName;
			
			loadedModules = [];
			
			getModule();
		}
		
		private function getModule() : void
		{
			if ( moduleList.length > 0 )
			{
				var module : Object = moduleList.shift();
				sendNotification( ApplicationFacade.LOAD_MODULE, new ModuleVO( module.name, currentModuleCategory ) );
				return;
			}
			
			placeToolsets();
		}
		
		private function placeToolsets() : void
		{
			toolsetBar.removeAllElements();
			
			if( loadedModules.length == 0 )
				return;
			
			for each ( var item : VIModule in loadedModules )
			{
				item.getToolset();
			}
			
			return;
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

		private function tabBar_indexChangeEvent( event : IndexChangeEvent ) : void
		{
			var categoryName : String = event.target.selectedItem.name as String;
			
			showModulesByCategory( categoryName );
		}
	}
}