package net.vdombox.ide.model
{
	import flash.display.DisplayObject;
	
	import mx.collections.ArrayCollection;
	import mx.events.ModuleEvent;
	import mx.modules.IModuleInfo;
	import mx.modules.ModuleManager;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	[ResourceBundle( "Modules" )]
	
	public class ModulesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ModulesProxy";

		public static const MODULE_LOADED : String = "Module Loaded";

		private static const MODULES_DIR : String = "app:/modules/";

		private static const MODULES_XML : XML = <modules>
				<category name="applicationManagment">
					<module name="FirstModule" path="app:/modules/First.swf"/>
					<module name="SecondModule" path="app:/modules/Second.swf"/>
				</category>
				<category name="editing">
					<module name="FirstModule" path="app:/modules/First.swf"/>
					<module name="SecondModule" path="app:/modules/Second.swf"/>
				</category>
				<category name="language">
					<module name="FirstModule" path="app:/modules/First.swf"/>
					<module name="SecondModule" path="app:/modules/Second.swf"/>
				</category>
				<category name="some">
				</category>
			</modules>

		public function ModulesProxy( data : Object = null )
		{
			super( NAME, data );
			init();
		}

		private var _categories : ArrayCollection;
		private var _modulesListByCategory : Object;

		private var moduleInfo : IModuleInfo;

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		public function get categories() : ArrayCollection
		{
			return _categories;
		}

		public function getModulesList( categoryName : String ) : Array
		{
			if( _modulesListByCategory.hasOwnProperty( categoryName ) )
				return _modulesListByCategory[ categoryName ];
			else
				return null;
		}

		public function loadModule( categoryName : String, moduleName : String ) : void
		{
			var module : XML = MODULES_XML.category.( @name == categoryName ).module.( @name == moduleName )[ 0 ];
			moduleInfo = ModuleManager.getModule( module.@path );
			moduleInfo.addEventListener( ModuleEvent.READY, moduleReadyHandler );
			moduleInfo.load();
		}

		private function init() : void
		{
			_categories = new ArrayCollection();
			_modulesListByCategory = {};
			
			var categoryName : String;
			var categoryLocalizedName : String;
			
			var moduleName : String;
			var moduleLocalizedName : String;
			
			var moduleList : Array;
			
			for each ( var category : XML in MODULES_XML.* ) //TODO Добавить проверку наличия локализованного имени и т.д.
			{
				categoryName = category.@name;
				categoryLocalizedName = resourceManager.getString( "Modules", categoryName );
				
				_categories.addItem({ name: categoryName, localizedName : categoryLocalizedName });
				
				moduleList = [];
				
				for each ( var module : XML in category.* )
				{
					moduleName = module.@name;
					moduleList.push({ name : moduleName, localizedName : "two" }); 
				}
				
				_modulesListByCategory[ categoryName ] = moduleList;
			}
		}

		private function moduleReadyHandler( event : ModuleEvent ) : void
		{
			var module : DisplayObject = event.module.factory.create() as DisplayObject;
			sendNotification( MODULE_LOADED, module );
		}
	}
}