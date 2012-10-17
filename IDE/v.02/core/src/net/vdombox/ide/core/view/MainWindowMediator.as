//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.core.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.model.PreferencesProxy;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.MainWindowEvent;
	import net.vdombox.ide.core.model.ModulesProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.StatesProxy;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	import net.vdombox.ide.core.view.components.MainWindow;
	import net.vdombox.ide.core.view.components.SettingsWindow;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Group;
	import spark.events.IndexChangeEvent;

	use namespace mx_internal;

	/**
	 *
	 * @author andreev ap
	 */
	public class MainWindowMediator extends Mediator implements IMediator
	{
		/**
		 *
		 * @default
		 */
		public static const NAME : String = "MainScreenMediator";

		/**
		 *
		 * @param viewComponent
		 */
		public function MainWindowMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var applicationVO : ApplicationVO;


		private var modulesList : Array;

		private var modulesProxy : ModulesProxy;

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var resourceVO : ResourceVO;

		private var selectedModuleID : String = "";

		private var windowManager : WindowManager = WindowManager.getInstance();

		private var moduleVO : ModuleVO;
		
		private var typeCheckSaved : String = "";
		/**
		 *
		 */
		public function closeWindow() : void
		{
			windowManager.removeWindow( mainWindow );
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var body : Object = notification.getBody();

			switch ( notification.getName() )
			{
				case ApplicationFacade.SHOW_MODULE_TOOLSET:
				{
					toolsetBar.addElement( body.component as IVisualElement );

					break;
				}

				case ApplicationFacade.SHOW_MODULE_BODY:
				{
					mainWindow.addElement( body.component as IVisualElement );
					
					sendNotification( PreferencesProxy.SELECTED_COLOR_SCHEME_CHANGE );

					setApplicationInfo();

					break;
				}

				case ApplicationFacade.CHANGE_SELECTED_MODULE:
				{
					var newSelectedModuleID : String = body as String;
					moduleVO = modulesProxy.getModuleByID( newSelectedModuleID );

					if ( currentModule != moduleVO )
					{
						if ( currentModule.moduleID == "net.vdombox.ide.modules.Events" ||
							 currentModule.moduleID == "net.vdombox.ide.modules.Tree")
						{
							typeCheckSaved = "changeModule";
							sendNotification( ApplicationFacade.APPLICATION_CHECK_SAVED, statesProxy.selectedApplication );
						}
						else 
							selectModule( moduleVO );
					}

					break;
				}


				case ApplicationFacade.SELECTED_APPLICATION_CHANGED:
				{
					applicationVO = body as ApplicationVO;

					setApplicationInfo();

					break;
				}

				case ApplicationFacade.OPEN_MAIN_WINDOW:
				{
					selectModule( currentModule );
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_SAVE_CHECKED:
				{
					if ( body as Boolean )
					{
						if ( typeCheckSaved == "changeModule" )
							selectModule( moduleVO );
						else
							openAppManager();
					}
					else
					{
						sendNotification( ApplicationFacade.WRITE_QUESTION, ResourceManager.getInstance().getString( 'Core_General', 'save_the_changes' ) );
					}
					
					break;
				}
					
				case ApplicationFacade.ALERT_WINDOW_CLOSE:
				{
					if ( body as Boolean )
					{
						sendNotification( ApplicationFacade.APPLICATION_SET_SAVE, statesProxy.selectedApplication );
					}
						
					if ( typeCheckSaved == "changeModule" )
						selectModule( moduleVO );
					else
						openAppManager();
					
					break;
				}
					
				case ApplicationFacade.SIGNOUT:
				{
					logoutHandler();
					
					break;
				}
			}
			
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SHOW_MODULE_TOOLSET );
			interests.push( ApplicationFacade.SHOW_MODULE_BODY );
			interests.push( ApplicationFacade.CHANGE_SELECTED_MODULE );
			interests.push( ApplicationFacade.SELECTED_APPLICATION_CHANGED );
			interests.push( ApplicationFacade.OPEN_MAIN_WINDOW );
			interests.push( ApplicationFacade.APPLICATION_SAVE_CHECKED );
			interests.push( ApplicationFacade.ALERT_WINDOW_CLOSE );
			interests.push( ApplicationFacade.SIGNOUT );
			
			return interests;
		}
		
		private function addHandlers() : void
		{
			mainWindow.addEventListener( FlexEvent.CREATION_COMPLETE, mainWindow_creationCompleteHandler, false, 0, true );
			mainWindow.addEventListener( MainWindowEvent.LOGOUT, logoutHandler, true, 0, true );
			mainWindow.addEventListener( MainWindowEvent.CLOSE, closeHandler, true, 0, true );
			mainWindow.addEventListener( MainWindowEvent.SHOW_APP_MANAGER, appManagerHandler, true, 0, true );
			mainWindow.addEventListener( Event.CLOSE, closeWindowHandler, false, 0, true );
		}
		
		
		private function removeHandlers() : void
		{
			mainWindow.removeEventListener( FlexEvent.CREATION_COMPLETE, mainWindow_creationCompleteHandler );
			mainWindow.removeEventListener( MainWindowEvent.LOGOUT, logoutHandler, true );
			mainWindow.removeEventListener( MainWindowEvent.CLOSE, closeHandler, true );
			mainWindow.removeEventListener( MainWindowEvent.SHOW_APP_MANAGER, appManagerHandler, true );
			mainWindow.removeEventListener( Event.CLOSE, closeWindowHandler );
		}



		/**
		 *
		 * @return
		 */
		public function get mainWindow() : MainWindow
		{
			return viewComponent as MainWindow;
		}

		override public function onRegister() : void
		{
			addHandlers();

			modulesProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;

			sendNotification( ApplicationFacade.CHECK_UPDATE );
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		/**
		 *
		 */
		public function openWindow() : void
		{
			windowManager.addWindow( mainWindow );
		}

		public function get statesProxy() : StatesProxy
		{
			return facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
		}

		private function appManagerHandler( event : MainWindowEvent ) : void
		{
			if ( currentModule.moduleID == "net.vdombox.ide.modules.Events" ||
				currentModule.moduleID == "net.vdombox.ide.modules.Tree" )
			{
				typeCheckSaved = "appManagerOpened";
				sendNotification( ApplicationFacade.APPLICATION_CHECK_SAVED, statesProxy.selectedApplication );
			}
			else
				openAppManager();
		}
		
		private function openAppManager() : void
		{
			currentModule.module.deSelect();
			sendNotification( ApplicationFacade.OPEN_APPLICATION_MANAGER, mainWindow );
		}

		private function cleanup() : void
		{
			toolsetBar.removeAllElements();
			mainWindow.removeAllElements();
		}

		private function closeWindowHandler( event : Event ) : void
		{
			cleanup();
			
			removeHandlers();
		}

		private function get currentModule() : ModuleVO
		{
			return modulesProxy.getModuleByID( selectedModuleID );
			;
		}

		private function initTitle() : void
		{
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			mainWindow.title = serverProxy.authInfo.hostname;
		}

		private function initUser() : void
		{
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			mainWindow.username = serverProxy.authInfo.username;
		}

		private function logoutHandler( event : MainWindowEvent = null ) : void
		{
			cleanup();

			sendNotification( ApplicationFacade.REQUEST_FOR_SIGNOUT );
		}
		
		private function closeHandler( event : MainWindowEvent = null ) : void
		{			
			sendNotification( ApplicationFacade.CLOSE_IDE );
		}

		private function mainWindow_creationCompleteHandler( event : FlexEvent ) : void
		{
			showModules();
			selectModule();

			initUser();
			initTitle();
		}

		private function placeToolsets() : void
		{
			toolsetBar.removeAllElements();

			if ( modulesList.length == 0 )
				return;

			for ( var i : int = 0; i < modulesList.length; i++ )
			{
				var moduleVO : ModuleVO = modulesList[ i ];

				if ( moduleVO.module.hasToolset )
					moduleVO.module.getToolset();
			}
		}

		private function selectModule( moduleVO : ModuleVO = null ) : void
		{
			mainWindow.removeAllElements();

			// deselect all modules
			for each ( var modVO : ModuleVO in modulesList )
			{
				modVO.module.deSelect();
			}

			// choose module to select
			if ( !moduleVO )
				moduleVO = modulesList[ 0 ] as ModuleVO;

			moduleVO.module.getBody();


			selectedModuleID = moduleVO.moduleID;

			sendNotification( ApplicationFacade.SELECTED_MODULE_CHANGED, moduleVO );
		}

		private function setApplicationInfo() : void
		{
			if ( !applicationVO )
				applicationVO = statesProxy.selectedApplication;

			if ( !applicationVO )
				return;

			mainWindow.nameApplication.text = applicationVO.name;

			if ( !applicationVO.iconID )
			{
				mainWindow.iconApplication.source = null;
			}
			else
			{
				resourceVO = new ResourceVO( applicationVO.id );
				resourceVO.setID( applicationVO.iconID );

				mainWindow.resourceVO = resourceVO;

				sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO );
			}
		}

		private function settingsButton_clickHandler( event : MouseEvent ) : void
		{
			if ( facade.hasMediator( SettingsWindowMediator.NAME ) )
				facade.removeMediator( SettingsWindowMediator.NAME );

			var settingsWindow : SettingsWindow = new SettingsWindow();
			facade.registerMediator( new SettingsWindowMediator( settingsWindow ) );

			windowManager.addWindow( settingsWindow, mainWindow, true );
		}

		private function showModules() : void
		{

			cleanup();

			modulesList = modulesProxy.modules;

			if ( modulesList.length == 0 )
				return;

			placeToolsets();
		}

		private function tabBar_indexChangeEvent( event : IndexChangeEvent ) : void
		{
			showModules();
			selectModule();
		}

		private function get toolsetBar() : Group
		{
			return mainWindow.toolsetBar;
		}
	}
}
