package net.vdombox.ide.core.view
{
	import net.vdombox.ide.common.interfaces.IVIModule;
	import net.vdombox.ide.common.VIModule;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class VIModuleMediator extends Mediator implements IMediator
	{
		public function VIModuleMediator( viewComponent : VIModule )
		{
			super( viewComponent.moduleID, viewComponent );
		}

		public function tearDown() : void
		{
			module.tearDown();
		}

		private function get module() : IVIModule
		{
			return viewComponent as IVIModule;
		}
	}
}