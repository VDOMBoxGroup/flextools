package net.vdombox.ide.core.view
{
	import net.vdombox.ide.core.model.ModulesProxy;
	import net.vdombox.ide.core.model.SettingsProxy;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class SettingsWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "SettingsWindowMediator";

		public function SettingsWindowMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		override public function onRegister() : void
		{
			var modulesProxy : ModulesProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
			var settingsProxy : SettingsProxy = facade.retrieveProxy( SettingsProxy.NAME ) as SettingsProxy;
			
			var modules : Array = modulesProxy.modules;
			var modulesWithSettings : Array = [];
			
			for ( var i : int = 0; i < modules.length; i++ )
			{
				if ( ModuleVO( modules[ i ] ).module.hasSettings )
					modulesWithSettings.push( modules[ i ].module ); 
			}
		}
	}
}