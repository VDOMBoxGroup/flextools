package net.vdombox.ide.core.model
{
	import mx.events.ModuleEvent;
	import mx.modules.IModuleInfo;
	import mx.modules.ModuleManager;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectUtil;
	
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.core.model.vo.ModulesCategoryVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	[ResourceBundle( "Modules" )]
	
	public class ModulesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ModulesProxy";

		public static const MODULE_LOADED : String = "Module Loaded";

		private static const MODULES_DIR : String = "app:/modules/";

		private static const MODULES_XML : XML = 
			<modules>
				<category name="applicationManagment">
					<module name="ApplicationsManagment" path="app:/net/vdombox/ide/modules/ApplicationsManagment.swf"/>
				</category>
				<category name="Editor">
					<module name="Edition" path="app:/net/vdombox/ide/modules/Edition.swf"/>
				</category>
			</modules>

		public function ModulesProxy( data : Object = null )
		{
			super( NAME, data );
			init();
		}

		private var _categories : Array;
		private var _modulesListByCategory : Object;

		private var moduleInfo : IModuleInfo;

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		public function get categories() : Array
		{
			return _categories;
		}

		public function getModulesList( categoryName : String ) : Array
		{
			if( _modulesListByCategory.hasOwnProperty( categoryName ) )
				return ObjectUtil.copy( _modulesListByCategory[ categoryName ] ) as Array;
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
			_categories = [];
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
				
				moduleList = [];
				
				for each ( var module : XML in category.* )
				{
					moduleName = module.@name;
					moduleList.push({ name : moduleName, localizedName : "two" }); 
				}
				
				_categories.push( new ModulesCategoryVO( categoryName, categoryLocalizedName, moduleList ) );
				_modulesListByCategory[ categoryName ] = moduleList;
			}
		}

		private function moduleReadyHandler( event : ModuleEvent ) : void
		{
			var module : VIModule = event.module.factory.create() as VIModule;
			sendNotification( MODULE_LOADED, module );
		}
	}
}