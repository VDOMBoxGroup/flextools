package net.vdombox.ide.modules.wysiwyg.interfaces
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.VdomObjectAttributesVO;

	public interface IToolbar
	{
		function get attributes() : Array

		function get item() : IRenderer
			
//		function get vdomObjectAttributesVO() : VdomObjectAttributesVO 	

		function init( item : IRenderer ) : void
			
		function refresh( item : IRenderer ) : void

		function close() : void
			
		function saveValue() : String
			
		function get vdomObjectAttributesVO(): VdomObjectAttributesVO 	
	}
}