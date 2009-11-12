package net.vdombox.ide.modules
{
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.view.components.MainContent;

	public class ApplicationsManagment extends VIModule
	{
		public static const NAME : String = "ApplicationsManagment";
		
		private static const MODULE_ID : String = "04D1487D-F14E-0FE5-82F9-E6E8FEFCD2CD";
		
		public function ApplicationsManagment()
		{
			super( ApplicationFacade.getInstance( NAME ));
			ApplicationFacade( facade ).startup( this );
		}
		
		override public function get moduleID() : String
		{
			return MODULE_ID;
		}
		
		override public function getToolset() : void
		{
			facade.sendNotification( ApplicationFacade.CREATE_TOOLSET );
		}
		
		override public function getMainContent() : void
		{
			facade.sendNotification( ApplicationFacade.EXPORT_MAIN_CONTENT, new MainContent() );
		}
	}
}