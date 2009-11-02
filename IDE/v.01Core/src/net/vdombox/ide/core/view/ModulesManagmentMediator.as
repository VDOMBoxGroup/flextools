package net.vdombox.ide.view
{
	import flash.display.DisplayObject;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Box;
	
	import net.vdombox.ide.model.ModulesProxy;
	import net.vdombox.ide.view.components.ModulesManagment;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ModulesManagmentMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ModulesManagmentMediator";

		public function ModulesManagmentMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var modulesProxy : ModulesProxy;
		private var currentModuleCategory : String;
		private var moduleList : Array;
		private var loadedModules : Array;

		override public function onRegister() : void
		{
			modulesProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
		}

		private function get modulesManagment() : ModulesManagment
		{
			return Box( viewComponent ).getChildAt( 0 ) as ModulesManagment;
		}

		override public function listNotificationInterests() : Array
		{
			return [ ModulesProxy.MODULE_LOADED ];
		}

		override public function handleNotification( note : INotification ) : void
		{
			switch ( note.getName() )
			{
				case ModulesProxy.MODULE_LOADED:
				{
					var module : DisplayObject = note.getBody() as DisplayObject;
					loadedModules.push( module );
					getModule();
					break;
				}
			}
		}

		public function showModulesByCategory( categoryName : String ) : void
		{
			var moduleXMLList : Array = modulesProxy.getModulesList( categoryName );
			currentModuleCategory = categoryName;
			moduleList = [];
			loadedModules = [];
			for each ( var module : XML in moduleXMLList )
			{
				moduleList.push( { name: module.@name } );
			}

			getModule();
		}

		private function getModule() : void
		{
			if ( moduleList.length == 0 )
			{	
				var test : Array = [];
				for each ( var item : * in loadedModules )
				{
					test.push( { label : item.title, icon : item.icon } );
				}
				modulesManagment.modulesButtonBar.dataProvider = test;
				
				modulesManagment.modulePlacement.removeAllChildren();
				
				if( loadedModules.length > 0 )
					modulesManagment.modulePlacement.addChild( loadedModules[ 0 ] );
				
				return;
			}

			var module : Object = moduleList.shift();
			modulesProxy.loadModule( currentModuleCategory, module.name );
		}

	}
}