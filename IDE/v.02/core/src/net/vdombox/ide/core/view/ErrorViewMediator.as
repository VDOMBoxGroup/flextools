package net.vdombox.ide.core.view
{
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class ErrorViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ErrorViewMediator";
		
		public function ErrorViewMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
	}
}