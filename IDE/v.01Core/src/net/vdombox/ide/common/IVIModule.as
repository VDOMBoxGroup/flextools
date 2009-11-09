package net.vdombox.ide.common
{
	import mx.core.UIComponent;
	
	import net.vdombox.ide.core.interfaces.IToolset;

	public interface IVIModule
	{
		function get moduleID() : String;
//		function get name() : String;

//		function get icon() : Class;
//		function get title() : String;

		function get toolset() : IToolset;
		function get mainContent() : UIComponent;
		function get settings() : UIComponent;
	}
}