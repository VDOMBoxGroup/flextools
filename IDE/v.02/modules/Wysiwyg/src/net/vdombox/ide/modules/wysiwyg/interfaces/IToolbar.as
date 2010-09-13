package net.vdombox.ide.modules.wysiwyg.interfaces
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;

	public interface IToolbar
	{
		function get attributes() : Array

		function get item() : IRenderer

		function init( item : IRenderer ) : void

		function close() : void
	}
}