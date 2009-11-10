package net.vdombox.ide.modules
{
	import net.vdombox.ide.common.VIModule;
	import net.vdombox.ide.modules.edition.ApplicationFacade;
	import net.vdombox.ide.modules.edition.view.components.Toolset;

	public class Edition extends VIModule
	{
		public static const NAME : String = "Edition";

		public function Edition()
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