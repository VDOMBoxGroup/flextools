package net.vdombox.ide.modules
{
	import flash.events.Event;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.modules.edit.ApplicationFacade;
	import net.vdombox.ide.modules.edit.view.components.Body;

	public class Edit extends VIModule
	{
		public static const MODULE_ID : String = "04D1487D-F14E-0FE5-82F9-E6E8FEFCD2CD";
		
		public static const MODULE_NAME : String = "Edit";
		
		public static const TEAR_DOWN:String = "tearDown";
		
		public function Edit()
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
		
		override public function getToolset() : void
		{
			facade.sendNotification( ApplicationFacade.CREATE_TOOLSET );
		}
		
		override public function getBody() : void
		{
			facade.sendNotification( ApplicationFacade.CREATE_BODY );
		}
	}
}