package net.vdombox.components.xmldialogeditor.model.vo.components
{
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentAddition;
	
	public class UploadVO extends ComponentAddition
	{
		public function UploadVO(value:XML)
		{
			super(value);
			
			name = "Upload";
		}
	}
}