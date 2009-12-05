package net.vdombox.ide.modules
{
	import flash.events.Event;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;

	public class Wysiwyg extends VIModule
	{
		public static const MODULE_ID : String = "net.vdombox.ide.modules.Wysiwyg";
		
		public static const MODULE_NAME : String = "Wysiwyg";
		
		public static const TEAR_DOWN:String = "tearDown";
		
		public function Wysiwyg()
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
		
		override public function getBody() : void
		{
			facade.sendNotification( ApplicationFacade.CREATE_BODY );
		}
	}
}