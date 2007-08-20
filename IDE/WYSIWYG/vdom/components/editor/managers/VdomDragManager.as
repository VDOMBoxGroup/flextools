package vdom.components.editor.managers
{
import mx.core.IUIComponent;
import mx.core.DragSource;
import flash.events.MouseEvent;
import mx.core.IFlexDisplayObject;
import mx.core.Singleton;
	
public class VdomDragManager
{
    /**
     *  @private
     *  Linker dependency on implementation class.
     */
    private static var implClassDependency:VdomDragManagerImpl;

	/**
	 *  @private
	 */
	private static var impl:IVdomDragManager = Singleton
		.getInstance("vdom.components.editor.managers::IVdomDragManager") as IVdomDragManager;
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	public static function doDrag(
			dragInitiator:IUIComponent, 
			dragSource:DragSource, 
			mouseEvent:MouseEvent,
			dragImage:IFlexDisplayObject = null, // instance of dragged item(s)
			xOffset:Number = 0,
			yOffset:Number = 0,
			imageAlpha:Number = 0.5,
			allowMove:Boolean = true):void
	{
		impl.doDrag(dragInitiator, dragSource, mouseEvent, dragImage, xOffset,
				yOffset, imageAlpha, allowMove);
	}
	
	public static function acceptDragDrop(target:IUIComponent):void
	{
		impl.acceptDragDrop(target);
	}
	public static function endDrag():void
	{
		impl.endDrag();
	}
}
}

