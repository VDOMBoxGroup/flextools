package net.vdombox.ide.modules.edit
{
	import net.vdombox.ide.modules.Edit;
	import net.vdombox.ide.modules.edit.controller.CreateBodyCommand;
	import net.vdombox.ide.modules.edit.controller.CreateToolsetCommand;
	import net.vdombox.ide.modules.edit.controller.StartupCommand;
	import net.vdombox.ide.modules.edit.controller.TearDownCommand;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class ApplicationFacade extends Facade implements IFacade
	{
		public static const STARTUP : String = "startup";
		
		public static const CREATE_TOOLSET : String = "createToolset";
		public static const CREATE_BODY : String = "createBody";
		
		public static const EXPORT_TOOLSET : String = "exportToolset";
		public static const EXPORT_BODY : String = "exportBody";
		
		public static const MODULE_SELECTED : String = "moduleSelected";
		public static const MODULE_DESELECTED : String = "moduleDeselected";
		
		public static const CONNECT_PROXIES_PIPE : String = "connectProxiesPipe";
		
		public static const GET_SELECTED_APPLICATION : String = "getSelectedApplication";
//		public static const GET_SELECTED_GETTED : String = "selectedApplicationGetted";
		public static const SET_SELECTED_APPLICATION : String = "setSelectedApplication";
		
		public static const SELECTED_APPLICATION_CHANGED : String = "selectedApplicationChanged";
		
		public static const GET_APPLICATIONS_LIST : String = "getApplicationsList";
		public static const APPLICATIONS_LIST_GETTED : String = "applicationsListGetted";
		
		public static const GET_RESOURCE : String = "getResource";
		public static const RESOURCE_GETTED : String = "resourceGetted";
		
		public static const TEAR_DOWN : String = "tearDown";
		
		public static function getInstance( key : String ) : ApplicationFacade
		{
			if ( instanceMap[ key ] == null )
				instanceMap[ key ] = new ApplicationFacade( key );
			return instanceMap[ key ] as ApplicationFacade;
		}

		public function ApplicationFacade( key : String )
		{
			super( key );
		}
		
		public function startup( application : Edit ) : void
		{
			sendNotification( STARTUP, application );
		}
		
		override protected function initializeController( ) : void 
		{
			super.initializeController();
			registerCommand( STARTUP, StartupCommand );
			registerCommand( CREATE_TOOLSET, CreateToolsetCommand );
			registerCommand( CREATE_BODY, CreateBodyCommand );
			registerCommand( TEAR_DOWN, TearDownCommand );
		}
	}
}