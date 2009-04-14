package net.vdombox.ide.view
{
	import mx.collections.XMLListCollection;
	import mx.events.FlexEvent;
	import mx.events.ItemClickEvent;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.model.LocaleProxy;
	import net.vdombox.ide.model.ModulesProxy;
	import net.vdombox.ide.view.components.MainScreen;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	[ResourceBundle( "ApplicationManagment" )]
	[ResourceBundle( "Modules" )]

	public class MainScreenMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "MainScreenMediator";

		public function MainScreenMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var modulesProxy : ModulesProxy;
		private var localeProxy : LocaleProxy;

		private var applicationsManagmentMediator : ApplicationsManagmentMediator;
		private var modulesManagmentMediator : ModulesManagmentMediator;

		override public function onRegister() : void
		{
			modulesProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
			localeProxy = facade.retrieveProxy( LocaleProxy.NAME ) as LocaleProxy;

			addEventListeners();
		}

		private function get mainScreen() : MainScreen
		{
			return viewComponent as MainScreen;
		}

		private function addEventListeners() : void
		{
			mainScreen.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			applicationsManagmentMediator = new ApplicationsManagmentMediator( mainScreen.applicationsManagment );
			facade.registerMediator( applicationsManagmentMediator );
			
			modulesManagmentMediator = new ModulesManagmentMediator( mainScreen.modulesManagment )
			facade.registerMediator( modulesManagmentMediator );

			mainScreen.mainTabBar.addEventListener( ItemClickEvent.ITEM_CLICK, mainTabBar_itemClickHandler )

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


			mainScreen.mainTabBar.iconField = null;

			mainScreen.mainTabBar.labelFunction = function( data : XML ) : String
			{
				return data.@label[ 0 ];
			};

			mainScreen.mainTabBar.dataProvider = tabs;
		}

		private function mainTabBar_itemClickHandler( event : ItemClickEvent ) : void
		{
			var categoryName : String = event.item.@name;
			
			if ( categoryName == "applicationManagment" )
			{
				mainScreen.componentsStack.selectedChild = mainScreen.applicationsManagment;
			}
			else
			{
				mainScreen.componentsStack.selectedChild = mainScreen.modulesManagment;
				modulesManagmentMediator.showModulesByCategory( categoryName );
			}
		}
	}
}