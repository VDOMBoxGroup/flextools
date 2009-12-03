package net.vdombox.ide.modules
{
	import flash.events.Event;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.modules.edition.ApplicationFacade;
	import net.vdombox.ide.modules.edition.view.components.Body;

	public class Edition extends VIModule
	{
		public static const MODULE_ID : String = "net.vdombox.ide.modules.Edition";
		
		public static const MODULE_NAME : String = "Edition";
		
		public static const TEAR_DOWN:String = "tearDown";
		
		public function Edition()
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