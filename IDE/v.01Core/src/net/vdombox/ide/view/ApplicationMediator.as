package net.vdombox.ide.view
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindowSystemChrome;

	import net.vdombox.ide.ApplicationFacade;
	import net.vdombox.ide.view.components.LoginWindow;
	import net.vdombox.ide.view.components.MainWindow;
	import net.vdombox.ide.view.managers.PopUpWindowManager;

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

		private var popUpWindowManager : PopUpWindowManager = PopUpWindowManager.getInstance();

		private var currentWindow : Window;

		private var loginWindow : LoginWindow;

		private var mainWindow : MainWindow;

		override public function listNotificationInterests() : Array
		{
			return [ ApplicationFacade.STARTUP ];
		}

		override public function handleNotification( note : INotification ) : void
		{
			switch ( note.getName())
			{
				case ApplicationFacade.STARTUP:
				{
					openLoginWindow();
					break;
				}
			}
		}

		public function openLoginWindow() : void
		{
			if ( mainWindow && mainWindow.visible )
				mainWindow.visible = false;

			if ( !loginWindow )
			{
				loginWindow = new LoginWindow();
				facade.registerMediator( new LoginWindowMediator( loginWindow ));

				loginWindow.open();
			}
			else
			{
				if ( !loginWindow.visible )
					loginWindow.visible = true;
			}

			currentWindow = loginWindow;
		}

		public function openMainWindow() : void
		{
			if ( loginWindow && loginWindow.visible )
				loginWindow.visible = false;

			if ( !mainWindow )
			{
				mainWindow = new MainWindow();
				facade.registerMediator( new MainWindowMediator( mainWindow ));

				mainWindow.open();
			}
			else
			{
				if ( !mainWindow.visible )
					mainWindow.visible = true;
			}

			currentWindow = mainWindow;
		}

	}
}