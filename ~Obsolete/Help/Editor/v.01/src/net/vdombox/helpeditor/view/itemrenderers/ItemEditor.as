package net.vdombox.helpeditor.view.itemrenderers
{
	import mx.controls.TextInput;
	
	public class ItemEditor extends TextInput
	{
		public function ItemEditor()
		{
			super();
			
			restrict = "a-zA-Z0-9\- ";
		}
	}
}