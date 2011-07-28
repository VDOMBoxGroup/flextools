package net.vdombox.ide.modules.wysiwyg.interfaces
{
	import flash.events.IEventDispatcher;
	
	import mx.core.IUIComponent;
	
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.VdomObjectXMLPresentationVO;
	import net.vdombox.ide.modules.wysiwyg.model.vo.EditorVO;

	public interface IEditor extends IEventDispatcher
	{
		function get editorVO() : EditorVO

		function get status() : uint
		function set status( value : uint ) : void
		function set xmlPresentation(value: VdomObjectXMLPresentationVO): void
		function get xmlPresentation(): VdomObjectXMLPresentationVO
		function get state() : String
			
		function set selectedRenderer( value : IRenderer ):void
		function get selectedRenderer( ) : IRenderer	
	}
}