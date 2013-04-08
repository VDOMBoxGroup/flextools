package net.vdombox.ide.common.interfaces
{

	public interface IVIModule
	{
		function get moduleID() : String;

		function get moduleName() : String;

		function get version() : String;

		function get hasToolset() : Boolean;

		function get hasSettings() : Boolean;

		function get hasBody() : Boolean;

		function getToolset() : void;

		function getSettingsScreen() : void;

		function getBody() : void;

		function initializeSettings() : void;

		function tearDown() : void;
	}
}
