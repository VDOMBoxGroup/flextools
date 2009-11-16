package net.vdombox.ide.common
{
	import mx.core.UIComponent;

	import net.vdombox.ide.core.interfaces.IToolset;

	public interface IVIModule
	{
		function get moduleID() : String;

		function getToolset() : void;
		
		function getBody() : void;
		
		function tearDown() : void;
	}
}