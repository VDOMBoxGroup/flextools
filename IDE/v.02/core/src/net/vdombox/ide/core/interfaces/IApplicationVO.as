package net.vdombox.ide.core.interfaces
{

	public interface IApplicationVO
	{
		function get id() : String

		function get name() : String

		function get description() : String

		function get serverVersion() : String

		function get iconID() : String

		function get indexPageID() : String

		function get numberOfPages() : int

		function get numberOfObjects() : int

		function get scriptingLanguage() : String
	}
}