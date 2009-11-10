package net.vdombox.ide.modules
{
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.modules.applicationsSearch.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsSearch.view.components.Toolset;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;

	public class ApplicationsSearch extends VIModule
	{
		public static const NAME : String = "ApplicationsSearch";

		public function ApplicationsSearch()
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
	}
}