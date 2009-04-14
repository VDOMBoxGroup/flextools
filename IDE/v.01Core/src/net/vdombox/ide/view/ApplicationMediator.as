package net.vdombox.ide.view
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;

	import mx.core.Window;

	import net.vdombox.ide.ApplicationFacade;
	import net.vdombox.ide.view.components.LoginForm;
	import net.vdombox.ide.view.components.MainScreen;
	import net.vdombox.ide.view.managers.PopUpWindowManager;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

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

		private var loginWindow : Window;
		private var mainWindow : Window;

		override public function listNotificationInterests() : Array
		{
			return [ ApplicationFacade.STARTUP ];
		}

		override public function handleNotification( note : INotification ) : void
		{
			switch ( note.getName() )
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
				var loginForm : LoginForm = new LoginForm();
				facade.registerMediator( new LoginFormMediator( loginForm ) );

//				loginForm.addEventListener( LoginFormEvent.SUBMIT_BEGIN, loginForm_submitBeginHandler );
//				loginForm.addEventListener( LoginFormEvent.QUIT, loginForm_quitHandler );

				var windowOptions : NativeWindowInitOptions = new NativeWindowInitOptions();
				windowOptions.systemChrome = NativeWindowSystemChrome.NONE;
				windowOptions.resizable = false;
				windowOptions.maximizable = false;
				windowOptions.minimizable = false;
				windowOptions.transparent = true;

				loginWindow = popUpWindowManager.addPopUp( loginForm, "VDOM IDE - Login",
														   null, false, null, windowOptions );

				loginWindow.showTitleBar = false;
				loginWindow.showGripper = false;
				loginWindow.showStatusBar = false;

				loginWindow.setStyle( "borderStyle", "none" );
				loginWindow.setStyle( "backgroundAlpha", .0 );
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
				var mainScreen : MainScreen = new MainScreen();
				facade.registerMediator( new MainScreenMediator( mainScreen ) );

//				loginForm.addEventListener( LoginFormEvent.SUBMIT_BEGIN, loginForm_submitBeginHandler );
//				loginForm.addEventListener( LoginFormEvent.QUIT, loginForm_quitHandler );

				var windowOptions : NativeWindowInitOptions = new NativeWindowInitOptions();
				windowOptions.systemChrome = NativeWindowSystemChrome.NONE;
				windowOptions.resizable = true;
				windowOptions.maximizable = true;
				windowOptions.minimizable = true;
				windowOptions.transparent = true;

				mainWindow = popUpWindowManager.addPopUp( mainScreen, "VDOM IDE - Login",
														  null, false, null, windowOptions );

				mainWindow.showTitleBar = true;
				mainWindow.showGripper = true;
				mainWindow.showStatusBar = true;

				mainWindow.setStyle( "borderStyle", "none" );
				mainWindow.setStyle( "backgroundAlpha", .0 );
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