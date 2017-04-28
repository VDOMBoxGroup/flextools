package net.vdombox.ide.core.model
{
	import flash.utils.Dictionary;

	import mx.events.ModuleEvent;
	import mx.modules.IModuleInfo;
	import mx.modules.ModuleManager;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.vo.ModuleVO;

	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

import spark.components.Window;

	/**
	 * @flowerModelElementId _DDnEgEomEeC-JfVEe_-0Aw
	 */
	public class ModulesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ModulesProxy";

		private static const MODULES_XML : XML = <modules>

			<category name="Edition">

				<!--module name="Wysiwyg" path="app:/modules/Wysiwyg/Wysiwyg.swf"/><module name="Preview" path="app:/modules/Preview/Preview2.swf"/>
				<module name="Events" path="app:/modules/Events/Events.swf"/><module name="Trees" path="app:/modules/Tree/Tree.swf"/>
				<module name="Scripts" path="app:/modules/Scripts/Scripts.swf"/><module name="DB" path="app:/modules/DataBase/DataBase.swf"/>
				<module name="Resources" path="app:/modules/ResourceBrowser/ResourceBrowser.swf"/-->

				<module name="Wysiwyg" path="/modules/Wysiwyg/Wysiwyg.swf"/>
				<module name="Preview" path="/modules/Preview/Preview2.swf"/>
				<module name="Events" path="app:/modules/Events/Events.swf"/>
				<module name="Trees" path="app:/modules/Tree/Tree.swf"/>
				<module name="Scripts" path="app:/modules/Scripts/Scripts.swf"/>
				<module name="DB" path="/modules/DataBase/DataBase.swf"/>
				<module name="Resources" path="app:/modules/ResourceBrowser/ResourceBrowser.swf"/>

			</category></modules>

		private static const MODULES_DIR : String = "app:/modules/";

		public function ModulesProxy( data : Object = null )
		{
			super( NAME, data );
		}

		private var loadedModules : Dictionary;

		private var modulesList : Array;

		private var modulesForLoadQue : Array;

		private var resourceManager : IResourceManager;

		private var moduleInfo : IModuleInfo;

		private var countLoadedModules : int;

		public function get modules() : Array
		{
			return modulesList.slice();
		}

		override public function onRegister() : void
		{
			resourceManager = ResourceManager.getInstance();
		}

		override public function onRemove() : void
		{
			cleanup();
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
			sendNotification( ApplicationFacade.MODULES_LOADING_START );

			generateModulesList();

			modulesForLoadQue = modulesList.slice();

			loadModuleFromQue();
		}

		public function unloadAllModules() : void
		{
			var moduleVO : ModuleVO;

			if ( modulesList && modulesList.length > 0 )
			{
				for ( var i : int = 0; i < modulesList.length; i++ )
				{
					moduleVO = modulesList[ i ] as ModuleVO;

					sendNotification( ApplicationFacade.MODULES_UNLOADING_START, moduleVO );

					if ( moduleVO.module )
						moduleVO.module.tearDown();
				}
			}

			cleanup();
		}

		public function cleanup() : void
		{
			modulesList = null;
			modulesForLoadQue = null;
			loadedModules = null;
		}

		private function generateModulesList() : void
		{
			modulesList = [];
			modulesForLoadQue = [];
			loadedModules = new Dictionary();

			var modulePath : String;
			var moduleVO : ModuleVO;

			var categoryXML : XML = MODULES_XML.children()[ 0 ] //TODO Добавить проверку наличия локализованного имени и т.д.

			for each ( var module : XML in categoryXML.* )
			{
				modulePath = module.@path;

				modulesList.push( new ModuleVO( modulePath ) );
			}

			countLoadedModules = modulesList.length;

		}

		private function loadModuleFromQue() : void
		{
			trace("loadModuleFromQue");
			if ( modulesForLoadQue.length == 0 )
			{
				sendNotification( ApplicationFacade.MODULES_LOADING_SUCCESSFUL );
				return;
			}


			var moduleVO : ModuleVO = modulesForLoadQue.shift();
            trace(moduleVO.moduleName , " : ", moduleVO.path);
			sendNotification( ApplicationFacade.MODULE_LOADING_START, moduleVO );

			moduleInfo = ModuleManager.getModule( moduleVO.path );
			moduleInfo.data = moduleVO;

			moduleInfo.addEventListener( ModuleEvent.READY, moduleReadyHandler );
			moduleInfo.addEventListener( ModuleEvent.ERROR, moduleErrorHandler );

			loadedModules[ moduleInfo ] = "";
			moduleInfo.load();

		}

		private function moduleReadyHandler( event : ModuleEvent ) : void
		{
			trace("moduleReadyHandler");
			moduleInfo.removeEventListener( ModuleEvent.READY, moduleReadyHandler );
			moduleInfo.removeEventListener( ModuleEvent.ERROR, moduleErrorHandler );

			var moduleVO : ModuleVO = event.module.data as ModuleVO;
			var module : VIModule = event.module.factory.create() as VIModule;
			module.startup();
			moduleVO.setModule( module );

			delete loadedModules[ event.module ]

			sendNotification( ApplicationFacade.MODULE_LOADING_SUCCESSFUL, moduleVO );
			loadModuleFromQue();
		}

		private function moduleErrorHandler( event : ModuleEvent ) : void
		{
			trace("moduleErrorHandler: " +event.errorText);
			var moduleVO : ModuleVO = event.module.data as ModuleVO;
			sendNotification( ApplicationFacade.MODULES_LOADING_ERROR, moduleVO );
		}
	}
}
