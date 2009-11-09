package net.vdombox.ide.modules
{
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.modules.edition.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IFacade;

	public class Edition extends VIModule
	{
		public static const NAME : String = "Edition";

		public function Edition()
		{
			super( ApplicationFacade.getInstance( NAME ));
			ApplicationFacade( facade ).startup( this );
		}
	}
}