//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.core.view
{
	import flash.desktop.NativeApplication;
	import flash.display.Loader;
	import flash.display.Screen;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayList;
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	import mx.events.AIREvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.managers.SystemManager;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.MainWindowEvent;
	import net.vdombox.ide.core.model.ModulesProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.SessionProxy;
	import net.vdombox.ide.core.model.StatesProxy;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	import net.vdombox.ide.core.model.vo.ModulesCategoryVO;
	import net.vdombox.ide.core.view.components.MainWindow;
	import net.vdombox.ide.core.view.components.SettingsWindow;
	import net.vdombox.ide.core.view.managers.PopUpWindowManager;
	import net.vdombox.utils.VersionUtils;
	import net.vdombox.utils.WindowManager;
	
	import org.osmf.utils.Version;
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.ButtonBar;
	import spark.components.Group;
	import spark.events.IndexChangeEvent;
	import spark.skins.spark.ButtonSkin;

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

		private var currentModuleCategory : ModulesCategoryVO;

		private var modulesList : Array;

		private var modulesProxy : ModulesProxy;

		private var resourceManager : IResourceManager = ResourceManager.getInstance();

		private var selectedModuleID : String = "";

		private var windowManager : WindowManager = WindowManager.getInstance();
		
		private var applicationVO : ApplicationVO;

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
					setApplicationInfo();
					break;
				}

				case ApplicationFacade.CHANGE_SELECTED_MODULE:
				{
					var newSelectedModuleID : String = body as String;
					var moduleVO : ModuleVO = modulesProxy.getModuleByID( newSelectedModuleID );

					selectModule( moduleVO );
					break;
				}


				case ApplicationFacade.OPEN_APPLICATION_IN_EDITOR:
				{
					applicationVO = body as ApplicationVO;
					
					openApplicationInEditor();
					break;
				}
					
				case ApplicationFacade.RESOURCE_LOADED:
				{
					if ( !applicationVO )
						return;
					
					var resVO : ResourceVO  = notification.getBody() as ResourceVO;
					if ( resVO.ownerID != applicationVO.id )
						return;
					
					if ( resVO.id != applicationVO.iconID )
						return;
					
					BindingUtils.bindSetter( setIcon, resVO, "data", false, true );
					
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
			interests.push( ApplicationFacade.OPEN_APPLICATION_IN_EDITOR );
			interests.push( ApplicationFacade.RESOURCE_LOADED );

			return interests;
		}
		
		private function setApplicationInfo() : void
		{
			
			if (!applicationVO)
			{
				var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
				
				applicationVO = statesProxy.selectedApplication;
			}
			mainWindow.nameApplication.text = applicationVO.name;
			
			if ( !applicationVO.iconID )
			{
				mainWindow.iconApplication.source = null;
			}
			
			if ( applicationVO.iconID )
			{
				var resourceVO : ResourceVO = new ResourceVO( applicationVO.id );
				resourceVO.setID( applicationVO.iconID );
				
				sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO );
			}
		}
		
		private function setIcon( value : * ) : void
		{
			var loader : Loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, setIconLoaded );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, setIconLoaded );
			
			try
			{
				loader.loadBytes( value );
			}
			catch ( error : Error )
			{
				// FIXME Сделать обработку исключения если не грузится изображение
			}
		}
		
		private function setIconLoaded( event : Event ) : void
		{
			if ( event.type == IOErrorEvent.IO_ERROR )
				return;
			mainWindow.iconApplication.source = event.target.content;
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

		private function addHandlers() : void
		{
			mainWindow.addEventListener( FlexEvent.CREATION_COMPLETE, mainWindow_creationCompleteHandler, false, 0, true );
			mainWindow.addEventListener( MainWindowEvent.LOGOUT, logoutHandler, true, 0, true );
			mainWindow.addEventListener( MainWindowEvent.SHOW_APP_MANAGER, appManagerHandler, true, 0, true );
		}

		private function appManagerHandler( event : MainWindowEvent ) : void
		{
			sendNotification( ApplicationFacade.OPEN_APPLICATION_MANAGER, event.target );
		}

		private function cleanup() : void
		{
			toolsetBar.removeAllElements();
			mainWindow.removeAllElements();
		}

		private function initTitle() : void
		{
			/*var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var title : String            = "";

			title = serverProxy.authInfo.hostname + "  -  >VDOM IDE.v.2.0.1008" ;

			if ( statesProxy.selectedApplication )
				title = statesProxy.selectedApplication.name + "  @  " + title;*/

			mainWindow.title = VersionUtils.getApplicationName();
		}

		private function initUser() : void
		{
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			mainWindow.username = serverProxy.authInfo.username;
		}

		private function logoutHandler( event : MainWindowEvent ) : void
		{
			cleanup();
			sendNotification( ApplicationFacade.REQUEST_FOR_SIGNOUT );
		}

		private function mainWindow_creationCompleteHandler( event : FlexEvent ) : void
		{

			showModules();
			selectModule();

			initUser();
			initTitle();
		}

		private function openApplicationInEditor() : void
		{
			selectModule();
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

		private function removeHandlers() : void
		{
			mainWindow.removeEventListener( FlexEvent.CREATION_COMPLETE, mainWindow_creationCompleteHandler );
			mainWindow.removeEventListener( MainWindowEvent.LOGOUT, logoutHandler, true );
			mainWindow.removeEventListener( MainWindowEvent.SHOW_APP_MANAGER, appManagerHandler, true );
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
// todo: delete
			sendNotification( ApplicationFacade.SELECTED_MODULE_CHANGED, moduleVO );
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
