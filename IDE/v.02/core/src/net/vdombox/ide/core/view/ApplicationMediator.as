package net.vdombox.ide.core.view
{
	import flash.desktop.NativeApplication;
	
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.view.components.InitialWindow;
	import net.vdombox.ide.core.view.components.MainWindow;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Window;

	public class ApplicationMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ApplicationMediator";

		public function ApplicationMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );

			application.nativeWindow.close();
			NativeApplication.nativeApplication.autoExit = false;
		}

		protected function get application() : VdomIDE
		{
			return viewComponent as VdomIDE
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.INITIAL_WINDOW_OPENED );

//			interests.push( ApplicationFacade.MAIN_WINDOW_OPENED );
			interests.push( ApplicationFacade.TYPES_LOADED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();

			switch ( name )
			{
				case ApplicationFacade.TYPES_LOADED:
				{
					sendNotification( ApplicationFacade.OPEN_MAIN_WINDOW );

					break;
				}

				case ApplicationFacade.INITIAL_WINDOW_OPENED:
				{
					sendNotification( ApplicationFacade.LOAD_MODULES_REQUEST );

					break;
				}

//				case ApplicationFacade.MAIN_WINDOW_OPENED:
//					{
//						sendNotification( ApplicationFacade.LOAD_MODULES );
//
//						break;
//					}
			}
		}
	}
}