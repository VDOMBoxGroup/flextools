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

		private static const MODULES_XML : XML = <modules>
				<category name="applicationManagment">
					<module name="ApplicationsManagment" path="app:/modules/ApplicationsManagment.swf"/>
				</category>
				<category name="Editor">
					<module name="Edition" path="app:/modules/Edition.swf"/>
				</category>
			</modules>

		public function ModulesProxy( data : Object = null )
		{
			super( NAME, data );
		}

		private var _categories : Array;

//		private var modulesListByCategory : Object;
//		private var _loadedModules : Object;
		private var modulesList : Array;

		private var modulesForLoadQue : Array;

		private var moduleInfo : IModuleInfo;

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		public function get categories() : Array
		{
			return _categories.slice();
		}
		
		override public function onRegister() : void
		{
			modulesList = [];
			_categories = [];
			modulesForLoadQue = [];
			
			var category : ModulesCategoryVO;
			var categoryName : String;
			var categoryLocalizedName : String;
			var categoryModulesList : Array;
			
			var modulePath : String;
			
			for each ( var categoryXML : XML in MODULES_XML.* ) //TODO Добавить проверку наличия локализованного имени и т.д.
			{
				categoryName = categoryXML.@name;
				categoryLocalizedName = resourceManager.getString( "Modules", categoryName );
				
				category = new ModulesCategoryVO( categoryName, categoryLocalizedName );
				
				_categories.push();
				
				categoryModulesList = [];
				
				for each ( var module : XML in categoryXML.* )
				{
					modulePath = module.@path;
					modulesList.push( new ModuleVO( category, modulePath ));
				}
				
				_categories.push( new ModulesCategoryVO( categoryName, categoryLocalizedName ));
			}
		}
		
		public function getModulesListByCategory( categoryVO : ModulesCategoryVO ) : Array
		{
			var result : Array = modulesList.filter( 
				function( element : ModuleVO, index : int, arr : Array ) : Boolean
				{
					if ( element.category == categoryVO )
						return true;
					else
						return false;
				});

			return null;
		}

		public function getModuleByID( moduleID : String ) : ModuleVO
		{
			var modulesListLength : int = modulesList.length;
			var moduleVO : ModuleVO;

			for ( var i : int = 0; i < modulesListLength; i++ )
			{
				moduleVO = modulesList[ i ] as ModuleVO;

				if ( moduleVO.moduleID == moduleID )
					break;
			}

			return moduleVO;
		}

		public function loadModule( moduleVO : ModuleVO ) : void
		{
			modulesForLoadQue.push( moduleVO );
			
			loadModuleFromQue();
		}

		public function loadModules() : void
		{
			modulesForLoadQue = modulesList.slice();

			loadModuleFromQue();
		}

		private function loadModuleFromQue() : void
		{
			if ( modulesForLoadQue.length == 0 )
			{
				sendNotification( ApplicationFacade.MODULES_LOADED );
				return;
			}

			var moduleVO : ModuleVO = modulesForLoadQue.shift();

			var moduleInfo : IModuleInfo = ModuleManager.getModule( moduleVO.path );
			moduleInfo.data = moduleVO;

			moduleInfo.addEventListener( ModuleEvent.READY, moduleReadyHandler );
			moduleInfo.addEventListener( ModuleEvent.ERROR, moduleErrorHandler );
			moduleInfo.load();

		}

		private function moduleReadyHandler( event : ModuleEvent ) : void
		{
			var moduleVO : ModuleVO = event.module.data as ModuleVO;
			var module : VIModule = event.module.factory.create() as VIModule;
			moduleVO.setModule( module );
			sendNotification( ApplicationFacade.MODULE_LOADED, moduleVO );
			loadModuleFromQue();
		}
		
		private function moduleErrorHandler( event : ModuleEvent ) : void
		{
			var d : * = "";
		}
	}
}