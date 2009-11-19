package net.vdombox.ide.modules
{
	import flash.events.Event;
	
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.modules.applicationsSearch.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsSearch.view.components.MainContent;
	
	public class ApplicationsSearch extends VIModule
	{
		public static const MODULE_ID : String = "D37F3F0B-2FC6-4C76-338F-FB54D28FE1D1";
		
		public static const TEAR_DOWN:String = "tearDown";
		
		public function ApplicationsSearch()
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
		
		override public function getToolset() : void
		{
			facade.sendNotification( ApplicationFacade.CREATE_TOOLSET );
		}
		
		override public function getBody() : void
		{
			facade.sendNotification( ApplicationFacade.EXPORT_MAIN_CONTENT, new MainContent() );
		}
	}
}