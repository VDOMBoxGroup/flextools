package net.vdombox.ide.common
{
	import mx.core.UIComponent;

	public interface IVIModule
	{
		function get moduleID() : String;

		function getToolset() : void;
		
		function getPropertyScreen() : void;
		
		function getBody() : void;
		
		function tearDown() : void;
	}
}