package src.net.vdombox.powerpack.lib.extendedapi.controls
{
	import mx.controls.TextArea;
	import mx.core.IUITextField;

	public class SuperTextArea extends TextArea
	{
		public function SuperTextArea()
		{
			super();
		}
		
		public function get field():IUITextField
		{
			return super.textField;
		}
	}
}