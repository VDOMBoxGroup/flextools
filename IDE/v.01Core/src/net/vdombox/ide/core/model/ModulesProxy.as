package net.vdombox.ide.core.model
{
	import mx.events.ModuleEvent;
	import mx.modules.IModuleInfo;
	import mx.modules.ModuleManager;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	import net.vdombox.ide.core.model.vo.ModulesCategoryVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	
	[ResourceBundle( "Modules" )]
	
	public class ModulesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ModulesProxy";

		private static const MODULES_DIR : String = "app:/modules/";

		private static const MODULES_XML : XML = 
			<modules>
				<category name="applicationManagment">
					<module name="ApplicationsManagment" path="app:/net/vdombox/ide/modules/ApplicationsManagment.swf"/>
					<module name="ApplicationsSearch" path="app:/net/vdombox/ide/modules/ApplicationsSearch.swf"/>
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
		private var _loadedModules : Object;

		private var moduleInfo : IModuleInfo;

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		public function get categories() : Array
		{		
			return _categories.slice();
		}

		public function getModulesList( categoryName : String ) : Array
		{
			if( _modulesListByCategory.hasOwnProperty( categoryName ) )
				return _modulesListByCategory[ categoryName ].slice() as Array ;
			else
				return null;
		}
		
		public function getModuleByID( moduleID : String ) : ModuleVO
		{
			return _loadedModules[ moduleID ] as ModuleVO;
		}
		
		public function loadModule( moduleVO : ModuleVO ) : void
		{
			moduleInfo = ModuleManager.getModule( moduleVO.path );
			moduleInfo.data = moduleVO;
			
			moduleInfo.addEventListener( ModuleEvent.READY, moduleReadyHandler );
			moduleInfo.load();
		}

		private function init() : void
		{
			_categories = [];
			_modulesListByCategory = {};
			
			var categoryName : String;
			var categoryLocalizedName : String;
			
			var modulePath : String;
			
			var moduleList : Array;
			
			for each ( var category : XML in MODULES_XML.* ) //TODO Добавить проверку наличия локализованного имени и т.д.
			{
				categoryName = category.@name;
				categoryLocalizedName = resourceManager.getString( "Modules", categoryName );
				
				moduleList = [];
				
				for each ( var module : XML in category.* )
				{
					modulePath = module.@path;
					moduleList.push( new ModuleVO( categoryName, modulePath ) ); 
				}
				
				_categories.push( new ModulesCategoryVO( categoryName, categoryLocalizedName ) );
				_modulesListByCategory[ categoryName ] = moduleList;
			}
		}

		private function moduleReadyHandler( event : ModuleEvent ) : void
		{
			var moduleVO : ModuleVO = event.module.data as ModuleVO;
			var module : VIModule = event.module.factory.create() as VIModule;
			moduleVO.setBody( module );
			_loadedModules[ moduleVO.moduleID ] = moduleVO;
			sendNotification( ApplicationFacade.MODULE_LOADED, moduleVO );
		}
	}
}