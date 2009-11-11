package net.vdombox.ide.modules
{
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.view.components.MainContent;
	import net.vdombox.ide.modules.applicationsManagment.view.components.Toolset;

	public class ApplicationsManagment extends VIModule
	{
		public static const NAME : String = "ApplicationsManagment";

		public function ApplicationsManagment()
		{
			super( ApplicationFacade.getInstance( NAME ));
			ApplicationFacade( facade ).startup( this );
		}
		
		override public function getToolset() : void
		{
			var button : Toolset = new Toolset();
			button.label = NAME;
			
			facade.sendNotification( ApplicationFacade.EXPORT_TOOLSET, button );
		}
		
		override public function getMainContent() : void
		{
			facade.sendNotification( ApplicationFacade.EXPORT_MAIN_CONTENT, new MainContent() );
		}
	}
}