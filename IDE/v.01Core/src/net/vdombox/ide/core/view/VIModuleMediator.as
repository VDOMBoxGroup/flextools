package net.vdombox.ide.core.view
{
	import net.vdombox.ide.common.VIModule;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class VIModuleMediator extends Mediator implements IMediator
	{
		public static const NAME : String = 'VIModuleMediator';

		public function VIModuleMediator( viewComponent : VIModule )
		{
			super( NAME + "/" + viewComponent.moduleID, viewComponent );
		}
	}
}