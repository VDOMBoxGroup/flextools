package net.vdombox.ide.modules
{
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.modules.applicationsSearch.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsSearch.view.components.Toolset;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;

	public class ApplicationsSearch extends VIModule
	{
		public static const NAME : String = "ApplicationsSearch";
		
		private static const MODULE_ID : String = "359E390B-38DB-F09E-FFBA-E6EB27692859";

		public function ApplicationsSearch()
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
			var button : Toolset = new Toolset();
			button.label = NAME;

			facade.sendNotification( ApplicationFacade.EXPORT_TOOLSET, button );
		}
	}
}