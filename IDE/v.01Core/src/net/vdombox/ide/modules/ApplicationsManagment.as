package net.vdombox.ide.modules
{
	import net.vdombox.ide.common.VDOMIDEModule;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;

	public class ApplicationsManagment extends VDOMIDEModule
	{
		public static const NAME : String = "ApplicationsManagment";

		public function ApplicationsManagment()
		{
			super( ApplicationFacade.getInstance( NAME ));
//			ApplicationFacade( facade ).startup( this );
		}
	}
}