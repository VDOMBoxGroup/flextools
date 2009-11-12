package net.vdombox.ide.modules
{
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.modules.edition.ApplicationFacade;
	import net.vdombox.ide.modules.edition.view.components.Toolset;

	public class Edition extends VIModule
	{
		public static const NAME : String = "Edition";
		
		private static const MODULE_ID : String = "C594A2ED-B7C2-B577-D643-E6EB3FA4B90E";

		public function Edition()
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