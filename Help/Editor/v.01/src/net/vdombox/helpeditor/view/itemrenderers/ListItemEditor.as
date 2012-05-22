package net.vdombox.helpeditor.view.itemrenderers
{
	import mx.controls.TextInput;
	
	public class ListItemEditor extends TextInput
	{
		public function ListItemEditor()
		{
			super();
			
			restrict = "a-zA-Z0-9\- ";
		}
	}
}