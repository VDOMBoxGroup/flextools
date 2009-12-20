package net.vdombox.ide.modules
{
	import flash.events.Event;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.modules.resourceBrowser.ApplicationFacade;

	public class ResourceBrowser extends VIModule
	{
		public static const MODULE_ID : String = "net.vdombox.ide.modules.ResourceBrowser";
		
		public static const MODULE_NAME : String = "ResourceBrowser";
		
		public static const VERSION : String = "0.0.1";
		
		public static const TEAR_DOWN:String = "tearDown";
		
		public function ResourceBrowser()
		{
			super( ApplicationFacade.getInstance( MODULE_ID ));
			ApplicationFacade( facade ).startup( this );
		}
		
		private var resourceManager : IResourceManager = ResourceManager.getInstance();
		
		override public function tearDown():void
		{
			dispatchEvent( new Event( TEAR_DOWN ) );
		}
		
		override public function get moduleID() : String
		{
			return MODULE_ID;
		}
		
		override public function get moduleName() : String
		{
			return MODULE_NAME;
		}
		
		override public function get version() : String
		{
			return MODULE_NAME;
		}
		
		override public function get hasToolset() : Boolean
		{
			return true;
		}
		
		override public function get hasSettings() : Boolean
		{
			return true;
		}
		
		override public function get hasBody() : Boolean
		{
			return true;
		}
		
		override public function getToolset() : void
		{
			facade.sendNotification( ApplicationFacade.CREATE_TOOLSET );
		}
		
		override public function getSettingsScreen() : void
		{
			facade.sendNotification( ApplicationFacade.CREATE_SETTINGS_SCREEN );
		}
		
		override public function getBody() : void
		{
			facade.sendNotification( ApplicationFacade.CREATE_BODY );
		}
		
		override public function initializeSettings() : void
		{
			facade.sendNotification( ApplicationFacade.INITIALIZE_SETTINGS );
		}
	}
}