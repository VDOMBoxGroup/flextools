package net.vdombox.ide.modules
{
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;

	public class ApplicationsManagment extends VIModule
	{
		public static const NAME : String = "ApplicationsManagment";

		public function ApplicationsManagment()
		{
			super( ApplicationFacade.getInstance( NAME ));
			ApplicationFacade( facade ).startup( this );
		}
	}
}