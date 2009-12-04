package net.vdombox.ide.core.view
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.view.components.ProgressView;
	import net.vdombox.ide.core.view.components.Task;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

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
			interests.push( ApplicationFacade.LOAD_MODULES );
			interests.push( ApplicationFacade.MODULES_LOADED );
			interests.push( ApplicationFacade.MODULE_LOADED );
			
			interests.push( ApplicationFacade.CONNECTION_SERVER_STARTS);
			interests.push( ApplicationFacade.CONNECTION_SERVER_SUCCESSFUL);
			
			interests.push( ApplicationFacade.LOGON_STARTS );
			interests.push( ApplicationFacade.LOGON_SUCCESS );
			
			interests.push( ApplicationFacade.APPLICATIONS_LOADING );
			interests.push( ApplicationFacade.APPLICATIONS_LOADED );
			
			interests.push( ApplicationFacade.TYPES_LOADING );
			interests.push( ApplicationFacade.TYPES_LOADED );

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
					task.description = notification.getName();
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
					
				case ApplicationFacade.CONNECTION_SERVER_STARTS:
				{
					task= new Task();
					task.description = "Connect to server...";
					task.status = "process";
					
					tasks[ "connect" ] = task;
					
					progressView.place.addElement( task );
					
					break;
				}
					
				case ApplicationFacade.CONNECTION_SERVER_SUCCESSFUL:
				{
					task = tasks[ "connect" ];
					task.description = "Connect to server";
					task.status = "OK";
					
					break;
				}
					
				case ApplicationFacade.LOGON_STARTS:
				{
					task= new Task();
					task.description = "Log on to server...";
					task.status = "process";
					
					tasks[ "logon" ] = task;
					
					progressView.place.addElement( task );
					
					break;
				}
					
				case ApplicationFacade.LOGON_SUCCESS:
				{
					task = tasks[ "logon" ];
					task.description = "Log on to server";
					task.status = "OK";
					
					break;
				}
					
				case ApplicationFacade.APPLICATIONS_LOADING:
				{
					task= new Task();
					task.description = "Applications loading...";
					task.status = "process";
					
					tasks[ "applications" ] = task;
					
					progressView.place.addElement( task );
					
					break;
				}
					
				case ApplicationFacade.APPLICATIONS_LOADED:
				{
					task = tasks[ "applications" ];
					task.description = "Applications loading";
					task.status = "OK";
					
					break;
				}
					
				case ApplicationFacade.TYPES_LOADING:
				{
					task= new Task();
					task.description = "Types loading(0)...";
					task.status = "process";
					
					tasks[ "types" ] = task;
					
					progressView.place.addElement( task );
					
					break;
				}
					
				case ApplicationFacade.TYPES_LOADED:
				{
					task = tasks[ "types" ];
					task.description = "Types loading(" + notification.getBody().length + ")...";
					task.status = "OK";
					
					break;
				}
			}
		}
		
		public function cleanup() : void
		{
			progressView.place.removeAllElements();
			tasks = {};
		}
		
		private function get progressView() : ProgressView
		{
			return viewComponent as ProgressView;
		}
	}
}