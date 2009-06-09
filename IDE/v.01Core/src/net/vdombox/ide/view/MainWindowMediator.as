package net.vdombox.ide.view
{
	import mx.collections.XMLListCollection;
	import mx.events.FlexEvent;
	import mx.events.ItemClickEvent;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.model.LocaleProxy;
	import net.vdombox.ide.model.ModulesProxy;
	import net.vdombox.ide.view.components.MainWindow;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	[ResourceBundle( "ApplicationManagment" )]
	[ResourceBundle( "Modules" )]

	public class MainWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "MainScreenMediator";

		public function MainWindowMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var modulesProxy : ModulesProxy;
		private var localeProxy : LocaleProxy;

		private var applicationsManagmentMediator : ApplicationsManagmentMediator;
		private var modulesManagmentMediator : ModulesManagmentMediator;

		private function get mainWindow() : MainWindow
		{
			return viewComponent as MainWindow;
		}

		override public function onRegister() : void
		{
			modulesProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
			localeProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;

			addEventListeners();
		}

		private function addEventListeners() : void
		{
			mainWindow.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			applicationsManagmentMediator = new ApplicationsManagmentMediator( mainWindow.applicationsManagment );
			facade.registerMediator( applicationsManagmentMediator );

			modulesManagmentMediator = new ModulesManagmentMediator( mainWindow.modulesManagment )
			facade.registerMediator( modulesManagmentMediator );

			mainWindow.mainTabBar.addEventListener( ItemClickEvent.ITEM_CLICK, mainTabBar_itemClickHandler )

			var tabs : XMLListCollection = new XMLListCollection();
			tabs.addItem(
				<category name="applicationManagment" label={resourceManager.getString( "ApplicationManagment",
																						"title" )}/>
				);

			var modulesCategories : XMLList = modulesProxy.categories;
			for each ( var category : XML in modulesCategories )
			{
				tabs.addItem(
					<category name={category.@name} label={resourceManager.getString( "Modules",
																					  category.@name )}/>
					);
			}


			mainWindow.mainTabBar.iconField = null;

			mainWindow.mainTabBar.labelFunction = function( data : XML ) : String
			{
				return data.@label[ 0 ];
			};

			mainWindow.mainTabBar.dataProvider = tabs;
			mainWindow.mainTabBar.selectedIndex = 0;
		}

		private function mainTabBar_itemClickHandler( event : ItemClickEvent ) : void
		{
			var categoryName : String = event.item.@name;

			if ( categoryName == "applicationManagment" )
			{
				mainWindow.componentsStack.selectedChild = mainWindow.applicationsManagment;
			}
			else
			{
				mainWindow.componentsStack.selectedChild = mainWindow.modulesManagment;
				modulesManagmentMediator.showModulesByCategory( categoryName );
			}
		}
	}
}