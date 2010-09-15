package net.vdombox.ide.modules.wysiwyg.interfaces
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;

	public interface IRenderer
	{
		function get renderVO() : RenderVO
		function set renderVO( value : RenderVO ) : void
			
		function get vdomObjectVO() : IVDOMObjectVO
			
		function get typeVO() : TypeVO
			
		function get movable() : Boolean;
		function get resizable() : uint;
		
		function get editableComponent() : Object;
		
		function lock( isRemoveChildren : Boolean = false ) : void
	}
}