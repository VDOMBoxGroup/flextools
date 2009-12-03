package net.vdombox.ide.core.view
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.view.components.ProgressView;
	import net.vdombox.ide.core.view.components.Task;
	
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

		private var tasks : Object;
		
		override public function onRegister() : void
		{
			tasks = {};
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
			var task : Task;
			switch ( notification.getName() )
			{
				case ApplicationFacade.LOAD_MODULES:
				{
					task= new Task();
					task.taskName = notification.getName();
					task.status = "begin";
					
					tasks[ "types" ] = task;
					
					progressView.place.addElement( task );
					
					break;
				}
					
				case ApplicationFacade.MODULE_LOADED:
				{
					task = tasks[ "types" ];
					task.status = "loading";
					
					break;
				}
					
				case ApplicationFacade.MODULES_LOADED:
				{
					task = tasks[ "types" ];
					task.status = "OK";
					
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