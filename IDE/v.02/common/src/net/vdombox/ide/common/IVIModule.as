package net.vdombox.ide.common
{
	public interface IVIModule
	{
		function get moduleID() : String;

		function get moduleName() : String;

		function get hasToolset() : Boolean;

		function get hasPropertyScreen() : Boolean;

		function get hasBody() : Boolean;

		function getToolset() : void;

		function getPropertyScreen() : void;

		function getBody() : void;

		function tearDown() : void;
	}
}