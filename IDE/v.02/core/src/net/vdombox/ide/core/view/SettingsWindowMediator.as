package net.vdombox.ide.core.view
{
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayList;
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.interfaces.ISettingsScreen;
	import net.vdombox.ide.common.interfaces.IVIModule;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ModulesProxy;
	import net.vdombox.ide.core.model.SettingsStorageProxy;
	import net.vdombox.ide.core.model.vo.ModuleVO;
	import net.vdombox.ide.core.view.components.SettingsWindow;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Label;
	import spark.components.List;
	import spark.events.IndexChangeEvent;

	public class SettingsWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "SettingsWindowMediator";

		public function SettingsWindowMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		private var modulesProxy : ModulesProxy;
		private var settingsProxy : SettingsStorageProxy;
		
		private var moduleWithSettings : Object;
		private var settingsScreensList : Object;
		
		
		private var selectedSettingsID : String
		
		public function get settingsWindow() : SettingsWindow
		{
			return viewComponent as SettingsWindow;
		}
		
		override public function onRegister() : void
		{
			addEventListeners();
			
			modulesProxy = facade.retrieveProxy( ModulesProxy.NAME ) as ModulesProxy;
			settingsProxy = facade.retrieveProxy( SettingsStorageProxy.NAME ) as SettingsStorageProxy;
			
			settingsScreensList = {};
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.SHOW_MODULE_SETTINGS_SCREEN );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			
			switch ( notification.getName() )
			{
				case ApplicationFacade.SHOW_MODULE_SETTINGS_SCREEN:
				{
					settingsScreensList[ body.recepientKey ] = body.component;
					
					settingsWindow.settingsScreenHolder.addElement( body.component as IVisualElement );
					
					break;
				}
			}
		}

		private function addEventListeners() : void
		{
			settingsWindow.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			settingsWindow.settingsCategory.addEventListener( IndexChangeEvent.CHANGE, settingsCategory_changeHandler );
			settingsWindow.performOK.addEventListener( MouseEvent.CLICK, performOK_clickHandler );
			settingsWindow.performCancel.addEventListener( MouseEvent.CLICK, performCancel_clickHandler );

			var modules : Array = modulesProxy.modules;
			
			var settingsCategoryCollection : ArrayList = new ArrayList();

			moduleWithSettings = {};
			
			settingsCategoryCollection.addItem( { id : "VdomIDE", label : "General" } );
			
			var module : IVIModule;

			for ( var i : int = 0; i < modules.length; i++ )
			{
				if ( ModuleVO( modules[ i ] ).module.hasSettings )
				{
					module = modules[ i ].module as IVIModule;
					moduleWithSettings[ module.moduleID ] = module;
					settingsCategoryCollection.addItem( { id : module.moduleID, label: module.moduleName } );
				}
			}
			
			settingsWindow.settingsCategory.requireSelection = true;
			settingsWindow.settingsCategory.labelField = "label";
			settingsWindow.settingsCategory.dataProvider = settingsCategoryCollection;
			
		}
		
		private function settingsCategory_changeHandler( event : IndexChangeEvent ) : void
		{
			var selectedItem : Object = List( event.currentTarget ).selectedItem;
			
			selectedSettingsID = selectedItem.id;
			
			settingsWindow.settingsScreenHolder.removeAllElements();
			
			if( settingsScreensList.hasOwnProperty( selectedSettingsID ) )
			{
				settingsWindow.settingsScreenHolder.addElement( settingsScreensList[ selectedSettingsID ] );
				return;
			}
			
			if( selectedItem.id == "VdomIDE" )
			{
				var label : Label = new Label();
				label.text = "general";
				label.verticalCenter = 0;
				label.horizontalCenter = 0;
				settingsWindow.settingsScreenHolder.addElement( label );
			}
			else
			{
				IVIModule( moduleWithSettings[ selectedItem.id ] ).getSettingsScreen();
			}
		}
		
		private function performOK_clickHandler( event : MouseEvent ) : void
		{
			if( selectedSettingsID == "VdomIDE" )
			{
				var d : * = "";
			}
			else
			{
				if ( settingsScreensList.hasOwnProperty( selectedSettingsID ) )
					ISettingsScreen( settingsScreensList[ selectedSettingsID ] ).performOK();
			}
			
			sendNotification( ApplicationFacade.CLOSE_SETTINGS_WINDOW );
		}
		
		private function performCancel_clickHandler( event : MouseEvent ) : void
		{
			sendNotification( ApplicationFacade.CLOSE_SETTINGS_WINDOW );
		}
	}
}