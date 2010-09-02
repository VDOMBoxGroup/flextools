package net.vdombox.ide.modules.wysiwyg.interfaces
{
	import mx.core.IUIComponent;
	
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;

	public interface IEditor
	{
		function get vdomObjectVO () : IVDOMObjectVO
		function set vdomObjectVO ( value : IVDOMObjectVO ) : void
	}
}