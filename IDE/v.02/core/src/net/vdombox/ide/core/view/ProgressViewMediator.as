package net.vdombox.ide.core.view
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.view.components.initialWindowClasses.ProgressView;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Label;

	public class ProgressViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ProgressViewMediator";

		public function ProgressViewMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.STARTUP );
			interests.push( ApplicationFacade.LOGOFF );
			interests.push( ApplicationFacade.LOAD_MODULES );
			interests.push( ApplicationFacade.MODULES_LOADED );
			interests.push( ApplicationFacade.MODULE_LOADED );

			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case ApplicationFacade.LOAD_MODULES:
				{
					var label : Label = new Label();
					label.text = notification.getName();
					label.setStyle( "color", "white" );
					progressView.place.addElement( label );
					break;
				}
				case ApplicationFacade.MODULE_LOADED:
				{
					var label : Label = new Label();
					label.text = notification.getName();
					label.setStyle( "color", "white" );
					progressView.place.addElement( label );
					break;
				}
			}
		}
		
		private function get progressView() : ProgressView
		{
			return viewComponent as ProgressView;
		}
	}
}