package vdom.controls.wysiwyg
{
import mx.controls.Text;
import mx.core.IUITextField;

public class SimpleText extends Text
{
	public function SimpleText()
	{
		super();
	}
//	private var _alpha:Number = 1;
	
//	public function set textAlpha(value:Number):void
//	{
//		_alpha = value
//	}
//	
//	override protected function childrenCreated():void
//    {
//        super.childrenCreated();
//        textField.alpha = _alpha;
//    }
	public function get textContainer():IUITextField
	{
		return textField;
	}
}
}