package net.vdombox.ide.modules.applicationsManagment.view
{
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ApplicationItemRendererMediator extends Mediator implements IMediator
	{
		public function ApplicationItemRendererMediator( mediatorName : String = null, viewComponent : Object = null )
		{
			super( mediatorName, viewComponent );
		}
	}
}