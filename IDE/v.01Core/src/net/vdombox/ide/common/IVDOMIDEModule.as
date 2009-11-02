package net.vdombox.ide.common
{
	public interface IVDOMIDEModule
	{
		function get moduleID() : String;
		function get name() : String;
		
		function get icon() : Class;
		function get title() : String;
		
		function get toolset() : IToolset;
	}
}