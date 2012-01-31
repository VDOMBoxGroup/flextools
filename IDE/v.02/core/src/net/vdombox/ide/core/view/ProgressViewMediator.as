package net.vdombox.ide.core.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.TypesProxy;
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

		public function get progressView() : ProgressView
		{
			return viewComponent as ProgressView;
		}

		override public function onRegister() : void
		{
			tasks = {};

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.MODULES_LOADING_START );
			interests.push( ApplicationFacade.MODULE_LOADING_SUCCESSFUL );
			interests.push( ApplicationFacade.MODULES_LOADING_SUCCESSFUL );

			interests.push( ApplicationFacade.SERVER_CONNECTION_START );
			interests.push( ApplicationFacade.SERVER_CONNECTION_SUCCESSFUL );
			interests.push( ApplicationFacade.SERVER_CONNECTION_ERROR );

			interests.push( ApplicationFacade.SERVER_LOGIN_START );
			interests.push( ApplicationFacade.SERVER_LOGIN_SUCCESSFUL );
			interests.push( ApplicationFacade.SERVER_LOGIN_ERROR );

			interests.push( TypesProxy.TYPES_LOADING );
			interests.push( TypesProxy.TYPES_LOADED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();

			var task : Task;

			switch ( name )
			{
				case ApplicationFacade.MODULES_LOADING_START:
				{
					task = new Task();
					task.description = notification.getName();
					task.status = "begin";

					tasks[ "types" ] = task;

					progressView.addElement( task );

					break;
				}

				case ApplicationFacade.MODULE_LOADING_SUCCESSFUL:
				{
					task = tasks[ "types" ];

					if ( task )
						task.status = "loading";

					break;
				}

				case ApplicationFacade.MODULES_LOADING_SUCCESSFUL:
				{
					task = tasks[ "types" ];

					if ( task )
						task.status = "OK";

					break;
				}

				case ApplicationFacade.SERVER_CONNECTION_START:
				{
					task = new Task();
					task.description = "Connect to server...";
					task.status = "process";

					tasks[ "connect" ] = task;

					progressView.addElement( task );

					break;
				}

				case ApplicationFacade.SERVER_CONNECTION_SUCCESSFUL:
				{
					task = tasks[ "connect" ];
					if ( task )
					{
						task.description = "Connect to server";
						task.status = "OK";
					}

					break;
				}

				case ApplicationFacade.SERVER_LOGIN_START:
				{
					task = new Task();
					task.description = "Log on to server...";
					task.status = "process";

					tasks[ "logon" ] = task;

					progressView.addElement( task );

					break;
				}

				case ApplicationFacade.SERVER_LOGIN_SUCCESSFUL:
				{
					task = tasks[ "logon" ];
					if ( task )
					{
						task.description = "Log on to server";
						task.status = "OK";
					}

					break;
				}

				case TypesProxy.TYPES_LOADING:
				{
					task = new Task();
					task.description = "Types loading...";
					task.status = "process";

					tasks[ "types" ] = task;

					progressView.addElement( task );

					break;
				}

				case TypesProxy.TYPES_LOADED:
				{
					task = tasks[ "types" ];
					if ( task )
					{
						task.description = "Types loading(" + notification.getBody().length + ")...";
						task.status = "OK";
					}

					break;
				}
			}
		}

		public function cleanup() : void
		{
			progressView.removeAllElements();
			tasks = {};
		}

		private function addHandlers() : void
		{
//			progressView.addEventListener( Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true );
//			progressView.addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true );
		}

		private function removeHandlers() : void
		{
//			progressView.removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
//			progressView.removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
		}
	}
}