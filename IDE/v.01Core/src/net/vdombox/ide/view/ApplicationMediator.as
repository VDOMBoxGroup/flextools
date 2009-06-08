package net.vdombox.ide.view
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	
	import net.vdombox.ide.ApplicationFacade;
	import net.vdombox.ide.view.components.LoginWindow;
	import net.vdombox.ide.view.components.MainScreen;
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
//				var loginForm : LoginForm = new LoginForm();
				loginWindow = new LoginWindow();
				facade.registerMediator( new LoginWindowMediator( loginWindow ) );

				loginWindow.systemChrome = NativeWindowSystemChrome.NONE;
				loginWindow.resizable = false;
				loginWindow.maximizable = false;
				loginWindow.minimizable = false;
				loginWindow.transparent = true;
//				loginWindow.setStyle( "skinClass", WindowSkin );
				loginWindow.title = "VDOM IDE - Login";

				loginWindow.showTitleBar = false;
				loginWindow.showGripper = false;
				loginWindow.showStatusBar = false;

				
				loginWindow.open();
				
//				loginWindow.addElement( loginForm );
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

				var windowOptions : NativeWindowInitOptions = new NativeWindowInitOptions();
				windowOptions.systemChrome = NativeWindowSystemChrome.NONE;
				windowOptions.resizable = true;
				windowOptions.maximizable = true;
				windowOptions.minimizable = true;
				windowOptions.transparent = true;
				
				var mainWindow : Window = new Window();

				mainWindow.systemChrome = NativeWindowSystemChrome.NONE;
				mainWindow.resizable = true;
				mainWindow.maximizable = true;
				mainWindow.minimizable = true;
				mainWindow.transparent = true;

//				mainWindow.titleBarFactory = new ClassFactory( MainTitleBar );
				
				
				mainWindow.addChild( mainScreen );


				mainWindow.showTitleBar = true;
				mainWindow.showGripper = false;
				mainWindow.showStatusBar = true;
	
				mainWindow.setStyle( "borderStyle", "none" );
				mainWindow.setStyle( "backgroundAlpha", .0 );
				
				mainWindow.width = 800;
				mainWindow.height = 600;
				
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