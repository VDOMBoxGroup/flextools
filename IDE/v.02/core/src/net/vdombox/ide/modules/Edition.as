package net.vdombox.ide.modules
{
	import flash.events.Event;
	
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.modules.edition.ApplicationFacade;
	import net.vdombox.ide.modules.edition.view.components.MainContent;
	
	public class Edition extends VIModule
	{
		public static const MODULE_ID : String = "433B3EB7-E872-9A2C-39AB-FB919E5148F5";
		
		public static const TEAR_DOWN:String = "tearDown";
		
		public function Edition()
		{
			super( ApplicationFacade.getInstance( MODULE_ID ));
			ApplicationFacade( facade ).startup( this );
		}
		
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