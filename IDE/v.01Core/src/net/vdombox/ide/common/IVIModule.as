package net.vdombox.ide.common
{
	import mx.core.UIComponent;

	import net.vdombox.ide.core.interfaces.IToolset;

	public interface IVIModule
	{
		function get moduleID() : String;
		
		function get settings() : UIComponent;

		function getToolset() : void;
		
		function getMainContent() : void;
		
		function tearDown() : void;
	}
}