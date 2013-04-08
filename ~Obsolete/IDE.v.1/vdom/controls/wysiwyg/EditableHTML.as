package vdom.controls.wysiwyg
{
import mx.controls.HTML;

public class EditableHTML extends HTML {
	
	public function EditableHTML()
	{
		super();
	}
	
	public function get editabledText():String
	{
		if(loaded)
			return domWindow.document.getElementsByTagName("body")[0].innerHTML;
		else
			return null;
	}
	
	public function set editabledText(value:*):void
	{
		if(loaded)
			domWindow.document.getElementsByTagName("body")[0].innerHTML = value;
	}
}
}