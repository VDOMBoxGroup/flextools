package net.vdombox.ide.model
{
	import flash.display.DisplayObject;

	import mx.events.ModuleEvent;
	import mx.modules.IModuleInfo;
	import mx.modules.ModuleManager;

	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ModulesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ModulesProxy";

		public static const MODULE_LOADED : String = "Module Loaded";

		private static const MODULES_DIR : String = "app:/modules/";

		private static const MODULES_XML : XML = <modules>
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

		private var _categories : XMLList;

		private var moduleInfo : IModuleInfo;

		public function get categories() : XMLList
		{
			return _categories;
		}

		public function getModulesList( categoryName : String ) : XMLList
		{
			return new XMLList( MODULES_XML.category.( @name == categoryName ).module );
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
			_categories = new XMLList();

			for each ( var category : XML in MODULES_XML.* )
			{
				_categories += <category name={category.@name}/>
			}
		}

		private function moduleReadyHandler( event : ModuleEvent ) : void
		{
			var module : DisplayObject = event.module.factory.create() as DisplayObject;
			sendNotification( MODULE_LOADED, module );
		}
	}
}