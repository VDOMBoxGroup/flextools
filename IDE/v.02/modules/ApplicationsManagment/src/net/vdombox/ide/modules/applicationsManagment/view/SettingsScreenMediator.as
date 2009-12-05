package net.vdombox.ide.modules.applicationsManagment.view
{
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class SettingsScreenMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "SettingsScreenMediator";
		
		public function SettingsScreenMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
	}
}