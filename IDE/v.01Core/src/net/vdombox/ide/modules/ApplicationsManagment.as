package net.vdombox.ide.modules
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.view.components.MainContent;

	public class ApplicationsManagment extends VIModule
	{
		public static const MODULE_ID : String = "04D1487D-F14E-0FE5-82F9-E6E8FEFCD2CD";
		
		public function ApplicationsManagment()
		{
			super( ApplicationFacade.getInstance( MODULE_ID ));
			ApplicationFacade( facade ).startup( this );
		}
		
		private var resourceManager : IResourceManager = ResourceManager.getInstance();
		
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