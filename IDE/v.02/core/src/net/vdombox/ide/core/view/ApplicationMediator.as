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

		private var currentWindow : Window;

		private var initialWindowMediator : InitialWindowMediator;

		private var mainWindowMediator : MainWindowMediator;

//		private var windowManager : WindowManager = net.vdombox.utils.WindowManager.getInstance();

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.STARTUP );
			interests.push( ApplicationFacade.INITIAL_WINDOW_OPENED );
			interests.push( ApplicationFacade.MAIN_WINDOW_OPENED );
			interests.push( ApplicationFacade.TYPES_LOADED );

			return interests;
		}

		override public function handleNotification( note : INotification ) : void
		{
			switch ( note.getName())
			{
				case ApplicationFacade.STARTUP:
				{
					initialWindowMediator.openWindow();
					
					break;
				}
				
				case ApplicationFacade.TYPES_LOADED:
				{
					mainWindowMediator.openWindow();
					initialWindowMediator.closeWindow();
					
					break;
				}
					
				case ApplicationFacade.INITIAL_WINDOW_OPENED:
				{
					sendNotification( ApplicationFacade.LOAD_MODULES );
					
					break;
				}
				
				case ApplicationFacade.MAIN_WINDOW_OPENED:
				{
					sendNotification( ApplicationFacade.LOAD_MODULES );
					
					break;
				}
			}
		}

		override public function onRegister() : void
		{
			initialWindowMediator = new InitialWindowMediator( new InitialWindow());
			facade.registerMediator( initialWindowMediator );

			mainWindowMediator = new MainWindowMediator( new MainWindow());
			facade.registerMediator( mainWindowMediator );
		}
	}
}