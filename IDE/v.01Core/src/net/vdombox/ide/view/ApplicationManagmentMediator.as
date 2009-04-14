package net.vdombox.ide.view
{
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	import org.puremvc.as3.multicore.interfaces.IMediator;

	public class ApplicationManagmentMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ApplicationManagmentMediator";

		public function ApplicationManagmentMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
	}
}