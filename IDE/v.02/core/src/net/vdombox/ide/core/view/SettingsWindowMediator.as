package net.vdombox.ide.core.view
{
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class SettingsWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "SettingsWindowMediator";

		public function SettingsWindowMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
	}
}