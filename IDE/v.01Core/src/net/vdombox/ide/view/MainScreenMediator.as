package net.vdombox.ide.view
{
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class MainScreenMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "MainScreenMediator";

		public function MainScreenMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

	}
}