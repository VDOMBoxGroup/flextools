package net.vdombox.ide.view
{
	import net.vdombox.ide.model.ModulesProxy;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ModulesManagmentMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ModulesManagmentMediator";

		public function ModulesManagmentMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		private var modulesProxy : ModulesProxy;
		
		override public function onRegister():void
		{
			modulesProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
		}
		
		public function showModulesByCategory( categoryName : String ) : void
		{
			var moduleList : XMLList = modulesProxy.getModulesList( categoryName );
		}
	}
}