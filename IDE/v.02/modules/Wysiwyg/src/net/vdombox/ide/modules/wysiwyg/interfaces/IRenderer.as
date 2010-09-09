package net.vdombox.ide.modules.wysiwyg.interfaces
{
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;

	public interface IRenderer
	{
		function get renderVO() : RenderVO
		function set renderVO( value : RenderVO ) : void
	}
}